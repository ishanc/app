import pandas as pd
import sys
import os

# Add the lasVegas/app directory to the path
sys.path.append(os.path.join('lasVegas', 'app'))

from sumtotal_transformer_with_neo4j import fetch_mapping_rules_from_neo4j, transform_sumtotal_file

def main():
    # Load the SumTotal file
    input_df = pd.read_excel('lasVegas/Activity/Curriculum.xlsx')
    print("Input file columns:", input_df.columns.tolist())
    print("Input file shape:", input_df.shape)
    
    # Check Activity Code values
    if 'Activity Code' in input_df.columns:
        activity_code_values = input_df['Activity Code']
        print(f"\nActivity Code values:")
        print(f"  Non-empty values: {(activity_code_values != '').sum()}")
        print(f"  Empty values: {(activity_code_values == '').sum()}")
        print(f"  Sample values: {activity_code_values.head().tolist()}")
        print(f"  Data type: {activity_code_values.dtype}")
    
    # Fetch mapping rules
    mapping_rules = fetch_mapping_rules_from_neo4j('Activity_Curriculum')
    print(f"\nFetched {len(mapping_rules)} mapping rules")
    
    # Find the Curriculum ID* mapping
    curriculum_rule = None
    for rule in mapping_rules:
        if rule['CSOD Field Name'] == 'Curriculum ID*':
            curriculum_rule = rule
            break
    
    if curriculum_rule:
        print(f"\nCurriculum ID* mapping rule:")
        print(f"  CSOD Field: {curriculum_rule['CSOD Field Name']}")
        print(f"  SumTotal Field: '{curriculum_rule['SumTotal Field Name']}'")
        print(f"  Mandatory: {curriculum_rule['mandatory']}")
        print(f"  Default Value: '{curriculum_rule['default_value']}'")
        print(f"  Transformation: '{curriculum_rule['transformation']}'")
        
        # Check if the SumTotal field exists in the input file
        st_field = curriculum_rule['SumTotal Field Name']
        if st_field in input_df.columns:
            print(f"  ✓ SumTotal field '{st_field}' found in input file")
            print(f"  Sample values: {input_df[st_field].head().tolist()}")
        else:
            print(f"  ✗ SumTotal field '{st_field}' NOT found in input file")
            print(f"  Available columns: {input_df.columns.tolist()}")
    else:
        print("✗ No mapping rule found for Curriculum ID*")
    
    # Transform the file
    print("\nTransforming file...")
    transformed_df = transform_sumtotal_file(input_df, mapping_rules, 'Activity_Curriculum')
    
    print(f"\nTransformed file shape: {transformed_df.shape}")
    print("Transformed file columns:", transformed_df.columns.tolist())
    
    # Check Curriculum ID* in output
    if 'Curriculum ID*' in transformed_df.columns:
        curriculum_values = transformed_df['Curriculum ID*']
        print(f"\nCurriculum ID* values:")
        print(f"  Non-empty values: {(curriculum_values != '').sum()}")
        print(f"  Empty values: {(curriculum_values == '').sum()}")
        print(f"  Sample values: {curriculum_values.head().tolist()}")
        print(f"  Data type: {curriculum_values.dtype}")
        
        # Check if the values were copied correctly
        if 'Activity Code' in input_df.columns:
            print(f"\nComparison:")
            print(f"  Input Activity Code (first 5): {input_df['Activity Code'].head().tolist()}")
            print(f"  Output Curriculum ID* (first 5): {curriculum_values.head().tolist()}")
            
            # Check if they match
            matches = (input_df['Activity Code'].fillna('') == curriculum_values).sum()
            print(f"  Matching values: {matches} out of {len(input_df)}")
    else:
        print("✗ Curriculum ID* column not found in output")

if __name__ == "__main__":
    main() 