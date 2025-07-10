import pandas as pd
import logging
from datetime import datetime
import re
from typing import Dict, List, Optional, Tuple

# Configure logging - use INFO for production, DEBUG for troubleshooting
logging.basicConfig(level=logging.INFO, format='%(levelname)s:%(name)s:%(message)s')
logger = logging.getLogger(__name__)

class CypherParser:
    """Parser for Cypher mapping files"""
    
    def __init__(self):
        self.current_file: Optional[str] = None
        self.current_csod_field: Optional[str] = None
        self.current_st_field: Optional[str] = None
        self.current_properties: Dict[str, str] = {}
        self.current_sumtotal_mapping: Optional[str] = None
        self.in_set_statement: bool = False
        self.mapping_rules: Dict[str, List[Dict]] = {}
    
    def clean_property_value(self, value: str) -> str:
        """Clean property value by removing quotes, commas, and whitespace"""
        return value.strip().strip(',').strip('"').strip("'")
    
    def parse_property_line(self, line: str, line_number: int) -> None:
        """Parse a single property line and extract key-value pairs"""
        # Remove 'csod.' prefix if present
        clean_line = line.replace('csod.', '').strip()
        
        # Split by comma and process each property
        for prop_part in clean_line.split(','):
            prop_part = prop_part.strip()
            if '=' not in prop_part:
                continue
                
            key, value = prop_part.split('=', 1)
            key = key.strip()
            value = self.clean_property_value(value)
            
            self.current_properties[key] = value
            
            # Log transformation rules for debugging
            if key == "transformation" and value:
                logger.debug(f"Line {line_number}: Found transformation rule: {value[:100]}...")
    
    def parse_file(self, filepath: str) -> Dict[str, List[Dict]]:
        """Parse the Cypher file and extract mapping rules"""
        logger.info(f"Parsing Cypher file: {filepath}")
        
        with open(filepath, 'r', encoding='utf-8') as f:
            for line_number, line in enumerate(f, 1):
                line = line.strip()
                
                # Skip empty lines and comments
                if not line or line.startswith('//'):
                    continue
                
                self._process_line(line, line_number)
        
        logger.info(f"Parsed {len(self.mapping_rules)} files with mapping rules")
        for file_name, rules in self.mapping_rules.items():
            logger.info(f"  {file_name}: {len(rules)} rules")
        
        return self.mapping_rules
    
    def _process_line(self, line: str, line_number: int) -> None:
        """Process a single line from the Cypher file"""
        
        # File definition
        if line.startswith('MERGE (f:File {name:'):
            file_match = line.split('"')[1] if '"' in line else None
            if file_match:
                self.current_file = file_match
                if self.current_file not in self.mapping_rules:
                    self.mapping_rules[self.current_file] = []
                logger.debug(f"Line {line_number}: Found file: {self.current_file}")
        
        # CSOD field definition
        elif line.startswith('MERGE (csod:CSODField {name:'):
            field_match = line.split('"')[1] if '"' in line else None
            if field_match and self.current_file:
                self.current_csod_field = field_match
                self.current_properties = {}
                logger.debug(f"Line {line_number}: Found CSOD field: {self.current_csod_field}")
        
        # SET properties (start)
        elif line.startswith('SET csod.'):
            self.in_set_statement = True
            self.parse_property_line(line.replace('SET csod.', ''), line_number)
        
        # SET properties (continuation)
        elif self.in_set_statement and '=' in line:
            self.parse_property_line(line, line_number)
        
        # SumTotal field definition
        elif line.startswith('MERGE (st:SumTotalField {name:'):
            field_match = line.split('"')[1] if '"' in line else None
            if field_match and self.current_file:
                self.current_st_field = field_match
                logger.debug(f"Line {line_number}: Found SumTotal field: {self.current_st_field}")
        
        # MAPS_TO relationship
        elif line.startswith('MERGE (st)-[:MAPS_TO]->'):
            if self.current_st_field:
                self.current_sumtotal_mapping = self.current_st_field
                logger.debug(f"Line {line_number}: Will map {self.current_st_field} to next CSOD field")
        
        # OUTPUTS_FIELD relationship (end of field definition)
        elif line.startswith('MERGE (f)-[:OUTPUTS_FIELD]->(csod);'):
            self.in_set_statement = False
            self._create_rule(line_number)
            self._reset_state()
    
    def _create_rule(self, line_number: int) -> None:
        """Create a mapping rule from current state"""
        if not (self.current_file and self.current_csod_field and self.current_properties):
            return
        
        rule = {
            "CSOD Field Name": self.current_csod_field,
            "SumTotal Field Name": self.current_sumtotal_mapping or "",
            "Mandatory": self.current_properties.get("mandatory", ""),
            "Field Type": self.current_properties.get("field_type", ""),
            "Char Length": self.current_properties.get("char_length", ""),
            "Default Value": self.current_properties.get("default_value", ""),
            "Accepted Values": self.current_properties.get("accepted_values", ""),
            "Output Document": self.current_properties.get("output_document", ""),
            "Transformation": self.current_properties.get("transformation", "")
        }
        
        self.mapping_rules[self.current_file].append(rule)
        logger.debug(f"Line {line_number}: Added rule for {self.current_csod_field}")
    
    def _reset_state(self) -> None:
        """Reset parser state for next field"""
        self.current_csod_field = None
        self.current_properties = {}
        self.current_sumtotal_mapping = None


class TransformationEngine:
    """Engine for applying transformation rules"""
    
    @staticmethod
    def apply_transformation(input_value: str, transformation_rule: str) -> str:
        """Apply CASE WHEN transformation rule to input value"""
        if not transformation_rule or not input_value:
            return input_value
        
        try:
            # Extract all WHEN clauses
            when_pattern = r"WHEN input_value = '([^']+)' THEN ([^ ]+)"
            matches = re.findall(when_pattern, transformation_rule)
            
            # Check each WHEN clause
            for condition_value, result_value in matches:
                if str(input_value).strip() == condition_value:
                    logger.debug(f"Transformation applied: '{input_value}' -> '{result_value}'")
                    return result_value
            
            # Check for ELSE clause
            else_match = re.search(r"ELSE ([^ ]+)", transformation_rule)
            if else_match:
                default_value = else_match.group(1)
                logger.debug(f"Transformation default applied: '{input_value}' -> '{default_value}'")
                return default_value
            
            # No match found, return original value
            logger.debug(f"No transformation match found for '{input_value}', keeping original")
            return input_value
            
        except Exception as e:
            logger.warning(f"Error applying transformation rule: {e}")
            return input_value


class DataTransformer:
    """Main data transformation engine"""
    
    def __init__(self, mapping_rules: Dict[str, List[Dict]]):
        self.mapping_rules = mapping_rules
        self.transformation_engine = TransformationEngine()
    
    def transform_data(self, input_file: str) -> Dict[str, pd.DataFrame]:
        """Transform data using the mapping rules"""
        logger.info(f"Loading input file: {input_file}")
        
        # Load the Excel file
        df = pd.read_excel(input_file)
        logger.info(f"Loaded {len(df)} rows with columns: {list(df.columns)}")
        
        # Group rules by output document
        output_files = self._group_rules_by_output()
        logger.info(f"Found {len(output_files)} output files: {list(output_files.keys())}")
        
        # Transform data for each output file
        transformed_data = {}
        for output_file, rules in output_files.items():
            transformed_data[output_file] = self._transform_output_file(df, rules, output_file)
        
        return transformed_data
    
    def _group_rules_by_output(self) -> Dict[str, List[Dict]]:
        """Group mapping rules by output document"""
        output_files = {}
        
        for file_name, rules in self.mapping_rules.items():
            logger.debug(f"Processing file: {file_name} with {len(rules)} rules")
            for rule in rules:
                output_doc = rule.get("Output Document", "")
                if output_doc:
                    if output_doc not in output_files:
                        output_files[output_doc] = []
                    output_files[output_doc].append(rule)
                else:
                    logger.warning(f"Rule '{rule['CSOD Field Name']}' has empty output_document")
        
        return output_files
    
    def _transform_output_file(self, df: pd.DataFrame, rules: List[Dict], output_file: str) -> pd.DataFrame:
        """Transform data for a specific output file"""
        logger.info(f"Processing output file: {output_file}")
        logger.debug(f"  Rules: {[rule['CSOD Field Name'] for rule in rules]}")
        
        output_rows = []
        
        for _, row in df.iterrows():
            output_row = {}
            
            for rule in rules:
                value = self._get_field_value(row, rule)
                output_row[rule["CSOD Field Name"]] = value
            
            output_rows.append(output_row)
        
        result_df = pd.DataFrame(output_rows)
        logger.info(f"Created {len(output_rows)} rows for {output_file}")
        return result_df
    
    def _get_field_value(self, row: pd.Series, rule: Dict) -> str:
        """Get the value for a specific field from the row"""
        csod_field = rule["CSOD Field Name"]
        sumtotal_field = rule["SumTotal Field Name"]
        default_value = rule["Default Value"]
        
        # Get value from source data or use default
        if sumtotal_field and sumtotal_field in row:
            sumtotal_value = row[sumtotal_field]
            if pd.isna(sumtotal_value) or sumtotal_value == "" or str(sumtotal_value).strip() == "":
                value = default_value if default_value else ""
                logger.debug(f"Field {csod_field}: SumTotal field '{sumtotal_field}' is empty, using default: '{value}'")
            else:
                value = str(sumtotal_value)
                logger.debug(f"Field {csod_field}: Using SumTotal value '{value}' from field '{sumtotal_field}'")
        else:
            value = default_value if default_value else ""
            logger.debug(f"Field {csod_field}: No SumTotal mapping, using default: '{value}'")
        
        # Apply transformation if available
        transformation_rule = rule.get("Transformation", "")
        if transformation_rule:
            logger.debug(f"Field {csod_field}: Found transformation rule: {transformation_rule[:100]}...")
            original_value = value
            value = self.transformation_engine.apply_transformation(value, transformation_rule)
            if value != original_value:
                logger.info(f"Field {csod_field}: Transformed '{original_value}' -> '{value}'")
        else:
            logger.debug(f"Field {csod_field}: No transformation rule found")
        
        return value


class OutputManager:
    """Manages output file generation"""
    
    @staticmethod
    def save_output_files(transformed_data: Dict[str, pd.DataFrame]) -> None:
        """Save transformed data to CSV files"""
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        
        for output_file, df in transformed_data.items():
            filename = f"output_{output_file}_{timestamp}.csv"
            df.to_csv(filename, index=False)
            logger.info(f"Saved {filename} with {len(df)} rows and {len(df.columns)} columns")
            logger.info(f"  Columns: {list(df.columns)}")


def main():
    """Main execution function"""
    # Load mapping rules
    parser = CypherParser()
    mapping_rules = parser.parse_file("Curriculum_Mapping.cypher")
    
    # Transform data
    transformer = DataTransformer(mapping_rules)
    input_file = "SumTotal_CSOD_Mapping_Files/Activity/SumTotal  Report Data/Curriculum.xlsx"
    transformed_data = transformer.transform_data(input_file)
    
    # Save output files
    OutputManager.save_output_files(transformed_data)


if __name__ == "__main__":
    main() 