#!/usr/bin/env python3
"""
MetricsService - Aggregates business metrics for LMS transformation dashboard
"""

import sys
import os
from typing import Dict, Any, Optional

# Add paths for imports
sys.path.append(os.path.join(os.path.dirname(__file__), '..', '..', 'lms_error_analyzer', 'database'))

class MetricsService:
    """Provides aggregated metrics for the LMS transformation dashboard"""
    
    def __init__(self):
        self._cached_metrics = None
        
    def get_dashboard_metrics(self) -> Dict[str, Any]:
        """Get current dashboard metrics including total records processed"""
        try:
            # Import session manager
            from session_manager import session_manager
            
            total_records = 0
            files_processed = 0
            
            # Get data from session manager if available and not reset
            if (session_manager.current_session and 
                session_manager.current_session.uploaded_files and 
                not getattr(session_manager.current_session, 'reset', False)):
                print(f"DEBUG: Found {len(session_manager.current_session.uploaded_files)} files in active session")
                for uploaded_file in session_manager.current_session.uploaded_files:
                    total_records += uploaded_file.row_count
                    files_processed += 1
                    print(f"DEBUG: File {uploaded_file.original_file_name}: {uploaded_file.row_count} records")
            else:
                if session_manager.current_session and getattr(session_manager.current_session, 'reset', False):
                    print("DEBUG: Current session has been reset - ignoring old files")
                else:
                    print("DEBUG: No active session data, falling back to database")
                # Fallback to database if no session or session is reset
                total_records, files_processed = self._get_metrics_from_database()
            
            print(f"DEBUG: Total records: {total_records}, Files: {files_processed}")
            
            return {
                'total_records_processed': total_records,
                'files_processed': files_processed,
                'status': 'active' if files_processed > 0 else 'empty'
            }
            
        except Exception as e:
            # Graceful degradation
            return {
                'total_records_processed': 0,
                'files_processed': 0,
                'status': 'error',
                'error': str(e)
            }
    
    def _get_metrics_from_database(self) -> tuple[int, int]:
        """Fallback method to get metrics from database"""
        try:
            from dashboard import Dashboard
            dashboard = Dashboard()
            
            # Get data from file_completeness_summary table
            cursor = dashboard.connection.cursor(dictionary=True)
            cursor.execute("""
                SELECT 
                    COUNT(*) as files_processed,
                    COALESCE(SUM(total_records), 0) as total_records
                FROM file_completeness_summary
            """)
            result = cursor.fetchone()
            cursor.close()
            dashboard.close_connections()
            
            return result['total_records'], result['files_processed']
            
        except Exception:
            return 0, 0
    
    def reset_metrics(self) -> bool:
        """Reset all metrics (called on delete all files)"""
        try:
            # Clear cache
            self._cached_metrics = None
            return True
        except Exception:
            return False
    
    def update_after_upload(self, filename: str, row_count: int) -> bool:
        """Update metrics after successful file upload"""
        try:
            # Clear cache to force refresh
            self._cached_metrics = None
            return True
        except Exception:
            return False

# Global instance
metrics_service = MetricsService()
