#!/usr/bin/env python3
"""Test the updated retrieval framework with actual uploaded files"""

from lms_error_analyzer.database.retrieval_framework import MySQLRetrieval

def test_with_actual_file(file_name):
    print(f"=== TESTING {file_name} ===")
    
    retrieval = MySQLRetrieval()
    signals = retrieval.get_quality_signals(file_name)
    
    print(f"Results for {file_name}:")
    print(f"  Total Records: {signals.completeness_summary.get('total_records', 0)}")
    print(f"  Incomplete Records: {signals.completeness_summary.get('incomplete_records', 0)}") 
    print(f"  Error-Prone Records: {signals.error_prone_records}")
    print(f"  Clean Records: {signals.clean_records}")
    print(f"  Quality Percentage: {signals.quality_percentage}%")
    print(f"  Total Errors: {len(signals.error_logs)}")
    print(f"  Error Types: {len(signals.error_summary)} different types")
    
    # Show some error types
    if signals.error_summary:
        top_errors = sorted(signals.error_summary.items(), key=lambda x: x[1], reverse=True)[:3]
        print(f"  Top Errors: {top_errors}")
    
    print()

if __name__ == "__main__":
    # Test with files that have data in your database
    test_files = [
        "Activity_Curriculum.xlsx",
        "Core_Employee.xlsx", 
        "Core_Audience.xlsx",
        "Prerequisites_Question.xlsx"
    ]
    
    for file_name in test_files:
        try:
            test_with_actual_file(file_name)
        except Exception as e:
            print(f"Error testing {file_name}: {e}")
            print()
