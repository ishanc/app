#!/bin/bash
set -e

echo "🔍 Starting LMS application initialization..."

# Extract host and port from connection strings
MYSQL_HOST_ONLY=$(echo $MYSQL_HOST | cut -d: -f1)
MYSQL_PORT_ONLY=${MYSQL_PORT:-3306}
NEO4J_HOST_ONLY=$(echo $NEO4J_HOST | cut -d: -f1)
NEO4J_PORT_ONLY=${NEO4J_PORT:-7687}

echo "🔄 Waiting for MySQL at $MYSQL_HOST_ONLY:$MYSQL_PORT_ONLY..."
while ! nc -z $MYSQL_HOST_ONLY $MYSQL_PORT_ONLY; do 
    echo "⏳ MySQL not ready, waiting..."
    sleep 2
done
echo "✅ MySQL is ready!"

echo "🔄 Waiting for Neo4j at $NEO4J_HOST_ONLY:$NEO4J_PORT_ONLY..."
while ! nc -z $NEO4J_HOST_ONLY $NEO4J_PORT_ONLY; do 
    echo "⏳ Neo4j not ready, waiting..."
    sleep 2
done
echo "✅ Neo4j is ready!"

echo "🚀 All dependencies ready. Starting application..."
exec "$@"
