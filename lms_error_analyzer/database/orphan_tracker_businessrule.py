#!/usr/bin/env python3
"""
SumTotal→CSOD Orphan Tracker (Business Rule Driven)
Complete Implementation: Neo4j Rule Discovery + SQL Orphan Detection

IMPORTANT: SumTotal-Only Module
=============================
This module operates exclusively on SumTotal data and relationships.
Do NOT import or use:
- FilenameMapper.to_db_key() (without strict_sumtotal=True) 
- fetch_mapping_rules_from_neo4j() (CSOD-specific)
- Any CSODField or OUTPUTS_FIELD queries
- CSOD file name mappings

Uses canonical Activities PK anchor approach:
- PK Field: 'Activity Code' (with space) 
- PK Anchor: pk.pk_anchor = true in Activity_Curriculum
- PK Target: activity_curriculum* MySQL tables
- FK Sources: ClassCode, ILTCourseCode from ILT files

ENVIRONMENT SETUP:
==================
Required environment variables:
- MYSQL_HOST=localhost
- MYSQL_USER=your_mysql_user  
- MYSQL_PASSWORD=your_mysql_password
- MYSQL_DB=error_logging
- NEO4J_URI=bolt://localhost:7687 (for rule discovery)
- NEO4J_USER=neo4j (for rule discovery)
- NEO4J_PASSWORD=your_neo4j_password (for rule discovery)

USAGE:
======
# Test both Neo4j discovery and SQL execution
python orphan_tracker_businessrule.py --mode both

# Test only SQL orphan detection  
python orphan_tracker_businessrule.py --mode sql

# Test only Neo4j rule discovery
python orphan_tracker_businessrule.py --mode neo4j

# Enable debug logging
python orphan_tracker_businessrule.py --debug

# Use in ETL (programmatic)
from orphan_tracker_businessrule import run_activities_orphan_checks
result = run_activities_orphan_checks()
"""

import logging
import os
import time
from datetime import datetime
from typing import List, Dict, Any, Optional
from dataclasses import dataclass
from neo4j import GraphDatabase
import mysql.connector
from mysql.connector import Error as MySQLError

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


@dataclass
class OrphanRule:
    """Represents a business rule for orphan detection"""
    business_rule: str
    fk_field: str
    fk_file: str
    pk_field: str
    pk_file: str
    pk_entity: str
    relationship_type: str
    validation_priority: str
    orphan_impact: str


class ActivityRuleDiscovery:
    """Discovers Activities domain orphan detection rules from Neo4j"""
    
    def __init__(self, neo4j_driver):
        self.driver = neo4j_driver
    
    def pull_activity_rules_from_neo4j(self) -> List[OrphanRule]:
        """
        Pull Activities domain FK→PK rules from Neo4j :REFERENCES_PRIMARY_KEY edges
        
        Returns:
            List[OrphanRule]: Business rules for Activities orphan detection
        """
        discovery_query = """
        MATCH (fk:SumTotalField)-[r:REFERENCES_PRIMARY_KEY]->(pk:SumTotalField)
        WHERE pk.entityType='Activities' AND pk.pk_anchor=true
        RETURN DISTINCT
          coalesce(r.businessRule, fk.name + ' -> ' + coalesce(pk.name,'Activity Code')) AS business_rule,
          coalesce(r.relationshipType,'many_to_one') AS relationship_type,
          coalesce(r.orphanedRecordImpact,'Data integrity violation') AS orphan_impact,
          coalesce(r.validationPriority,'Medium') AS priority,
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
                
            # Convert to OrphanRule objects
            rules = []
            for record in records:
                rule = OrphanRule(
                    business_rule=record['business_rule'] or f"{record['fk_field']} -> {record['pk_field']}",
                    fk_field=record['fk_field'],
                    fk_file=record['fk_file'],
                    pk_field=record['pk_field'], 
                    pk_file=record['pk_file'],
                    pk_entity=record['pk_entity'],
                    relationship_type=record['relationship_type'] or 'many_to_one',
                    validation_priority=record['priority'] or 'Medium',
                    orphan_impact=record['orphan_impact'] or 'Data integrity violation'
                )
                rules.append(rule)
                
            logger.info(f"✅ Discovered {len(rules)} Activities orphan detection rules")
            
            if logger.isEnabledFor(logging.DEBUG):
                for rule in rules:
                    logger.debug(f"  📋 {rule.business_rule} [{rule.validation_priority}]")
                    logger.debug(f"     FK: {rule.fk_field} in {rule.fk_file}")
                    logger.debug(f"     PK: {rule.pk_field} in {rule.pk_file}")
                    
            return rules
            
        except Exception as e:
            logger.error(f"❌ Failed to discover rules from Neo4j: {e}")
            raise


@dataclass
class OrphanCheckResult:
    """Results from orphan detection analysis"""
    total_checks: int
    successful_checks: int
    failed_checks: int
    processing_time_ms: int
    summary_rows_inserted: int
    error_messages: List[str]


class ActivitiesOrphanExecutor:
    """Executes SQL-based orphan detection for Activities domain"""
    
    def __init__(self, mysql_config: Optional[Dict[str, str]] = None):
        """
        Initialize with MySQL configuration
        
        Args:
            mysql_config: Dict with host, user, password, database keys
                         If None, reads from environment variables
        """
        if mysql_config:
            self.mysql_config = mysql_config
        else:
            self.mysql_config = {
                'host': os.getenv('MYSQL_HOST', 'localhost'),
                'user': os.getenv('MYSQL_USER'),
                'password': os.getenv('MYSQL_PASSWORD'),
                'database': os.getenv('MYSQL_NAME'),
                'autocommit': False,
                'charset': 'utf8mb4',
                'collation': 'utf8mb4_unicode_ci',
                'port':'3306'
                
            }
            
        # Validate required config
        required_keys = ['user', 'password', 'database']
        missing_keys = [k for k in required_keys if not self.mysql_config.get(k)]
        if missing_keys:
            raise ValueError(f"Missing MySQL configuration: {missing_keys}")
            
        self.sql_script_path = os.path.join(
            os.path.dirname(os.path.dirname(os.path.dirname(__file__))),
            "sql", "activities_orphans.sql"
        )
        
    def get_mysql_connection(self) -> mysql.connector.MySQLConnection:
        """Create MySQL connection with error handling"""
        try:
            connection = mysql.connector.connect(**self.mysql_config)
            logger.debug("✅ MySQL connection established")
            return connection
        except MySQLError as e:
            logger.error(f"❌ Failed to connect to MySQL: {e}")
            raise
            
    def load_sql_script(self) -> str:
        """Load the Activities orphan detection SQL script"""
        try:
            if not os.path.exists(self.sql_script_path):
                raise FileNotFoundError(f"SQL script not found: {self.sql_script_path}")
                
            with open(self.sql_script_path, 'r', encoding='utf-8') as f:
                script_content = f.read()
                
            logger.debug(f"📄 Loaded SQL script: {self.sql_script_path}")
            return script_content
            
        except Exception as e:
            logger.error(f"❌ Failed to load SQL script: {e}")
            raise
            
    def begin_analysis_transaction(self, connection: mysql.connector.MySQLConnection) -> str:
        """
        Begin atomic analysis transaction with staging table
        
        Returns:
            str: Unique analysis run ID for this transaction
        """
        analysis_run_id = f"activities_{datetime.now().strftime('%Y%m%d_%H%M%S')}_{os.getpid()}"
        
        try:
            cursor = connection.cursor()
            
            # Create staging table for atomic operations
            cursor.execute("""
                DROP TEMPORARY TABLE IF EXISTS cross_file_integrity_staging
            """)
            
            cursor.execute("""
                CREATE TEMPORARY TABLE cross_file_integrity_staging (
                    analysis_run_id VARCHAR(100),
                    relationship_name VARCHAR(255),
                    source_file_pattern VARCHAR(100),
                    target_file_pattern VARCHAR(100),
                    key_field VARCHAR(100),
                    total_source_records INT,
                    total_target_records INT,
                    orphaned_source_records INT,
                    orphaned_target_records INT,
                    integrity_percentage DECIMAL(5,2),
                    processing_time_ms INT,
                    relationship_type VARCHAR(50),
                    business_priority VARCHAR(20),
                    discovered_from_neo4j TINYINT(1) DEFAULT 1,
                    analysis_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                ) ENGINE=InnoDB
            """)
            
            cursor.close()
            logger.info(f"🏗️  Analysis transaction started with ID: {analysis_run_id}")
            return analysis_run_id
            
        except MySQLError as e:
            logger.error(f"❌ Failed to begin analysis transaction: {e}")
            raise
            
    def commit_analysis_results(self, connection: mysql.connector.MySQLConnection, analysis_run_id: str) -> int:
        """
        Atomically commit staging results to main table
        
        Args:
            connection: MySQL connection
            analysis_run_id: Unique run identifier
            
        Returns:
            int: Number of rows committed
        """
        try:
            cursor = connection.cursor()
            
            # Archive old Activities orphan detection results (keep history)
            cursor.execute("""
                INSERT INTO cross_file_integrity_archive (
                    original_id, analysis_run_id, relationship_name, source_file_pattern, target_file_pattern,
                    key_field, total_source_records, total_target_records, orphaned_source_records,
                    orphaned_target_records, integrity_percentage, processing_time_ms, relationship_type,
                    business_priority, discovered_from_neo4j, analysis_timestamp, archived_at
                )
                SELECT id, analysis_run_id, relationship_name, source_file_pattern, target_file_pattern,
                       key_field, total_source_records, total_target_records, orphaned_source_records,
                       orphaned_target_records, integrity_percentage, processing_time_ms, relationship_type,
                       business_priority, discovered_from_neo4j, analysis_timestamp, NOW()
                FROM cross_file_integrity_summary
                WHERE discovered_from_neo4j = 1 
                  AND (relationship_name LIKE '%Activities%' OR relationship_name LIKE '%Activity%')
            """)
            archived_rows = cursor.rowcount
            
            # Remove old Activities orphan detection results
            cursor.execute("""
                DELETE FROM cross_file_integrity_summary
                WHERE discovered_from_neo4j = 1 
                  AND (relationship_name LIKE '%Activities%' OR relationship_name LIKE '%Activity%')
            """)
            deleted_rows = cursor.rowcount
            
            # Insert new results from staging
            cursor.execute("""
                INSERT INTO cross_file_integrity_summary (
                    analysis_run_id, relationship_name, source_file_pattern, target_file_pattern,
                    key_field, total_source_records, total_target_records, orphaned_source_records,
                    orphaned_target_records, integrity_percentage, processing_time_ms, relationship_type,
                    business_priority, discovered_from_neo4j, analysis_timestamp
                )
                SELECT analysis_run_id, relationship_name, source_file_pattern, target_file_pattern,
                       key_field, total_source_records, total_target_records, orphaned_source_records,
                       orphaned_target_records, integrity_percentage, processing_time_ms, relationship_type,
                       business_priority, discovered_from_neo4j, analysis_timestamp
                FROM cross_file_integrity_staging
            """)
            committed_rows = cursor.rowcount
            
            cursor.close()
            
            if archived_rows > 0:
                logger.info(f"📦 Archived {archived_rows} historical Activities orphan results")
            if deleted_rows > 0:
                logger.info(f"🧹 Removed {deleted_rows} old Activities orphan results")
            logger.info(f"✅ Committed {committed_rows} new Activities orphan results")
            
            return committed_rows
            
        except MySQLError as e:
            logger.error(f"❌ Failed to commit analysis results: {e}")
            raise
            
    def ensure_archive_table_exists(self, connection: mysql.connector.MySQLConnection):
        """Ensure archive table exists for historical data"""
        try:
            cursor = connection.cursor()
            cursor.execute("""
                CREATE TABLE IF NOT EXISTS cross_file_integrity_archive (
                    archive_id INT AUTO_INCREMENT PRIMARY KEY,
                    original_id INT,
                    analysis_run_id VARCHAR(100),
                    relationship_name VARCHAR(255),
                    source_file_pattern VARCHAR(100),
                    target_file_pattern VARCHAR(100),
                    key_field VARCHAR(100),
                    total_source_records INT,
                    total_target_records INT,
                    orphaned_source_records INT,
                    orphaned_target_records INT,
                    integrity_percentage DECIMAL(5,2),
                    processing_time_ms INT,
                    relationship_type VARCHAR(50),
                    business_priority VARCHAR(20),
                    discovered_from_neo4j TINYINT(1),
                    analysis_timestamp TIMESTAMP,
                    archived_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    INDEX idx_relationship_name (relationship_name),
                    INDEX idx_analysis_run_id (analysis_run_id),
                    INDEX idx_archived_at (archived_at)
                ) ENGINE=InnoDB
            """)
            cursor.close()
            logger.debug("📦 Archive table ready")
            
        except MySQLError as e:
            logger.warning(f"⚠️  Could not create archive table: {e}")
            # Continue without archiving
            
    def execute_orphan_analysis(self) -> OrphanCheckResult:
        """
        Execute the complete Activities orphan detection analysis using atomic transactions
        
        Returns:
            OrphanCheckResult: Summary of analysis execution
        """
        start_time = time.time()
        errors = []
        summary_rows = 0
        analysis_run_id = None
        
        logger.info("🚀 Starting Activities orphan detection analysis with atomic transactions...")
        
        connection = None
        try:
            # Establish connection and setup
            connection = self.get_mysql_connection()
            self.ensure_archive_table_exists(connection)
            
            # Begin atomic transaction with staging table
            analysis_run_id = self.begin_analysis_transaction(connection)
            
            # Load and execute SQL script (now writes to staging table)
            sql_script = self.load_sql_script()
            
            cursor = connection.cursor()
            
            # Execute multi-statement SQL script
            logger.info("📊 Executing orphan detection SQL script...")
            
            # Count INSERT statements to track expected summary rows
            expected_inserts = sql_script.count('INSERT INTO cross_file_integrity_staging')
            logger.debug(f"Expected summary inserts: {expected_inserts}")
            
            # Split and execute individual statements
            statements = []
            for line in sql_script.split('\n'):
                line = line.strip()
                if line and not line.startswith('--'):
                    statements.append(line)
            
            # Join and split by semicolon to get complete statements
            full_script = ' '.join(statements)
            individual_statements = [stmt.strip() for stmt in full_script.split(';') if stmt.strip()]
            
            logger.debug(f"Executing {len(individual_statements)} SQL statements...")
            
            # Execute each statement
            failed_statements = 0
            for i, statement in enumerate(individual_statements, 1):
                try:
                    logger.debug(f"Executing statement {i}/{len(individual_statements)}")
                    cursor.execute(statement)
                    if cursor.with_rows:
                        cursor.fetchall()  # Consume any results
                except Exception as stmt_error:
                    logger.warning(f"Statement {i} failed: {stmt_error}")
                    failed_statements += 1
                    if failed_statements > 5:  # Don't allow too many failures
                        raise Exception(f"Too many statement failures ({failed_statements})")
            
            # Verify staging table has results
            cursor.execute("SELECT COUNT(*) FROM cross_file_integrity_staging")
            staging_rows = cursor.fetchone()[0]
            
            if staging_rows == 0:
                raise Exception("No results generated in staging table")
                
            logger.info(f"📊 Generated {staging_rows} results in staging table")
            
            # Atomically commit results to main table
            summary_rows = self.commit_analysis_results(connection, analysis_run_id)
            
            cursor.close()
            connection.commit()
            
            processing_time_ms = int((time.time() - start_time) * 1000)
            
            logger.info(f"✅ Atomic orphan analysis completed successfully")
            logger.info(f"   📊 Summary rows committed: {summary_rows}")
            logger.info(f"   🆔 Analysis run ID: {analysis_run_id}")
            logger.info(f"   ⏱️  Processing time: {processing_time_ms}ms")
            
            return OrphanCheckResult(
                total_checks=expected_inserts,
                successful_checks=expected_inserts - failed_statements,
                failed_checks=failed_statements,
                processing_time_ms=processing_time_ms,
                summary_rows_inserted=summary_rows,
                error_messages=[]
            )
            
        except Exception as e:
            error_msg = f"Orphan analysis failed: {e}"
            errors.append(error_msg)
            logger.error(f"❌ {error_msg}")
            
            # Rollback on error
            if connection:
                try:
                    connection.rollback()
                    logger.info("🔄 Complete transaction rolled back due to error")
                except:
                    pass
                    
            processing_time_ms = int((time.time() - start_time) * 1000)
            
            return OrphanCheckResult(
                total_checks=1,
                successful_checks=0,
                failed_checks=1,
                processing_time_ms=processing_time_ms,
                summary_rows_inserted=0,
                error_messages=errors
            )
            
        finally:
            if connection:
                try:
                    connection.close()
                    logger.debug("🔌 MySQL connection closed")
                except:
                    pass
                    
    def get_todays_summaries(self) -> List[Dict[str, Any]]:
        """Retrieve today's Activities orphan detection summaries for verification"""
        connection = None
        try:
            connection = self.get_mysql_connection()
            cursor = connection.cursor(dictionary=True)
            
            cursor.execute("""
                SELECT 
                    analysis_run_id,
                    relationship_name,
                    key_field,
                    total_source_records,
                    orphaned_source_records,
                    integrity_percentage,
                    business_priority,
                    analysis_timestamp
                FROM cross_file_integrity_summary 
                WHERE DATE(analysis_timestamp) = CURDATE()
                  AND discovered_from_neo4j = 1
                  AND (relationship_name LIKE '%Activities%' OR relationship_name LIKE '%Activity%')
                ORDER BY 
                    CASE business_priority 
                        WHEN 'Critical' THEN 1 
                        WHEN 'High' THEN 2 
                        WHEN 'Medium' THEN 3 
                        WHEN 'Info' THEN 4 
                        ELSE 5 
                    END,
                    relationship_name
            """)
            
            results = cursor.fetchall()
            cursor.close()
            
            logger.debug(f"📋 Retrieved {len(results)} Activities orphan summary records from today")
            return results
            
        except Exception as e:
            logger.error(f"❌ Failed to retrieve summaries: {e}")
            return []
            
        finally:
            if connection:
                try:
                    connection.close()
                except:
                    pass

    @staticmethod
    def get_activities_orphan_summaries_for_pdf() -> List[Dict[str, Any]]:
        """
        Static method to retrieve Activities orphan summaries for PDF generation
        
        Returns:
            List[Dict]: Activities orphan detection results for PDF reports
        """
        from dotenv import load_dotenv
        load_dotenv()
        
        try:
            executor = ActivitiesOrphanExecutor()
            return executor.get_todays_summaries()
        except Exception as e:
            logger.error(f"❌ Failed to get Activities orphan summaries for PDF: {e}")
            return []


def test_activities_orphan_executor():
    """Test function for SQL-based orphan detection"""
    from dotenv import load_dotenv
    
    # Load environment variables from .env file
    load_dotenv()
    
    try:
        executor = ActivitiesOrphanExecutor()
        
        print("\n🧪 TESTING ACTIVITIES ORPHAN DETECTION")
        print("=" * 60)
        
        # Test connection
        print("🔗 Testing MySQL connection...")
        try:
            conn = executor.get_mysql_connection()
            conn.close()
            print("✅ MySQL connection successful")
        except Exception as e:
            print(f"❌ MySQL connection failed: {e}")
            return
            
        # Test SQL script loading
        print("📄 Testing SQL script loading...")
        try:
            script = executor.load_sql_script()
            print(f"✅ SQL script loaded ({len(script)} characters)")
        except Exception as e:
            print(f"❌ SQL script loading failed: {e}")
            return
            
        # Execute orphan analysis
        print("🚀 Executing orphan detection analysis...")
        result = executor.execute_orphan_analysis()
        
        print(f"\n📊 ANALYSIS RESULTS:")
        print(f"   Total checks: {result.total_checks}")
        print(f"   Successful: {result.successful_checks}")
        print(f"   Failed: {result.failed_checks}")
        print(f"   Processing time: {result.processing_time_ms}ms")
        print(f"   Summary rows: {result.summary_rows_inserted}")
        
        if result.error_messages:
            print(f"   Errors: {result.error_messages}")
            
        # Retrieve and display summaries
        if result.successful_checks > 0:
            print("\n📋 TODAY'S ORPHAN DETECTION SUMMARIES:")
            summaries = executor.get_todays_summaries()
            
            for summary in summaries:
                integrity = summary['integrity_percentage']
                priority = summary['business_priority']
                orphans = summary['orphaned_source_records']
                total = summary['total_source_records']
                
                status = "✅" if integrity == 100 else "⚠️" if integrity > 90 else "❌"
                
                print(f"\n{status} {summary['relationship_name']}")
                print(f"   Priority: {priority}")
                print(f"   Integrity: {integrity}% ({total-orphans}/{total})")
                print(f"   Orphaned: {orphans}")
                
        print(f"\n{'✅ SUCCESS' if result.failed_checks == 0 else '❌ FAILED'}: Orphan detection test completed")
        
    except Exception as e:
        logger.error(f"❌ Test failed: {e}")


def test_rule_discovery():
    """Test function for rule discovery"""
    import os
    from dotenv import load_dotenv
    
    load_dotenv()
    
    neo4j_uri = os.getenv("NEO4J_URI")
    neo4j_user = os.getenv("NEO4J_USER")
    neo4j_password = os.getenv("NEO4J_PASSWORD")
    
    if not all([neo4j_uri, neo4j_user, neo4j_password]):
        logger.error("❌ Missing Neo4j credentials in .env file")
        return
        
    try:
        driver = GraphDatabase.driver(neo4j_uri, auth=(neo4j_user, neo4j_password))
        discovery = ActivityRuleDiscovery(driver)
        
        rules = discovery.pull_activity_rules_from_neo4j()
        
        print(f"\n📊 DISCOVERED RULES SUMMARY:")
        print(f"Total rules: {len(rules)}")
        
        # Sanity check: should see 2-3 rules for Activities (with updated field names)
        expected_fk_fields = ["ClassCode", "ILTCourseCode"]
        found_fk_fields = [rule.fk_field for rule in rules]
        
        print(f"Expected FK fields: {expected_fk_fields}")
        print(f"Found FK fields: {found_fk_fields}")
        
        for rule in rules:
            print(f"\n🔗 {rule.business_rule}")
            print(f"   Priority: {rule.validation_priority}")
            print(f"   FK: {rule.fk_field} ({rule.fk_file})")
            print(f"   PK: {rule.pk_field} ({rule.pk_file})")
            print(f"   Impact: {rule.orphan_impact}")
            
        # Validation - should see ClassCode rules from different ILT files + optional ILTCourseCode
        if len(rules) == 0:
            print(f"\n❌ ERROR: No rules found. Check Neo4j pk_anchor setup and :REFERENCES_PRIMARY_KEY edges.")
        elif len(rules) < 2:
            print(f"\n⚠️  WARNING: Expected 2-3 rules, got {len(rules)}. May be missing some ILT file relationships.")
        else:
            print(f"\n✅ Rule count looks good ({len(rules)} rules found)")
            
        # Check that all rules point to the canonical PK
        all_pk_activity_code = all(rule.pk_field == 'Activity Code' for rule in rules)
        all_pk_curriculum = all(rule.pk_file == 'activity_curriculum*' for rule in rules)
        
        if all_pk_activity_code and all_pk_curriculum:
            print("✅ All rules correctly point to 'Activity Code' in 'activity_curriculum*'")
        else:
            print("⚠️  Some rules have incorrect PK field or file mappings")
            
        driver.close()
        
    except Exception as e:
        logger.error(f"❌ Test failed: {e}")


def main():
    """Main function to run Activities orphan detection tests"""
    import argparse
    import sys
    from dotenv import load_dotenv
    
    # Load environment variables from .env file
    load_dotenv()
    
    parser = argparse.ArgumentParser(description="Activities Orphan Detection Tool")
    parser.add_argument("--mode", choices=["neo4j", "sql", "both"], default="both",
                       help="Test mode: neo4j (rule discovery), sql (orphan execution), or both")
    parser.add_argument("--debug", action="store_true", help="Enable debug mode")
    
    args = parser.parse_args()
    
    # Set debug logging
    if args.debug:
        logging.getLogger().setLevel(logging.DEBUG)
    
    success = True
    
    try:
        if args.mode in ["neo4j", "both"]:
            print("🔍 Testing Neo4j rule discovery...")
            test_rule_discovery()
            
        if args.mode in ["sql", "both"]:
            print("\n📊 Testing SQL orphan detection...")
            test_activities_orphan_executor()
            
        print(f"\n🎉 Testing completed successfully!")
        
    except Exception as e:
        logger.error(f"💥 Testing failed: {e}")
        success = False
        
    sys.exit(0 if success else 1)


def run_activities_orphan_checks():
    """
    Main entry point for automated orphan checking (called from ETL)
    
    Returns:
        OrphanCheckResult: Analysis results
    """
    from dotenv import load_dotenv
    
    # Load environment variables from .env file
    load_dotenv()
    
    try:
        executor = ActivitiesOrphanExecutor()
        return executor.execute_orphan_analysis()
    except Exception as e:
        logger.error(f"❌ Failed to run orphan checks: {e}")
        return OrphanCheckResult(
            total_checks=0,
            successful_checks=0,
            failed_checks=1,
            processing_time_ms=0,
            summary_rows_inserted=0,
            error_messages=[str(e)]
        )


if __name__ == "__main__":
    main()
