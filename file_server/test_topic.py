import sys
sys.path.append('../lasVegas/app')
import sumtotal_transformer_with_neo4j as transformer

# Test the Topic transformation
test_rule = 'CASE WHEN input_value = "Artificial Intelligence" THEN 1274 WHEN input_value = "Software" THEN 1275 ELSE 1382 END'
print("Testing transformation parsing...")
parsed = transformer.parse_case_statement(test_rule)
print(f"Parsed mappings: {parsed}")

# Test the transformation
result = transformer.apply_transformation_rule('Artificial Intelligence', parsed)
print(f"Result for 'Artificial Intelligence': {result}")

# Check database rules
print("\nChecking database rules...")
rules = transformer.fetch_mapping_rules_from_neo4j('Activity_Curriculum')
subject_rules = [r for r in rules if 'Subject IDs' in r.get('CSOD Field Name', '')]
print(f"Subject IDs rules found: {len(subject_rules)}")

if subject_rules:
    rule = subject_rules[0]
    print(f"CSOD Field: {rule['CSOD Field Name']}")
    print(f"SumTotal Field: {rule['SumTotal Field Name']}")
    print(f"Has transformation: {bool(rule.get('transformation'))}")
    if rule.get('transformation'):
        print(f"Transformation preview: {rule['transformation'][:100]}...")
        
        # Test the actual transformation from database
        parsed_db = transformer.parse_case_statement(rule['transformation'])
        result_db = transformer.apply_transformation_rule('Artificial Intelligence', parsed_db)
        print(f"Database transformation result: {result_db}")
else:
    print("No Subject IDs rules found in database!") 