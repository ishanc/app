import mysql.connector
import logging
import traceback
from datetime import datetime
from typing import Optional
import sys
import pandas as pd
from column_meta_data import ColumnMetaData

class ErrorLogger:
    """
    Centralized error logging system that stores errors in MySQL database.
    Follows industry best practices for error logging and categorization.
    """
    
    # Database configuration- this needs to be corrected when pushed to AWS/ production. 
    
    DB_CONFIG = {
        'host': 'localhost',
        'user': 'error_logger',
        'password': 'IerpAgents.com1%',
        'database': 'error_logging',
        'port': 3306,
        'ssl_disabled': True,
        'autocommit': False,
        'connect_timeout': 30,
        'use_unicode': True
    }
    
    # Error categories
    ERROR_CATEGORIES = {
        'VALIDATION': 'Data validation errors',
        'TRANSFORMATION': 'Data transformation errors', 
        'DATABASE': 'Database connection/query errors',
        'FILE_PROCESSING': 'File reading/writing errors',
        'NEO4J': 'Neo4j database errors',
        'CONFIGURATION': 'Configuration/setup errors',
        'SYSTEM': 'System/application errors'
    }
    
    # Validation error types
    VALIDATION_ERROR_TYPES = {
        'TRUNCATION': 'Field value exceeds character length limit', #Source file error
        'LEADING_SPACES': 'Field value has leading whitespace',#can fix in code/ workshop agent. 
        'TRAILING_SPACES': 'Field value has trailing whitespace',#can fix in workshop agent
        'ENCODING_ISSUE': 'Field value contains invalid characters',#source 
        'MANDATORY_EMPTY': 'Mandatory field is empty or null',#source/ workshop 
        'DATE_FORMAT': 'Invalid date/time format',#workshop depends on target format
        'LEADING_ZEROS': 'Numeric field has unwanted leading zeros',#workshop confirmation
        'DUPLICATE_RECORD': 'Duplicate record found',# need to implement logic for this. 
        'HETEROGENEOUS_TYPE': 'Field contains heterogeneous data types',#workshop confirmation 
        'OUTLIER_VALUE': 'Field value is an outlier', #date cannot be too much of an outlier. percentage cannot be more than 100% 
        'TYPE_COMPATIBILITY': 'Field value is not type compatible', #compatability issue inside workshop, right parameters/logic. 
        'BOOLEAN_CONVERSION': 'Boolean value transformation issue', #transformation validation workshop trasnformation
        'HEADER_INCONSISTENCY': 'File header/structure inconsistency',#workshop confirmation
        'DELIMITER_ISSUE': 'File delimiter/structure issue',#add logic for this. 
        'COMPLETENESS_SCORE': 'Data completeness issue'#output into the error field. report to the user. As a percentage, use as a test metric. 
    }
    
    _logger = None
    _db_connection = None
    
    @classmethod
    def _get_logger(cls):
        """Get or create logger instance"""
        if cls._logger is None:
            cls._logger = logging.getLogger(__name__)
            if not cls._logger.handlers:
                handler = logging.StreamHandler()
                formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
                handler.setFormatter(formatter)
                cls._logger.addHandler(handler)
                cls._logger.setLevel(logging.INFO)
        return cls._logger
    
    @classmethod
    def _get_db_connection(cls):
        """Get or create database connection"""
        try:
            if cls._db_connection is None or not cls._db_connection.is_connected():
                cls._db_connection = mysql.connector.connect(**cls.DB_CONFIG)
                # cls._get_logger().info("Successfully connected to MySQL error logging database")  # Reduced logging
            return cls._db_connection
        except mysql.connector.Error as e:
            cls._get_logger().error(f"Failed to connect to MySQL error logging database: {str(e)}")
            return None
    
    @classmethod
    def _create_error_table(cls):
        """Create error logging table if it doesn't exist"""
        create_table_sql = """
        CREATE TABLE IF NOT EXISTS error_logs (
            error_id INT AUTO_INCREMENT PRIMARY KEY,
            message TEXT NOT NULL,
            file_name VARCHAR(255),
            line_number INT,
            error_category VARCHAR(50) NOT NULL,
            validation_type VARCHAR(50),
            timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
            stack_trace TEXT,
            INDEX idx_category (error_category),
            INDEX idx_timestamp (timestamp),
            INDEX idx_file (file_name),
            INDEX idx_validation_type (validation_type)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
        """
        
        try:
            connection = cls._get_db_connection()
            if connection:
                cursor = connection.cursor()
                cursor.execute(create_table_sql)
                connection.commit()
                cursor.close()
                # cls._get_logger().info("Error logging table created/verified successfully")  # Reduced logging
            else:
                cls._get_logger().error("Cannot create error table - no database connection")
        except mysql.connector.Error as e:
            cls._get_logger().error(f"Failed to create error logging table: {str(e)}")
    

    
   
    @classmethod
    def get_errors_by_validation_type(cls, validation_type: str, limit: int = 100) -> list:
        """
        Retrieve validation types from database.
        
        Args:
            validation_type: Validation type to filter by
            limit: Maximum number of records to return
            
        Returns:
            List of validation types
        """
        try:
            connection = cls._get_db_connection()
            if connection:
                cursor = connection.cursor(dictionary=True)
                query = """
                SELECT error_id, message, file_name, line_number, error_category, validation_type, timestamp, stack_trace
                FROM error_logs
                WHERE validation_type = %s
                ORDER BY timestamp DESC
                LIMIT %s
                """
                cursor.execute(query, (validation_type, limit))
                results = cursor.fetchall()
                cursor.close()
                return results
            else:
                cls._logger.error("Cannot retrieve validation types")
                return []
        except mysql.connector.Error as e:
            cls._logger.error(f"Failed to retrieve validation types: {str(e)}")
            return []
   
    @classmethod
    def get_errors_by_category(cls, category: str, limit: int = 100) -> list:
        """
        Retrieve errors by category from database.
        
        Args:
            category: Error category to filter by
            limit: Maximum number of records to return
            
        Returns:
            List of error records
        """
        try:
            connection = cls._get_db_connection()
            if connection:
                cursor = connection.cursor(dictionary=True)
                query = """
                SELECT error_id, message, file_name, line_number, error_category, validation_type,
                       timestamp, stack_trace
                FROM error_logs 
                WHERE error_category = %s 
                ORDER BY timestamp DESC 
                LIMIT %s
                """
                cursor.execute(query, (category, limit))
                results = cursor.fetchall()
                cursor.close()
                return results
            else:
                cls._logger.error("Cannot retrieve errors - no database connection")
                return []
        except mysql.connector.Error as e:
            cls._logger.error(f"Failed to retrieve errors: {str(e)}")
            return []
    
    @classmethod
    def get_recent_errors(cls, hours: int = 24, limit: int = 100) -> list:
        """
        Retrieve recent errors from database.
        
        Args:
            hours: Number of hours to look back
            limit: Maximum number of records to return
            
        Returns:
            List of error records
        """
        try:
            connection = cls._get_db_connection()
            if connection:
                cursor = connection.cursor(dictionary=True)
                query = """
                SELECT error_id, message, file_name, line_number, error_category, validation_type,
                       timestamp, stack_trace
                FROM error_logs 
                WHERE timestamp >= DATE_SUB(NOW(), INTERVAL %s HOUR)
                ORDER BY timestamp DESC 
                LIMIT %s
                """
                cursor.execute(query, (hours, limit))
                results = cursor.fetchall()
                cursor.close()
                return results
            else:
                cls._logger.error("Cannot retrieve errors - no database connection")
                return []
        except mysql.connector.Error as e:
            cls._logger.error(f"Failed to retrieve errors: {str(e)}")
            return []
    
    @classmethod
    def close_connection(cls):
        """Close the database connection"""
        try:
            if cls._db_connection and cls._db_connection.is_connected():
                cls._db_connection.close()
                cls._logger.info("MySQL error logging connection closed")
        except Exception as e:
            cls._logger.error(f"Error closing database connection: {str(e)}")
    
    @classmethod
    def test_connection(cls) -> bool:
        """Test the database connection"""
        try:
            connection = cls._get_db_connection()
            if connection:
                cursor = connection.cursor()
                cursor.execute("SELECT 1")
                cursor.fetchone()
                cursor.close()
                # cls._logger.info("MySQL error logging connection test successful")  # Reduced logging
                return True
            else:
                cls._logger.error("MySQL error logging connection test failed")
                return False
        except Exception as e:
            cls._logger.error(f"MySQL error logging connection test failed: {str(e)}")
            return False 
        
    # Add table verified = False class variable
    _table_verified = False
    
    # Queue for batch error processing
    _error_queue = []
    _queue_lock = None
    #Error type counting
    _error_type_counts = {}
    
    
    
    @classmethod
    def _get_queue_lock(cls):
        """Get or create thread lock for queue operations"""
        if cls._queue_lock is None:
            import threading
            cls._queue_lock = threading.Lock()
        return cls._queue_lock
    
    
    #method to return all current counts of error types
    @classmethod
    def get_error_type_counts(cls):
        """
        Get the current counts of all error types.
        
        Returns:
            Dictionary with error type counts
        """
        #get current counts of error types
        
        #if the error type counts dictionary is empty, return an empty dictionary
        return dict(cls._error_type_counts)
    
    #method to reset the error type counts
    @classmethod
    def reset_error_type_counts(cls):
        """
        Reset all error type counts. Useful between file processing turns. """
        cls._error_type_counts.clear()
    
    #method to get the count of a specific error type
    @classmethod
    def get_error_count(cls, error_type: str) -> int:
        """Get count for a specific error type"""
        return cls._error_type_counts.get(error_type, 0)
    
    @classmethod # made to be agnostic of the input file name. 
    def queue_validation_error(cls, error_type: str, field_name: str, row_number: int, 
                        value: str, max_length: int = None, expected_format: str = None, file_name: str = None, 
                        line_number: int = None, field_values: pd.Series = None):
        """
        Queue a validation error for batch processing.
        
        Args:
            error_type: Type of validation error (from VALIDATION_ERROR_TYPES)
            field_name: Name of the field with the error
            row_number: Row number where error occurred
            value: The problematic value
            max_length: Maximum allowed length (for truncation errors)
            expected_format: Expected format (for date/format errors)
            field_values: Pandas Series containing the field values (for checking input field name)
        """
        if error_type not in cls.VALIDATION_ERROR_TYPES:
            raise ValueError(f"Invalid error type '{error_type}'. Must be one of: {list(cls.VALIDATION_ERROR_TYPES.keys())}")
        
        # Use SumTotal field name if available, otherwise use the provided field name
        display_field_name = field_name
        if field_values is not None and hasattr(field_values, 'attrs'):
            if 'input_field_name' in field_values.attrs and field_values.attrs['input_field_name']:
                display_field_name = field_values.attrs['input_field_name']
        
        #Increment error count
        cls._error_type_counts[error_type] = cls._error_type_counts.get(error_type, 0) + 1
        
        error_details = { 
            'category': 'VALIDATION',
            'error_type': error_type,
            'field_name': display_field_name,
            'row_number': row_number,
            'value': str(value)[:500] if value else '',  # Limit value length
            'max_length': max_length,
            'expected_format': expected_format,
            'timestamp': datetime.now(),
            'file_name': file_name,
            'line_number': row_number + 1 if row_number is not None else None  # Convert to 1-based file line number
        }
        
        with cls._get_queue_lock():
            cls._error_queue.append(error_details)
        
        # Log to console immediately for visibility - DISABLED to reduce console spam
        # logger = cls._get_logger()
        # message = cls._format_validation_message(error_details)
        # logger.error(f"[VALIDATION] {message}")  # Validation errors still stored in DB for reports
    
    @classmethod
    def _format_validation_message(cls, error_details: dict) -> str:
        """Format validation error message for logging"""
        error_type = error_details['error_type']
        field_name = error_details['field_name']  # This is now the display_field_name (SumTotal name)
        row_number = error_details['row_number']
        value = error_details['value']
        
        if error_type == 'TRUNCATION':
            max_length = error_details.get('max_length', 'unknown')
            return f"Field '{field_name}' at row {row_number} exceeded char_length {max_length}. Value: '{value}'"
        elif error_type == 'LEADING_SPACES':
            return f"Field '{field_name}' at row {row_number} has leading spaces. Value: '{value}'"
        elif error_type == 'TRAILING_SPACES':
            return f"Field '{field_name}' at row {row_number} has trailing spaces. Value: '{value}'"
        elif error_type == 'ENCODING_ISSUE':
            return f"Field '{field_name}' at row {row_number} contains invalid characters. Value: '{value}'"
        elif error_type == 'MANDATORY_EMPTY':
            return f"Mandatory field '{field_name}' at row {row_number} is empty"
        elif error_type == 'DATE_FORMAT':
            expected_format = error_details.get('expected_format', 'unknown')
            return f"Field '{field_name}' at row {row_number} has invalid date format. Expected: {expected_format}, Value: '{value}'"
        elif error_type == 'LEADING_ZEROS':
            return f"Field '{field_name}' at row {row_number} has unwanted leading zeros. Value: '{value}'"
        else:
            # No fallback - only specific error types are allowed
            return f"Field '{field_name}' at row {row_number} has validation error type '{error_type}'. Value: '{value}'" 
    
    @classmethod
    def process_error_queue(cls, batch_size: int = 100):
        """
        Process all queued errors in batches.
        
        Args:
            batch_size: Number of errors to process in each batch
        """
        with cls._get_queue_lock():
            if not cls._error_queue:
                return
            
            # Get all queued errors
            errors_to_process = cls._error_queue.copy()
            cls._error_queue.clear()
        
        logger = cls._get_logger()
        # logger.info(f"Processing {len(errors_to_process)} queued validation errors")  # Reduced logging
        
        # Process errors in batches
        for i in range(0, len(errors_to_process), batch_size):
            batch = errors_to_process[i:i + batch_size]
            cls._process_error_batch(batch)
    
    @classmethod
    def _process_error_batch(cls, error_batch: list):
        """Process a batch of errors in a single database transaction"""
        try:
            connection = cls._get_db_connection()
            if not connection:
                logger = cls._get_logger()
                logger.error("Cannot process error batch - no database connection")
                return
            
            cursor = connection.cursor()
            
            # Prepare batch insert
            insert_sql = """
            INSERT INTO error_logs (message, file_name, line_number, error_category, validation_type, stack_trace)
            VALUES (%s, %s, %s, %s, %s, %s)
            """
            
            # Process each error in the batch
            for error_details in error_batch:
                message = cls._format_validation_message(error_details)
                file_name = error_details.get('file_name', 'unknown')
                line_number = error_details.get('line_number')
                category = error_details['category']
                stack_trace = None
                
                cursor.execute(insert_sql, (message, file_name, line_number,category,error_details['error_type'], stack_trace))
            
            # Commit the entire batch
            connection.commit()
            cursor.close()
            
            logger = cls._get_logger()
            # logger.debug(f"Successfully processed batch of {len(error_batch)} validation errors")  # Reduced logging
            
        except mysql.connector.Error as e:
            logger = cls._get_logger()
            logger.error(f"Failed to process error batch: {str(e)}")
        except Exception as e:
            logger = cls._get_logger()
            logger.error(f"Unexpected error processing batch: {str(e)}")
    
    @classmethod
    def get_queue_size(cls) -> int:
        """Get the current size of the error queue"""
        with cls._get_queue_lock():
            return len(cls._error_queue)
    
    @classmethod
    def clear_queue(cls):
        """Clear all queued errors (use with caution)"""
        with cls._get_queue_lock():
            cls._error_queue.clear()
    
    @classmethod 
    def validate_field(cls, field_name: str, field_values: pd.Series, field_type: str = '', 
                      char_length: str = '', mandatory: bool = False, file_name : str = None):
        """
        Comprehensive field validation - handles all validation types
        
        Args:
            field_name: Name of the field being validated
            field_values: Pandas Series containing field values
            field_type: Type of field (Char, Integer, Decimal, Date and Time, etc.)
            char_length: Maximum character length for text fields
            mandatory: Whether the field is mandatory
        """
        # Validate mandatory fields
        if mandatory:
            cls._validate_mandatory_field(field_name, field_values, file_name)
        
        # Validate character length (truncation)
        if char_length and char_length.isdigit():
            cls._validate_truncation(field_name, field_values, int(char_length), file_name)
        
        # Validate encoding for text fields
        if field_type == 'Char':
            cls._validate_encoding(field_name, field_values, file_name)
    
#--VALIDATION METHODS--
    #method to detect outliers
    @classmethod
    def detect_outliers(cls, field_name: str, field_values: pd.Series, file_name: str = None, method: str = 'iqr'):
        """Detect outlier values using IQR or z-score method, dates needed to be added. 
        """ 
        try:
            numeric_values = pd.to_numeric(field_values, errors='coerce').dropna()
            if len(numeric_values) < 3:
                return
            
            if method == 'iqr':
                q1, q3 = numeric_values.quantile([0.25, 0.75])
                iqr = q3 - q1
                lower_bound = q1 - 1.5 * iqr
                upper_bound = q3 + 1.5 * iqr
                outlier_mask = (numeric_values < lower_bound) | (numeric_values > upper_bound)
            else:  # z-score
                z_scores = abs((numeric_values - numeric_values.mean()) / numeric_values.std())
                outlier_mask = z_scores > 3
            
            outlier_indices = numeric_values[outlier_mask].index
            for idx in outlier_indices:
                cls.queue_validation_error('OUTLIER_VALUE', field_name, idx, numeric_values.loc[idx], file_name=file_name, line_number=idx, field_values=field_values)
        except Exception as e:
            cls._get_logger().warning(f"Outlier detection failed for field '{field_name}': {str(e)}")
    
    @classmethod
    def detect_heterogeneous_types(cls, field_name: str, field_values: pd.Series, file_name: str = None):
        """Detect true heterogeneous data when fundamentally different data types are mixed in"""
        try:
            # Single pass collection
            pure_numeric = []
            text_based = []
            
            # Main processing loop
            for idx, value in field_values.items():
                if pd.notna(value) and (str_val := str(value).strip()):
                    if str_val.isdigit():
                        pure_numeric.append((idx, str_val))
                    else:
                        text_based.append((idx, str_val))
            
            total = len(pure_numeric) + len(text_based)
            if total == 0:
                return 
            
            # Calculate percentages
            numeric_pct = len(pure_numeric) / total
            text_pct = len(text_based) / total
            
            # Only flag if we have a significant mix (not 95%+ of one type)
            if 0.05 < numeric_pct < 0.95:  # Between 5% and 95% numeric
                cls._get_logger().info(
                    f"Column '{field_name}' has mixed types: "
                    f"{numeric_pct:.1%} numeric, {text_pct:.1%} text"
                )
                
                # Determine minority type to flag as errors
                if numeric_pct < text_pct:
                    # Numeric values are the minority - flag them
                    for idx, val in pure_numeric:
                        cls.queue_validation_error(
                            'HETEROGENEOUS_TYPE', field_name, idx, val,
                            file_name=file_name, line_number=idx, field_values=field_values
                        )
                else:
                    # Text values are the minority - flag them
                    for idx, val in text_based:
                        cls.queue_validation_error(
                            'HETEROGENEOUS_TYPE', field_name, idx, val,
                            file_name=file_name, line_number=idx, field_values=field_values
                        )
                    
        except Exception as e:
            cls._get_logger().warning(f"Heterogeneous type detection failed for field '{field_name}': {str(e)}")
    
    @classmethod
    def detect_leading_spaces(cls, field_name: str, field_values: pd.Series, file_name: str = None):
        """Detect leading spaces in text fields"""
        try:
            leading_mask = field_values.astype(str).str.match(r'^\s+')
            for idx in field_values[leading_mask].index:
                cls.queue_validation_error('LEADING_SPACES', field_name, idx, field_values.loc[idx], file_name=file_name, line_number=idx, field_values=field_values)
        except Exception as e:
            cls._get_logger().warning(f"Leading spaces detection failed for field '{field_name}': {str(e)}")
    
    @classmethod
    def detect_trailing_spaces(cls, field_name: str, field_values: pd.Series, file_name: str = None):
        """Detect trailing spaces in text fields"""
        try:
            trailing_mask = field_values.astype(str).str.match(r'.*\s+$')
            for idx in field_values[trailing_mask].index:
                cls.queue_validation_error('TRAILING_SPACES', field_name, idx, field_values.loc[idx], file_name=file_name, line_number=idx, field_values=field_values)
        except Exception as e:
            cls._get_logger().warning(f"Trailing spaces detection failed for field '{field_name}': {str(e)}")
    
    @classmethod
    def detect_date_format_issues(cls, field_name: str, field_values: pd.Series, expected_format: str = None, file_name: str = None):
        """Detect invalid date formats"""
        try:
            for idx, value in field_values.items():
                if pd.notna(value) and str(value).strip():
                    try:
                        pd.to_datetime(value)
                    except:
                        cls.queue_validation_error('DATE_FORMAT', field_name, idx, value, expected_format=expected_format, file_name=file_name, line_number=idx, field_values=field_values)
        except Exception as e:
            cls._get_logger().warning(f"Date format detection failed for field '{field_name}': {str(e)}")
    
    @classmethod
    def detect_leading_zeros(cls, field_name: str, field_values: pd.Series, file_name: str = None):
        """Detect unwanted leading zeros in numeric fields"""
        try:
            for idx, value in field_values.items():
                if pd.notna(value) and str(value).startswith('0') and len(str(value)) > 1:
                    try:
                        int(value)  # Check if it's actually numeric
                        cls.queue_validation_error('LEADING_ZEROS', field_name, idx, value, file_name=file_name, line_number=idx, field_values=field_values)
                    except ValueError:
                        pass  # Not numeric, skip
        except Exception as e:
            cls._get_logger().warning(f"Leading zeros detection failed for field '{field_name}': {str(e)}")
    
    @classmethod
    def detect_type_compatibility(cls, field_name: str, field_values: pd.Series, expected_type: str, file_name: str = None):
        """Detect type compatibility issues"""
        try:
            if expected_type == 'integer':
                non_int_mask = pd.to_numeric(field_values, errors='coerce').isna()
                for idx in field_values[non_int_mask].index:
                    cls.queue_validation_error('TYPE_COMPATIBILITY', field_name, idx, field_values.loc[idx], file_name=file_name, line_number=idx, field_values=field_values)
            elif expected_type == 'decimal':
                non_num_mask = pd.to_numeric(field_values, errors='coerce').isna()
                for idx in field_values[non_num_mask].index:
                    cls.queue_validation_error('TYPE_COMPATIBILITY', field_name, idx, field_values.loc[idx], file_name=file_name, line_number=idx, field_values=field_values)
        except Exception as e:
            cls._get_logger().warning(f"Type compatibility detection failed for field '{field_name}': {str(e)}")
    
    @classmethod
    def detect_boolean_conversion_issues(cls, field_name: str, field_values: pd.Series, file_name: str = None):
        """Detect boolean conversion issues"""
        try:
            valid_bools = ['true', 'false', '1', '0', 'yes', 'no', 'y', 'n', 't', 'f']
            invalid_bool_mask = ~field_values.astype(str).str.lower().isin(valid_bools)
            for idx in field_values[invalid_bool_mask].index:
                if pd.notna(field_values.loc[idx]) and str(field_values.loc[idx]).strip():
                    cls.queue_validation_error('BOOLEAN_CONVERSION', field_name, idx, field_values.loc[idx], file_name=file_name, line_number=idx, field_values=field_values)
        except Exception as e:
            cls._get_logger().warning(f"Boolean conversion detection failed for field '{field_name}': {str(e)}")
    
    @classmethod
    def detect_header_inconsistency(cls, df: pd.DataFrame, expected_headers: list = None, file_name: str = None):
        """Detect header/structure inconsistencies"""#delimiter issue, record terminator - file structure and consistency error
        try:
            if expected_headers:
                missing_headers = set(expected_headers) - set(df.columns)
                extra_headers = set(df.columns) - set(expected_headers)
                if missing_headers or extra_headers:
                    cls.queue_validation_error('HEADER_INCONSISTENCY', 'HEADERS', 0, f"Missing: {missing_headers}, Extra: {extra_headers}", file_name=file_name, line_number=0)
        except Exception as e:
            cls._get_logger().warning(f"Header inconsistency detection failed: {str(e)}")
    
    @classmethod
    def calculate_completeness_score(cls, df: pd.DataFrame, mandatory_fields: list = None, file_name: str = None):#object by unique identifier file going by record 
        """Calculate and log data completeness score"""
        try:
            if mandatory_fields:
                completeness_scores = {}
                for field in mandatory_fields:
                    if field in df.columns:
                        non_empty_count = df[field].notna().sum()
                        total_count = len(df)
                        completeness = non_empty_count / total_count if total_count > 0 else 0
                        completeness_scores[field] = completeness
                        
                        if completeness < 0.9:  # Log if completeness is below 90%
                            cls.queue_validation_error('COMPLETENESS_SCORE', field, 0, f"Completeness: {completeness:.2%}", file_name=file_name, line_number=0)
            else:
                # Overall completeness
                total_cells = df.size
                non_empty_cells = df.notna().sum().sum()
                overall_completeness = non_empty_cells / total_cells if total_cells > 0 else 0
                
                if overall_completeness < 0.8:  # Log if overall completeness is below 80%
                    cls.queue_validation_error('COMPLETENESS_SCORE', 'OVERALL', 0, f"Overall completeness: {overall_completeness:.2%}", file_name=file_name, line_number=0)
        except Exception as e:
            cls._get_logger().warning(f"Completeness score calculation failed: {str(e)}")
    
    @classmethod
    def comprehensive_validation(cls, df: pd.DataFrame, field_configs: dict = None, file_name: str = None):
        """Run comprehensive validation on entire DataFrame"""
        try:
            for col in df.columns:
                field_config = field_configs.get(col, {}) if field_configs else {}
                
                # Basic validations
                cls.validate_field(
                    col, df[col], 
                    field_config.get('field_type', ''),
                    field_config.get('char_length', ''),
                    field_config.get('mandatory', False),
                    file_name
                )
                
                # Additional validations
                if field_config.get('check_outliers', False):
                    cls.detect_outliers(col, df[col], file_name)
                
                if field_config.get('check_heterogeneous', False):
                    cls.detect_heterogeneous_types(col, df[col], file_name)
                
                if field_config.get('field_type') == 'Char':
                    cls.detect_leading_spaces(col, df[col], file_name)
                    cls.detect_trailing_spaces(col, df[col], file_name)
                
                if field_config.get('field_type') in ['date', 'datetime']:
                    cls.detect_date_format_issues(col, df[col], field_config.get('date_format'), file_name)
                
                if field_config.get('field_type') in ['integer', 'decimal']:
                    cls.detect_leading_zeros(col, df[col], file_name)
                    cls.detect_type_compatibility(col, df[col], field_config.get('field_type'), file_name)
                
                if field_config.get('field_type') == 'boolean':
                    cls.detect_boolean_conversion_issues(col, df[col], file_name)
            
            # File-level validations
            if field_configs:
                mandatory_fields = [col for col, config in field_configs.items() if config.get('mandatory', False)]
                cls.calculate_completeness_score(df, mandatory_fields, file_name)
            
        except Exception as e:
            cls._get_logger().warning(f"Comprehensive validation failed: {str(e)}") 
        
    @classmethod
    def _validate_mandatory_field(cls, field_name: str, field_values: pd.Series, file_name: str = None):
        """Validate mandatory fields are not empty"""
        try:
            empty_mask = (field_values.isna() | (field_values.astype(str).str.strip() == ''))
            if empty_mask.any():
                # Get the problematic indices safely
                problematic_indices = field_values[empty_mask].index
                for idx in problematic_indices:
                    # Skip empty string indices
                    if idx == '':
                        continue
                    cls.queue_validation_error('MANDATORY_EMPTY', field_name, idx, '', file_name = file_name, line_number = idx, field_values=field_values)
        except Exception as e:
            # Log the error but don't crash the validation
            logger = cls._get_logger()
            logger.warning(f"Mandatory field validation failed for field '{field_name}': {str(e)}")
    
    @classmethod
    def _validate_truncation(cls, field_name: str, field_values: pd.Series, max_length: int, file_name: str = None):
        try:
            too_long_mask = field_values.astype(str).str.len() > max_length
            if too_long_mask.any():
                # Get the problematic indices safely
                problematic_indices = field_values[too_long_mask].index
                for idx in problematic_indices:
                    # Skip empty string indices
                    if idx == '':
                        continue
                    try:
                        original_value = field_values.at[idx]
                        cls.queue_validation_error('TRUNCATION', field_name, idx, original_value, max_length, file_name=file_name, line_number=idx, field_values=field_values)
                    except KeyError:
                        # Skip if index doesn't exist
                        continue
        except Exception as e:
            # Log the error but don't crash the validation
            logger = cls._get_logger()
            logger.warning(f"Truncation validation failed for field '{field_name}': {str(e)}")
    
    @classmethod
    def _validate_encoding(cls, field_name: str, field_values: pd.Series, file_name: str = None):
        """Validate text fields don't contain invalid characters"""
        try:
            # Define acceptable special characters (in addition to ASCII)
            ACCEPTABLE_SPECIAL_CHARS = {'‡'}  # Add more special characters here if needed
            
            def is_valid_character(char):
                """Check if a character is valid (ASCII or in acceptable special chars)"""
                return char.isascii() or char in ACCEPTABLE_SPECIAL_CHARS
            
            def has_invalid_chars(text):
                """Check if text contains any invalid characters"""
                if not text:
                    return False
                return not all(is_valid_character(char) for char in text)
            
            encoding_issues_mask = field_values.astype(str).apply(has_invalid_chars)
            if encoding_issues_mask.any():
                # Get the problematic indices safely
                problematic_indices = encoding_issues_mask[encoding_issues_mask].index
                for idx in problematic_indices:
                    # Skip empty string indices
                    if idx == '':
                        continue
                    try:
                        original_value = field_values.at[idx]
                        cls.queue_validation_error('ENCODING_ISSUE', field_name, idx, original_value,file_name=file_name, line_number=idx, field_values=field_values)
                    except KeyError:
                        # Skip if index doesn't exist
                        continue
        except Exception as e:
            # Log the error but don't crash the validation
            logger = cls._get_logger()
            logger.warning(f"Encoding validation failed for field '{field_name}': {str(e)}") 
