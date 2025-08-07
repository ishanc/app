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
            port=os.getenv('MYSQL_PORT', 3306)
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
                c.overall_completeness as percent_complete,
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
            overall_completeness DECIMAL(5,2) NOT NULL,
            mandatory_completeness DECIMAL(5,2),
            total_fields INT NOT NULL,
            mandatory_fields INT NOT NULL,
            incomplete_mandatory_fields INT NOT NULL,
            last_processed TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            INDEX idx_file_name (file_name),
            INDEX idx_completeness (overall_completeness)
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
        """Map filename to the correct database key for mapping rules (same as file_server/app.py)"""
        # Remove file extension
        file_key = os.path.splitext(filename)[0]
        
        # Define the mapping from incoming filenames to database file names
        filename_mappings = {
            # Activity mappings
            "Activity_Curriculum": "Activity_Curriculum",
            "Activity_QuickAssessment": "Activity_Test",
            "Activity_ILTSessions": "Activity_SessionParts",
            "Activity_ILTClass": "Activity_Sessions", 
            "Activity_ILTCourse": "Activity_Events",
            "Activity_OnlineCourse": "Activity_OnlineCourse",
            "Activity_Online Course": "Activity_OnlineCourse",  # Original with space
            "Activity_Online_Course": "Activity_OnlineCourse",  # Flask converts space to underscore
            "Activity_Document": "Activity_Material",
            
            # Transcript mappings
            "Transcript_Curriculum": "Transcript_CurriculumTranscript",
            "Transcript_Document": "Transcript_MaterialTranscript", 
            "Transcript_ILT Class": "Transcript_SessionTranscript",
            "Transcript_ILT_Class": "Transcript_SessionTranscript",
            "Transcript_Online Course": "Transcript_OnlineCourse",
            "Transcript_Online_Course": "Transcript_OnlineCourse",
            "Transcript_QuickAssessment": "Transcript_TestTranscript",
            
            # Core mappings
            "Core_Audience": "Core_GroupsOU",
            "Core_Domain": "Core_DivisionOU",
            "Core_Employee": "Core_Employee", 
            "Core_Jobs": "Core_PositionOU",
            "Core_Organization": "Core_CostCenterOU",
            
            # Prerequisites mappings
            "Prerequisites_Facility": "Prerequisites_Facility",
            "Prerequisites_Instructor": "Prerequisites_Instructor",
            "Prerequisites_Provider": "Prerequisites_Provider",
            "Prerequisites_Question": "Prerequisites_Questions",
            "Prerequisites_QuestionBanks": "Prerequisites_QuestionsCategories",
            "Prerequisites_Subject": "Prerequisites_Subject"
        }
        
        # Return mapped key if exists, otherwise return original
        mapped_key = filename_mappings.get(file_key, file_key)
        
        return mapped_key
    
    def calculate_file_completeness(self, file_name, input_df):
        """Calculate completeness metrics for a file using error log data"""
        # Get mandatory fields from Neo4j
        mandatory_fields = self.get_mandatory_fields_from_neo4j(file_name)
        
        print(f"DEBUG: Found {len(mandatory_fields)} mandatory fields: {mandatory_fields}")
        print(f"DEBUG: DataFrame has {len(input_df)} rows and {len(input_df.columns)} columns")
        
        # Get error data for this file from database
        cursor = self.connection.cursor(dictionary=True)
        cursor.execute("""
            SELECT 
                MAX(line_number) as total_records,
                SUM(CASE WHEN validation_type = 'MANDATORY_EMPTY' THEN 1 ELSE 0 END) as mandatory_empty_count
            FROM error_logs 
            WHERE file_name = %s
        """, (file_name,))
        
        error_data = cursor.fetchone()
        cursor.close()
        
        if not error_data or error_data['total_records'] is None:
            print(f"WARNING: No error data found for {file_name}")
            return {
                'overall_completeness': 0.0,
                'mandatory_completeness': 0.0,
                'total_fields': len(input_df.columns) * len(input_df),
                'mandatory_fields': len(mandatory_fields),
                'incomplete_mandatory_fields': 0
            }
        
        total_records = error_data['total_records']
        mandatory_empty_count = error_data['mandatory_empty_count'] or 0
        
        print(f"DEBUG: Error log data - Total records: {total_records}, Mandatory empty: {mandatory_empty_count}")
        
        # Calculate overall completeness (all fields)
        total_fields = len(input_df.columns) * len(input_df)
        non_empty_fields = 0
        
        for column in input_df.columns:
            # Count non-empty values (including wrong types - they still have data)
            # Only count as empty if truly None, empty string, or whitespace-only
            non_empty_count = input_df[column].apply(
                lambda x: x is not None and str(x).strip() != ""
            ).sum()
            non_empty_fields += non_empty_count
        
        overall_completeness = (non_empty_fields / total_fields * 100) if total_fields > 0 else 0
        
        # Calculate mandatory completeness using error log data
        if mandatory_fields and total_records > 0:
            total_mandatory_positions = len(mandatory_fields) * total_records
            filled_mandatory_positions = total_mandatory_positions - mandatory_empty_count
            mandatory_completeness = (filled_mandatory_positions / total_mandatory_positions * 100) if total_mandatory_positions > 0 else 0
            
            print(f"DEBUG: Mandatory completeness calculation:")
            print(f"  • Total mandatory positions: {total_mandatory_positions}")
            print(f"  • Filled mandatory positions: {filled_mandatory_positions}")
            print(f"  • Mandatory completeness: {mandatory_completeness}%")
        else:
            mandatory_completeness = 0
            print(f"DEBUG: No mandatory fields or no records found")
        
        return {
            'overall_completeness': round(overall_completeness, 2),
            'mandatory_completeness': round(mandatory_completeness, 2),
            'total_fields': total_fields,
            'mandatory_fields': len(mandatory_fields),
            'incomplete_mandatory_fields': mandatory_empty_count
        }
    
    def store_completeness_metrics(self, file_name, metrics):
        """Store completeness metrics in the database"""
        connection = self.connection
        cursor = connection.cursor()
        
        insert_query = """
        INSERT INTO file_completeness_summary 
        (file_name, overall_completeness, mandatory_completeness, total_fields, 
        mandatory_fields, incomplete_mandatory_fields)
        VALUES (%s, %s, %s, %s, %s, %s)
        ON DUPLICATE KEY UPDATE
        overall_completeness = VALUES(overall_completeness),
        mandatory_completeness = VALUES(mandatory_completeness),
        total_fields = VALUES(total_fields),
        mandatory_fields = VALUES(mandatory_fields),
        incomplete_mandatory_fields = VALUES(incomplete_mandatory_fields),
        last_processed = CURRENT_TIMESTAMP
        """
        
        try:
            cursor.execute(insert_query, (
                file_name,
                float(metrics['overall_completeness']),
                float(metrics['mandatory_completeness']),
                int(metrics['total_fields']),
                int(metrics['mandatory_fields']),
                int(metrics['incomplete_mandatory_fields'])
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