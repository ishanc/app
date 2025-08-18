# SumTotal Data Quality Retrieval Framework

## Overview

This framework implements a comprehensive retrieval system for analyzing SumTotal file quality by combining MySQL raw data, quality signals, and Neo4j mapping constraints. It's designed to prepare context for LLM-based analysis while keeping all findings in SumTotal field terms.

## Key Features

- **DB-first approach**: Queries MySQL tables directly for raw data metrics
- **SumTotal-centric analysis**: All findings reference original SumTotal field names
- **Neo4j constraint validation**: Uses CSOD field properties to validate SumTotal data
- **Context bundling**: Assembles ranked, token-optimized analysis context
- **Caching and observability**: Deterministic results with detailed logging

## Files

- `retrieval_framework.py` - Main framework implementation
- `test_retrieval.py` - Test script and validation
- `README_retrieval.md` - This documentation

## Quick Start

```python
from retrieval_framework import RetrievalFramework

# Initialize framework
framework = RetrievalFramework()

# Build analysis context for a file
bundle = framework.build_analysis_context("Transcript_QuickAssessment.csv")

# Get summary
summary = framework.get_bundle_summary(bundle)
print(summary)

# Close connections
framework.close()
```

## Test Results

Based on testing with real sample data:

### Transcript_QuickAssessment.csv
- **Rows**: 2,471
- **Fields analyzed**: 8
- **High severity issues**: 1 (TrainingStatus field missing data)
- **Key findings**:
  - Date format violations in RegistrationDate and CompletionDate
  - Score field contains decimals but expected integers
  - TrainingStatus field not found in table

### Activity_Curriculum.csv  
- **Rows**: 1,154
- **Fields analyzed**: 9
- **High severity issues**: 0
- **Key findings**:
  - Child ActivityCode exceeds 100 character limit (max: 151)

## Architecture

### Core Components

1. **MySQLRetrieval**: Handles raw data queries and quality signals
   - Table name resolution (CamelCase → snake_case)
   - Field metrics calculation (nulls, lengths, types, samples)
   - Quality signals (error_logs, completeness_summary)

2. **Neo4jRetrieval**: Handles mapping constraints
   - SumTotal → CSOD field mappings
   - Constraint properties (mandatory, type, length, accepted values)
   - Transformation rules

3. **FieldProfiler**: Creates comprehensive field profiles
   - Combines metrics with constraints
   - Detects violations (mandatory, length, type, domain)
   - Assigns severity levels

4. **ContextAssembler**: Builds ranked analysis context
   - Prioritizes by severity and violation count
   - Creates mapping summaries
   - Generates cache keys for reproducibility

### Data Flow

1. Filename → FilenameMapper → file_key (for Neo4j) + table_name (for MySQL)
2. MySQL: Raw data metrics + quality signals
3. Neo4j: Mapping constraints by SumTotal field
4. Combine: Field profiles with violations and severity
5. Rank: By severity, violations, and error correlation
6. Bundle: Complete context ready for LLM analysis

## Usage Patterns

### CLI Testing
```bash
cd lms_error_analyzer/database
python test_retrieval.py
```

### Programmatic Usage
```python
# Simple analysis
framework = RetrievalFramework()
bundle = framework.build_analysis_context("your_file.csv")

# Save bundle for inspection
bundle = framework.build_analysis_context("your_file.csv", save_bundle=True)

# Get summary only
summary = framework.get_bundle_summary(bundle)
```

### Integration with LLM
```python
# Build context
bundle = framework.build_analysis_context("your_file.csv")

# Convert to LLM prompt (future implementation)
prompt = f"""
Analyze SumTotal data quality for {bundle.file_name}:

File Overview: {bundle.overview}
Field Issues: {[p.violations for p in bundle.field_profiles if p.violations]}
Quality Signals: {bundle.quality_signals.error_summary}

Provide analysis in JSON format...
"""
```

## Configuration

The framework uses environment variables for database connections:

```env
# MySQL
MYSQL_HOST=localhost
MYSQL_PORT=3306
MYSQL_NAME=error_logging
MYSQL_USER=error_logger
MYSQL_PASSWORD=your_password

# Neo4j
NEO4J_URI=bolt://localhost:7687
NEO4J_USER=neo4j
NEO4J_PASSWORD=your_password
```

## Output Structure

### ContextBundle
- `file_name`: Original filename
- `file_key`: Neo4j mapping key  
- `table_name`: MySQL table name
- `overview`: Table statistics
- `field_profiles`: List of SumTotal field profiles
- `quality_signals`: Error logs and completeness data
- `mapping_summary`: High-level mapping statistics
- `metadata`: Cache keys and generation info

### SumTotalFieldProfile
- `sumtotal_field_name`: Original SumTotal field name
- `metrics`: Raw data statistics (nulls, lengths, samples)
- `csod_constraints`: List of mapped CSOD constraints
- `violations`: List of detected issues
- `severity`: High/Medium/Low priority
- `error_count`: Correlated error log count

## Next Steps

This framework provides the retrieval foundation. Next phases:

1. **LLM Integration**: Add prompt templates and model calls
2. **Advanced Analytics**: Cross-field dependency analysis
3. **Recommendations**: Suggest fixes based on constraint violations
4. **Monitoring**: Track data quality trends over time

## Validation

The framework has been tested with real sample data:
- ✅ MySQL connection and table resolution
- ✅ Neo4j mapping constraint retrieval  
- ✅ Field metric calculation and violation detection
- ✅ Context bundle assembly and ranking
- ✅ JSON serialization and caching
- ✅ End-to-end integration with sample files
