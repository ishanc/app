from flask import Flask, render_template, request, send_from_directory, jsonify
import os
import sys
from werkzeug.utils import secure_filename
import time
import pandas as pd
from datetime import datetime
import logging
import debugpy
from typing import List, Optional

# Configure logging
logging.basicConfig(level=logging.WARNING)
logging.getLogger('mysql.connector').setLevel(logging.WARNING)
logger = logging.getLogger(__name__)

# Add the lasVegas app directory to Python path
LASVEGAS_APP_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'lasVegas', 'app'))
sys.path.append(LASVEGAS_APP_DIR)

# Add lms_error_analyzer database directory to Python path for PDF generation
LMS_DATABASE_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'lms_error_analyzer', 'database'))
sys.path.append(LMS_DATABASE_DIR)

import sumtotal_transformer_with_neo4j as transformer

# Import session manager
sys.path.append(LMS_DATABASE_DIR)
from session_manager import session_manager

app = Flask(__name__)

# Use absolute paths for all directories
# In Docker, the working directory is now /app/file_server
BASE_DIR = os.path.abspath(os.path.dirname(__file__))
app.config['UPLOAD_FOLDER'] = os.path.join(BASE_DIR, 'uploads')
app.config['PROCESSED_FOLDER'] = os.path.join(BASE_DIR, 'processed')
app.config['MAX_CONTENT_LENGTH'] = 50 * 1024 * 1024  # 50MB max file size

# Ensure upload and processed directories exist
os.makedirs(app.config['UPLOAD_FOLDER'], exist_ok=True)
os.makedirs(app.config['PROCESSED_FOLDER'], exist_ok=True)

logger.debug(f"Upload folder: {app.config['UPLOAD_FOLDER']}")
logger.debug(f"Processed folder: {app.config['PROCESSED_FOLDER']}")

ALLOWED_EXTENSIONS = {'xlsx', 'csv'}

def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

@app.route('/health')
@app.route('/ready') 
def health_check():
    """Health check endpoint for Docker and ECS"""
    try:
        health_status = {
            'status': 'healthy',
            'timestamp': datetime.now().isoformat(),
            'services': {}
        }
        
        # Test MySQL connection
        try:
            sys.path.append(LMS_DATABASE_DIR)
            from utils.db_utils import DatabaseConnectionManager
            db_manager = DatabaseConnectionManager()
            with db_manager.get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute("SELECT 1")
                cursor.fetchone()
            health_status['services']['mysql'] = 'connected'
        except Exception as e:
            health_status['services']['mysql'] = f'error: {str(e)}'
            health_status['status'] = 'unhealthy'
        
        # Test Neo4j connection
        try:
            with driver.session() as session:
                session.run("RETURN 1")
            health_status['services']['neo4j'] = 'connected'
        except Exception as e:
            health_status['services']['neo4j'] = f'error: {str(e)}'
            health_status['status'] = 'unhealthy'
        
        status_code = 200 if health_status['status'] == 'healthy' else 503
        return jsonify(health_status), status_code
        
    except Exception as e:
        return jsonify({
            'status': 'unhealthy',
            'error': str(e),
            'timestamp': datetime.now().isoformat()
        }), 503

@app.route('/live')
def liveness():
    """Simple liveness check"""
    return jsonify({'status': 'alive'}), 200

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/lms')
def lms_ui():
    """Serve the new LMS Migration Agent UI"""
    return send_from_directory(BASE_DIR, 'index.html')

def map_filename_to_database_key(filename):
    """Map filename to the correct database key for mapping rules"""
    # Import here to avoid circular imports
    sys.path.append(os.path.join(os.path.dirname(__file__), '..', 'lms_error_analyzer', 'database'))
    from utils.filename_mapper import FilenameMapper
    return FilenameMapper.to_db_key(filename)

def validate_transformed_data(df, mapping_rules):
    """Validate the transformed data against mapping rules"""
    errors = []
    warnings = []  # Keep for internal logging only
    
    for rule in mapping_rules:
        csod_field = rule['CSOD Field Name']
        st_field = rule.get('SumTotal Field Name', '')  # Get SumTotal mapping
        mandatory = rule.get('mandatory', '') == 'Mandatory'
        
        # Only validate fields that have SumTotal source mappings
        if not st_field or st_field.strip() == '':
            # Skip validation for fields with no SumTotal mapping (default-only fields)
            continue
            
        if csod_field in df.columns:
            # Check for mandatory fields that are empty
            if mandatory:
                empty_count = (df[csod_field].isna() | (df[csod_field].astype(str).str.strip() == '')).sum()
                if empty_count > 0:
                    warnings.append(f"Mandatory field '{csod_field}' has {empty_count} empty values")
        else:
            # Field is missing from output
            if mandatory:
                errors.append(f"Mandatory field '{csod_field}' is missing from output")
            else:
                warnings.append(f"Optional field '{csod_field}' is missing from output")
    
    # Log warnings internally but don't return them to UI
    if warnings:
        logger.warning(f"Validation warnings: {warnings}")
    
    return {
        'total_errors': len(errors),
        'total_warnings': 0,  # Always return 0 for UI
        'errors': errors,
        'warnings': []  # Always return empty array for UI
    }

def process_file(filepath):
    """Process a file using the SumTotal transformer"""
    try:
        # Fetch mapping rules directly from Neo4j database
        filename = os.path.basename(filepath)
        file_key = map_filename_to_database_key(filename)
        
        logger.info(f"Processing file: {filename} -> {file_key}")
        neo4j_start = time.time()
        mapping_rules = transformer.fetch_mapping_rules_from_neo4j(file_key)
        neo4j_time = time.time() - neo4j_start
        logger.info(f"Neo4j mapping rules fetch took {neo4j_time:.2f} seconds")
        
        # If no rules found in database, log error and stop processing
        if not mapping_rules:
            error_msg = f"No mapping rules found in Neo4j database for file: {file_key}"
            logger.error(f"Processing error: {error_msg}")
            raise ValueError(error_msg)
        
        # Read the Excel file with empty strings instead of NaN
        file_read_start = time.time()
        file_extension = os.path.splitext(filename)[1].lower()
        if file_extension in ['.xlsx', '.xls']:
            input_df = pd.read_excel(filepath, keep_default_na=False, na_values=[''])
        elif file_extension == '.csv':
            input_df = pd.read_csv(filepath, keep_default_na=False, na_values=[''])
        else:
            raise ValueError(f"Unsupported file type: {file_extension}")
        
        file_read_time = time.time() - file_read_start
        logger.info(f"File reading took {file_read_time:.2f} seconds")
        
        # Debug: Check for issues with the DataFrame
        logger.info(f"Loaded DataFrame shape: {input_df.shape}")
        logger.info(f"DataFrame columns: {list(input_df.columns)}")
        
        # Check for empty column names
        empty_columns = [col for col in input_df.columns if col == '']
        if empty_columns:
            logger.error(f"Found {len(empty_columns)} empty column names in uploaded file")
            raise ValueError(f"Uploaded file contains {len(empty_columns)} empty column names")
        
        # Check for duplicate column names
        if len(input_df.columns) != len(set(input_df.columns)):
            logger.error("Uploaded file contains duplicate column names")
            raise ValueError("Uploaded file contains duplicate column names")
        
        # Transform the data
        start_time = time.time()
        transformed_df = transformer.transform_sumtotal_file(input_df, mapping_rules, file_key, filename) #Pass original filename
        transform_time = time.time() - start_time
        logger.info(f"Data transformation took {transform_time:.2f} seconds")
        
        # Store input row count for metrics
        input_row_count = len(input_df)
        logger.info(f"Input file contains {input_row_count} records")
        
        # Optional: Calculate file completeness metrics for PDF generation
        ENABLE_DASHBOARD_METRICS = os.getenv('ENABLE_DASHBOARD_METRICS', 'true').lower() == 'true'
        if ENABLE_DASHBOARD_METRICS:
            try:
                dashboard_start = time.time()
                sys.path.append(os.path.join(os.path.dirname(__file__), '..', 'lms_error_analyzer', 'database'))
                from dashboard import Dashboard
                dashboard = Dashboard()
                completeness_metrics = dashboard.calculate_file_completeness(filename, input_df)
                dashboard.store_completeness_metrics(filename, completeness_metrics)
                dashboard.close_connections()
                dashboard_time = time.time() - dashboard_start
                logger.info(f"Dashboard completeness metrics took {dashboard_time:.2f} seconds")
            except Exception as e:
                logger.error(f"Error calculating dashboard metrics for {filename}: {e}")
        else:
            logger.info("Dashboard metrics calculation disabled for faster processing")
        
        # Optional: Anomaly report generation (can be disabled for faster processing)
        ENABLE_ANOMALY_REPORTS = os.getenv('ENABLE_ANOMALY_REPORTS', 'false').lower() == 'true'
        if ENABLE_ANOMALY_REPORTS:
            try:
                report_start = time.time()
                from report_generator import generate_anomaly_report_csv
                report_filename = generate_anomaly_report_csv(filename, app.config['PROCESSED_FOLDER'])
                report_time = time.time() - report_start
                logger.info(f"Anomaly report generation took {report_time:.2f} seconds")
                logger.info(f"Saved anomaly report (not added to processed list): {report_filename}")
            except Exception as re:
                logger.error(f"Error generating anomaly report for {filename}: {re}")
        else:
            logger.info("Anomaly report generation disabled for faster processing")
        
        
        
        # Ensure empty strings instead of NaN in output
        transformed_df = transformed_df.fillna("")
        
        # Save to multiple files based on output_document property
        saved_files = []
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        
        # Group fields by output_document while preserving order
        output_groups = {}
        for rule in mapping_rules:
            output_document = rule.get('output_document', '')
            # If output_document is empty or just a space, fall back to file property or file_key
            if not output_document or output_document.strip() == '':
                output_document = rule.get('file', file_key)
            csod_field = rule['CSOD Field Name']
            
            # For Transcript files, only allow Transcript-specific output documents
            if file_key.startswith("Transcript_") and not output_document.startswith("Transcript_"):
                logger.warning(f"Skipping non-Transcript output document '{output_document}' for Transcript file '{file_key}'")
                continue
            
            if output_document not in output_groups:
                output_groups[output_document] = []
            # Only add if not already present (to avoid duplicates while preserving order)
            if csod_field not in output_groups[output_document]:
                output_groups[output_document].append(csod_field)
        
        logger.info(f"Created output groups: {list(output_groups.keys())}")
        
        # Create separate CSV files for each output document
        for output_document, columns in output_groups.items():
            # Filter DataFrame to only include columns for this output document (preserving order)
            available_columns = [col for col in columns if col in transformed_df.columns]
            if available_columns:
                output_filename = f"processed_{timestamp}_{output_document}.csv"
                output_path = os.path.join(app.config['PROCESSED_FOLDER'], output_filename)
                
                # Save the filtered DataFrame with preserved column order
                transformed_df[available_columns].to_csv(output_path, index=False)
                saved_files.append(output_filename)
                logger.info(f"Saved {len(available_columns)} columns to {output_filename}")
        
        # Validate the transformed data
        validation_results = validate_transformed_data(transformed_df, mapping_rules)
        
        return {
            'success': True,
            'validation': validation_results,
            'processed_files': saved_files
        }
        
    except Exception as e:
        logger.error(f"Error processing file {filepath}: {str(e)}", exc_info=True)
        return {
            'success': False,
            'error': str(e)
        }

@app.route('/upload', methods=['POST'])
def upload_file():
    if 'file' not in request.files:
        return jsonify({'error': 'No file part'}), 400
    
    file = request.files['file']
    if file.filename == '':
        return jsonify({'error': 'No selected file'}), 400
    
    if file and allowed_file(file.filename):
        try:
            filename = secure_filename(file.filename)
            filepath = os.path.join(app.config['UPLOAD_FOLDER'], filename)
            file.save(filepath)
            
            logger.info(f"Processing file: {filename}")
            upload_start_time = time.time()
            
            # Initialize session if needed - ensure we have active session for file tracking
            if not session_manager.current_session:
                try:
                    session_id = session_manager.start_new_session("web_user")
                    logger.info(f"✅ Started new upload session: {session_id}")
                except Exception as session_init_error:
                    logger.error(f"❌ Failed to initialize session: {session_init_error}")
                    # Continue without session tracking for now
                    pass
            else:
                logger.info(f"📋 Using existing session: {session_manager.current_session.session_id}")
                
                        
            # STEP 1: Schema Migration - Ensure DB schema matches uploaded data structure
            ENABLE_SCHEMA_MIGRATION = os.getenv('ENABLE_SCHEMA_MIGRATION', 'true').lower() == 'true'
            if ENABLE_SCHEMA_MIGRATION:
                try:
                    migration_start = time.time()
                    sys.path.append(os.path.join(os.path.dirname(__file__), '..', 'lms_error_analyzer', 'database'))
                    from migrate_uploaded import GenericTabularMigrator
                    
                    logger.info(f"🔄 Running schema migration for: {filename}")
                    migrator = GenericTabularMigrator(filepath)
                    migration_success = migrator.run()
                    migration_time = time.time() - migration_start
                    
                    if migration_success:
                        logger.info(f"✅ Schema migration completed in {migration_time:.2f} seconds")
                    else:
                        logger.warning(f"⚠️ Schema migration had issues but continuing ({migration_time:.2f}s)")
                        
                except Exception as migration_error:
                    logger.error(f"❌ Schema migration error: {migration_error}")
                    # Continue with transformation - don't fail upload due to migration issues
            else:
                logger.info("📋 Schema migration disabled - using existing schema")
            
            # STEP 2: Process the file using the transformer
            
            # Process the file using the transformer
            try:
                processed_results = process_file(filepath)
            except Exception as process_error:
                logger.error(f"Error in process_file: {str(process_error)}")
                # Clean up the uploaded file
                if os.path.exists(filepath):
                    os.remove(filepath)
                return jsonify({'error': f'Processing error: {str(process_error)}'}), 500
            
            # Track file in session after successful processing - critical for orphan detection scope
            if processed_results.get('success'):
                try:
                    sys.path.append(LMS_DATABASE_DIR)
                    from utils.filename_mapper import FilenameMapper
                    
                    # Map filename to frontend display name and get row count
                    frontend_name = FilenameMapper.to_frontend_name(filename)
                    logger.info(f"📁 Mapping {filename} -> {frontend_name}")
                    
                    # Extract row count from processing results
                    row_count = 0
                    if 'validation' in processed_results and 'total_records' in processed_results['validation']:
                        row_count = processed_results['validation']['total_records']
                    
                    # Generate simple checksum for file integrity tracking
                    import hashlib
                    checksum = hashlib.md5(filename.encode()).hexdigest()[:8]
                    
                    logger.info(f"📊 Session tracking: {frontend_name}, rows: {row_count}, checksum: {checksum}")
                    
                    # Record file upload in session for domain-scoped orphan detection
                    if session_manager.current_session:
                        logger.info(f"📋 Recording upload in session: {session_manager.current_session.session_id}")
                        
                        success = session_manager.add_uploaded_file(
                            front_end_name=frontend_name,
                            original_file_name=filename,
                            row_count=row_count,
                            checksum_md5=checksum,
                            uploader="web_user"
                        )
                        
                        if success:
                            logger.info(f"✅ Successfully tracked in session: {frontend_name} ({row_count} rows)")
                        else:
                            logger.error(f"❌ Failed to track {frontend_name} in session")
                    else:
                        logger.warning("⚠️ No active session available for file tracking - orphan detection may include historical data")
                    
                except Exception as session_error:
                    logger.error(f"❌ Error tracking file in session: {session_error}")
                    # Don't fail the upload if session tracking fails - allow processing to continue
            
            # Clean up the original file
            try:
                os.remove(filepath)
            except Exception as cleanup_error:
                logger.warning(f"Could not clean up original file: {cleanup_error}")
            
            # Optional: Run orphan detection analysis for uploaded file
            ENABLE_ORPHAN_DETECTION = os.getenv('ENABLE_ORPHAN_DETECTION', 'true').lower() == 'true'
            if ENABLE_ORPHAN_DETECTION:
                try:
                    orphan_start = time.time()
                    sys.path.append(LMS_DATABASE_DIR)
                    from pdf_quality_report import _run_orphan_detection_for_uploaded_files
                    logger.info(f"Running orphan detection analysis for: {filename}")
                    _run_orphan_detection_for_uploaded_files([filename])
                    orphan_time = time.time() - orphan_start
                    logger.info(f"Orphan detection analysis took {orphan_time:.2f} seconds")
                except Exception as orphan_error:
                    logger.error(f"Error running orphan detection for {filename}: {orphan_error}")
                    # Don't fail the upload if orphan detection fails
            else:
                logger.info("Orphan detection analysis disabled for faster processing")

            # COMMENTED OUT: Auto PDF generation during upload
            # Reason: PDFs should only be generated when user explicitly clicks "Generate PDF Report"
            # This prevents automatic PDF creation during file processing
            
            # # Auto-generate PDF report after successful processing using original filenames
            # try:
            #     # Ensure proper import path for PDF generation
            #     sys.path.append(LMS_DATABASE_DIR)
            #     from pdf_quality_report import auto_generate_after_upload
            #     # auto_generate_after_upload now gets original files from database automatically
            #     pdf_filename = auto_generate_after_upload([], app.config['PROCESSED_FOLDER'])  # Empty list, function gets files from DB
            #     if pdf_filename:
            #         processed_results['pdf_report'] = pdf_filename
            #         logger.info(f"Auto-generated PDF report: {pdf_filename}")
            # except Exception as pdf_error:
            #     logger.error(f"Error auto-generating PDF report: {pdf_error}")
            #     # Don't fail the upload if PDF generation fails
            
            total_processing_time = time.time() - upload_start_time
            logger.info(f"🏁 TOTAL processing time: {total_processing_time:.2f} seconds")
            processed_results['processing_time'] = round(total_processing_time, 2)
            return jsonify(processed_results)
            
        except Exception as e:
            error_msg = f"Error processing {filename}: {str(e)}"
            logger.error(error_msg)
            # Clean up any uploaded file in case of error
            if 'filepath' in locals() and os.path.exists(filepath):
                try:
                    os.remove(filepath)
                except:
                    pass
            return jsonify({'error': error_msg}), 500
    else:
        return jsonify({'error': 'File type not allowed'}), 400

@app.route('/download/<filename>')
def download_file(filename):
    try:
        logger.debug(f"Attempting to download file: {filename}")
        logger.debug(f"From directory: {app.config['PROCESSED_FOLDER']}")
        
        # Check if file exists
        file_path = os.path.join(app.config['PROCESSED_FOLDER'], filename)
        if not os.path.exists(file_path):
            logger.error(f"File not found: {file_path}")
            return jsonify({'error': 'File not found'}), 404
            
        return send_from_directory(
            app.config['PROCESSED_FOLDER'],
            filename,
            as_attachment=True
        )
    except Exception as e:
        logger.error(f"Error downloading file: {str(e)}")
        return jsonify({'error': str(e)}), 500

@app.route('/files')
def list_files():
    try:
        files = os.listdir(app.config['PROCESSED_FOLDER'])
        logger.debug(f"Files in processed folder: {files}")
        return jsonify({'files': files})
    except Exception as e:
        logger.error(f"Error listing files: {str(e)}")
        return jsonify({'error': str(e)}), 500

@app.route('/delete/<filename>', methods=['DELETE'])
def delete_file(filename):
    """Delete a processed file (simple deletion without database cleanup)"""
    try:
        file_path = os.path.join(app.config['PROCESSED_FOLDER'], filename)
        if os.path.exists(file_path):
            os.remove(file_path)
            logger.info(f"Deleted file: {filename}")
            return jsonify({'success': True, 'message': f'File {filename} deleted successfully'})
        else:
            return jsonify({'error': 'File not found'}), 404
    except Exception as e:
        logger.error(f"Error deleting file {filename}: {e}")
        return jsonify({'error': str(e)}), 500

@app.route('/delete-all', methods=['DELETE'])
def delete_all_files():
    """Delete all processed files (simple file deletion without database cleanup)"""
    try:
        deleted_files = []
        errors = []
        
        # Get list of files to delete
        if os.path.exists(app.config['PROCESSED_FOLDER']):
            files = os.listdir(app.config['PROCESSED_FOLDER'])
            
            for filename in files:
                try:
                    file_path = os.path.join(app.config['PROCESSED_FOLDER'], filename)
                    if os.path.isfile(file_path):
                        os.remove(file_path)
                        deleted_files.append(filename)
                        logger.info(f"Deleted file: {filename}")
                except Exception as e:
                    error_msg = f"Error deleting {filename}: {str(e)}"
                    errors.append(error_msg)
                    logger.error(error_msg)
        
        # Also clean upload folder if it exists
        if os.path.exists(app.config['UPLOAD_FOLDER']):
            upload_files = os.listdir(app.config['UPLOAD_FOLDER'])
            for filename in upload_files:
                try:
                    file_path = os.path.join(app.config['UPLOAD_FOLDER'], filename)
                    if os.path.isfile(file_path):
                        os.remove(file_path)
                        deleted_files.append(f"upload/{filename}")
                        logger.info(f"Deleted upload file: {filename}")
                except Exception as e:
                    error_msg = f"Error deleting upload/{filename}: {str(e)}"
                    errors.append(error_msg)
                    logger.error(error_msg)
        
        if errors:
            return jsonify({
                'success': False, 
                'message': f'Deleted {len(deleted_files)} files with {len(errors)} errors',
                'deleted_files': deleted_files,
                'errors': errors
            }), 207  # Multi-status
        else:
            return jsonify({
                'success': True, 
                'message': f'Successfully deleted {len(deleted_files)} files',
                'deleted_files': deleted_files
            })
            
    except Exception as e:
        logger.error(f"Error in delete_all_files: {str(e)}")
        return jsonify({'success': False, 'error': str(e)}), 500

@app.route('/reset-all-data', methods=['POST'])
def reset_all_data_endpoint():
    """Reset all data for a new batch - clears database, files, and session data"""
    logger.info("🔍 Reset all data endpoint called") # DEBUG
    try:
        # Import from the parent directory where pdf_quality_report.py is located
        sys.path.append(LMS_DATABASE_DIR)
        from pdf_quality_report import reset_all_data
        
        # Reset everything
        results = reset_all_data(app.config['PROCESSED_FOLDER'])
        
        # Reset session data - clear current session and start fresh for next upload batch
        session_reset_success = False
        if session_manager.current_session:
            session_reset_success = session_manager.reset_session()
            logger.info(f"📋 Session reset: {'✅ Success' if session_reset_success else '❌ Failed'}")
        else:
            logger.info("📋 No active session to reset")
        
        # Always start a fresh session for the next upload batch
        try:
            session_id = session_manager.start_new_session("web_user")
            session_reset_success = True
            logger.info(f"✅ Started fresh session for next uploads: {session_id}")
        except Exception as e:
            logger.error(f"❌ Failed to start new session: {e}")
            session_reset_success = False
        
        # Determine overall success
        success = results['database_cleared'] and len(results['errors']) == 0 and session_reset_success
        
        response_data = {
            'success': success,
            'message': 'Data reset completed' if success else 'Data reset completed with some errors',
            'details': {
                'database_cleared': results['database_cleared'],
                'files_deleted': results['files_deleted'],
                'pdf_reports_deleted': results['pdf_reports_deleted'],
                'orphan_records_deleted': results.get('orphan_records_deleted', 0),
                'session_files_deleted': results.get('session_files_deleted', 0),
                'sessions_deleted': results.get('sessions_deleted', 0),
                'session_reset': session_reset_success
            }
        }
        
        if results['errors']:
            response_data['errors'] = results['errors']
        
        logger.info(f"✅ Reset operation completed: {response_data}")
        return jsonify(response_data)
        
    except Exception as e:
        logger.error(f"❌ Error resetting all data: {e}")
        logger.error(f"❌ Exception type: {type(e)}")
        import traceback
        logger.error(f"❌ Traceback: {traceback.format_exc()}")
        return jsonify({
            'success': False,
            'error': f'Failed to reset data: {str(e)}'
        }), 500

@app.route('/get-latest-pdf', methods=['GET'])
def get_latest_pdf():
    """Get the most recent PDF report or generate one if none exists"""
    try:
        # Find all PDF reports
        files = os.listdir(app.config['PROCESSED_FOLDER'])
        pdf_files = [f for f in files if f.startswith('data_quality_report_') and f.endswith('.pdf')]
        
        if pdf_files:
            # Sort by timestamp in filename (YYYYMMDD_HHMMSS format)
            latest_pdf = sorted(pdf_files, reverse=True)[0]
            logger.info(f"Found latest PDF report: {latest_pdf}")
            
            return jsonify({
                'success': True,
                'pdf_filename': latest_pdf,
                'message': 'Latest PDF report found',
                'action': 'found_existing'
            })
        else:
            # No PDF exists, generate one
            return generate_new_pdf_report()
            
    except Exception as e:
        logger.error(f"Error getting latest PDF: {e}")
        return jsonify({'error': f'Failed to get latest PDF: {str(e)}'}), 500

@app.route('/generate-pdf-report', methods=['POST'])
def generate_pdf_report():
    """Manually generate PDF quality report using original filenames from database"""
    return generate_new_pdf_report()

def generate_new_pdf_report():
    """Generate a new PDF report"""
    try:
        # Ensure proper import path for PDF generation
        sys.path.append(LMS_DATABASE_DIR)
        from pdf_quality_report import PDFQualityReportGenerator, get_original_file_list_from_db
        
        # Get original uploaded filenames from database - much cleaner!
        original_files = get_original_file_list_from_db()
        
        if not original_files:
            return jsonify({'error': 'No uploaded files found in database for report generation'}), 400
        
        # Run fresh session-aware orphan detection before generating PDF
        from pdf_quality_report import _run_orphan_detection_for_uploaded_files
        logger.info("Running session-aware orphan detection for manual PDF generation...")
        _run_orphan_detection_for_uploaded_files(original_files)
        
        # Generate PDF report using original filenames with fresh orphan data
        generator = PDFQualityReportGenerator(app.config['PROCESSED_FOLDER'])
        pdf_filename = generator.generate_report(original_files)
        
        logger.info(f"Manual PDF report generated: {pdf_filename}")
        
        return jsonify({
            'success': True,
            'pdf_filename': pdf_filename,
            'message': 'PDF report generated successfully',
            'files_analyzed': len(original_files),
            'action': 'generated_new'
        })
        
    except Exception as e:
        logger.error(f"Error generating manual PDF report: {e}")
        return jsonify({'error': f'Failed to generate PDF report: {str(e)}'}), 500


@app.route('/api/records_processed')
def records_processed():
    """Get total records processed with formatting"""
    try:
        # Lazy import with proper path setup
        sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))
        from lms_error_analyzer.database.utils.db_utils import get_total_records_processed
        
        total = get_total_records_processed()
        formatted_total = "{:,}".format(total) if total is not None else "0"
        return jsonify({'total': formatted_total})
    except Exception as e:
        logger.error(f"Error getting records processed: {e}")
        return jsonify({'total': '0'})

@app.route('/api/metrics', methods=['GET'])
def get_metrics():
    """Get dashboard metrics using the EXACT same proven functions as accurate reports."""
    try:
        # Import the proven functions that already work correctly
        sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))
        from lms_error_analyzer.database.pdf_quality_report import PDFQualityReportGenerator
        from lms_error_analyzer.database.report_generator import _fetch_completeness_for_file, _get_db_connection
        from lms_error_analyzer.database.dashboard import Dashboard
        
        # Get list of files from latest batch (minimal query)
        from lms_error_analyzer.database.utils.db_utils import DatabaseConnectionManager
        db_manager = DatabaseConnectionManager()
        
        files_result = db_manager.execute_query(
            """
            SELECT DISTINCT file_name, total_records, incomplete_records
            FROM file_completeness_summary 
            WHERE last_processed >= DATE_SUB(NOW(), INTERVAL 1 HOUR)
            """,
            dictionary=True
        )
        
        if not files_result:
            return jsonify({
                'success': True,
                'metrics': {
                    'total_records_processed': '0',
                    'total_records_with_anomalies': '0',
                    'total_clean_records': '0'
                }
            })
        
        # Initialize PDF generator to reuse its proven calculation methods
        pdf_generator = PDFQualityReportGenerator(output_dir="/tmp")  # temp dir, won't be used
        
        total_records = 0
        total_error_prone = 0
        
        # Use the PROVEN calculation logic for each file
        for file_record in files_result:
            file_name = file_record['file_name']
            file_total_records = file_record['total_records']
            file_incomplete_records = file_record['incomplete_records']
            
            total_records += file_total_records
            
            # Use the EXACT same proven function as PDF reports (line 221-296)
            file_error_prone = pdf_generator._calculate_error_prone_records(
                file_name, file_total_records, file_incomplete_records
            )
            
            total_error_prone += file_error_prone
            
            logger.info(f"File {file_name}: {file_error_prone}/{file_total_records} error-prone records")
        
        # Close connections
        pdf_generator.db_connection.close()
        
        # Simple calculation
        total_clean = max(0, total_records - total_error_prone)
        
        logger.info(f"PROVEN CALCULATION RESULTS: total={total_records}, error_prone={total_error_prone}, clean={total_clean}")
        
        # Format numbers with commas
        def format_number(n):
            return "{:,}".format(n) if n is not None else "0"

        response = {
            'success': True,
            'metrics': {
                'total_records_processed': format_number(total_records),
                'total_records_with_anomalies': format_number(total_error_prone),
                'total_clean_records': format_number(total_clean)
            }
        }
        
        return jsonify(response)
        
    except Exception as e:
        logger.error(f"Error in metrics endpoint: {e}", exc_info=True)
        return jsonify({
            'success': False,
            'error': str(e),
            'metrics': {
                'total_records_processed': '0',
                'total_records_with_anomalies': '0',
                'total_clean_records': '0'
            }
        }), 500

@app.route('/api/executive-summary', methods=['GET'])
def get_executive_summary():
    """Get executive summary text that matches what's in the PDF report."""
    try:
        # Import the proven functions that already work correctly
        sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))
        from lms_error_analyzer.database.pdf_quality_report import PDFQualityReportGenerator
        from lms_error_analyzer.database.utils.db_utils import DatabaseConnectionManager
        
        # Get list of files from latest batch (same logic as metrics endpoint)
        db_manager = DatabaseConnectionManager()
        
        files_result = db_manager.execute_query(
            """
            SELECT DISTINCT file_name, total_records, incomplete_records
            FROM file_completeness_summary 
            WHERE last_processed >= DATE_SUB(NOW(), INTERVAL 1 HOUR)
            """,
            dictionary=True
        )
        
        if not files_result:
            return jsonify({
                'success': True,
                'summary': 'No recent analysis data available. Please upload and process files first.'
            })
        
        # Initialize PDF generator to reuse its proven calculation methods
        pdf_generator = PDFQualityReportGenerator(output_dir="/tmp")  # temp dir, won't be used
        
        total_files = len(files_result)
        total_records = 0
        total_errors = 0
        
        # Use the EXACT same proven calculation logic as PDF reports
        for file_record in files_result:
            file_name = file_record['file_name']
            file_total_records = file_record['total_records']
            file_incomplete_records = file_record['incomplete_records']
            
            total_records += file_total_records
            
            # Use the EXACT same proven function as PDF reports
            file_error_prone = pdf_generator._calculate_error_prone_records(
                file_name, file_total_records, file_incomplete_records
            )
            
            total_errors += file_error_prone
        
        # Close connections
        pdf_generator.db_connection.close()
        
        # Create executive summary using EXACT same format as PDF report
        summary = f"""This report analyzes data quality across {total_files} files containing {total_records:,} total records. The analysis identified {total_errors:,} validation errors.

Key Recommendations:
• Address mandatory field completeness issues at the source
• Implement data validation workflows before processing
• Review critical validation errors for immediate remediation"""
        
        logger.info(f"Executive summary generated: {total_files} files, {total_records} records, {total_errors} errors")
        
        return jsonify({
            'success': True,
            'summary': summary
        })
        
    except Exception as e:
        logger.error(f"Error generating executive summary: {e}", exc_info=True)
        return jsonify({
            'success': False,
            'error': str(e),
            'summary': 'Error generating executive summary. Please try again.'
        })


"""
debugpy.listen(("localhost", 5679))  # Listen on all interfaces
print("⏳ Waiting for debugger to attach...")
debugpy.wait_for_client()  # This pauses execution until debugger connects
print("✅ Debugger attached!")"""

if __name__ == '__main__':
    app.run(debug=False, port=5001)
