from flask import Flask, render_template, request, send_from_directory, jsonify
import os
import sys
from werkzeug.utils import secure_filename
import time
import pandas as pd
from datetime import datetime

# Add the parent directory to Python path to find the lasVegas package
parent_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
sys.path.append(parent_dir)

# Import the transformer and required modules
from lasVegas.app import sumtotal_transformer_with_neo4j as transformer
from dotenv import load_dotenv
from neo4j import GraphDatabase

# Load environment variables
load_dotenv()

# Initialize Neo4j connection
NEO4J_URI = os.getenv('NEO4J_URI', 'bolt://localhost:7687')
NEO4J_USER = os.getenv('NEO4J_USER', 'neo4j')
NEO4J_PASSWORD = os.getenv('NEO4J_PASSWORD')

if not NEO4J_PASSWORD:
    raise ValueError("NEO4J_PASSWORD environment variable is required")

app = Flask(__name__)
driver = GraphDatabase.driver(NEO4J_URI, auth=(NEO4J_USER, NEO4J_PASSWORD))

# Define base directories
BASE_DIR = os.path.abspath(os.path.dirname(__file__))
app.config['UPLOAD_FOLDER'] = os.path.join(BASE_DIR, 'uploads')
app.config['PROCESSED_FOLDER'] = os.path.join(BASE_DIR, 'processed')
app.config['MAX_CONTENT_LENGTH'] = 50 * 1024 * 1024  # 50MB max file size

# Ensure upload and processed directories exist
os.makedirs(app.config['UPLOAD_FOLDER'], exist_ok=True)
os.makedirs(app.config['PROCESSED_FOLDER'], exist_ok=True)

ALLOWED_EXTENSIONS = {'xlsx'}

def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

@app.route('/')
def index():
    return render_template('index.html')

def process_file(filepath, original_filename):
    """Process a file using the SumTotal transformer"""
    try:
        # Read the Excel file with empty strings instead of NaN
        try:
            df = pd.read_excel(filepath, keep_default_na=False, na_values=[''])
            app.logger.info(f"Successfully read Excel file with {len(df)} rows and {len(df.columns)} columns")
        except Exception as e:
            raise ValueError(f"Error reading Excel file {original_filename}: {str(e)}")
        
        # Determine file category using original filename
        if "Employee" in original_filename:
            file_category = "Core"
        elif "Facility" in original_filename:
            file_category = "Prerequisites"
        elif "Curriculum" in original_filename or "Course" in original_filename:
            file_category = "Activity"
        elif "Transcript" in original_filename:
            file_category = "Transcript"
            
        if not file_category:
            app.logger.warning(f"Could not determine category for file: {original_filename}, defaulting to 'Activity'")
            file_category = "Activity"

        # Get the rules for this file type based on the original filename without extension
        # Do not use secure_filename here - we want to preserve the original name for lookups
        file_key = os.path.splitext(original_filename)[0]
        app.logger.info(f"Looking up mapping rules for file key: {file_key}")
        
        try:
            mapping_rules = transformer.fetch_mapping_rules_from_neo4j(driver)
        except Exception as e:
            app.logger.error("Failed to fetch mapping rules from Neo4j")
            raise ValueError(f"Database error: {str(e)}")

        if file_key not in mapping_rules:
            app.logger.info(f"No mappings found for {file_key}, creating default 1:1 mapping")
            # Create default 1:1 mapping
            mapping_rules[file_key] = [
                {"CSOD Field Name": col, "SumTotal Field Name": col}
                for col in df.columns
            ]
        
        # Transform the file
        try:
            processed_data = transformer.transform_sumtotal_file(df, mapping_rules[file_key], file_key)
            app.logger.info(f"Successfully transformed file data for {original_filename}")
        except Exception as e:
            raise ValueError(f"Error transforming file {original_filename}: {str(e)}")
        
        # Save the processed file
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        base_filename = os.path.splitext(original_filename)[0]  # Remove the original extension
        # Keep original filename in output but use underscore for timestamp
        processed_filename = f"{base_filename}_processed_{timestamp}.csv"  # Add .csv extension
        output_path = os.path.join(app.config['PROCESSED_FOLDER'], processed_filename)
        processed_data.to_csv(output_path, index=False)
        
        return processed_filename
        
    except Exception as e:
        app.logger.error(f"Error processing file {original_filename}: {str(e)}")
        raise ValueError(f"Processing failed: {str(e)}")

@app.route('/upload', methods=['POST'])
def upload_file():
    """Upload and process a file."""
    if 'file' not in request.files:
        return jsonify({'error': 'No file part'}), 400
    
    file = request.files['file']
    if file.filename == '':
        return jsonify({'error': 'No selected file'}), 400
    
    if file and allowed_file(file.filename):
        try:
            # Store the original filename before any modifications
            original_filename = file.filename
            
            # Use secure_filename for storage
            storage_filename = secure_filename(original_filename)
            filepath = os.path.join(app.config['UPLOAD_FOLDER'], storage_filename)
            file.save(filepath)
            
            # Process the file using the original filename
            processed_filename = process_file(filepath, original_filename)
            
            # Clean up the original file
            os.remove(filepath)
            
            return jsonify({
                'message': 'File successfully uploaded and processed',
                'processed_file': processed_filename
            })
            
        except Exception as e:
            # Clean up any uploaded file in case of error
            if os.path.exists(filepath):
                os.remove(filepath)
            return jsonify({'error': str(e)}), 500
    
    return jsonify({'error': 'File type not allowed'}), 400

@app.route('/download/<filename>')
def download_file(filename):
    return send_from_directory(app.config['PROCESSED_FOLDER'], filename)

@app.route('/files')
def list_files():
    files = os.listdir(app.config['PROCESSED_FOLDER'])
    return jsonify({'files': files})

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

@app.teardown_appcontext
def close_neo4j_driver(error):
    """Close the Neo4j driver when the app context is torn down."""
    if hasattr(app, 'driver'):
        driver.close()

if __name__ == '__main__':
    app.run(debug=True, port=5000)
