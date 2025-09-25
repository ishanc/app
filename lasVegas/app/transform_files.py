import os
import sys
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from dotenv import load_dotenv
from csod_transformer import CSodTransformer

def main():
    # Set up logging with more detail
    import logging
    logging.basicConfig(
        level=logging.INFO,
        format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
    )
    logger = logging.getLogger(__name__)
    
    # Load environment variables
    load_dotenv()
    logger.info("Environment variables loaded")
    
    # Get and validate Neo4j credentials
    neo4j_uri = os.getenv('NEO4J_URI')
    neo4j_user = os.getenv('NEO4J_USER')
    neo4j_password = os.getenv('NEO4J_PASSWORD')
    
    logger.info(f"Using Neo4j URI: {neo4j_uri}")
    logger.info(f"Using Neo4j user: {neo4j_user}")
    
    if not neo4j_password:
        raise ValueError("NEO4J_PASSWORD environment variable is required")
    
    # Initialize transformer
    transformer = CSodTransformer(neo4j_uri, neo4j_user, neo4j_password)
    
    try:
        # Set up source and destination directories
        source_dir = os.path.join(os.path.dirname(os.path.dirname(__file__)), 'source')
        transformed_dir = os.path.join(os.path.dirname(os.path.dirname(__file__)), 'transformed')
        
        logger.info(f"Source directory: {source_dir}")
        logger.info(f"Transformed directory: {transformed_dir}")
        
        # Check if source directory exists and has files
        if not os.path.exists(source_dir):
            raise ValueError(f"Source directory does not exist: {source_dir}")
        
        # List all files in source directory
        for root, dirs, files in os.walk(source_dir):
            logger.info(f"Scanning directory: {root}")
            logger.info(f"Found files: {files}")
        
        # Transform all files
        transformer.transform_directory(source_dir, transformed_dir)
        
    finally:
        # Clean up
        transformer.close()

if __name__ == "__main__":
    main()
