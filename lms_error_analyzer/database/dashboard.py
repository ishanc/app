import mysql.connector
import os
from dotenv import load_dotenv
from neo4j import GraphDatabase

load_dotenv()



class Dashboard:
    def __init__(self):
        self.connection = mysql.connector.connect(
            host=os.getenv('MYSQL_HOST', 'localhost'),
            user=os.getenv('MYSQL_USER'),
            password=os.getenv('MYSQL_PASSWORD'),
            database=os.getenv('MYSQL_NAME'),
            port=os.getenv('MYSQL_PORT', 3306),
            ssl_disabled=True,
            autocommit=False,
            connect_timeout=30,
            use_unicode=True
        )
        
        # Add Neo4j connection
        self.neo4j_driver = GraphDatabase.driver(
            os.getenv('NEO4J_URI'),
            auth=(os.getenv('NEO4J_USER'), os.getenv('NEO4J_PASSWORD'))
        )
    
    def _calculate_percent_valid(self, total_records, lines_with_errors):
        """Calculate the percent of records that are valid (have no errors)"""
        if total_records <= 0:
            return 0
        # Ensure lines_with_errors doesn't exceed total_records
        lines_with_errors = min(total_records, lines_with_errors)
        # Calculate percentage of records with NO errors
        percent_valid = ((total_records - lines_with_errors) / total_records) * 100
        return round(max(0, min(100, percent_valid)), 2)
    
    def debug_error_data(self, file_name):
        """Debug error data for a specific file"""
        query = """
        SELECT 
            file_name,
            MIN(line_number) as min_line,
            MAX(line_number) as max_line,
            COUNT(DISTINCT line_number) as unique_lines,
            COUNT(*) as total_errors,
            COUNT(DISTINCT validation_type) as validation_types
        FROM error_logs 
        WHERE file_name = %s
        GROUP BY file_name
        """
        cursor = self.connection.cursor(dictionary=True)
        cursor.execute(query, (file_name,))
        result = cursor.fetchone()
        cursor.close()
        
        if result:
            print(f"DEBUG: Error data for {file_name}:")
            print(f"  - Min line: {result['min_line']}")
            print(f"  - Max line: {result['max_line']}")
            print(f"  - Unique lines: {result['unique_lines']}")
            print(f"  - Total errors: {result['total_errors']}")
            print(f"  - Validation types: {result['validation_types']}")
        else:
            print(f"No error data found for {file_name}")
        return result
    
    def generate_quality_dashboard(self):
        #this is a dashboard for the user to see the quality of the data. 
        self.create_completeness_tables()
        query = """
        SELECT 
            file_name,
            MAX(total_records) as total_records,
            MAX(total_errors) as total_errors,
            MAX(lines_with_errors) as lines_with_errors,
            MAX(nulls_found) as nulls_found,
            MAX(unlinked_fk) as unlinked_fk,
            MAX(percent_complete) as percent_complete,
            MAX(mandatory_complete) as mandatory_complete
        FROM (
            SELECT 
                e.file_name,
                MAX(e.line_number) as total_records,
                COUNT(*) as total_errors,
                COUNT(DISTINCT e.line_number) as lines_with_errors,
                SUM(CASE WHEN e.validation_type = 'MANDATORY_EMPTY' THEN 1 ELSE 0 END) as nulls_found,
                SUM(CASE WHEN e.validation_type IN ('TYPE_COMPATIBILITY', 'HEADER_INCONSISTENCY') THEN 1 ELSE 0 END) as unlinked_fk,
                0 as percent_complete,
                0 as mandatory_complete
            FROM error_logs e
            WHERE e.file_name IS NOT NULL
            GROUP BY e.file_name
            
            UNION ALL
            
            SELECT 
                c.file_name,
                0 as total_records,
                0 as total_errors,
                0 as lines_with_errors,
                0 as nulls_found,
                0 as unlinked_fk,
                c.mandatory_completeness as percent_complete,
                c.mandatory_completeness as mandatory_complete
            FROM file_completeness_summary c
            WHERE c.file_name IS NOT NULL
        ) combined_data
        GROUP BY file_name
        """
        
        cursor = self.connection.cursor(dictionary=True)
        cursor.execute(query)
        results = cursor.fetchall()
        cursor.close()
        
        return [{
            'file_name': row['file_name'],
            'record_count': row['total_records'],
            'total_errors': row['total_errors'],
            'lines_with_errors': row['lines_with_errors'],
            'nulls_found': row['nulls_found'],
            'unlinked_fk': row['unlinked_fk'],
            'percent_valid': self._calculate_percent_valid(row['total_records'], row['lines_with_errors']),
            'percent_complete': row['percent_complete'],
            'mandatory_complete': row['mandatory_complete']
        } for row in results]

    def create_completeness_tables(self):
        connection = self.connection
        cursor = connection.cursor()
        
        create_table_query = """
        CREATE TABLE IF NOT EXISTS file_completeness_summary (
            id INT AUTO_INCREMENT PRIMARY KEY,
            file_name VARCHAR(255) NOT NULL UNIQUE,
            mandatory_completeness DECIMAL(5,2),
            total_records INT NOT NULL,
            incomplete_records INT NOT NULL,
            last_processed TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            INDEX idx_file_name (file_name),
            INDEX idx_mandatory_completeness (mandatory_completeness)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
        """
        try:
            cursor.execute(create_table_query)
            connection.commit()
            print("Completeness tables created successfully")
        except mysql.connector.Error as e:
            print(f"Error creating completeness tables: {e}")
        finally:
            cursor.close()
            
    def get_mandatory_fields_from_neo4j(self, file_name):
        """Get mandatory fields for a file from Neo4j mapping rules"""
        mandatory_fields = []
        
        try:
            with self.neo4j_driver.session() as session:
                query = """
                MATCH (f:File {name: $fileName})
                MATCH (f)-[:HAS_FIELD]->(st:SumTotalField)
                MATCH (st)-[:MAPS_TO]->(csod:CSODField)
                WHERE csod.mandatory = "Mandatory"
                WITH DISTINCT st.name as field_name
                RETURN field_name
                """
                # Use the same file mapping logic as the transformation pipeline
                file_key = self.map_filename_to_database_key(file_name)
                print(f"DEBUG: Original filename: {file_name}")
                print(f"DEBUG: Mapped file key: {file_key}")
                result = session.run(query, fileName=file_key)
                
                for record in result:
                    mandatory_fields.append(record["field_name"])
        except Exception as e:
            print(f"Error getting mandatory fields from Neo4j: {e}")
        
        return mandatory_fields
    
    def map_filename_to_database_key(self, filename):
        """Map filename to the correct database key for mapping rules"""
        from utils.filename_mapper import FilenameMapper
        return FilenameMapper.to_db_key(filename)
    
    def calculate_file_completeness(self, file_name, input_df):
        """Calculate mandatory completeness as percent of records with all mandatory fields populated.

        Business definitions:
        - Records = rows (header excluded)
        - Fields = columns (header excluded) 
        - mandatory_completeness = % of records where all mandatory fields are non-empty. 
        - total_records = total number of data rows
        - incomplete_records = number of records missing mandatory fields
        """
        # Get mandatory fields from Neo4j
        mandatory_fields = self.get_mandatory_fields_from_neo4j(file_name)

        total_records = len(input_df) if input_df is not None else 0
        print(f"DEBUG: Found {len(mandatory_fields)} mandatory fields: {mandatory_fields}")
        print(f"DEBUG: DataFrame has {total_records} rows and {len(input_df.columns) if input_df is not None else 0} columns")

        if total_records == 0:
            return {
                'mandatory_completeness': 0.0,
                'total_records': 0,
                'incomplete_records': 0
            }

        # Normalize values: treat None/NaN/whitespace-only as empty
        def is_non_empty(value):
            try:
                return value is not None and str(value).strip() != ""
            except Exception:
                return False

        # Build a boolean mask per mandatory field: True where value is non-empty.
        per_field_masks = []
        print(f"DEBUG: Input DataFrame columns: {list(input_df.columns) if input_df is not None else []}")
        
        for field in mandatory_fields:
            if field in input_df.columns:
                mask = input_df[field].apply(is_non_empty)
                non_empty_count = mask.sum()
                print(f"DEBUG: Field '{field}' FOUND - {non_empty_count}/{total_records} non-empty values")
            else:
                # If field not present, treat as all False (every row fails)
                mask = input_df.index.to_series().apply(lambda _: False)
                print(f"DEBUG: Field '{field}' NOT FOUND in DataFrame columns")
            per_field_masks.append(mask)

        if per_field_masks:
            # Row is complete if all mandatory field masks are True
            from functools import reduce
            import operator
            all_complete_mask = reduce(operator.and_, per_field_masks)
            num_complete_records = int(all_complete_mask.sum())
        else:
            # No mandatory fields configured; treat as zero completeness per current policy
            num_complete_records = 0

        num_incomplete_records = total_records - num_complete_records
        mandatory_completeness = (num_complete_records / total_records * 100.0) if total_records > 0 else 0.0

        # Return mandatory completeness metrics
        return {
            'mandatory_completeness': round(mandatory_completeness, 2),
            'total_records': int(total_records),
            'incomplete_records': int(num_incomplete_records)
        }
    
    def store_completeness_metrics(self, file_name, metrics):
        """Store completeness metrics in the database"""
        connection = self.connection
        cursor = connection.cursor()
        
        insert_query = """
        INSERT INTO file_completeness_summary 
        (file_name, mandatory_completeness, total_records, incomplete_records)
        VALUES (%s, %s, %s, %s)
        ON DUPLICATE KEY UPDATE
        mandatory_completeness = VALUES(mandatory_completeness),
        total_records = VALUES(total_records),
        incomplete_records = VALUES(incomplete_records),
        last_processed = CURRENT_TIMESTAMP
        """
        
        try:
            cursor.execute(insert_query, (
                file_name,
                float(metrics['mandatory_completeness']),
                int(metrics['total_records']),
                int(metrics['incomplete_records'])
            ))
            connection.commit()
            print(f"Stored completeness metrics for {file_name}")
        except mysql.connector.Error as e:
            print(f"Error storing completeness metrics: {e}")
        finally:
            cursor.close()
    
    def close_connections(self):
        """Close database connections"""
        if hasattr(self, 'connection') and self.connection:
            self.connection.close()
        if hasattr(self, 'neo4j_driver') and self.neo4j_driver:
            self.neo4j_driver.close()