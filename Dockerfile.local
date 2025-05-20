# Use Python 3.11 slim as base image
FROM python:3.11-slim

# Add non-root user for security
RUN groupadd -r appuser && useradd -r -g appuser appuser

# Set working directory
WORKDIR /app

# Install system dependencies
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && apt-get install -y \
    gcc \
    python3-dev \
    curl \
    && rm -rf /var/lib/apt/lists/*

# For local development, we don't need the CloudWatch agent
# The CloudWatch agent will be added in the production build

# Copy only the requirements files first to leverage Docker cache
COPY file_server/requirements.txt file_server-requirements.txt
COPY lasVegas/requirements.txt lasvegas-requirements.txt

# Install Python dependencies
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install --no-cache-dir -r file_server-requirements.txt -r lasvegas-requirements.txt

# Copy only necessary application code
COPY file_server/app.py file_server/app.py
COPY file_server/static file_server/static
COPY file_server/templates file_server/templates
COPY lasVegas/app lasVegas/app
COPY lasVegas/Core lasVegas/Core
COPY lasVegas/source lasVegas/source

# Create necessary directories and set permissions
RUN mkdir -p file_server/uploads file_server/processed file_server/logs \
    && chown -R appuser:appuser /app \
    && chmod -R 755 file_server/uploads file_server/processed file_server/logs

# Set environment variables
ENV PYTHONPATH=/app:${PYTHONPATH}
ENV FLASK_APP=file_server/app.py
ENV FLASK_ENV=production
ENV AWS_DEFAULT_REGION=us-east-1

# Switch to non-root user
USER appuser

# Expose the port the app runs on
EXPOSE 8080

# Health check for ECS
HEALTHCHECK --interval=30s --timeout=3s \
  CMD curl -f http://localhost:8080/ || exit 1

# Command to run the application
CMD ["python", "-m", "flask", "run", "--host=0.0.0.0", "--port=8080"]
