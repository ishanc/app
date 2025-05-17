import os
import sys
import pandas as pd

# Add the correct path to the transformer module
sys.path.append('/Users/ishanchoudhary/Documents/lasVegas/app/lasVegas/app')
from sumtotal_transformer_with_neo4j import transform_sumtotal_file

def test_transcript_curriculum_archived():
    """Test specifically for TranscriptCurriculum's Archived field default value"""
    
    # Create test input data
    test_data = {
        "EmployeeID": ["001", "002", "003"],
        "ActivityCode": ["C1", "C2", "C3"],
        "TrainingStatus": ["Complete", "In Progress", "Not Started"]
    }
    input_df = pd.DataFrame(test_data)
    
    # Define minimal mapping rules focusing on Archived field
    mapping_rules = {
        "TranscriptCurriculum": [
            {
                "CSOD Field Name": "User ID*",
                "SumTotal Field Name": "EmployeeID",
                "Default value": "",
                "field_type": "Char",
                "mandatory": "Mandatory"
            },
            {
                "CSOD Field Name": "Curriculum ID*",
                "SumTotal Field Name": "ActivityCode",
                "Default value": "",
                "field_type": "Char",
                "mandatory": "Mandatory"
            },
            {
                "CSOD Field Name": "Transcript Status*",
                "SumTotal Field Name": "TrainingStatus",
                "Default value": "",
                "field_type": "Char",
                "mandatory": "Mandatory"
            },
            {
                "CSOD Field Name": "Archived",
                "SumTotal Field Name": "",
                "Default value": "false",
                "field_type": "Boolean",
                "mandatory": "Optional",
                "accepted_values": "1, 0, y, n, yes, no, t, f, true, false, on, off, active, inactive"
            }
        ]
    }
    
    # Transform the data
    result_df = transform_sumtotal_file(input_df, "TranscriptCurriculum", mapping_rules)
    
    # Print results for verification
    print("\nInput DataFrame:")
    print(input_df)
    print("\nOutput DataFrame:")
    print(result_df)
    
    # Verify Archived field
    print("\nArchived field values:", result_df["Archived"].tolist())
    assert all(val == "false" for val in result_df["Archived"]), "All Archived values should be 'false'"
    print("Test passed: All Archived values are 'false'")

if __name__ == "__main__":
    test_transcript_curriculum_archived()