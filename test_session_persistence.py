#!/usr/bin/env python3
"""Test session persistence across different process instances"""
import sys
import os
sys.path.append('lms_error_analyzer/database')

# Test 1: Create a new session manager instance and check if it loads existing sessions
print("🧪 Test 1: Session Manager Auto-loading")
from session_manager import SessionManager
sm1 = SessionManager()

if sm1.current_session:
    print(f"✅ Auto-loaded session: {sm1.current_session.session_id}")
    print(f"   📁 Files in session: {len(sm1.current_session.uploaded_files)}")
    for file in sm1.current_session.uploaded_files:
        print(f"      - {file.original_file_name} -> {file.canonical_table}")
else:
    print("❌ No session auto-loaded")

print()

# Test 2: Create another instance and verify it loads the same session
print("🧪 Test 2: Second Instance Auto-loading")
sm2 = SessionManager()

if sm2.current_session:
    print(f"✅ Second instance loaded session: {sm2.current_session.session_id}")
    print(f"   📁 Files in session: {len(sm2.current_session.uploaded_files)}")
    matches = sm1.current_session and sm1.current_session.session_id == sm2.current_session.session_id
    print(f"   🔗 Same session as first instance: {matches}")
else:
    print("❌ Second instance didn't auto-load session")

print()

# Test 3: Check domain detection
print("🧪 Test 3: Domain Detection")
if sm2.current_session:
    for domain in ['activities', 'employees', 'orgs']:
        should_run = sm2.should_run_orphan_detection(domain)
        uploaded_tables = sm2.get_uploaded_tables_for_domain(domain)
        print(f"   {domain}: should_run={should_run}, tables={uploaded_tables}")
else:
    print("❌ No session available for domain testing")

