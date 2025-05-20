"""
This module handles the transformation of SumTotal files to CSOD format using Neo4j mappings.
It supports reading Excel files, applying field transformations, and handling type conversions.
"""

import os
import pandas as pd
import logging
from neo4j import GraphDatabase
from dotenv import load_dotenv
from datetime import datetime
from typing import List, Dict, Tuple, Optional, Any, Set, Union

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

# Load environment variables
load_dotenv()

# Load Neo4j credentials from .env
NEO4J_URI = os.getenv("NEO4J_URI")
NEO4J_USER = os.getenv("NEO4J_USER")
NEO4J_PASSWORD = os.getenv("NEO4J_PASSWORD")

logger.info("Environment variables loaded")

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

def parse_case_statement(transformation_rule: str) -> Dict[str, Union[Dict[str, str], Optional[str]]]:
    """Parse a CASE statement transformation rule into a dictionary of mappings.
    
    Args:
        transformation_rule: A string containing a SQL-style CASE statement 
        
    Returns:
        Dictionary with 'mappings' key containing case mappings and 'default' key with else value
    """
    try:
        if not transformation_rule or not isinstance(transformation_rule, str):
            return {'mappings': {}, 'default': None}
            
        # Remove CASE and END keywords and split into conditions
        rule = transformation_rule.strip()
        if rule.upper().startswith('CASE'):
            rule = rule[4:]
        if rule.upper().endswith('END'):
            rule = rule[:-3]
            
        mappings: Dict[str, str] = {}
        else_value: Optional[str] = None
        
        # Parse WHEN/THEN pairs and ELSE clause
        parts = rule.strip().split('WHEN')
        for part in parts[1:]:  # Skip first empty part
            if 'THEN' in part:
                try:
                    condition, value = part.split('THEN', 1)
                    condition = condition.strip().strip("'").strip('"')
                    value = value.split('ELSE', 1)[0].strip().strip("'").strip('"')
                    mappings[condition] = value
                except Exception as e:
                    logger.warning(f"Error parsing WHEN/THEN clause: {e}")
            
        # Check for ELSE clause
        if 'ELSE' in rule:
            try:
                else_value = rule.split('ELSE', 1)[1].split('END')[0].strip().strip("'").strip('"')
            except Exception as e:
                logger.warning(f"Error parsing ELSE clause: {e}")
        
        return {'mappings': mappings, 'default': else_value}
        
    except Exception as e:
        logger.error(f"Failed to parse transformation rule: {e}")
        return {'mappings': {}, 'default': None}

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

def transform_sumtotal_file(input_df: pd.DataFrame, file_rules: List[Dict], file_type: str) -> pd.DataFrame:
    """Transform a SumTotal file according to mapping rules and file type."""
    output_df = pd.DataFrame(index=range(len(input_df) if not input_df.empty else 1))
    logger.info(f"Processing file type: {file_type}")
    
    if not file_rules:
        logger.warning(f"No mapping rules found for file type: {file_type}")
        return output_df
        
    logger.info(f"\nProcessing {file_type} with {len(file_rules)} mapping rules from Neo4j:")
    for rule in file_rules:
        try:
            logger.info(f"  - CSOD Field: {rule.get('CSOD Field Name', 'Unknown')}")
            logger.info(f"    SumTotal Field: {rule.get('SumTotal Field Name', '')}")
            logger.info(f"    Field Type: {rule.get('field_type', 'String')}")  # Default to String type
            logger.info(f"    Mandatory: {rule.get('mandatory', False)}")
            if rule.get('transformation'):
                logger.info(f"    Has Transformation Rule: Yes")
                logger.debug(f"    Transformation: {rule['transformation']}")
            if rule.get('Default value'):
                logger.info(f"    Default Value: {rule['Default value']}")
        except Exception as e:
            logger.warning(f"Error logging rule details: {e}. Rule data: {rule}")

    # Process each field according to mapping rules
    for rule in file_rules:
        try:
            # Extract field properties with defaults
            csod_field = rule.get('CSOD Field Name')
            if not csod_field:
                logger.warning(f"Skipping rule with missing CSOD Field Name: {rule}")
                continue
                
            st_field = rule.get('SumTotal Field Name', '')
            default_value = rule.get('Default value', '')
            transformation = rule.get('transformation', '')
            field_type = rule.get('field_type', 'String')  # Default to String type
            char_length = rule.get('char_length', '')
            mandatory = rule.get('mandatory', False)

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
                    if parsed_transform:
                        non_empty_mask = values.astype(str).str.strip() != ''
                        if non_empty_mask.any():
                            try:
                                output_df.loc[non_empty_mask, csod_field] = values[non_empty_mask].apply(
                                    lambda x: apply_transformation_rule(x, parsed_transform)
                                )
                                logger.debug(f"Applied transformation to {non_empty_mask.sum()} values")
                            except Exception as e:
                                logger.error(f"Error applying transformation for {csod_field}: {e}")

            # Handle field type specific conversions
            if field_type:
                try:
                    if field_type.upper() in ('BOOLEAN', 'BOOL'):
                        output_df[csod_field] = output_df[csod_field].apply(
                            lambda x: convert_to_boolean(x, rule.get('accepted_values', ''))
                        )
                    elif field_type.upper() in ('INTEGER', 'INT'):
                        output_df[csod_field] = pd.to_numeric(
                            output_df[csod_field], 
                            errors='coerce'
                        ).fillna(0).astype(int)
                    elif field_type.upper().startswith('TIME'):
                        output_df[csod_field] = output_df[csod_field].apply(format_time_value)
                    elif field_type.upper() in ('DATETIME', 'DATE'):
                        # Handle both empty strings and invalid dates
                        output_df[csod_field] = pd.to_datetime(
                            output_df[csod_field], 
                            errors='coerce'
                        ).fillna(pd.NaT)
                        # Only format dates that are not NaT
                        mask = ~output_df[csod_field].isna()
                        if mask.any():
                            output_df.loc[mask, csod_field] = output_df.loc[mask, csod_field].dt.strftime('%Y-%m-%d %H:%M:%S')
                        output_df.loc[~mask, csod_field] = ''  # Set empty string for NaT values
                    else:
                        # For all other types, ensure string conversion
                        output_df[csod_field] = output_df[csod_field].astype(str)
                        
                except Exception as e:
                    logger.error(f"Error converting field type for {csod_field}: {e}. Using string type as fallback.")
                    # Fall back to string type on error
                    output_df[csod_field] = output_df[csod_field].astype(str)

            # Apply defaults and handle missing values
            empty_mask = (output_df[csod_field].isna()) | (output_df[csod_field].astype(str).str.strip() == '')
            if empty_mask.any():
                # For mandatory fields without a default, use a sensible default based on field type
                if mandatory and not default_value:
                    if csod_field == "Transcript Status*":
                        default_value = "Not Started"
                        logger.info(f"Using default value '{default_value}' for mandatory field {csod_field}")
                    elif field_type.upper() in ('BOOLEAN', 'BOOL'):
                        default_value = "0"
                    elif field_type.upper() in ('INTEGER', 'INT'):
                        default_value = "0"
                    elif field_type.upper() in ('DATETIME', 'DATE'):
                        # Skip default for date/time fields
                        pass
                    else:
                        logger.warning(f"Mandatory field {csod_field} has no default value")

                if default_value:
                    output_df.loc[empty_mask, csod_field] = default_value
                    logger.debug(f"- Applied default value '{default_value}' to {empty_mask.sum()} empty cells")

            # Truncate char fields to specified length if needed
            if char_length and str(char_length).isdigit():
                max_length = int(char_length)
                output_df[csod_field] = output_df[csod_field].astype(str).str.slice(0, max_length)
                logger.debug(f"- Truncated values to max length: {max_length}")

        except Exception as e:
            logger.error(f"Error processing field {csod_field}: {e}")
            continue

    return output_df

def convert_to_boolean(value: Any, accepted_values: str = "1, 0, y, n, yes, no, t, f, true, false, on, off, active, inactive") -> str:
    """Convert various inputs to boolean values based on accepted values.
    
    Args:
        value: The value to convert to boolean
        accepted_values: Comma-separated string of accepted boolean values
        
    Returns:
        '1' for true values, '0' for false or invalid values
    """
    try:
        if pd.isna(value) or value == '':
            return '0'
            
        str_value = str(value).lower().strip()
        true_values = {v.lower().strip() for v in accepted_values.split(',') 
                    if v.lower().strip() in {'1', 'y', 'yes', 't', 'true', 'on', 'active'}}
        
        return '1' if str_value in true_values else '0'
        
    except Exception as e:
        logger.warning(f"Error converting {value} to boolean: {e}")
        return '0'  # Return false for any errors

def format_time_value(value: Any) -> str:
    """Format time values in the required format (HHHHHH:MM:SS).
    
    Args:
        value: A time value as string, int (minutes), float (minutes), or pandas NaT
        
    Returns:
        Time string in format HHHHHH:MM:SS, or 000000:00:00 if invalid/empty
    """
    if pd.isna(value) or value == '':
        return '000000:00:00'
        
    try:
        # Try to parse input as timedelta or time string
        if isinstance(value, (int, float)):
            # Assume minutes if numeric
            total_minutes = int(value)
            hours = total_minutes // 60
            minutes = total_minutes % 60
            return f"{hours:06d}:00:{minutes:02d}"
        else:
            # Try to parse as time string
            time_parts = str(value).strip().split(':')
            if len(time_parts) >= 2:
                hours = int(time_parts[0])
                minutes = int(time_parts[1])
                seconds = int(time_parts[2]) if len(time_parts) > 2 else 0
                
                # Validate ranges
                if not (0 <= minutes < 60 and 0 <= seconds < 60):
                    raise ValueError(f"Invalid minutes/seconds: {minutes}:{seconds}")
                    
                return f"{hours:06d}:{minutes:02d}:{seconds:02d}"
            else:
                raise ValueError(f"Invalid time format: {value}")
                
    except Exception as e:
        logger.warning(f"Could not parse time value '{value}': {e}")
        return '000000:00:00'  # Return default format if parsing fails

def process_directory(directory_path: str, output_dir: str, mapping_rules: Dict[str, List[Dict]]) -> Tuple[int, int, int]:
    """Process all Excel files in a directory and its subdirectories."""
    processed = 0
    failed = 0
    total = 0
    
    # Process all Excel files in directory recursively
    for root, _, files in os.walk(directory_path):
        # Filter for Excel files
        excel_files = [f for f in files if f.lower().endswith(('.xlsx', '.xls'))]
        if not excel_files:
            continue
        
        # Update total and log
        total += len(excel_files)
        logger.info(f"Found {len(excel_files)} Excel files in {os.path.relpath(root, directory_path)}")
        
        # Create output directory
        rel_path = os.path.relpath(root, directory_path)
        current_output_dir = os.path.join(output_dir, rel_path)
        os.makedirs(current_output_dir, exist_ok=True)
        
        # Process each file
        for file in excel_files:
            file_path = os.path.join(root, file)
            # Get file key without normalization
            file_key = os.path.splitext(file)[0]
            logger.info(f"\nProcessing file: {file}")
            
            try:
                # Read Excel file
                input_df = pd.read_excel(file_path, keep_default_na=False, na_values=[''])
                logger.info(f"File shape: {input_df.shape}")
                logger.info(f"Columns: {list(input_df.columns)}")
                
                # Get mapping rules exactly as is
                file_rules = mapping_rules.get(file_key, [])
                if file_rules:
                    logger.info(f"Found {len(file_rules)} field mappings for {file_key}:")
                    for rule in file_rules:
                        logger.info(f"  - CSOD Field: {rule['CSOD Field Name']}")
                        logger.info(f"    SumTotal Field: {rule['SumTotal Field Name']}")
                        logger.info(f"    Has Transformation Rule: {'Yes' if rule['transformation'] else 'No'}")
                        logger.info(f"    Default Value: {rule['Default value'] if rule['Default value'] else 'None'}")
                else:
                    logger.warning(f"No mapping rules found for {file_key}")
                
                # Transform and save
                output_df = transform_sumtotal_file(input_df, file_rules, file_key)
                output_path = os.path.join(current_output_dir, f"{file_key}-CSOD.csv")
                output_df.to_csv(output_path, index=False)
                
                processed += 1
                logger.info(f"Successfully transformed and saved to: {output_path}")
                
            except Exception as e:
                logger.error(f"Failed to process {file}: {str(e)}", exc_info=True)
                failed += 1
                    
    return total, processed, failed

def process_folder_sequence(source_folder: str, output_folder: str, mapping_rules: dict) -> None:
    """Process main folders in the specified sequence.
    
    Args:
        source_folder: Root path containing source folders to process
        output_folder: Root path for transformed output files
        mapping_rules: Dictionary of mapping rules from Neo4j database
    """    
    try:
        total_files = 0
        total_processed = 0
        total_failed = 0
        
        logger.info("Starting main folder sequential processing")
        logger.info(f"Source folder: {source_folder}")
        logger.info(f"Output folder: {output_folder}")
        
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
        
    except Exception as e:
        logger.error(f"Error in folder sequence processing: {str(e)}", exc_info=True)
        raise

def fetch_mapping_rules_from_neo4j(driver) -> Dict[str, List[Dict]]:
    """Fetch mapping rules directly from Neo4j database"""
    mapping_rules = {}
    
    try:
        with driver.session() as session:
            # First get all files
            files_query = """
            MATCH (f:File)
            WHERE f.name IS NOT NULL AND f.name <> ''
            RETURN f.name as file_name
            """
            files_result = session.run(files_query)
            
            for record in files_result:
                file_name = record["file_name"]
                mapping_rules[file_name] = []
                
                # For each file, get its field mappings
                field_query = """
                MATCH (f:File {name: $file_name})-[:OUTPUTS_FIELD]->(csod:CSODField)
                OPTIONAL MATCH (st:SumTotalField)-[:MAPS_TO]->(csod)
                WHERE f.name = $file_name 
                RETURN 
                    csod.name as csod_field,
                    st.name as st_field,
                    coalesce(csod.default_value, '') as default_value,
                    coalesce(csod.transformation, '') as transformation,
                    coalesce(csod.field_type, 'String') as field_type,
                    coalesce(csod.char_length, '') as char_length,
                    coalesce(csod.mandatory, 'Optional') as mandatory,
                    coalesce(csod.accepted_values, '') as accepted_values
                """
                
                field_result = session.run(field_query, file_name=file_name)
                
                for field in field_result:
                    field_mapping = {
                        "CSOD Field Name": field["csod_field"],
                        "SumTotal Field Name": field["st_field"] or "",
                        "Default value": field["default_value"] or "",
                        "transformation": field["transformation"] or "",
                        "field_type": field["field_type"] or "String",  # Default to String type
                        "char_length": str(field["char_length"]) if field["char_length"] else "",
                        "mandatory": field["mandatory"] == "Mandatory",
                        "accepted_values": field["accepted_values"].split(", ") if field["accepted_values"] else []
                    }   
                    mapping_rules[file_name].append(field_mapping)
                
                logger.debug(f"Loaded {len(mapping_rules[file_name])} mappings for file {file_name}")
        
        logger.info(f"Successfully loaded mapping rules for {len(mapping_rules)} files from Neo4j")
        return mapping_rules
        
    except Exception as e:
        logger.error(f"Failed to fetch mapping rules from Neo4j: {str(e)}", exc_info=True)
        raise

if __name__ == "__main__":
    try:
        logger.info("Starting transformation process")
        
        # Ensure output directory exists
        os.makedirs(OUTPUT_FOLDER, exist_ok=True)
        
        # Load mapping rules directly from Neo4j database
        mapping_rules = fetch_mapping_rules_from_neo4j(driver)
        logger.info(f"Loaded {len(mapping_rules)} file mappings from Neo4j database")
        
        # Process folders in sequence
        process_folder_sequence(SOURCE_FOLDER, OUTPUT_FOLDER, mapping_rules)
        logger.info("Transformation process completed successfully")
        
    except Exception as e:
        logger.error("Fatal error occurred", exc_info=True)
        raise
    finally:
        cleanup()
