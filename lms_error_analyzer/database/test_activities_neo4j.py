#!/usr/bin/env python3
"""
Neo4j Activities Relationship Testing Script
Tests the Activities portion of Neo4j mappings and relationships
"""

import os
import sys
import json
import logging
from typing import Dict, List, Any
from datetime import datetime
from neo4j import GraphDatabase
from dotenv import load_dotenv

# Add parent directory to path for imports
sys.path.append(os.path.dirname(os.path.dirname(os.path.dirname(__file__))))

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class ActivitiesNeo4jTester:
    """Test Activities relationships in Neo4j"""
    
    def __init__(self):
        load_dotenv()
        self.neo4j_uri = os.getenv("NEO4J_URI")
        self.neo4j_user = os.getenv("NEO4J_USER") 
        self.neo4j_password = os.getenv("NEO4J_PASSWORD")
        
        if not all([self.neo4j_uri, self.neo4j_user, self.neo4j_password]):
            raise ValueError("Missing Neo4j credentials in .env file")
            
        self.driver = None
        self.activities_cypher_file = os.path.join(
            os.path.dirname(os.path.dirname(os.path.dirname(__file__))),
            "activities_relationships.cypher"
        )
    
    def connect(self):
        """Connect to Neo4j database"""
        try:
            self.driver = GraphDatabase.driver(
                self.neo4j_uri, 
                auth=(self.neo4j_user, self.neo4j_password)
            )
            logger.info("✅ Connected to Neo4j database")
        except Exception as e:
            logger.error(f"❌ Failed to connect to Neo4j: {e}")
            raise
    
    def disconnect(self):
        """Close Neo4j connection"""
        if self.driver:
            self.driver.close()
            logger.info("🔌 Disconnected from Neo4j")
    
    def execute_cypher_file(self, file_path: str):
        """Execute cypher commands from file"""
        try:
            with open(file_path, 'r') as file:
                cypher_content = file.read()
            
            # Split into individual statements and execute
            statements = [stmt.strip() for stmt in cypher_content.split(';') if stmt.strip()]
            
            with self.driver.session() as session:
                for i, statement in enumerate(statements, 1):
                    if statement:
                        logger.info(f"📝 Executing statement {i}/{len(statements)}")
                        result = session.run(statement)
                        logger.info(f"✅ Statement {i} executed successfully")
                        
        except Exception as e:
            logger.error(f"❌ Error executing cypher file: {e}")
            raise
    
    def test_activities_setup(self) -> Dict[str, Any]:
        """Test Activities primary key setup"""
        query = """
        MATCH (st:SumTotalField)
        WHERE st.isPrimaryKey = true 
          AND st.entityType = "Activities"
        RETURN st.name as field_name, 
               st.file as file_name,
               st.uniqueIdentifier as uid,
               st.businessDescription as description
        """
        
        with self.driver.session() as session:
            result = session.run(query)
            records = [record.data() for record in result]
            
        logger.info(f"🔍 Found {len(records)} Activities primary key fields")
        return {"primary_keys": records}
    
    def test_activities_relationships(self) -> Dict[str, Any]:
        """Test Activities foreign key relationships"""
        query = """
        MATCH (pk:SumTotalField {entityType: "Activities"})<-[r:REFERENCES_PRIMARY_KEY]-(fk:SumTotalField)
        RETURN fk.name as foreign_key_field,
               fk.file as foreign_key_file,
               pk.name as primary_key_field,
               pk.file as primary_key_file,
               r.businessRule as business_rule,
               r.relationshipType as relationship_type,
               r.validationPriority as priority
        ORDER BY fk.file, fk.name
        """
        
        with self.driver.session() as session:
            result = session.run(query)
            records = [record.data() for record in result]
            
        logger.info(f"🔗 Found {len(records)} Activities relationships")
        return {"relationships": records}
    
    def test_orphaned_records_potential(self) -> Dict[str, Any]:
        """Test for potential orphaned records (fields that should reference Activities)"""
        query = """
        MATCH (st:SumTotalField)
        WHERE (st.name CONTAINS "ActivityCode" OR st.name CONTAINS "ClassCode")
          AND NOT EXISTS((st)-[:REFERENCES_PRIMARY_KEY]->())
          AND st.isPrimaryKey IS NULL
        RETURN st.name as field_name,
               st.file as file_name,
               "Potential orphaned reference" as status
        ORDER BY st.file, st.name
        """
        
        with self.driver.session() as session:
            result = session.run(query)
            records = [record.data() for record in result]
            
        logger.info(f"⚠️  Found {len(records)} potential orphaned references")
        return {"potential_orphans": records}
    
    def validate_activities_integrity(self) -> Dict[str, Any]:
        """Validate Activities data integrity"""
        validation_results = {}
        
        # Test 1: Primary keys setup
        logger.info("🧪 Testing Activities primary key setup...")
        validation_results["primary_key_test"] = self.test_activities_setup()
        
        # Test 2: Relationships
        logger.info("🧪 Testing Activities relationships...")
        validation_results["relationships_test"] = self.test_activities_relationships()
        
        # Test 3: Orphaned records
        logger.info("🧪 Testing for orphaned references...")
        validation_results["orphaned_test"] = self.test_orphaned_records_potential()
        
        return validation_results
    
    def generate_test_report(self, results: Dict[str, Any]) -> str:
        """Generate a formatted test report"""
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        report_file = f"activities_neo4j_test_report_{timestamp}.json"
        
        # Add summary statistics
        summary = {
            "test_timestamp": timestamp,
            "primary_keys_count": len(results["primary_key_test"]["primary_keys"]),
            "relationships_count": len(results["relationships_test"]["relationships"]),
            "potential_orphans_count": len(results["orphaned_test"]["potential_orphans"]),
            "test_status": "PASSED" if len(results["orphaned_test"]["potential_orphans"]) == 0 else "WARNING"
        }
        
        full_report = {
            "summary": summary,
            "detailed_results": results
        }
        
        report_path = os.path.join(os.path.dirname(__file__), report_file)
        with open(report_path, 'w') as f:
            json.dump(full_report, f, indent=2)
        
        logger.info(f"📄 Test report saved to: {report_path}")
        return report_path
    
    def run_full_test(self):
        """Run the complete Activities Neo4j test suite"""
        logger.info("🚀 Starting Activities Neo4j Test Suite...")
        
        try:
            # Connect to Neo4j
            self.connect()
            
            # Execute the Activities relationship setup
            if os.path.exists(self.activities_cypher_file):
                logger.info("📋 Executing Activities relationship setup...")
                self.execute_cypher_file(self.activities_cypher_file)
            else:
                logger.warning(f"⚠️  Activities cypher file not found: {self.activities_cypher_file}")
            
            # Run validation tests
            results = self.validate_activities_integrity()
            
            # Generate report
            report_path = self.generate_test_report(results)
            
            # Print summary
            summary = results
            logger.info("\n" + "="*50)
            logger.info("📊 ACTIVITIES NEO4J TEST SUMMARY")
            logger.info("="*50)
            logger.info(f"✅ Primary Keys: {len(results['primary_key_test']['primary_keys'])}")
            logger.info(f"🔗 Relationships: {len(results['relationships_test']['relationships'])}")
            logger.info(f"⚠️  Potential Orphans: {len(results['orphaned_test']['potential_orphans'])}")
            logger.info(f"📄 Report: {report_path}")
            logger.info("="*50)
            
        except Exception as e:
            logger.error(f"❌ Test suite failed: {e}")
            raise
        finally:
            self.disconnect()


def main():
    """Main function to run Activities Neo4j tests"""
    try:
        tester = ActivitiesNeo4jTester()
        tester.run_full_test()
        logger.info("🎉 Activities Neo4j test suite completed successfully!")
        
    except Exception as e:
        logger.error(f"💥 Test suite failed: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
