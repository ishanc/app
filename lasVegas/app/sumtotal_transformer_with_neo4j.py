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
    logger.error(f"NEO4J connection error: {str(e)}")
    raise

# Import MySQL error logging
from error_logger import ErrorLogger

def cleanup():
    """Cleanup function to close the Neo4j driver connection and error logger"""
    if driver:
        driver.close()
        logger.info("Neo4j connection closed")
    
    # Close error logger connection
    ErrorLogger.close_connection()

def parse_case_statement(transformation_rule: str) -> dict:
    """Parse a CASE statement transformation rule from Neo4j into a Python dictionary of mappings and default."""
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
    # Handle complex CASE statements with input_value references
    if 'input_value' in rule:
        # Split by WHEN and process each condition
        parts = rule.split('WHEN')
        for part in parts[1:]:  # Skip first empty part
            if 'THEN' in part:
                # Extract the condition and value
                condition_part, value_part = part.split('THEN', 1)
                # Extract the value after 'input_value = '
                if "input_value = '" in condition_part:
                    condition = condition_part.split("input_value = '")[1].split("'")[0]
                elif 'input_value = "' in condition_part:
                    condition = condition_part.split('input_value = "')[1].split('"')[0]
                else:
                    continue
                # Extract the result value
                value = value_part.split('WHEN')[0].split('ELSE')[0].strip()
                mappings[condition] = value
        # Check for ELSE clause
        if 'ELSE' in rule:
            else_value = rule.split('ELSE', 1)[1].split('END')[0].strip()
    else:
        # Original simple parsing for basic CASE statements
        parts = rule.strip().split('WHEN')
        for part in parts[1:]:  # Skip first empty part
            if 'THEN' in part:
                condition, value = part.split('THEN', 1)
                condition = condition.strip()
                value = value.split('ELSE', 1)[0].strip()
                mappings[condition] = value
        # Check for ELSE clause
        if 'ELSE' in rule:
            else_value = rule.split('ELSE', 1)[1].split('END')[0].strip()
    return {'mappings': mappings, 'default': else_value}

def apply_transformation_rule(value: str, transformation: dict) -> str:
    """Apply a parsed transformation rule to a value. Handles exact and pattern matches, returns default if no match."""
    if not transformation:
        return value
    mappings = transformation.get('mappings', {})
    default = transformation.get('default')
    # Try exact match first
    if value in mappings:
        return mappings[value]
    # For Topic/Subject mappings, try pattern matching (convert value to string for safety)
    value_str = "" if value is None else f"{value}"
    for pattern, result in mappings.items():
        if pattern.strip() in value_str or value_str.strip() in pattern:
            return result
    return default if default is not None else value

def validate_input_dataframe(input_df):
    """Validate input DataFrame for common issues"""
    # Check for empty column names
    empty_columns = [col for col in input_df.columns if col == '']
    if empty_columns:
        logger.error(f"Found {len(empty_columns)} empty column names in input DataFrame")
        raise ValueError(f"Input DataFrame contains {len(empty_columns)} empty column names")
    
    # Check for duplicate column names
    if len(input_df.columns) != len(set(input_df.columns)):
        logger.error("Input DataFrame contains duplicate column names")
        raise ValueError("Input DataFrame contains duplicate column names")

def initialize_output_dataframe(input_df):
    """Initialize output DataFrame with proper structure"""
    num_rows = max(len(input_df), 1)
    output_df = pd.DataFrame(index=range(num_rows))
    return output_df, set()  # Return DataFrame and populated_fields set

def process_source_field_mapping(input_df, output_df, rule, populated_fields):
    """Process source field mapping and copy values"""
    csod_field = rule['CSOD Field Name']
    st_field = rule.get('SumTotal Field Name', '')
    
    if not st_field or st_field not in input_df.columns:
        if st_field:
            logger.warning(f"SumTotal field '{st_field}' not found in input file for {csod_field}")
        return populated_fields
    
    if csod_field in populated_fields:
        return populated_fields
    
    try:
        # Safety check for empty field names
        if st_field == '':
            logger.error(f"Attempting to access empty field name for {csod_field}")
            raise ValueError(f"Cannot access empty field name for {csod_field}")
        
        values = input_df[st_field].fillna('')
        
        # Ensure values is a pandas Series
        if not isinstance(values, pd.Series):
            logger.warning(f"Values for {st_field} is not a pandas Series: {type(values)}")
            values = pd.Series([values] * len(output_df))
        
        output_df[csod_field] = values
        populated_fields.add(csod_field)
        
    except Exception as e:
        logger.error(f"TRANSFORMATION error: {str(e)}")
        output_df[csod_field] = [''] * len(output_df)
        populated_fields.add(csod_field)
    
    return populated_fields

def apply_field_transformation(output_df, rule, populated_fields):
    """Apply transformation rules to field values"""
    csod_field = rule['CSOD Field Name']
    transformation = rule.get('transformation', '')
    
    if not transformation or csod_field not in output_df.columns:
        return
    
    try:
        parsed_transform = parse_case_statement(transformation)
        values = output_df[csod_field]
        non_empty_mask = values.astype(str).str.strip() != ''
        
        if non_empty_mask.any():
            output_df.loc[non_empty_mask, csod_field] = values[non_empty_mask].apply(
                lambda x: apply_transformation_rule(x, parsed_transform)
            )
    except Exception as e:
        logger.error(f"Transformation error for {csod_field}: {str(e)}")

def apply_default_values(output_df, rule, populated_fields):
    """Apply default values to empty fields"""
    csod_field = rule['CSOD Field Name']
    default_value = rule.get('default_value', '')
    mandatory = rule.get('mandatory', '') == 'Mandatory'
    
    if csod_field in populated_fields:
        return populated_fields
    
    if default_value:
        empty_mask = (output_df[csod_field].isna()) | (output_df[csod_field].astype(str).str.strip() == '')
        if empty_mask.any():
            output_df.loc[empty_mask, csod_field] = default_value
            populated_fields.add(csod_field)
    elif mandatory:
        logger.warning(f"Mandatory field {csod_field} has no default value - will remain empty if no SumTotal data")
    
    return populated_fields

def handle_special_field_mappings(input_df, output_df, rule, populated_fields):
    """Handle special field mappings like Provider type"""
    csod_field = rule['CSOD Field Name']
    
    if csod_field == 'Provider type*':
        provider_values = input_df['Provider'].fillna('') if 'Provider' in input_df.columns else pd.Series([''] * len(output_df))
        output_df[csod_field] = provider_values.apply(lambda x: 'ILT' if 'ILT' in str(x) else 'ONLINE')
        populated_fields.add(csod_field)
    
    return populated_fields

def validate_field(output_df, rule, input_filename, input_df=None):
    """Validate field using ErrorLogger"""
    csod_field = rule['CSOD Field Name']
    st_field = rule.get('SumTotal Field Name', csod_field)
    field_type = rule.get('field_type', '')
    char_length = rule.get('char_length', '')
    mandatory = rule.get('mandatory', '') == 'Mandatory'
    
    # Get the field values from output DataFrame
    field_values = output_df[csod_field]
    
    # If we have input DataFrame and there's a SumTotal field mapping, 
    # store the input field name metadata for error logging
    if input_df is not None and st_field != csod_field and st_field in input_df.columns:
        if isinstance(field_values, pd.Series):
            field_values.attrs['input_field_name'] = st_field
            field_values.attrs['output_field_name'] = csod_field
    
    ErrorLogger.validate_field(
        field_name=csod_field,
        field_values=field_values,
        field_type=field_type,
        char_length=char_length,
        mandatory=mandatory,
        file_name=input_filename
    )

def transform_sumtotal_file(input_df, mapping_rules, file_type, input_filename=None): #file_type is the file name without the mapping file extension, may be used later for error logging as duplicate detection is hard coded for now
    """Transform a SumTotal file according to mapping rules and file type."""
    
    #--INSERT DUPLICATE DETECTION HERE--
    #This is a for the duplicate detection logic, hard coded for now NEED to change later for being company agnostic, unique columns will be things like EmployeeID, Column ID, etc
    unique_cols = ['Curriculum ID*', 'Event ID*', 'Session ID*', 'Material ID*', 'Test ID*','User ID*','OU ID*','Facility ID*','Instructor ID*','Course ID*']
    for unique_id in unique_cols:
        if unique_id in input_df.columns:
            # Create a boolean mask identifying duplicate values in the unique_id column
            # duplicated() returns True for all duplicate rows (both first and subsequent occurrences)
            # keep=False means all duplicates are marked as True, not just subsequent occurrences
            # This mask can be used to filter the dataframe to find/handle duplicate records
            dup_mask = input_df.duplicated(subset = [unique_id], keep = False)
            #Loop through the duplicate rows and queue an error for each
            for idx in input_df[dup_mask].index:
                ErrorLogger.queue_validation_error(
                    error_type = "DUPLICATE_RECORD",
                    field_name = unique_id,
                    row_number = idx,
                    value=str(input_df.loc[idx, unique_id]),
                    file_name = input_filename,
                    line_number = idx,
                )
                
    # Type-aware validation: only run relevant checks for each field
    for rule in mapping_rules:
        csod_field = rule['CSOD Field Name']
        st_field = rule.get('SumTotal Field Name', csod_field)
        field_type = rule.get('field_type', '').lower()
        char_length = rule.get('char_length', '')
        values = input_df[st_field] if st_field in input_df.columns else None
        if values is None:
            continue

        # Store input field name in Series metadata for error logging
        if isinstance(values, pd.Series):
            values.attrs['input_field_name'] = st_field
            values.attrs['output_field_name'] = csod_field

        # MANDATORY_EMPTY and TRUNCATION are handled in validate_field

        # LEADING_SPACES and TRAILING_SPACES
        if field_type in ['char', 'string']:
            ErrorLogger.detect_leading_spaces(csod_field, values, input_filename)
            ErrorLogger.detect_trailing_spaces(csod_field, values, input_filename)

        # ENCODING_ISSUE is handled in validate_field

        # DATE_FORMAT
        if field_type in ['date', 'datetime', 'date/time']:
            ErrorLogger.detect_date_format_issues(csod_field, values, file_name=input_filename)

        # LEADING_ZEROS and TYPE_COMPATIBILITY
        if field_type in ['integer', 'decimal']:
            ErrorLogger.detect_leading_zeros(csod_field, values, input_filename)
            ErrorLogger.detect_type_compatibility(csod_field, values, field_type, input_filename)

        # BOOLEAN_CONVERSION
        if field_type == 'boolean':
            ErrorLogger.detect_boolean_conversion_issues(csod_field, values, input_filename)

        # OUTLIER_VALUE
        if field_type in ['integer', 'decimal', 'float']:
            ErrorLogger.detect_outliers(csod_field, values, input_filename)

        # HETEROGENEOUS_TYPE
        ErrorLogger.detect_heterogeneous_types(csod_field, values, input_filename)

        # COMPLETENESS_SCORE (optional, can be run at file level)
        # HEADER_INCONSISTENCY and DELIMITER_ISSUE are file-level, not field-level

    # File-level checks (optional, uncomment if needed):
    # ErrorLogger.detect_header_inconsistency(input_df, expected_headers=[r['CSOD Field Name'] for r in mapping_rules], file_name=input_filename)
    # ErrorLogger.calculate_completeness_score(input_df, mandatory_fields=[r['CSOD Field Name'] for r in mapping_rules if r.get('mandatory', '').lower() == 'mandatory'], file_name=input_filename)

    validate_input_dataframe(input_df)
    
    # Initialize output DataFrame
    output_df, populated_fields = initialize_output_dataframe(input_df)
    
    # Process all fields based on mapping rules
    for rule in mapping_rules:
        csod_field = rule['CSOD Field Name']
        
        # Initialize field with empty string if not already present
        if csod_field not in output_df.columns:
            output_df[csod_field] = ''
        
        # Process source field mapping
        populated_fields = process_source_field_mapping(input_df, output_df, rule, populated_fields)
        
        # Apply transformations
        apply_field_transformation(output_df, rule, populated_fields)
        
        # Apply default values
        populated_fields = apply_default_values(output_df, rule, populated_fields)
        
        # Handle special field mappings
        populated_fields = handle_special_field_mappings(input_df, output_df, rule, populated_fields)
        
        # Validate field
        validate_field(output_df, rule, input_filename, input_df)
    
    # Process any queued validation errors before returning
    ErrorLogger.process_error_queue()
    
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
        
        # Create corresponding output directory structure
        rel_path = os.path.relpath(root, directory_path)
        current_output_dir = os.path.join(output_dir, rel_path)
        os.makedirs(current_output_dir, exist_ok=True)
        
        for file in input_files:
            file_path = os.path.join(root, file)
            file_key = os.path.splitext(file)[0]
            
            try:
                # Read Excel with empty strings instead of NaN
                input_df = pd.read_excel(file_path, keep_default_na=False, na_values=[''], dtype=str)
                
                # Create empty mapping rules if none exist
                if file_key not in mapping_rules:
                    mapping_rules[file_key] = [
                        {"CSOD Field Name": col, "SumTotal Field Name": col}
                        for col in input_df.columns
                    ]
                
                # Pass the file_key as file_type and filename for error logging
                transformed_df = transform_sumtotal_file(input_df, mapping_rules[file_key], file_key, file)
                
                # Ensure empty strings instead of NaN in output
                transformed_df = transformed_df.fillna("")
                
                # Write CSV without index and with empty strings for missing values
                output_file_path = os.path.join(current_output_dir, f"{file_key}-CSOD.csv")
                transformed_df.to_csv(output_file_path, index=False, na_rep="")
                processed += 1
                
            except Exception as e:
                logger.error(f"FILE_PROCESSING error: {str(e)}")
                failed += 1
                
    return total, processed, failed

def process_folder_sequence(source_folder: str, output_folder: str, mapping_rules: dict):
    """Process main folders in the specified sequence"""


    total_files = 0
    total_processed = 0
    total_failed = 0
    
    # Process each main folder in sequence
    for folder in FOLDER_SEQUENCE:
        current_folder = os.path.join(source_folder, folder)

        
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
        


def load_mapping_rules_from_neo4j_file(filepath: str) -> Dict[str, List[Dict]]:
    """Load and parse mapping rules from the Neo4j cypher file"""
    mapping_rules = {}
    current_file = None
    current_st_field = None
    current_csod_field = None
    current_properties = {}  # Store all properties for current field


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

                    
            elif line.startswith('MERGE (csod:CSODField {name:'):
                if current_file:
                    current_csod_field = line.split('"')[1]
                    current_properties = {
                        "CSOD Field Name": current_csod_field,
                        "SumTotal Field Name": "",
                        "Default value": "",
                        "transformation": ""
                    }

                    
            elif line.startswith('SET csod.'):
                if current_file and current_csod_field:
                    try:
                        # Remove 'SET csod.' prefix and parse property
                        prop_line = line[9:].strip()
                        prop_name, prop_value = prop_line.split('=', 1)
                        prop_name = prop_name.strip()
                        prop_value = prop_value.strip().rstrip(',')
                        
                        # Store default_value and other properties
                        if prop_name == 'default_value':
                            current_properties["default_value"] = prop_value

                        elif prop_name == 'transformation':
                            current_properties["transformation"] = prop_value
                        # Store all properties in case we need them
                        current_properties[prop_name] = prop_value

                        
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

def fetch_mapping_rules_from_neo4j(file_name: str) -> List[Dict]:
    """Fetch mapping rules directly from Neo4j for a specific file"""
    rules = []
    
    try:
        with driver.session() as session:
            # Special handling for Activity_Curriculum - fetch both Activity_Curriculum and Activity_CurriculumStructure
            if file_name == "Activity_Curriculum":
                query = """
                MATCH (f:File)-[:OUTPUTS_FIELD]->(csod:CSODField)
                WHERE f.name IN ['Activity_Curriculum', 'Activity_CurriculumStructure']
                OPTIONAL MATCH (st:SumTotalField)-[:MAPS_TO]->(csod)
                OPTIONAL MATCH (f)-[:HAS_FIELD]->(st)
                RETURN csod.name as csod_field_name,
                       st.name as sumtotal_field_name,
                       csod.mandatory as mandatory,
                       csod.field_type as field_type,
                       csod.char_length as char_length,
                       csod.default_value as default_value,
                       csod.accepted_values as accepted_values,
                       csod.transformation as transformation,
                       f.name as file,
                       csod.output_document as output_document
                """
                result = session.run(query)
            # Special handling for Activity_Test - fetch both Activity_Test and Activity_TestMapping
            elif file_name == "Activity_Test":
                query = """
                MATCH (f:File)-[:OUTPUTS_FIELD]->(csod:CSODField)
                WHERE f.name IN ['Activity_Test', 'Activity_TestMapping']
                OPTIONAL MATCH (st:SumTotalField)-[:MAPS_TO]->(csod)
                OPTIONAL MATCH (f)-[:HAS_FIELD]->(st)
                RETURN csod.name as csod_field_name,
                       st.name as sumtotal_field_name,
                       csod.mandatory as mandatory,
                       csod.field_type as field_type,
                       csod.char_length as char_length,
                       csod.default_value as default_value,
                       csod.accepted_values as accepted_values,
                       csod.transformation as transformation,
                       f.name as file,
                       csod.output_document as output_document
                """
                result = session.run(query)
            # Special handling for Transcript files - ensure they only fetch their specific rules
            elif file_name.startswith("Transcript_"):
                query = """
                MATCH (f:File {name: $fileName})-[:OUTPUTS_FIELD]->(csod:CSODField)
                WHERE f.name = $fileName
                OPTIONAL MATCH (st:SumTotalField)-[:MAPS_TO]->(csod)
                OPTIONAL MATCH (f)-[:HAS_FIELD]->(st)
                RETURN csod.name as csod_field_name,
                       st.name as sumtotal_field_name,
                       csod.mandatory as mandatory,
                       csod.field_type as field_type,
                       csod.char_length as char_length,
                       csod.default_value as default_value,
                       csod.accepted_values as accepted_values,
                       csod.transformation as transformation,
                       f.name as file,
                       csod.output_document as output_document
                """
                result = session.run(query, fileName=file_name)
                logger.info(f"Executing Transcript-specific query for file: {file_name}")
            else:
                # Regular query for other files
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
                       csod.transformation as transformation,
                       f.name as file,
                       csod.output_document as output_document
                """
                result = session.run(query, fileName=file_name)
            
            for record in result:
                rule = {
                    "CSOD Field Name": record["csod_field_name"],
                    "SumTotal Field Name": record["sumtotal_field_name"] or "",
                    "mandatory": record["mandatory"] or "Optional",
                    "field_type": record["field_type"] or "",
                    "char_length": record["char_length"] or "",
                    "default_value": record.get("default_value") or "",
                    "accepted_values": record["accepted_values"] or "",
                    "transformation": record["transformation"] or "",
                    "file": record["file"] or file_name,
                    "output_document": record.get("output_document") or ""
                }
                rules.append(rule)
                logger.debug(f"Fetched rule: {rule['CSOD Field Name']} -> {rule['output_document']} (file: {rule['file']})")
            
            logger.info(f"Fetched {len(rules)} mapping rules from Neo4j for file: {file_name}")
            return rules
            
    except Exception as e:
        logger.error(f"NEO4J query error: {str(e)}")
        raise

def fetch_all_mapping_rules_from_neo4j() -> Dict[str, List[Dict]]:
    """Fetch mapping rules for all files from Neo4j database"""
    all_rules = {}
    
    try:
        with driver.session() as session:
            # First get all file names
            file_query = "MATCH (f:File) RETURN f.name as file_name"
            file_result = session.run(file_query)
            
            for file_record in file_result:
                file_name = file_record["file_name"]
                rules = fetch_mapping_rules_from_neo4j(file_name)
                all_rules[file_name] = rules
                
        logger.info(f"Fetched mapping rules for {len(all_rules)} files from Neo4j")
        return all_rules
        
    except Exception as e:
        logger.error(f"NEO4J fetch error: {str(e)}")
        raise

def transform_data(data: List[Dict], mapping_rules: List[Dict]) -> List[Dict]:
    """Transform data using mapping rules - no field ordering manipulation"""
    transformed_data = []
    
    # Create a mapping from SumTotal field names to CSOD field names and their properties
    field_mapping = {}
    
    for rule in mapping_rules:
        csod_field = rule["CSOD Field Name"]
        sumtotal_field = rule["SumTotal Field Name"]
        
        if sumtotal_field:  # Only map if there's a SumTotal field
            field_mapping[sumtotal_field] = {
                "csod_field": csod_field,
                "mandatory": rule["mandatory"],
                "field_type": rule["field_type"],
                "char_length": rule["char_length"],
                "default_value": rule["default_value"],
                "accepted_values": rule["accepted_values"],
                "transformation": rule["transformation"]
            }
    
    for row in data:
        transformed_row = {}
        
        for rule in mapping_rules:
            csod_field = rule["CSOD Field Name"]
            sumtotal_field = rule["SumTotal Field Name"]
            
            # Get the value from SumTotal data
            if sumtotal_field and sumtotal_field in row:
                value = row[sumtotal_field]  # ✅ 1. If SumTotal field exists, use it
            else:
                value = None
            
            # Apply transformation if specified
            if value is not None and rule["transformation"]:
                try:
                    # Convert value to string before transformation to handle floats from Excel
                    # Handle special cases to prevent data loss
                    if pd.isna(value) or value == "":
                        value_str = ""
                    elif isinstance(value, (int, float)):
                        # For numeric values, use full precision
                        value_str = str(value)
                    else:
                        value_str = str(value)
                    
                    # Parse the transformation rule first
                    parsed_transformation = parse_case_statement(rule["transformation"])
                    value = apply_transformation_rule(value_str, parsed_transformation)
                except Exception as e:
                    logger.warning(f"Transformation failed for {csod_field}: {e}")
                    value = None
            
            # Use default value if no value from SumTotal
            if value is None or value == "":
                if rule.get("default_value"):
                    value = rule["default_value"]  # ✅ 2. If no SumTotal data, use default
                else:
                    value = ""  # ✅ 3. If neither exists, leave empty
            
            # For fields without SumTotal mappings, always apply default if available
            if not sumtotal_field and rule.get("default_value"):
                value = rule["default_value"]
            
            transformed_row[csod_field] = value
        
        transformed_data.append(transformed_row)
    
    return transformed_data


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
        logger.error(f"SYSTEM error: {str(e)}")
        raise
    finally:
        cleanup()
