import sys
sys.path.append('../lasVegas/app')
import sumtotal_transformer_with_neo4j as transformer
from neo4j import GraphDatabase
import os
from dotenv import load_dotenv

load_dotenv()

# Initialize the Neo4j driver
NEO4J_URI = os.getenv("NEO4J_URI")
NEO4J_USER = os.getenv("NEO4J_USER")
NEO4J_PASSWORD = os.getenv("NEO4J_PASSWORD")

driver = GraphDatabase.driver(NEO4J_URI, auth=(NEO4J_USER, NEO4J_PASSWORD))

try:
    with driver.session() as session:
        # Test the exact query being used
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
               csod.accepted_values as accepted_values,
               csod.transformation as transformation
        LIMIT 5
        """
        result = session.run(query, fileName="Activity_Curriculum")
        
        print("Database query results:")
        for i, record in enumerate(result):
            print(f"\nRecord {i+1}:")
            print(f"  csod_field_name: {record['csod_field_name']}")
            print(f"  sumtotal_field_name: {record['sumtotal_field_name']}")
            print(f"  mandatory: {record['mandatory']}")
            print(f"  field_type: {record['field_type']}")
            print(f"  char_length: {record['char_length']}")
            print(f"  default_value: {record['default_value']}")
            print(f"  accepted_values: {record['accepted_values']}")
            print(f"  transformation: {record['transformation'][:100] if record['transformation'] else 'None'}...")
            
            # Check if default_value field exists
            if 'default_value' in record:
                print(f"  ✅ default_value field exists: {record['default_value']}")
            else:
                print(f"  ❌ default_value field missing")
            print(f"  Available keys: {list(record.keys())}")

finally:
    driver.close() 