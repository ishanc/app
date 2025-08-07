import os
import pandas as pd
import logging
from typing import Dict, List

# Set up logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

def get_transcript_curriculum_rules(cypher_file_path: str) -> Dict:
    """Extract only TranscriptCurriculum rules from Neo4j cypher file"""
    rules = {}
    current_file = None
    current_st_field = None
    current_csod_field = None
    current_properties = {}
    is_transcript_curriculum = False

    with open(cypher_file_path, 'r') as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith('//'):
                continue

            if line.startswith('MERGE (f:File {name:'):
                current_file = line.split('"')[1]
                is_transcript_curriculum = (current_file == "TranscriptCurriculum")
                if is_transcript_curriculum:
                    rules[current_file] = []
                
            if not is_transcript_curriculum:
                continue

            if line.startswith('MERGE (csod:CSODField {name:'):
                current_csod_field = line.split('"')[1]
                current_properties = {
                    "CSOD Field Name": current_csod_field,
                    "SumTotal Field Name": "",
                    "Default value": "",
                    "field_type": "",
                    "mandatory": "",
                    "accepted_values": ""
                }

            elif line.startswith('SET csod.'):
                if current_file and current_csod_field:
                    try:
                        prop_line = line[9:].strip()
                        prop_name, prop_value = prop_line.split('=', 1)
                        prop_name = prop_name.strip()
                        prop_value = prop_value.strip().rstrip(',')
                        
                        # Map Neo4j property names to our dictionary keys
                        prop_mapping = {
                            'default_value': 'Default value',
                            'field_type': 'field_type',
                            'accepted_values': 'accepted_values',
                            'mandatory': 'mandatory'
                        }
                        
                        if prop_name in prop_mapping:
                            current_properties[prop_mapping[prop_name]] = prop_value
                            
                    except ValueError as e:
                        logger.warning(f"Failed to parse property line: {line}")

            elif line.startswith('MERGE (st:SumTotalField {name:'):
                if current_file:
                    current_st_field = line.split('"')[1]

            elif line.startswith('MERGE (st)-[:MAPS_TO]->(csod)'):
                if current_file and current_st_field and current_csod_field:
                    current_properties["SumTotal Field Name"] = current_st_field

            elif line.startswith('MERGE (f)-[:OUTPUTS_FIELD]->(csod)'):
                if current_file and current_csod_field and current_properties:
                    rules[current_file].append(current_properties.copy())
                    current_csod_field = None
                    current_properties = {}

    return rules

def print_field_details(rules: Dict):
    """Print field details in a readable format"""
    for file_name, fields in rules.items():
        print(f"\nFields for {file_name}:")
        print("=" * 80)
        
        # Sort fields by name for better readability
        fields.sort(key=lambda x: x["CSOD Field Name"])
        
        for field in fields:
            print(f"\nCSOD Field: {field['CSOD Field Name']}")
            print("-" * 40)
            for key, value in field.items():
                if key != "CSOD Field Name" and value:  # Only print non-empty values
                    print(f"{key}: {value}")

if __name__ == "__main__":
    # Get the Neo4j cypher file path
    cypher_file = os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(__file__))), 
                              "neo4j_knowledge_graph_cypher.txt")
    
    # Extract and print TranscriptCurriculum rules
    rules = get_transcript_curriculum_rules(cypher_file)
    print_field_details(rules)