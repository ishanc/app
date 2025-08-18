
# LMS Error Analyzer - Data Analyzer Agent

This project implements the **Data Analyzer Agent** module from the LMS Migration functional specifications, designed to provide intelligent error analysis for SumTotal-to-CSOD data migration.

## Project Overview

The LMS Error Analyzer builds on top of an existing SumTotal-to-CSOD transformation system to provide comprehensive error analysis and categorization. The system reads captured migration errors from MySQL database and performs intelligent analysis using LLM processing with specialized categorization.

## Core Components

### 1. Error Categorization Engine (`database/error_categorizer.py`)
- Reads migration errors from MySQL database (error_logs table)
- Maps 16 validation types to 11 functional specification categories
- Creates categorized error arrays for specialized analysis

### 2. LLM Processing Pipeline (`core/`)
- Implements 400-token chunking with context preservation
- Batch processing for efficient LLM analysis
- SumTotal-to-CSOD migration context maintenance

### 3. MCP Tools Suite (`mcp_tools/`)
- 11 specialized tools for each error category
- Category-specific analysis prompts
- Integration with Model Context Protocol

### 4. Report Generation (`reports/`)
- Executive Summary
- Detailed Defect Log
- Data Quality Observations
- Mapping Validation Matrix
- Archival Recommendations Report

## Error Categories (Per Functional Specifications)

### Structure, Format, and Completeness Validation:
1. **File Structure & Header Consistency** - Delimiter/header structure validation
2. **Data Completeness Analysis** - Field completeness scoring
3. **Format Conformity & Nuances** - Spacing, encoding, format issues

### Anomaly Detection and Outlier Analysis:
4. **Duplicate Record Identification** - Duplicate unique identifier detection
5. **Null/Empty Value Flagging** - Critical mandatory field validation
6. **Format Mismatch Detection** - Pattern conformity validation
7. **Outlier Identification** - Statistical range validation
8. **Heterogeneous Data Type Detection** - Mixed data type identification

### Data Type and Length Validation:
9. **Source-to-Target Type Compatibility** - Data type conversion validation
10. **Character Length Analysis & Truncation Risk** - SumTotal (255) to CSOD (100) length validation
11. **Boolean Transformation Validation** - Boolean format conversion validation

## Database Configuration

**Local MySQL Database:**
- Host: localhost
- User: error_logger
- Password: IerpAgents.com1%
- Database: error_logging
- Table: error_logs

**Error Table Schema:**
- error_id, message, file_name, line_number, error_category, timestamp, stack_trace, validation_type

## Technology Stack

- **Backend**: Python 3.11+ with FastAPI
- **Database**: MySQL with mysql-connector-python
- **LLM Integration**: OpenAI API with batch processing
- **MCP Framework**: Python MCP SDK
- **Processing**: 400-token chunking with context preservation

## Development Workflow

1. **Error Extraction**: Read errors from existing MySQL database
2. **Categorization**: Map validation types to 11 FS categories
3. **Chunking**: Implement 400-token chunking for LLM processing
4. **Analysis**: Process chunks through specialized LLM prompts
5. **MCP Integration**: Build specialized tools for each category
6. **Reporting**: Generate comprehensive analysis reports

## Integration with Existing System

This error analyzer integrates with the existing SumTotal-to-CSOD transformation system by:
- Reading errors captured during transformation process
- Analyzing existing validation_type classifications
- Providing intelligent categorization and insights
- Supporting migration quality improvement workflows

## Success Metrics

- Process 1M+ error records efficiently
- Categorize errors with 95%+ accuracy
- Generate actionable insights for migration team
- Support iterative error resolution workflows
- Provide specialized analysis for each error category