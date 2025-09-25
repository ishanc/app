# Use Python 3.11 as base image (to support newer package versions)
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    netcat-traditional \
    && rm -rf /var/lib/apt/lists/*

# Copy ALL THREE requirements files first to leverage Docker cache
COPY file_server/requirements.txt .
COPY lasVegas/requirements.txt ./backend_requirements.txt
COPY lms_error_analyzer/requirements.txt ./lms_requirements.txt

# Install Python dependencies from ALL THREE files
RUN pip install --no-cache-dir -r requirements.txt -r backend_requirements.txt -r lms_requirements.txt

# Copy the entire application
COPY . .

# Create necessary directories for file operations
RUN mkdir -p file_server/uploads file_server/processed file_server/templates \
    && mkdir -p logs lms_error_analyzer/logs \
    && chmod 777 logs lms_error_analyzer/logs

# Set environment variables
ENV PYTHONPATH=/app
ENV FLASK_APP=file_server/app.py
ENV FLASK_ENV=production

# Verify critical files exist
RUN test -f file_server/app.py || (echo "Main Flask app not found" && exit 1)
RUN test -f lasVegas/app/sumtotal_transformer_with_neo4j.py || (echo "Transformer module not found" && exit 1)
RUN test -f file_server/index.html || (echo "Template file not found" && exit 1)
RUN test -f lms_error_analyzer/database/pdf_quality_report.py || (echo "PDF report module not found" && exit 1)

# Expose the port the app runs on
EXPOSE 8000

# Add healthcheck
HEALTHCHECK --interval=30s --timeout=30s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1

# Back to your ORIGINAL command - simple Flask server
CMD ["flask", "run", "--host=0.0.0.0", "--port=8000"] 