#!/usr/bin/env python3
"""
SumTotal→CSOD Orphan Tracker (Business Rule Driven)
Complete Implementation: Neo4j Rule Discovery + SQL Orphan Detection
Supports Activities & Employees domains with atomic transaction handling

IMPORTANT: SumTotal-Only Module
=============================
This module operates exclusively on SumTotal data and relationships.
Do NOT import or use:
- FilenameMapper.to_db_key() (without strict_sumtotal=True) 
- fetch_mapping_rules_from_neo4j() (CSOD-specific)
- Any CSODField or OUTPUTS_FIELD queries
- CSOD file name mappings

SUPPORTED DOMAINS:
==================
Activities Domain:
- PK Field: 'Activity Code' (with space) 
- PK Anchor: pk.pk_anchor = true in Activity_Curriculum
- PK Target: activity_curriculum* MySQL tables
- FK Sources: ClassCode, ILTCourseCode from ILT files

Employees Domain:
- PK Field: 'PersonNumber'
- PK Source: core_employee table
- FK Sources: EmployeeID (transcript_*), EmployeeId (prerequisites_instructor)
- Report-only: Owner (activity_curriculum)

ENVIRONMENT SETUP:
==================
Required environment variables:
- MYSQL_HOST=localhost
- MYSQL_USER=your_mysql_user  
- MYSQL_PASSWORD=your_mysql_password
- MYSQL_NAME=error_logging
- MYSQL_PORT=3306
- NEO4J_URI=bolt://localhost:7687 (for rule discovery)
- NEO4J_USER=neo4j (for rule discovery)
- NEO4J_PASSWORD=your_neo4j_password (for rule discovery)

USAGE:
======
# Test both domains (atomic transaction)
python orphan_tracker_businessrule.py --mode sql --domain all

# Test Activities only
python orphan_tracker_businessrule.py --mode sql --domain activities

# Test Employees only
python orphan_tracker_businessrule.py --mode sql --domain employees

# Test both Neo4j discovery and SQL execution
python orphan_tracker_businessrule.py --mode both --domain all

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
from dotenv import load_dotenv

# Load environment variables at startup
load_dotenv()

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Default SQL directory
DEF_SQL_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', 'sql')


def _db_conn():
    """Create MySQL connection using environment variables"""
    return mysql.connector.connect(
        host=os.getenv('MYSQL_HOST', 'localhost'),
        user=os.getenv('MYSQL_USER'),
        password=os.getenv('MYSQL_PASSWORD'),
        database=os.getenv('MYSQL_NAME'),
        port=int(os.getenv('MYSQL_PORT', 3306)),
        autocommit=False,
        charset='utf8mb4',
        collation='utf8mb4_unicode_ci'
    )


def run_sql(path, conn):
    """Execute SQL file with semicolon-separated statements"""
    full_path = path if os.path.isabs(path) else os.path.join(DEF_SQL_DIR, path)
    with open(full_path, 'r', encoding='utf-8') as f:
        sql = f.read()
    
    # Naive split works because our scripts don't embed semicolons in strings
    statements = [s.strip() for s in sql.split(';') if s.strip()]
    cursor = conn.cursor()
    
    try:
        for statement in statements:
            cursor.execute(statement)
            if cursor.with_rows:
                cursor.fetchall()
    finally:
        cursor.close()


def _log_orphan_results(conn, domain_name, where_clause):
    """Standardized logging for orphan detection results"""
    try:
        cursor = conn.cursor(dictionary=True)
        cursor.execute(f"""
          SELECT relationship_name, key_field, total_source_records,
                 orphaned_source_records, integrity_percentage, business_priority
          FROM cross_file_integrity_summary
          WHERE DATE(analysis_timestamp) = CURDATE()
            AND discovered_from_neo4j = 1
            AND ({where_clause})
          ORDER BY relationship_name
        """)
        rows = cursor.fetchall()
        cursor.close()
        
        if rows:
            logger.info(f"📊 {domain_name} Orphan Detection Results ({len(rows)} relationships):")
            for row in rows:
                # Calculate exact percentage for display
                total = row['total_source_records']
                orphaned = row['orphaned_source_records']
                valid_records = total - orphaned
                exact_pct = (valid_records / total * 100) if total > 0 else 100.0
                
                logger.info(f"  📋 {row['relationship_name']}")
                logger.info(f"     • Key Field: {row['key_field']}")
                logger.info(f"     • Total Records: {total:,}")
                logger.info(f"     • Valid Records: {valid_records:,}")
                logger.info(f"     • Orphaned Records: {orphaned:,}")
                logger.info(f"     • Integrity: {row['integrity_percentage']:.2f}% (exact: {exact_pct:.4f}%)")
                logger.info(f"     • Priority: {row['business_priority']}")
                logger.info("")
        else:
            logger.warning(f"⚠️  No {domain_name} orphan detection results found for today")
            
    except Exception as e:
        logger.error(f"❌ Failed to retrieve {domain_name} execution results: {e}")


def _log_activities_results(conn):
    """Log Activities orphan detection results after execution"""
    _log_orphan_results(conn, "Activities", "relationship_name LIKE '%Activities%' OR relationship_name LIKE '%Activity%'")


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


class EmployeeRuleDiscovery:
    """Discovers Employees domain orphan detection rules from Neo4j"""
    
    def __init__(self, neo4j_driver):
        self.driver = neo4j_driver
    
    def pull_employee_rules_from_neo4j(self) -> List[OrphanRule]:
        """
        Pull Employees domain FK→PK rules from Neo4j :REFERENCES_PRIMARY_KEY edges
        
        Returns:
            List[OrphanRule]: Business rules for Employees orphan detection
        """
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
                    validation_priority=record['priority'] or 'High',
                    orphan_impact=record['orphan_impact'] or 'Employee data integrity violation'
                )
                rules.append(rule)
                
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


class JobRuleDiscovery:
    """Discovers Jobs domain orphan detection rules from Neo4j"""
    
    def __init__(self, neo4j_driver):
        self.driver = neo4j_driver
    
    def pull_job_rules_from_neo4j(self) -> List[OrphanRule]:
        """
        Pull Jobs domain FK→PK rules from Neo4j :REFERENCES_PRIMARY_KEY edges
        
        Returns:
            List[OrphanRule]: Business rules for Jobs orphan detection
        """
        discovery_query = """
        MATCH (fk:SumTotalField)-[r:REFERENCES_PRIMARY_KEY]->(pk:SumTotalField)
        WHERE pk.entityType='Jobs' AND pk.pk_anchor=true
        RETURN DISTINCT
          coalesce(r.businessRule, fk.name + ' -> ' + coalesce(pk.name,'JobCode')) AS business_rule,
          coalesce(r.relationshipType,'many_to_one') AS relationship_type,
          coalesce(r.orphanedRecordImpact,'Job data integrity violation') AS orphan_impact,
          coalesce(r.validationPriority,'Medium') AS priority,
          fk.name AS fk_field,
          fk.file AS fk_file,
          coalesce(pk.name,'JobCode') AS pk_field,
          'core_job*' AS pk_file,
          'Jobs' AS pk_entity
        ORDER BY CASE priority WHEN 'Critical' THEN 1 WHEN 'High' THEN 2 WHEN 'Medium' THEN 3 WHEN 'Low' THEN 4 ELSE 5 END, business_rule;
        """
        
        logger.info("🔍 Discovering Jobs orphan detection rules from Neo4j...")
        
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
                    orphan_impact=record['orphan_impact'] or 'Job data integrity violation'
                )
                rules.append(rule)
                
            logger.info(f"✅ Discovered {len(rules)} Jobs orphan detection rules")
            
            if logger.isEnabledFor(logging.DEBUG):
                for rule in rules:
                    logger.debug(f"  📋 {rule.business_rule} [{rule.validation_priority}]")
                    logger.debug(f"     FK: {rule.fk_field} in {rule.fk_file}")
                    logger.debug(f"     PK: {rule.pk_field} in {rule.pk_file}")
                    
            return rules
            
        except Exception as e:
            logger.error(f"❌ Failed to discover Job rules from Neo4j: {e}")
            raise


class OrganizationRuleDiscovery:
    """Discovers Organization domain orphan detection rules from Neo4j"""
    
    def __init__(self, neo4j_driver):
        self.driver = neo4j_driver
    
    def pull_organization_rules_from_neo4j(self) -> List[OrphanRule]:
        """
        Pull Organization domain FK→PK rules from Neo4j :REFERENCES_PRIMARY_KEY edges
        
        Returns:
            List[OrphanRule]: Business rules for Organization orphan detection
        """
        discovery_query = """
        MATCH (fk:SumTotalField)-[r:REFERENCES_PRIMARY_KEY]->(pk:SumTotalField)
        WHERE pk.entityType='Organization' AND pk.pk_anchor=true
        RETURN DISTINCT
          coalesce(r.businessRule, fk.name + ' -> ' + coalesce(pk.name,'OrganizationCode')) AS business_rule,
          coalesce(r.relationshipType,'many_to_one') AS relationship_type,
          coalesce(r.orphanedRecordImpact,'Organization data integrity violation') AS orphan_impact,
          coalesce(r.validationPriority,'Medium') AS priority,
          fk.name AS fk_field,
          fk.file AS fk_file,
          coalesce(pk.name,'OrganizationCode') AS pk_field,
          'core_organization*' AS pk_file,
          'Organization' AS pk_entity
        ORDER BY CASE priority WHEN 'Critical' THEN 1 WHEN 'High' THEN 2 WHEN 'Medium' THEN 3 WHEN 'Low' THEN 4 ELSE 5 END, business_rule;
        """
        
        logger.info("🔍 Discovering Organization orphan detection rules from Neo4j...")
        
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
                    orphan_impact=record['orphan_impact'] or 'Organization data integrity violation'
                )
                rules.append(rule)
                
            logger.info(f"✅ Discovered {len(rules)} Organization orphan detection rules")
            
            if logger.isEnabledFor(logging.DEBUG):
                for rule in rules:
                    logger.debug(f"  📋 {rule.business_rule} [{rule.validation_priority}]")
                    logger.debug(f"     FK: {rule.fk_field} in {rule.fk_file}")
                    logger.debug(f"     PK: {rule.pk_field} in {rule.pk_file}")
                    
            return rules
            
        except Exception as e:
            logger.error(f"❌ Failed to discover Organization rules from Neo4j: {e}")
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
                    
    def get_mysql_connection(self) -> mysql.connector.MySQLConnection:
        """Create MySQL connection with error handling"""
        try:
            connection = mysql.connector.connect(**self.mysql_config)
            logger.debug("✅ MySQL connection established")
            return connection
        except MySQLError as e:
            logger.error(f"❌ Failed to connect to MySQL: {e}")
            raise


class BaseOrphanExecutor:
    """Base class for Neo4j-based orphan detection executors"""
    
    def __init__(self, conn, neo4j_driver, domain_name):
        """
        Initialize with database connections
        
        Args:
            conn: Active MySQL connection for atomic transaction support
            neo4j_driver: Neo4j driver for rule discovery
            domain_name: Name of the domain (e.g., "Employees", "Jobs")
        """
        self.conn = conn
        self.neo4j_driver = neo4j_driver
        self.domain_name = domain_name
    
    def _generate_orphan_sql(self, rules: List[OrphanRule]) -> str:# delete this no need I will put in the sql code myself. 
        """Generate SQL for orphan detection from Neo4j rules"""
        if not rules:
            return ""
        
        # Get the primary key info from the first rule (all should be the same)
        pk_field = rules[0].pk_field
        pk_entity = rules[0].pk_entity
        pk_table = self._get_pk_table_name(pk_entity)
        
        sql_parts = [
            f"-- Generated {self.domain_name} orphan detection SQL",
            f"-- Purge today's {self.domain_name} rows",
            f"DELETE FROM cross_file_integrity_summary",
            f"WHERE discovered_from_neo4j = 1",
            f"  AND DATE(analysis_timestamp) = CURDATE()",
            f"  AND relationship_name LIKE '{pk_entity}.%';",
            "",
            "SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;",
            "",
            f"-- Build canonical {pk_entity} PK cache",
            f"DROP TEMPORARY TABLE IF EXISTS valid_{pk_entity.lower()}_pk;",
            f"CREATE TEMPORARY TABLE valid_{pk_entity.lower()}_pk ( pk VARCHAR(500) PRIMARY KEY ) ENGINE=InnoDB;",
            "",
            f"INSERT IGNORE INTO valid_{pk_entity.lower()}_pk (pk)",
            f"SELECT DISTINCT UPPER(TRIM(",
            f"  REPLACE(REPLACE(REPLACE(CONVERT({pk_field} USING utf8mb4),",
            f"    CHAR(194,160),' '), CHAR(226,128,175),' '), CHAR(226,128,135),' ')",
            f"))",
            f"FROM {pk_table}",
            f"WHERE {pk_field} IS NOT NULL",
            f"  AND TRIM(REPLACE(REPLACE(REPLACE(CONVERT({pk_field} USING utf8mb4),",
            f"    CHAR(194,160),' '), CHAR(226,128,175),' '), CHAR(226,128,135),' ')) <> '';",
            ""
        ]
        
        # Add analysis for each rule
        for rule in rules:
            fk_table = self._get_fk_table_name(rule.fk_file)
            relationship_name = f"{pk_entity}.{rule.fk_file}.{rule.fk_field} → {pk_entity}.{pk_field}"
            
            sql_parts.extend([
                f"-- {rule.business_rule}",
                f"SET @total_fk_{rule.fk_field.lower()} = (",
                f"  SELECT COUNT(DISTINCT UPPER(TRIM(",
                f"    REPLACE(REPLACE(REPLACE(CONVERT({rule.fk_field} USING utf8mb4),",
                f"      CHAR(194,160),' '), CHAR(226,128,175),' '), CHAR(226,128,135),' ')",
                f"  )))",
                f"  FROM {fk_table}",
                f"  WHERE {rule.fk_field} IS NOT NULL",
                f"    AND TRIM(REPLACE(REPLACE(REPLACE(CONVERT({rule.fk_field} USING utf8mb4),",
                f"      CHAR(194,160),' '), CHAR(226,128,175),' '), CHAR(226,128,135),' ')) <> ''",
                f");",
                "",
                f"SET @orphans_{rule.fk_field.lower()} = (",
                f"  SELECT COUNT(*) FROM (",
                f"    SELECT DISTINCT UPPER(TRIM(",
                f"      REPLACE(REPLACE(REPLACE(CONVERT({rule.fk_field} USING utf8mb4),",
                f"        CHAR(194,160),' '), CHAR(226,128,175),' '), CHAR(226,128,135),' ')",
                f"    )) AS fk",
                f"    FROM {fk_table}",
                f"    WHERE {rule.fk_field} IS NOT NULL",
                f"      AND TRIM(REPLACE(REPLACE(REPLACE(CONVERT({rule.fk_field} USING utf8mb4),",
                f"        CHAR(194,160),' '), CHAR(226,128,175),' '), CHAR(226,128,135),' ')) <> ''",
                f"  ) s LEFT JOIN valid_{pk_entity.lower()}_pk p ON s.fk = p.pk",
                f"  WHERE p.pk IS NULL",
                f");",
                "",
                f"SET @integrity_{rule.fk_field.lower()} = CASE",
                f"  WHEN @total_fk_{rule.fk_field.lower()} = 0 THEN 100.00",
                f"  ELSE ROUND(100.0 * (@total_fk_{rule.fk_field.lower()} - @orphans_{rule.fk_field.lower()}) / @total_fk_{rule.fk_field.lower()}, 2)",
                f"END;",
                "",
                f"INSERT INTO cross_file_integrity_summary (",
                f"  analysis_run_id, relationship_name, source_file_pattern, target_file_pattern, key_field,",
                f"  total_source_records, total_target_records, orphaned_source_records, orphaned_target_records,",
                f"  integrity_percentage, processing_time_ms, relationship_type, business_priority, discovered_from_neo4j",
                f") VALUES (",
                f"  UUID(), '{relationship_name}',",
                f"  '{fk_table}*', '{pk_table}*', '{rule.fk_field}→{pk_field}',",
                f"  @total_fk_{rule.fk_field.lower()}, (SELECT COUNT(*) FROM valid_{pk_entity.lower()}_pk), @orphans_{rule.fk_field.lower()}, 0,",
                f"  @integrity_{rule.fk_field.lower()}, 0, '{rule.relationship_type}', '{rule.validation_priority}', 1",
                f");",
                ""
            ])
        
        return "\n".join(sql_parts)
    
    def _get_pk_table_name(self, entity_type: str) -> str:
        """Get primary key table name for entity type"""
        table_mapping = {
            'Employees': 'core_employee',
            'Jobs': 'core_job', 
            'Organization': 'core_organization',
            'Activities': 'activity_curriculum'
        }
        return table_mapping.get(entity_type, f'core_{entity_type.lower()}')
    
    def _get_fk_table_name(self, file_name: str) -> str:
        """Convert file name to table name"""
        # Remove file extensions and convert to table format
        table_name = file_name.replace('.xlsx', '').replace('.csv', '')
        table_name = table_name.replace('_', '_').lower()
        return table_name
    
    def execute_sql_statements(self, sql: str):
        """Execute SQL statements"""
        if not sql.strip():
            logger.warning(f"No SQL to execute for {self.domain_name}")
            return
            
        # Split by semicolon and execute each statement
        statements = [s.strip() for s in sql.split(';') if s.strip() and not s.strip().startswith('--')]
        cursor = self.conn.cursor()
        
        try:
            for statement in statements:
                if statement:
                    cursor.execute(statement)
        finally:
            cursor.close()


class EmployeeOrphanExecutor(BaseOrphanExecutor):
    """Executes Neo4j-based orphan detection for Employees domain"""
    
    def __init__(self, conn, neo4j_driver=None):
        """
        Initialize with database connections
        
        Args:
            conn: Active MySQL connection for atomic transaction support
            neo4j_driver: Neo4j driver for rule discovery (optional, will create if None)
        """
        super().__init__(conn, neo4j_driver, "Employees")
        
    def execute(self):
        """Execute the Employees orphan detection using Neo4j rules"""
        logger.info("🔍 Executing Employees orphan detection analysis...")
        
        if self.neo4j_driver:
            # Use Neo4j rule discovery
            discovery = EmployeeRuleDiscovery(self.neo4j_driver)
            rules = discovery.pull_employee_rules_from_neo4j()
            
            if rules:
                sql = self._generate_orphan_sql(rules)
                self.execute_sql_statements(sql)
                logger.info(f"✅ Employees orphan analysis completed using {len(rules)} Neo4j rules")
            else:
                logger.warning("⚠️  No Employee rules found in Neo4j, falling back to hardcoded SQL")
                run_sql('employees_orphans.sql', self.conn)
        else:
            # Fallback to hardcoded SQL
            logger.info("🔄 Using hardcoded SQL (no Neo4j driver provided)")
            run_sql('employees_orphans.sql', self.conn)
            
        logger.info("✅ Employees orphan analysis completed")
        
        # Log the results
        self._log_execution_results()
    
    def _log_execution_results(self):
        """Log the Employee orphan detection results after execution"""
        _log_orphan_results(self.conn, "Employees", "relationship_name LIKE 'Employees.%'")
    
    @staticmethod
    def get_employees_orphan_summaries_for_pdf():
        """
        Get today's Employee orphan summaries for PDF reporting
        
        Returns:
            List[Dict]: Employee orphan detection results from today
        """
        conn = _db_conn()
        try:
            cursor = conn.cursor(dictionary=True)
            cursor.execute("""
              SELECT analysis_run_id, relationship_name, key_field, total_source_records,
                     orphaned_source_records, integrity_percentage, business_priority, analysis_timestamp
              FROM cross_file_integrity_summary
              WHERE DATE(analysis_timestamp) = CURDATE()
                AND discovered_from_neo4j = 1
                AND relationship_name LIKE 'Employees.%'
              ORDER BY relationship_name
            """)
            rows = cursor.fetchall()
            cursor.close()
            return rows
        finally:
            conn.close()


class JobOrphanExecutor(BaseOrphanExecutor):
    """Executes Neo4j-based orphan detection for Jobs domain"""
    
    def __init__(self, conn, neo4j_driver):
        """
        Initialize with database connections
        
        Args:
            conn: Active MySQL connection for atomic transaction support
            neo4j_driver: Neo4j driver for rule discovery
        """
        super().__init__(conn, neo4j_driver, "Jobs")
        
    def execute(self):
        """Execute the Jobs orphan detection using Neo4j rules"""
        logger.info("🔍 Executing Jobs orphan detection analysis...")
        
        discovery = JobRuleDiscovery(self.neo4j_driver)
        rules = discovery.pull_job_rules_from_neo4j()
        
        if rules:
            sql = self._generate_orphan_sql(rules)
            self.execute_sql_statements(sql)
            logger.info(f"✅ Jobs orphan analysis completed using {len(rules)} Neo4j rules")
        else:
            logger.warning("⚠️  No Job rules found in Neo4j")
            
        # Log the results
        self._log_execution_results()
    
    def _log_execution_results(self):
        """Log the Job orphan detection results after execution"""
        _log_orphan_results(self.conn, "Jobs", "relationship_name LIKE 'Jobs.%'")
    
    @staticmethod
    def get_jobs_orphan_summaries_for_pdf():
        """
        Get today's Job orphan summaries for PDF reporting
        
        Returns:
            List[Dict]: Job orphan detection results from today
        """
        conn = _db_conn()
        try:
            cursor = conn.cursor(dictionary=True)
            cursor.execute("""
              SELECT analysis_run_id, relationship_name, key_field, total_source_records,
                     orphaned_source_records, integrity_percentage, business_priority, analysis_timestamp
              FROM cross_file_integrity_summary
              WHERE DATE(analysis_timestamp) = CURDATE()
                AND discovered_from_neo4j = 1
                AND relationship_name LIKE 'Jobs.%'
              ORDER BY relationship_name
            """)
            rows = cursor.fetchall()
            cursor.close()
            return rows
        finally:
            conn.close()


class OrganizationOrphanExecutor(BaseOrphanExecutor):
    """Executes Neo4j-based orphan detection for Organization domain"""
    
    def __init__(self, conn, neo4j_driver):
        """
        Initialize with database connections
        
        Args:
            conn: Active MySQL connection for atomic transaction support
            neo4j_driver: Neo4j driver for rule discovery
        """
        super().__init__(conn, neo4j_driver, "Organization")
        
    def execute(self):
        """Execute the Organization orphan detection using Neo4j rules"""
        logger.info("🔍 Executing Organization orphan detection analysis...")
        
        discovery = OrganizationRuleDiscovery(self.neo4j_driver)
        rules = discovery.pull_organization_rules_from_neo4j()
        
        if rules:
            sql = self._generate_orphan_sql(rules)
            self.execute_sql_statements(sql)
            logger.info(f"✅ Organization orphan analysis completed using {len(rules)} Neo4j rules")
        else:
            logger.warning("⚠️  No Organization rules found in Neo4j")
            
        # Log the results
        self._log_execution_results()
    
    def _log_execution_results(self):
        """Log the Organization orphan detection results after execution"""
        _log_orphan_results(self.conn, "Organization", "relationship_name LIKE 'Organization.%'")
    
    @staticmethod
    def get_organization_orphan_summaries_for_pdf():
        """
        Get today's Organization orphan summaries for PDF reporting
        
        Returns:
            List[Dict]: Organization orphan detection results from today
        """
        conn = _db_conn()
        try:
            cursor = conn.cursor(dictionary=True)
            cursor.execute("""
              SELECT analysis_run_id, relationship_name, key_field, total_source_records,
                     orphaned_source_records, integrity_percentage, business_priority, analysis_timestamp
              FROM cross_file_integrity_summary
              WHERE DATE(analysis_timestamp) = CURDATE()
                AND discovered_from_neo4j = 1
                AND relationship_name LIKE 'Organization.%'
              ORDER BY relationship_name
            """)
            rows = cursor.fetchall()
            cursor.close()
            return rows
        finally:
            conn.close()
            
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
        
        # Test Activities rule discovery
        print("\n🎯 Testing Activities Rule Discovery:")
        activities_discovery = ActivityRuleDiscovery(driver)
        activities_rules = activities_discovery.pull_activity_rules_from_neo4j()
        
        print(f"📊 Activities Rules: {len(activities_rules)} found")
        expected_activities_fk_fields = ["ClassCode", "ILTCourseCode"]
        found_activities_fk_fields = [rule.fk_field for rule in activities_rules]
        
        print(f"Expected FK fields: {expected_activities_fk_fields}")
        print(f"Found FK fields: {found_activities_fk_fields}")
        
        for rule in activities_rules:
            print(f"🔗 {rule.business_rule}")
            print(f"   Priority: {rule.validation_priority}")
            print(f"   FK: {rule.fk_field} ({rule.fk_file})")
            print(f"   PK: {rule.pk_field} ({rule.pk_file})")
            print(f"   Impact: {rule.orphan_impact}")
            
        # Test Employees rule discovery
        print("\n🎯 Testing Employees Rule Discovery:")
        employees_discovery = EmployeeRuleDiscovery(driver)
        employees_rules = employees_discovery.pull_employee_rules_from_neo4j()
        
        print(f"📊 Employees Rules: {len(employees_rules)} found")
        expected_employees_fk_fields = ["Owner", "EmployeeID", "EmployeeId"]
        found_employees_fk_fields = [rule.fk_field for rule in employees_rules]
        
        print(f"Expected FK fields: {expected_employees_fk_fields}")
        print(f"Found FK fields: {found_employees_fk_fields}")
        
        for rule in employees_rules:
            print(f"🔗 {rule.business_rule}")
            print(f"   Priority: {rule.validation_priority}")
            print(f"   FK: {rule.fk_field} ({rule.fk_file})")
            print(f"   PK: {rule.pk_field} ({rule.pk_file})")
            print(f"   Impact: {rule.orphan_impact}")
            
        # Test Jobs rule discovery
        print("\n🎯 Testing Jobs Rule Discovery:")
        jobs_discovery = JobRuleDiscovery(driver)
        jobs_rules = jobs_discovery.pull_job_rules_from_neo4j()
        
        print(f"📊 Jobs Rules: {len(jobs_rules)} found")
        expected_jobs_fk_fields = ["JobCode", "PositionID"]
        found_jobs_fk_fields = [rule.fk_field for rule in jobs_rules]
        
        print(f"Expected FK fields: {expected_jobs_fk_fields}")
        print(f"Found FK fields: {found_jobs_fk_fields}")
        
        for rule in jobs_rules:
            print(f"🔗 {rule.business_rule}")
            print(f"   Priority: {rule.validation_priority}")
            print(f"   FK: {rule.fk_field} ({rule.fk_file})")
            print(f"   PK: {rule.pk_field} ({rule.pk_file})")
            print(f"   Impact: {rule.orphan_impact}")
            
        # Test Organization rule discovery
        print("\n🎯 Testing Organization Rule Discovery:")
        organization_discovery = OrganizationRuleDiscovery(driver)
        organization_rules = organization_discovery.pull_organization_rules_from_neo4j()
        
        print(f"📊 Organization Rules: {len(organization_rules)} found")
        expected_organization_fk_fields = ["OrganizationCode", "DepartmentID"]
        found_organization_fk_fields = [rule.fk_field for rule in organization_rules]
        
        print(f"Expected FK fields: {expected_organization_fk_fields}")
        print(f"Found FK fields: {found_organization_fk_fields}")
        
        for rule in organization_rules:
            print(f"🔗 {rule.business_rule}")
            print(f"   Priority: {rule.validation_priority}")
            print(f"   FK: {rule.fk_field} ({rule.fk_file})")
            print(f"   PK: {rule.pk_field} ({rule.pk_file})")
            print(f"   Impact: {rule.orphan_impact}")
            
        # Combined validation
        total_rules = len(activities_rules) + len(employees_rules) + len(jobs_rules) + len(organization_rules)
        print(f"\n📊 OVERALL DISCOVERY SUMMARY:")
        print(f"Activities rules: {len(activities_rules)}")
        print(f"Employees rules: {len(employees_rules)}")
        print(f"Jobs rules: {len(jobs_rules)}")
        print(f"Organization rules: {len(organization_rules)}")
        print(f"Total rules: {total_rules}")
        
        if total_rules == 0:
            print(f"\n❌ ERROR: No rules found. Check Neo4j pk_anchor setup and :REFERENCES_PRIMARY_KEY edges.")
        elif len(activities_rules) == 0:
            print(f"\n⚠️  WARNING: No Activities rules found. Check Activities domain setup in Neo4j.")
        elif len(employees_rules) == 0:
            print(f"\n⚠️  WARNING: No Employees rules found. Check Employees domain setup in Neo4j.")
        elif len(jobs_rules) == 0:
            print(f"\n⚠️  WARNING: No Jobs rules found. Check Jobs domain setup in Neo4j.")
        elif len(organization_rules) == 0:
            print(f"\n⚠️  WARNING: No Organization rules found. Check Organization domain setup in Neo4j.")
        else:
            print(f"\n✅ Rule discovery working for all domains!")
            
        # Check that all Activities rules point to the canonical PK
        if activities_rules:
            all_pk_activity_code = all(rule.pk_field == 'Activity Code' for rule in activities_rules)
            all_pk_curriculum = all(rule.pk_file == 'activity_curriculum*' for rule in activities_rules)
            
            if all_pk_activity_code and all_pk_curriculum:
                print("✅ All Activities rules correctly point to 'Activity Code' in 'activity_curriculum*'")
            else:
                print("⚠️  Some Activities rules have incorrect PK field or file mappings")
        
        # Check that all Employees rules point to the canonical PK
        if employees_rules:
            all_pk_person_number = all(rule.pk_field == 'PersonNumber' for rule in employees_rules)
            all_pk_core_employee = all(rule.pk_file == 'core_employee*' for rule in employees_rules)
            
            if all_pk_person_number and all_pk_core_employee:
                print("✅ All Employees rules correctly point to 'PersonNumber' in 'core_employee*'")
            else:
                print("⚠️  Some Employees rules have incorrect PK field or file mappings")
        
        # Check that all Jobs rules point to the canonical PK  
        if jobs_rules:
            all_pk_job_code = all(rule.pk_field == 'JobCode' for rule in jobs_rules)
            all_pk_core_job = all(rule.pk_file == 'core_job*' for rule in jobs_rules)
            
            if all_pk_job_code and all_pk_core_job:
                print("✅ All Jobs rules correctly point to 'JobCode' in 'core_job*'")
            else:
                print("⚠️  Some Jobs rules have incorrect PK field or file mappings")
        
        # Check that all Organization rules point to the canonical PK
        if organization_rules:
            all_pk_org_code = all(rule.pk_field == 'OrganizationCode' for rule in organization_rules)
            all_pk_core_org = all(rule.pk_file == 'core_organization*' for rule in organization_rules)
            
            if all_pk_org_code and all_pk_core_org:
                print("✅ All Organization rules correctly point to 'OrganizationCode' in 'core_organization*'")
            else:
                print("⚠️  Some Organization rules have incorrect PK field or file mappings")
            
        driver.close()
        
    except Exception as e:
        logger.error(f"❌ Test failed: {e}")


def main():
    """Main function to run orphan detection with domain selection and atomic transactions"""
    import argparse
    import sys
    from dotenv import load_dotenv
    
    # Load environment variables from .env file
    load_dotenv()
    
    parser = argparse.ArgumentParser(description="Orphan Detection Tool (Activities + Employees + Jobs + Organization)")
    parser.add_argument("--mode", choices=["neo4j", "sql", "both"], default="both",
                       help="Test mode: neo4j (rule discovery), sql (orphan execution), or both")
    parser.add_argument("--domain", choices=["activities", "employees", "jobs", "organization", "all"], default="all",
                       help="Domain to analyze: activities, employees, jobs, organization, or all")
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
            print(f"\n📊 Testing Neo4j-based orphan detection for domain(s): {args.domain}")
            
            # Set up Neo4j connection for rule discovery
            neo4j_uri = os.getenv("NEO4J_URI")
            neo4j_user = os.getenv("NEO4J_USER") 
            neo4j_password = os.getenv("NEO4J_PASSWORD")
            
            neo4j_driver = None
            if all([neo4j_uri, neo4j_user, neo4j_password]):
                neo4j_driver = GraphDatabase.driver(neo4j_uri, auth=(neo4j_user, neo4j_password))
            else:
                logger.warning("⚠️  Missing Neo4j credentials, will use fallback SQL for supported domains")
            
            # Single MySQL connection with atomic transaction
            conn = _db_conn()
            try:
                if args.domain in ("activities", "all"):
                    print("🔍 Executing Activities orphan detection...")
                    # Activities still uses hardcoded SQL for now
                    run_sql('activities_orphans.sql', conn)
                    print("✅ Activities orphan analysis completed")
                    _log_activities_results(conn)
                    
                if args.domain in ("employees", "all"):
                    print("🔍 Executing Employees orphan detection...")
                    EmployeeOrphanExecutor(conn, neo4j_driver).execute()
                    
                if args.domain in ("jobs", "all"):
                    if neo4j_driver:
                        print("🔍 Executing Jobs orphan detection...")
                        JobOrphanExecutor(conn, neo4j_driver).execute()
                    else:
                        print("⚠️  Skipping Jobs domain (requires Neo4j connection)")
                        
                if args.domain in ("organization", "all"):
                    if neo4j_driver:
                        print("🔍 Executing Organization orphan detection...")
                        OrganizationOrphanExecutor(conn, neo4j_driver).execute()
                    else:
                        print("⚠️  Skipping Organization domain (requires Neo4j connection)")
                    
                # Commit all domains atomically
                conn.commit()
                print("✅ All orphan detection committed successfully")
                
            except Exception as e:
                conn.rollback()
                logger.error(f"❌ Orphan detection failed, rolled back: {e}")
                success = False
                raise
            finally:
                conn.close()
                if neo4j_driver:
                    neo4j_driver.close()
            
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
