# Use Python 3.11 as base image (to support newer package versions)
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements first to leverage Docker cache
COPY file_server/requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the entire application
COPY . .

# Create necessary directories for file operations
RUN mkdir -p file_server/uploads file_server/processed file_server/templates

# Set environment variables
ENV PYTHONPATH=/app
ENV FLASK_APP=file_server/app.py
ENV FLASK_ENV=production

# Verify critical files exist
RUN test -f neo4j_knowledge_graph_cypher.txt || (echo "Neo4j mapping file not found" && exit 1)
RUN test -f lasVegas/app/sumtotal_transformer_with_neo4j.py || (echo "Transformer module not found" && exit 1)
RUN test -f file_server/templates/index.html || (echo "Template file not found" && exit 1)

# Expose the port the app runs on
EXPOSE 8000

# Add healthcheck
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8000/ || exit 1

# Command to run the application
CMD ["flask", "run", "--host=0.0.0.0", "--port=8000"] 