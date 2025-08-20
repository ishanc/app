#!/usr/bin/env python3
"""
Script to clean neo4j_knowledge_graph_cypher.txt by removing all transformation logic.
This removes:
1. Full CASE statements (csod.transformation = CASE ... END)
2. String reference transformations (csod.transformation = "LOOKUP_NAME")
3. Keeps basic field mappings without transformations
"""

import re

def clean_neo4j_file(input_file, output_file):
    """Remove all transformation logic from the Neo4j Cypher file."""
    
    with open(input_file, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Pattern to match full CASE statements (case insensitive)
    # This matches from "csod.transformation = CASE" to the corresponding "END"
    case_pattern = r'csod\.transformation\s*=\s*CASE.*?END\s*\n'
    
    # Pattern to match string reference transformations (case insensitive)
    string_pattern = r'csod\.transformation\s*=\s*"[^"]*"\s*\n'
    
    # Pattern to match Transformation with capital T
    case_pattern2 = r'csod\.Transformation\s*=\s*CASE.*?END\s*\n'
    string_pattern2 = r'csod\.Transformation\s*=\s*"[^"]*"\s*\n'
    
    # Remove CASE statements (both variations)
    content = re.sub(case_pattern, '', content, flags=re.DOTALL | re.IGNORECASE)
    content = re.sub(case_pattern2, '', content, flags=re.DOTALL)
    
    # Remove string transformations (both variations)
    content = re.sub(string_pattern, '', content, flags=re.IGNORECASE)
    content = re.sub(string_pattern2, '', content)
    
    # Clean up any empty lines that might be left
    content = re.sub(r'\n\s*\n\s*\n', '\n\n', content)
    
    # Write the cleaned content
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print(f"Cleaned file saved to: {output_file}")

if __name__ == "__main__":
    input_file = "neo4j_knowledge_graph_cypher.txt"
    output_file = "neo4j_knowledge_graph_cypher_cleaned.txt"
    
    clean_neo4j_file(input_file, output_file) 