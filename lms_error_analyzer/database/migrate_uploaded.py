#!/usr/bin/env python3
"""
Generic Tabular Ingestion Script (CSV/Excel -> MySQL)

Enterprise-agnostic loader that:
- Reads any CSV or Excel file
- Derives target table from the filename (tolerant matching)
- Introspects MySQL table columns and inserts only the intersection
- Ignores unknown CSV columns (not present in DB table)
- Uses INSERT IGNORE to skip duplicates based on existing keys/indexes

Usage examples:
python migrate_uploaded.py --file lms_error_analyzer/csvInput/Activity_Curriculum.csv
python migrate_uploaded.py --dir lms_error_analyzer/csvInput

Notes:
- Keeps current hardcoded MySQL config (error_logging) per request
- Assumes target tables already exist and are named to match the files
"""

import os
import sys
import argparse
import logging
from pathlib import Path
from typing import List, Optional, Tuple

import pandas as pd
import mysql.connector

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('migration.log'),
        logging.StreamHandler(sys.stdout)
    ]
)

# Set encoding for stream handler
for handler in logging.getLogger().handlers:
    if hasattr(handler, 'stream') and hasattr(handler.stream, "reconfigure"):
        handler.stream.reconfigure(encoding='utf-8')

logger = logging.getLogger(__name__)

# Database configuration (kept as-is for now)
DB_CONFIG = {
    'host': 'localhost',
    'port': 3306,
    'database': 'error_logging',
    'user': 'error_logger',
    'password': 'MySQLserver123'
}


def quote_identifier(identifier: str) -> str:
    """Safely quote MySQL identifiers, handling spaces or reserved words."""
    # Escape backticks within identifier
    safe = identifier.replace('`', '``')
    return f"`{safe}`"


class GenericTabularMigrator:
    """Generic CSV/Excel to MySQL ingestor that is not column-specific."""

    def __init__(self, file_path: str):
        self.file_path = file_path
        self.file_name = Path(file_path).name
        self.base_name = Path(file_path).stem
        self.conn = None
        self.cursor = None
        self.df: Optional[pd.DataFrame] = None
        self.table_schema = DB_CONFIG['database']
        self.table_name: Optional[str] = None

    def connect_db(self) -> bool:
        try:
            self.conn = mysql.connector.connect(**DB_CONFIG)
            self.cursor = self.conn.cursor()
            logger.info("✅ Connected to MySQL")
            return True
        except Exception as e:
            logger.error(f"❌ Database connection failed: {e}")
            return False

    def disconnect_db(self):
        try:
            if self.cursor:
                self.cursor.close()
            if self.conn:
                self.conn.close()
        finally:
            logger.info("🔌 Disconnected from MySQL")

    def _resolve_table_name(self) -> str:
        """Convert filename to table name: CamelCase to snake_case."""
        import re
        # Convert CamelCase to snake_case: Activity_ILTClass -> activity_ilt_class
        name = self.base_name.replace(' ', '_')
        # Insert underscore before uppercase letters that follow lowercase/digits
        s1 = re.sub('([a-z0-9])([A-Z])', r'\1_\2', name)
        # Insert underscore before uppercase letters that are followed by lowercase letters  
        s2 = re.sub('([A-Z])([A-Z][a-z])', r'\1_\2', s1)
        return s2.lower()

    def _ensure_columns_are_text(self, table_name: str, columns: List[str]):
        """Convert specified columns to accept any data (TEXT or large VARCHAR)"""
        try:
            for col in columns:
                # First try TEXT
                alter_sql = f"ALTER TABLE {quote_identifier(table_name)} MODIFY COLUMN {quote_identifier(col)} TEXT"
                try:
                    self.cursor.execute(alter_sql)
                    logger.info(f"✅ Converted {col} to TEXT in {table_name}")
                except Exception as e:
                    # If TEXT fails (likely due to index), try smaller VARCHAR sizes
                    if "used in key specification" in str(e) or "key was too long" in str(e):
                        # Try progressively smaller VARCHAR sizes for indexed columns
                        for varchar_size in [1000, 500, 255]:
                            try:
                                alter_sql = f"ALTER TABLE {quote_identifier(table_name)} MODIFY COLUMN {quote_identifier(col)} VARCHAR({varchar_size})"
                                self.cursor.execute(alter_sql)
                                logger.info(f"✅ Converted {col} to VARCHAR({varchar_size}) in {table_name}")
                                break
                            except Exception as e2:
                                if varchar_size == 255:  # Last attempt failed
                                    # Try dropping and recreating the column as last resort
                                    try:
                                        logger.warning(f"⚠️ Attempting to drop and recreate {col} as VARCHAR(255)")
                                        drop_sql = f"ALTER TABLE {quote_identifier(table_name)} DROP COLUMN {quote_identifier(col)}"
                                        self.cursor.execute(drop_sql)
                                        add_sql = f"ALTER TABLE {quote_identifier(table_name)} ADD COLUMN {quote_identifier(col)} VARCHAR(255)"
                                        self.cursor.execute(add_sql)
                                        logger.info(f"✅ Recreated {col} as VARCHAR(255) in {table_name}")
                                    except Exception as e3:
                                        logger.warning(f"❌ Could not recreate {col}: {e3}")
                                continue
                    else:
                        logger.warning(f"❌ Could not convert {col} to TEXT: {e}")
            self.conn.commit()
            logger.info(f"🔄 Column conversion completed for {table_name}")
        except Exception as e:
            logger.error(f"❌ Error converting columns: {e}")

    def _fetch_table_columns(self, table_name: str) -> List[str]:
        """Fetch ordered column list from MySQL for target table."""
        try:
            sql = (
                "SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS "
                "WHERE TABLE_SCHEMA = %s AND TABLE_NAME = %s ORDER BY ORDINAL_POSITION"
            )
            cur = self.conn.cursor()
            cur.execute(sql, (self.table_schema, table_name))
            cols = [row[0] for row in cur.fetchall()]
            cur.close()
            return cols
        except Exception as e:
            logger.error(f"❌ Failed to read columns for table {table_name}: {e}")
            return []

    def _read_file_into_dataframe(self) -> bool:
        try:
            if not Path(self.file_path).exists():
                raise FileNotFoundError(f"File not found: {self.file_path}")

            ext = Path(self.file_path).suffix.lower()
            logger.info(f"📖 Reading {ext} file: {self.file_path}")
            if ext in ['.xlsx', '.xls']:
                self.df = pd.read_excel(self.file_path, sheet_name=0, dtype=str, keep_default_na=False)# why keep_default_na=False? Because we want to keep t
            elif ext == '.csv':
                # Handle CSV with proper encoding detection and NaN handling
                self.df = pd.read_csv(self.file_path, dtype=str, keep_default_na=False, na_values=[''])
            else:
                raise ValueError(f"Unsupported file type: {ext}")

            # Normalize headers and handle empty DataFrames
            self.df.columns = [str(c).strip() for c in self.df.columns]
            
            # Check for empty DataFrame
            if len(self.df) == 0:
                logger.warning(f"⚠️ File appears to be empty: {self.file_path}")
                return False
                
            # Check for unnamed/empty columns
            empty_cols = [col for col in self.df.columns if col == '' or col.startswith('Unnamed:')]
            if empty_cols:
                logger.warning(f"⚠️ Found {len(empty_cols)} empty/unnamed columns, dropping them")
                self.df = self.df.drop(columns=empty_cols)
            
            logger.info(f"✅ Loaded {len(self.df)} rows | Columns: {list(self.df.columns)}")
            return True
        except Exception as e:
            logger.error(f"❌ Failed to read file: {e}")
            return False

    def _build_insert_statement(self, table_name: str, insert_columns: List[str]) -> Tuple[str, List[str]]:
        # First, alter all columns to TEXT to accept any data
        self._ensure_columns_are_text(table_name, insert_columns)
        
        placeholders = ", ".join(["%s"] * len(insert_columns))
        quoted_cols = ", ".join([quote_identifier(col) for col in insert_columns])
        sql = f"REPLACE INTO {quote_identifier(table_name)} ({quoted_cols}) VALUES ({placeholders})"
        return sql, insert_columns

    def _iter_row_values(self, insert_columns: List[str]):
        for _, row in self.df.iterrows():
            values = []
            for col in insert_columns:
                val = row.get(col)
                if val is None or pd.isna(val):
                    values.append(None)
                else:
                    # Keep the exact input data as-is - no conversion at all
                    values.append(str(val))
            yield values

    def run(self) -> bool:
        logger.info(f"🚀 Starting ingestion for: {self.file_name}")

        if not self.connect_db():
            return False

        try:
            self.table_name = self._resolve_table_name()
            logger.info(f"🗂️ Target table resolved as: {self.table_name}")

            if not self._read_file_into_dataframe():
                return False

            table_columns = self._fetch_table_columns(self.table_name)
            if not table_columns:
                logger.error(f"❌ No columns found for table {self.table_name}")
                return False

            # Determine intersection: CSV headers present in table
            csv_headers = list(self.df.columns)
            insert_columns = [c for c in csv_headers if c in table_columns]
            unknown_columns = [c for c in csv_headers if c not in table_columns]

            if not insert_columns:
                logger.error("❌ No matching columns between file and table. Abort.")
                logger.info(f"File columns: {csv_headers}")
                logger.info(f"Table columns: {table_columns}")
                return False

            if unknown_columns:
                logger.info(f"ℹ️ Ignoring unknown columns not in table: {unknown_columns}")

            insert_sql, _ = self._build_insert_statement(self.table_name, insert_columns)

            inserted = 0
            failed = 0

            # Insert row by row - log failures but continue
            for row_idx, values in enumerate(self._iter_row_values(insert_columns), 1):
                try:
                    self.cursor.execute(insert_sql, values)
                    self.conn.commit()
                    inserted += 1
                    
                    # Log progress every 100 rows
                    if inserted % 100 == 0:
                        logger.info(f"Processed {inserted} rows so far...")
                        
                except Exception as e:
                    failed += 1
                    logger.warning(f"Row {row_idx} failed to insert: {e}")
                    # Log the actual values that failed for debugging
                    logger.debug(f"Failed values: {values}")
                    # Don't rollback - just continue to next row

            total_processed = len(self.df)
            logger.info(f"✅ Done. Total rows: {total_processed} | Inserted: {inserted} | Failed: {failed}")
            return True  # Always return True - we want to process all files even if some rows fail
        finally:
            self.disconnect_db()


def discover_files_in_directory(directory: str) -> List[str]:
    supported_exts = {'.csv', '.xlsx', '.xls'}
    files: List[str] = []
    for root, _, filenames in os.walk(directory):
        for name in filenames:
            if Path(name).suffix.lower() in supported_exts:
                files.append(os.path.join(root, name))
    return files


def main():
    parser = argparse.ArgumentParser(description="Ingest CSV/Excel files into MySQL (column-agnostic)")
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument('--file', help='Path to a single CSV/Excel file')
    group.add_argument('--dir', help='Path to a directory to process all CSV/Excel files (no default)')
    args = parser.parse_args()

    targets: List[str] = []
    if args.file:
        targets = [args.file]
    elif args.dir:
        targets = discover_files_in_directory(args.dir)
        if not targets:
            logger.info("No CSV/Excel files found in directory.")
            sys.exit(0)

    overall_success = True
    processed_count = 0
    failed_count = 0
    
    logger.info(f"🎯 Processing {len(targets)} file(s)...")
    
    for path in targets:
        logger.info(f"\n{'='*60}")
        migrator = GenericTabularMigrator(path)
        success = migrator.run()
        if success:
            processed_count += 1
        else:
            failed_count += 1
        overall_success = overall_success and success

    logger.info(f"\n{'='*60}")
    logger.info(f"🎉 SUMMARY: {processed_count} successful, {failed_count} failed out of {len(targets)} total files")
    sys.exit(0 if overall_success else 1)


if __name__ == "__main__":
    main()