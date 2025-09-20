from neo4j import GraphDatabase
import os
from dotenv import load_dotenv

load_dotenv()

neo4j_driver = GraphDatabase.driver(
    os.getenv('NEO4J_URI'),
    auth=(os.getenv('NEO4J_USER'), os.getenv('NEO4J_PASSWORD'))
)

def check_mandatory_fields():
    with neo4j_driver.session() as session:
        # Check Activity_Curriculum mandatory fields
        query = """
        MATCH (f:File {name: 'Activity_Curriculum'})-[:HAS_FIELD]->(st:SumTotalField)
        MATCH (st)-[:MAPS_TO]->(csod:CSODField)
        WHERE csod.mandatory = 'Mandatory'
        RETURN st.name AS field_name
        """
        
        result = session.run(query)
        mandatory_fields = [record["field_name"] for record in result]
        
        print(f"Found {len(mandatory_fields)} mandatory fields for Activity_Curriculum:")
        for field in mandatory_fields:
            print(f"- {field}")

if __name__ == "__main__":
    check_mandatory_fields()
    neo4j_driver.close()