# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **SumTotal to CSOD Data Transformation System** that converts Learning Management System (LMS) data from SumTotal format to CSOD (CSO Direct) format using Neo4j database-driven mapping rules. The system provides a web interface for file upload and automated data transformation.

## Development Commands

### Environment Setup
```bash
# Create virtual environment (Python 3.11 required)
cd lasVegas
bash setup.sh

# Or manually:
python3.11 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
```

### Running the Application

**Local Development:**
```bash
# Start the Flask web server
cd file_server
python app.py
# Access at http://localhost:8000
```

**Docker Development:**
```bash
# Build and run with Docker Compose
docker-compose up --build

# Access at http://localhost:5001
```

### Testing
```bash
# Run specific test files
python test_default_values.py
python test_transcript_curriculum.py
python test_data_validation.py

# Run transformer tests
cd lasVegas/app
python -m pytest test_*.py
```

### Database Operations
```bash
# Clean Neo4j database
python clean_neo4j_file.py

# Test Neo4j connection
python -c "from sumtotal_transformer_with_neo4j import driver; print('Connected to Neo4j')"
```

## Architecture

### Core Components

1. **Web Interface** (`file_server/app.py`)
   - Flask application handling file uploads/downloads
   - Filename mapping and validation
   - Integration with transformation engine

2. **Transformation Engine** (`lasVegas/app/sumtotal_transformer_with_neo4j.py`)
   - Core data transformation logic
   - Neo4j database querying for mapping rules
   - CASE statement parsing and application
   - Multi-output file generation support

3. **Error Logging System** (`lasVegas/app/error_logger.py`)
   - MySQL-based error logging with categorization
   - Validation error tracking without data truncation
   - Support for multiple error types (VALIDATION, TRANSFORMATION, DATABASE, etc.)

4. **Database Layer**
   - **Neo4j**: Stores mapping rules, field definitions, and transformation logic
   - **MySQL**: Error logging and validation tracking

### Data Flow

1. User uploads SumTotal Excel/CSV file via web interface
2. System maps filename to database key using `map_filename_to_database_key()`
3. Fetches mapping rules from Neo4j using `fetch_mapping_rules_from_neo4j()`
4. Processes file with pandas and applies transformations
5. Generates CSOD-formatted CSV output(s)
6. Provides download link to user

### Key Functions

- `fetch_mapping_rules_from_neo4j(file_name)`: Retrieves mapping rules from Neo4j
- `transform_sumtotal_file(input_df, mapping_rules, input_filename)`: Core transformation
- `parse_case_statement(transformation_rule)`: Parses Cypher CASE statements
- `map_filename_to_database_key(filename)`: Maps filenames to database keys

## File Processing Logic

### Supported File Types
- **Activity**: Curriculum, Tests, Sessions, Events, OnlineCourse, Material
- **Transcript**: Curriculum, Materials, Sessions, OnlineCourse, Tests  
- **Core**: Employee, Audience, Domain, Jobs, Organization
- **Prerequisites**: Facility, Instructor, Subject, Provider, Questions

### Multi-Output Support
Some input files generate multiple outputs:
- `QuickAssessment.xlsx` → `Activity_Test.csv` + `Activity_TestMapping.csv`
- `Activity_Curriculum.xlsx` → `Activity_Curriculum.csv` + `Activity_CurriculumStructure.csv`

### Transformation Rules
- Database-driven CASE statements for value mapping
- Support for `input_value` placeholders in Cypher queries
- Default values applied when source data is missing
- Character length validation without truncation

## Configuration

### Environment Variables (.env)
```bash
NEO4J_URI=bolt://localhost:7687
NEO4J_USER=neo4j
NEO4J_PASSWORD=your_password
FLASK_ENV=development
```

### Directory Structure
```
file_server/
├── uploads/          # Temporary file storage
├── processed/        # Output CSV files
├── templates/        # HTML templates
└── static/          # CSS, JS, assets

lasVegas/app/
├── sumtotal_transformer_with_neo4j.py  # Core transformer
├── error_logger.py                     # Error logging
├── test_*.py                          # Test files
└── logs/                              # Application logs
```

## Error Handling

### Error Categories
- **VALIDATION**: Data validation errors (logged to MySQL)
- **TRANSFORMATION**: Data transformation errors (console)
- **DATABASE**: Database connection/query errors (console)
- **FILE_PROCESSING**: File reading/writing errors (console)
- **NEO4J**: Neo4j database errors (console)

### Data Integrity
- System preserves original data even when validation fails
- No automatic truncation of fields exceeding character limits
- Errors are logged but don't prevent processing

## Docker Configuration

### Build and Run
```bash
# Production build
docker build -t sumtotal-transformer .

# Development with compose
docker-compose up --build
```

### Key Docker Settings
- Port mapping: 5001:8000 (external:internal)
- Volume mounts for persistent file storage
- Health checks every 30 seconds
- Resource limits: 1 CPU, 1GB RAM

## Testing Guidelines

### Unit Tests
- Focus on individual transformation functions
- Test CASE statement parsing logic
- Validate filename mapping logic

### Integration Tests
- Test complete file processing workflow
- Verify database connectivity
- Test error handling scenarios

### Sample Data
Use files in these directories for testing:
- `SumTotal_CSOD_Mapping_Files/Activity/`
- `SumTotal_CSOD_Mapping_Files/Core/`
- `SumTotal_CSOD_Mapping_Files/Prerequisites/`

## Development Notes

### Code Quality
- Main transformer was refactored from 200+ lines to modular functions
- Each function follows Single Responsibility Principle
- Enhanced error handling and logging throughout

### Character Encoding
- UTF-8-BOM support for international characters
- Support for special characters: ‡, Â, â, …, ", ", ', '
- Proper CSV encoding with `utf-8-sig`

### Performance Considerations
- Connection pooling for database operations
- Efficient pandas operations for large files
- Optimized logging levels for production

## Troubleshooting

### Common Issues
1. **"No mapping rules found"**: Check filename mapping and Neo4j connectivity
2. **File upload errors**: Verify file format (Excel/CSV) and size limits
3. **Transformation failures**: Check CASE statement syntax in Neo4j
4. **Database errors**: Verify Neo4j and MySQL connectivity

### Debugging Steps
```bash
# Check application logs
docker logs app-file-server

# Test Neo4j connection
python -c "from sumtotal_transformer_with_neo4j import driver; print('Connected')"

# Verify file processing
python -c "from sumtotal_transformer_with_neo4j import fetch_mapping_rules_from_neo4j; print(fetch_mapping_rules_from_neo4j('Activity_Curriculum'))"
```