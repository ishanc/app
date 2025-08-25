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
    records_without_errors: float
    overall_quality_score: float
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
    
    def calculate_quality_scores(self, completeness_data: Dict, error_data: Dict) -> List[FileQualityScore]:
        """Calculate quality scores for files"""
        scores = []
        
        for file_name in completeness_data.keys():
            comp = completeness_data[file_name]
            errors = error_data[file_name]
            
            mandatory_complete = comp.get('mandatory_completeness', 0.0)
            total_records = comp.get('total_records', 0)
            incomplete_records = comp.get('incomplete_records', 0)
            total_errors = errors.get('total_errors', 0)
            
                        # Calculate completion percentage
            completion_percentage = 0.0
            if total_records > 0:
                complete_records = total_records - incomplete_records
                completion_percentage = (complete_records / total_records) * 100
            
            # Overall quality score (80% mandatory completeness, 20% penalty for critical errors)
            overall_quality = mandatory_complete * 0.8
            
            # Apply penalty for critical errors
            critical_errors = sum(
                errors['error_types'].get(error_type, 0) 
                for error_type in self.SEVERITY_CATEGORIES.get('Critical', [])
            )
            
            if total_records > 0 and critical_errors > 0:
                critical_penalty = min(critical_errors / total_records, 1.0) * 20
                overall_quality = max(0, overall_quality - critical_penalty)
            
            # Add usability bonus
            if mandatory_complete > 0:
                usability_bonus = 20 if total_records > 0 else 0
                if total_records > 0:
                    error_density = total_errors / total_records
                    if error_density > 3.0:
                        usability_bonus = 10
                    elif error_density > 1.0:
                        usability_bonus = 15
                overall_quality += usability_bonus
                
            scores.append(FileQualityScore(
                    file_name=file_name,
                    mandatory_fields_complete=mandatory_complete,
                    records_without_errors=round(completion_percentage, 1),
                    overall_quality_score=round(overall_quality, 1),
                    total_records=total_records,
                    error_count=total_errors
                ))
            
        return sorted(scores, key=lambda x: x.overall_quality_score, reverse=True)
    
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
        """Add quality scores table"""
        if not quality_scores:
            return
            
        story.append(Paragraph("File Quality Scores", styles['Heading2']))
        
        data = [['File Name', 'Mandatory Complete', 'Completion %', 'Quality Score', 'Total Records', 'Errors']]
        
        for score in quality_scores:
            data.append([
                score.file_name,
                f"{score.mandatory_fields_complete:.1f}%",
                f"{score.records_without_errors:.1f}%",
                f"{score.overall_quality_score:.1f}%",
                f"{score.total_records:,}",
                f"{score.error_count:,}"
            ])
        
        col_widths = [2.2*inch, 1*inch, 1*inch, 1*inch, 0.9*inch, 0.9*inch]
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
                    f"{activity_row.get('integrity_percentage', 0):.1f}%",
                    f"{activity_row.get('orphaned_source_records', 0):,}",
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
                    f"{activity_row.get('integrity_percentage', 0):.1f}%",
                    f"{activity_row.get('orphaned_source_records', 0):,}"
                ])
            
            col_widths = [4.0*inch, 1.0*inch, 1.0*inch]
            medium_priority_table = self.create_expandable_table(data, col_widths)
            if medium_priority_table:
                story.append(medium_priority_table)
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
            # Get Activities orphan detection results from new system
            from orphan_tracker_businessrule import ActivitiesOrphanExecutor
            activities_data = ActivitiesOrphanExecutor.get_activities_orphan_summaries_for_pdf()
            
            # Use enhanced retrieval framework for non-Activities relationships
            from retrieval_framework import RetrievalFramework
            framework = RetrievalFramework()
            
            # Filter out Activities from old system to avoid conflicts
            non_activities_files = [f for f in file_names if not f.lower().startswith('activity')]
            if non_activities_files:
                cross_file_data = framework.get_cross_file_analysis(non_activities_files)
            else:
                cross_file_data = {'summary': {}, 'integrity_analysis': [], 'cross_file_patterns': {}}
            
            # Add dedicated Activities section with optimal formatting
            self._add_activities_orphan_section(story, styles, activities_data)
            
            # Merge Activities data into cross_file_data for general analysis
            cross_file_data = self._merge_activities_orphan_data(cross_file_data, activities_data)
            
            # Add summary metrics
            summary = cross_file_data.get('summary', {})
            if summary:
                story.append(Paragraph("Integrity Summary", styles['Heading3']))
                summary_data = [
                    ['Metric', 'Value'],
                    ['Total Relationships Analyzed', f"{summary.get('total_relationships', 0):,}"],
                    ['Critical Integrity Issues', f"{summary.get('critical_issues', 0):,}"],
                    ['Total Orphaned Records', f"{summary.get('total_orphaned_records', 0):,}"]
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
                        integrity_pct = f"{rel.get('integrity_percentage', 0):.1f}%"
                        orphaned = f"{rel.get('orphaned_records', 0):,}"
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
                
                # Add cross-file patterns summary
                cross_file_patterns = cross_file_data.get('cross_file_patterns', {})
                if cross_file_patterns:
                    story.append(Paragraph("Cross-File Relationship Patterns", styles['Heading3']))
                    
                    pattern_data = [['Pattern Type', 'Affected Files', 'Total Issues', 'Severity']]
                    
                    for pattern_name, pattern_info in cross_file_patterns.items():
                        # Show all files, no truncation
                        files_list = ', '.join(pattern_info.get('files', []))
                        
                        pattern_data.append([
                            pattern_name.replace('_integrity', '').replace('_', ' ').title(),
                            files_list,
                            f"{pattern_info.get('total_count', 0):,}",
                            pattern_info.get('severity', 'Unknown')
                        ])
                    
                    # Wider columns for full text display
                    pattern_table = self.create_expandable_table(pattern_data, [2.0*inch, 3.0*inch, 1.0*inch, 1.0*inch])
                    if pattern_table:
                        story.append(pattern_table)
                    
            else:
                story.append(Paragraph("No cross-file integrity issues detected.", styles['Normal']))
            
            # Close framework connections
            framework.close()
            
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
    """Get original uploaded filenames from database"""
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
        cursor.execute("""
            SELECT file_name 
            FROM file_completeness_summary 
            GROUP BY file_name 
            ORDER BY MAX(last_processed) DESC
        """)
        results = cursor.fetchall()
        cursor.close()
        connection.close()
        
        filenames = [row[0] for row in results if row[0]]
        logger.info(f"Found {len(filenames)} files: {filenames}")
        return filenames
        
    except Exception as e:
        logger.error(f"Error getting file list: {e}")
        return []


def auto_generate_after_upload(file_names: List[str], output_dir: str) -> Optional[str]:
    """Auto-generate PDF report"""
    try:
        original_files = get_original_file_list_from_db()
        if len(original_files) >= 1:
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
        connection.commit()
        cursor.close()
        connection.close()
        results['database_cleared'] = True
        
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
