#!/bin/bash

# Check if cypher-shell is installed
if ! command -v cypher-shell &> /dev/null; then
    echo "Error: cypher-shell is not installed. Please install Neo4j command line tools first."
    exit 1
fi

# Check if .env file exists
if [ ! -f .env ]; then
    echo "Error: .env file not found"
    exit 1
fi

# Load environment variables from .env
export $(cat .env | grep -v '^#' | xargs)

# Run the Cypher commands
echo "Running Neo4j mappings..."
cat neo4j_knowledge_graph_cypher.txt | cypher-shell -u "$NEO4J_USER" -p "$NEO4J_PASSWORD" -a "$NEO4J_URI"

if [ $? -eq 0 ]; then
    echo "Successfully executed Neo4j mappings!"
else
    echo "Error executing Neo4j mappings. Please check your connection parameters in .env file and try again."
    exit 1
fi