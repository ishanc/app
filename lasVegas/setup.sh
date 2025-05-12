#!/bin/bash

# Remove existing virtual environment if it exists
if [ -d "venv" ]; then
    echo "Removing existing virtual environment..."
    rm -rf venv
fi

# Check if Python 3.11 is installed
if command -v python3.11 &>/dev/null; then
    PYTHON_CMD=python3.11
else
    echo "Python 3.11 is not installed. Please install it first."
    exit 1
fi

# Create new virtual environment with Python 3.11
echo "Creating new virtual environment with Python 3.11..."
$PYTHON_CMD -m venv venv

# Activate virtual environment
echo "Activating virtual environment..."
source venv/bin/activate

# Install setuptools first
echo "Installing setuptools..."
pip install --upgrade pip setuptools wheel

# Install dependencies
echo "Installing dependencies from requirements.txt..."
pip install -r requirements.txt

echo "Setup complete! Virtual environment is activated."

# Activate virtual environment
echo "Activating virtual environment..."
source venv/bin/activate