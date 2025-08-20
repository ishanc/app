import os
from datetime import datetime
from typing import Dict, Any, List
from collections import defaultdict

import mysql.connector
from dotenv import load_dotenv

# Imported relatively because file_server adds this directory to sys.path
from llm_processor import LLMProcessor
from dashboard import Dashboard


def _get_db_connection():
    load_dotenv()
    return mysql.connector.connect(
        host=os.getenv('MYSQL_HOST', 'localhost'),
        user=os.getenv('MYSQL_USER'),
        password=os.getenv('MYSQL_PASSWORD'),
        database=os.getenv('MYSQL_NAME'),
        port=int(os.getenv('MYSQL_PORT', 3306)),
        ssl_disabled=True,
        connect_timeout=30,
        use_unicode=True
    )


def _fetch_error_logs_for_file(connection, file_name: str) -> List[Dict[str, Any]]:
    query = (
        "SELECT error_id, message, file_name, line_number, error_category, validation_type, timestamp, stack_trace "
        "FROM error_logs WHERE file_name = %s ORDER BY timestamp DESC"
    )
    cursor = connection.cursor(dictionary=True)
    cursor.execute(query, (file_name,))
    results = cursor.fetchall()
    cursor.close()
    return results or []


def _fetch_completeness_for_file(connection, file_name: str) -> Dict[str, Any]:
    query = (
        "SELECT mandatory_completeness, total_records, incomplete_records "
        "FROM file_completeness_summary WHERE file_name = %s"
    )
    cursor = connection.cursor(dictionary=True)
    cursor.execute(query, (file_name,))
    row = cursor.fetchone()
    cursor.close()
    
    # Map to correct terminology for downstream usage
    if row:
        return {
            'mandatory_completeness': row.get('mandatory_completeness'),
            'total_records': row.get('total_records'),
            'incomplete_records': row.get('incomplete_records')
        }
    return {}


def _calculate_anomaly_rates(error_rows: List[Dict[str, Any]], total_records: int, mandatory_fields: List[str]) -> Dict[str, Dict[str, float]]:
    """
    Calculate anomaly rates per field per error type for mandatory fields only.
    
    Args:
        error_rows: List of error records from database
        total_records: Total number of records in the file
        mandatory_fields: List of mandatory field names (SumTotal names)
    
    Returns:
        Dict[field_name][validation_type] = anomaly_rate_percentage
    """
    if total_records <= 0:
        return {}
    
    # Group errors by (field_name, validation_type) and collect unique line numbers
    field_error_lines = defaultdict(lambda: defaultdict(set))
    
    for error in error_rows:
        validation_type = error.get('validation_type', '')
        line_number = error.get('line_number')
        message = error.get('message', '')
        
        # Extract field name from error message (using same logic as LLMProcessor)
        field_name = _extract_field_name_from_message(message)
        
        # Only process mandatory fields
        if field_name and field_name in mandatory_fields and line_number is not None:
            field_error_lines[field_name][validation_type].add(line_number)
    
    # Calculate anomaly rates
    anomaly_rates = {}
    for field_name, error_types in field_error_lines.items():
        anomaly_rates[field_name] = {}
        for validation_type, line_numbers in error_types.items():
            unique_affected_records = len(line_numbers)
            anomaly_rate = (unique_affected_records / total_records) * 100
            anomaly_rates[field_name][validation_type] = round(anomaly_rate)
    
    return anomaly_rates


def _extract_field_name_from_message(message: str) -> str:
    """Extract field name from error message using same pattern as LLMProcessor"""
    if not message:
        return None
    try:
        first_quote = message.index("'")
        second_quote = message.index("'", first_quote + 1)
        return message[first_quote + 1:second_quote]
    except ValueError:
        return None


def _get_validation_type_from_anomaly(anomaly_text: str) -> str:
    """Map anomaly text back to validation type for rate lookup"""
    # Map based on key phrases in LLMProcessor.validation_to_anomaly
    anomaly_lower = anomaly_text.lower()
    
    if "mandatory field has empty values" in anomaly_lower:
        return "MANDATORY_EMPTY"
    elif "truncation risk" in anomaly_lower or "exceeds target length" in anomaly_lower:
        return "TRUNCATION"
    elif "leading whitespace" in anomaly_lower:
        return "LEADING_SPACES"
    elif "trailing whitespace" in anomaly_lower:
        return "TRAILING_SPACES"
    elif "encoding" in anomaly_lower or "invalid character" in anomaly_lower:
        return "ENCODING_ISSUE"
    elif "date format" in anomaly_lower:
        return "DATE_FORMAT"
    elif "leading zeros" in anomaly_lower:
        return "LEADING_ZEROS"
    elif "duplicate record" in anomaly_lower:
        return "DUPLICATE_RECORD"
    elif "heterogeneous data types" in anomaly_lower:
        return "HETEROGENEOUS_TYPE"
    elif "outlier values" in anomaly_lower:
        return "OUTLIER_VALUE"
    elif "type compatibility" in anomaly_lower:
        return "TYPE_COMPATIBILITY"
    elif "boolean normalization" in anomaly_lower or "boolean conversion" in anomaly_lower:
        return "BOOLEAN_CONVERSION"
    elif "header" in anomaly_lower or "structure inconsistency" in anomaly_lower:
        return "HEADER_INCONSISTENCY"
    elif "delimiter" in anomaly_lower:
        return "DELIMITER_ISSUE"
    elif "completeness" in anomaly_lower:
        return "COMPLETENESS_SCORE"
    else:
        return "UNKNOWN"


def _write_csv(report_rows: List[Dict[str, Any]], output_path: str) -> None:
    # Minimal dependency CSV writer using pandas if available; else raw write
    try:
        import pandas as pd  # noqa
        import pandas
        df = pandas.DataFrame(report_rows)
        df.to_csv(output_path, index=False)
    except Exception:
        # Fallback to manual CSV writing
        if not report_rows:
            with open(output_path, 'w', encoding='utf-8') as f:
                f.write('file_name,section,field,severity,anomaly,anomaly_rate,remediation_recommendation\n')
            return
        headers = ['file_name', 'section', 'field', 'severity', 'anomaly', 'anomaly_rate', 'remediation_recommendation']
        with open(output_path, 'w', encoding='utf-8') as f:
            f.write(','.join(headers) + '\n')
            for row in report_rows:
                values = [str(row.get(h, '')).replace('\n', ' ').replace('\r', ' ') for h in headers]
                f.write(','.join(values) + '\n')


def generate_anomaly_report_csv(file_name: str, output_dir: str) -> str:
    """
    Generate an MVP anomaly CSV report for the given file using error logs and
    completeness summary. Returns the saved CSV filename.
    """
    connection = _get_db_connection()
    try:
        error_rows = _fetch_error_logs_for_file(connection, file_name)
        completeness = _fetch_completeness_for_file(connection, file_name)

        # Get mandatory fields from Neo4j for filtering and anomaly rate calculation
        dashboard = Dashboard()
        try:
            mandatory_fields = dashboard.get_mandatory_fields_from_neo4j(file_name)
            print(f"DEBUG: Found {len(mandatory_fields)} mandatory fields for {file_name}: {mandatory_fields}")
        except Exception as e:
            print(f"WARNING: Could not get mandatory fields from Neo4j: {e}")
            mandatory_fields = []
        finally:
            dashboard.close_connections()

        # Calculate anomaly rates per field per error type
        total_records = completeness.get('total_records', 0) if completeness else 0
        anomaly_rates = _calculate_anomaly_rates(error_rows, total_records, mandatory_fields)
        print(f"DEBUG: Calculated anomaly rates: {anomaly_rates}")

        # Prepare inputs for LLMProcessor (heuristic baseline)
        categorized_errors = {"raw": error_rows}
        completeness_by_file = {file_name: completeness} if completeness else {}

        # Use OpenAI if API key present, otherwise heuristic
        llm = LLMProcessor(use_openai=bool(os.getenv("OPENAI_API_KEY")))
        insights = llm.generate_insights(
            categorized_errors,
            chunker=None,
            completeness_by_file=completeness_by_file,
            field_meta_by_file=None,
        )

        # Flatten insights into CSV rows
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        report_filename = f"anomaly_report_{timestamp}_{os.path.splitext(file_name)[0]}.csv"
        output_path = os.path.join(output_dir, report_filename)

        report_rows: List[Dict[str, Any]] = []
        file_payload = insights.get('files', {}).get(file_name) or insights.get('files', {}).get('unknown')

        # Summary section
        if file_payload and 'summary' in file_payload:
            summary = file_payload['summary']
            for key in ['mandatory_completeness', 'total_errors']:
                if key in summary:
                    report_rows.append({
                        'file_name': file_name,
                        'section': 'summary',
                        'field': key,
                        'severity': '',
                        'anomaly': str(summary.get(key)),
                        'anomaly_rate': '',  # Empty for summary rows
                        'remediation_recommendation': '',  # Empty for summary rows
                    })

        # Field anomalies - filter to mandatory fields only and append anomaly rates
        if file_payload and 'fields' in file_payload:
            for field_rec in file_payload['fields']:
                field_name = field_rec.get('field') or ''
                severity = field_rec.get('severity') or ''
                
                # Skip non-mandatory fields
                if field_name not in mandatory_fields:
                    print(f"DEBUG: Skipping optional field: {field_name}")
                    continue
                
                anomalies = field_rec.get('anomalies', [])
                remediation_recommendations = field_rec.get('remediation_recommendations', [])
                
                # Ensure we have the same number of anomalies and recommendations
                max_length = max(len(anomalies), len(remediation_recommendations))
                
                for i in range(max_length):
                    anomaly = anomalies[i] if i < len(anomalies) else ''
                    recommendation = remediation_recommendations[i] if i < len(remediation_recommendations) else ''
                    
                    # Try to determine validation type from anomaly text to get rate
                    validation_type = _get_validation_type_from_anomaly(anomaly) if anomaly else ''
                    anomaly_text = anomaly  # Keep original clean text
                    anomaly_rate = ''  # Default empty rate
                    
                    # Get anomaly rate if available and format with % symbol
                    if (field_name in anomaly_rates and 
                        validation_type in anomaly_rates[field_name]):
                        rate = anomaly_rates[field_name][validation_type]
                        anomaly_rate = f"{rate}%"
                    
                    report_rows.append({
                        'file_name': file_name,
                        'section': 'field',
                        'field': field_name,
                        'severity': severity,
                        'anomaly': anomaly_text,
                        'anomaly_rate': anomaly_rate,
                        'remediation_recommendation': recommendation,
                    })

        _write_csv(report_rows, output_path)
        return report_filename
    finally:
        try:
            connection.close()
        except Exception:
            pass

