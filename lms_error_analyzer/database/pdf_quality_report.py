#!/usr/bin/env python3
"""
Optimized PDF Quality Report Generator

Generates PDF reports for data quality analysis with vertical text expansion
instead of truncation to preserve critical information.
"""

import os
import logging
from datetime import datetime
from typing import Dict, List, Optional, Any
from collections import defaultdict
from dataclasses import dataclass

import mysql.connector
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.units import inch
from reportlab.lib.colors import HexColor
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle
from reportlab.lib.enums import TA_CENTER
from dotenv import load_dotenv

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)
load_dotenv()


@dataclass
class FileQualityScore:
    """Quality score breakdown for a file"""
    file_name: str
    mandatory_fields_complete: float
    records_without_errors: float  # This is now Quality %
    total_records: int
    error_count: int


class PDFQualityReportGenerator:
    """Optimized PDF quality report generator"""
    
    # Simplified remediation mapping
    REMEDIATION_MAPPING = {
        'MANDATORY_EMPTY': "Source: mandatory field empty. Requires data correction.",
        'TRUNCATION': "Source: field exceeds length limit. Adjust target or truncate data.",
        'ENCODING_ISSUE': "Source: invalid characters. Fix character encoding.",
        'HETEROGENEOUS_TYPE': "Workshop: mixed data types. Standardize approach needed.",
        'DUPLICATE_RECORD': "Transform: duplicate found. Implement deduplication logic.",
        'TYPE_COMPATIBILITY': "Workshop: incompatible types. Resolve compatibility.",
        'DATE_FORMAT': "Workshop: invalid date format. Transform to target format.",
        'LEADING_SPACES': "Transform: leading whitespace. Auto-fix with trim.",
        'TRAILING_SPACES': "Transform: trailing whitespace. Auto-fix with trim.",
        'OUTLIER_VALUE': "Source/Workshop: outlier detected. Validate and correct.",
        'LEADING_ZEROS': "Workshop: unwanted leading zeros. Confirm removal.",
        'BOOLEAN_CONVERSION': "Workshop: boolean transformation issue. Validate.",
        'HEADER_INCONSISTENCY': "Source/Workshop: header inconsistency. Confirm structure.",
        'DELIMITER_ISSUE': "Source: delimiter issue. Implement detection logic.",
        'COMPLETENESS_SCORE': "Source/Workshop: completeness issue. Report metric."
    }
    
    SEVERITY_CATEGORIES = {
        'Critical': ['MANDATORY_EMPTY', 'DUPLICATE_RECORD', 'TYPE_COMPATIBILITY'],
        'High': ['TRUNCATION', 'ENCODING_ISSUE', 'HETEROGENEOUS_TYPE'],
        'Medium': ['LEADING_SPACES', 'TRAILING_SPACES', 'DATE_FORMAT', 'OUTLIER_VALUE'],
        'Low': ['LEADING_ZEROS', 'BOOLEAN_CONVERSION', 'COMPLETENESS_SCORE', 'HEADER_INCONSISTENCY', 'DELIMITER_ISSUE']
    }
    
    def __init__(self, output_dir: str):
        self.output_dir = output_dir
        self.db_connection = mysql.connector.connect(
            host=os.getenv('MYSQL_HOST', 'localhost'),
            user=os.getenv('MYSQL_USER'),
            password=os.getenv('MYSQL_PASSWORD'),
            database=os.getenv('MYSQL_NAME'),
            port=int(os.getenv('MYSQL_PORT', 3306)),
            ssl_disabled=True,
            autocommit=False,
            connect_timeout=30,
            use_unicode=True
        )
    
    def get_completeness_data(self, file_names: List[str]) -> Dict[str, Dict[str, Any]]:
        """Get completeness data from database"""
        try:
            cursor = self.db_connection.cursor(dictionary=True)
            placeholders = ', '.join(['%s'] * len(file_names))
            
            cursor.execute(f"""
                SELECT file_name, mandatory_completeness, total_records, incomplete_records, last_processed
                FROM file_completeness_summary 
                WHERE file_name IN ({placeholders})
            """, file_names)
            
            results = cursor.fetchall()
            cursor.close()
            
            # Convert to dictionary
            data = {}
            for row in results:
                data[row['file_name']] = {
                    'mandatory_completeness': float(row.get('mandatory_completeness', 0) or 0),
                    'total_records': int(row.get('total_records', 0) or 0),
                    'incomplete_records': int(row.get('incomplete_records', 0) or 0),
                    'last_processed': row.get('last_processed')
                }
            
            # Add empty entries for missing files
            for file_name in file_names:
                if file_name not in data:
                    data[file_name] = {
                        'mandatory_completeness': 0.0,
                        'total_records': 0,
                        'incomplete_records': 0,
                        'last_processed': None
                    }
            
            return data
            
        except Exception as e:
            logger.error(f"Error getting completeness data: {e}")
            return {f: {'mandatory_completeness': 0.0, 'total_records': 0, 'incomplete_records': 0} 
                    for f in file_names}
    
    def get_error_data(self, file_names: List[str]) -> Dict[str, Dict[str, Any]]:
        """Get error data from database"""
        try:
            cursor = self.db_connection.cursor(dictionary=True)
            placeholders = ', '.join(['%s'] * len(file_names))
            
            # Get error counts by type
            cursor.execute(f"""
                SELECT file_name, validation_type, COUNT(*) as error_count
                FROM error_logs 
                WHERE file_name IN ({placeholders})
                GROUP BY file_name, validation_type
            """, file_names)
            error_results = cursor.fetchall()
            
            # Get total error counts
            cursor.execute(f"""
                SELECT file_name, COUNT(*) as total_errors
                FROM error_logs 
                WHERE file_name IN ({placeholders})
                GROUP BY file_name
            """, file_names)
            total_results = cursor.fetchall()
            cursor.close()
            
            # Build error data structure
            data = {}
            for file_name in file_names:
                data[file_name] = {'total_errors': 0, 'error_types': {}}
            
            for row in error_results:
                if row['file_name'] in data:
                    data[row['file_name']]['error_types'][row['validation_type']] = row['error_count']
            
            for row in total_results:
                if row['file_name'] in data:
                    data[row['file_name']]['total_errors'] = row['total_errors']
            
            return data
            
        except Exception as e:
            logger.error(f"Error getting error data: {e}")
            return {f: {'total_errors': 0, 'error_types': {}} for f in file_names}
    
    def _extract_field_name_from_error_message(self, message: str) -> Optional[str]:
        """
        Extract SumTotal field name from error message.
        
        Error messages typically follow format: "Field 'FieldName' at row X has [error description]"
        
        Args:
            message: Error message string
            
        Returns:
            Extracted field name or None if not found
        """
        import re
        # Pattern to match "Field 'FieldName'" or similar variations
        patterns = [
            r"Field '([^']+)'",      # Field 'FieldName'
            r"field '([^']+)'",      # field 'FieldName' 
            r"Field \"([^\"]+)\"",   # Field "FieldName"
            r"field \"([^\"]+)\""    # field "FieldName"
        ]
        
        for pattern in patterns:
            match = re.search(pattern, message)
            if match:
                return match.group(1).strip()
        
        return None
    
    def _get_mandatory_fields_for_file(self, file_name: str) -> List[str]:
        """
        Get mandatory fields for a file using Dashboard's Neo4j integration.
        
        Args:
            file_name: Name of the file
            
        Returns:
            List of mandatory SumTotal field names
        """
        try:
            from dashboard import Dashboard
            dashboard = Dashboard()
            try:
                mandatory_fields = dashboard.get_mandatory_fields_from_neo4j(file_name)
                logger.debug(f"Found {len(mandatory_fields)} mandatory fields for {file_name}: {mandatory_fields}")
                return mandatory_fields
            finally:
                dashboard.close_connections()
        except Exception as e:
            logger.warning(f"Could not get mandatory fields for {file_name}: {e}")
            return []
    
    def _calculate_error_prone_records(self, file_name: str, total_records: int, incomplete_records: int) -> int:
        """
        Calculate the number of error-prone records for a file.
        
        An error-prone record is one that has one or more errors in mandatory fields.
        
        Args:
            file_name: Name of the file
            total_records: Total number of records in the file
            incomplete_records: Number of records with incomplete mandatory fields
            
        Returns:
            Number of error-prone records
        """
        if total_records == 0:
            return 0
            
        try:
            cursor = self.db_connection.cursor(dictionary=True)
            
            # Get mandatory fields for this file
            mandatory_fields = self._get_mandatory_fields_for_file(file_name)
            if not mandatory_fields:
                logger.warning(f"No mandatory fields found for {file_name}, falling back to incomplete_records: {incomplete_records}")
                # Fallback: If we can't determine mandatory fields, use incomplete_records as proxy
                # This ensures consistency with mandatory completeness calculation
                return incomplete_records
            
            # Build SQL to get errors in mandatory fields
            # We need to extract field names from error messages and match against mandatory fields
            cursor.execute("""
                SELECT DISTINCT line_number, message
                FROM error_logs 
                WHERE file_name = %s 
                AND line_number IS NOT NULL
            """, (file_name,))
            
            error_results = cursor.fetchall()
            cursor.close()
            
            # Track which line numbers (records) have errors in mandatory fields
            error_prone_lines = set()
            
            for error_row in error_results:
                line_number = error_row['line_number']
                message = error_row['message']
                
                # Extract field name from error message
                field_name = self._extract_field_name_from_error_message(message)
                
                # Check if this field is mandatory
                if field_name and field_name in mandatory_fields:
                    error_prone_lines.add(line_number)
                    logger.debug(f"Found error in mandatory field '{field_name}' at line {line_number}")
            
            error_prone_count = len(error_prone_lines)
            logger.info(f"File {file_name}: {error_prone_count} out of {total_records} records are error-prone (detailed analysis)")
            
            # Sanity check: If detailed analysis gives 0 but we have incomplete_records, use incomplete_records
            if error_prone_count == 0 and incomplete_records > 0:
                logger.warning(f"File {file_name}: Detailed analysis found 0 error-prone records but incomplete_records={incomplete_records}. Using incomplete_records as fallback.")
                return incomplete_records
            
            return error_prone_count
            
        except Exception as e:
            logger.error(f"Error calculating error-prone records for {file_name}: {e}")
            # If detailed analysis fails, fall back to incomplete_records
            logger.info(f"Using incomplete_records ({incomplete_records}) as fallback for {file_name}")
            return incomplete_records
    
    def calculate_quality_scores(self, completeness_data: Dict, error_data: Dict) -> List[FileQualityScore]:
        """
        Calculate quality scores for files using the new Quality % methodology.
        
        Quality % = (total_records - error_prone_records) / total_records * 100
        where error_prone_records are records with 1+ errors in mandatory fields.
        
        FIXED: Now uses incomplete_records as fallback when Neo4j mandatory field lookup fails.
        This ensures Quality % is consistent with Mandatory Complete %.
        
        Args:
            completeness_data: Completeness data for each file
            error_data: Error data for each file
            
        Returns:
            List of FileQualityScore objects sorted by Quality %
        """
        scores = []
        
        for file_name in completeness_data.keys():
            comp = completeness_data[file_name]
            errors = error_data[file_name]
            
            # Extract basic metrics
            mandatory_complete = comp.get('mandatory_completeness', 0.0)
            total_records = comp.get('total_records', 0)
            incomplete_records = comp.get('incomplete_records', 0)
            total_errors = errors.get('total_errors', 0)
            
            # Calculate error-prone records (records with errors in mandatory fields)
            error_prone_records = self._calculate_error_prone_records(file_name, total_records, incomplete_records)
            
            # Calculate Quality % = (total_records - error_prone_records) / total_records * 100
            quality_percentage = 0.0
            if total_records > 0:
                clean_records = total_records - error_prone_records
                quality_percentage = (clean_records / total_records) * 100
            
            # Ensure bounds [0, 100]
            quality_percentage = max(0.0, min(100.0, quality_percentage))
            
            logger.info(f"File {file_name}: Quality % = {quality_percentage:.1f}% "
                       f"({total_records - error_prone_records}/{total_records} clean records)")
                
            scores.append(FileQualityScore(
                    file_name=file_name,
                    mandatory_fields_complete=mandatory_complete,
                    records_without_errors=round(quality_percentage, 1),  # This is Quality %
                    total_records=total_records,
                    error_count=total_errors
                ))
            
        return sorted(scores, key=lambda x: x.records_without_errors, reverse=True)
    
    def create_expandable_table(self, data: List[List[str]], col_widths: List[float]) -> Table:
        """Create table with vertical text expansion instead of truncation"""
        if not data:
            return None
        
        # Process data to use Paragraph objects for automatic wrapping
        processed_data = []
        styles = getSampleStyleSheet()
        
        # Create custom style for table cells with enhanced word wrap
        cell_style = ParagraphStyle(
            'TableCell',
            parent=styles['Normal'],
            fontSize=8,
            leading=10,
            leftIndent=0,
            rightIndent=0,
            wordWrap='LTR',
            allowWidows=1,
            allowOrphans=1,
            splitLongWords=True,  # Allow breaking long words
            breakLongWords=True,  # Force break very long words
            spaceAfter=0,
            spaceBefore=0
        )
        
        header_style = ParagraphStyle(
            'TableHeader',
            parent=styles['Normal'],
            fontSize=9,
            leading=11,
            fontName='Helvetica-Bold',
            textColor=HexColor('#FFFFFF'),
            wordWrap='LTR',
            allowWidows=1,
            allowOrphans=1
        )
        
        for row_idx, row in enumerate(data):
            processed_row = []
            for cell in row:
                if row_idx == 0:  # Header row
                    processed_row.append(Paragraph(str(cell), header_style))
                else:
                    processed_row.append(Paragraph(str(cell), cell_style))
            processed_data.append(processed_row)
        
        # Create table with automatic row height calculation
        table = Table(processed_data, colWidths=col_widths, splitByRow=True)
        table.setStyle(TableStyle([
            # Header styling
            ('BACKGROUND', (0, 0), (-1, 0), HexColor('#2E86AB')),
            ('TEXTCOLOR', (0, 0), (-1, 0), HexColor('#FFFFFF')),
            ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
            ('FONTSIZE', (0, 0), (-1, 0), 9),
            
            # Body styling
            ('BACKGROUND', (0, 1), (-1, -1), HexColor('#F8F9FA')),
            ('FONTNAME', (0, 1), (-1, -1), 'Helvetica'),
            ('FONTSIZE', (0, 1), (-1, -1), 8),
            
            # Layout
            ('ALIGN', (0, 0), (-1, -1), 'LEFT'),
            ('VALIGN', (0, 0), (-1, -1), 'TOP'),
            ('LEFTPADDING', (0, 0), (-1, -1), 6),
            ('RIGHTPADDING', (0, 0), (-1, -1), 6),
            ('TOPPADDING', (0, 0), (-1, -1), 8),
            ('BOTTOMPADDING', (0, 0), (-1, -1), 8),
            
            # Grid
            ('GRID', (0, 0), (-1, -1), 1, HexColor('#CCCCCC')),
            ('ROWBACKGROUNDS', (0, 1), (-1, -1), [HexColor('#FFFFFF'), HexColor('#F8F9FA')])
        ]))
        
        return table
    
    def generate_report(self, file_names: List[str]) -> str:
        """Generate PDF report"""
        try:
            logger.info(f"Generating PDF report for {len(file_names)} files")
            
            # Get data
            completeness_data = self.get_completeness_data(file_names)
            error_data = self.get_error_data(file_names)
            quality_scores = self.calculate_quality_scores(completeness_data, error_data)
            
            # Generate PDF
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            pdf_filename = f"data_quality_report_{timestamp}.pdf"
            pdf_path = os.path.join(self.output_dir, pdf_filename)
            
            self._create_pdf(pdf_path, completeness_data, error_data, quality_scores, file_names)
            
            logger.info(f"PDF report generated: {pdf_filename}")
            return pdf_filename
            
        except Exception as e:
            logger.error(f"Error generating PDF report: {e}")
            raise
        finally:
            self._cleanup()
    
    def _create_pdf(self, pdf_path: str, completeness_data: Dict, error_data: Dict, 
                          quality_scores: List[FileQualityScore], file_names: List[str]):
        """Create the PDF document"""
        doc = SimpleDocTemplate(pdf_path, pagesize=A4, rightMargin=72, leftMargin=72,
                              topMargin=72, bottomMargin=18)
        story = []
        styles = getSampleStyleSheet()
        
        # Title
        title_style = ParagraphStyle(
            'CustomTitle',
            parent=styles['Heading1'],
            fontSize=24,
            spaceAfter=30,
            alignment=TA_CENTER,
            textColor=HexColor('#2E86AB')
        )
        
        story.append(Paragraph("Data Quality Analysis Report", title_style))
        story.append(Paragraph(f"Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}", styles['Normal']))
        story.append(Spacer(1, 20))
        
        # Executive Summary
        self._add_summary(story, styles, completeness_data, error_data)
        
        # Quality Scores Table
        self._add_quality_table(story, styles, quality_scores)
        
        # Error Summary Table
        self._add_error_table(story, styles, error_data)
        
        # Cross-File Integrity Analysis (Phase 2 Enhancement)
        self._add_cross_file_integrity_analysis(story, styles, file_names)
        
        # Cross-File Error Patterns
        self._add_cross_file_patterns(story, styles, error_data)
        
        doc.build(story)
    
    def _add_summary(self, story, styles, completeness_data: Dict, error_data: Dict):
        """Add executive summary"""
        story.append(Paragraph("Executive Summary", styles['Heading2']))
        
        total_files = len(completeness_data)
        total_records = sum(data.get('total_records', 0) for data in completeness_data.values())
        total_errors = sum(data.get('total_errors', 0) for data in error_data.values())
        
        summary = f"""
        This report analyzes data quality across {total_files} files containing {total_records:,} total records.
        The analysis identified {total_errors:,} validation errors.
        
        <b>Key Recommendations:</b>
        • Address mandatory field completeness issues at the source
        • Implement data validation workflows before processing
        • Review critical validation errors for immediate remediation
        """
        
        story.append(Paragraph(summary, styles['Normal']))
        story.append(Spacer(1, 20))
    
    def _add_quality_table(self, story, styles, quality_scores: List[FileQualityScore]):
        """
        Add quality scores table to PDF report.
        
        Quality % is calculated as: (total_records - error_prone_records) / total_records * 100
        where error_prone_records are records with 1+ errors in mandatory fields.
        """
        if not quality_scores:
            return
            
        story.append(Paragraph("File Quality Scores", styles['Heading2']))
        
        data = [['File Name', 'Mandatory Complete', 'Total Records', 'Errors', 'Quality %']]
        
        for score in quality_scores:
            data.append([
                score.file_name,
                f"{score.mandatory_fields_complete:.1f}%",
                f"{score.total_records:,}",
                f"{score.error_count:,}",
                f"{score.records_without_errors:.1f}%"
            ])
        
        col_widths = [2.5*inch, 1.2*inch, 1.0*inch, 1.0*inch, 1.2*inch]
        table = self.create_expandable_table(data, col_widths)
        
        if table:
            story.append(table)
            story.append(Spacer(1, 20))
    
    def _add_error_table(self, story, styles, error_data: Dict):
        """Add error summary table"""
        story.append(Paragraph("Error Summary", styles['Heading2']))
        
        # Aggregate errors
        error_summary = defaultdict(int)
        for file_errors in error_data.values():
            for error_type, count in file_errors.get('error_types', {}).items():
                error_summary[error_type] += count
        
        data = [['Error Type', 'Count', 'Severity', 'Recommended Action']]
        
        for error_type, count in sorted(error_summary.items(), key=lambda x: x[1], reverse=True):
            severity = self._get_severity(error_type)
            action = self.REMEDIATION_MAPPING.get(error_type, "Review and address")
            
            data.append([
                error_type,
                f"{count:,}",
                severity,
                action
            ])
        
        col_widths = [1.5*inch, 0.8*inch, 0.8*inch, 3.9*inch]
        table = self.create_expandable_table(data, col_widths)
        
        if table:
            story.append(table)
    
    def _merge_activities_orphan_data(self, cross_file_data: Dict, activities_data: List[Dict]) -> Dict:
        """
        Merge Activities orphan detection data into cross-file analysis structure
        
        Args:
            cross_file_data: Existing cross-file analysis data
            activities_data: Activities orphan detection results
            
        Returns:
            Dict: Merged cross-file analysis data
        """
        if not activities_data:
            return cross_file_data
            
        # Ensure structure exists
        if 'summary' not in cross_file_data:
            cross_file_data['summary'] = {}
        if 'integrity_analysis' not in cross_file_data:
            cross_file_data['integrity_analysis'] = []
        if 'cross_file_patterns' not in cross_file_data:
            cross_file_data['cross_file_patterns'] = {}
            
        # Calculate Activities summary metrics
        activities_orphaned = sum(row.get('orphaned_source_records', 0) for row in activities_data)
        activities_critical = len([row for row in activities_data if row.get('business_priority') in ['Critical', 'High']])
        activities_relationships = len(activities_data)
        
        # Debug logging
        print(f"🔍 DEBUG: Activities data length: {len(activities_data)}")
        print(f"🔍 DEBUG: Activities orphaned total: {activities_orphaned}")
        print(f"🔍 DEBUG: Activities critical count: {activities_critical}")
        if activities_data:
            print(f"🔍 DEBUG: Sample row: {activities_data[0]}")
        else:
            print("🔍 DEBUG: No Activities data received!")
        
        # Update summary
        existing_summary = cross_file_data['summary']
        existing_summary['total_relationships'] = existing_summary.get('total_relationships', 0) + activities_relationships
        existing_summary['critical_issues'] = existing_summary.get('critical_issues', 0) + activities_critical
        existing_summary['total_orphaned_records'] = existing_summary.get('total_orphaned_records', 0) + activities_orphaned
        
        # Convert Activities data to integrity_analysis format
        for activity_row in activities_data:
            # Map Activities data to expected format
            source_pattern = activity_row.get('relationship_name', '').split(' → ')[0] if ' → ' in activity_row.get('relationship_name', '') else 'Activities Source'
            target_pattern = activity_row.get('relationship_name', '').split(' → ')[1] if ' → ' in activity_row.get('relationship_name', '') else 'Activities Target'
            
            # Determine severity based on priority and integrity percentage
            priority = activity_row.get('business_priority', 'Medium') 
            integrity_pct = activity_row.get('integrity_percentage', 100)
            
            if priority in ['Critical', 'High'] or integrity_pct < 50:
                severity = 'High'
            elif integrity_pct < 90:
                severity = 'Medium'
            else:
                severity = 'Low'
                
            integrity_item = {
                'source_pattern': source_pattern,
                'dependent_pattern': target_pattern,
                'key_field': activity_row.get('key_field', 'ActivityCode'),
                'integrity_percentage': integrity_pct,
                'orphaned_records': activity_row.get('orphaned_source_records', 0),
                'business_impact': self._get_activities_business_impact(activity_row),
                'severity': severity,
                'system_source': 'Activities Orphan Tracker'  # Mark as from new system
            }
            
            cross_file_data['integrity_analysis'].append(integrity_item)
            
        # Add Activities pattern to cross_file_patterns
        if activities_data:
            # Determine proper severity based on critical relationships
            domain_severity = 'Critical' if activities_critical > 0 else ('High' if activities_orphaned > 100 else 'Medium')
            
            cross_file_data['cross_file_patterns']['Activities Domain'] = {
                'files': ['Activity_Curriculum', 'Activity_ILTClass', 'Activity_ILTSessions'],
                'total_issues': activities_orphaned,
                'severity': domain_severity,
                'pattern_type': 'Business Rule Validation'
            }
            
        return cross_file_data
    
    def _merge_employees_orphan_data(self, cross_file_data: Dict, employees_data: List[Dict]) -> Dict:
        """
        Merge Employees orphan detection data into cross-file analysis structure
        
        Args:
            cross_file_data: Existing cross-file analysis data
            employees_data: Employees orphan detection results
            
        Returns:
            Dict: Merged cross-file analysis data
        """
        if not employees_data:
            return cross_file_data
            
        # Ensure structure exists
        if 'summary' not in cross_file_data:
            cross_file_data['summary'] = {}
        if 'integrity_analysis' not in cross_file_data:
            cross_file_data['integrity_analysis'] = []
        if 'cross_file_patterns' not in cross_file_data:
            cross_file_data['cross_file_patterns'] = {}
            
        # Calculate Employees summary metrics
        employees_orphaned = sum(row.get('orphaned_source_records', 0) for row in employees_data)
        employees_critical = len([row for row in employees_data if row.get('business_priority') in ['Critical', 'High']])
        employees_relationships = len(employees_data)
        
        # Debug logging
        print(f"🔍 DEBUG: Employees data length: {len(employees_data)}")
        print(f"🔍 DEBUG: Employees orphaned total: {employees_orphaned}")
        print(f"🔍 DEBUG: Employees critical count: {employees_critical}")
        if employees_data:
            print(f"🔍 DEBUG: Sample row: {employees_data[0]}")
        else:
            print("🔍 DEBUG: No Employees data received!")
        
        # Update summary
        existing_summary = cross_file_data['summary']
        existing_summary['total_relationships'] = existing_summary.get('total_relationships', 0) + employees_relationships
        existing_summary['critical_issues'] = existing_summary.get('critical_issues', 0) + employees_critical
        existing_summary['total_orphaned_records'] = existing_summary.get('total_orphaned_records', 0) + employees_orphaned
        
        # Convert Employees data to integrity_analysis format
        for employee_row in employees_data:
            # Map Employees data to expected format
            source_pattern = employee_row.get('relationship_name', '').split(' → ')[0] if ' → ' in employee_row.get('relationship_name', '') else 'Employees Source'
            target_pattern = employee_row.get('relationship_name', '').split(' → ')[1] if ' → ' in employee_row.get('relationship_name', '') else 'Employees Target'
            
            # Determine severity based on priority and integrity percentage
            priority = employee_row.get('business_priority', 'Medium') 
            integrity_pct = employee_row.get('integrity_percentage', 100)
            
            if priority in ['Critical', 'High'] or integrity_pct < 50:
                severity = 'High'
            elif integrity_pct < 90:
                severity = 'Medium'
            else:
                severity = 'Low'
                
            integrity_item = {
                'source_pattern': source_pattern,
                'dependent_pattern': target_pattern,
                'key_field': employee_row.get('key_field', 'PersonNumber'),
                'integrity_percentage': integrity_pct,
                'orphaned_records': employee_row.get('orphaned_source_records', 0),
                'business_impact': self._get_employees_business_impact(employee_row),
                'severity': severity,
                'system_source': 'Employees Orphan Tracker'  # Mark as from new system
            }
            
            cross_file_data['integrity_analysis'].append(integrity_item)
            
        # Add Employees pattern to cross_file_patterns
        if employees_data:
            # Determine proper severity based on critical relationships
            domain_severity = 'Critical' if employees_critical > 0 else ('High' if employees_orphaned > 100 else 'Medium')
            
            cross_file_data['cross_file_patterns']['Employees Domain'] = {
                'files': ['Core_Employee', 'Transcript_Curriculum', 'Prerequisites_Instructor'],
                'total_issues': employees_orphaned,
                'severity': domain_severity,
                'pattern_type': 'Employee Referential Integrity'
            }
            
        return cross_file_data
    
    def _merge_orgs_orphan_data(self, cross_file_data: Dict, orgs_data: List[Dict]) -> Dict:
        """
        Merge Organizations orphan detection data into cross-file analysis structure
        
        Args:
            cross_file_data: Existing cross-file analysis data
            orgs_data: Organizations orphan detection results
            
        Returns:
            Dict: Merged cross-file analysis data
        """
        if not orgs_data:
            return cross_file_data
            
        # Ensure structure exists
        if 'summary' not in cross_file_data:
            cross_file_data['summary'] = {}
        if 'integrity_analysis' not in cross_file_data:
            cross_file_data['integrity_analysis'] = []
        if 'cross_file_patterns' not in cross_file_data:
            cross_file_data['cross_file_patterns'] = {}
            
        # Calculate Organizations summary metrics
        orgs_orphaned = sum(row.get('orphaned_source_records', 0) for row in orgs_data)
        orgs_critical = len([row for row in orgs_data if row.get('business_priority') in ['Critical', 'High']])
        orgs_relationships = len(orgs_data)
        
        # Debug logging
        print(f"🔍 DEBUG: Organizations data length: {len(orgs_data)}")
        print(f"🔍 DEBUG: Organizations orphaned total: {orgs_orphaned}")
        print(f"🔍 DEBUG: Organizations critical count: {orgs_critical}")
        if orgs_data:
            print(f"🔍 DEBUG: Sample row: {orgs_data[0]}")
        else:
            print("🔍 DEBUG: No Organizations data received!")
        
        # Update summary
        existing_summary = cross_file_data['summary']
        existing_summary['total_relationships'] = existing_summary.get('total_relationships', 0) + orgs_relationships
        existing_summary['critical_issues'] = existing_summary.get('critical_issues', 0) + orgs_critical
        existing_summary['total_orphaned_records'] = existing_summary.get('total_orphaned_records', 0) + orgs_orphaned
        
        # Convert Organizations data to integrity_analysis format
        for org_row in orgs_data:
            # Map Organizations data to expected format
            source_pattern = org_row.get('relationship_name', '').split(' → ')[0] if ' → ' in org_row.get('relationship_name', '') else 'Organizations Source'
            target_pattern = org_row.get('relationship_name', '').split(' → ')[1] if ' → ' in org_row.get('relationship_name', '') else 'Organizations Target'
            
            # Determine severity based on priority and integrity percentage
            priority = org_row.get('business_priority', 'Medium') 
            integrity_pct = org_row.get('integrity_percentage', 100)
            
            if priority in ['Critical', 'High'] or integrity_pct < 50:
                severity = 'High'
            elif integrity_pct < 90:
                severity = 'Medium'
            else:
                severity = 'Low'
                
            integrity_item = {
                'source_pattern': source_pattern,
                'dependent_pattern': target_pattern,
                'key_field': org_row.get('key_field', 'OrganizationCode'),
                'integrity_percentage': integrity_pct,
                'orphaned_records': org_row.get('orphaned_source_records', 0),
                'business_impact': self._get_orgs_business_impact(org_row),
                'severity': severity,
                'system_source': 'Organizations Orphan Tracker'  # Mark as from new system
            }
            
            cross_file_data['integrity_analysis'].append(integrity_item)
            
        # Add Organizations pattern to cross_file_patterns
        if orgs_data:
            # Determine proper severity based on critical relationships
            domain_severity = 'Critical' if orgs_critical > 0 else ('High' if orgs_orphaned > 100 else 'Medium')
            
            cross_file_data['cross_file_patterns']['Organizations Domain'] = {
                'files': ['Core_Employee', 'Core_Organization', 'Core_Domain'],
                'total_issues': orgs_orphaned,
                'severity': domain_severity,
                'pattern_type': 'Organizational Structure Integrity'
            }
            
        return cross_file_data
    
    def _add_activities_orphan_section(self, story, styles, activities_data: List[Dict]):
        """Add dedicated Activities orphan detection section with optimal formatting"""
        if not activities_data:
            return
            
        story.append(Paragraph("Activities Domain Integrity Analysis", styles['Heading3']))
        story.append(Paragraph(
            "Business rule-based orphan detection for Activities domain relationships. "
            "This analysis identifies ILT courses and sessions that lack valid activity references.",
            styles['Normal']
        ))
        story.append(Spacer(1, 12))
        
        # Group by priority for better readability
        high_priority = [row for row in activities_data if row.get('business_priority') in ['Critical', 'High']]
        medium_priority = [row for row in activities_data if row.get('business_priority') == 'Medium']
        info_priority = [row for row in activities_data if row.get('business_priority') in ['Info', 'Low']]
        
        if high_priority:
            story.append(Paragraph(f"<b>High Priority Issues ({len(high_priority)} relationships)</b>", styles['Normal']))
            
            data = [['Relationship', 'Key Field', 'Integrity %', 'Orphaned', 'Business Impact']]
            
            for activity_row in high_priority:
                relationship_name = activity_row.get('relationship_name', 'Unknown')
                # Simplify relationship name for display
                simplified_name = relationship_name.replace('Activity_Sessions.', '').replace('Activity_SessionParts.', '')
                
                data.append([
                    simplified_name,
                    activity_row.get('key_field', ''),
                    f"{self._safe_format_number(activity_row.get('integrity_percentage'), 0):.1f}%",
                    f"{self._safe_format_number(activity_row.get('orphaned_source_records'), 0):,}",
                    self._get_activities_business_impact(activity_row)
                ])
            
            # Use wider columns specifically for Activities data
            col_widths = [2.8*inch, 1.0*inch, 0.8*inch, 0.8*inch, 2.6*inch]
            high_priority_table = self.create_expandable_table(data, col_widths)
            if high_priority_table:
                story.append(high_priority_table)
            story.append(Spacer(1, 12))
        
        if medium_priority:
            story.append(Paragraph(f"<b>Medium Priority Issues ({len(medium_priority)} relationships)</b>", styles['Normal']))
            
            data = [['Relationship', 'Integrity %', 'Orphaned Records']]
            
            for activity_row in medium_priority:
                relationship_name = activity_row.get('relationship_name', 'Unknown')
                simplified_name = relationship_name.replace('Activity_Sessions.', '').replace('Activity_SessionParts.', '')
                
                data.append([
                    simplified_name,
                    f"{self._safe_format_number(activity_row.get('integrity_percentage'), 0):.1f}%",
                    f"{self._safe_format_number(activity_row.get('orphaned_source_records'), 0):,}"
                ])
            
            col_widths = [4.0*inch, 1.0*inch, 1.0*inch]
            medium_priority_table = self.create_expandable_table(data, col_widths)
            if medium_priority_table:
                story.append(medium_priority_table)
            story.append(Spacer(1, 12))
        
        if info_priority:
            story.append(Paragraph(f"<b>Informational Findings ({len(info_priority)} relationships)</b>", styles['Normal']))
            
            data = [['Relationship', 'Key Field', 'Integrity %', 'Orphaned', 'Notes']]
            
            for activity_row in info_priority:
                relationship_name = activity_row.get('relationship_name', 'Unknown')
                simplified_name = relationship_name.replace('Activity_Sessions.', '').replace('Activity_SessionParts.', '')
                # Remove "(report-only)" suffix for cleaner display
                simplified_name = simplified_name.replace(' (report-only)', '')
                
                integrity_pct = activity_row.get('integrity_percentage')
                integrity_str = f"{self._safe_format_number(integrity_pct, 0):.1f}%" if integrity_pct is not None else "N/A"
                
                data.append([
                    simplified_name,
                    activity_row.get('key_field', ''),
                    integrity_str,
                    f"{self._safe_format_number(activity_row.get('orphaned_source_records'), 0):,}",
                    "Reference data quality tracking"
                ])
            
            col_widths = [2.3*inch, 1.0*inch, 0.8*inch, 0.8*inch, 2.1*inch]
            info_priority_table = self.create_expandable_table(data, col_widths)
            if info_priority_table:
                story.append(info_priority_table)
            story.append(Spacer(1, 12))
        
    def _add_employees_orphan_section(self, story, styles, employees_data: List[Dict]):
        """Add dedicated Employees orphan detection section with optimal formatting"""
        if not employees_data:
            return
            
        story.append(Paragraph("Employees Domain Integrity Analysis", styles['Heading3']))
        story.append(Paragraph(
            "Business rule-based orphan detection for Employee domain relationships. "
            "This analysis identifies transcript records, instructor assignments, and curriculum ownership that lack valid employee references.",
            styles['Normal']
        ))
        story.append(Spacer(1, 12))
        
        # Group by priority for better readability
        high_priority = [row for row in employees_data if row.get('business_priority') in ['Critical', 'High']]
        medium_priority = [row for row in employees_data if row.get('business_priority') == 'Medium']
        info_priority = [row for row in employees_data if row.get('business_priority') in ['Info', 'Low']]
        
        if high_priority:
            story.append(Paragraph(f"<b>High Priority Issues ({len(high_priority)} relationships)</b>", styles['Normal']))
            
            data = [['Relationship', 'Key Field', 'Integrity %', 'Orphaned', 'Business Impact']]
            
            for employee_row in high_priority:
                relationship_name = employee_row.get('relationship_name', 'Unknown')
                # Simplify relationship name for display
                simplified_name = relationship_name.replace('Employees.', '').replace('Prerequisites_Instructor.', 'Prereq_Instr.')
                
                data.append([
                    simplified_name,
                    employee_row.get('key_field', ''),
                    f"{self._safe_format_number(employee_row.get('integrity_percentage'), 0):.1f}%",
                    f"{self._safe_format_number(employee_row.get('orphaned_source_records'), 0):,}",
                    self._get_employees_business_impact(employee_row)
                ])
            
            # Use wider columns specifically for Employees data
            col_widths = [2.8*inch, 1.0*inch, 0.8*inch, 0.8*inch, 2.6*inch]
            high_priority_table = self.create_expandable_table(data, col_widths)
            if high_priority_table:
                story.append(high_priority_table)
            story.append(Spacer(1, 12))
        
        if medium_priority:
            story.append(Paragraph(f"<b>Medium Priority Issues ({len(medium_priority)} relationships)</b>", styles['Normal']))
            
            data = [['Relationship', 'Integrity %', 'Orphaned Records']]
            
            for employee_row in medium_priority:
                relationship_name = employee_row.get('relationship_name', 'Unknown')
                simplified_name = relationship_name.replace('Employees.', '').replace('Prerequisites_Instructor.', 'Prereq_Instr.')
                
                data.append([
                    simplified_name,
                    f"{self._safe_format_number(employee_row.get('integrity_percentage'), 0):.1f}%",
                    f"{self._safe_format_number(employee_row.get('orphaned_source_records'), 0):,}"
                ])
            
            col_widths = [4.0*inch, 1.0*inch, 1.0*inch]
            medium_priority_table = self.create_expandable_table(data, col_widths)
            if medium_priority_table:
                story.append(medium_priority_table)
            story.append(Spacer(1, 12))
        
        if info_priority:
            story.append(Paragraph(f"<b>Informational Findings ({len(info_priority)} relationships)</b>", styles['Normal']))
            
            data = [['Relationship', 'Key Field', 'Integrity %', 'Orphaned', 'Notes']]
            
            for employee_row in info_priority:
                relationship_name = employee_row.get('relationship_name', 'Unknown')
                simplified_name = relationship_name.replace('Employees.', '').replace('Prerequisites_Instructor.', 'Prereq_Instr.')
                # Remove "(report-only)" suffix for cleaner display
                simplified_name = simplified_name.replace(' (report-only)', '')
                
                integrity_pct = employee_row.get('integrity_percentage')
                integrity_str = f"{self._safe_format_number(integrity_pct, 0):.1f}%" if integrity_pct is not None else "N/A"
                
                data.append([
                    simplified_name,
                    employee_row.get('key_field', ''),
                    integrity_str,
                    f"{self._safe_format_number(employee_row.get('orphaned_source_records'), 0):,}",
                    "Reference data quality tracking"
                ])
            
            col_widths = [2.3*inch, 1.0*inch, 0.8*inch, 0.8*inch, 2.1*inch]
            info_priority_table = self.create_expandable_table(data, col_widths)
            if info_priority_table:
                story.append(info_priority_table)
            story.append(Spacer(1, 12))
        
    def _get_activities_business_impact(self, activity_row: Dict) -> str:
        """
        Generate business impact description for Activities orphan detection
        
        Args:
            activity_row: Activities orphan detection result
            
        Returns:
            str: Business impact description
        """
        relationship_name = activity_row.get('relationship_name', '')
        orphaned = activity_row.get('orphaned_source_records', 0)
        total = activity_row.get('total_source_records', 0)
        priority = activity_row.get('business_priority', 'Medium')
        
        if 'ILTCourseCode' in relationship_name and 'Child ActivityCode' in relationship_name:
            return f"Critical: {orphaned}/{total} ILT courses lack valid activity links - impacts course catalog integrity"
        elif 'ClassCode' in relationship_name and priority == 'High':
            return f"High: {orphaned}/{total} class sessions orphaned - impacts scheduling and enrollment"  
        elif 'ActivityCode' in relationship_name:
            return f"Medium: {orphaned}/{total} activity references invalid - impacts reporting completeness"
        else:
            return f"{priority}: {orphaned}/{total} records with integrity issues - impacts data quality"
    
    def _safe_format_number(self, value, default=0):
        """Safely format a number, handling None values"""
        if value is None:
            return default
        try:
            return float(value)
        except (ValueError, TypeError):
            return default
    
    def _get_employees_business_impact(self, employee_row: Dict) -> str:
        """
        Generate business impact description for Employees orphan detection
        
        Args:
            employee_row: Employees orphan detection result
            
        Returns:
            str: Business impact description
        """
        relationship_name = employee_row.get('relationship_name', '')
        orphaned = employee_row.get('orphaned_source_records', 0)
        total = employee_row.get('total_source_records', 0)
        priority = employee_row.get('business_priority', 'Medium')
        
        if 'Transcript' in relationship_name:
            return f"High: {orphaned}/{total} training records lack valid employee references - impacts completion tracking and compliance"
        elif 'Prerequisites_Instructor' in relationship_name:
            return f"High: {orphaned}/{total} instructor assignments invalid - impacts training delivery authorization"
        elif 'Activity_Curriculum' in relationship_name and 'Owner' in relationship_name:
            return f"Medium: {orphaned}/{total} curriculum ownership unclear - impacts content governance"
        else:
            return f"{priority}: {orphaned}/{total} records with employee integrity issues - impacts data quality"
    
    def _add_orgs_orphan_section(self, story, styles, orgs_data: List[Dict]):
        """Add dedicated Organizations orphan detection section with optimal formatting"""
        if not orgs_data:
            return
            
        story.append(Paragraph("Organizations Domain Integrity Analysis", styles['Heading3']))
        story.append(Paragraph(
            "Business rule-based orphan detection for Organization domain relationships. "
            "This analysis identifies employee organizational assignments that lack valid organization references.",
            styles['Normal']
        ))
        story.append(Spacer(1, 12))
        
        # Group by priority for better readability
        high_priority = [row for row in orgs_data if row.get('business_priority') in ['Critical', 'High']]
        medium_priority = [row for row in orgs_data if row.get('business_priority') == 'Medium']
        info_priority = [row for row in orgs_data if row.get('business_priority') in ['Info', 'Low']]
        
        if high_priority:
            story.append(Paragraph(f"<b>High Priority Issues ({len(high_priority)} relationships)</b>", styles['Normal']))
            
            data = [['Relationship', 'Key Field', 'Integrity %', 'Orphaned', 'Business Impact']]
            
            for org_row in high_priority:
                relationship_name = org_row.get('relationship_name', 'Unknown')
                # Simplify relationship name for display
                simplified_name = relationship_name.replace('Orgs.', '').replace('Employees.', '')
                
                data.append([
                    simplified_name,
                    org_row.get('key_field', ''),
                    f"{self._safe_format_number(org_row.get('integrity_percentage'), 0):.1f}%",
                    f"{self._safe_format_number(org_row.get('orphaned_source_records'), 0):,}",
                    self._get_orgs_business_impact(org_row)
                ])
            
            # Use wider columns specifically for Organizations data
            col_widths = [2.8*inch, 1.0*inch, 0.8*inch, 0.8*inch, 2.6*inch]
            high_priority_table = self.create_expandable_table(data, col_widths)
            if high_priority_table:
                story.append(high_priority_table)
            story.append(Spacer(1, 12))
        
        if medium_priority:
            story.append(Paragraph(f"<b>Medium Priority Issues ({len(medium_priority)} relationships)</b>", styles['Normal']))
            
            data = [['Relationship', 'Integrity %', 'Orphaned Records']]
            
            for org_row in medium_priority:
                relationship_name = org_row.get('relationship_name', 'Unknown')
                simplified_name = relationship_name.replace('Orgs.', '').replace('Employees.', '')
                
                data.append([
                    simplified_name,
                    f"{self._safe_format_number(org_row.get('integrity_percentage'), 0):.1f}%",
                    f"{self._safe_format_number(org_row.get('orphaned_source_records'), 0):,}"
                ])
            
            col_widths = [4.0*inch, 1.0*inch, 1.0*inch]
            medium_priority_table = self.create_expandable_table(data, col_widths)
            if medium_priority_table:
                story.append(medium_priority_table)
            story.append(Spacer(1, 12))
        
        if info_priority:
            story.append(Paragraph(f"<b>Informational Findings ({len(info_priority)} relationships)</b>", styles['Normal']))
            
            data = [['Relationship', 'Key Field', 'Integrity %', 'Orphaned', 'Notes']]
            
            for org_row in info_priority:
                relationship_name = org_row.get('relationship_name', 'Unknown')
                simplified_name = relationship_name.replace('Orgs.', '').replace('Employees.', '')
                # Remove "(report-only)" suffix for cleaner display
                simplified_name = simplified_name.replace(' (report-only)', '')
                
                integrity_pct = org_row.get('integrity_percentage')
                integrity_str = f"{self._safe_format_number(integrity_pct, 0):.1f}%" if integrity_pct is not None else "N/A"
                
                data.append([
                    simplified_name,
                    org_row.get('key_field', ''),
                    integrity_str,
                    f"{self._safe_format_number(org_row.get('orphaned_source_records'), 0):,}",
                    "Organizational reference tracking"
                ])
            
            col_widths = [2.3*inch, 1.0*inch, 0.8*inch, 0.8*inch, 2.1*inch]
            info_priority_table = self.create_expandable_table(data, col_widths)
            if info_priority_table:
                story.append(info_priority_table)
            story.append(Spacer(1, 12))
    
    def _get_orgs_business_impact(self, org_row: Dict) -> str:
        """
        Generate business impact description for Organizations orphan detection
        
        Args:
            org_row: Organizations orphan detection result
            
        Returns:
            str: Business impact description
        """
        relationship_name = org_row.get('relationship_name', '')
        orphaned = org_row.get('orphaned_source_records', 0)
        total = org_row.get('total_source_records', 0)
        priority = org_row.get('business_priority', 'Medium')
        
        if 'Primary Domain Name' in relationship_name:
            return f"High: {orphaned}/{total} employees assigned to invalid domains - impacts organizational hierarchy"
        elif 'Primary Organization Name' in relationship_name:
            return f"High: {orphaned}/{total} employees assigned to invalid organizations - impacts reporting structure"
        else:
            return f"{priority}: {orphaned}/{total} records with organizational integrity issues - impacts data quality"
    
    def _add_cross_file_integrity_analysis(self, story, styles, file_names: List[str]):
        """Add comprehensive cross-file integrity analysis using Phase 2 enhanced system"""
        story.append(Paragraph("Cross-File Referential Integrity Analysis", styles['Heading2']))
        story.append(Paragraph(
            "This section analyzes referential integrity between files using dynamic relationship "
            "discovery from Neo4j field mappings. Critical integrity issues can impact data migration success.",
            styles['Normal']
        ))
        story.append(Spacer(1, 12))
        
        try:
            # Get orphan detection results from dedicated trackers ONLY
            from orphan_tracker_businessrule import ActivitiesOrphanExecutor, EmployeeOrphanExecutor, OrganizationOrphanExecutor
            activities_data_raw = ActivitiesOrphanExecutor.get_activities_orphan_summaries_for_pdf()
            employees_data_raw = EmployeeOrphanExecutor.get_employees_orphan_summaries_for_pdf()
            orgs_data_raw = OrganizationOrphanExecutor.get_orgs_orphan_summaries_for_pdf()
            
            # Apply deduplication at PDF level to ensure clean data
            activities_data = self._deduplicate_orphan_data(activities_data_raw, "Activities")
            employees_data = self._deduplicate_orphan_data(employees_data_raw, "Employees") 
            orgs_data = self._deduplicate_orphan_data(orgs_data_raw, "Organizations")
            
            # COMPLETELY DISABLE old RetrievalFramework to prevent Core_* relationships
            # Only use dedicated orphan trackers - no legacy framework
            cross_file_data = {'summary': {}, 'integrity_analysis': [], 'cross_file_patterns': {}}
            
            # Add dedicated Activities section with optimal formatting
            self._add_activities_orphan_section(story, styles, activities_data)
            
            # Add dedicated Employees section with optimal formatting
            self._add_employees_orphan_section(story, styles, employees_data)
            
            # Add dedicated Organizations section with optimal formatting
            self._add_orgs_orphan_section(story, styles, orgs_data)
            
            # Merge Activities data into cross_file_data for general analysis
            cross_file_data = self._merge_activities_orphan_data(cross_file_data, activities_data)
            
            # Merge Employees data into cross_file_data for general analysis
            cross_file_data = self._merge_employees_orphan_data(cross_file_data, employees_data)
            
            # Merge Organizations data into cross_file_data for general analysis
            cross_file_data = self._merge_orgs_orphan_data(cross_file_data, orgs_data)
            
            # Add summary metrics
            summary = cross_file_data.get('summary', {})
            if summary:
                story.append(Paragraph("Integrity Summary", styles['Heading3']))
                summary_data = [
                    ['Metric', 'Value'],
                    ['Total Relationships Analyzed', f"{self._safe_format_number(summary.get('total_relationships'), 0):,}"],
                    ['Critical Integrity Issues', f"{self._safe_format_number(summary.get('critical_issues'), 0):,}"],
                    ['Total Orphaned Records', f"{self._safe_format_number(summary.get('total_orphaned_records'), 0):,}"]
                ]
                
                summary_table = self.create_expandable_table(summary_data, [2.5*inch, 1.5*inch])
                if summary_table:
                    story.append(summary_table)
                story.append(Spacer(1, 12))
            
            # Add detailed integrity analysis
            integrity_analysis = cross_file_data.get('integrity_analysis', [])
            if integrity_analysis:
                story.append(Paragraph("Detailed Integrity Analysis", styles['Heading3']))
                
                # Group by severity for better readability
                critical_issues = [r for r in integrity_analysis if r.get('severity') == 'High']
                
                if critical_issues:
                    story.append(Paragraph(
                        f"<b>Critical Issues ({len(critical_issues)} relationships)</b>", 
                        styles['Normal']
                    ))
                    
                    data = [['Source → Target', 'Key Field', 'Integrity %', 'Orphaned Records', 'Business Impact']]
                    
                    for rel in critical_issues[:10]:  # Top 10 critical issues
                        source_target = f"{rel.get('source_pattern', 'Unknown')} → {rel.get('dependent_pattern', 'Unknown')}"
                        integrity_pct = f"{self._safe_format_number(rel.get('integrity_percentage'), 0):.1f}%"
                        orphaned = f"{self._safe_format_number(rel.get('orphaned_records'), 0):,}"
                        # NO TRUNCATION - let table expansion handle wrapping
                        impact = rel.get('business_impact', 'Unknown impact')
                        
                        data.append([
                            source_target,
                            rel.get('key_field', 'Unknown'),
                            integrity_pct,
                            orphaned,
                            impact
                        ])
                    
                    # Wider columns to accommodate full text without wrapping pressure
                    col_widths = [2.5*inch, 1.2*inch, 0.8*inch, 1.0*inch, 2.5*inch]
                    critical_table = self.create_expandable_table(data, col_widths)
                    if critical_table:
                        story.append(critical_table)
                    story.append(Spacer(1, 12))
                
                # Cross-file patterns summary removed - was showing zeros due to data structure mismatch
                    
            else:
                story.append(Paragraph("No cross-file integrity issues detected.", styles['Normal']))
            
            # No framework connections to close (using dedicated trackers only)
            
        except Exception as e:
            logger.error(f"Error generating cross-file integrity analysis: {e}")
            story.append(Paragraph(
                f"Error generating cross-file analysis: {str(e)}. Check system configuration.",
                styles['Normal']
            ))
        
        story.append(Spacer(1, 20))

    def _add_cross_file_patterns(self, story, styles, error_data: Dict):
        """Add cross-file error patterns table (legacy error-based patterns)"""
        story.append(Paragraph("Cross-File Error Patterns (Legacy Analysis)", styles['Heading2']))
        
        # Reorganize error data by error type across files
        cross_file_patterns = defaultdict(lambda: {'files': [], 'total_count': 0})
        
        for file_name, file_errors in error_data.items():
            for error_type, count in file_errors.get('error_types', {}).items():
                if count > 0:
                    cross_file_patterns[error_type]['files'].append(file_name)
                    cross_file_patterns[error_type]['total_count'] += count
        
        # Filter to only patterns affecting multiple files
        multi_file_patterns = {
            error_type: data for error_type, data in cross_file_patterns.items()
            if len(data['files']) > 1
        }
        
        if not multi_file_patterns:
            story.append(Paragraph("No cross-file error patterns detected.", styles['Normal']))
            story.append(Spacer(1, 20))
            return
        
        data = [['Error Pattern', 'Affected Files', 'Total Impact', 'Recommended Action']]
        
        for error_type, pattern_data in sorted(multi_file_patterns.items(), 
                        key=lambda x: x[1]['total_count'], reverse=True):
            affected_files = ', '.join(pattern_data['files'][:3])  # Show first 3 files
            if len(pattern_data['files']) > 3:
                affected_files += f", +{len(pattern_data['files']) - 3} more"
            
            total_impact = f"{pattern_data['total_count']:,} records"
            action = self.REMEDIATION_MAPPING.get(error_type, "Review and address")
            
            data.append([
                error_type,
                affected_files,
                total_impact,
                action
            ])
        
        col_widths = [1.3*inch, 2.0*inch, 1.0*inch, 2.7*inch]
        table = self.create_expandable_table(data, col_widths)
        
        if table:
            story.append(table)
            story.append(Spacer(1, 20))
    
    def _deduplicate_orphan_data(self, data: List[Dict], domain_name: str) -> List[Dict]:
        """
        Remove duplicate relationships from orphan detection data at PDF level.
        
        This ensures the PDF always shows clean, deduplicated data regardless of 
        database-level duplicate issues.
        
        Args:
            data: Raw orphan detection data with potential duplicates
            domain_name: Domain name for logging (Activities, Employees, Organizations)
            
        Returns:
            Deduplicated list with unique relationships only
        """
        if not data:
            return data
            
        # Use relationship_name as the deduplication key
        seen_relationships = {}
        deduplicated_data = []
        
        for item in data:
            relationship_name = item.get('relationship_name', '')
            
            if relationship_name not in seen_relationships:
                # First occurrence - keep it
                seen_relationships[relationship_name] = item
                deduplicated_data.append(item)
                logger.debug(f"✅ {domain_name}: Keeping relationship '{relationship_name}'")
            else:
                # Duplicate found - skip it
                logger.warning(f"🔄 {domain_name}: Skipping duplicate relationship '{relationship_name}'")
        
        original_count = len(data)
        final_count = len(deduplicated_data)
        if original_count != final_count:
            logger.info(f"📊 {domain_name}: Deduplicated {original_count} → {final_count} relationships (removed {original_count - final_count} duplicates)")
        else:
            logger.debug(f"📊 {domain_name}: No duplicates found in {final_count} relationships")
            
        return deduplicated_data
    
    def _get_severity(self, error_type: str) -> str:
        """Get severity for error type"""
        for severity, types in self.SEVERITY_CATEGORIES.items():
            if error_type in types:
                return severity
        return 'Medium'
    
    def _cleanup(self):
        """Clean up database connection"""
        try:
            if hasattr(self, 'db_connection') and self.db_connection:
                self.db_connection.close()
        except Exception as e:
            logger.error(f"Error cleaning up: {e}")


# Utility functions
def get_original_file_list_from_db() -> List[str]:
    """Get original uploaded filenames from database - fallback to session data if completeness table is empty"""
    try:
        connection = mysql.connector.connect(
            host=os.getenv('MYSQL_HOST', 'localhost'),
            user=os.getenv('MYSQL_USER'),
            password=os.getenv('MYSQL_PASSWORD'),
            database=os.getenv('MYSQL_NAME'),
            port=int(os.getenv('MYSQL_PORT', 3306)),
            ssl_disabled=True,
            connect_timeout=30,
            use_unicode=True
        )
        
        cursor = connection.cursor()
        
        # Primary: Try file_completeness_summary table
        cursor.execute("""
            SELECT file_name 
            FROM file_completeness_summary 
            GROUP BY file_name 
            ORDER BY MAX(last_processed) DESC
        """)
        results = cursor.fetchall()
        
        if results:
            filenames = [row[0] for row in results if row[0]]
            logger.info(f"Found {len(filenames)} files from completeness table: {filenames}")
        else:
            # Fallback: Use session tracking data when completeness table is empty (metrics disabled)
            logger.info("Completeness table empty, falling back to session data...")
            cursor.execute("""
                SELECT DISTINCT original_file_name 
                FROM file_ingest_log_session 
                ORDER BY uploaded_at DESC
            """)
            results = cursor.fetchall()
            filenames = [row[0] for row in results if row[0]]
            logger.info(f"Found {len(filenames)} files from session data: {filenames}")
        
        cursor.close()
        connection.close()
        
        filenames = [row[0] for row in results if row[0]]
        logger.info(f"Found {len(filenames)} files: {filenames}")
        return filenames
        
    except Exception as e:
        logger.error(f"Error getting file list: {e}")
        return []


def _run_orphan_detection_for_uploaded_files(file_names: List[str]):
    """
    Run orphan detection for domains based on uploaded files
    
    Args:
        file_names: List of uploaded file names
    """
    try:
        # Import orphan tracker
        import sys
        import os
        current_dir = os.path.dirname(os.path.abspath(__file__))
        sys.path.append(current_dir)
        from orphan_tracker_businessrule import run_sql, _db_conn, _tune_session, EmployeeOrphanExecutor
        
        # Determine which domains to run based on file names
        domains_to_run = set()
        
        for file_name in file_names:
            file_lower = file_name.lower()
            if any(keyword in file_lower for keyword in ['activity', 'curriculum', 'ilt']):
                domains_to_run.add('activities')
            elif any(keyword in file_lower for keyword in ['employee', 'transcript', 'instructor']):
                domains_to_run.add('employees')
            elif any(keyword in file_lower for keyword in ['organization', 'domain', 'audience']):
                domains_to_run.add('orgs')
        
        # Use session manager for authoritative session-based domain detection
        from session_manager import session_manager
        
        # Load most recent active session if not already loaded
        if not session_manager.current_session:
            try:
                conn_temp = session_manager._get_db_connection()
                cursor = conn_temp.cursor(dictionary=True)
                cursor.execute("""
                    SELECT session_id FROM upload_sessions 
                    WHERE is_active = TRUE 
                    ORDER BY created_at DESC LIMIT 1
                """)
                row = cursor.fetchone()
                cursor.close()
                conn_temp.close()
                
                if row:
                    session_config = session_manager.load_session(row['session_id'])
                    if session_config:
                        logger.info(f"📋 PDF generator loaded session: {row['session_id']} with {len(session_config.uploaded_files)} files")
                    else:
                        logger.warning(f"📋 Failed to load session config for {row['session_id']}")
                else:
                    logger.warning("📋 No active sessions found - using filename-based detection fallback")
            except Exception as e:
                logger.error(f"📋 Error loading session for PDF: {e} - using filename-based detection fallback")
        
        # Determine domains from session if available, otherwise fall back to filename detection
        if session_manager.current_session and session_manager.current_session.uploaded_files:
            domains_to_run = set()
            for domain in ['activities', 'employees', 'orgs']:
                if session_manager.should_run_orphan_detection(domain):
                    domains_to_run.add(domain)
                    uploaded_tables = session_manager.get_uploaded_tables_for_domain(domain)
                    logger.info(f"📋 Session-based: Will run {domain} domain (tables: {uploaded_tables})")
        
        if not domains_to_run:
            logger.info("📋 No domains detected from session or files, skipping orphan detection")
            return
        
        logger.info(f"📋 Running orphan detection for domains: {', '.join(domains_to_run)}")
        
        # Run orphan detection for each detected domain
        conn = _db_conn()
        try:
            _tune_session(conn)
            
            if 'activities' in domains_to_run:
                logger.info("Running Activities orphan detection...")
                run_sql('activities_orphans.sql', conn)
                conn.commit()
                logger.info("✅ Activities orphan detection completed")
            
            if 'employees' in domains_to_run:
                logger.info("📋 Running Employees orphan detection for PDF...")
                EmployeeOrphanExecutor(conn).execute()
                conn.commit()
                logger.info("✅ Employees orphan detection completed")
            
            if 'orgs' in domains_to_run:
                logger.info("Running Organizations orphan detection...")
                run_sql('orgs_orphans.sql', conn)
                conn.commit()
                logger.info("✅ Organizations orphan detection completed")
                
        finally:
            conn.close()
            
    except Exception as e:
        logger.error(f"Error running orphan detection: {e}")
        # Don't fail PDF generation if orphan detection fails


def auto_generate_after_upload(file_names: List[str], output_dir: str) -> Optional[str]:
    """Auto-generate PDF report with fresh orphan detection"""
    try:
        original_files = get_original_file_list_from_db()
        if len(original_files) >= 1:
            # Run fresh orphan detection for all domains before generating PDF
            logger.info("Running fresh orphan detection before PDF generation...")
            _run_orphan_detection_for_uploaded_files(original_files)
            
            # Generate PDF with fresh data
            generator = PDFQualityReportGenerator(output_dir)
            return generator.generate_report(original_files)
    except Exception as e:
        logger.error(f"Error auto-generating PDF: {e}")
    return None


def reset_all_data(processed_folder: str) -> Dict[str, Any]:
    """Reset all data"""
    results = {'database_cleared': False, 'files_deleted': 0, 'pdf_reports_deleted': 0, 'errors': []}
    
    try:
        # Clear database
        connection = mysql.connector.connect(
            host=os.getenv('MYSQL_HOST', 'localhost'),
            user=os.getenv('MYSQL_USER'),
            password=os.getenv('MYSQL_PASSWORD'),
            database=os.getenv('MYSQL_NAME'),
            port=int(os.getenv('MYSQL_PORT', 3306)),
            ssl_disabled=True,
            autocommit=False,
            connect_timeout=30,
            use_unicode=True
        )
        
        cursor = connection.cursor()
        cursor.execute("TRUNCATE error_logs")
        cursor.execute("TRUNCATE file_completeness_summary")
        
        # Clear orphan detection results
        cursor.execute("DELETE FROM cross_file_integrity_summary WHERE discovered_from_neo4j = 1")
        orphan_records_deleted = cursor.rowcount
        
        # Clear session data from authoritative table
        cursor.execute("DELETE FROM file_ingest_log_session")
        session_files_deleted = cursor.rowcount
        cursor.execute("DELETE FROM upload_sessions")
        sessions_deleted = cursor.rowcount
        
        connection.commit()
        cursor.close()
        connection.close()
        results['database_cleared'] = True
        results['orphan_records_deleted'] = orphan_records_deleted
        results['session_files_deleted'] = session_files_deleted
        results['sessions_deleted'] = sessions_deleted
        
    except Exception as e:
        results['errors'].append(f"Database error: {e}")
    
    try:
        # Delete files
        if os.path.exists(processed_folder):
            files_deleted = pdf_reports_deleted = 0
            for filename in os.listdir(processed_folder):
                file_path = os.path.join(processed_folder, filename)
                if os.path.isfile(file_path):
                    if filename.endswith('.csv') and (filename.startswith('processed_') or filename.startswith('anomaly_report_')):
                        os.remove(file_path)
                        files_deleted += 1
                    elif filename.endswith('.pdf') and filename.startswith('data_quality_report'):
                        os.remove(file_path)
                        pdf_reports_deleted += 1
            
            results['files_deleted'] = files_deleted
            results['pdf_reports_deleted'] = pdf_reports_deleted
            
    except Exception as e:
        results['errors'].append(f"File deletion error: {e}")
    
    return results
