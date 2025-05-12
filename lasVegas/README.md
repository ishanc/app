# lasVegas Project

This project is designed to transform data from SumTotal to a format compatible with Neo4j. It includes functionality for transforming files and processing folders.

## Project Structure

```
lasVegas
├── app
│   └── sumtotal_transformer_with_neo4j.py
├── requirements.txt
├── setup.sh
└── README.md
```

## Setup Instructions

1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd lasVegas
   ```

2. **Run the setup script**:
   ```bash
   bash setup.sh
   ```

3. **Activate the virtual environment**:
   After running the setup script, activate the virtual environment using:
   ```bash
   source venv/bin/activate
   ```

## Usage

To use the data transformation functionality, ensure that your CSV files are placed in the appropriate input folder. You can then call the functions defined in `app/sumtotal_transformer_with_neo4j.py` to process the data.

## Dependencies

This project requires the following Python packages:
- pandas
- py2neo
- python-dotenv

Make sure to install these dependencies before running the project.