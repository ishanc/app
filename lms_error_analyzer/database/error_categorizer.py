""" ErrorCategorizer (Main Orchestrator)
├── CategoryMapper (Mapping Logic)
├── ErrorFetcher (Database Access)
├── CategoryContainer (Result Storage)
└── ErrorBatch (Batch Processing) 
    """
    
import logging
import pandas as pd
from mysql.connector import connect, Error
from lms_error_analyzer.database.llm_processor import LLMProcessor

class ErrorCategorizer:
        """Orchestrates error categorization, manages DB connections, and coordinates components. 
        
          Error Handling Strategy:
         - Database failures: Log error, retry once, then raise exception
         - Unknown validation types: Log warning, categorize as 'unknown_type'
         - Malformed data: Log error, skip record, continue processing
         - Mapping failures: Log error, use default category, continue processing
         - LLM failures: Log error, retry, then raise exception
         
        """
        
        
        def __init__(self, db_config: None):
            """
                Initialize ErrorCategorizer.
    
                db_config should be a dictionary with:
    DB_CONFIG = {
        'host': 'localhost',
        'user': 'error_logger',
        'password': 'MySQLserver123',
        'database': 'error_logging',
        'port': 3306
        #should we add ssl_ca and ssl_verify?
    }
        """
            self.db_config = db_config or self._get_default_config()
            self.logger = self._setup_logger()
            self.category_mapper = CategoryMapper()
            self.category_container = CategoryContainer()
            self.error_fetcher = None  # Will be set when we connect
        def _setup_logger(self):
            """Initialize logging"""
            #configure logging
            logger = logging.getLogger('ErrorCategorizer')
            logger.setLevel(logging.INFO)
            if not logger.handlers: 
                #create a console handler
                handler = logging.StreamHandler()
                formatter = logging.Formatter('%(asctime)s [%(levelname)s] %(name)s: %(message)s')
                handler.setFormatter(formatter)
                logger.addHandler(handler)
            return logger

        def handle_database_error(self, error, context):#nice to have
            """Handle database connection/query failures."""
        pass
    
        def handle_unknown_validation_type(self, validation_type):#nice to have
            """Handle validation types not in mapping."""
        pass
    
        def handle_malformed_error_data(self, error_data):#nice to have
            """Handle errors with missing/invalid fields."""
        pass
    
        def handle_mapping_failure(self, validation_type, error):#nice to have
            """Handle failures in category mapping."""
            pass
        
        def connect(self):
            """ Establish db connection and return connection object"""
            #implement connection
            try:
                self.connection = connect(**self.db_config) #** is used to unpack the dictionary
                self.error_fetcher = ErrorFetcher(self.connection)#fetch errors from the database
                self.logger.info("Connected to database successfully")
            except Error as e:
                self.logger.error(f"Database connection failed: {e}")
                #retry once
                try:
                    self.logger.info("Retrying database connection...")
                    self.connection = connect(**self.db_config)
                    self.error_fetcher = ErrorFetcher(self.connection)
                    self.logger.info("Database connection successful after retry")
                except Error as e2:
                    self.logger.error(f"Database connection failed after retry: {e2}")
                    raise
                
        
        def disconnect(self):
            """ Close db connection"""
            if hasattr(self, 'connection') and self.connection:
                self.connection.close()
                self.logger.info("Database connection closed")
                self.connection = None
                self.error_fetcher = None
                
        def analyze_with_llm(self, api_key=None):
            """Categorize errors and analyze with LLM (Claude 3.7 or mock)."""
            categorized = self.category_container.get_all_categories()
            llm = LLMProcessor(api_key)
            def chunker(category, errors):
                return self.category_container.prepare_for_chunking(category)
            insights = llm.generate_insights(categorized, chunker)
            stats = self.get_category_statistics()
            return {"stats": stats, "llm_insights": insights}
        
        def categorize_all_errors(self, error_data=None, batch_size=1000):
            """
    Main orchestration method.
    Fetches errors, categorizes, and returns categorized results in different arrays.
    Uses error_id for cursor-based pagination.
    
    Args:
        error_data: Optional DataFrame of errors. If None, fetch from database with cursor pagination.
        batch_size: Number of errors to process per batch (default: 1000)
    
    Returns:
        dict: Categorized errors organized by FS category
    """
            if error_data is None:
        # Database fetching path with cursor pagination
        # Ensure we have a database connection
                if self.error_fetcher is None:
                    self.connect()
        
        # Initialize cursor position
                last_processed_id = 0
        
        # Process errors in batches using cursor pagination
                while True:
            # Fetch next batch
                    batch = self.error_fetcher.fetch_batch_after_id(last_processed_id, batch_size)
            
            # If no more errors, break
                    if not batch:
                        break
            
            # Process each error in the batch
                    for error in batch:
                # Map validation type to FS category
                        category = self.category_mapper.map_validation_type(error["validation_type"])
                
                # Add error to appropriate category array
                        self.category_container.add_error(category, error)
            
            # Update cursor position for next iteration
                    last_processed_id = batch[-1]["error_id"]
    
            else:
        # DataFrame processing path
                for _, error in error_data.iterrows():
                    error_dict = error.to_dict()
                    category = self.category_mapper.map_validation_type(error_dict["validation_type"])
                    self.category_container.add_error(category, error_dict)
    
    # Return categorized results
            return self.category_container.get_all_categories()
        
        def get_category_statistics(self):
            """Return count per category and summary metrics.
            """
            stats = {}
            for category, errors in self.category_container.get_all_categories().items(): #iterating over all items in the category container
                stats[category] = len(errors) #count of errors in each category
            stats['total'] = sum(stats.values())
            return stats

        def _track_progress(self, current_batch, total_batches, processed_errors):#nice to have
            """Track and log processing progress."""
            pass
        def get_progress_summary(self):#nice to have
            """Return current progress summary."""
            pass
        def _get_default_config(self): # remove this once we have a proper config
            """Return default database configuration."""
            return {
        "host": "localhost",
        "port": 3306,
        "database": "lms_error_analyzer",
        "user": "root",
        "password": "",
        "charset": "utf8mb4"
        }
        
class CategoryMapper:
    """class CategoryMapper:
    
    Handles mapping of validation types to FS categories.
    
    Maps 16 validation types to 11 FS categories:
    - MANDATORY_EMPTY, TRUNCATION, LEADING_SPACES, etc.
    """
    
    def __init__(self):
        self.validation_to_category = {
        # File Structure & Consistency
        "HEADER_INCONSISTENCY": "file_structure_consistency",
        "DELIMITER_ISSUE": "file_structure_consistency",
        
        # Data Completeness
        "COMPLETENESS_SCORE": "data_completeness",
        
        # Format Conformity
        "ENCODING_ISSUE": "format_conformity",
        "LEADING_SPACES": "format_conformity", 
        "TRAILING_SPACES": "format_conformity",
        "LEADING_ZEROS": "format_conformity",
        
        # Duplicate Records
        "DUPLICATE_RECORD": "duplicate_records",
        
        # Null Value Flagging
        "MANDATORY_EMPTY": "null_value_flagging",
        
        # Format Mismatch
        "DATE_FORMAT": "format_mismatch",
        
        # Outlier Identification
        "OUTLIER_VALUE": "outlier_identification",
        
        # Heterogeneous Data Types
        "HETEROGENEOUS_TYPE": "heterogeneous_data_types",
        
        # Character Length & Truncation
        "TRUNCATION": "char_length_truncation",
        # Type Compatibility
        "TYPE_COMPATIBILITY": "type_compatibility",
        
        # Boolean Transformation
        "BOOLEAN_CONVERSION": "boolean_transformation"
    }
    
        
    def map_validation_type(self, validation_type): #This is the main method that maps validation types to FS categories. and returns the category. if none
        """ Return FS category for given validation type. Handle unknown/null types."""
        if validation_type is None or validation_type == "":
            return "unknown_type"
    
        return self.validation_to_category.get(validation_type, "unknown_type")
    def get_all_categories(self):
        """ Return list of all FS categories."""#This is useful to avoid repeated calls, categories 
        return list(set(self.validation_to_category.values()))
    def get_validation_types_for_category(self, category): # Why is this needed? Is it for double checking I am not sure. Ans: testing and validation. generating reports that show validation types for each category.
        """Reverse lookup: return validation types for a given FS category."""
        return [validation_type for validation_type, category in self.validation_to_category.items() if category == category] # What does this do? Ans: it returns a list of validation types for a given category.
    
class ErrorFetcher:
    """Handles database queries and pagination for error logs.
    
    Expected error structure:
    {
        "validation_type": str,      # e.g., "MANDATORY_EMPTY", "TRUNCATION", etc.
        "error_message": str,        # Human-readable description
        "field_name": str,           # Field that had the error
        "row_number": int,           # Row number in source file
        "file_name": str,            # Source file name
        "timestamp": str,            # When error occurred
        "value": str,                # The problematic value
        "run_number": int,           # This wont exist yet will be added later
        "error_id": int              # Unique error identifier (primary key)
    }
    
    
    """
    def __init__(self, connection):
        self.connection = connection
        self.last_processed_id = 0  # Track cursor position
    
    
    def fetch_batch_after_id(self, last_id, batch_size=1000):
        """Fetch batch after specific error_id (cursor pagination)."""
        # Query: SELECT * FROM error_logs WHERE error_id > last_id ORDER BY error_id LIMIT batch_size
        query = """ SELECT * FROM error_logs where error_id > %s order by error_id limit %s """
        
        cursor = self.connection.cursor(dictionary=True)
        cursor.execute(query, (last_id, batch_size))
        results = cursor.fetchall()
        cursor.close()
        return results
    
    def fetch_by_validation_type(self, validation_type):
        """Fetch errors of a specific validation type."""
        query = """
        SELECT *
        FROM error_logs 
        WHERE validation_type = %s
        ORDER BY error_id
    """
        cursor = self.connection.cursor(dictionary=True)
        cursor.execute(query, (validation_type,))
        results = cursor.fetchall()
        cursor.close()
        return results
        
        
        
    
    def count_total_errors(self):
        """Get total error count for progress tracking."""
        query = "SELECT COUNT(*) as total FROM error_logs"
        cursor = self.connection.cursor(dictionary=True)
        cursor.execute(query)
        result = cursor.fetchone()
        cursor.close()
        return result['total'] if result else 0
    
    
    
class ErrorBatch:
    """Represents a batch of errors. 
    """
    def __init__(self, errors, batch_number, total_batches, metadata=None):
        self.errors = errors
        self.batch_number = batch_number
        self.total_batches = total_batches
        self.metadata = metadata or {}

    def add_error(self, error):
        self.errors.append(error)

    def get_errors_by_category(self, category):
    # This would require categorization logic
    # For now, return all errors
        return self.errors

    def to_dict(self):
        return {
        'errors': self.errors,
        'batch_number': self.batch_number,
        'total_batches': self.total_batches,
        'metadata': self.metadata
        }
        
class CategoryContainer:
    """Stores and manages categorized errors. 
    """
    def __init__(self):
        self.categories = {}
    def add_error(self, category, error):
        if category not in self.categories:
            self.categories[category] = []
        self.categories[category].append(error)
    def get_category(self, category_name):
        return self.categories.get(category_name, [])
    def get_all_categories(self): #Why is this needed? if there is get_category. look at it from the perspective of a senior dev. Ans: useful to avoid repeated calls, categories 
        return self.categories #returns all categories( does it need keys)
    
    def prepare_for_chunking(self, category, chunk_size=8, token_limit=400):
        """Split category into chunks for LLM, respecting token limit."""
        if category not in self.categories:
            return []
        errors = self.categories[category]
        chunks = []
        current_chunk = []
        current_token_count = 0
        #This is the main method that splits the errors into chunks for the LLM.
        for error in errors:
            #Simple token estimation (roughly 1 token per 4 chars)
            error_text = str(error)
            estimated_tokens = len(error_text) // 4
            if current_token_count + estimated_tokens > token_limit and current_chunk: #If the current chunk is too large, we add it to the chunks list and start a new chunk.
                chunks.append(current_chunk)
                current_chunk = [error] #Start a new chunk with the current error.
                current_token_count = estimated_tokens
            else: 
                current_chunk.append(error)
                current_token_count += estimated_tokens
        if current_chunk:
            chunks.append(current_chunk)
            
        return chunks
    
    
