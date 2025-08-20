# Cross-File PDF Quality Report Generator - User Guide

## Overview

The Cross-File PDF Quality Report Generator provides comprehensive data quality analysis across multiple uploaded files, with cumulative insights and cross-file relationship analysis.

## Workflow

### 📈 **Cumulative Upload Process**
1. **Upload Activity Files**: Upload Activity_Curriculum.xlsx, Activity_ILTSessions.xlsx, etc.
   - PDF automatically generates showing single-file analysis
   
2. **Upload Core Files**: Upload Core_Employee.xlsx, Core_Jobs.xlsx, etc.
   - PDF regenerates with cross-file analysis between Activity ↔ Core
   
3. **Upload Prerequisites**: Upload Prerequisites_Instructor.xlsx, etc.
   - PDF regenerates with expanded cross-file analysis
   
4. **Upload Transcript Files**: Upload Transcript_Curriculum.xlsx, etc.
   - PDF regenerates with complete cross-file relationship analysis

### 🔄 **Reset for New Batch**
5. **Hit "Reset PDF" Button**: Clears everything for a fresh start
   - Clears all database entries (`error_logs`, `file_completeness_summary`)
   - Deletes all processed CSV files
   - Deletes all PDF reports
   - System ready for new batch

## API Endpoints

### File Upload
```
POST /upload
```
- Processes file and auto-generates cumulative PDF
- Returns processing results including PDF filename if generated

### Manual PDF Generation
```
POST /generate-pdf-report
```
- Manually generates PDF for all currently processed files
- Useful for on-demand report generation

### Reset All Data
```
POST /reset-all-data
```
- **NEW**: Clears all data for new batch
- Removes all database entries and processed files
- Returns detailed reset operation results

### File Management
```
GET /files
DELETE /delete/<filename>
GET /download/<filename>
```
- List, delete, and download individual files
- File deletion is now simple (no complex database cleanup)

## Cross-File Analysis Features

### 🔗 **Referential Integrity Checks**
- **Employee_ID**: Links between Transcript files and Core_Employee
- **Curriculum_ID**: Links between Activity and Transcript files  
- **Instructor_ID**: Links between Activity and Prerequisites files
- **Orphaned Records**: Identifies records missing required relationships

### 📊 **Systemic Pattern Analysis**
- **Multi-File Error Patterns**: Errors affecting 2+ files
- **Severity Classification**: Critical/High/Medium/Low based on impact
- **Remediation Mapping**: Specific actions for each error type

### 📈 **Quality Score Comparison**
- **Mandatory Fields Completeness**: % of required fields populated
- **Optional Fields Completeness**: Estimated based on overall quality
- **Overall Quality Score**: Weighted score (70% mandatory, 30% optional)

## PDF Report Structure

### 1. Executive Summary
- Total files analyzed and record counts
- Critical issues summary
- Key recommendations

### 2. Cross-File Relationship Integrity Table
- Relationship type (Employee_ID lookup, etc.)
- Source and target files
- Orphaned record counts and integrity percentages

### 3. Cross-File Error Patterns Table
- Error patterns affecting multiple files
- Total impact across all files
- Recommended remediation actions

### 4. File Quality Score Comparison
- Side-by-side quality metrics for all files
- Mandatory vs optional field completeness
- Overall quality rankings

### 5. Data Issues Summary Table
- Aggregated error types across all files
- Categorization (Source/Transformation/Workshop)
- Remediation recommendations with severity

## Remediation Categories

### 🚨 **Critical Issues**
- `MANDATORY_EMPTY`: Missing required field values
- `DUPLICATE_RECORD`: Duplicate data entries
- `TYPE_COMPATIBILITY`: Data type mismatches

### ⚠️ **High Priority**
- `TRUNCATION`: Data exceeds field length limits
- `ENCODING_ISSUE`: Invalid character encoding
- `HETEROGENEOUS_TYPE`: Mixed data types in single field

### 📝 **Medium Priority**
- `LEADING_SPACES`/`TRAILING_SPACES`: Whitespace issues
- `DATE_FORMAT`: Invalid date formats
- `OUTLIER_VALUE`: Statistical outliers

### ℹ️ **Low Priority**
- `LEADING_ZEROS`: Unwanted zero padding
- `BOOLEAN_CONVERSION`: Boolean format issues
- `COMPLETENESS_SCORE`: General completeness metrics

## Benefits of Reset Approach

### ✅ **Simplified Workflow**
- One-click reset instead of managing individual file deletions
- Clear separation between batches
- No confusion about which files belong together

### ✅ **Better Cross-File Analysis**
- See complete picture before resetting
- Understand relationships across Activity/Core/Prerequisites/Transcript
- Cumulative insights as you add more files

### ✅ **Cleaner User Experience**
- Upload files → See growing analysis
- Hit reset when ready for new batch
- No complex deletion tracking

## Technical Implementation

### Database Tables Used
- `error_logs`: Validation errors with file context
- `file_completeness_summary`: Mandatory field completeness metrics

### File Processing Pipeline
1. File upload → SumTotal transformer
2. Validation errors logged to database
3. Completeness metrics calculated and stored
4. PDF auto-generated with current state
5. Cross-file analysis performed using Neo4j mappings

### Dependencies
- `reportlab`: Professional PDF generation
- `mysql-connector-python`: Database connectivity
- Existing modules: `retrieval_framework`, `dashboard`, `error_logger`

## Example Usage

```bash
# Upload multiple files (PDF grows with each upload)
curl -X POST -F "file=@Activity_Curriculum.xlsx" http://localhost:5001/upload
curl -X POST -F "file=@Core_Employee.xlsx" http://localhost:5001/upload
curl -X POST -F "file=@Transcript_Curriculum.xlsx" http://localhost:5001/upload

# View comprehensive cross-file analysis in generated PDF

# Reset for new batch
curl -X POST http://localhost:5001/reset-all-data

# Start uploading new batch of files...
```

This approach provides the comprehensive cross-file analysis you need while maintaining a clean, intuitive workflow that matches your actual usage patterns.
