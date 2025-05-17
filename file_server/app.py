from flask import Flask, render_template, request, send_from_directory, jsonify
import os
import sys
from werkzeug.utils import secure_filename
import time
import pandas as pd
from datetime import datetime

# Add the lasVegas app directory to Python path
LASVEGA_APP_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'lasVegas', 'app'))
sys.path.append(LASVEGA_APP_DIR)

import sumtotal_transformer_with_neo4j as transformer

app = Flask(__name__)
app.config['UPLOAD_FOLDER'] = 'uploads'
app.config['PROCESSED_FOLDER'] = 'processed'
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

def process_file(filepath):
    """Process a file using the SumTotal transformer"""
    try:
        # Load Neo4j mapping rules using absolute path
        mapping_file = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'neo4j_knowledge_graph_cypher.txt'))
        if not os.path.exists(mapping_file):
            raise ValueError(f"Mapping file not found at: {mapping_file}")
        mapping_rules = transformer.load_mapping_rules_from_neo4j_file(mapping_file)
        
        # Determine the file category based on its location in the folder structure
        filename = os.path.basename(filepath)
        file_category = None
        
        # Read the Excel file with empty strings instead of NaN
        df = pd.read_excel(filepath, keep_default_na=False, na_values=[''])
        
        # Determine file category
        if "Employee" in filename:
            file_category = "Core"
        elif "Facility" in filename:
            file_category = "Prerequisites"
        elif "Curriculum" in filename or "Course" in filename:
            file_category = "Activity"
        elif "Transcript" in filename:
            file_category = "Transcript"
            
        if not file_category:
            raise ValueError(f"Could not determine category for file: {filename}")
        
        # Get the rules for this file type based on the filename without extension
        file_key = os.path.splitext(filename)[0]
        if file_key not in mapping_rules:
            # Create default 1:1 mapping if no rules exist
            mapping_rules[file_key] = [
                {"CSOD Field Name": col, "SumTotal Field Name": col}
                for col in df.columns
            ]
        
        # Transform the file
        processed_data = transformer.transform_sumtotal_file(df, mapping_rules[file_key], file_key)
        
        # Save the processed file
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        base_filename = os.path.splitext(filename)[0]  # Remove the original extension
        processed_filename = f"processed_{timestamp}_{base_filename}.csv"  # Add .csv extension
        processed_filepath = os.path.join(app.config['PROCESSED_FOLDER'], processed_filename)
        
        # Save as CSV with empty strings for missing values
        processed_data.to_csv(processed_filepath, index=False, na_rep="")
        return processed_filename
        
    except Exception as e:
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
            
            # Process the file using the transformer
            processed_filename = process_file(filepath)
            
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

if __name__ == '__main__':
    app.run(debug=True, port=5000)
