# Use Python 3.11 slim as base image
FROM python:3.11-slim

# Add non-root user for security
RUN groupadd -r appuser && useradd -r -g appuser appuser

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    python3-dev \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Add CloudWatch agent for logging (architecture-specific)
RUN ARCH=$(dpkg --print-architecture) && \
    if [ "$ARCH" = "arm64" ]; then \
        curl -O https://s3.amazonaws.com/amazoncloudwatch-agent/debian/arm64/latest/amazon-cloudwatch-agent.deb; \
    else \
        curl -O https://s3.amazonaws.com/amazoncloudwatch-agent/debian/amd64/latest/amazon-cloudwatch-agent.deb; \
    fi && \
    dpkg -i amazon-cloudwatch-agent.deb && \
    rm amazon-cloudwatch-agent.deb

# Copy only the requirements files first to leverage Docker cache
COPY file_server/requirements.txt file_server-requirements.txt
COPY lasVegas/requirements.txt lasvegas-requirements.txt

# Install Python dependencies
RUN pip install --no-cache-dir -r file_server-requirements.txt -r lasvegas-requirements.txt

# Copy the application code
COPY . .

# Create necessary directories and set permissions
RUN mkdir -p file_server/uploads file_server/processed file_server/logs \
    && chown -R appuser:appuser /app

# Set environment variables
ENV PYTHONPATH=/app
ENV FLASK_APP=file_server/app.py
ENV FLASK_ENV=production
ENV AWS_DEFAULT_REGION=us-east-1

# Switch to non-root user
USER appuser

# Expose the port the app runs on
EXPOSE 5000

# Health check for ECS
HEALTHCHECK --interval=30s --timeout=3s \
  CMD curl -f http://localhost:5000/ || exit 1

# Command to run the application
CMD ["python", "-m", "flask", "run", "--host=0.0.0.0"]
