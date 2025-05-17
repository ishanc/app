from neo4j import GraphDatabase
import os
from dotenv import load_dotenv
import logging

def setup_logging():
    logging.basicConfig(
        level=logging.INFO,
        format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
    )
    return logging.getLogger(__name__)

def load_cypher_file(file_path):
    """Read and split the cypher file into individual statements."""
    with open(file_path, 'r') as f:
        content = f.read()
    
    # Split on semicolons, but keep statements that are part of the same block together
    statements = []
    current_statement = []
    
    for line in content.split('\n'):
        # Skip comments and empty lines
        if line.strip().startswith('//') or not line.strip():
            continue
            
        current_statement.append(line)
        
        if line.strip().endswith(';'):
            statements.append('\n'.join(current_statement))
            current_statement = []
    
    # Add any remaining statement
    if current_statement:
        statements.append('\n'.join(current_statement))
    
    return statements

def get_field_details(session, file_type, field_name):
    """Query Neo4j for details about a specific field in a file type."""
    query = """
    MATCH (f:File {name: $file_type})-[:HAS_FIELD]->(field)
    WHERE field.name = $field_name
    OPTIONAL MATCH (field)-[:MAPS_TO]->(target_field)
    OPTIONAL MATCH (field)-[:HAS_TRANSFORMATION]->(transform)
    RETURN field, target_field, transform
    """
    result = session.run(query, file_type=file_type, field_name=field_name)
    return result.single()

def main():
    logger = setup_logging()
    
    # Load environment variables
    load_dotenv()
    
    # Get Neo4j credentials
    neo4j_uri = os.getenv('NEO4J_URI', 'bolt://localhost:7687')
    neo4j_user = os.getenv('NEO4J_USER', 'neo4j')
    neo4j_password = os.getenv('NEO4J_PASSWORD')
    
    if not neo4j_password:
        raise ValueError("NEO4J_PASSWORD environment variable is required")
        
    logger.info(f"Connecting to Neo4j at {neo4j_uri}")
    
    # Connect to Neo4j
    driver = GraphDatabase.driver(neo4j_uri, auth=(neo4j_user, neo4j_password))
    
    try:
        # Check if we need to load data
        with driver.session() as session:
            result = session.run("MATCH (n) RETURN count(n) as node_count")
            node_count = result.single()["node_count"]
            
        if node_count == 0:
            # First, clear existing data
            logger.info("No data found in Neo4j, loading mappings...")
            with driver.session() as session:
                session.run("MATCH (n) DETACH DELETE n")

                # Load and execute Cypher statements
                cypher_file = os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(__file__))), 
                                        'neo4j_knowledge_graph_cypher.txt')
                logger.info(f"Loading Cypher statements from {cypher_file}")
                
                statements = load_cypher_file(cypher_file)
                logger.info(f"Found {len(statements)} Cypher statements to execute")
                
                for i, statement in enumerate(statements, 1):
                    try:
                        logger.debug(f"Executing statement {i}/{len(statements)}")
                        session.run(statement)
                    except Exception as e:
                        logger.error(f"Error executing statement {i}: {str(e)}")
                        logger.error(f"Failed statement: {statement}")
                        raise

        # Query specific field details
        with driver.session() as session:
            field_info = get_field_details(session, "Curriculum", "Vendor/Provider*")
            if field_info:
                logger.info("\nField Details:")
                if field_info["field"]:
                    logger.info(f"Field properties: {dict(field_info['field'])}")
                if field_info["target_field"]:
                    logger.info(f"Maps to: {dict(field_info['target_field'])}")
                if field_info["transform"]:
                    logger.info(f"Transformation: {dict(field_info['transform'])}")
            else:
                logger.info("Field not found in Neo4j database")

    finally:
        driver.close()

if __name__ == "__main__":
    main()
