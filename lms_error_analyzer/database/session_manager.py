#!/usr/bin/env python3
"""
Session-based File Upload Tracking

Manages upload sessions to ensure orphan detection only runs on files 
uploaded in the current session, not historical data.
"""

import os
import json
import uuid
import logging
from datetime import datetime
from typing import List, Dict, Optional, Any
from dataclasses import dataclass, asdict
import mysql.connector
from mysql.connector import Error as MySQLError
from dotenv import load_dotenv

load_dotenv()
logger = logging.getLogger(__name__)

@dataclass
class UploadedFile:
    """Tracks a file uploaded in a session"""
    front_end_name: str
    original_file_name: str
    canonical_table: str
    row_count: int
    checksum_md5: str
    uploaded_at: str
    uploader: str

@dataclass
class SessionConfig:
    """Session configuration for orphan detection"""
    session_id: str
    reset: bool = False
    domains: List[str] = None
    mysql_target: Dict[str, Any] = None
    rules: Dict[str, bool] = None
    front_end_name_to_table: Dict[str, str] = None
    uploaded_files: List[UploadedFile] = None
    active_tables: Dict[str, List[str]] = None

    def __post_init__(self):
        if self.domains is None:
            self.domains = ["activities", "employees", "orgs"]
        if self.mysql_target is None:
            self.mysql_target = {
                "host": os.getenv('MYSQL_HOST', 'localhost'),
                "port": int(os.getenv('MYSQL_PORT', 3306)),
                "schema": os.getenv('MYSQL_NAME', 'error_logging')
            }
        if self.rules is None:
            self.rules = {
                "run_if_uploaded_only": True,
                "require_session_match": True,
                "delete_today_rows_before_insert": True
            }
        if self.front_end_name_to_table is None:
            self.front_end_name_to_table = {
                # Activity mappings
                "Activities - Curriculum": "activity_curriculum",
                "Activities - Quick Assessment": "activity_test",
                "Activities - ILT Sessions": "activity_sessionparts",
                "Activities - ILT Class": "activity_sessions", 
                "Activities - ILT Course": "activity_events",
                "Activities - Online Course": "activity_onlinecourse",
                "Activities - Document": "activity_material",
                
                # Transcript mappings
                "Employees - Transcript Curriculum": "transcript_curriculumtranscript",
                "Employees - Transcript Document": "transcript_materialtranscript",
                "Employees - Transcript ILT Class": "transcript_sessiontranscript",
                "Employees - Transcript Online Course": "transcript_onlinecourse",
                "Employees - Transcript Quick Assessment": "transcript_testtranscript",
                
                # Core employee mappings
                "Employees - Core": "core_employee",
                "Employees - Prerequisites Instructor": "prerequisites_instructor",
                
                # Core mappings
                "Core - Audience": "core_groupsou",
                "Core - Jobs": "core_positionou",
                
                # Organization mappings
                "Organizations - Orgs": "core_costcenterou",
                "Organizations - Domains": "core_divisionou",
                
                # Prerequisites mappings
                "Prerequisites - Facility": "prerequisites_facility",
                "Prerequisites - Provider": "prerequisites_provider",
                "Prerequisites - Question": "prerequisites_questions",
                "Prerequisites - Question Banks": "prerequisites_questionscategories",
                "Prerequisites - Subject": "prerequisites_subject"
            }
        if self.uploaded_files is None:
            self.uploaded_files = []
        if self.active_tables is None:
            self.active_tables = {
                "activities": [
                    "activity_curriculum", "activity_test", "activity_sessionparts", 
                    "activity_sessions", "activity_events", "activity_onlinecourse", 
                    "activity_material"
                ],
                "employees": [
                    "core_employee", "prerequisites_instructor", 
                    "transcript_curriculumtranscript", "transcript_materialtranscript",
                    "transcript_sessiontranscript", "transcript_onlinecourse", 
                    "transcript_testtranscript"
                ],
                "orgs": [
                    "core_costcenterou", "core_divisionou", "core_groupsou", 
                    "core_positionou", "prerequisites_facility", "prerequisites_provider",
                    "prerequisites_questions", "prerequisites_questionscategories", 
                    "prerequisites_subject"
                ]
            }

class SessionManager:
    """Manages upload sessions and file tracking"""
    
    def __init__(self):
        self.current_session: Optional[SessionConfig] = None
        self._init_db_tables()
        self._load_most_recent_session()
    
    def _get_db_connection(self) -> mysql.connector.MySQLConnection:
        """Create MySQL connection using environment variables"""
        try:
            connection = mysql.connector.connect(
                host=os.getenv('MYSQL_HOST', 'localhost'),
                user=os.getenv('MYSQL_USER'),
                password=os.getenv('MYSQL_PASSWORD'),
                database=os.getenv('MYSQL_NAME'),
                autocommit=False,
                charset='utf8mb4',
                collation='utf8mb4_unicode_ci',
                port=int(os.getenv('MYSQL_PORT', 3306))
            )
            return connection
        except MySQLError as e:
            logger.error(f"❌ Failed to connect to MySQL: {e}")
            raise
    
    def _init_db_tables(self):
        """Create session tracking tables if they don't exist"""
        try:
            conn = self._get_db_connection()
            cursor = conn.cursor()
            
            # Session tracking table
            cursor.execute("""
                CREATE TABLE IF NOT EXISTS upload_sessions (
                    session_id VARCHAR(36) PRIMARY KEY,
                    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                    reset_at DATETIME NULL,
                    config_json TEXT NOT NULL,
                    is_active BOOLEAN DEFAULT TRUE,
                    INDEX idx_created_at (created_at),
                    INDEX idx_active (is_active)
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
            """)
            
            # Session-scoped file tracking table (authoritative source for uploaded files)
            cursor.execute("""
                CREATE TABLE IF NOT EXISTS file_ingest_log_session (
                    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
                    session_id VARCHAR(36) NOT NULL,
                    front_end_name VARCHAR(255) NOT NULL,
                    original_file_name VARCHAR(255) NOT NULL,
                    canonical_table VARCHAR(128) NOT NULL,
                    row_count INT NOT NULL DEFAULT 0,
                    checksum_md5 VARCHAR(32) NOT NULL,
                    uploaded_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                    uploader VARCHAR(128) DEFAULT 'system',
                    INDEX idx_session_id (session_id),
                    INDEX idx_canonical_table (canonical_table),
                    INDEX idx_uploaded_at (uploaded_at),
                    CONSTRAINT fk_file_ingest_log_session
                        FOREIGN KEY (session_id) REFERENCES upload_sessions(session_id) ON DELETE CASCADE
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
            """)
            
            conn.commit()
            cursor.close()
            conn.close()
            logger.info("✅ Session tracking tables initialized successfully")
        except Exception as e:
            logger.error(f"❌ Failed to initialize session tables: {e}")
            logger.error(f"❌ Database connection details: {os.getenv('MYSQL_HOST')}:{os.getenv('MYSQL_PORT')}/{os.getenv('MYSQL_NAME')}")
            # Don't raise - let the application continue but log the issue
    
    def _load_most_recent_session(self):
        """Automatically load the most recent active session on initialization"""
        try:
            conn = self._get_db_connection()
            cursor = conn.cursor(dictionary=True)
            cursor.execute("""
                SELECT session_id FROM upload_sessions 
                WHERE is_active = TRUE 
                ORDER BY created_at DESC LIMIT 1
            """)
            row = cursor.fetchone()
            cursor.close()
            conn.close()
            
            if row:
                session_config = self.load_session(row['session_id'])
                if session_config:
                    logger.info(f"🔄 Auto-loaded recent session: {row['session_id']} with {len(session_config.uploaded_files)} files")
                else:
                    logger.debug("📝 No recent session found or failed to load")
            else:
                logger.debug("📝 No active sessions found")
                
        except Exception as e:
            logger.debug(f"📝 Could not auto-load recent session: {e}")
            # Don't fail initialization if session loading fails
    
    def start_new_session(self, uploader: str = "system") -> str:
        """Start a new upload session"""
        session_id = str(uuid.uuid4())
        session_config = SessionConfig(session_id=session_id)
        
        try:
            conn = self._get_db_connection()
            cursor = conn.cursor()
            
            cursor.execute("""
                INSERT INTO upload_sessions (session_id, config_json)
                VALUES (%s, %s)
            """, (session_id, json.dumps(asdict(session_config))))
            
            conn.commit()
            cursor.close()
            conn.close()
            
            self.current_session = session_config
            logger.info(f"✅ Started new session: {session_id}")
            return session_id
            
        except Exception as e:
            logger.error(f"❌ Failed to start new session: {e}")
            raise
    
    def load_session(self, session_id: str) -> Optional[SessionConfig]:
        """Load an existing session"""
        try:
            conn = self._get_db_connection()
            cursor = conn.cursor(dictionary=True)
            
            cursor.execute("""
                SELECT config_json FROM upload_sessions 
                WHERE session_id = %s AND is_active = TRUE
            """, (session_id,))
            
            row = cursor.fetchone()
            if not row:
                cursor.close()
                conn.close()
                return None
            
            # Load uploaded files for this session from authoritative table
            cursor.execute("""
                SELECT front_end_name, original_file_name, canonical_table, 
                       row_count, checksum_md5, uploaded_at, uploader
                FROM file_ingest_log_session 
                WHERE session_id = %s
                ORDER BY uploaded_at
            """, (session_id,))
            
            files_data = cursor.fetchall()
            cursor.close()
            conn.close()
            
            # Reconstruct session config
            config_dict = json.loads(row['config_json'])
            config_dict['uploaded_files'] = [
                UploadedFile(
                    front_end_name=f['front_end_name'],
                    original_file_name=f['original_file_name'],
                    canonical_table=f['canonical_table'],
                    row_count=f['row_count'],
                    checksum_md5=f['checksum_md5'],
                    uploaded_at=f['uploaded_at'].isoformat(),
                    uploader=f['uploader']
                ) for f in files_data
            ]
            
            session_config = SessionConfig(**config_dict)
            self.current_session = session_config
            return session_config
            
        except Exception as e:
            logger.error(f"❌ Failed to load session {session_id}: {e}")
            return None
    
    def add_uploaded_file(self, front_end_name: str, original_file_name: str, 
                         row_count: int, checksum_md5: str, uploader: str = "system") -> bool:
        """Add a file to the current session"""
        if not self.current_session:
            logger.error("❌ No active session to add file to")
            return False
        
        # Map frontend name to canonical table
        canonical_table = self.current_session.front_end_name_to_table.get(front_end_name)
        if not canonical_table:
            logger.error(f"❌ Unknown frontend file type: {front_end_name}")
            return False
        
        try:
            conn = self._get_db_connection()
            cursor = conn.cursor()
            
            # Verify session exists before recording file upload
            cursor.execute("SELECT session_id FROM upload_sessions WHERE session_id = %s", 
                         (self.current_session.session_id,))
            if not cursor.fetchone():
                logger.warning(f"⚠️ Session {self.current_session.session_id} not found in database, creating new session")
                cursor.close()
                conn.close()
                # Create a new session and retry
                self.start_new_session(uploader)
                return self.add_uploaded_file(front_end_name, original_file_name, row_count, checksum_md5, uploader)
            
            # Record file upload in authoritative session table
            cursor.execute("""
                INSERT INTO file_ingest_log_session 
                (session_id, front_end_name, original_file_name, canonical_table, 
                 row_count, checksum_md5, uploader)
                VALUES (%s, %s, %s, %s, %s, %s, %s)
            """, (
                self.current_session.session_id, front_end_name, original_file_name,
                canonical_table, row_count, checksum_md5, uploader
            ))
            
            conn.commit()
            cursor.close()
            conn.close()
            
            # Add to current session config
            uploaded_file = UploadedFile(
                front_end_name=front_end_name,
                original_file_name=original_file_name,
                canonical_table=canonical_table,
                row_count=row_count,
                checksum_md5=checksum_md5,
                uploaded_at=datetime.now().isoformat(),
                uploader=uploader
            )
            self.current_session.uploaded_files.append(uploaded_file)
            
            logger.info(f"✅ Added file to session {self.current_session.session_id}: {original_file_name} -> {canonical_table}")
            return True
            
        except Exception as e:
            logger.error(f"❌ Failed to add file to session: {e}")
            return False
    
    def reset_session(self, session_id: Optional[str] = None) -> bool:
        """Reset session (clear uploaded files)"""
        target_session_id = session_id or (self.current_session.session_id if self.current_session else None)
        if not target_session_id:
            logger.error("❌ No session to reset")
            return False
        
        try:
            conn = self._get_db_connection()
            cursor = conn.cursor()
            
            # Mark session as reset and clear files
            cursor.execute("""
                UPDATE upload_sessions 
                SET reset_at = CURRENT_TIMESTAMP, 
                    config_json = JSON_SET(config_json, '$.reset', TRUE, '$.uploaded_files', JSON_ARRAY())
                WHERE session_id = %s
            """, (target_session_id,))
            
            # Clear uploaded files from authoritative session table
            cursor.execute("""
                DELETE FROM file_ingest_log_session WHERE session_id = %s
            """, (target_session_id,))
            
            conn.commit()
            cursor.close()
            conn.close()
            
            # Update current session if it's the one being reset
            if self.current_session and self.current_session.session_id == target_session_id:
                self.current_session.reset = True
                self.current_session.uploaded_files = []
            
            logger.info(f"✅ Reset session: {target_session_id}")
            return True
            
        except Exception as e:
            logger.error(f"❌ Failed to reset session {target_session_id}: {e}")
            return False
    
    def get_uploaded_tables_for_domain(self, domain: str) -> List[str]:
        """Get list of tables that have been uploaded for a domain in current session"""
        if not self.current_session or not self.current_session.uploaded_files:
            return []
        
        domain_tables = self.current_session.active_tables.get(domain, [])
        uploaded_tables = [f.canonical_table for f in self.current_session.uploaded_files]
        
        return [table for table in domain_tables if table in uploaded_tables]
    
    def should_run_orphan_detection(self, domain: str) -> bool:
        """Check if orphan detection should run for a domain"""
        if not self.current_session:
            return False
        
        if self.current_session.reset:
            return False
        
        if self.current_session.rules.get("run_if_uploaded_only", True):
            uploaded_tables = self.get_uploaded_tables_for_domain(domain)
            return len(uploaded_tables) > 0
        
        return True
    
    def get_session_json(self) -> str:
        """Get current session as JSON for logging/debugging"""
        if not self.current_session:
            return "{}"
        return json.dumps(asdict(self.current_session), indent=2, default=str)

# Global session manager instance
session_manager = SessionManager()
