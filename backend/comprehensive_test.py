#!/usr/bin/env python3
"""
Comprehensive Backend API Test Suite for Gyanvruksh Educational Platform

This script tests all major endpoints with proper authentication.
"""

import requests
import json
import sys
from typing import Dict, List, Optional

BASE_URL = "http://localhost:8000"

class BackendTester:
    def __init__(self):
        self.tokens = {}
        self.test_users = {
            'admin': {
                'email': 'masarukaze041@gmail.com',
                'password': 'masarukaze041@gmail.com'  # Fixed password from add_users.py
            },
            'teacher': {
                'email': 'mail-teacher@example.com',
                'password': 'pass-teacher123'
            },
            'student': {
                'email': 'student@example.com',
                'password': 'pass-student123'  # Correct student password
            }
        }

    def log(self, message: str, status: str = "INFO"):
        """Log messages with status indicators"""
        status_icons = {
            "INFO": "ℹ️",
            "SUCCESS": "✅",
            "ERROR": "❌",
            "WARNING": "⚠️"
        }
        print(f"{status_icons.get(status, 'ℹ️')} {message}")

    def test_health_check(self) -> bool:
        """Test basic health endpoint"""
        self.log("Testing health check endpoint...")
        try:
            response = requests.get(f"{BASE_URL}/healthz")
            if response.status_code == 200:
                self.log("Health check passed", "SUCCESS")
                return True
            else:
                self.log(f"Health check failed: {response.status_code}", "ERROR")
                return False
        except Exception as e:
            self.log(f"Health check error: {e}", "ERROR")
            return False

    def login_user(self, user_type: str) -> Optional[str]:
        """Login a user and return their token"""
        self.log(f"Logging in {user_type}...")

        if user_type not in self.test_users:
            self.log(f"Unknown user type: {user_type}", "ERROR")
            return None

        user_data = self.test_users[user_type]
        try:
            response = requests.post(
                f"{BASE_URL}/api/auth/login",
                json={
                    'email': user_data['email'],
                    'password': user_data['password']
                }
            )

            if response.status_code == 200:
                token_data = response.json()
                token = token_data['access_token']
                self.tokens[user_type] = token
                self.log(f"{user_type} login successful", "SUCCESS")
                return token
            else:
                self.log(f"{user_type} login failed: {response.status_code} - {response.text}", "ERROR")
                return None
        except Exception as e:
            self.log(f"{user_type} login error: {e}", "ERROR")
            return None

    def test_authenticated_endpoint(self, method: str, url: str, user_type: str,
                                  data: dict = None, expected_status: int = 200) -> bool:
        """Test an authenticated endpoint"""
        if user_type not in self.tokens:
            self.log(f"No token available for {user_type}", "ERROR")
            return False

        token = self.tokens[user_type]
        headers = {'Authorization': f'Bearer {token}'}

        try:
            if method.upper() == 'GET':
                response = requests.get(f"{BASE_URL}{url}", headers=headers)
            elif method.upper() == 'POST':
                response = requests.post(f"{BASE_URL}{url}", json=data, headers=headers)
            elif method.upper() == 'PUT':
                response = requests.put(f"{BASE_URL}{url}", json=data, headers=headers)
            elif method.upper() == 'DELETE':
                response = requests.delete(f"{BASE_URL}{url}", headers=headers)
            else:
                self.log(f"Unsupported HTTP method: {method}", "ERROR")
                return False

            if response.status_code == expected_status:
                self.log(f"{method} {url} - Status: {response.status_code}", "SUCCESS")
                return True
            else:
                self.log(f"{method} {url} - Status: {response.status_code} - {response.text}", "ERROR")
                return False

        except Exception as e:
            self.log(f"{method} {url} - Error: {e}", "ERROR")
            return False

    def run_comprehensive_tests(self):
        """Run all tests"""
        self.log("🚀 Starting Comprehensive Backend API Tests", "INFO")
        self.log("=" * 60)

        # Test 1: Health Check
        if not self.test_health_check():
            self.log("❌ Health check failed. Stopping tests.", "ERROR")
            return

        # Test 2: Login all user types
        self.log("\n🔐 Testing Authentication...")
        for user_type in ['admin', 'teacher', 'student']:
            self.login_user(user_type)

        # Test 3: Test protected endpoints for each user type
        self.log("\n📚 Testing Student Endpoints...")
        if 'student' in self.tokens:
            student_tests = [
                ('GET', '/api/student/dashboard/stats'),
                ('GET', '/api/courses/'),
                ('GET', '/api/courses/mine'),
                ('GET', '/api/student/upcoming-deadlines?days_ahead=7'),
                ('GET', '/api/gyanvruksh/leaderboard'),
            ]

            for method, endpoint in student_tests:
                self.test_authenticated_endpoint(method, endpoint, 'student')

        self.log("\n👨‍🏫 Testing Teacher Endpoints...")
        if 'teacher' in self.tokens:
            teacher_tests = [
                ('GET', '/api/courses/available'),
                ('GET', '/api/courses/teacher/stats'),
                ('GET', '/api/courses/teacher/upcoming-classes'),
            ]

            for method, endpoint in teacher_tests:
                self.test_authenticated_endpoint(method, endpoint, 'teacher')

        self.log("\n👑 Testing Admin Endpoints...")
        if 'admin' in self.tokens:
            admin_tests = [
                ('GET', '/api/auth/admin/users'),
                ('GET', '/api/courses/'),
                ('GET', '/api/auth/me'),
            ]

            for method, endpoint in admin_tests:
                self.test_authenticated_endpoint(method, endpoint, 'admin')

        # Test 4: Test course operations
        self.log("\n📖 Testing Course Operations...")
        if 'admin' in self.tokens:
            # Create a test course
            course_data = {
                'title': 'Test Course API',
                'description': 'Testing course creation via API',
                'total_hours': 10,
                'difficulty': 'beginner',
                'is_published': True
            }

            create_response = self.test_authenticated_endpoint(
                'POST', '/api/courses/', 'admin', course_data, 201
            )

            if create_response:
                # Test getting courses
                self.test_authenticated_endpoint('GET', '/api/courses/', 'admin')

        # Test 5: Test enrollment operations
        self.log("\n📝 Testing Enrollment Operations...")
        if 'student' in self.tokens and 'admin' in self.tokens:
            # Get available courses for enrollment
            courses_response = self.test_authenticated_endpoint(
                'GET', '/api/courses/available-for-enrollment', 'student'
            )

            if courses_response:
                # Try to enroll in first available course
                # Note: This might fail if no courses are available or already enrolled
                self.test_authenticated_endpoint(
                    'POST', '/api/student/enroll', 'student',
                    {'course_id': 1}, 200  # This might need to be adjusted
                )

        self.log("\n" + "=" * 60)
        self.log("🏁 Backend API Testing Complete!", "INFO")

        # Summary
        total_tests = len(self.tokens) * 3  # Rough estimate
        successful_tests = sum(1 for token in self.tokens.values() if token)
        self.log(f"✅ Successful authentications: {successful_tests}/{len(self.test_users)}", "SUCCESS")

if __name__ == "__main__":
    tester = BackendTester()
    tester.run_comprehensive_tests()
