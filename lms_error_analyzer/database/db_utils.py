#!/usr/bin/env python3
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

# [MODIFIED: 2025-09-16] Added context manager support to DatabaseConnectionManager
"""
Original implementation:

class DatabaseConnectionManager:
    # Basic database connection manager without context manager support
    def __init__(self):
        self.db_config = {
            'host': os.getenv('MYSQL_HOST', 'localhost'),
            'user': os.getenv('MYSQL_USER'),
            'password': os.getenv('MYSQL_PASSWORD'),
            'database': os.getenv('MYSQL_NAME'),
            'port': int(os.getenv('MYSQL_PORT', 3306))
        }
"""

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
            'host': os.getenv('MYSQL_HOST', 'localhost'),
            'user': os.getenv('MYSQL_USER'),
            'password': os.getenv('MYSQL_PASSWORD'),
            'database': os.getenv('MYSQL_NAME'),
            'port': int(os.getenv('MYSQL_PORT', 3306)),
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

# [MODIFIED: 2025-09-17] Updated to sum records from all files in recent batch
"""
Original implementation:
def get_total_records_processed() -> int:
    db = DatabaseConnectionManager()
    try:
        latest_result = db.execute_query(
            "SELECT MAX(last_processed) as latest FROM file_completeness_summary",
            dictionary=True
        )
        if not latest_result or not latest_result[0]['latest']:
            return 0
        latest = latest_result[0]['latest']
        total_result = db.execute_query(
            "SELECT SUM(total_records) as total FROM file_completeness_summary WHERE last_processed = %s",
            (latest,),
            dictionary=True
        )
        return total_result[0]['total'] or 0

Reason for change: Now includes records from all files in the recent batch
"""

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