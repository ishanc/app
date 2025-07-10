from flask import Flask, render_template, request, send_from_directory, jsonify
import os
import sys
from werkzeug.utils import secure_filename
import time
import pandas as pd
from datetime import datetime
import logging

# Configure logging
logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger(__name__)

# Add the lasVegas app directory to Python path
LASVEGA_APP_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'lasVegas', 'app'))
sys.path.append(LASVEGA_APP_DIR)

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
    # Remove file extension
    file_key = os.path.splitext(filename)[0]
    
    # Define the mapping from incoming filenames to database file names
    # Simple one-to-one mappings for now
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
        transformed_df = transformer.transform_sumtotal_file(input_df, mapping_rules, file_key)
        
       
        
        
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
    """Delete a processed file"""
    try:
        file_path = os.path.join(app.config['PROCESSED_FOLDER'], filename)
        if os.path.exists(file_path):
            os.remove(file_path)
            return jsonify({'success': True, 'message': 'File deleted successfully'})
        else:
            return jsonify({'error': 'File not found'}), 404
    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(debug=True, port=5001)
