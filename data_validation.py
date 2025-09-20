import pandas as pd
import logging
from typing import Dict, List, Any, Tuple, Optional
from datetime import datetime
import re
import os

class DataValidator:
    """Comprehensive data validation for SumTotal to CSOD transformation pipeline"""
    
    def __init__(self, log_level=logging.INFO):
        self.logger = self._setup_logger(log_level)
        self.validation_errors = []
        self.validation_warnings = []
        
    def _setup_logger(self, log_level):
        """Setup logger for validation messages"""
        logger = logging.getLogger('DataValidator')
        logger.setLevel(log_level)
        
        if not logger.handlers:
            handler = logging.StreamHandler()
            formatter = logging.Formatter(
                '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
            )
            handler.setFormatter(formatter)
            logger.addHandler(handler)
            
        return logger
    
    def validate_input_file(self, filepath: str, expected_columns: List[str] = None) -> Tuple[bool, List[str]]:
        """
        Validate input file structure and content
        
        Args:
            filepath: Path to the input file
            expected_columns: List of expected column names (optional)
            
        Returns:
            Tuple of (is_valid, error_messages)
        """
        errors = []
        warnings = []
        
        try:
            # Check file exists
            if not os.path.exists(filepath):
                errors.append(f"File does not exist: {filepath}")
                return False, errors
            
            # Check file size
            file_size = os.path.getsize(filepath)
            if file_size == 0:
                errors.append(f"File is empty: {filepath}")
                return False, errors
            
            # Read file based on extension
            file_ext = os.path.splitext(filepath)[1].lower()
            if file_ext in ['.xlsx', '.xls']:
                try:
                    df = pd.read_excel(filepath, keep_default_na=False, na_values=[''])
                except Exception as e:
                    errors.append(f"Failed to read Excel file: {str(e)}")
                    return False, errors
            elif file_ext == '.csv':
                try:
                    df = pd.read_csv(filepath, keep_default_na=False, na_values=[''], encoding='utf-8')
                except Exception as e:
                    errors.append(f"Failed to read CSV file: {str(e)}")
                    return False, errors
            else:
                errors.append(f"Unsupported file type: {file_ext}")
                return False, errors
            
            # Validate DataFrame structure
            if df.empty:
                errors.append("DataFrame is empty - no data rows found")
                return False, errors
            
            if len(df.columns) == 0:
                errors.append("DataFrame has no columns")
                return False, errors
            
            # Check for expected columns if provided
            if expected_columns:
                missing_columns = set(expected_columns) - set(df.columns)
                if missing_columns:
                    errors.append(f"Missing expected columns: {list(missing_columns)}")
                
                extra_columns = set(df.columns) - set(expected_columns)
                if extra_columns:
                    warnings.append(f"Extra columns found: {list(extra_columns)}")
            
            # Check for completely empty columns
            empty_columns = []
            for col in df.columns:
                if df[col].isna().all() or (df[col].astype(str).str.strip() == '').all():
                    empty_columns.append(col)
            
            if empty_columns:
                warnings.append(f"Completely empty columns: {empty_columns}")
            
            # Check for duplicate column names
            if len(df.columns) != len(set(df.columns)):
                errors.append("Duplicate column names found")
            
            # Check for duplicate rows
            duplicate_rows = df.duplicated().sum()
            if duplicate_rows > 0:
                warnings.append(f"Found {duplicate_rows} duplicate rows")
            
            # Store validation results
            self.validation_errors.extend(errors)
            self.validation_warnings.extend(warnings)
            
            return len(errors) == 0, errors
            
        except Exception as e:
            error_msg = f"Unexpected error during file validation: {str(e)}"
            errors.append(error_msg)
            self.validation_errors.append(error_msg)
            return False, errors
    
    def validate_mapping_rules(self, mapping_rules: List[Dict], file_type: str) -> Tuple[bool, List[str]]:
        """
        Validate mapping rules structure and content
        
        Args:
            mapping_rules: List of mapping rule dictionaries
            file_type: Type of file being processed
            
        Returns:
            Tuple of (is_valid, error_messages)
        """
        errors = []
        warnings = []
        
        if not mapping_rules:
            errors.append(f"No mapping rules provided for file type: {file_type}")
            return False, errors
        
        required_fields = ['CSOD Field Name']
        optional_fields = ['SumTotal Field Name', 'Default value', 'transformation', 
                          'field_type', 'char_length', 'mandatory', 'accepted_values']
        
        for i, rule in enumerate(mapping_rules):
            # Check required fields
            for field in required_fields:
                if field not in rule:
                    errors.append(f"Rule {i}: Missing required field '{field}'")
                elif not rule[field]:
                    errors.append(f"Rule {i}: Required field '{field}' is empty")
            
            # Validate field types
            if 'field_type' in rule and rule['field_type']:
                valid_types = ['string', 'integer', 'decimal', 'date', 'datetime', 'boolean']
                if rule['field_type'].lower() not in valid_types:
                    warnings.append(f"Rule {i}: Unknown field type '{rule['field_type']}'")
            
            # Validate character length
            if 'char_length' in rule and rule['char_length']:
                try:
                    length = int(rule['char_length'])
                    if length <= 0:
                        errors.append(f"Rule {i}: Character length must be positive, got {length}")
                except ValueError:
                    errors.append(f"Rule {i}: Invalid character length '{rule['char_length']}'")
            
            # Validate mandatory field
            if 'mandatory' in rule and rule['mandatory']:
                valid_mandatory = ['Mandatory', 'Optional']
                if rule['mandatory'] not in valid_mandatory:
                    warnings.append(f"Rule {i}: Unknown mandatory value '{rule['mandatory']}'")
            
            # Validate transformation syntax
            if 'transformation' in rule and rule['transformation']:
                transform_errors = self._validate_transformation_syntax(rule['transformation'])
                for error in transform_errors:
                    errors.append(f"Rule {i}: {error}")
        
        # Check for duplicate CSOD field names
        csod_fields = [rule.get('CSOD Field Name', '') for rule in mapping_rules]
        duplicate_csod = [field for field in set(csod_fields) if csod_fields.count(field) > 1]
        if duplicate_csod:
            errors.append(f"Duplicate CSOD field names: {duplicate_csod}")
        
        self.validation_errors.extend(errors)
        self.validation_warnings.extend(warnings)
        
        return len(errors) == 0, errors
    
    def _validate_transformation_syntax(self, transformation: str) -> List[str]:
        """Validate transformation rule syntax"""
        errors = []
        
        if not transformation:
            return errors
        
        # Basic CASE statement validation
        if 'CASE' in transformation.upper():
            # Check for balanced CASE/END
            case_count = transformation.upper().count('CASE')
            end_count = transformation.upper().count('END')
            if case_count != end_count:
                errors.append("Unbalanced CASE/END statements in transformation")
            
            # Check for WHEN/THEN pairs
            when_count = transformation.upper().count('WHEN')
            then_count = transformation.upper().count('THEN')
            if when_count != then_count:
                errors.append("Unbalanced WHEN/THEN pairs in transformation")
        
        return errors
    
    def validate_data_values(self, df: pd.DataFrame, mapping_rules: List[Dict], 
                           file_type: str) -> Tuple[bool, List[str]]:
        """
        Validate data values against mapping rules
        
        Args:
            df: Input DataFrame
            mapping_rules: List of mapping rules
            file_type: Type of file being processed
            
        Returns:
            Tuple of (is_valid, error_messages)
        """
        errors = []
        warnings = []
        
        # Build field mapping dictionary
        field_mapping = {}
        for rule in mapping_rules:
            csod_field = rule.get('CSOD Field Name', '')
            st_field = rule.get('SumTotal Field Name', '')
            if st_field and csod_field:
                field_mapping[st_field] = csod_field
        
        for rule in mapping_rules:
            csod_field = rule.get('CSOD Field Name', '')
            st_field = rule.get('SumTotal Field Name', '')
            mandatory = rule.get('mandatory', '') == 'Mandatory'
            char_length = rule.get('char_length', '')
            accepted_values = rule.get('accepted_values', [])
            
            # For each CSOD field, check its mapped SumTotal field
            if st_field and st_field in df.columns:
                # Validate using source field values
                if mandatory:
                    empty_count = (df[st_field].isna() | (df[st_field].astype(str).str.strip() == '')).sum()
                    if empty_count > 0:
                        errors.append(f"Mandatory field '{st_field}' mapped to '{csod_field}' has {empty_count} empty values")
            else:
                # Field is missing but required
                if mandatory:
                    warnings.append(f"Mandatory field '{csod_field}' has no SumTotal mapping")
                continue
            
            # Check for mandatory field violations
            if mandatory:
                empty_mask = df[st_field].isna() | (df[st_field].astype(str).str.strip() == '')
                empty_count = empty_mask.sum()
                if empty_count > 0:
                    errors.append(f"Mandatory field '{csod_field}' has {empty_count} empty values")
            
            # Check character length violations
            if char_length and char_length.isdigit():
                max_length = int(char_length)
                too_long_mask = df[st_field].astype(str).str.len() > max_length
                too_long_count = too_long_mask.sum()
                if too_long_count > 0:
                    errors.append(f"Field '{csod_field}' has {too_long_count} values exceeding {max_length} characters")
            
            # Check accepted values violations
            if accepted_values:
                if isinstance(accepted_values, str):
                    accepted_values = [v.strip() for v in accepted_values.split(',')]
                
                invalid_mask = ~df[st_field].astype(str).str.lower().isin([v.lower() for v in accepted_values])
                invalid_count = invalid_mask.sum()
                if invalid_count > 0:
                    errors.append(f"Field '{csod_field}' has {invalid_count} values not in accepted list: {accepted_values}")
            
            # Check data type violations
            field_type = rule.get('field_type', '').lower()
            if field_type:
                type_errors = self._validate_data_types(df[st_field], field_type, csod_field)
                errors.extend(type_errors)
        
        self.validation_errors.extend(errors)
        self.validation_warnings.extend(warnings)
        
        return len(errors) == 0, errors
    
    def _validate_data_types(self, series: pd.Series, expected_type: str, field_name: str) -> List[str]:
        """Validate data types for a series"""
        errors = []
        
        if expected_type == 'integer':
            # Check for non-integer values
            non_int_mask = pd.to_numeric(series, errors='coerce').isna()
            non_int_count = non_int_mask.sum()
            if non_int_count > 0:
                errors.append(f"Field '{field_name}' has {non_int_count} non-integer values")
        
        elif expected_type == 'decimal':
            # Check for non-numeric values
            non_num_mask = pd.to_numeric(series, errors='coerce').isna()
            non_num_count = non_num_mask.sum()
            if non_num_count > 0:
                errors.append(f"Field '{field_name}' has {non_num_count} non-numeric values")
        
        elif expected_type == 'date':
            # Check for invalid date values
            date_errors = 0
            for value in series.dropna():
                try:
                    pd.to_datetime(value)
                except:
                    date_errors += 1
            if date_errors > 0:
                errors.append(f"Field '{field_name}' has {date_errors} invalid date values")
        
        elif expected_type == 'boolean':
            # Check for non-boolean values
            valid_bools = ['true', 'false', '1', '0', 'yes', 'no', 'y', 'n']
            invalid_bool_mask = ~series.astype(str).str.lower().isin(valid_bools)
            invalid_bool_count = invalid_bool_mask.sum()
            if invalid_bool_count > 0:
                errors.append(f"Field '{field_name}' has {invalid_bool_count} non-boolean values")
        
        return errors
    
    def validate_output_data(self, output_df: pd.DataFrame, mapping_rules: List[Dict], 
                           file_type: str) -> Tuple[bool, List[str]]:
        """
        Validate transformed output data
        
        Args:
            output_df: Output DataFrame
            mapping_rules: List of mapping rules
            file_type: Type of file being processed
            
        Returns:
            Tuple of (is_valid, error_messages)
        """
        errors = []
        warnings = []
        
        # Check that all expected CSOD fields are present
        expected_csod_fields = [rule.get('CSOD Field Name', '') for rule in mapping_rules]
        missing_csod_fields = set(expected_csod_fields) - set(output_df.columns)
        if missing_csod_fields:
            errors.append(f"Missing expected CSOD fields in output: {list(missing_csod_fields)}")
        
        # Check for mandatory fields in output
        for rule in mapping_rules:
            csod_field = rule.get('CSOD Field Name', '')
            mandatory = rule.get('mandatory', '') == 'Mandatory'
            
            if csod_field in output_df.columns and mandatory:
                empty_mask = output_df[csod_field].isna() | (output_df[csod_field].astype(str).str.strip() == '')
                empty_count = empty_mask.sum()
                if empty_count > 0:
                    errors.append(f"Mandatory output field '{csod_field}' has {empty_count} empty values")
        
        # Check for NaN values in output
        nan_columns = output_df.columns[output_df.isna().any()].tolist()
        if nan_columns:
            warnings.append(f"Output contains NaN values in columns: {nan_columns}")
        
        self.validation_errors.extend(errors)
        self.validation_warnings.extend(warnings)
        
        return len(errors) == 0, errors
    
    def generate_validation_report(self, file_type: str) -> Dict[str, Any]:
        """Generate a comprehensive validation report"""
        report = {
            'file_type': file_type,
            'timestamp': datetime.now().isoformat(),
            'summary': {
                'total_errors': len(self.validation_errors),
                'total_warnings': len(self.validation_warnings),
                'is_valid': len(self.validation_errors) == 0
            },
            'errors': self.validation_errors,
            'warnings': self.validation_warnings
        }
        
        return report
    
    def clear_validation_results(self):
        """Clear all validation results"""
        self.validation_errors = []
        self.validation_warnings = []
    
    def log_validation_summary(self):
        """Log validation summary"""
        if self.validation_errors:
            self.logger.error(f"Validation completed with {len(self.validation_errors)} errors:")
            for error in self.validation_errors:
                self.logger.error(f"  - {error}")
        
        if self.validation_warnings:
            self.logger.warning(f"Validation completed with {len(self.validation_warnings)} warnings:")
            for warning in self.validation_warnings:
                self.logger.warning(f"  - {warning}")
        
        if not self.validation_errors and not self.validation_warnings:
            self.logger.info("Validation completed successfully with no errors or warnings") 