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
class MultiFileContext:
    """Aggregated context for multiple related files"""
    file_names: List[str]
    bundles: Dict[str, ContextBundle]
    aggregate_summary: Dict[str, Any]
    metadata: Dict[str, Any]


class MySQLRetrieval:
    """Handles MySQL database queries for raw data and quality signals"""
    
    def __init__(self):
        self.connection = None
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
                    avg_length=avg_length or 0.0,
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
            completeness = cursor.fetchone() or {}
            
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
    
    def close(self):
        """Close MySQL connection"""
        if self.connection:
            self.connection.close()
            logger.info("🔌 Disconnected from MySQL")


class Neo4jRetrieval:
    """Handles Neo4j queries for mapping rules and constraints"""
    
    def __init__(self):
        self.driver = None
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
    
    def close(self):
        """Close Neo4j connection"""
        if self.driver:
            self.driver.close()
            logger.info("🔌 Disconnected from Neo4j")


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
        return hashlib.md5(json.dumps(key_data, sort_keys=True).encode()).hexdigest()

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

        aggregate_summary = {
            'files_analyzed': len(bundles),
            'total_rows': total_rows,
            'total_fields_analyzed': total_fields_analyzed,
            'total_error_logs': total_errors,
            'total_violations': total_violations,
            'severity_counts': severity_counts,
        }

        metadata = {
            'generated_at': datetime.now().isoformat(),
            'cache_keys': {
                name: ContextAssembler._generate_cache_key(
                    name, bundles[name].overview, bundles[name].quality_signals
                ) for name in bundles
            }
        }

        return MultiFileContext(
            file_names=file_names,
            bundles=bundles,
            aggregate_summary=aggregate_summary,
            metadata=metadata
        )


class RetrievalFramework:
    """Main retrieval framework class"""
    
    def __init__(self):
        self.mysql_retrieval = MySQLRetrieval()
        self.neo4j_retrieval = Neo4jRetrieval()
    
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
