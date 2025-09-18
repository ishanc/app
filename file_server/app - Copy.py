from flask import Flask, render_template, request, send_from_directory, jsonify
import os
import sys
#sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))
#sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'lasVegas', 'app')))
#sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..', 'lms_error_analyzer', 'database')))
#import sys
#sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..')))
#import sys
from werkzeug.utils import secure_filename
import time
import pandas as pd
from datetime import datetime
import logging
import debugpy
from typing import List, Optional
from lms_error_analyzer.database.pdf_quality_report import get_total_records_processed
#from pdf_quality_report import get_total_records_processed

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


#sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

#sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'lasVegas', 'app')))
import sumtotal_transformer_with_neo4j as transformer

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

@app.route('/')
def index():
    return render_template('index.html')

def map_filename_to_database_key(filename):
    """Map filename to the correct database key for mapping rules"""
    # Import here to avoid circular imports
   # sys.path.append(os.path.join(os.path.dirname(__file__), '..', 'lms_error_analyzer', 'database'))
    from utils.filename_mapper import FilenameMapper
    return FilenameMapper.to_db_key(filename)

def validate_transformed_data(df, mapping_rules):
    """Validate the transformed data against mapping rules"""
    errors = []
    warnings = []  # Keep for internal logging only
    
    for rule in mapping_rules:
        csod_field = rule['CSOD Field Name']
        mandatory = rule.get('mandatory', '') == 'Mandatory'
        
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
        mapping_rules = transformer.fetch_mapping_rules_from_neo4j(file_key)
        
        # If no rules found in database, log error and stop processing
        if not mapping_rules:
            error_msg = f"No mapping rules found in Neo4j database for file: {file_key}"
            logger.error(f"Processing error: {error_msg}")
            raise ValueError(error_msg)
        
        # Read the Excel file with empty strings instead of NaN
        file_extension = os.path.splitext(filename)[1].lower()
        if file_extension in ['.xlsx', '.xls']:
            input_df = pd.read_excel(filepath, keep_default_na=False, na_values=[''])
        elif file_extension == '.csv':
            input_df = pd.read_csv(filepath, keep_default_na=False, na_values=[''])
        else:
            raise ValueError(f"Unsupported file type: {file_extension}")
        
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
        transformed_df = transformer.transform_sumtotal_file(input_df, mapping_rules, file_key, filename) #Pass original filename
        try:
            sys.path.append(os.path.join(os.path.dirname(__file__), '..', 'lms_error_analyzer', 'database'))
            from dashboard import Dashboard
            from report_generator import generate_anomaly_report_csv
            dashboard = Dashboard()
            completeness_metrics = dashboard.calculate_file_completeness(filename, input_df)
            dashboard.store_completeness_metrics(filename, completeness_metrics)
            dashboard.close_connections()
            # Generate MVP anomaly CSV report alongside processed files
            try:
                report_filename = generate_anomaly_report_csv(filename, app.config['PROCESSED_FOLDER'])
                logger.info(f"Saved anomaly report (not added to processed list): {report_filename}")
            except Exception as re:
                logger.error(f"Error generating anomaly report for {filename}: {re}")
        except Exception as e:
            logger.error(f"Error calculating completeness for {filename}: {e}")
        
        
        
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
            
            # Process the file using the transformer
            try:
                processed_results = process_file(filepath)
            except Exception as process_error:
                logger.error(f"Error in process_file: {str(process_error)}")
                # Clean up the uploaded file
                if os.path.exists(filepath):
                    os.remove(filepath)
                return jsonify({'error': f'Processing error: {str(process_error)}'}), 500
            
            # Clean up the original file
            try:
                os.remove(filepath)
            except Exception as cleanup_error:
                logger.warning(f"Could not clean up original file: {cleanup_error}")
            
            # Auto-generate PDF report after successful processing using original filenames
            try:
                from pdf_quality_report import auto_generate_after_upload
                # auto_generate_after_upload now gets original files from database automatically
                pdf_filename = auto_generate_after_upload([], app.config['PROCESSED_FOLDER'])  # Empty list, function gets files from DB
                if pdf_filename:
                    processed_results['pdf_report'] = pdf_filename
                    logger.info(f"Auto-generated PDF report: {pdf_filename}")
            except Exception as pdf_error:
                logger.error(f"Error auto-generating PDF report: {pdf_error}")
                # Don't fail the upload if PDF generation fails
            
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

@app.route('/reset-all-data', methods=['POST'])
def reset_all_data_endpoint():
    """Reset all data for a new batch - clears database and all processed files"""
    logger.info("🔍 Reset all data endpoint called") # DEBUG
    try:
        # Import from the parent directory where pdf_quality_report.py is located
        sys.path.append(os.path.join(os.path.dirname(__file__), '..'))
        from pdf_quality_report import reset_all_data
        
        # Reset everything
        results = reset_all_data(app.config['PROCESSED_FOLDER'])
        
        # Determine overall success
        success = results['database_cleared'] and len(results['errors']) == 0
        
        response_data = {
            'success': success,
            'message': 'Data reset completed' if success else 'Data reset completed with some errors',
            'details': {
                'database_cleared': results['database_cleared'],
                'files_deleted': results['files_deleted'],
                'pdf_reports_deleted': results['pdf_reports_deleted']
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

@app.route('/generate-pdf-report', methods=['POST'])
def generate_pdf_report():
    """Manually generate PDF quality report using original filenames from database"""
    try:
        from pdf_quality_report import PDFQualityReportGenerator, get_original_file_list_from_db
        
        # Get original uploaded filenames from database - much cleaner!
        original_files = get_original_file_list_from_db()
        
        if not original_files:
            return jsonify({'error': 'No uploaded files found in database for report generation'}), 400
        
        # Generate PDF report using original filenames
        generator = PDFQualityReportGenerator(app.config['PROCESSED_FOLDER'])
        pdf_filename = generator.generate_report(original_files)
        
        logger.info(f"Manual PDF report generated: {pdf_filename}")
        
        return jsonify({
            'success': True,
            'pdf_filename': pdf_filename,
            'message': f'PDF report generated successfully',
            'files_analyzed': len(original_files)
        })
        
    except Exception as e:
        logger.error(f"Error generating manual PDF report: {e}")
        return jsonify({'error': f'Failed to generate PDF report: {str(e)}'}), 500

@app.route('/quality-dashboard')
def quality_dashboard():
    """Get quality dashboard data for all processed files"""
    try:
        sys.path.append(os.path.join(os.path.dirname(__file__), '..', 'lms_error_analyzer', 'database'))
        from dashboard import Dashboard
        
        dashboard = Dashboard()
        try:
            quality_data = dashboard.generate_quality_dashboard()
            dashboard.close_connections()
            
            return jsonify({
                'success': True,
                'quality_data': quality_data,
                'total_files': len(quality_data)
            })
        except Exception as dashboard_error:
            dashboard.close_connections()
            raise dashboard_error
            
    except Exception as e:
        logger.error(f"Error getting quality dashboard: {e}")
        return jsonify({'error': f'Failed to get quality dashboard: {str(e)}'}), 500

"""
debugpy.listen(("localhost", 5679))  # Listen on all interfaces
print("⏳ Waiting for debugger to attach...")
debugpy.wait_for_client()  # This pauses execution until debugger connects
print("✅ Debugger attached!")"""



# Simple API endpoint to get total records processed on the front end
@app.route('/api/records_processed')
def records_processed():
    total = get_total_records_processed()  # Implement this function
    return jsonify({'total': total})

# Simple API endpoint to get total anomalies count on the front end
'''@app.route('/api/anomalies_count')
def anomalies_count():
    #from lms_error_analyzer.database.pdf_quality_report import get_total_anomalies
    count = get_total_anomalies()
    return jsonify({'anomalies': count})'''

if __name__ == '__main__':
    app.run(debug=False, port=5001)
