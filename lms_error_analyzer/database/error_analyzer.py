from mysql_connector import MySQLConnector


connector = MySQLConnector()

try:
    query = "SELECT DISTINCT validation_type FROM error_logs"
    #execute query
    results = connector.execute_query("error_logging", query)

#convert results to list
    validation_types = results['validation_type'].tolist()

#Print each error category
    print("Validation Types:")
    for validation_type in validation_types:
        print(f"- {validation_type}")
except Exception as e:
    print(f"Error: {e}")

    """def get_unique_columns_for_duplicate_detection(mapping_rules, input_df):
    ""Get columns to check for duplicates based on mapping rules""
    unique_cols = []
    
    # Define which output fields should be checked for duplicates
    duplicate_check_fields = ['Curriculum ID*', 'Event ID*', 'Session ID*', 'Material ID*', 'Test ID*']
    
    for rule in mapping_rules:
        csod_field = rule['CSOD Field Name']
        st_field = rule.get('SumTotal Field Name', '')
        
        # Only check if this output field should be checked AND has an input mapping
        if csod_field in duplicate_check_fields and st_field and st_field in input_df.columns:
            unique_cols.append(st_field)
    
    return unique_cols
    """
#
#
#
#
#






