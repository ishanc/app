import os
import logging
from neo4j import GraphDatabase
from typing import Dict, List
import json

# Set up logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Neo4j connection settings (using environment variables)
NEO4J_URI = os.getenv('NEO4J_URI', 'bolt://localhost:7687')
NEO4J_USER = os.getenv('NEO4J_USER', 'neo4j')
NEO4J_PASSWORD = os.getenv('NEO4J_PASSWORD')

if not NEO4J_PASSWORD:
    raise ValueError("NEO4J_PASSWORD environment variable is required")

def get_neo4j_rules(file_name: str) -> List[Dict]:
    """Fetch mapping rules directly from Neo4j for a specific file"""
    rules = []
    
    with GraphDatabase.driver(NEO4J_URI, auth=(NEO4J_USER, NEO4J_PASSWORD)) as driver:
        with driver.session() as session:
            # Query to get all CSOD fields and their properties for a specific file
            query = """
            MATCH (f:File {name: $fileName})-[:OUTPUTS_FIELD]->(csod:CSODField)
            OPTIONAL MATCH (st:SumTotalField)-[:MAPS_TO]->(csod)
            OPTIONAL MATCH (f)-[:HAS_FIELD]->(st)
            RETURN csod.name as csod_field_name,
                   st.name as sumtotal_field_name,
                   csod.mandatory as mandatory,
                   csod.field_type as field_type,
                   csod.char_length as char_length,
                   csod.default_value as default_value,
                   csod.accepted_values as accepted_values
            ORDER BY csod_field_name
            """
            result = session.run(query, fileName=file_name)
            
            for record in result:
                rule = {
                    "CSOD Field Name": record["csod_field_name"],
                    "SumTotal Field Name": record["sumtotal_field_name"] or "",
                    "mandatory": record["mandatory"] or "Optional",
                    "field_type": record["field_type"] or "",
                    "char_length": record["char_length"] or "",
                    "default_value": record["default_value"] or "",
                    "accepted_values": record["accepted_values"] or ""
                }
                rules.append(rule)
    
    return rules

def test_neo4j_rules():
    """Test fetching and validating Neo4j rules"""
    try:
        # Test TranscriptCurriculum file rules
        logger.info("Fetching rules for TranscriptCurriculum...")
        rules = get_neo4j_rules("TranscriptCurriculum")
        
        # Print all rules in a readable format
        logger.info("\nTranscriptCurriculum Rules:")
        logger.info("=" * 50)
        for rule in rules:
            logger.info(f"\nField: {rule['CSOD Field Name']}")
            logger.info(f"Source: {rule['SumTotal Field Name']}")
            logger.info(f"Mandatory: {rule['mandatory']}")
            logger.info(f"Field Type: {rule['field_type']}")
            logger.info(f"Default Value: {rule['default_value']}")
            logger.info(f"Accepted Values: {rule['accepted_values']}")
        
        # Specifically check the Archived field
        archived_rule = next((r for r in rules if r["CSOD Field Name"] == "Archived"), None)
        if archived_rule:
            logger.info("\nArchived Field Configuration:")
            logger.info("=" * 50)
            logger.info(json.dumps(archived_rule, indent=2))
        else:
            logger.error("Archived field not found in rules!")
            
    except Exception as e:
        logger.error(f"Error testing Neo4j rules: {str(e)}", exc_info=True)

if __name__ == "__main__":
    test_neo4j_rules()