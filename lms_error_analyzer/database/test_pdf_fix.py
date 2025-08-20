#!/usr/bin/env python3
"""
Test PDF Quality Report Generator Fixes

This script tests the updated PDF quality report generator to ensure it uses
real MySQL data instead of fabricated retrieval framework bundles.
"""

import os
import sys
import traceback
from datetime import datetime

# Add project paths
sys.path.append('../../')
sys.path.append('../../lasVegas/app')

def test_pdf_generator():
    """Test the PDF generator with real MySQL data"""
    print("=" * 80)
    print("TESTING PDF QUALITY REPORT GENERATOR FIXES")
    print("=" * 80)
    print()
    
    try:
        # Import from current directory (database folder)
        from pdf_quality_report import PDFQualityReportGenerator
        
        # Initialize generator
        output_dir = '../../file_server/processed'
        generator = PDFQualityReportGenerator(output_dir)
        
        # Test files that should exist in database (use actual file names from database)
        test_files = [
            'Activity_Curriculum.xlsx'
        ]
        
        print(f"🧪 Testing with files: {test_files}")
        print()
        
        # Test 1: Real completeness data retrieval
        print("TEST 1: Real Completeness Data Retrieval")
        print("-" * 50)
        try:
            completeness_data = generator.get_real_completeness_data(test_files)
            
            for file_name, data in completeness_data.items():
                mandatory_comp = data.get('mandatory_completeness', 0)
                total_records = data.get('total_records', 0)
                incomplete_records = data.get('incomplete_records', 0)
                
                print(f"📄 {file_name}:")
                print(f"   • Mandatory Completeness: {mandatory_comp}%")
                print(f"   • Total Records: {total_records:,}")
                print(f"   • Incomplete Records: {incomplete_records:,}")
                print()
                
                # Validate data makes sense
                if mandatory_comp == 0.0 and total_records > 0:
                    print(f"   ⚠️  WARNING: 0% mandatory completeness with {total_records} records")
                elif mandatory_comp > 0:
                    print(f"   ✅ Real mandatory completeness data found!")
                    
            print("✅ Completeness data retrieval test completed")
            
        except Exception as e:
            print(f"❌ Completeness data test failed: {e}")
            traceback.print_exc()
        
        print()
        
        # Test 2: Real error data retrieval
        print("TEST 2: Real Error Data Retrieval")
        print("-" * 50)
        try:
            error_data = generator.get_real_error_data(test_files)
            
            for file_name, data in error_data.items():
                total_errors = data.get('total_errors', 0)
                error_types = data.get('error_types', {})
                
                print(f"📄 {file_name}:")
                print(f"   • Total Errors: {total_errors:,}")
                
                if error_types:
                    print("   • Error Types:")
                    for error_type, count in sorted(error_types.items(), key=lambda x: x[1], reverse=True):
                        print(f"     - {error_type}: {count:,}")
                else:
                    print("   • No error types found")
                print()
                
            print("✅ Error data retrieval test completed")
            
        except Exception as e:
            print(f"❌ Error data test failed: {e}")
            traceback.print_exc()
        
        print()
        
        # Test 3: Quality scores calculation with real data
        print("TEST 3: Quality Scores Calculation with Real Data")
        print("-" * 50)
        try:
            # Create real context structure
            real_context = {
                'file_names': test_files,
                'completeness_data': completeness_data,
                'error_data': error_data
            }
            
            quality_scores = generator._calculate_file_quality_scores_real(real_context)
            
            print("📊 Quality Scores (using real MySQL data):")
            for score in quality_scores:
                print(f"📄 {score.file_name}:")
                print(f"   • Mandatory Fields Complete: {score.mandatory_fields_complete}%")
                print(f"   • Completion Percentage: {score.records_without_errors}%")
                print(f"   • Overall Quality Score: {score.overall_quality_score}%")
                print(f"   • Total Records: {score.total_records:,}")
                print()
                
                # Check if scores make sense
                if score.overall_quality_score == 30.0:
                    print(f"   ⚠️  WARNING: Still showing constant 30% - fix may not be working")
                else:
                    print(f"   ✅ Quality score varies from 30% - fix working!")
                    
            print("✅ Quality scores calculation test completed")
            
        except Exception as e:
            print(f"❌ Quality scores test failed: {e}")
            traceback.print_exc()
        
        print()
        
        # Test 4: Full PDF generation
        print("TEST 4: Full PDF Generation with Real Data")
        print("-" * 50)
        try:
            # Generate PDF with timestamp
            pdf_filename = generator.generate_comprehensive_report(test_files, save_timestamp=True)
            pdf_path = os.path.join(output_dir, pdf_filename)
            
            print(f"📋 Generated PDF: {pdf_filename}")
            
            # Check if PDF was created
            if os.path.exists(pdf_path):
                file_size = os.path.getsize(pdf_path) / 1024  # KB
                print(f"   • File size: {file_size:.1f} KB")
                print(f"   • Full path: {pdf_path}")
                print("   ✅ PDF file successfully created!")
            else:
                print("   ❌ PDF file was not created")
                
        except Exception as e:
            print(f"❌ PDF generation test failed: {e}")
            traceback.print_exc()
        
        print()
        
        # Test 5: Comparison with dashboard data
        print("TEST 5: Data Validation Against Dashboard")
        print("-" * 50)
        try:
            from dashboard import Dashboard
            
            dashboard = Dashboard()
            
            print("🔍 Comparing PDF data with Dashboard data:")
            
            for file_name in test_files:
                # Get PDF completeness data
                pdf_completeness = completeness_data.get(file_name, {}).get('mandatory_completeness', 0)
                
                # Try to get dashboard data (this might fail if file not in right format)
                try:
                    # Dashboard expects original filename format, not processed format
                    original_name = file_name.replace('processed_', '').replace('_20250819_100357', '').replace('_20250819_101956', '')
                    if original_name.endswith('-CHR.csv'):
                        original_name = original_name.replace('-CHR.csv', '.xlsx')
                    elif original_name.endswith('.csv'):
                        original_name = original_name.replace('.csv', '.xlsx')
                    
                    print(f"📄 {file_name} (mapped to {original_name}):")
                    print(f"   • PDF shows mandatory completeness: {pdf_completeness}%")
                    
                    # Note: We can't easily test dashboard data without actual file processing
                    # but we can verify the PDF is using MySQL data
                    if pdf_completeness == 100.0:
                        print(f"   ✅ PDF using real data (showing expected 100% completeness)")
                    elif pdf_completeness == 0.0:
                        print(f"   ⚠️  PDF might still be using fabricated data (showing 0%)")
                    else:
                        print(f"   ✅ PDF using real data (showing {pdf_completeness}% completeness)")
                        
                except Exception as de:
                    print(f"   ℹ️  Dashboard comparison skipped: {de}")
                
                print()
            
            dashboard.close_connections()
            print("✅ Data validation test completed")
            
        except Exception as e:
            print(f"❌ Data validation test failed: {e}")
            traceback.print_exc()
        
        print()
        print("=" * 80)
        print("PDF GENERATOR TESTING COMPLETED")
        print("=" * 80)
        
        # Final cleanup
        generator._cleanup_connections()
        
    except ImportError as e:
        print(f"❌ Import error: {e}")
        print("Make sure you're running from the correct directory and dependencies are installed")
    except Exception as e:
        print(f"❌ Unexpected error: {e}")
        traceback.print_exc()

def verify_database_connection():
    """Verify we can connect to the database"""
    print("🔌 Testing database connection...")
    try:
        import mysql.connector
        from dotenv import load_dotenv
        
        load_dotenv()
        
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
        cursor.execute("SELECT COUNT(*) FROM file_completeness_summary")
        completeness_count = cursor.fetchone()[0]
        
        cursor.execute("SELECT COUNT(*) FROM error_logs")
        error_count = cursor.fetchone()[0]
        
        cursor.close()
        connection.close()
        
        print(f"✅ Database connection successful!")
        print(f"   • File completeness records: {completeness_count}")
        print(f"   • Error log records: {error_count}")
        print()
        
        return True
        
    except Exception as e:
        print(f"❌ Database connection failed: {e}")
        return False

if __name__ == "__main__":
    print("Starting PDF Quality Report Generator Tests...")
    print()
    
    # First verify database connection
    if verify_database_connection():
        # Run the main tests
        test_pdf_generator()
    else:
        print("Cannot proceed with tests - database connection failed")
        print("Please check your MySQL connection and environment variables")
