#!/usr/bin/env python3
"""
Test script for data validation functionality
"""

import pandas as pd
import sys
import os

# Add the lasVegas/app directory to the path
sys.path.append(os.path.join(os.path.dirname(__file__), 'lasVegas', 'app'))

from data_validation import DataValidator

def create_sample_data():
    """Create sample data for testing"""
    data = {
        'Employee ID': ['E001', 'E002', 'E003', 'E004', 'E005'],
        'Name': ['John Doe', 'Jane Smith', 'Bob Johnson', 'Alice Brown', 'Charlie Wilson'],
        'Department': ['IT', 'HR', 'Finance', 'Marketing', 'IT'],
        'Salary': [50000, 60000, 55000, 65000, 52000],
        'Start Date': ['2023-01-15', '2023-02-01', '2023-03-10', '2023-01-20', '2023-04-05'],
        'Status': ['Active', 'Active', 'Inactive', 'Active', 'Active'],
        'Manager': ['', 'John Doe', 'Jane Smith', 'Bob Johnson', 'John Doe'],
        'Phone': ['555-1234', '555-5678', '555-9012', '555-3456', '555-7890'],
        'Email': ['john@company.com', 'jane@company.com', 'bob@company.com', 'alice@company.com', 'charlie@company.com']
    }
    return pd.DataFrame(data)

def create_sample_mapping_rules():
    """Create sample mapping rules for testing"""
    return [
        {
            'CSOD Field Name': 'Employee ID*',
            'SumTotal Field Name': 'Employee ID',
            'mandatory': 'Mandatory',
            'field_type': 'string',
            'char_length': '10',
            'accepted_values': 'E001,E002,E003,E004,E005'
        },
        {
            'CSOD Field Name': 'Full Name*',
            'SumTotal Field Name': 'Name',
            'mandatory': 'Mandatory',
            'field_type': 'string',
            'char_length': '50'
        },
        {
            'CSOD Field Name': 'Department Code',
            'SumTotal Field Name': 'Department',
            'mandatory': 'Optional',
            'field_type': 'string',
            'char_length': '20',
            'transformation': 'CASE Department WHEN "IT" THEN "IT001" WHEN "HR" THEN "HR001" WHEN "Finance" THEN "FIN001" ELSE "OTH001" END'
        },
        {
            'CSOD Field Name': 'Annual Salary',
            'SumTotal Field Name': 'Salary',
            'mandatory': 'Optional',
            'field_type': 'decimal',
            'char_length': '10'
        },
        {
            'CSOD Field Name': 'Hire Date*',
            'SumTotal Field Name': 'Start Date',
            'mandatory': 'Mandatory',
            'field_type': 'date',
            'char_length': '10'
        },
        {
            'CSOD Field Name': 'Employment Status',
            'SumTotal Field Name': 'Status',
            'mandatory': 'Optional',
            'field_type': 'string',
            'char_length': '10',
            'accepted_values': 'Active,Inactive,Terminated'
        },
        {
            'CSOD Field Name': 'Manager ID',
            'SumTotal Field Name': 'Manager',
            'mandatory': 'Optional',
            'field_type': 'string',
            'char_length': '10'
        },
        {
            'CSOD Field Name': 'Contact Phone',
            'SumTotal Field Name': 'Phone',
            'mandatory': 'Optional',
            'field_type': 'string',
            'char_length': '15'
        },
        {
            'CSOD Field Name': 'Email Address*',
            'SumTotal Field Name': 'Email',
            'mandatory': 'Mandatory',
            'field_type': 'string',
            'char_length': '100'
        }
    ]

def create_invalid_data():
    """Create data with validation issues"""
    data = {
        'Employee ID': ['E001', '', 'E003', 'E004', 'E005'],  # Empty mandatory field
        'Name': ['John Doe', 'Jane Smith', 'Bob Johnson', 'Alice Brown', 'Charlie Wilson'],
        'Department': ['IT', 'HR', 'Finance', 'Marketing', 'Invalid'],  # Invalid department
        'Salary': [50000, 'invalid', 55000, 65000, 52000],  # Invalid numeric
        'Start Date': ['2023-01-15', 'invalid-date', '2023-03-10', '2023-01-20', '2023-04-05'],  # Invalid date
        'Status': ['Active', 'Active', 'Invalid', 'Active', 'Active'],  # Invalid status
        'Manager': ['', 'John Doe', 'Jane Smith', 'Bob Johnson', 'John Doe'],
        'Phone': ['555-1234', '555-5678', '555-9012', '555-3456', '555-7890'],
        'Email': ['john@company.com', 'jane@company.com', 'bob@company.com', 'alice@company.com', 'charlie@company.com']
    }
    return pd.DataFrame(data)

def test_validation():
    """Run comprehensive validation tests"""
    print("=== Data Validation Test Suite ===\n")
    
    # Initialize validator
    validator = DataValidator(log_level=logging.INFO)
    
    # Test 1: Valid data validation
    print("Test 1: Valid Data Validation")
    print("-" * 40)
    
    df_valid = create_sample_data()
    mapping_rules = create_sample_mapping_rules()
    
    # Validate mapping rules
    is_valid_rules, rule_errors = validator.validate_mapping_rules(mapping_rules, "Employee")
    print(f"Mapping rules valid: {is_valid_rules}")
    if rule_errors:
        print("Rule errors:", rule_errors)
    
    # Validate data values
    is_valid_data, data_errors = validator.validate_data_values(df_valid, mapping_rules, "Employee")
    print(f"Data values valid: {is_valid_data}")
    if data_errors:
        print("Data errors:", data_errors)
    
    # Generate and display validation report
    report = validator.generate_validation_report("Employee")
    print(f"\nValidation Report:")
    print(f"  Total errors: {report['summary']['total_errors']}")
    print(f"  Total warnings: {report['summary']['total_warnings']}")
    print(f"  Is valid: {report['summary']['is_valid']}")
    
    validator.log_validation_summary()
    validator.clear_validation_results()
    
    print("\n" + "="*50 + "\n")
    
    # Test 2: Invalid data validation
    print("Test 2: Invalid Data Validation")
    print("-" * 40)
    
    df_invalid = create_invalid_data()
    
    # Validate data values with invalid data
    is_valid_data, data_errors = validator.validate_data_values(df_invalid, mapping_rules, "Employee")
    print(f"Data values valid: {is_valid_data}")
    if data_errors:
        print("Data errors found:")
        for error in data_errors:
            print(f"  - {error}")
    
    # Generate and display validation report
    report = validator.generate_validation_report("Employee")
    print(f"\nValidation Report:")
    print(f"  Total errors: {report['summary']['total_errors']}")
    print(f"  Total warnings: {report['summary']['total_warnings']}")
    print(f"  Is valid: {report['summary']['is_valid']}")
    
    validator.log_validation_summary()
    validator.clear_validation_results()
    
    print("\n" + "="*50 + "\n")
    
    # Test 3: Invalid mapping rules
    print("Test 3: Invalid Mapping Rules")
    print("-" * 40)
    
    invalid_rules = [
        {
            'CSOD Field Name': '',  # Empty required field
            'SumTotal Field Name': 'Employee ID',
            'mandatory': 'Mandatory'
        },
        {
            'CSOD Field Name': 'Duplicate Field',  # Duplicate field name
            'SumTotal Field Name': 'Name',
            'mandatory': 'Mandatory'
        },
        {
            'CSOD Field Name': 'Duplicate Field',  # Duplicate field name
            'SumTotal Field Name': 'Department',
            'mandatory': 'Invalid'  # Invalid mandatory value
        },
        {
            'CSOD Field Name': 'Test Field',
            'SumTotal Field Name': 'Salary',
            'char_length': '-5'  # Invalid character length
        }
    ]
    
    # Validate invalid mapping rules
    is_valid_rules, rule_errors = validator.validate_mapping_rules(invalid_rules, "Employee")
    print(f"Mapping rules valid: {is_valid_rules}")
    if rule_errors:
        print("Rule errors found:")
        for error in rule_errors:
            print(f"  - {error}")
    
    validator.log_validation_summary()
    
    print("\n=== Validation Test Suite Complete ===")

if __name__ == "__main__":
    import logging
    logging.basicConfig(level=logging.INFO)
    test_validation() 