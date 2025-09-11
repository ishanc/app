#!/usr/bin/env python3
"""
SumTotal→CSOD Orphan Tracker (Session-based)
Only runs orphan detection on files uploaded in the current session

Changes in this version:
- Session-based file tracking - only process uploaded files
- Use sargable time range filters (no DATE() wrapper) for today's rows
- Commit per-domain (Activities, then Employees) to reduce lock footprint
- Set safe session params (lock wait timeout, isolation)
- Harden logging: clamp valid>=0; 'N/A' when integrity is NULL
"""

import os
import logging
import mysql.connector
from mysql.connector import Error as MySQLError
from dotenv import load_dotenv
from neo4j import GraphDatabase
from dataclasses import dataclass
from typing import List, Dict, Optional, Any
from session_manager import session_manager

# Set up logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(name)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

@dataclass
class OrphanRule:
    """Simple data class for orphan detection rules from Neo4j"""
    business_rule: str
    fk_field: str
    fk_file: str
    pk_field: str
    pk_file: str
    pk_entity: str
    relationship_type: str = "many_to_one"
    validation_priority: str = "Medium"
    orphan_impact: str = "Data integrity violation"

# -----------------------------
# DB helpers
# -----------------------------

def _db_conn() -> mysql.connector.MySQLConnection:
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
        logger.debug("✅ MySQL connection established")
        return connection
    except MySQLError as e:
        logger.error(f"❌ Failed to connect to MySQL: {e}")
        raise

def _tune_session(conn: mysql.connector.MySQLConnection) -> None:
    """Apply safe session parameters for lower lock contention."""
    try:
        c = conn.cursor()
        c.execute("SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci")
        c.execute("SET SESSION innodb_lock_wait_timeout = 60")
        c.execute("SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED")
        c.close()
    except Exception as e:
        logger.warning(f"Could not tune session: {e}")

def _log_where_am_i(conn):
    c = conn.cursor()
    c.execute("SELECT @@hostname, @@port, DATABASE(), @@version")
    h, p, d, v = c.fetchone()
    logger.info(f"📡 MySQL target = {h}:{p} / {d}  (v={v})")
    c.close()

# -----------------------------
# SQL runner
# -----------------------------

def run_sql(sql_filename: str, connection: mysql.connector.MySQLConnection):
    """Execute SQL script from sql/ directory (split on ';')."""
    try:
        current_dir = os.path.dirname(os.path.abspath(__file__))
        project_root = os.path.dirname(os.path.dirname(current_dir))
        sql_path = os.path.join(project_root, 'sql', sql_filename)

        if not os.path.exists(sql_path):
            raise FileNotFoundError(f"SQL file not found: {sql_path}")

        with open(sql_path, 'r', encoding='utf-8') as f:
            sql_content = f.read()

        # Verification logging to ensure we're executing the right file
        import hashlib
        logger.info("🔍 SQL File Verification:")
        logger.info(f"   Path: {os.path.abspath(sql_path)}")
        logger.info(f"   MD5: {hashlib.md5(sql_content.encode()).hexdigest()[:8]}")
        logger.info(f"   First line: {sql_content.splitlines()[0] if sql_content else 'EMPTY FILE'}")
        logger.info(f"   File size: {len(sql_content)} characters")

        cursor = connection.cursor()
        for statement in sql_content.split(';'):
            stmt = statement.strip()
            if stmt and not stmt.startswith('--'):
                cursor.execute(stmt)
        cursor.close()
        logger.debug(f"✅ Executed SQL script: {sql_filename}")

    except Exception as e:
        logger.error(f"❌ Failed to execute SQL script {sql_filename}: {e}")
        raise

# -----------------------------
# Logging helpers
# -----------------------------

def _log_orphan_results(conn, domain_name, where_clause):
    """Standardized logging for orphan detection results (today)."""
    try:
        cursor = conn.cursor(dictionary=True)
        cursor.execute(f"""
          SELECT relationship_name, key_field, total_source_records,
                 orphaned_source_records, integrity_percentage, business_priority
          FROM cross_file_integrity_summary
          WHERE analysis_timestamp >= CURRENT_DATE()
            AND analysis_timestamp <  CURRENT_DATE() + INTERVAL 1 DAY
            AND discovered_from_neo4j = 1
            AND ({where_clause})
          ORDER BY relationship_name
        """)
        rows = cursor.fetchall()
        cursor.close()

        if rows:
            logger.info(f"📊 {domain_name} Orphan Detection Results ({len(rows)} relationships):")
            for row in rows:
                total = int(row.get('total_source_records') or 0)
                orphaned = int(row.get('orphaned_source_records') or 0)
                valid_records = max(total - orphaned, 0)
                # exact % uses computed valid/total when total>0
                exact_pct = (valid_records / total * 100.0) if total > 0 else 100.0
                integrity_val = row.get('integrity_percentage')
                integrity_str = f"{float(integrity_val):.2f}%" if integrity_val is not None else "N/A"

                logger.info(f"  📋 {row['relationship_name']}")
                logger.info(f"     • Key Field: {row['key_field']}")
                logger.info(f"     • Total Records: {total:,}")
                logger.info(f"     • Valid Records: {valid_records:,}")
                logger.info(f"     • Orphaned Records: {orphaned:,}")
                logger.info(f"     • Integrity: {integrity_str} (exact: {exact_pct:.4f}%)")
                logger.info(f"     • Priority: {row['business_priority']}")
                logger.info("")
        else:
            logger.warning(f"⚠️  No {domain_name} orphan detection results found for today")

    except Exception as e:
        logger.error(f"❌ Failed to retrieve {domain_name} execution results: {e}")

def _log_activities_results(conn):
    """Log Activities orphan detection results"""
    _log_orphan_results(conn, "Activities", "relationship_name LIKE 'Activities.%'")

def _log_orgs_results(conn):
    """Log Organizations orphan detection results"""
    _log_orphan_results(conn, "Organizations", "relationship_name LIKE 'Orgs.%'")

# -----------------------------
# PDF helper classes
# -----------------------------

class ActivitiesOrphanExecutor:
    """Simple executor for Activities domain - just for PDF compatibility"""

    @staticmethod
    def get_activities_orphan_summaries_for_pdf():
        """Get today's Activity orphan summaries for PDF reporting"""
        try:
            conn = _db_conn()
            try:
                _tune_session(conn)
                cursor = conn.cursor(dictionary=True)
                cursor.execute(
                    """
                  SELECT analysis_run_id, relationship_name, key_field, total_source_records,
                         orphaned_source_records, integrity_percentage, business_priority, analysis_timestamp
                  FROM cross_file_integrity_summary
                  WHERE analysis_timestamp >= CURRENT_DATE()
                    AND analysis_timestamp <  CURRENT_DATE() + INTERVAL 1 DAY
                    AND discovered_from_neo4j = 1
                    AND relationship_name LIKE 'Activities.%'
                  ORDER BY relationship_name
                """
                )
                rows = cursor.fetchall()
                cursor.close()
                return rows or []
            finally:
                conn.close()
        except Exception as e:
            logger.error(f"❌ Failed to get Activities orphan summaries for PDF: {e}")
            return []

class ActivityRuleDiscovery:
    """Discovers Activities domain orphan detection rules from Neo4j"""

    def __init__(self, neo4j_driver):
        self.driver = neo4j_driver

    def pull_activity_rules_from_neo4j(self) -> List[OrphanRule]:
        """Pull Activities domain FK→PK rules from Neo4j"""
        discovery_query = """
        MATCH (fk:SumTotalField)-[r:REFERENCES_PRIMARY_KEY]->(pk:SumTotalField)
        WHERE pk.entityType='Activities' AND pk.pk_anchor=true
        RETURN DISTINCT
          coalesce(r.businessRule, fk.name + ' must reference Activities.' + coalesce(pk.name,'Activity Code')) AS business_rule,
          coalesce(r.relationshipType,'many_to_one') AS relationship_type,
          coalesce(r.orphanedRecordImpact,'Activities without valid parent activities') AS orphan_impact,
          coalesce(r.validationPriority,'High') AS priority,
          fk.name AS fk_field,
          fk.file AS fk_file,
          coalesce(pk.name,'Activity Code') AS pk_field,
          'activity_curriculum*' AS pk_file,
          'Activities' AS pk_entity
        ORDER BY CASE priority WHEN 'Critical' THEN 1 WHEN 'High' THEN 2 WHEN 'Medium' THEN 3 WHEN 'Low' THEN 4 ELSE 5 END, business_rule;
        """
        logger.info("🔍 Discovering Activities orphan detection rules from Neo4j...")
        try:
            with self.driver.session() as session:
                result = session.run(discovery_query)
                records = [record.data() for record in result]
            rules: List[OrphanRule] = []
            for record in records:
                rules.append(
                    OrphanRule(
                        business_rule=record['business_rule'] or f"{record['fk_field']} -> {record['pk_field']}",
                        fk_field=record['fk_field'],
                        fk_file=record['fk_file'],
                        pk_field=record['pk_field'],
                        pk_file=record['pk_file'],
                        pk_entity=record['pk_entity'],
                        relationship_type=record['relationship_type'] or 'many_to_one',
                        validation_priority=record['priority'] or 'High',
                        orphan_impact=record['orphan_impact'] or 'Activities without valid parent activities'
                    )
                )
            logger.info(f"✅ Discovered {len(rules)} Activities orphan detection rules")
            if logger.isEnabledFor(logging.DEBUG):
                for rule in rules:
                    logger.debug(f"  📋 {rule.business_rule} [{rule.validation_priority}]")
                    logger.debug(f"     FK: {rule.fk_field} in {rule.fk_file}")
                    logger.debug(f"     PK: {rule.pk_field} in {rule.pk_file}")
            return rules
        except Exception as e:
            logger.error(f"❌ Failed to discover Activity rules from Neo4j: {e}")
            raise

class EmployeeRuleDiscovery:
    """Discovers Employees domain orphan detection rules from Neo4j"""

    def __init__(self, neo4j_driver):
        self.driver = neo4j_driver

    def pull_employee_rules_from_neo4j(self) -> List[OrphanRule]:
        """Pull Employees domain FK→PK rules from Neo4j"""
        discovery_query = """
        MATCH (fk:SumTotalField)-[r:REFERENCES_PRIMARY_KEY]->(pk:SumTotalField)
        WHERE pk.entityType='Employees' AND pk.pk_anchor=true
        RETURN DISTINCT
          coalesce(r.businessRule, fk.name + ' -> ' + coalesce(pk.name,'PersonNumber')) AS business_rule,
          coalesce(r.relationshipType,'many_to_one') AS relationship_type,
          coalesce(r.orphanedRecordImpact,'Employee data integrity violation') AS orphan_impact,
          coalesce(r.validationPriority,'High') AS priority,
          fk.name AS fk_field,
          fk.file AS fk_file,
          coalesce(pk.name,'PersonNumber') AS pk_field,
          'core_employee*' AS pk_file,
          'Employees' AS pk_entity
        ORDER BY CASE priority WHEN 'Critical' THEN 1 WHEN 'High' THEN 2 WHEN 'Medium' THEN 3 WHEN 'Low' THEN 4 ELSE 5 END, business_rule;
        """
        logger.info("🔍 Discovering Employees orphan detection rules from Neo4j...")
        try:
            with self.driver.session() as session:
                result = session.run(discovery_query)
                records = [record.data() for record in result]
            rules: List[OrphanRule] = []
            for record in records:
                rules.append(
                    OrphanRule(
                        business_rule=record['business_rule'] or f"{record['fk_field']} -> {record['pk_field']}",
                        fk_field=record['fk_field'],
                        fk_file=record['fk_file'],
                        pk_field=record['pk_field'],
                        pk_file=record['pk_file'],
                        pk_entity=record['pk_entity'],
                        relationship_type=record['relationship_type'] or 'many_to_one',
                        validation_priority=record['priority'] or 'High',
                        orphan_impact=record['orphan_impact'] or 'Employee data integrity violation'
                    )
                )
            logger.info(f"✅ Discovered {len(rules)} Employees orphan detection rules")
            if logger.isEnabledFor(logging.DEBUG):
                for rule in rules:
                    logger.debug(f"  📋 {rule.business_rule} [{rule.validation_priority}]")
                    logger.debug(f"     FK: {rule.fk_field} in {rule.fk_file}")
                    logger.debug(f"     PK: {rule.pk_field} in {rule.pk_file}")
            return rules
        except Exception as e:
            logger.error(f"❌ Failed to discover Employee rules from Neo4j: {e}")
            raise

class EmployeeOrphanExecutor:
    """Simple executor for Employees domain - just runs SQL file"""

    def __init__(self, conn):
        self.conn = conn

    def execute(self):
        logger.info("🔍 Executing Employees orphan detection analysis...")
        run_sql('employees_orphans.sql', self.conn)
        logger.info("✅ Employees orphan analysis completed")
        self._log_execution_results()

    def _log_execution_results(self):
        _log_orphan_results(self.conn, "Employees", "relationship_name LIKE 'Employees.%'")

    @staticmethod
    def get_employees_orphan_summaries_for_pdf():
        """Get today's Employee orphan summaries for PDF reporting"""
        try:
            conn = _db_conn()
            try:
                _tune_session(conn)
                cursor = conn.cursor(dictionary=True)
                cursor.execute(
                    """
                  SELECT analysis_run_id, relationship_name, key_field, total_source_records,
                         orphaned_source_records, integrity_percentage, business_priority, analysis_timestamp
                  FROM cross_file_integrity_summary
                  WHERE analysis_timestamp >= CURRENT_DATE()
                    AND analysis_timestamp <  CURRENT_DATE() + INTERVAL 1 DAY
                    AND discovered_from_neo4j = 1
                    AND relationship_name LIKE 'Employees.%'
                  ORDER BY relationship_name
                """
                )
                rows = cursor.fetchall()
                cursor.close()
                return rows or []
            finally:
                conn.close()
        except Exception as e:
            logger.error(f"❌ Failed to get Employees orphan summaries for PDF: {e}")
            return []

class OrganizationOrphanExecutor:
    """Simple executor for Organizations domain - for PDF compatibility"""

    @staticmethod
    def get_orgs_orphan_summaries_for_pdf():
        """Get today's Organization orphan summaries for PDF reporting"""
        try:
            conn = _db_conn()
            try:
                _tune_session(conn)
                cursor = conn.cursor(dictionary=True)
                cursor.execute(
                    """
                  SELECT analysis_run_id, relationship_name, key_field, total_source_records,
                         orphaned_source_records, integrity_percentage, business_priority, analysis_timestamp
                  FROM cross_file_integrity_summary
                  WHERE analysis_timestamp >= CURRENT_DATE()
                    AND analysis_timestamp <  CURRENT_DATE() + INTERVAL 1 DAY
                    AND discovered_from_neo4j = 1
                    AND relationship_name LIKE 'Orgs.%'
                  ORDER BY relationship_name
                """
                )
                rows = cursor.fetchall()
                cursor.close()
                return rows or []
            finally:
                conn.close()
        except Exception as e:
            logger.error(f"❌ Failed to get Organizations orphan summaries for PDF: {e}")
            return []

# -----------------------------
# Neo4j discovery test
# -----------------------------

def test_rule_discovery():
    """Test Neo4j rule discovery for Activities and Employees"""
    load_dotenv()
    neo4j_uri = os.getenv("NEO4J_URI")
    neo4j_user = os.getenv("NEO4J_USER")
    neo4j_password = os.getenv("NEO4J_PASSWORD")
    if not all([neo4j_uri, neo4j_user, neo4j_password]):
        logger.error("❌ Missing Neo4j credentials in .env file")
        return
    try:
        driver = GraphDatabase.driver(neo4j_uri, auth=(neo4j_user, neo4j_password))
        print("\n🎯 Testing Activities Rule Discovery:")
        activities_discovery = ActivityRuleDiscovery(driver)
        activities_rules = activities_discovery.pull_activity_rules_from_neo4j()
        print(f"📊 Activities Rules: {len(activities_rules)} found")
        for rule in activities_rules:
            print(f"🔗 {rule.business_rule}")
            print(f"   Priority: {rule.validation_priority}")
            print(f"   FK: {rule.fk_field} ({rule.fk_file})")
            print(f"   PK: {rule.pk_field} ({rule.pk_file})")
        print("\n🎯 Testing Employees Rule Discovery:")
        employees_discovery = EmployeeRuleDiscovery(driver)
        employees_rules = employees_discovery.pull_employee_rules_from_neo4j()
        print(f"📊 Employees Rules: {len(employees_rules)} found")
        for rule in employees_rules:
            print(f"🔗 {rule.business_rule}")
            print(f"   Priority: {rule.validation_priority}")
            print(f"   FK: {rule.fk_field} ({rule.fk_file})")
            print(f"   PK: {rule.pk_field} ({rule.pk_file})")
        print(f"\n📊 TOTAL: {len(activities_rules + employees_rules)} rules discovered")
        driver.close()
    except Exception as e:
        logger.error(f"❌ Test failed: {e}")

# -----------------------------
# Main CLI
# -----------------------------

def main():
    """Main function - session-aware domain selection"""
    import argparse
    import sys
    load_dotenv()
    parser = argparse.ArgumentParser(description="Session-based Orphan Detection Tool")
    parser.add_argument("--mode", choices=["neo4j", "sql", "both"], default="both",
                       help="Test mode: neo4j (rule discovery), sql (orphan execution), or both")
    parser.add_argument("--domain", choices=["activities", "employees", "orgs", "all"], default="all",
                       help="Domain to analyze: activities, employees, orgs, or all")
    parser.add_argument("--session-id", type=str, help="Session ID to load (if not provided, uses current session)")
    parser.add_argument("--debug", action="store_true", help="Enable debug mode")
    args = parser.parse_args()
    
    if args.debug:
        logging.getLogger().setLevel(logging.DEBUG)
    
    success = True
    try:
        # Load or check session
        if args.session_id:
            session_config = session_manager.load_session(args.session_id)
            if not session_config:
                logger.error(f"❌ Session {args.session_id} not found")
                return False
            logger.info(f"✅ Loaded session: {args.session_id}")
        else:
            session_config = session_manager.current_session
            if not session_config:
                logger.warning("⚠️ No active session found - results may include historical data")
        
        if session_config:
            logger.info(f"📝 Session {session_config.session_id} has {len(session_config.uploaded_files)} uploaded files")
            # Log canonical tables for domain filtering clarity
            uploaded_tables = [f.canonical_table for f in session_config.uploaded_files]
            logger.info(f"📋 Uploaded canonical tables: {uploaded_tables}")
            if args.debug:
                logger.debug(f"Session config:\n{session_manager.get_session_json()}")
        
        if args.mode in ["neo4j", "both"]:
            print("🔍 Testing Neo4j rule discovery...")
            test_rule_discovery()
        
        if args.mode in ["sql", "both"]:
            print(f"\n📊 Testing SQL orphan detection for domain(s): {args.domain}")
            conn = _db_conn()
            _tune_session(conn)
            _log_where_am_i(conn)
            try:
                # Check each domain against session uploads
                domains_to_run = []
                if args.domain == "all":
                    domains_to_run = ["activities", "employees", "orgs"]
                else:
                    domains_to_run = [args.domain]
                
                for domain in domains_to_run:
                    should_run = session_manager.should_run_orphan_detection(domain)
                    uploaded_tables = session_manager.get_uploaded_tables_for_domain(domain)
                    
                    if not should_run:
                        logger.info(f"⏭️ Skipping {domain} - no files uploaded in current session")
                        print(f"⏭️ Skipping {domain} - no files uploaded in current session")
                        continue
                    
                    logger.info(f"🔍 Executing {domain.title()} orphan detection for session {session_config.session_id if session_config else 'unknown'}")
                    logger.info(f"📁 Session uploaded tables for {domain}: {uploaded_tables}")
                    print(f"🔍 Executing {domain.title()} orphan detection...")
                    print(f"   📁 Session uploaded tables: {uploaded_tables}")
                    
                    if domain == "activities":
                        run_sql('activities_orphans.sql', conn)
                        conn.commit()
                        print("✅ Activities orphan analysis completed")
                        _log_activities_results(conn)
                    elif domain == "employees":
                        EmployeeOrphanExecutor(conn).execute()
                        conn.commit()
                        print("✅ Employees orphan analysis completed")
                    elif domain == "orgs":
                        run_sql('orgs_orphans.sql', conn)
                        conn.commit()
                        print("✅ Organizations orphan analysis completed")
                        _log_orgs_results(conn)
                
                print("✅ All orphan detection committed successfully")
            except Exception as e:
                conn.rollback()
                logger.error(f"❌ Orphan detection failed, rolled back: {e}")
                success = False
                raise
            finally:
                conn.close()
        print("\n🎉 Testing completed successfully!")
    except Exception as e:
        logger.error(f"💥 Testing failed: {e}")
        success = False
    import sys as _sys
    _sys.exit(0 if success else 1)

if __name__ == "__main__":
    main()