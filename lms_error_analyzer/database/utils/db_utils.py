#!/usr/bin/env python3
# [MODIFIED: 2025-09-19] Reorganized file structure and cleaned up documentation
"""
Database Utilities Module

This module provides centralized database connection management and utility functions
for database operations used by both frontend and backend components.

Key Features:
- Database connection management 
- Frontend statistics retrieval
- Common database queries
- Connection pooling (future enhancement)
"""

import os
import logging
from typing import List, Dict, Any, Optional
from contextlib import contextmanager
import mysql.connector
from dotenv import load_dotenv

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)
load_dotenv()

# [MODIFIED: 2025-09-19] Enhanced class documentation and cleaned up structure
class DatabaseConnectionManager:
    """
    Manages database connections and provides common database operations.
    
    This class centralizes database connection configuration and provides
    utility methods for common database operations. It implements connection
    pooling best practices and ensures proper resource cleanup.
    
    Can be used either as a context manager or through get_connection():
    
    As context manager:
        with DatabaseConnectionManager() as conn:
            cursor = conn.cursor()
            cursor.execute("SELECT * FROM table")
            
    Using get_connection:
        with db_manager.get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("SELECT * FROM table")
    """
    
    def __init__(self):
        """Initialize database connection parameters from environment variables."""
        self.db_config = {
            'host': os.getenv('MYSQL_HOST'),
            'user': os.getenv('MYSQL_USER'),
            'password': os.getenv('MYSQL_PASSWORD'),
            'database': os.getenv('MYSQL_NAME'),
            'port': int(os.getenv('MYSQL_PORT')),
            'ssl_disabled': True,
            'connect_timeout': 30,
            'use_unicode': True
        }

    @contextmanager
    def get_connection(self, autocommit: bool = True, max_retries: int = 3, retry_delay: int = 2):
        """
        Context manager for database connections with retry logic.
        
        Args:
            autocommit (bool): Whether to enable autocommit mode
            max_retries (int): Maximum number of connection retry attempts
            retry_delay (int): Delay in seconds between retry attempts
            
        Yields:
            mysql.connector.MySQLConnection: Active database connection
            
        Example:
            with db_manager.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute("SELECT * FROM table")
        """
        connection = None
        retry_count = 0
        last_error = None

        while retry_count < max_retries:
            try:
                if connection and connection.is_connected():
                    connection.close()

                connection = mysql.connector.connect(
                    **self.db_config,
                    autocommit=autocommit,
                    connection_timeout=30,
                    get_warnings=True
                )
                
                # Test the connection
                cursor = connection.cursor()
                cursor.execute("SELECT 1")
                cursor.fetchone()
                cursor.close()
                
                yield connection
                return
            except mysql.connector.Error as e:
                last_error = e
                retry_count += 1
                logger.warning(f"Database connection attempt {retry_count} failed: {e}")
                if retry_count < max_retries:
                    import time
                    time.sleep(retry_delay)
            except Exception as e:
                logger.error(f"Unexpected database error: {e}")
                raise
            finally:
                if connection and connection.is_connected():
                    connection.close()
        
        # If we get here, all retries failed
        logger.error(f"All database connection attempts failed after {max_retries} retries")
        raise last_error if last_error else Exception("Could not establish database connection")

    def __enter__(self):
        """Enter the context manager, creating a new connection."""
        self.connection = mysql.connector.connect(
            **self.db_config,
            autocommit=True
        )
        return self.connection

    def __exit__(self, exc_type, exc_val, exc_tb):
        """Exit the context manager, closing the connection."""
        if hasattr(self, 'connection') and self.connection and self.connection.is_connected():
            self.connection.close()
            
    def execute_query(self, query: str, params: tuple = None, dictionary: bool = False) -> List[Any]:
        """
        Execute a query and return results.
        
        Args:
            query: SQL query to execute
            params: Query parameters
            dictionary: Whether to return results as dictionaries
            
        Returns:
            List of query results
        """
        with self.get_connection() as conn:
            cursor = conn.cursor(dictionary=dictionary)
            try:
                if params:
                    cursor.execute(query, params)
                else:
                    cursor.execute(query)
                return cursor.fetchall()
            finally:
                cursor.close()

def get_total_clean_records() -> int:
    """
    Get total number of clean records (records with no errors) across all files.
    These are records that are ready for transformation after data analysis.
    
    Returns:
        int: Total number of clean records across all files
    """
    db = DatabaseConnectionManager()
    try:
        # Get latest processing timestamp
        latest_result = db.execute_query(
            """
            SELECT MAX(last_processed) as latest_batch
            FROM file_completeness_summary
            """,
            dictionary=True
        )
        
        if not latest_result or not latest_result[0]['latest_batch']:
            return 0
            
        latest_batch = latest_result[0]['latest_batch']
        
        # Get the batch start time (truncate to minute to group related files)
        batch_result = db.execute_query(
            """
            SELECT DATE_FORMAT(MIN(last_processed), '%Y-%m-%d %H:%i:00') as batch_start
            FROM file_completeness_summary
            WHERE last_processed >= DATE_SUB(%s, INTERVAL 5 MINUTE)
            """,
            (latest_batch,),
            dictionary=True
        )
        
        if not batch_result or not batch_result[0]['batch_start']:
            return 0
            
        batch_start = batch_result[0]['batch_start']
        
        # Calculate clean records (total records minus records with any type of error)
        clean_result = db.execute_query(
            """
            WITH FileErrorCounts AS (
                -- Get count of distinct records with errors for each file
                SELECT 
                    fcs.file_name,
                    fcs.total_records,
                    fcs.incomplete_records,
                    COUNT(DISTINCT el.line_number) as validation_error_records
                FROM file_completeness_summary fcs
                LEFT JOIN error_logs el ON fcs.file_name = el.file_name
                WHERE fcs.last_processed >= %s
                GROUP BY fcs.file_name, fcs.total_records, fcs.incomplete_records
            )
            SELECT 
                SUM(
                    total_records - GREATEST(
                        incomplete_records,
                        validation_error_records,
                        LEAST(incomplete_records + validation_error_records, total_records)
                    )
                ) as total_clean_records
            FROM FileErrorCounts
            """,
            (batch_start,),
            dictionary=True
        )
        
        total_clean = clean_result[0]['total_clean_records'] or 0
        logger.info(f"Total clean records in batch since {batch_start}: {total_clean}")
        return total_clean
        
    except Exception as e:
        logger.error(f"Error getting total clean records: {e}")
        return 0

def get_total_records_processed() -> int:
    """
    Get total number of records processed in the latest batch.
    Sums up records from all files in the current batch.
    
    Returns:
        int: Total number of records processed across all files
    """
    db = DatabaseConnectionManager()
    try:
        # Get latest processing timestamp
        latest_result = db.execute_query(
            """
            SELECT MAX(last_processed) as latest_batch
            FROM file_completeness_summary
            """,
            dictionary=True
        )
        
        if not latest_result or not latest_result[0]['latest_batch']:
            return 0
            
        latest_batch = latest_result[0]['latest_batch']
        
        # Get the batch start time (truncate to minute to group related files)
        batch_result = db.execute_query(
            """
            SELECT DATE_FORMAT(MIN(last_processed), '%Y-%m-%d %H:%i:00') as batch_start
            FROM file_completeness_summary
            WHERE last_processed >= DATE_SUB(%s, INTERVAL 5 MINUTE)
            """,
            (latest_batch,),
            dictionary=True
        )
        
        if not batch_result or not batch_result[0]['batch_start']:
            return 0
            
        batch_start = batch_result[0]['batch_start']
        
        # Sum up records from all files processed in this batch
        total_result = db.execute_query(
            """
            SELECT SUM(total_records) as total
            FROM file_completeness_summary
            WHERE last_processed >= %s
            """,
            (batch_start,),
            dictionary=True
        )
        
        logger.info(f"Total records in batch since {batch_start}: {total_result[0]['total']}")
        return total_result[0]['total'] or 0
        
    except Exception as e:
        logger.error(f"Error getting total records processed: {e}")
        return 0

# [MODIFIED: 2025-09-19] Fixed duplicate implementation and proper function placement
# [MODIFIED: 2025-09-19] Enhanced error handling for connection issues
def get_total_error_prone_records() -> int:
    """
    Get total number of error-prone records across all files.
    An error-prone record is one that has one or more errors or is incomplete.
    
    Returns:
        int: Total number of error-prone records
    """
    db_manager = DatabaseConnectionManager()
    
    try:
        with db_manager.get_connection(autocommit=True) as connection:
            cursor = connection.cursor(dictionary=True)
            
            # Get latest processing timestamp
            latest_result = db_manager.execute_query(
                """
                SELECT MAX(last_processed) as latest_batch
                FROM file_completeness_summary
                """,
                dictionary=True
            )
            
            if not latest_result or not latest_result[0]['latest_batch']:
                logger.warning("No processed files found")
                return 0
                
            latest_batch = latest_result[0]['latest_batch']
            
            # Get the batch start time (truncate to minute to group related files)
            batch_result = db_manager.execute_query(
                """
                SELECT DATE_FORMAT(MIN(last_processed), '%Y-%m-%d %H:%i:00') as batch_start
                FROM file_completeness_summary
                WHERE last_processed >= DATE_SUB(%s, INTERVAL 5 MINUTE)
                """,
                (latest_batch,),
                dictionary=True
            )
            
            if not batch_result or not batch_result[0]['batch_start']:
                logger.warning("Could not determine batch start time")
                return 0
                
            batch_start = batch_result[0]['batch_start']
            
            # Get incomplete records count first
            incomplete_result = db_manager.execute_query(
                """
                SELECT file_name, incomplete_records
                FROM file_completeness_summary
                WHERE last_processed >= %s
                """,
                (batch_start,),
                dictionary=True
            )
            
            # Strategy for counting records with anomalies:
            # 1. For each file, we need to:
            #    - Count incomplete records (missing mandatory fields)
            #    - Count validation errors (invalid data)
            #    - Ensure rows with both types of errors are counted only once
            # 2. We use a single query to:
            #    - Get incomplete records count from file_completeness_summary
            #    - Get validation errors from error_logs
            #    - Join them to see overlap
            # 3. For each file we'll identify:
            #    - Rows that are just incomplete
            #    - Rows that just have validation errors
            #    - Rows that have both issues (to avoid double-counting)
            
            # Get both incomplete records and validation errors in a single query
            anomaly_result = db_manager.execute_query(
                """
                WITH ValidationErrors AS (
                    -- Get rows with validation errors
                    SELECT DISTINCT 
                        file_name,
                        line_number
                    FROM error_logs
                    WHERE file_name IN (
                        SELECT file_name 
                        FROM file_completeness_summary 
                        WHERE last_processed >= %s
                    )
                    AND line_number IS NOT NULL
                )
                SELECT 
                    fcs.file_name,
                    fcs.incomplete_records,
                    COUNT(DISTINCT ve.line_number) as validation_error_count,
                    -- Count rows in error_logs to get validation errors
                    -- These might overlap with incomplete records, so we track separately
                    COUNT(DISTINCT CASE 
                        WHEN ve.line_number IS NOT NULL THEN ve.line_number 
                        END) as pure_validation_errors,
                    -- Total problematic rows is the higher of:
                    -- 1. Number of incomplete records (they might include validation errors)
                    -- 2. Number of distinct rows with validation errors
                    CASE 
                        WHEN COUNT(DISTINCT ve.line_number) > fcs.incomplete_records 
                        THEN COUNT(DISTINCT ve.line_number)
                        ELSE fcs.incomplete_records
                    END as total_problematic_rows
                FROM file_completeness_summary fcs
                LEFT JOIN ValidationErrors ve ON fcs.file_name = ve.file_name
                WHERE fcs.last_processed >= %s
                GROUP BY fcs.file_name, fcs.incomplete_records
                """,
                (batch_start, batch_start),
                dictionary=True
            )
            
            total_anomalies = 0
            
            # Process each file's results
            for file in anomaly_result:
                file_name = file['file_name']
                incomplete_count = file['incomplete_records']
                validation_count = file['validation_error_count']
                pure_validation_errors = file['pure_validation_errors']
                problematic_rows = file['total_problematic_rows']
                
                # Detailed logging for this file's anomalies
                if incomplete_count > 0 or validation_count > 0:
                    logger.info(f"\nAnalysis for {file_name}:")
                    
                    if incomplete_count > 0:
                        logger.info(f"  ├── {incomplete_count} records with incomplete/missing mandatory fields")
                    
                    if validation_count > 0:
                        logger.info(f"  ├── {validation_count} records with validation errors")
                        
                    if incomplete_count > 0 and validation_count > 0:
                        overlap = max(0, incomplete_count + validation_count - problematic_rows)
                        logger.info(f"  ├── {overlap} records have both incomplete fields AND validation errors")
                        logger.info(f"  └── {problematic_rows} unique problematic records (after removing double-counting)")
                    else:
                        logger.info(f"  └── {problematic_rows} total problematic records")
                
                # Add the problematic rows count (avoiding double-counting)
                total_anomalies += problematic_rows
            
            logger.info(f"Total anomalies (unique rows with any type of error): {total_anomalies}")
            return total_anomalies
            
    except Exception as e:
        logger.error(f"Error getting error-prone records: {e}", exc_info=True)
        return 0

def get_original_file_list() -> List[str]:
    """
    Get list of original uploaded filenames from database.
    Used by report generator to process all available files.
    
    Returns:
        List[str]: List of filenames that have been processed
    """
    db = DatabaseConnectionManager()
    try:
        results = db.execute_query(
            """
            SELECT file_name 
            FROM file_completeness_summary 
            GROUP BY file_name 
            ORDER BY MAX(last_processed) DESC
            """
        )
        
        filenames = [row[0] for row in results if row[0]]
        logger.info(f"Found {len(filenames)} files: {filenames}")
        return filenames
        
    except Exception as e:
        logger.error(f"Error getting file list: {e}")
        return []

def reset_database_state(processed_folder: str) -> Dict[str, Any]:
    """
    Reset database and clean up processed files.
    Used for maintenance and testing purposes.
    
    Args:
        processed_folder: Path to folder containing processed files
        
    Returns:
        Dict with results of reset operation
    """
    results = {
        'database_cleared': False,
        'files_deleted': 0,
        'pdf_reports_deleted': 0,
        'errors': []
    }
    
    db = DatabaseConnectionManager()
    try:
        with db.get_connection(autocommit=False) as conn:
            cursor = conn.cursor()
            cursor.execute("TRUNCATE error_logs")
            cursor.execute("TRUNCATE file_completeness_summary")
            conn.commit()
            results['database_cleared'] = True
            
    except Exception as e:
        results['errors'].append(f"Database error: {e}")
    
    try:
        if os.path.exists(processed_folder):
            for filename in os.listdir(processed_folder):
                file_path = os.path.join(processed_folder, filename)
                if os.path.isfile(file_path):
                    if filename.endswith('.csv') and (
                        filename.startswith('processed_') or 
                        filename.startswith('anomaly_report_')
                    ):
                        os.remove(file_path)
                        results['files_deleted'] += 1
                    elif filename.endswith('.pdf') and filename.startswith('data_quality_report'):
                        os.remove(file_path)
                        results['pdf_reports_deleted'] += 1
                        
    except Exception as e:
        results['errors'].append(f"File deletion error: {e}")
    
    return results