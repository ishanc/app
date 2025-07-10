import mysql.connector
import logging
import traceback
from datetime import datetime
from typing import Optional
import sys
import pandas as pd

class ErrorLogger:
    """
    Centralized error logging system that stores errors in MySQL database.
    Follows industry best practices for error logging and categorization.
    """
    
    # Database configuration
    DB_CONFIG = {
        'host': 'localhost',
        'user': 'error_logger',
        'password': 'IerpAgents.com1%',
        'database': 'error_logging',
        'port': 3306
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
        'TRUNCATION': 'Field value exceeds character length limit',
        'LEADING_SPACES': 'Field value has leading whitespace',
        'TRAILING_SPACES': 'Field value has trailing whitespace',
        'ENCODING_ISSUE': 'Field value contains invalid characters',
        'MANDATORY_EMPTY': 'Mandatory field is empty or null',
        'DATE_FORMAT': 'Invalid date/time format',
        'LEADING_ZEROS': 'Numeric field has unwanted leading zeros',
        'INVALID_FORMAT': 'Field value does not match expected format'
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
                cls._get_logger().info("Successfully connected to MySQL error logging database")
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
            timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
            stack_trace TEXT,
            INDEX idx_category (error_category),
            INDEX idx_timestamp (timestamp),
            INDEX idx_file (file_name)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
        """
        
        try:
            connection = cls._get_db_connection()
            if connection:
                cursor = connection.cursor()
                cursor.execute(create_table_sql)
                connection.commit()
                cursor.close()
                cls._get_logger().info("Error logging table created/verified successfully")
            else:
                cls._get_logger().error("Cannot create error table - no database connection")
        except mysql.connector.Error as e:
            cls._get_logger().error(f"Failed to create error logging table: {str(e)}")
    
    @classmethod
    def log_error(cls, category: str, message: str, file_name: Optional[str] = None, 
                  line_number: Optional[int] = None, include_stack_trace: bool = True):
        """
        Log an error to the MySQL database.
        
        Args:
            category: Error category (must be one of ERROR_CATEGORIES keys)
            message: Error message
            file_name: Name of the file where error occurred
            line_number: Line number where error occurred
            include_stack_trace: Whether to include stack trace in log
        """
        # Validate category
        if category not in cls.ERROR_CATEGORIES:
            category = 'SYSTEM'  # Default to SYSTEM if invalid category
        
        # Get stack trace if requested
        stack_trace = None
        if include_stack_trace:
            try:
                stack_trace = ''.join(traceback.format_stack())
            except:
                stack_trace = "Unable to capture stack trace"
        
        # Prepare file name
        if file_name is None:
            file_name = "unknown"
        
        # Log to console first (for immediate visibility)
        logger = cls._get_logger()
        logger.error(f"[{category}] {message} - File: {file_name}, Line: {line_number}")
        
        # Try to log to database
        try:
            connection = cls._get_db_connection()
            if connection:
                # Ensure table exists, check flag first 
                if not cls._table_verified:
                    cls._create_error_table()
                    cls._table_verified = True
                
                
                # Insert error record
                insert_sql = """
                INSERT INTO error_logs (message, file_name, line_number, error_category, stack_trace)
                VALUES (%s, %s, %s, %s, %s)
                """
                
                cursor = connection.cursor()
                cursor.execute(insert_sql, (message, file_name, line_number, category, stack_trace))
                connection.commit()
                cursor.close()
                
                logger.debug(f"Error logged to database successfully")
            else:
                logger.error("Failed to log error to database - no database connection")
                
        except mysql.connector.Error as e:
            logger.error(f"Failed to log error to database: {str(e)}")
        except Exception as e:
            logger.error(f"Unexpected error while logging to database: {str(e)}")
    
    @classmethod
    def log_exception(cls, category: str, exception: Exception, file_name: Optional[str] = None, 
                     line_number: Optional[int] = None):
        """
        Log an exception with full details.
        
        Args:
            category: Error category
            exception: The exception object
            file_name: Name of the file where exception occurred
            line_number: Line number where exception occurred
        """
        message = f"Exception: {type(exception).__name__}: {str(exception)}"
        stack_trace = ''.join(traceback.format_exception(type(exception), exception, exception.__traceback__))
        
        # Log to console
        logger = cls._get_logger()
        logger.error(f"[{category}] {message}", exc_info=True)
        
        # Try to log to database
        try:
            connection = cls._get_db_connection()
            if connection:
                # Ensure table exists, check flag first 
                if not cls._table_verified:
                    cls._create_error_table()
                    cls._table_verified = True
                
                # Insert error record
                insert_sql = """
                INSERT INTO error_logs (message, file_name, line_number, error_category, stack_trace)
                VALUES (%s, %s, %s, %s, %s)
                """
                
                cursor = connection.cursor()
                cursor.execute(insert_sql, (message, file_name, line_number, category, stack_trace))
                connection.commit()
                cursor.close()
                
                logger.debug(f"Exception logged to database successfully")
            else:
                logger.error("Failed to log exception to database - no database connection")
                
        except mysql.connector.Error as e:
            logger.error(f"Failed to log exception to database: {str(e)}")
        except Exception as e:
            logger.error(f"Unexpected error while logging exception to database: {str(e)}")
    
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
                SELECT error_id, message, file_name, line_number, error_category, 
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
                SELECT error_id, message, file_name, line_number, error_category, 
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
                cls._logger.info("MySQL error logging connection test successful")
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
    
    @classmethod
    def _get_queue_lock(cls):
        """Get or create thread lock for queue operations"""
        if cls._queue_lock is None:
            import threading
            cls._queue_lock = threading.Lock()
        return cls._queue_lock
    
    @classmethod
    def queue_validation_error(cls, error_type: str, field_name: str, row_number: int, 
                              value: str, max_length: int = None, expected_format: str = None):
        """
        Queue a validation error for batch processing.
        
        Args:
            error_type: Type of validation error (from VALIDATION_ERROR_TYPES)
            field_name: Name of the field with the error
            row_number: Row number where error occurred
            value: The problematic value
            max_length: Maximum allowed length (for truncation errors)
            expected_format: Expected format (for date/format errors)
        """
        if error_type not in cls.VALIDATION_ERROR_TYPES:
            error_type = 'INVALID_FORMAT'
        
        error_details = {
            'category': 'VALIDATION',
            'error_type': error_type,
            'field_name': field_name,
            'row_number': row_number,
            'value': str(value)[:500] if value else '',  # Limit value length
            'max_length': max_length,
            'expected_format': expected_format,
            'timestamp': datetime.now(),
            'file_name': 'unknown',
            'line_number': None
        }
        
        with cls._get_queue_lock():
            cls._error_queue.append(error_details)
        
        # Log to console immediately for visibility
        logger = cls._get_logger()
        message = cls._format_validation_message(error_details)
        logger.error(f"[VALIDATION] {message}")
    
    @classmethod
    def _format_validation_message(cls, error_details: dict) -> str:
        """Format validation error message for logging"""
        error_type = error_details['error_type']
        field_name = error_details['field_name']
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
            return f"Field '{field_name}' at row {row_number} has invalid format. Value: '{value}'"
    
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
        logger.info(f"Processing {len(errors_to_process)} queued validation errors")
        
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
            INSERT INTO error_logs (message, file_name, line_number, error_category, stack_trace)
            VALUES (%s, %s, %s, %s, %s)
            """
            
            # Process each error in the batch
            for error_details in error_batch:
                message = cls._format_validation_message(error_details)
                file_name = error_details.get('file_name', 'unknown')
                line_number = error_details.get('line_number')
                category = error_details['category']
                stack_trace = None
                
                cursor.execute(insert_sql, (message, file_name, line_number, category, stack_trace))
            
            # Commit the entire batch
            connection.commit()
            cursor.close()
            
            logger = cls._get_logger()
            logger.debug(f"Successfully processed batch of {len(error_batch)} validation errors")
            
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
                      char_length: str = '', mandatory: bool = False):
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
            cls._validate_mandatory_field(field_name, field_values)
        
        # Validate character length (truncation)
        if char_length and char_length.isdigit():
            cls._validate_truncation(field_name, field_values, int(char_length))
        
        # Validate encoding for text fields
        if field_type == 'Char':
            cls._validate_encoding(field_name, field_values)
    
    @classmethod
    def _validate_mandatory_field(cls, field_name: str, field_values: pd.Series):
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
                    cls.queue_validation_error('MANDATORY_EMPTY', field_name, idx, '')
        except Exception as e:
            # Log the error but don't crash the validation
            logger = cls._get_logger()
            logger.warning(f"Mandatory field validation failed for field '{field_name}': {str(e)}")
    
    @classmethod
    def _validate_truncation(cls, field_name: str, field_values: pd.Series, max_length: int):
        """Validate field values don't exceed character length"""
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
                        cls.queue_validation_error('TRUNCATION', field_name, idx, original_value, max_length)
                    except KeyError:
                        # Skip if index doesn't exist
                        continue
        except Exception as e:
            # Log the error but don't crash the validation
            logger = cls._get_logger()
            logger.warning(f"Truncation validation failed for field '{field_name}': {str(e)}")
    
    @classmethod
    def _validate_encoding(cls, field_name: str, field_values: pd.Series):
        """Validate text fields don't contain invalid characters"""
        try:
            encoding_issues_mask = field_values.astype(str).apply(
                lambda x: x and not x.isascii()
            )
            if encoding_issues_mask.any():
                # Get the problematic indices safely
                problematic_indices = encoding_issues_mask[encoding_issues_mask].index
                for idx in problematic_indices:
                    # Skip empty string indices
                    if idx == '':
                        continue
                    try:
                        original_value = field_values.at[idx]
                        cls.queue_validation_error('ENCODING_ISSUE', field_name, idx, original_value)
                    except KeyError:
                        # Skip if index doesn't exist
                        continue
        except Exception as e:
            # Log the error but don't crash the validation
            logger = cls._get_logger()
            logger.warning(f"Encoding validation failed for field '{field_name}': {str(e)}")
 
   