from dashboard import Dashboard
import pandas as pd
from datetime import datetime

def view_dashboard():
    """View comprehensive dashboard metrics for recently processed files"""
    dashboard = Dashboard()
    
    try:
        # Get dashboard data
        results = dashboard.generate_quality_dashboard()
        
        print("=" * 80)
        print("📊 DATA QUALITY DASHBOARD")
        print("=" * 80)
        print(f"Generated at: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        print()
        
        if not results:
            print("❌ No files found in dashboard")
            return
        
        for i, file_data in enumerate(results, 1):
            print(f"📁 FILE {i}: {file_data['file_name']}")
            print("-" * 60)
            
            # Basic metrics
            print(f"📈 Total Rows: {file_data['record_count']:,}")  # Changed from "Total Records"
            print(f"❌ Total Errors: {file_data['total_errors']:,}")
            print(f"⚠️  Lines with Errors: {file_data['lines_with_errors']:,}")
            print(f"🔍 Nulls Found: {file_data['nulls_found']:,}")
            print(f"🔗 Unlinked FK: {file_data['unlinked_fk']:,}")
            print()
            
            # Quality percentages
            print(f"✅ % Valid: {file_data['percent_valid']}%")
            print(f"📊 % Complete: {file_data['percent_complete']}%")
            print(f"🎯 Mandatory Complete: {file_data['mandatory_complete']}%")
            print()
            
            # Calculate additional insights
            if file_data['record_count'] > 0:
                records_with_errors = file_data['lines_with_errors']
                records_without_errors = file_data['record_count'] - records_with_errors
                print(f"📋 Rows WITHOUT Errors: {records_without_errors:,} / {file_data['record_count']:,}")  # Changed from "Records"
                print(f"📋 Rows WITH Errors: {records_with_errors:,} / {file_data['record_count']:,}")  # Changed from "Records"
            print()
            
            # Get detailed completeness data from database
            cursor = dashboard.connection.cursor(dictionary=True)
            cursor.execute("""
                SELECT * FROM file_completeness_summary 
                WHERE file_name = %s
                ORDER BY last_processed DESC
                LIMIT 1
            """, (file_data['file_name'],))
            
            completeness_data = cursor.fetchone()
            cursor.close()
            
            if completeness_data:
                print("🔍 DETAILED COMPLETENESS ANALYSIS:")
                # Use the actual field names from the table schema
                print(f"   • Overall Completeness: {completeness_data.get('overall_completeness', 'N/A')}%")
                print(f"   • Mandatory Completeness: {completeness_data.get('mandatory_completeness', 'N/A')}%")
                print(f"   • Total Fields: {completeness_data.get('total_fields', 'N/A'):,}")
                print(f"   • Mandatory Fields: {completeness_data.get('mandatory_fields', 'N/A')}")
                print(f"   • Incomplete Mandatory Fields: {completeness_data.get('incomplete_mandatory_fields', 'N/A'):,}")
                print(f"   • Last Processed: {completeness_data.get('last_processed', 'N/A')}")
                print()
                
                # Show discrepancy if it exists
                mandatory_empty_errors = file_data.get('nulls_found', 0)
                incomplete_mandatory = completeness_data.get('incomplete_mandatory_fields', 0)
                if mandatory_empty_errors > 0 and incomplete_mandatory == 0:
                    print("⚠️  COMPLETENESS DISCREPANCY DETECTED:")
                    print(f"   • Error logs show {mandatory_empty_errors:,} mandatory empty errors")
                    print(f"   • But completeness shows {incomplete_mandatory} incomplete mandatory fields")
                    print("   • This suggests a field name mapping issue in completeness calculation")
                    print()
            
            print("=" * 80)
            print()
    
    except Exception as e:
        print(f"❌ Error generating dashboard: {e}")
        import traceback
        traceback.print_exc()
    
    finally:
        dashboard.close_connections()

def analyze_completeness_discrepancy():
    """Analyze why completeness might be showing incorrect values for all files with discrepancies"""
    print("\n" + "=" * 80)
    print("🔍 COMPLETENESS DISCREPANCY ANALYSIS")
    print("=" * 80)
    
    dashboard = Dashboard()
    
    try:
        # Get all files that have both error logs and completeness data
        cursor = dashboard.connection.cursor(dictionary=True)
        cursor.execute("""
            SELECT DISTINCT e.file_name
            FROM error_logs e
            LEFT JOIN file_completeness_summary c ON e.file_name = c.file_name
            WHERE e.validation_type = 'MANDATORY_EMPTY'
            ORDER BY e.file_name
        """)
        
        files_with_mandatory_errors = cursor.fetchall()
        cursor.close()
        
        for file_record in files_with_mandatory_errors:
            file_name = file_record['file_name']
            print(f"\n📁 ANALYZING: {file_name}")
            print("-" * 50)
            
            # Check completeness data
            cursor = dashboard.connection.cursor(dictionary=True)
            cursor.execute("""
                SELECT * FROM file_completeness_summary 
                WHERE file_name = %s
                ORDER BY last_processed DESC
                LIMIT 1
            """, (file_name,))
            
            completeness_record = cursor.fetchone()
            cursor.close()
            
            # Check error counts
            cursor = dashboard.connection.cursor(dictionary=True)
            cursor.execute("""
                SELECT validation_type, COUNT(*) as count
                FROM error_logs 
                WHERE file_name = %s
                GROUP BY validation_type
                ORDER BY count DESC
            """, (file_name,))
            
            error_summary = cursor.fetchall()
            cursor.close()
            
            # Display results
            if completeness_record:
                print(f"✅ Completeness Record Found:")
                print(f"   • Overall: {completeness_record.get('overall_completeness', 'N/A')}%")
                print(f"   • Mandatory: {completeness_record.get('mandatory_completeness', 'N/A')}%")
                print(f"   • Incomplete Mandatory Fields: {completeness_record.get('incomplete_mandatory_fields', 'N/A')}")
            else:
                print("❌ No completeness record found")
            
            print(f"\n📊 Error Summary:")
            mandatory_empty_count = 0
            for error in error_summary:
                print(f"   • {error['validation_type']}: {error['count']:,} errors")
                if error['validation_type'] == 'MANDATORY_EMPTY':
                    mandatory_empty_count = error['count']
            
            # Check for discrepancy
            if completeness_record and mandatory_empty_count > 0:
                incomplete_mandatory = completeness_record.get('incomplete_mandatory_fields', 0)
                if incomplete_mandatory == 0:
                    print(f"\n⚠️  DISCREPANCY DETECTED:")
                    print(f"   • Error logs: {mandatory_empty_count:,} mandatory empty errors")
                    print(f"   • Completeness: {incomplete_mandatory} incomplete mandatory fields")
                    print(f"   • Likely cause: Field name mapping mismatch")
        
    except Exception as e:
        print(f"❌ Error analyzing discrepancy: {e}")
        import traceback
        traceback.print_exc()
    
    finally:
        dashboard.close_connections()

if __name__ == "__main__":
    view_dashboard()
    analyze_completeness_discrepancy() 