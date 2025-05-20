import os
import pandas as pd
import logging
from neo4j import GraphDatabase
from typing import Dict, List, Optional, Any
from datetime import datetime
from collections import OrderedDict

class CSodTransformer:
    def __init__(self, neo4j_uri: str, neo4j_user: str, neo4j_password: str):
        """Initialize the transformer with Neo4j connection details."""
        self.driver = GraphDatabase.driver(neo4j_uri, auth=(neo4j_user, neo4j_password))
        self.logger = self._setup_logger()
        self.field_mappings = {}
        self.field_rules = {}
        self.source_order = {}  # New: Store source field order
        self._load_mappings()

    def _setup_logger(self) -> logging.Logger:
        """Set up logging with file output."""
        logger = logging.getLogger('CSodTransformer')
        logger.setLevel(logging.INFO)
        
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        log_dir = os.path.join(os.path.dirname(os.path.dirname(__file__)), 'logs')
        os.makedirs(log_dir, exist_ok=True)
        
        file_handler = logging.FileHandler(
            os.path.join(log_dir, f'transformation_{timestamp}.log')
        )
        formatter = logging.Formatter('%(asctime)s - %(levelname)s - %(message)s')
        file_handler.setFormatter(formatter)
        logger.addHandler(file_handler)
        
        return logger

    def _load_mappings(self):
        """Load all mappings and rules from Neo4j."""
        self.logger.info("Loading mappings from Neo4j...")
        try:
            with self.driver.session() as session:
                self.logger.info("Connected to Neo4j database")
                
                # Get all file types from Neo4j
                result = session.run("""
                    MATCH (f:File)
                    WHERE f.name IS NOT NULL AND f.name <> ''
                    RETURN DISTINCT f.name as name
                    ORDER BY name
                """)
                file_types = [record["name"] for record in result]
                self.logger.info(f"Found file types in Neo4j: {file_types}")
                
                if not file_types:
                    self.logger.error("No file types found in Neo4j database.")
                    return
                
                # Get field mappings without any ordering
                query = """
                    MATCH (f:File)-[:HAS_FIELD]->(st:SumTotalField)-[:MAPS_TO]->(csod:CSODField)
                    WHERE f.name IS NOT NULL AND f.name <> ''
                    RETURN f.name as file_name, 
                           st.name as sumtotal_field, 
                           csod.name as csod_field,
                           coalesce(csod.mandatory, 'Optional') as mandatory,
                           coalesce(csod.field_type, '') as field_type,
                           coalesce(csod.char_length, '') as char_length,
                           coalesce(csod.default_value, '') as default_value,
                           coalesce(csod.accepted_values, '') as accepted_values,
                           csod.Transformation as transformation
                    ORDER BY f.name, st.name
                """
                result = session.run(query)
                
                # Initialize dictionaries
                self.field_mappings = {}
                self.field_rules = {}
                self.source_order = {}  # Track source field order
                
                for record in result:
                    file_name = record["file_name"]
                    if file_name not in self.field_mappings:
                        self.field_mappings[file_name] = OrderedDict()
                        self.field_rules[file_name] = {}
                        self.source_order[file_name] = []
                    
                    st_field = record["sumtotal_field"]
                    csod_field = record["csod_field"]
                    
                    # Store mapping
                    self.field_mappings[file_name][st_field] = csod_field
                    self.field_rules[file_name][csod_field] = {
                        "mandatory": record["mandatory"] == "Mandatory",
                        "field_type": record["field_type"],
                        "char_length": record["char_length"],
                        "default_value": record["default_value"],
                        "accepted_values": record["accepted_values"].split(", ") if record["accepted_values"] else [],
                        "transformation": record["transformation"]
                    }
                    
                    # Track source field order
                    if st_field not in self.source_order[file_name]:
                        self.source_order[file_name].append(st_field)
                
                # Get output-only fields
                query = """
                    MATCH (f:File)-[:OUTPUTS_FIELD]->(csod:CSODField)
                    WHERE NOT EXISTS((f)-[:HAS_FIELD]->(:SumTotalField)-[:MAPS_TO]->(csod))
                    AND f.name IS NOT NULL AND f.name <> ''
                    RETURN f.name as file_name,
                           csod.name as csod_field,
                           coalesce(csod.mandatory, 'Optional') as mandatory,
                           coalesce(csod.field_type, '') as field_type,
                           coalesce(csod.char_length, '') as char_length,
                           coalesce(csod.default_value, '') as default_value,
                           coalesce(csod.accepted_values, '') as accepted_values,
                           csod.Transformation as transformation
                    ORDER BY f.name, csod.name
                """
                result = session.run(query)
                
                for record in result:
                    file_name = record["file_name"]
                    if file_name not in self.field_rules:
                        self.field_rules[file_name] = {}
                    
                    csod_field = record["csod_field"]
                    self.field_rules[file_name][csod_field] = {
                        "mandatory": record["mandatory"] == "Mandatory",
                        "field_type": record["field_type"],
                        "char_length": record["char_length"],
                        "default_value": record["default_value"],
                        "accepted_values": record["accepted_values"].split(", ") if record["accepted_values"] else [],
                        "transformation": record["transformation"]
                    }
                
        except Exception as e:
            self.logger.error(f"Error loading mappings from Neo4j: {str(e)}")
            raise

    def _validate_and_transform_value(self, value: Any, rules: Dict, field_name: str, file_name: str, row_idx: int) -> Any:
        """Validate and transform a single value according to rules."""
        # Handle empty values
        if pd.isna(value) or value == "":
            if rules.get("mandatory"):
                self.logger.error(
                    f"File: {file_name}, Row: {row_idx}, Field: {field_name} - "
                    "Mandatory field is empty"
                )
            return rules.get("default_value", "")

        # Convert to string for validation
        str_value = str(value)

        # Check character length
        char_length = rules.get("char_length")
        if char_length and len(str_value) > int(char_length):
            self.logger.error(
                f"File: {file_name}, Row: {row_idx}, Field: {field_name} - "
                f"Value exceeds maximum length of {char_length}"
            )
            return ""

        # Check accepted values
        accepted_values = rules.get("accepted_values", [])
        if accepted_values:
            if str_value.lower() not in [v.lower() for v in accepted_values]:
                self.logger.error(
                    f"File: {file_name}, Row: {row_idx}, Field: {field_name} - "
                    f"Value '{str_value}' not in accepted values: {accepted_values}"
                )
                return ""

        # Apply transformation if exists
        transformation = rules.get("transformation")
        if transformation:
            try:
                if isinstance(transformation, dict):
                    return transformation.get(str_value, transformation.get("ELSE", value))
            except Exception as e:
                self.logger.error(
                    f"File: {file_name}, Row: {row_idx}, Field: {field_name} - "
                    f"Transformation failed: {str(e)}"
                )
                return ""

        return value

    def _infer_file_type(self, filepath: str) -> str:
        """Infer the Neo4j file type from filepath."""
        # Get directory name and base filename
        dir_name = os.path.basename(os.path.dirname(filepath))
        base_name = os.path.splitext(os.path.basename(filepath))[0]
        
        # Remove (ST) and (CSOD) suffixes if present
        base_name = base_name.replace("(ST)", "").replace("(CSOD)", "").strip()
        base_name = base_name.split('-')[0].strip()  # Remove everything after a dash
        
        # Try to find an exact match first
        if base_name in self.field_mappings:
            return base_name
            
        # Try to find a partial match in original keys
        for file_type in self.field_mappings.keys():
            if file_type.lower() in base_name.lower():
                return file_type
            
        # Default to directory name if no match found
        return dir_name

    def transform_file(self, input_path: str, output_path: str):
        """Transform a single file according to the mapping rules."""
        try:
            # Determine the file type
            file_type = self._infer_file_type(input_path)
            self.logger.info(f"Processing file: {input_path}")
            self.logger.info(f"Inferred file type: {file_type}")
            
            if file_type not in self.field_mappings:
                self.logger.error(f"No mappings found for file type: {file_type}")
                self.logger.info(f"Available mappings are for: {list(self.field_mappings.keys())}")
                return
            
            # Read the input file
            try:
                if input_path.endswith(('.xlsx', '.xls')):
                    self.logger.info(f"Reading Excel file: {input_path}")
                    df = pd.read_excel(input_path)
                else:
                    self.logger.info(f"Reading CSV file: {input_path}")
                    df = pd.read_csv(input_path)
            except Exception as e:
                self.logger.error(f"Error reading input file {input_path}: {str(e)}")
                return
                
            input_columns = df.columns.tolist()
            self.logger.info(f"Input columns in order: {input_columns}")
            
            # Get mappings and rules
            field_mappings = self.field_mappings[file_type]
            file_rules = self.field_rules[file_type]
            
            # Create an output DataFrame
            output_df = pd.DataFrame(index=range(len(df)))
            
            # Process mapped fields in exact input sequence
            processed_fields = set()
            ordered_fields = []
            
            # Step 1: Process input columns in exact sequence they appear
            for input_col in input_columns:
                if input_col in field_mappings:
                    csod_field = field_mappings[input_col]
                    rules = file_rules[csod_field]
                    
                    self.logger.info(f"Processing mapped field: {input_col} -> {csod_field}")
                    
                    # Initialize field with empty strings
                    output_df[csod_field] = ''
                    
                    # Add to ordered fields and mark as processed
                    if csod_field not in processed_fields:
                        ordered_fields.append(csod_field)
                        processed_fields.add(csod_field)
                    
                    # Transform and validate the data
                    output_df[csod_field] = [
                        self._validate_and_transform_value(
                            value, rules, csod_field, input_path, idx
                        )
                        for idx, value in enumerate(df[input_col])
                    ]
            
            # Step 2: Add mandatory fields not in input
            mandatory_fields = [
                field for field in file_rules
                if field not in processed_fields and file_rules[field].get("mandatory", False)
            ]
            
            for csod_field in mandatory_fields:
                rules = file_rules[csod_field]
                ordered_fields.append(csod_field)
                processed_fields.add(csod_field)
                output_df[csod_field] = [rules.get("default_value", "")] * len(df)
                self.logger.info(f"Added mandatory field: {csod_field}")
            
            # Step 3: Add optional fields
            optional_fields = [
                field for field in file_rules
                if field not in processed_fields and not file_rules[field].get("mandatory", False)
            ]
            
            for csod_field in optional_fields:
                rules = file_rules[csod_field]
                ordered_fields.append(csod_field)
                output_df[csod_field] = [rules.get("default_value", "")] * len(df)
                self.logger.info(f"Added optional field: {csod_field}")
            
            # Reorder columns to match ordered_fields
            result_df = output_df[ordered_fields]
            
            # Log final column sequence
            self.logger.info("Final column sequence:")
            for idx, col in enumerate(ordered_fields):
                self.logger.info(f"{idx + 1}. {col}")
            
            # Ensure output directory exists
            os.makedirs(os.path.dirname(output_path), exist_ok=True)
            
            # Save the transformed file as CSV
            result_df.to_csv(output_path, index=False)
            self.logger.info(f"Successfully saved transformed file to {output_path}")
            
        except Exception as e:
            self.logger.error(f"Error transforming file {input_path}: {str(e)}")
            raise

