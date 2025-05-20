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

def parse_case_statement(transformation_rule: str) -> dict:
    """Parse a CASE statement transformation rule into a dictionary of mappings"""
    if not transformation_rule or not isinstance(transformation_rule, str):
        return {}
        
    # Remove CASE and END keywords and split into conditions
    rule = transformation_rule.strip()
    if rule.upper().startswith('CASE'):
        rule = rule[4:]
    if rule.upper().endswith('END'):
        rule = rule[:-3]
        
    mappings = {}
    else_value = None
    
    # Parse WHEN/THEN pairs and ELSE clause
    parts = rule.strip().split('WHEN')
    for part in parts[1:]:  # Skip first empty part
        if 'THEN' in part:
            condition, value = part.split('THEN', 1)
            condition = condition.strip().strip("'").strip('"')
            value = value.split('ELSE', 1)[0].strip().strip("'").strip('"')
            mappings[condition] = value
        
    # Check for ELSE clause
    if 'ELSE' in rule:
        else_value = rule.split('ELSE', 1)[1].split('END')[0].strip().strip("'").strip('"')
        
    return {'mappings': mappings, 'default': else_value}

def apply_transformation_rule(value: str, transformation: dict) -> str:
    """Apply a parsed transformation rule to a value"""
    if not transformation:
        return value
        
    mappings = transformation.get('mappings', {})
    default = transformation.get('default')
    
    # Try exact match first
    if value in mappings:
        return mappings[value]
    
    # For Topic/Subject mappings, try pattern matching
    for pattern, result in mappings.items():
        if pattern.strip() in value or value.strip() in pattern:
            return result
            
    return default if default is not None else value

def transform_sumtotal_file(input_df, mapping_rules, file_type):
    """Transform a SumTotal file according to mapping rules and file type"""
    output_df = pd.DataFrame(index=range(len(input_df) if not input_df.empty else 1))
    logger.info(f"Processing file type: {file_type}")
    
    # Process all fields based on mapping rules
    for rule in mapping_rules:
        csod_field = rule['CSOD Field Name']
        st_field = rule.get('SumTotal Field Name', '')
        default_value = rule.get('Default value', '')
        transformation = rule.get('transformation', '')
        field_type = rule.get('field_type', '')
        char_length = rule.get('char_length', '')
        mandatory = rule.get('mandatory', '') == 'Mandatory'
        
        logger.debug(f"\nProcessing field: {csod_field}")
        logger.debug(f"- SumTotal field: {st_field}")
        logger.debug(f"- Default value: {default_value}")
        logger.debug(f"- Has transformation: {'Yes' if transformation else 'No'}")
        logger.debug(f"- Field type: {field_type}")
        logger.debug(f"- Character length: {char_length}")
        logger.debug(f"- Mandatory: {mandatory}")

        # Initialize field with empty string
        output_df[csod_field] = ''
        
        # Apply source values if SumTotal mapping exists
        if st_field and st_field in input_df.columns:
            values = input_df[st_field].fillna('')
            output_df[csod_field] = values
            
            # Apply transformation if it exists
            if transformation:
                parsed_transform = parse_case_statement(transformation)
                non_empty_mask = values.astype(str).str.strip() != ''
                if non_empty_mask.any():
                    output_df.loc[non_empty_mask, csod_field] = values[non_empty_mask].apply(
                        lambda x: apply_transformation_rule(x, parsed_transform)
                    )

        # Always apply default value to empty cells if one exists or if field is mandatory
        if default_value or mandatory:
            empty_mask = (output_df[csod_field].isna()) | (output_df[csod_field].astype(str).str.strip() == '')
            if empty_mask.any():
                # For mandatory fields without a default, use a sensible default based on field type
                if mandatory and not default_value:
                    if csod_field == "Transcript Status*":
                        default_value = "Not Started"
                        logger.info(f"Using default value '{default_value}' for mandatory field {csod_field}")
                    else:
                        logger.warning(f"Mandatory field {csod_field} has no default value")

                if default_value:
                    output_df.loc[empty_mask, csod_field] = default_value
                    logger.debug(f"- Applied default value '{default_value}' to {empty_mask.sum()} empty cells")

        # Special handling for Provider type mapping
        if csod_field == 'Provider type*':
            provider_values = input_df['Provider'].fillna('') if 'Provider' in input_df.columns else pd.Series([''] * len(output_df))
            output_df[csod_field] = provider_values.apply(lambda x: 'ILT' if 'ILT' in str(x) else 'ONLINE')

        # Truncate fields that have a character length limit
        if char_length and char_length.isdigit():
            max_length = int(char_length)
            too_long_mask = output_df[csod_field].astype(str).str.len() > max_length
            if too_long_mask.any():
                output_df.loc[too_long_mask, csod_field] = output_df.loc[too_long_mask, csod_field].str.slice(0, max_length)
                logger.info(f"Truncated {too_long_mask.sum()} values in {csod_field} to {max_length} characters")

    return output_df

def process_directory(directory_path: str, output_dir: str, mapping_rules: dict) -> tuple:
    """Process all Excel files in a directory and its subdirectories"""
    processed = 0
    failed = 0
    total = 0
    
    for root, _, files in os.walk(directory_path):
        input_files = [f for f in files if f.lower().endswith(('.xlsx', '.xls', '.csv'))]
        if not input_files:
            continue
            
        total += len(input_files)
        logger.info(f"Found {len(input_files)} input files in {os.path.relpath(root, directory_path)}")
        
        # Create corresponding output directory structure
        rel_path = os.path.relpath(root, directory_path)
        current_output_dir = os.path.join(output_dir, rel_path)
        os.makedirs(current_output_dir, exist_ok=True)
        
        for file in input_files:
            file_path = os.path.join(root, file)
            file_key = os.path.splitext(file)[0]
            
            logger.info(f"\nProcessing file: {file}")
            try:
                # Read Excel with empty strings instead of NaN
                input_df = pd.read_excel(file_path, keep_default_na=False, na_values=[''])
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
                
                # Pass the file_key as file_type
                transformed_df = transform_sumtotal_file(input_df, mapping_rules[file_key], file_key)
                
                # Ensure empty strings instead of NaN in output
                transformed_df = transformed_df.fillna("")
                
                # Write CSV without index and with empty strings for missing values
                output_file_path = os.path.join(current_output_dir, f"{file_key}-CSOD.csv")
                transformed_df.to_csv(output_file_path, index=False, na_rep="")
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
    current_st_field = None
    current_csod_field = None
    current_properties = {}  # Store all properties for current field
    logger.setLevel(logging.DEBUG)  # Temporarily set to DEBUG for more verbose logging

    # First pass - collect all fields and their properties
    with open(filepath, 'r') as f:
        for line in f:
            line = line.strip()
            if line.startswith('//') or not line:
                continue
                
            if line.startswith('MERGE (f:File {name:'):
                current_file = line.split('"')[1]
                if current_file and current_file not in mapping_rules:
                    mapping_rules[current_file] = []
                    logger.debug(f"\n=== Processing file: {current_file} ===")
                    
            elif line.startswith('MERGE (csod:CSODField {name:'):
                if current_file:
                    current_csod_field = line.split('"')[1]
                    current_properties = {
                        "CSOD Field Name": current_csod_field,
                        "SumTotal Field Name": "",
                        "Default value": "",
                        "transformation": ""
                    }
                    logger.debug(f"Found CSOD field: {current_csod_field}")
                    
            elif line.startswith('SET csod.'):
                if current_file and current_csod_field:
                    try:
                        # Remove 'SET csod.' prefix and parse property
                        prop_line = line[9:].strip()
                        prop_name, prop_value = prop_line.split('=', 1)
                        prop_name = prop_name.strip()
                        prop_value = prop_value.strip().strip('"').strip("'").rstrip(',')
                        
                        # Store default_value and other properties
                        if prop_name == 'default_value':
                            current_properties["Default value"] = prop_value
                            logger.debug(f"  Setting default value: {prop_value}")
                        elif prop_name == 'transformation':
                            current_properties["transformation"] = prop_value
                        # Store all properties in case we need them
                        current_properties[prop_name] = prop_value
                        logger.debug(f"  Property {prop_name} = {prop_value}")
                        
                    except ValueError as e:
                        logger.warning(f"Failed to parse property line: {line}")
                        logger.warning(str(e))
                    
            elif line.startswith('MERGE (f)-[:OUTPUTS_FIELD]->(csod)'):
                if current_file and current_csod_field and current_properties:
                    mapping_rules[current_file].append(current_properties.copy())
                    logger.debug(f"Added field config for {current_csod_field} to {current_file}:")
                    logger.debug(f"  {current_properties}")
                    current_csod_field = None
                    current_properties = {}

    # Second pass - update SumTotal field mappings
    current_file = None
    current_st_field = None
    current_csod_field = None
    
    with open(filepath, 'r') as f:
        for line in f:
            line = line.strip()
            if line.startswith('//') or not line:
                continue
                
            if line.startswith('MERGE (f:File {name:'):
                current_file = line.split('"')[1]
                logger.debug(f"\n=== Processing SumTotal mappings for file: {current_file} ===")
                    
            elif line.startswith('MERGE (st:SumTotalField {name:'):
                if current_file:
                    current_st_field = line.split('"')[1]
                    logger.debug(f"Found SumTotal field: {current_st_field}")
                    
            elif line.startswith('MERGE (csod:CSODField {name:'):
                if current_file:
                    current_csod_field = line.split('"')[1]
                    logger.debug(f"Processing MAPS_TO for CSOD field: {current_csod_field}")
                    
            elif line.startswith('MERGE (st)-[:MAPS_TO]->(csod)'):
                if current_file and current_st_field and current_csod_field:
                    for rule in mapping_rules[current_file]:
                        if rule["CSOD Field Name"] == current_csod_field:
                            rule["SumTotal Field Name"] = current_st_field
                            logger.debug(f"  Mapped {current_st_field} to {current_csod_field}")
                            break
                    current_st_field = None
                    current_csod_field = None

    logger.debug("\n=== Final mapping rules ===")
    for file_name, rules in mapping_rules.items():
        logger.debug(f"\nFile: {file_name}")
        for rule in rules:
            logger.debug(f"  {rule}")
            
    logger.setLevel(logging.INFO)  # Reset to INFO level
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
