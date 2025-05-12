import os
import pandas as pd
import logging
from neo4j import GraphDatabase
from dotenv import load_dotenv
from datetime import datetime
from typing import List, Dict

# Configure logging
log_directory = "logs"
os.makedirs(log_directory, exist_ok=True)
log_file = os.path.join(log_directory, f"transformation_{datetime.now().strftime('%Y%m%d_%H%M%S')}.log")

# Set up logging configuration
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler(log_file),
        logging.StreamHandler()  # This will show logs in terminal too
    ]
)
logger = logging.getLogger(__name__)

# Define the main folder processing sequence
FOLDER_SEQUENCE = [
    "Core",
    "Prerequisites",
    "Activity",
    "Transcript"
]

load_dotenv()
logger.info("Environment variables loaded")

# Load Neo4j credentials from .env
NEO4J_URI = os.getenv("NEO4J_URI")
NEO4J_USER = os.getenv("NEO4J_USER")
NEO4J_PASSWORD = os.getenv("NEO4J_PASSWORD")

# Set absolute paths for source and output folders
SOURCE_FOLDER = os.path.join(os.path.dirname(os.path.dirname(__file__)), "source")
OUTPUT_FOLDER = os.path.join(os.path.dirname(os.path.dirname(__file__)), "transformed")

logger.info(f"Source folder: {SOURCE_FOLDER}")
logger.info(f"Output folder: {OUTPUT_FOLDER}")

# Initialize the Neo4j driver
try:
    driver = GraphDatabase.driver(NEO4J_URI, auth=(NEO4J_USER, NEO4J_PASSWORD))
    logger.info("Successfully connected to Neo4j database")
except Exception as e:
    logger.error(f"Failed to connect to Neo4j: {str(e)}")
    raise

def cleanup():
    """Cleanup function to close the Neo4j driver connection"""
    if driver:
        driver.close()
        logger.info("Neo4j connection closed")

def transform_sumtotal_file(input_df: pd.DataFrame, file_key: str, mapping_rules: dict) -> pd.DataFrame:
    logger.info(f"Starting transformation for file key: {file_key}")
    logger.info(f"Input DataFrame shape: {input_df.shape}")
    
    # Special handling for transcript files
    if os.path.basename(os.path.dirname(file_key)).lower() == "transcript":
        transformed_data = input_df.copy()
        logger.info(f"Transcript file detected, keeping original columns")
        return transformed_data
        
    if file_key not in mapping_rules:
        logger.error(f"No mapping rules found for file '{file_key}'")
        raise ValueError(f"No mapping rules defined for file '{file_key}'")

    rules = mapping_rules[file_key]
    output_columns = [r["CSOD Field Name"] for r in rules]
    logger.info(f"Output columns to be created: {output_columns}")

    # Create mapping of CSOD fields to SumTotal fields
    mapped_fields = {
        r["CSOD Field Name"]: r["SumTotal Field Name"]
        for r in rules
    }
    logger.info(f"Field mapping configuration: {mapped_fields}")

    transformed_data = {}
    for csod_field in output_columns:
        sumtotal_field = mapped_fields.get(csod_field, "")
        
        # Special handling for Audience Code/AudiencePK field
        if sumtotal_field == "Audience Code/AudiencePK":
            # Try both possible column names
            if "Audience Code" in input_df.columns:
                transformed_data[csod_field] = input_df["Audience Code"]
                logger.debug(f"Mapped 'Audience Code' to {csod_field}")
            elif "AudiencePK" in input_df.columns:
                transformed_data[csod_field] = input_df["AudiencePK"]
                logger.debug(f"Mapped 'AudiencePK' to {csod_field}")
            else:
                # Default handling if neither column exists
                rule = next(r for r in rules if r["CSOD Field Name"] == csod_field)
                default_value = rule.get("Default value", "")
                transformed_data[csod_field] = pd.Series([default_value] * len(input_df))
                logger.debug(f"Neither 'Audience Code' nor 'AudiencePK' found, using default value for {csod_field}: {default_value}")
        # Regular field mapping
        elif sumtotal_field and sumtotal_field in input_df.columns:
            transformed_data[csod_field] = input_df[sumtotal_field]
            logger.debug(f"Mapped {sumtotal_field} to {csod_field}")
        else:
            # Special handling for OU ID field with no mapping
            if csod_field == "OU ID*" and not sumtotal_field:
                transformed_data[csod_field] = pd.Series(range(1, len(input_df) + 1)).astype(str)
                logger.debug("Generated sequential OU IDs")
            else:
                rule = next(r for r in rules if r["CSOD Field Name"] == csod_field)
                default_value = rule.get("Default value", "")
                transformed_data[csod_field] = pd.Series([default_value] * len(input_df))
                logger.debug(f"Used default value for {csod_field}: {default_value}")

    result_df = pd.DataFrame(transformed_data)
    logger.info(f"Transformation complete. Output DataFrame shape: {result_df.shape}")
    return result_df

def process_directory(directory_path: str, output_dir: str, mapping_rules: dict) -> tuple:
    """Process all Excel files in a directory and its subdirectories"""
    processed = 0
    failed = 0
    total = 0
    
    for root, _, files in os.walk(directory_path):
        excel_files = [f for f in files if f.lower().endswith(('.xlsx', '.xls'))]
        if not excel_files:
            continue
            
        total += len(excel_files)
        logger.info(f"Found {len(excel_files)} Excel files in {os.path.relpath(root, directory_path)}")
        
        # Create corresponding output directory structure
        rel_path = os.path.relpath(root, directory_path)
        current_output_dir = os.path.join(output_dir, rel_path)
        os.makedirs(current_output_dir, exist_ok=True)
        
        for file in excel_files:
            file_path = os.path.join(root, file)
            file_key = os.path.splitext(file)[0]
            
            logger.info(f"\nProcessing file: {file}")
            try:
                input_df = pd.read_excel(file_path)
                logger.info(f"File shape: {input_df.shape}")
                logger.info("Columns:")
                for col in input_df.columns:
                    # Show a sample of non-null values for each column
                    sample = input_df[col].dropna().iloc[:3].tolist() if not input_df[col].empty else []
                    logger.info(f"  - {col}")
                    logger.info(f"    Sample values: {sample[:3]}")
                
                # Create empty mapping rules if none exist
                if file_key not in mapping_rules:
                    mapping_rules[file_key] = [
                        {"CSOD Field Name": col, "SumTotal Field Name": col}
                        for col in input_df.columns
                    ]
                    logger.info(f"Created default 1:1 mapping for {file_key}")
                
                transformed_df = transform_sumtotal_file(input_df, file_key, mapping_rules)
                
                output_file_path = os.path.join(current_output_dir, f"{file_key}-CSOD.csv")
                transformed_df.to_csv(output_file_path, index=False)
                logger.info(f"Successfully transformed and saved: {output_file_path}")
                processed += 1
                
            except Exception as e:
                logger.error(f"Failed to process {file_path}: {str(e)}", exc_info=True)
                failed += 1
                
    return total, processed, failed

def process_folder_sequence(source_folder: str, output_folder: str, mapping_rules: dict):
    """Process main folders in the specified sequence"""
    logger.info("Starting main folder sequential processing")
    logger.info(f"Source folder: {source_folder}")
    logger.info(f"Output folder: {output_folder}")

    total_files = 0
    total_processed = 0
    total_failed = 0
    
    # Process each main folder in sequence
    for folder in FOLDER_SEQUENCE:
        current_folder = os.path.join(source_folder, folder)
        logger.info(f"\n=== Processing main folder: {folder} ===")
        
        if not os.path.exists(current_folder):
            logger.warning(f"Main folder not found: {current_folder}")
            continue
            
        # Create corresponding output folder
        current_output_folder = os.path.join(output_folder, folder)
        os.makedirs(current_output_folder, exist_ok=True)
        
        # Process the current directory and all its subdirectories
        folder_total, folder_processed, folder_failed = process_directory(
            current_folder, 
            current_output_folder, 
            mapping_rules
        )
        
        total_files += folder_total
        total_processed += folder_processed
        total_failed += folder_failed
        
        logger.info(f"=== Completed {folder} ===")
        logger.info(f"Files found: {folder_total}")
        logger.info(f"Successfully processed: {folder_processed}")
        logger.info(f"Failed to process: {folder_failed}")

    logger.info("\n=== Final Processing Summary ===")
    logger.info(f"Total files found: {total_files}")
    logger.info(f"Successfully processed: {total_processed}")
    logger.info(f"Failed to process: {total_failed}")
    logger.info("=============================")

def load_mapping_rules_from_neo4j_file(filepath: str) -> Dict[str, List[Dict]]:
    """Load and parse mapping rules from the Neo4j cypher file"""
    mapping_rules = {}
    current_file = None
    
    with open(filepath, 'r') as f:
        for line in f:
            # Skip comments and empty lines
            if line.strip().startswith('//') or not line.strip():
                continue
                
            # Parse MERGE statements
            if line.strip().startswith('MERGE (f:File {name:'):
                # Extract file name
                file_name = line.split('"')[1]
                if file_name:  # Only set if file name is not empty
                    current_file = file_name
                    if current_file not in mapping_rules:
                        mapping_rules[current_file] = []
                        
            elif line.strip().startswith('MERGE (st:SumTotalField {name:'):
                if current_file:
                    # Extract SumTotal field name
                    st_field = line.split('"')[1]
                    
                    # Look for corresponding CSOD field in next lines
                    next_lines = []
                    while 'MERGE (csod:CSODField' not in next_lines and len(next_lines) < 5:
                        next_line = next(f, '').strip()
                        next_lines.append(next_line)
                        
                    for nl in next_lines:
                        if 'MERGE (csod:CSODField {name:' in nl:
                            csod_field = nl.split('"')[1]
                            # Add mapping rule
                            mapping_rules[current_file].append({
                                "CSOD Field Name": csod_field,
                                "SumTotal Field Name": st_field,
                                "Default value": ""
                            })
                            break
                            
    return mapping_rules

if __name__ == "__main__":
    try:
        logger.info("Starting transformation process")
        
        # Ensure output directory exists
        os.makedirs(OUTPUT_FOLDER, exist_ok=True)
        
        # Load mapping rules from Neo4j file
        mapping_file = os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(__file__))), "neo4j_knowledge_graph_cypher.txt")
        mapping_rules = load_mapping_rules_from_neo4j_file(mapping_file)
        logger.info(f"Loaded {len(mapping_rules)} file mappings from Neo4j rules")
        
        # Process folders in sequence
        process_folder_sequence(SOURCE_FOLDER, OUTPUT_FOLDER, mapping_rules)
        logger.info("Transformation process completed successfully")
        
    except Exception as e:
        logger.error("Fatal error occurred", exc_info=True)
        raise
    finally:
        cleanup()
