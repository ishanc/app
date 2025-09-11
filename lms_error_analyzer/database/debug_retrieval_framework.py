#!/usr/bin/env python3
"""
Debug script to inspect retrieval framework data
"""

import os
import sys
import json
import logging
from typing import List

sys.path.append(os.path.dirname(__file__))

from retrieval_framework import RetrievalFramework
from pdf_quality_report import get_original_file_list_from_db

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def debug_retrieval_framework():
    """Debug what data the retrieval framework is seeing"""
    try:
        logger.info("🔍 Debugging retrieval framework...")
        
        # Get files
        file_names = get_original_file_list_from_db()
        logger.info(f"📁 Files to analyze: {file_names}")
        
        # Initialize framework
        framework = RetrievalFramework()
        
        # Build multi-file context and inspect it
        logger.info("🔨 Building multi-file context...")
        multi_context = framework.build_multi_file_context(file_names)
        
        logger.info(f"\n📊 MULTI-FILE CONTEXT SUMMARY:")
        logger.info(f"Files processed: {len(multi_context.bundles)}")
        
        # Inspect each bundle
        for file_name, bundle in multi_context.bundles.items():
            logger.info(f"\n📄 FILE: {file_name}")
            logger.info(f"   Key: {bundle.file_key}")
            logger.info(f"   Table: {bundle.table_name}")
            logger.info(f"   Rows: {bundle.overview.get('row_count', 0):,}")
            logger.info(f"   Fields: {len(bundle.field_profiles)}")
            
            # Show field names to understand what's available
            field_names = [p.sumtotal_field_name for p in bundle.field_profiles]
            logger.info(f"   Field Names: {field_names}")
            
            # Show Neo4j constraints
            logger.info(f"   Neo4j Constraints Found: {len(bundle.field_profiles)} fields")
            for profile in bundle.field_profiles[:3]:  # Show first 3
                constraints = [c.csod_field_name for c in profile.csod_constraints]
                logger.info(f"     • {profile.sumtotal_field_name} -> {constraints}")
        
        # Debug our relationship patterns
        logger.info(f"\n🔗 RELATIONSHIP PATTERN DEBUGGING:")
        
        # Our hardcoded patterns
        relationship_rules = [
            ('core_', ['transcript_', 'activity_'], 'Employee_ID', 'employee_integrity'),
            ('activity_', ['transcript_'], 'Activity_ID', 'activity_integrity'),
            ('activity_', ['transcript_'], 'Curriculum_ID', 'curriculum_integrity'),
            ('prerequisites_', ['activity_'], 'Instructor_ID', 'instructor_integrity'),
        ]
        
        for primary_pattern, dependent_patterns, key_field, relationship_name in relationship_rules:
            logger.info(f"\n🔍 Checking pattern: {primary_pattern} -> {dependent_patterns} on {key_field}")
            
            # Find files matching patterns
            primary_files = [name for name in multi_context.bundles.keys() 
                            if primary_pattern in name.lower()]
            
            dependent_files = [name for name in multi_context.bundles.keys()
                             if any(pattern in name.lower() for pattern in dependent_patterns)]
            
            logger.info(f"   Primary files found: {primary_files}")
            logger.info(f"   Dependent files found: {dependent_files}")
            
            # Check if key field exists in files
            for file_name in primary_files + dependent_files:
                if file_name in multi_context.bundles:
                    bundle = multi_context.bundles[file_name]
                    has_field = any(p.sumtotal_field_name.lower() == key_field.lower() 
                                   for p in bundle.field_profiles)
                    logger.info(f"   {file_name} has {key_field}: {has_field}")
                    
                    if has_field:
                        # Get the field profile
                        field_profile = next((p for p in bundle.field_profiles 
                                            if p.sumtotal_field_name.lower() == key_field.lower()), None)
                        if field_profile and field_profile.metrics:
                            logger.info(f"     Sample values: {field_profile.metrics.sample_values[:3]}")
        
        # Show aggregate summary
        logger.info(f"\n📈 AGGREGATE SUMMARY:")
        for key, value in multi_context.aggregate_summary.items():
            logger.info(f"   {key}: {value}")
        
        logger.info("✅ Debug completed!")
        return True
        
    except Exception as e:
        logger.error(f"❌ Debug failed: {e}")
        import traceback
        traceback.print_exc()
        return False
    
    finally:
        try:
            framework.mysql_retrieval.close()
            framework.neo4j_retrieval.close()
        except:
            pass

if __name__ == "__main__":
    debug_retrieval_framework()
