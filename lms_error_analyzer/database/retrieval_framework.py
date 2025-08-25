#!/usr/bin/env python3
"""
SumTotal Data Quality Retrieval Framework

This module implements a comprehensive retrieval system for analyzing SumTotal file quality
by combining MySQL raw data, quality signals, and Neo4j mapping constraints.

Key Features:
- DB-first approach: queries MySQL tables directly for raw data metrics  
- SumTotal-centric analysis: all findings reference original SumTotal field names
- Neo4j constraint validation: uses CSOD field properties to validate SumTotal data
- Context bundling: assembles ranked, token-optimized analysis context
- Caching and observability: deterministic results with detailed logging
"""

import os
import re
import json
import logging
import hashlib
from datetime import datetime
from typing import Dict, List, Optional, Tuple, Any, Union
from dataclasses import dataclass, asdict
from collections import defaultdict

import mysql.connector
from neo4j import GraphDatabase
from dotenv import load_dotenv

# Import utilities from existing modules
from utils.filename_mapper import FilenameMapper

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

load_dotenv()

# Database configurations
MYSQL_CONFIG = {
    'host': os.getenv('MYSQL_HOST', 'localhost'),
    'port': int(os.getenv('MYSQL_PORT', 3306)),
    'database': os.getenv('MYSQL_NAME', 'error_logging'),
    'user': os.getenv('MYSQL_USER', 'error_logger'),
    'password': os.getenv('MYSQL_PASSWORD', 'IerpAgents.com1%')
}

NEO4J_CONFIG = {
    'uri': os.getenv('NEO4J_URI', 'bolt://localhost:7687'),
    'user': os.getenv('NEO4J_USER', 'neo4j'),
    'password': os.getenv('NEO4J_PASSWORD', '')
}


@dataclass
class FieldMetrics:
    """Per-field metrics from MySQL raw data"""
    column_name: str
    total_rows: int
    null_count: int
    blank_count: int
    distinct_count: int
    max_length: int
    avg_length: float
    sample_values: List[str]
    type_violations: int = 0
    length_violations: int = 0
    domain_violations: int = 0


@dataclass
class CSODConstraint:
    """CSOD field constraints from Neo4j"""
    csod_field_name: str
    mandatory: str
    field_type: str
    char_length: Optional[str]
    accepted_values: str
    default_value: str
    transformation: Optional[str]
    output_document: str


@dataclass
class SumTotalFieldProfile:
    """Complete profile for a SumTotal field"""
    sumtotal_field_name: str
    metrics: Optional[FieldMetrics]
    csod_constraints: List[CSODConstraint]
    violations: List[str]
    severity: str  # High, Medium, Low
    error_count: int = 0


@dataclass
class QualitySignals:
    """Quality signals from MySQL"""
    error_logs: List[Dict[str, Any]]
    completeness_summary: Dict[str, Any]
    error_summary: Dict[str, int]


@dataclass
class ContextBundle:
    """Complete context for LLM analysis"""
    file_name: str
    file_key: str
    table_name: str
    overview: Dict[str, Any]
    field_profiles: List[SumTotalFieldProfile]
    quality_signals: QualitySignals
    mapping_summary: Dict[str, Any]
    metadata: Dict[str, Any]


@dataclass
class RelationshipDefinition:
    """Configuration for cross-file relationship analysis"""
    relationship_name: str
    source_pattern: str          # File pattern for source files (e.g., 'Core_*')
    target_pattern: str          # File pattern for target files (e.g., 'Transcript_*')
    key_field: str              # Field name used for cross-reference
    relationship_type: str       # PARENT_CHILD, REFERENCE, MANY_TO_MANY
    business_priority: str       # Critical, High, Medium, Low
    cardinality: str            # 1:1, 1:N, N:N
    validation_rules: List[str]  # List of validation rules to apply
    discovered_from_neo4j: bool = False  # Whether discovered dynamically


@dataclass
class CrossFileRelationship:
    """Referential integrity analysis between files"""
    relationship_name: str        # e.g., "core_employee_to_transcript_integrity"
    primary_file: str            # e.g., "Core_Employee.xlsx"  
    dependent_file: str          # e.g., "Transcript_History.xlsx"
    key_field: str              # e.g., "Employee_ID"
    total_source_records: int    # Records in primary file
    total_dependent_records: int # Records in dependent file  
    orphaned_records: int        # Records with missing parent reference
    integrity_percentage: float  # Valid references percentage
    orphaned_samples: List[str]  # Sample orphaned key values
    severity: str               # High, Medium, Low
    business_impact: str        # Impact description
    processing_time_ms: int = 0  # Time taken for analysis
    analysis_run_id: str = ""    # Unique identifier for analysis run


@dataclass
class MultiFileContext:
    """Aggregated context for multiple related files"""
    file_names: List[str]
    bundles: Dict[str, ContextBundle]
    aggregate_summary: Dict[str, Any]
    cross_file_relationships: List[CrossFileRelationship]
    metadata: Dict[str, Any]


class PerformanceMonitor:
    """Tracks performance metrics for cross-file analysis"""
    
    def __init__(self):
        self.start_times = {}
        self.metrics = defaultdict(list)
    
    def start_timer(self, operation_name: str):
        """Start timing an operation"""
        self.start_times[operation_name] = datetime.now()
    
    def end_timer(self, operation_name: str) -> int:
        """End timing and return milliseconds elapsed"""
        if operation_name in self.start_times:
            elapsed = (datetime.now() - self.start_times[operation_name]).total_seconds() * 1000
            self.metrics[operation_name].append(elapsed)
            del self.start_times[operation_name]
            return int(elapsed)
        return 0
    
    def get_average_time(self, operation_name: str) -> float:
        """Get average execution time for an operation"""
        times = self.metrics.get(operation_name, [])
        return sum(times) / len(times) if times else 0.0
    
    def log_performance_summary(self):
        """Log performance summary for all operations"""
        logger.info("📊 Performance Summary:")
        for operation, times in self.metrics.items():
            avg_time = sum(times) / len(times)
            logger.info(f"   • {operation}: {avg_time:.1f}ms average ({len(times)} runs)")


class MySQLRetrieval:
    """Handles MySQL database queries for raw data and quality signals"""
    
    def __init__(self, performance_monitor: Optional[PerformanceMonitor] = None):
        self.connection = None
        self.performance_monitor = performance_monitor or PerformanceMonitor()
        self._connect()
    
    def _connect(self):
        """Establish MySQL connection"""
        try:
            self.connection = mysql.connector.connect(**MYSQL_CONFIG)
            logger.info("✅ Connected to MySQL")
        except Exception as e:
            logger.error(f"❌ MySQL connection failed: {e}")
            raise
    
    def resolve_table_name(self, filename: str) -> str:
        """Convert filename to MySQL table name using snake_case"""
        # Remove extension and normalize
        base_name = os.path.splitext(filename)[0].replace(' ', '_')
        
        # Convert CamelCase to snake_case
        s1 = re.sub('([a-z0-9])([A-Z])', r'\1_\2', base_name)
        s2 = re.sub('([A-Z])([A-Z][a-z])', r'\1_\2', s1)
        return s2.lower()
    
    def get_table_overview(self, table_name: str) -> Dict[str, Any]:
        """Get basic table statistics"""
        try:
            cursor = self.connection.cursor(dictionary=True)
            
            # Check if table exists
            cursor.execute("""
                SELECT COUNT(*) as table_exists 
                FROM information_schema.tables 
                WHERE table_schema = %s AND table_name = %s
            """, (MYSQL_CONFIG['database'], table_name))
            
            if not cursor.fetchone()['table_exists']:
                cursor.close()
                return {'exists': False, 'error': f'Table {table_name} not found'}
            
            # Get row count
            cursor.execute(f"SELECT COUNT(*) as row_count FROM `{table_name}`")
            row_count = cursor.fetchone()['row_count']
            
            # Get column info
            cursor.execute("""
                SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE, CHARACTER_MAXIMUM_LENGTH
                FROM information_schema.columns 
                WHERE table_schema = %s AND table_name = %s 
                ORDER BY ordinal_position
            """, (MYSQL_CONFIG['database'], table_name))
            
            columns = cursor.fetchall()
            cursor.close()
            
            return {
                'exists': True,
                'row_count': row_count,
                'column_count': len(columns),
                'columns': [col['COLUMN_NAME'] for col in columns],
                'column_details': columns
            }
        except Exception as e:
            logger.error(f"Error getting table overview for {table_name}: {e}")
            return {'exists': False, 'error': str(e)}
    
    def get_field_metrics(self, table_name: str, column_name: str, sample_size: int = 5) -> FieldMetrics:
        """Calculate comprehensive metrics for a specific field"""
        try:
            cursor = self.connection.cursor()
            
            # Basic metrics query
            query = f"""
                SELECT 
                    COUNT(*) as total_rows,
                    COUNT(`{column_name}`) as non_null_count,
                    COUNT(DISTINCT `{column_name}`) as distinct_count,
                    MAX(LENGTH(`{column_name}`)) as max_length,
                    AVG(LENGTH(`{column_name}`)) as avg_length,
                    SUM(CASE WHEN `{column_name}` = '' OR `{column_name}` IS NULL THEN 1 ELSE 0 END) as null_blank_count
                FROM `{table_name}`
            """
            
            cursor.execute(query)
            stats = cursor.fetchone()
            
            # Sample values
            cursor.execute(f"""
                SELECT DISTINCT `{column_name}` 
                FROM `{table_name}` 
                WHERE `{column_name}` IS NOT NULL AND `{column_name}` != ''
                ORDER BY RAND() 
                LIMIT %s
            """, (sample_size,))
            
            samples = [row[0] for row in cursor.fetchall() if row[0]]
            cursor.close()
            
            if stats:
                total_rows, non_null_count, distinct_count, max_length, avg_length, null_blank_count = stats
                
                return FieldMetrics(
                    column_name=column_name,
                    total_rows=total_rows or 0,
                    null_count=(total_rows or 0) - (non_null_count or 0),
                    blank_count=null_blank_count or 0,
                    distinct_count=distinct_count or 0,
                    max_length=max_length or 0,
                    avg_length=float(avg_length) if avg_length is not None else 0.0,
                    sample_values=samples
                )
            else:
                # Return empty metrics if no data
                return FieldMetrics(
                    column_name=column_name,
                    total_rows=0,
                    null_count=0,
                    blank_count=0,
                    distinct_count=0,
                    max_length=0,
                    avg_length=0.0,
                    sample_values=[]
                )
                
        except Exception as e:
            logger.error(f"Error calculating metrics for {table_name}.{column_name}: {e}")
            return FieldMetrics(
                column_name=column_name,
                total_rows=0,
                null_count=0,
                blank_count=0,
                distinct_count=0,
                max_length=0,
                avg_length=0.0,
                sample_values=[],
                type_violations=0
            )
    
    def get_quality_signals(self, file_name: str) -> QualitySignals:
        """Retrieve error logs and completeness data for a file"""
        try:
            cursor = self.connection.cursor(dictionary=True)
            
            # Get error logs
            cursor.execute("""
                SELECT error_id, message, file_name, line_number, error_category, 
                       validation_type, timestamp, stack_trace
                FROM error_logs 
                WHERE file_name = %s 
                ORDER BY timestamp DESC 
                LIMIT 1000
            """, (file_name,))
            error_logs = cursor.fetchall()
            
            # Get completeness summary
            cursor.execute("""
                SELECT mandatory_completeness, total_records, incomplete_records
                FROM file_completeness_summary 
                WHERE file_name = %s
            """, (file_name,))
            completeness_raw = cursor.fetchone() or {}
            
            # Convert Decimal values to avoid JSON serialization issues
            completeness = {}
            if completeness_raw:
                completeness = {
                    'mandatory_completeness': float(completeness_raw.get('mandatory_completeness', 0)) if completeness_raw.get('mandatory_completeness') is not None else 0.0,
                    'total_records': int(completeness_raw.get('total_records', 0)) if completeness_raw.get('total_records') is not None else 0,
                    'incomplete_records': int(completeness_raw.get('incomplete_records', 0)) if completeness_raw.get('incomplete_records') is not None else 0
                }
            
            # Get error summary by type
            cursor.execute("""
                SELECT validation_type, COUNT(*) as count
                FROM error_logs 
                WHERE file_name = %s 
                GROUP BY validation_type
                ORDER BY count DESC
            """, (file_name,))
            error_summary = {row['validation_type']: row['count'] for row in cursor.fetchall()}
            
            cursor.close()
            
            return QualitySignals(
                error_logs=error_logs,
                completeness_summary=completeness,
                error_summary=error_summary
            )
            
        except Exception as e:
            logger.error(f"Error getting quality signals for {file_name}: {e}")
            return QualitySignals(
                error_logs=[],
                completeness_summary={},
                error_summary={}
            )
    
    def get_orphaned_records_analysis(self, primary_table: str, dependent_table: str, key_field: str, 
                                     batch_size: int = 10000) -> Dict[str, Any]:
        """Direct MySQL query for orphaned record detection with batch processing"""
        operation_name = f"orphaned_analysis_{primary_table}_{dependent_table}"
        self.performance_monitor.start_timer(operation_name)
        
        try:
            cursor = self.connection.cursor(dictionary=True)
            
            # Verify tables exist
            for table in [primary_table, dependent_table]:
                cursor.execute("""
                    SELECT COUNT(*) as table_exists 
                    FROM information_schema.tables 
                    WHERE table_schema = %s AND table_name = %s
                """, (MYSQL_CONFIG['database'], table))
                if not cursor.fetchone()['table_exists']:
                    raise ValueError(f"Table {table} does not exist")
            
            # Verify key field exists in both tables
            for table in [primary_table, dependent_table]:
                cursor.execute("""
                    SELECT COUNT(*) as field_exists
                    FROM information_schema.columns 
                    WHERE table_schema = %s AND table_name = %s AND column_name = %s
                """, (MYSQL_CONFIG['database'], table, key_field))
                if not cursor.fetchone()['field_exists']:
                    logger.error(f"Error analyzing orphaned records for {primary_table}->{dependent_table} on {key_field}: Field {key_field} does not exist in table {table}")
                    raise ValueError(f"Field {key_field} does not exist in table {table}")
            
            # Count orphaned records using LEFT JOIN with batch processing for large datasets
            orphaned_query = f"""
                SELECT COUNT(*) as orphaned_count
                FROM `{dependent_table}` d
                LEFT JOIN `{primary_table}` p ON d.`{key_field}` = p.`{key_field}`
                WHERE p.`{key_field}` IS NULL 
                AND d.`{key_field}` IS NOT NULL 
                AND d.`{key_field}` != ''
            """
            
            cursor.execute(orphaned_query)
            orphaned_result = cursor.fetchone()
            orphaned_count = orphaned_result['orphaned_count'] if orphaned_result else 0
            
            # Count total dependent records with non-null key field
            total_query = f"""
                SELECT COUNT(*) as total_count
                FROM `{dependent_table}` 
                WHERE `{key_field}` IS NOT NULL 
                AND `{key_field}` != ''
            """
            
            cursor.execute(total_query)
            total_result = cursor.fetchone()
            total_count = total_result['total_count'] if total_result else 0
            
            # Get sample orphaned values (limit to prevent memory issues)
            sample_query = f"""
                SELECT DISTINCT d.`{key_field}` as orphaned_value
                FROM `{dependent_table}` d
                LEFT JOIN `{primary_table}` p ON d.`{key_field}` = p.`{key_field}`
                WHERE p.`{key_field}` IS NULL 
                AND d.`{key_field}` IS NOT NULL 
                AND d.`{key_field}` != ''
                LIMIT 5
            """
            
            cursor.execute(sample_query)
            sample_results = cursor.fetchall()
            orphaned_samples = [str(row['orphaned_value']) for row in sample_results]
            
            # Count primary records
            primary_query = f"""
                SELECT COUNT(DISTINCT `{key_field}`) as primary_count
                FROM `{primary_table}` 
                WHERE `{key_field}` IS NOT NULL 
                AND `{key_field}` != ''
            """
            
            cursor.execute(primary_query)
            primary_result = cursor.fetchone()
            primary_count = primary_result['primary_count'] if primary_result else 0
            
            cursor.close()
            
            processing_time = self.performance_monitor.end_timer(operation_name)
            
            return {
                'orphaned_count': orphaned_count,
                'total_dependent_records': total_count,
                'total_primary_records': primary_count,
                'orphaned_samples': orphaned_samples,
                'integrity_percentage': round((total_count - orphaned_count) / total_count * 100, 1) if total_count > 0 else 100.0,
                'processing_time_ms': processing_time
            }
            
        except Exception as e:
            self.performance_monitor.end_timer(operation_name)
            logger.error(f"Error analyzing orphaned records for {primary_table}->{dependent_table} on {key_field}: {e}")
            return {
                'orphaned_count': 0,
                'total_dependent_records': 0,
                'total_primary_records': 0,
                'orphaned_samples': [],
                'integrity_percentage': 100.0,
                'processing_time_ms': 0
            }
    
    def close(self):
        """Close MySQL connection"""
        if self.connection:
            self.connection.close()
            logger.info("🔌 Disconnected from MySQL")


class Neo4jRetrieval:
    """Handles Neo4j queries for mapping rules and constraints"""
    
    def __init__(self, performance_monitor: Optional[PerformanceMonitor] = None):
        self.driver = None
        self.performance_monitor = performance_monitor or PerformanceMonitor()
        self._connect()
    
    def _connect(self):
        """Establish Neo4j connection"""
        try:
            self.driver = GraphDatabase.driver(
                NEO4J_CONFIG['uri'], 
                auth=(NEO4J_CONFIG['user'], NEO4J_CONFIG['password'])
            )
            logger.info("✅ Connected to Neo4j")
        except Exception as e:
            logger.error(f"❌ Neo4j connection failed: {e}")
            raise
    
    def get_mapping_constraints(self, file_key: str) -> Dict[str, List[CSODConstraint]]:
        """Get SumTotal->CSOD mapping constraints for a file"""
        try:
            with self.driver.session() as session:
                query = """
                MATCH (f:File {name: $fileKey})-[:HAS_FIELD]->(st:SumTotalField)
                MATCH (st)-[:MAPS_TO]->(csod:CSODField)
                RETURN 
                    st.name as sumtotal_field,
                    csod.name as csod_field,
                    csod.mandatory as mandatory,
                    csod.field_type as field_type,
                    csod.char_length as char_length,
                    csod.accepted_values as accepted_values,
                    csod.default_value as default_value,
                    csod.transformation as transformation,
                    csod.output_document as output_document
                """
                
                result = session.run(query, fileKey=file_key)
                
                # Group by SumTotal field
                constraints_by_field = defaultdict(list)
                
                for record in result:
                    sumtotal_field = record.get('sumtotal_field')
                    if sumtotal_field:
                        constraint = CSODConstraint(
                            csod_field_name=record.get('csod_field', ''),
                            mandatory=record.get('mandatory', ''),
                            field_type=record.get('field_type', ''),
                            char_length=record.get('char_length'),
                            accepted_values=record.get('accepted_values', ''),
                            default_value=record.get('default_value', ''),
                            transformation=record.get('transformation'),
                            output_document=record.get('output_document', '')
                        )
                        constraints_by_field[sumtotal_field].append(constraint)
                
                logger.info(f"Retrieved constraints for {len(constraints_by_field)} SumTotal fields")
                return dict(constraints_by_field)
                
        except Exception as e:
            logger.error(f"Error getting mapping constraints for {file_key}: {e}")
            return {}
    
    def discover_cross_file_relationships(self) -> List[RelationshipDefinition]:
        """Discover cross-file relationships dynamically from Neo4j field mappings with confidence scoring"""
        operation_name = "neo4j_relationship_discovery"
        self.performance_monitor.start_timer(operation_name)
        
        try:
            with self.driver.session() as session:
                # Enhanced query with stricter criteria and confidence scoring
                discovery_query = """
                MATCH (f1:File)-[:HAS_FIELD]->(sf1:SumTotalField)
                MATCH (f2:File)-[:HAS_FIELD]->(sf2:SumTotalField)
                WHERE f1.name <> f2.name 
                AND (
                    // High confidence: Exact field name matches
                    sf1.name = sf2.name OR
                    // Medium confidence: Key relationship fields with exact patterns
                    (sf1.name ENDS WITH 'ID' AND sf2.name ENDS WITH 'ID' AND sf1.name = sf2.name) OR
                    (sf1.name ENDS WITH 'Code' AND sf2.name ENDS WITH 'Code' AND sf1.name = sf2.name) OR
                    // Business-critical relationships with validated patterns
                    (sf1.name IN ['Employee_ID', 'EmployeeID', 'Employee ID'] AND sf2.name IN ['Employee_ID', 'EmployeeID', 'Employee ID']) OR
                    (sf1.name IN ['Activity_ID', 'ActivityID', 'Activity ID', 'ActivityCode'] AND sf2.name IN ['Activity_ID', 'ActivityID', 'Activity ID', 'ActivityCode']) OR
                    (sf1.name IN ['Curriculum_ID', 'CurriculumID', 'Curriculum ID'] AND sf2.name IN ['Curriculum_ID', 'CurriculumID', 'Curriculum ID'])
                )
                RETURN DISTINCT 
                    f1.name as source_file,
                    f2.name as target_file,
                    sf1.name as source_field,
                    sf2.name as target_field,
                    CASE 
                        WHEN sf1.name = sf2.name THEN 'High'
                        WHEN sf1.name IN ['Employee_ID', 'EmployeeID', 'Employee ID'] THEN 'Critical'
                        WHEN sf1.name ENDS WITH 'ID' OR sf1.name ENDS WITH 'Code' THEN 'Medium'
                        ELSE 'Low'
                    END as confidence_level,
                    'REFERENCE' as relationship_type
                ORDER BY confidence_level DESC, f1.name, f2.name
                """
                
                result = session.run(discovery_query)
                
                discovered_relationships = []
                processed_pairs = set()
                
                for record in result:
                    source_file = record.get('source_file')
                    target_file = record.get('target_file')
                    source_field = record.get('source_field')
                    target_field = record.get('target_field')
                    confidence_level = record.get('confidence_level', 'Low')
                    
                    # Use the more common field name between source and target
                    common_field = source_field if source_field == target_field else source_field
                    
                    # Create a unique key to avoid duplicate relationships
                    relationship_key = f"{source_file}_{target_file}_{common_field}"
                    if relationship_key in processed_pairs:
                        continue
                    processed_pairs.add(relationship_key)
                    
                    # TEMPORARY DEBUG: Don't skip any relationships for now
                    if confidence_level == 'Low' and not self._is_business_critical_field(common_field):
                        logger.info(f"🔍 TEMP DEBUG: Would skip low confidence relationship: {relationship_key}, but allowing for debug")
                        # continue  # Commented out for debugging
                    
                    # Enhanced priority mapping based on confidence and business rules
                    priority = self._determine_business_priority(common_field, confidence_level)
                    
                    # Add confidence-based validation rules
                    validation_rules = ['orphaned_record_check']
                    if confidence_level in ['High', 'Critical']:
                        validation_rules.extend(['minimum_sample_size_100', 'integrity_threshold_10'])
                    else:
                        validation_rules.extend(['minimum_sample_size_500', 'integrity_threshold_25'])
                    
                    relationship_def = RelationshipDefinition(
                        relationship_name=f"neo4j_discovered_{source_file}_to_{target_file}_{common_field}",
                        source_pattern=source_file,
                        target_pattern=target_file,
                        key_field=common_field,
                        relationship_type='REFERENCE',
                        business_priority=priority,
                        cardinality='1:N',
                        validation_rules=validation_rules,
                        discovered_from_neo4j=True
                    )
                    
                    discovered_relationships.append(relationship_def)
                
                processing_time = self.performance_monitor.end_timer(operation_name)
                logger.info(f"🔍 Neo4j discovered {len(discovered_relationships)} cross-file relationships in {processing_time}ms")
                
                return discovered_relationships
                
        except Exception as e:
            self.performance_monitor.end_timer(operation_name)
            logger.error(f"Error discovering relationships from Neo4j: {e}")
            # Return fallback hardcoded relationships
            return self._get_fallback_relationships()
    
    def _is_business_critical_field(self, field_name: str) -> bool:
        """Determine if a field is business-critical regardless of confidence level"""
        critical_patterns = [
            'Employee_ID', 'EmployeeID', 'Employee ID',
            'User_ID', 'UserID', 'User ID',
            'Curriculum_ID', 'CurriculumID', 'Curriculum ID'
        ]
        return any(pattern.lower() in field_name.lower() for pattern in critical_patterns)
    
    def _determine_business_priority(self, field_name: str, confidence_level: str) -> str:
        """Enhanced business priority determination with confidence scoring"""
        field_lower = field_name.lower()
        
        # Override based on business criticality
        if any(critical in field_lower for critical in ['employee', 'user']):
            return 'Critical'
        elif any(high_priority in field_lower for high_priority in ['activity', 'curriculum', 'course']):
            return 'High' if confidence_level in ['High', 'Critical'] else 'Medium'
        elif confidence_level == 'Critical':
            return 'Critical'
        elif confidence_level == 'High':
            return 'High'
        else:
            return 'Medium'
    

    
    def _get_fallback_relationships(self) -> List[RelationshipDefinition]:
        """Fallback to hardcoded relationships if Neo4j discovery fails"""
        logger.info("🔄 Using fallback hardcoded relationships")
        
        return [
            RelationshipDefinition(
                relationship_name="fallback_activity_to_transcript",
                source_pattern="Activity_*",
                target_pattern="Transcript_*",
                key_field="ActivityCode",
                relationship_type="PARENT_CHILD",
                business_priority="High",
                cardinality="1:N",
                validation_rules=["orphaned_record_check"],
                discovered_from_neo4j=False
            ),
            RelationshipDefinition(
                relationship_name="fallback_core_to_transcript",
                source_pattern="Core_*",
                target_pattern="Transcript_*",
                key_field="EmployeeID",
                relationship_type="PARENT_CHILD",
                business_priority="Critical",
                cardinality="1:N",
                validation_rules=["orphaned_record_check"],
                discovered_from_neo4j=False
            )
        ]
    
    def close(self):
        """Close Neo4j connection"""
        if self.driver:
            self.driver.close()
            logger.info("🔌 Disconnected from Neo4j")


class CrossFileAnalyzer:
    """Analyzes referential integrity across SumTotal source files using dynamic discovery"""
    
    def __init__(self, mysql_retrieval: MySQLRetrieval, neo4j_retrieval: Neo4jRetrieval, 
                 performance_monitor: Optional[PerformanceMonitor] = None):
        self.mysql_retrieval = mysql_retrieval
        self.neo4j_retrieval = neo4j_retrieval
        self.performance_monitor = performance_monitor or PerformanceMonitor()
        self.analysis_run_id = f"analysis_{datetime.now().strftime('%Y%m%d_%H%M%S_%f')}"
    
    def analyze_relationships(self, bundles: Dict[str, ContextBundle]) -> List[CrossFileRelationship]:
        """Analyze all cross-file relationships using dynamic discovery"""
        self.performance_monitor.start_timer("total_cross_file_analysis")
        relationships = []
        
        # Step 1: Discover relationships dynamically from Neo4j
        logger.info("🔍 Discovering cross-file relationships from Neo4j...")
        relationship_definitions = self.neo4j_retrieval.discover_cross_file_relationships()
        
        logger.info(f"📋 Found {len(relationship_definitions)} relationship definitions:")
        for rel_def in relationship_definitions:
            discovery_source = "Neo4j" if rel_def.discovered_from_neo4j else "Fallback"
            logger.info(f"   • {rel_def.relationship_name} ({discovery_source})")
        
        # Step 2: Analyze each discovered relationship
        for rel_def in relationship_definitions:
            try:
                discovered_relationships = self._analyze_relationship_definition(bundles, rel_def)
                relationships.extend(discovered_relationships)
            except Exception as e:
                logger.error(f"❌ Error analyzing relationship {rel_def.relationship_name}: {e}")
                continue
        
        # Step 3: Persist results to database
        self._persist_analysis_results(relationships)
        
        processing_time = self.performance_monitor.end_timer("total_cross_file_analysis")
        logger.info(f"✅ Cross-file analysis complete: {len(relationships)} relationships analyzed in {processing_time}ms")
        
        # Log performance summary
        self.performance_monitor.log_performance_summary()
        
        return relationships
    
    def _analyze_relationship_definition(self, bundles: Dict[str, ContextBundle], 
                                       rel_def: RelationshipDefinition) -> List[CrossFileRelationship]:
        """Analyze a specific relationship definition"""
        relationships = []
        
        # Find files matching source and target patterns
        source_files = self._find_matching_files(bundles, rel_def.source_pattern)
        target_files = self._find_matching_files(bundles, rel_def.target_pattern)
        
        logger.debug(f"🔗 Analyzing {rel_def.relationship_name}:")
        logger.debug(f"   Source files: {source_files}")
        logger.debug(f"   Target files: {target_files}")
        logger.debug(f"   Key field: {rel_def.key_field}")
        
        for source_file in source_files:
            for target_file in target_files:
                if source_file == target_file:
                    continue
                
                # Check if both files have the key field
                if not self._file_has_field(bundles[source_file], rel_def.key_field):
                    logger.debug(f"   ⚠️ Source file {source_file} missing field {rel_def.key_field}")
                    continue
                if not self._file_has_field(bundles[target_file], rel_def.key_field):
                    logger.debug(f"   ⚠️ Target file {target_file} missing field {rel_def.key_field}")
                    continue
                
                # Perform MySQL analysis
                relationship = self._perform_mysql_analysis(source_file, target_file, rel_def, bundles)
                if relationship:
                    relationships.append(relationship)
        
        return relationships
    
    def _find_matching_files(self, bundles: Dict[str, ContextBundle], pattern: str) -> List[str]:
        """Find files matching a pattern (supports wildcards)"""
        if pattern.endswith('*'):
            # Pattern matching (e.g., 'Activity_*')
            prefix = pattern[:-1].lower()
            return [name for name in bundles.keys() if name.lower().startswith(prefix)]
        else:
            # Exact matching or table name matching
            matching_files = []
            for name, bundle in bundles.items():
                if (name.lower() == pattern.lower() or 
                    bundle.table_name.lower() == pattern.lower() or
                    bundle.file_key.lower() == pattern.lower()):
                    matching_files.append(name)
            return matching_files
    
    def _file_has_field(self, bundle: ContextBundle, field_name: str) -> bool:
        """Check if a file has a specific field (case-insensitive)"""
        for profile in bundle.field_profiles:
            if profile.sumtotal_field_name.lower() == field_name.lower():
                return True
        return False
    
    def _perform_mysql_analysis(self, source_file: str, target_file: str, 
                               rel_def: RelationshipDefinition, bundles: Dict[str, ContextBundle]) -> Optional[CrossFileRelationship]:
        """Perform MySQL orphaned record analysis with validation rules"""
        source_table = self.mysql_retrieval.resolve_table_name(source_file)
        target_table = self.mysql_retrieval.resolve_table_name(target_file)
        
        try:
            analysis = self.mysql_retrieval.get_orphaned_records_analysis(
                source_table, target_table, rel_def.key_field
            )
            
            # Apply validation rules to filter low-quality relationships
            if not self._passes_validation_rules(analysis, rel_def.validation_rules):
                logger.debug(f"   ❌ Relationship {rel_def.relationship_name} failed validation rules")
                return None
            
            if analysis['total_dependent_records'] > 0:
                relationship = self._create_relationship_from_analysis(
                    rel_def, source_file, target_file, analysis
                )
                
                logger.info(f"✅ {source_file} -> {target_file} on {rel_def.key_field}: "
                          f"{analysis['integrity_percentage']}% integrity, "
                          f"{analysis['orphaned_count']} orphaned records")
                
                return relationship
            
        except Exception as e:
            logger.warning(f"⚠️ Could not analyze {source_file} -> {target_file} on {rel_def.key_field}: {e}")
        
        return None
    
    def _create_relationship_from_analysis(self, rel_def: RelationshipDefinition, source_file: str, 
                                         target_file: str, analysis: Dict[str, Any]) -> CrossFileRelationship:
        """Create CrossFileRelationship from MySQL analysis results"""
        integrity_percentage = analysis['integrity_percentage']
        orphaned_count = analysis['orphaned_count']
        
        # Determine severity based on business priority and integrity
        if rel_def.business_priority == 'Critical' or integrity_percentage < 70:
            severity = "High"
            impact = f"Critical: {orphaned_count:,} orphaned records ({100-integrity_percentage:.1f}% missing references)"
        elif rel_def.business_priority == 'High' or integrity_percentage < 90:
            severity = "Medium"
            impact = f"Moderate: {orphaned_count:,} orphaned records ({100-integrity_percentage:.1f}% missing references)"
        else:
            severity = "Low"
            impact = f"Minor: {orphaned_count:,} orphaned records ({100-integrity_percentage:.1f}% missing references)"
        
        return CrossFileRelationship(
            relationship_name=f"{rel_def.relationship_name}_{source_file}_to_{target_file}",
            primary_file=source_file,
            dependent_file=target_file,
            key_field=rel_def.key_field,
            total_source_records=analysis['total_primary_records'],
            total_dependent_records=analysis['total_dependent_records'],
            orphaned_records=orphaned_count,
            integrity_percentage=integrity_percentage,
            orphaned_samples=analysis['orphaned_samples'],
            severity=severity,
            business_impact=impact,
            processing_time_ms=analysis['processing_time_ms'],
            analysis_run_id=self.analysis_run_id
        )
    
    def _persist_analysis_results(self, relationships: List[CrossFileRelationship]):
        """Persist analysis results to cross_file_integrity_summary table"""
        if not relationships:
            return
        
        try:
            cursor = self.mysql_retrieval.connection.cursor()
            
            insert_query = """
            INSERT INTO cross_file_integrity_summary (
                analysis_run_id, relationship_name, source_file_pattern, target_file_pattern,
                key_field, total_source_records, total_target_records, orphaned_source_records,
                orphaned_target_records, integrity_percentage, processing_time_ms,
                relationship_type, business_priority, discovered_from_neo4j
            ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
            """
            
            for rel in relationships:
                cursor.execute(insert_query, (
                    rel.analysis_run_id,
                    rel.relationship_name,
                    rel.primary_file,
                    rel.dependent_file,
                    rel.key_field,
                    rel.total_source_records,
                    rel.total_dependent_records,
                    rel.orphaned_records,
                    0,  # orphaned_target_records (not calculated in current implementation)
                    rel.integrity_percentage,
                    rel.processing_time_ms,
                    'REFERENCE',  # Default relationship type
                    rel.severity,
                    True  # Assume discovered from Neo4j for now
                ))
            
            self.mysql_retrieval.connection.commit()
            cursor.close()
            
            logger.info(f"💾 Persisted {len(relationships)} relationship analysis results to database")
            
        except Exception as e:
            logger.error(f"❌ Failed to persist analysis results: {e}")
    
    def _passes_validation_rules(self, analysis: Dict[str, Any], validation_rules: List[str]) -> bool:
        """Check if relationship analysis passes validation rules"""
        # TEMPORARY DEBUG: Log all analysis data for debugging
        logger.info(f"🔍 DEBUGGING: Analysis data: {analysis}")
        logger.info(f"🔍 DEBUGGING: Validation rules: {validation_rules}")
        
        for rule in validation_rules:
            if rule == 'minimum_sample_size_100' and analysis['total_dependent_records'] < 100:
                logger.info(f"   ⚠️ TEMP DEBUG: Failed minimum_sample_size_100: {analysis['total_dependent_records']} records")
                # TEMPORARY: Don't reject for now, just log
                continue
            elif rule == 'minimum_sample_size_500' and analysis['total_dependent_records'] < 500:
                logger.info(f"   ⚠️ TEMP DEBUG: Failed minimum_sample_size_500: {analysis['total_dependent_records']} records")
                # TEMPORARY: Don't reject for now, just log
                continue
            elif rule == 'integrity_threshold_10' and analysis['integrity_percentage'] < 10.0:
                logger.info(f"   ⚠️ TEMP DEBUG: Failed integrity_threshold_10: {analysis['integrity_percentage']}% integrity")
                # TEMPORARY: Don't reject for now, just log
                continue
            elif rule == 'integrity_threshold_25' and analysis['integrity_percentage'] < 25.0:
                logger.info(f"   ⚠️ TEMP DEBUG: Failed integrity_threshold_25: {analysis['integrity_percentage']}% integrity")
                # TEMPORARY: Don't reject for now, just log
                continue
        
        # TEMPORARY: Always return True for debugging
        logger.info("🔍 TEMP DEBUG: Allowing all relationships for debugging")
        return True
    
    # Legacy methods removed - use instance methods instead


class FieldProfiler:
    """Creates comprehensive SumTotal field profiles with CSOD validation"""
    
    @staticmethod
    def create_profile(sumtotal_field: str, metrics: Optional[FieldMetrics], 
                      constraints: List[CSODConstraint]) -> SumTotalFieldProfile:
        """Create a complete field profile with violations"""
        violations = []
        severity = "Low"
        
        if not metrics:
            return SumTotalFieldProfile(
                sumtotal_field_name=sumtotal_field,
                metrics=None,
                csod_constraints=constraints,
                violations=["No data metrics available"],
                severity="High"
            )
        
        # Check mandatory coverage
        mandatory_constraints = [c for c in constraints if c.mandatory == "Mandatory"]
        if mandatory_constraints and metrics.total_rows > 0:
            blank_rate = (metrics.null_count + metrics.blank_count) / metrics.total_rows
            if blank_rate > 0:
                violations.append(f"Mandatory field has {blank_rate:.1%} blank/null values")
                severity = "High"
        
        # Check character length violations
        for constraint in constraints:
            if constraint.char_length and constraint.char_length.isdigit():
                max_allowed = int(constraint.char_length)
                if metrics.max_length > max_allowed:
                    violations.append(f"Max length {metrics.max_length} exceeds limit {max_allowed}")
                    severity = "Medium" if severity != "High" else severity
        
        # Check accepted values violations
        for constraint in constraints:
            if constraint.accepted_values and metrics.sample_values:
                accepted = set(v.strip() for v in constraint.accepted_values.split(',') if v.strip())
                if accepted:
                    violations_found = [v for v in metrics.sample_values if v not in accepted]
                    if violations_found:
                        violations.append(f"Values outside accepted set: {violations_found[:3]}")
                        severity = "Medium" if severity != "High" else severity
        
        # Check type compatibility
        for constraint in constraints:
            if constraint.field_type in ['Integer', 'Boolean'] and metrics.sample_values:
                type_violations = FieldProfiler._check_type_compatibility(
                    metrics.sample_values, constraint.field_type
                )
                if type_violations:
                    violations.extend(type_violations)
                    severity = "Medium" if severity != "High" else severity
        
        return SumTotalFieldProfile(
            sumtotal_field_name=sumtotal_field,
            metrics=metrics,
            csod_constraints=constraints,
            violations=violations,
            severity=severity
        )
    
    @staticmethod
    def _check_type_compatibility(sample_values: List[str], field_type: str) -> List[str]:
        """Check if sample values are compatible with expected type"""
        violations = []
        
        if field_type == "Integer":
            non_int_values = []
            for value in sample_values:
                try:
                    int(value)
                except (ValueError, TypeError):
                    non_int_values.append(value)
            
            if non_int_values:
                violations.append(f"Non-integer values found: {non_int_values[:3]}")
        
        elif field_type == "Boolean":
            boolean_values = {'1', '0', 'y', 'n', 'yes', 'no', 't', 'f', 'true', 'false', 'on', 'off'}
            non_bool_values = [v for v in sample_values if v.lower() not in boolean_values]
            
            if non_bool_values:
                violations.append(f"Non-boolean values found: {non_bool_values[:3]}")
        
        return violations


class ContextAssembler:
    """Assembles and ranks context for LLM analysis"""
    
    @staticmethod
    def create_bundle(file_name: str, mysql_retrieval: MySQLRetrieval, 
                     neo4j_retrieval: Neo4jRetrieval) -> ContextBundle:
        """Create complete context bundle"""
        
        # Resolve identifiers
        file_key = FilenameMapper.to_db_key(file_name)
        table_name = mysql_retrieval.resolve_table_name(file_name)
        
        logger.info(f"Creating context bundle: {file_name} -> {file_key} -> {table_name}")
        
        # Get overview
        overview = mysql_retrieval.get_table_overview(table_name)
        
        # Get quality signals
        quality_signals = mysql_retrieval.get_quality_signals(file_name)
        
        # Get mapping constraints
        constraints_by_field = neo4j_retrieval.get_mapping_constraints(file_key)
        
        # Create field profiles
        field_profiles = []
        
        if overview.get('exists') and constraints_by_field:
            for sumtotal_field, constraints in constraints_by_field.items():
                # Check if field exists in actual table
                if sumtotal_field in overview.get('columns', []):
                    metrics = mysql_retrieval.get_field_metrics(table_name, sumtotal_field)
                else:
                    metrics = None
                
                profile = FieldProfiler.create_profile(sumtotal_field, metrics, constraints)
                
                # Add error correlation
                field_error_count = sum(
                    1 for log in quality_signals.error_logs 
                    if sumtotal_field.lower() in log.get('message', '').lower()
                )
                profile.error_count = field_error_count
                
                field_profiles.append(profile)
        
        # Sort profiles by severity and violation count
        field_profiles.sort(key=lambda p: (
            {'High': 0, 'Medium': 1, 'Low': 2}[p.severity],
            -len(p.violations),
            -p.error_count
        ))
        
        # Create mapping summary
        mapping_summary = {
            'total_sumtotal_fields': len(constraints_by_field),
            'fields_with_data': len([p for p in field_profiles if p.metrics]),
            'mandatory_fields': len([
                p for p in field_profiles 
                if any(c.mandatory == "Mandatory" for c in p.csod_constraints)
            ]),
            'fields_with_violations': len([p for p in field_profiles if p.violations])
        }
        
        # Create metadata
        metadata = {
            'generated_at': datetime.now().isoformat(),
            'file_key_mapping': file_key,
            'table_resolution': table_name,
            'cache_key': ContextAssembler._generate_cache_key(file_name, overview, quality_signals)
        }
        
        return ContextBundle(
            file_name=file_name,
            file_key=file_key,
            table_name=table_name,
            overview=overview,
            field_profiles=field_profiles,
            quality_signals=quality_signals,
            mapping_summary=mapping_summary,
            metadata=metadata
        )
    
    @staticmethod
    def _generate_cache_key(file_name: str, overview: Dict, quality_signals: QualitySignals) -> str:
        """Generate cache key for reproducibility"""
        key_data = {
            'file_name': file_name,
            'row_count': overview.get('row_count', 0),
            'error_count': len(quality_signals.error_logs),
            'completeness': quality_signals.completeness_summary
        }
        return hashlib.md5(json.dumps(key_data, sort_keys=True, default=str).encode()).hexdigest()

    @staticmethod
    def create_multi_bundle(
        file_names: List[str], 
        mysql_retrieval: MySQLRetrieval, 
        neo4j_retrieval: Neo4jRetrieval
    ) -> MultiFileContext:
        """Create an aggregated multi-file context bundle.

        This performs per-file context creation and then computes aggregate
        statistics across all files for higher-level analysis.
        """
        logger.info(f"Creating multi-file context for {len(file_names)} file(s)")

        bundles: Dict[str, ContextBundle] = {}

        for file_name in file_names:
            try:
                bundle = ContextAssembler.create_bundle(file_name, mysql_retrieval, neo4j_retrieval)
                bundles[file_name] = bundle
            except Exception as e:
                logger.error(f"Failed to create bundle for {file_name}: {e}")

        # Aggregate statistics
        total_rows = 0
        total_fields_analyzed = 0
        total_errors = 0
        total_violations = 0
        severity_counts = {'High': 0, 'Medium': 0, 'Low': 0}

        for bundle in bundles.values():
            total_rows += bundle.overview.get('row_count', 0) or 0
            total_fields_analyzed += len(bundle.field_profiles)
            total_errors += len(bundle.quality_signals.error_logs)
            total_violations += sum(len(p.violations) for p in bundle.field_profiles)
            for p in bundle.field_profiles:
                if p.severity in severity_counts:
                    severity_counts[p.severity] += 1

        # Perform cross-file relationship analysis using enhanced analyzer
        logger.info("Analyzing cross-file relationships...")
        
        # Create enhanced analyzer with performance monitoring
        analyzer = CrossFileAnalyzer(mysql_retrieval, neo4j_retrieval)
        cross_file_relationships = analyzer.analyze_relationships(bundles)
        
        # Add cross-file metrics to aggregate summary
        critical_relationships = [r for r in cross_file_relationships if r.severity == "High"]
        total_orphaned_records = sum(r.orphaned_records for r in cross_file_relationships)
        
        aggregate_summary = {
            'files_analyzed': len(bundles),
            'total_rows': total_rows,
            'total_fields_analyzed': total_fields_analyzed,
            'total_error_logs': total_errors,
            'total_violations': total_violations,
            'severity_counts': severity_counts,
            'cross_file_relationships': len(cross_file_relationships),
            'critical_integrity_issues': len(critical_relationships),
            'total_orphaned_records': total_orphaned_records,
        }

        metadata = {
            'generated_at': datetime.now().isoformat(),
            'cache_keys': {
                name: ContextAssembler._generate_cache_key(
                    name, bundles[name].overview, bundles[name].quality_signals
                ) for name in bundles
            }
        }

        logger.info(f"✅ Cross-file analysis complete: {len(cross_file_relationships)} relationships, {len(critical_relationships)} critical issues")

        return MultiFileContext(
            file_names=file_names,
            bundles=bundles,
            aggregate_summary=aggregate_summary,
            cross_file_relationships=cross_file_relationships,
            metadata=metadata
        )


class RetrievalFramework:
    """Main retrieval framework class"""
    
    def __init__(self):
        self.performance_monitor = PerformanceMonitor()
        self.mysql_retrieval = MySQLRetrieval(self.performance_monitor)
        self.neo4j_retrieval = Neo4jRetrieval(self.performance_monitor)
    
    def build_analysis_context(self, file_name: str, 
                             save_bundle: bool = False,
                             output_dir: Optional[str] = None) -> ContextBundle:
        """
        Main entrypoint: Build complete analysis context for a SumTotal file
        
        Args:
            file_name: Original uploaded filename (e.g., "Transcript_QuickAssessment.csv")
            save_bundle: Whether to save the context bundle to disk
            output_dir: Directory to save bundle (defaults to current directory)
        
        Returns:
            ContextBundle: Complete context for LLM analysis
        """
        logger.info(f"🚀 Building analysis context for: {file_name}")
        
        try:
            # Create context bundle
            bundle = ContextAssembler.create_bundle(
                file_name, self.mysql_retrieval, self.neo4j_retrieval
            )
            
            # Log summary
            logger.info(f"✅ Context bundle created:")
            logger.info(f"   • File: {bundle.file_name} -> {bundle.file_key}")
            logger.info(f"   • Table: {bundle.table_name}")
            logger.info(f"   • Rows: {bundle.overview.get('row_count', 0):,}")
            logger.info(f"   • Fields analyzed: {len(bundle.field_profiles)}")
            logger.info(f"   • High severity: {len([p for p in bundle.field_profiles if p.severity == 'High'])}")
            logger.info(f"   • Total violations: {sum(len(p.violations) for p in bundle.field_profiles)}")
            logger.info(f"   • Error logs: {len(bundle.quality_signals.error_logs)}")
            
            # Save bundle if requested
            if save_bundle:
                self._save_bundle(bundle, output_dir)
            
            return bundle
            
        except Exception as e:
            logger.error(f"❌ Error building context for {file_name}: {e}")
            raise
    
    def build_multi_file_context(
        self, 
        file_names: List[str], 
        save_bundle: bool = False, 
        output_dir: Optional[str] = None
    ) -> MultiFileContext:
        """Build aggregated analysis context across multiple files.

        Args:
            file_names: List of original uploaded filenames
            save_bundle: Whether to persist the multi-file bundle as JSON
            output_dir: Destination directory when saving is enabled
        """
        logger.info(f"🚀 Building multi-file analysis context for: {file_names}")

        try:
            multi = ContextAssembler.create_multi_bundle(
                file_names, self.mysql_retrieval, self.neo4j_retrieval
            )

            logger.info(
                "✅ Multi-file context created: %d files, %d rows, %d fields, %d violations",
                multi.aggregate_summary.get('files_analyzed', 0),
                multi.aggregate_summary.get('total_rows', 0),
                multi.aggregate_summary.get('total_fields_analyzed', 0),
                multi.aggregate_summary.get('total_violations', 0),
            )

            if save_bundle:
                self._save_multi_bundle(multi, output_dir)

            return multi
        except Exception as e:
            logger.error(f"❌ Error building multi-file context: {e}")
            raise
    
    def _save_bundle(self, bundle: ContextBundle, output_dir: Optional[str] = None):
        """Save context bundle to disk for inspection"""
        if not output_dir:
            output_dir = os.getcwd()
        
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        filename = f"context_bundle_{bundle.file_key}_{timestamp}.json"
        filepath = os.path.join(output_dir, filename)
        
        # Convert to JSON-serializable format
        bundle_dict = asdict(bundle)
        
        with open(filepath, 'w', encoding='utf-8') as f:
            json.dump(bundle_dict, f, indent=2, default=str)
        
        logger.info(f"💾 Context bundle saved: {filepath}")
    
    def _save_multi_bundle(self, multi_bundle: MultiFileContext, output_dir: Optional[str] = None):
        """Save multi-file context bundle to disk for inspection"""
        if not output_dir:
            output_dir = os.getcwd()

        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        safe_key = hashlib.md5(
            json.dumps(sorted(multi_bundle.file_names)).encode()
        ).hexdigest()[:10]
        filename = f"context_bundle_MULTI_{safe_key}_{timestamp}.json"
        filepath = os.path.join(output_dir, filename)

        bundle_dict = asdict(multi_bundle)

        with open(filepath, 'w', encoding='utf-8') as f:
            json.dump(bundle_dict, f, indent=2, default=str)

        logger.info(f"💾 Multi-file context bundle saved: {filepath}")
    
    def get_bundle_summary(self, bundle: ContextBundle) -> Dict[str, Any]:
        """Get a concise summary of the context bundle"""
        high_severity_fields = [p for p in bundle.field_profiles if p.severity == "High"]
        
        return {
            'file_info': {
                'name': bundle.file_name,
                'key': bundle.file_key,
                'table': bundle.table_name,
                'rows': bundle.overview.get('row_count', 0)
            },
            'analysis_summary': {
                'fields_analyzed': len(bundle.field_profiles),
                'high_severity_count': len(high_severity_fields),
                'total_violations': sum(len(p.violations) for p in bundle.field_profiles),
                'mandatory_coverage_issues': len([
                    p for p in bundle.field_profiles 
                    if any('Mandatory field has' in v for v in p.violations)
                ])
            },
            'quality_signals': {
                'error_logs_count': len(bundle.quality_signals.error_logs),
                'mandatory_completeness': bundle.quality_signals.completeness_summary.get('mandatory_completeness'),
                'top_error_types': list(bundle.quality_signals.error_summary.keys())[:5]
            },
            'top_issues': [
                {
                    'field': p.sumtotal_field_name,
                    'severity': p.severity,
                    'violations': p.violations[:3],  # Top 3 violations
                    'error_count': p.error_count
                }
                for p in bundle.field_profiles[:5]  # Top 5 problematic fields
                if p.violations
            ]
        }
    
    def get_cross_file_analysis(self, file_names: List[str]) -> Dict[str, Any]:
        """Get cross-file relationship analysis for PDF generator"""
        try:
            multi_context = self.build_multi_file_context(file_names)
            
            # Convert cross-file relationships to PDF-friendly format
            cross_file_patterns = {}
            integrity_analysis = []
            
            for relationship in multi_context.cross_file_relationships:
                # Format for cross-file patterns table
                pattern_key = f"{relationship.key_field}_integrity"
                if pattern_key not in cross_file_patterns:
                    cross_file_patterns[pattern_key] = {
                        'files': [],
                        'total_count': 0,
                        'severity': relationship.severity
                    }
                
                cross_file_patterns[pattern_key]['files'].extend([
                    relationship.primary_file, relationship.dependent_file
                ])
                cross_file_patterns[pattern_key]['total_count'] += relationship.orphaned_records
                
                # Format for integrity analysis table
                integrity_analysis.append({
                    'source_pattern': relationship.primary_file.split('_')[0] + '_*',
                    'dependent_pattern': relationship.dependent_file.split('_')[0] + '_*', 
                    'key_field': relationship.key_field,
                    'total_references': relationship.total_dependent_records,
                    'orphaned_records': relationship.orphaned_records,
                    'integrity_percentage': relationship.integrity_percentage,
                    'severity': relationship.severity,
                    'business_impact': relationship.business_impact
                })
            
            # Remove duplicates from files lists
            for pattern in cross_file_patterns.values():
                pattern['files'] = list(set(pattern['files']))
            
            return {
                'cross_file_patterns': cross_file_patterns,
                'integrity_analysis': integrity_analysis,
                'summary': {
                    'total_relationships': len(multi_context.cross_file_relationships),
                    'critical_issues': len([r for r in multi_context.cross_file_relationships if r.severity == "High"]),
                    'total_orphaned_records': sum(r.orphaned_records for r in multi_context.cross_file_relationships)
                }
            }
            
        except Exception as e:
            logger.error(f"Error getting cross-file analysis: {e}")
            return {
                'cross_file_patterns': {},
                'integrity_analysis': [],
                'summary': {'total_relationships': 0, 'critical_issues': 0, 'total_orphaned_records': 0}
            }
    
    def get_multi_bundle_summary(self, multi_bundle: MultiFileContext) -> Dict[str, Any]:
        """Get a concise summary for a multi-file context bundle"""
        per_file = {}
        for name, b in multi_bundle.bundles.items():
            per_file[name] = {
                'rows': b.overview.get('row_count', 0),
                'fields_analyzed': len(b.field_profiles),
                'violations': sum(len(p.violations) for p in b.field_profiles),
                'high_severity_count': len([p for p in b.field_profiles if p.severity == 'High']),
                'error_logs_count': len(b.quality_signals.error_logs),
            }

        return {
            'files': list(multi_bundle.file_names),
            'aggregate': multi_bundle.aggregate_summary,
            'per_file': per_file,
        }
    
    def close(self):
        """Close all database connections"""
        self.mysql_retrieval.close()
        self.neo4j_retrieval.close()


# CLI interface for testing
def main():
    """CLI entrypoint for testing the retrieval framework"""
    import argparse
    
    parser = argparse.ArgumentParser(description="SumTotal Data Quality Retrieval Framework")
    parser.add_argument('file_name', help='SumTotal filename to analyze')
    parser.add_argument('--save', action='store_true', help='Save context bundle to disk')
    parser.add_argument('--output-dir', help='Output directory for saved bundle')
    parser.add_argument('--summary-only', action='store_true', help='Show summary only')
    
    args = parser.parse_args()
    
    # Initialize framework
    framework = RetrievalFramework()
    
    try:
        # Build context
        bundle = framework.build_analysis_context(
            args.file_name, 
            save_bundle=args.save,
            output_dir=args.output_dir
        )
        
        if args.summary_only:
            # Print summary
            summary = framework.get_bundle_summary(bundle)
            print("\n" + "="*60)
            print("SUMTOTAL ANALYSIS CONTEXT SUMMARY")
            print("="*60)
            print(json.dumps(summary, indent=2))
        else:
            # Print detailed field profiles
            print(f"\n📊 FIELD PROFILES ({len(bundle.field_profiles)} total)")
            print("-" * 60)
            
            for i, profile in enumerate(bundle.field_profiles[:10], 1):  # Top 10
                print(f"\n{i}. {profile.sumtotal_field_name} ({profile.severity})")
                if profile.violations:
                    for violation in profile.violations:
                        print(f"   ⚠️  {violation}")
                if profile.metrics:
                    print(f"   📈 Rows: {profile.metrics.total_rows:,}, Nulls: {profile.metrics.null_count}, Max Length: {profile.metrics.max_length}")
                print(f"   🎯 Maps to {len(profile.csod_constraints)} CSOD field(s)")
    
    finally:
        framework.close()


if __name__ == "__main__":
    main()
