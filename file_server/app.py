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
        "Transcript_Curriculum": "Transcript_Curriculum",
        "Transcript_Document": "Transcript_Materials", 
        "Transcript_ILTClass": "Transcript_Sessions",
        "Transcript_OnlineCourse": "Transcript_OnlineCourse",
        "Transcript_QuickAssessment": "Transcript_Tests",
        
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
        "Prerequisites_QuestionBanks": "Prerequisites_QuestionCategories",
        "Prerequisites_Subject": "Prerequisites_Subject"
    }
    
    # Return mapped key if exists, otherwise return original
    mapped_key = filename_mappings.get(file_key, file_key)
    
    return mapped_key

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
            logger.error(error_msg)
            raise ValueError(error_msg)
        
        # Read the Excel file with empty strings instead of NaN
        file_extension = os.path.splitext(filepath)[1].lower()
        if file_extension == '.xlsx':
            df = pd.read_excel(filepath, keep_default_na=False, na_values=[''])
        elif file_extension == '.csv':
            df = pd.read_csv(filepath, keep_default_na=False, na_values=[''], encoding='utf-8')
        else:
            raise ValueError(f"Unsupported file type: {file_extension}")
        
        # Determine file category
        if "Core" in filename:
            file_category = "Core"
        elif "Prerequisites" in filename:
            file_category = "Prerequisites"
        elif "Activity" in filename or "Course" in filename or "Activity" in filename:
            file_category = "Activity"
        elif "Transcript" in filename:
            file_category = "Transcript"
            
        if not file_category:
            raise ValueError(f"Could not determine category for file: {filename}")
        
        # Convert DataFrame to list of dictionaries for the new transform_data function
        data = df.to_dict('records')
        
        # Transform the data using the new function
        transformed_data = transformer.transform_data(data, mapping_rules)
        
        # Convert back to DataFrame
        processed_data = pd.DataFrame(transformed_data)
        
        # Save the processed file
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        processed_filename = f"processed_{timestamp}_{file_key}.csv"  # Use CSOD file type name
        processed_filepath = os.path.join(app.config['PROCESSED_FOLDER'], processed_filename)
        
        # Save as CSV with empty strings for missing values and prevent float conversion
        processed_data.to_csv(processed_filepath, index=False, na_rep="", encoding='utf-8-sig', float_format='%.0f')
        logger.info(f"Saved processed file: {processed_filename}")
        return processed_filename
        
    except Exception as e:
        logger.error(f"Error in process_file: {str(e)}")
        raise Exception(f"Error processing file {filepath}: {str(e)}")

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
                processed_filename = process_file(filepath)
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
            
            return jsonify({
                'message': 'File successfully processed',
                'processed_file': processed_filename
            })
            
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
