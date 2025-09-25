import mysql.connector
import os
from dotenv import load_dotenv
from neo4j import GraphDatabase

load_dotenv()



class Dashboard:
    def __init__(self):
        self.connection = mysql.connector.connect(
            host=os.getenv('MYSQL_HOST'),
            user=os.getenv('MYSQL_USER'),
            password=os.getenv('MYSQL_PASSWORD'),
            database=os.getenv('MYSQL_NAME'),
            port=int(os.getenv('MYSQL_PORT')),
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
        """Generate dashboard for data quality with completeness as primary source"""
        self.create_completeness_tables()
        
        # A1: Completeness-driven query with LEFT JOIN aggregated errors
        query = """
        WITH err AS (
          SELECT 
            e.file_name,
            COUNT(*)                             AS total_errors,
            COUNT(DISTINCT e.line_number)        AS lines_with_errors,
            SUM(e.validation_type = 'MANDATORY_EMPTY')                                                       AS nulls_found,
            SUM(e.validation_type IN ('TYPE_COMPATIBILITY','HEADER_INCONSISTENCY'))                          AS unlinked_fk
          FROM error_logs e
          WHERE e.file_name IS NOT NULL
          GROUP BY e.file_name
        )
        SELECT 
          c.file_name,
          c.total_records,
          COALESCE(err.total_errors, 0)          AS total_errors,
          COALESCE(err.lines_with_errors, 0)     AS lines_with_errors,
          COALESCE(err.nulls_found, 0)           AS nulls_found,
          COALESCE(err.unlinked_fk, 0)           AS unlinked_fk,
          c.mandatory_completeness               AS percent_complete,
          CASE 
            WHEN c.total_records <= 0 THEN 0
            ELSE ROUND(100.0 * (c.total_records - COALESCE(err.lines_with_errors,0)) / c.total_records, 2)
          END                                     AS percent_valid
        FROM file_completeness_summary c
        LEFT JOIN err ON err.file_name = c.file_name
        ORDER BY c.file_name
        """
        
        cursor = self.connection.cursor(dictionary=True)
        cursor.execute(query)
        results = cursor.fetchall()
        cursor.close()
        
        # A2: Get total fields data and merge into results
        total_fields_data = self.get_total_fields_data([row['file_name'] for row in results])
        
        # A5: Build response with new structure
        dashboard_results = []
        for row in results:
            file_name = row['file_name']
            dashboard_results.append({
                'file_name': file_name,
                'record_count': int(row['total_records']),  # A3: Use completeness total_records
                'total_errors': int(row['total_errors']),
                'lines_with_errors': int(row['lines_with_errors']),
                'nulls_found': int(row['nulls_found']),
                'unlinked_fk': int(row['unlinked_fk']),
                'percent_valid': float(row['percent_valid']),  # A3: From SQL calculation
                'percent_complete': float(row['percent_complete']),  # A3: mandatory_completeness
                'mandatory_complete': float(row['percent_complete']),  # Backward compatibility
                'total_fields_in_file': total_fields_data.get(file_name, 0)  # A2: New field
            })
        
        return dashboard_results

    def get_total_fields_data(self, file_names):
        """
        A2: Get total fields count for each file using information_schema with SumTotal-only mapping
        
        Args:
            file_names: List of SumTotal file names (e.g., "Activity_Curriculum", "Core_Audience")
            
        Returns:
            Dict[str, int]: Mapping of file_name -> total_fields_in_file
        """
        # SumTotal-only file name to MySQL table mapping
        sumtotal_to_mysql_table = {
            # Activity files
            "Activity_Curriculum": "activity_curriculum",
            "Activity_Document": "activity_document", 
            "Activity_ILTClass": "activity_ilt_class",
            "Activity_ILTCourse": "activity_ilt_course",
            "Activity_ILTSessions": "activity_ilt_sessions",
            "Activity_Online Course": "activity_online_course",
            "Activity_Online_Course": "activity_online_course",
            "Activity_QuickAssessment": "activity_quick_assessment",
            
            # Core files
            "Core_Audience": "core_audience",
            "Core_Domain": "core_domain",
            "Core_Employee": "core_employee",
            "Core_Jobs": "core_jobs", 
            "Core_Organization": "core_organization",
            
            # Prerequisites files
            "Prerequisites_Facility": "prerequisites_facility",
            "Prerequisites_Instructor": "prerequisites_instructor",
            "Prerequisites_Provider": "prerequisites_provider",
            "Prerequisites_Question": "prerequisites_question",
            "Prerequisites_QuestionBanks": "prerequisites_question_banks",
            "Prerequisites_Subject": "prerequisites_subject",
            
            # Transcript files
            "Transcript_Curriculum": "transcript_curriculum",
            "Transcript_Document": "transcript_document",
            "Transcript_ILTClass": "transcript_ilt_class",
            "Transcript_ILT_Class": "transcript_ilt_class",  # Add missing mapping
            "Transcript_Online Course": "transcript_online_course",
            "Transcript_Online_Course": "transcript_online_course",
            "Transcript_QuickAssessment": "transcript_quick_assessment"
        }
        
        total_fields_data = {}
        cursor = self.connection.cursor(dictionary=True)
        
        try:
            for file_name in file_names:
                # Clean file name (remove .xlsx extension if present)
                clean_file_name = file_name.replace('.xlsx', '').replace('.csv', '')
                table_name = sumtotal_to_mysql_table.get(clean_file_name)
                
                if table_name:
                    try:
                        # Query information_schema for column count
                        cursor.execute("""
                            SELECT COUNT(*) as field_count
                            FROM information_schema.columns
                            WHERE table_schema = DATABASE()
                              AND table_name = %s
                        """, (table_name,))
                        
                        result = cursor.fetchone()
                        field_count = result['field_count'] if result else 0
                        total_fields_data[file_name] = field_count
                        
                        if field_count == 0:
                            print(f"WARNING: No fields found for table '{table_name}' (file: {file_name})")
                            
                    except Exception as e:
                        print(f"ERROR: Failed to get field count for {file_name} -> {table_name}: {e}")
                        total_fields_data[file_name] = 0
                else:
                    print(f"WARNING: No table mapping found for SumTotal file '{clean_file_name}'")
                    total_fields_data[file_name] = 0
                    
        finally:
            cursor.close()
            
        return total_fields_data

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
        """
        A4: Get mandatory fields for a file from Neo4j using SumTotal-only file names
        
        Args:
            file_name: SumTotal file name (e.g., "Activity_Curriculum", "Core_Audience")
            
        Returns:
            List[str]: List of mandatory SumTotal field names
        """
        mandatory_fields = []
        
        try:
            with self.neo4j_driver.session() as session:
                # A4: Updated Cypher query for SumTotal-only lookup
                query = """
                MATCH (f:File {name: $fileName})-[:HAS_FIELD]->(st:SumTotalField)
                MATCH (st)-[:MAPS_TO]->(csod:CSODField)
                WHERE csod.mandatory = 'Mandatory'
                RETURN DISTINCT st.name AS field_name
                """
                
                # A4: Use SumTotal-only file name mapping (no CSOD conversion)
                sumtotal_file_key = self.get_sumtotal_file_key(file_name)
                print(f"DEBUG: Original filename: {file_name}")
                print(f"DEBUG: SumTotal file key: {sumtotal_file_key}")
                
                result = session.run(query, fileName=sumtotal_file_key)
                
                for record in result:
                    mandatory_fields.append(record["field_name"])
                    
                print(f"DEBUG: Found {len(mandatory_fields)} mandatory fields for {sumtotal_file_key}")
                
        except Exception as e:
            print(f"ERROR: Failed to get mandatory fields from Neo4j for {file_name}: {e}")
        
        return mandatory_fields
    
    def get_sumtotal_file_key(self, filename):
        # Clean filename (remove extensions)
        clean_filename = filename.replace('.xlsx', '').replace('.csv', '')
        
        # Copy the COMPLETE mappings from filename_mapper.py (lines 22-57)
        sumtotal_file_mappings = {
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
            "Core_Employee": "Core_Employee-CHR", 
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
        
        # Return mapped name or original clean name for direct SumTotal files
        return sumtotal_file_mappings.get(clean_filename, clean_filename)
    
    def calculate_file_completeness(self, file_name, input_df):
        """Calculate mandatory completeness as percent of records with all mandatory fields populated.

        Business definitions:
        - Records = rows (header excluded)
        - Fields = columns (header excluded) 
        - mandatory_completeness = % of records where all mandatory fields are non-empty. 
        - total_records = total number of data rows
        - incomplete_records = number of records missing mandatory fields
        """
        # Get mandatory fields from Neo4j using mapped filename
        from utils.filename_mapper import FilenameMapper
        mapped_file_name = FilenameMapper.to_db_key(file_name)
        print(f"DEBUG: Mapping {file_name} -> {mapped_file_name} for Neo4j lookup")
        mandatory_fields = self.get_mandatory_fields_from_neo4j(mapped_file_name)

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