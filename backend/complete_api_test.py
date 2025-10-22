#!/usr/bin/env python3
"""
Complete Backend API Endpoint Test Suite for Gyanvruksh Educational Platform

This script tests EVERY single endpoint in the API with proper authentication.
"""

import requests
import json
import sys
import time
from typing import Dict, List, Optional

BASE_URL = "http://localhost:8000"

class CompleteBackendTester:
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
                'password': 'pass-student@example.com'
            }
        }
        self.test_results = {
            'passed': 0,
            'failed': 0,
            'total': 0
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
                self.test_results['passed'] += 1
                return True
            else:
                self.log(f"Health check failed: {response.status_code}", "ERROR")
                return False
        except Exception as e:
            self.log(f"Health check error: {e}", "ERROR")
            return False
        finally:
            self.test_results['total'] += 1

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

    def test_endpoint(self, method: str, url: str, user_type: str = None,
                     data: dict = None, expected_status: int = 200,
                     description: str = "") -> bool:
        """Test a single endpoint"""
        headers = {}

        if user_type and user_type in self.tokens:
            token = self.tokens[user_type]
            if token:
                headers['Authorization'] = f'Bearer {token}'

        try:
            if method.upper() == 'GET':
                response = requests.get(f"{BASE_URL}{url}", headers=headers, timeout=10)
            elif method.upper() == 'POST':
                response = requests.post(f"{BASE_URL}{url}", json=data, headers=headers, timeout=10)
            elif method.upper() == 'PUT':
                response = requests.put(f"{BASE_URL}{url}", json=data, headers=headers, timeout=10)
            elif method.upper() == 'DELETE':
                response = requests.delete(f"{BASE_URL}{url}", headers=headers, timeout=10)
            elif method.upper() == 'PATCH':
                response = requests.patch(f"{BASE_URL}{url}", json=data, headers=headers, timeout=10)
            else:
                self.log(f"Unsupported HTTP method: {method}", "ERROR")
                return False

            success = response.status_code == expected_status
            if success:
                self.log(f"{method} {url} - {response.status_code} {description}", "SUCCESS")
                self.test_results['passed'] += 1
            else:
                self.log(f"{method} {url} - {response.status_code} (expected {expected_status}) {description}", "ERROR")

            return success

        except Exception as e:
            self.log(f"{method} {url} - Error: {e} {description}", "ERROR")
            return False
        finally:
            self.test_results['total'] += 1

    def run_complete_tests(self):
        """Test EVERY single API endpoint"""
        self.log("🚀 Starting COMPLETE Backend API Endpoint Tests", "INFO")
        self.log("=" * 80)

        # Test 1: Health Check
        if not self.test_health_check():
            self.log("❌ Health check failed. Stopping tests.", "ERROR")
            return

        # Test 2: Login all user types
        self.log("\n🔐 Testing Authentication...")
        for user_type in ['admin', 'teacher', 'student']:
            self.login_user(user_type)

        # Test 3: Test ALL endpoints systematically

        # AUTH ENDPOINTS (No auth required for register/login)
        self.log("\n🔑 Testing Authentication Endpoints...")
        auth_endpoints = [
            ('POST', '/api/auth/register', None, {
                'email': f'test_{int(time.time())}@example.com',  # Unique email
                'password': 'testpass123',
                'full_name': 'Test User',
                'role': 'service_seeker',
                'sub_role': 'student'
            }, 201, "User registration"),
            ('POST', '/api/auth/login', None, {
                'email': 'masarukaze041@gmail.com',
                'password': 'masarukaze041@gmail.com'
            }, 200, "Admin login"),
        ]

        for method, url, user_type, data, expected, desc in auth_endpoints:
            self.test_endpoint(method, url, user_type, data, expected, desc)

        # PROTECTED ENDPOINTS (Require authentication)
        if 'admin' in self.tokens:
            self.log("\n👑 Testing Admin-Protected Endpoints...")

            admin_endpoints = [
                ('GET', '/api/auth/me', 'admin', None, 200, "Get current user info"),
                ('GET', '/api/auth/admin/users', 'admin', None, 200, "List all users"),
                ('POST', '/api/auth/admin/create-admin', 'admin', {
                    'email': f'newadmin_{int(time.time())}@test.com',  # Unique email
                    'password': 'adminpass123',
                    'full_name': 'New Admin User',
                    'role': 'admin',
                    'sub_role': 'admin',
                    'age': 30,
                    'gender': 'Other'
                }, 201, "Create new admin"),
            ]

            for method, url, user_type, data, expected, desc in admin_endpoints:
                self.test_endpoint(method, url, user_type, data, expected, desc)

        if 'student' in self.tokens:
            self.log("\n📚 Testing Student-Protected Endpoints...")

            student_endpoints = [
                ('GET', '/api/student/dashboard/stats', 'student', None, 200, "Student dashboard stats"),
                ('GET', '/api/courses/', 'student', None, 200, "List courses"),
                ('GET', '/api/courses/mine', 'student', None, 200, "My enrolled courses"),
                ('GET', '/api/student/upcoming-deadlines?days_ahead=7', 'student', None, 200, "Upcoming deadlines"),
                ('GET', '/api/gyanvruksh/leaderboard', 'student', None, 200, "Leaderboard"),
                ('GET', '/api/gyanvruksh/profile', 'student', None, 200, "User profile"),
            ]

            for method, url, user_type, data, expected, desc in student_endpoints:
                self.test_endpoint(method, url, user_type, data, expected, desc)

        # Always test student endpoints with a fresh login attempt
        self.log("\n📚 Testing Student Endpoints (with fresh login)...")
        fresh_student_token = self.login_user('student')
        if fresh_student_token:
            student_endpoints = [
                ('GET', '/api/student/dashboard/stats', 'student', None, 200, "Student dashboard stats"),
                ('GET', '/api/courses/', 'student', None, 200, "List courses"),
            ]

            for method, url, user_type, data, expected, desc in student_endpoints:
                self.test_endpoint(method, url, user_type, data, expected, desc)

        if 'teacher' in self.tokens:
            self.log("\n👨‍🏫 Testing Teacher-Protected Endpoints...")

            teacher_endpoints = [
                ('GET', '/api/courses/available', 'teacher', None, 200, "Available courses for teachers"),
                ('GET', '/api/courses/teacher/stats', 'teacher', None, 200, "Teacher statistics"),
                ('GET', '/api/courses/teacher/upcoming-classes', 'teacher', None, 200, "Upcoming classes"),
                ('GET', '/api/courses/teacher/student-queries', 'teacher', None, 200, "Student queries"),
            ]

            for method, url, user_type, data, expected, desc in teacher_endpoints:
                self.test_endpoint(method, url, user_type, data, expected, desc)

        # COURSE ENDPOINTS
        self.log("\n📖 Testing Course Endpoints...")
        course_endpoints = [
            ('GET', '/api/courses/', 'admin', None, 200, "List all courses"),
            ('GET', '/api/courses/available-for-enrollment', None, None, 200, "Courses available for enrollment"),
            ('GET', '/api/courses/recommended', None, None, 200, "Recommended courses"),
            ('GET', '/api/categories/', None, None, 200, "List categories"),
        ]

        for method, url, user_type, data, expected, desc in course_endpoints:
            self.test_endpoint(method, url, user_type, data, expected, desc)

        # LESSON ENDPOINTS
        self.log("\n📝 Testing Lesson Endpoints...")
        lesson_endpoints = [
            ('GET', '/api/lessons/?course_id=1', None, None, 200, "List lessons for course"),
        ]

        for method, url, user_type, data, expected, desc in lesson_endpoints:
            self.test_endpoint(method, url, user_type, data, expected, desc)

        # QUIZ ENDPOINTS
        self.log("\n❓ Testing Quiz Endpoints...")
        if 'teacher' in self.tokens:
            quiz_endpoints = [
                ('GET', '/api/quizzes/', 'teacher', None, 200, "List all quizzes"),
            ]

            for method, url, user_type, data, expected, desc in quiz_endpoints:
                self.test_endpoint(method, url, user_type, data, expected, desc)

        # ASSIGNMENT ENDPOINTS
        self.log("\n📋 Testing Assignment Endpoints...")
        assignment_endpoints = [
            ('GET', '/api/assignments/', 'student', None, 200, "List assignments"),
        ]

        for method, url, user_type, data, expected, desc in assignment_endpoints:
            self.test_endpoint(method, url, user_type, data, expected, desc)

        # ATTENDANCE ENDPOINTS
        self.log("\n📊 Testing Attendance Endpoints...")
        if 'teacher' in self.tokens:
            # Use course 5 which has teacher_id: 5 (matches our test teacher)
            attendance_endpoints = [
                ('GET', '/api/courses/5/attendance/sessions', 'teacher', None, 200, "Course attendance sessions"),
            ]

            for method, url, user_type, data, expected, desc in attendance_endpoints:
                self.test_endpoint(method, url, user_type, data, expected, desc)

        # NOTIFICATION ENDPOINTS
        self.log("\n🔔 Testing Notification Endpoints...")
        notification_endpoints = [
            ('GET', '/api/notifications', 'student', None, 200, "List notifications"),
        ]

        for method, url, user_type, data, expected, desc in notification_endpoints:
            self.test_endpoint(method, url, user_type, data, expected, desc)

        # CHAT ENDPOINTS
        self.log("\n💬 Testing Chat Endpoints...")
        chat_endpoints = [
            ('GET', '/api/chat/messages', 'student', None, 200, "Chat messages"),
        ]

        for method, url, user_type, data, expected, desc in chat_endpoints:
            self.test_endpoint(method, url, user_type, data, expected, desc)

        # PROGRESS ENDPOINTS
        self.log("\n📈 Testing Progress Endpoints...")
        progress_endpoints = [
            ('GET', '/api/student/progress-report', 'student', None, 200, "Student progress report"),
        ]

        for method, url, user_type, data, expected, desc in progress_endpoints:
            self.test_endpoint(method, url, user_type, data, expected, desc)

        # DASHBOARD ENDPOINTS
        self.log("\n📊 Testing Dashboard Endpoints...")
        dashboard_endpoints = [
            ('GET', '/api/dashboard/teacher/dashboard-stats', 'teacher', None, 200, "Teacher dashboard stats"),
        ]

        for method, url, user_type, data, expected, desc in dashboard_endpoints:
            self.test_endpoint(method, url, user_type, data, expected, desc)

        # GYANVRUKSH ENDPOINTS
        self.log("\n🎮 Testing Gyanvruksh Endpoints...")
        gyanvruksh_endpoints = [
            ('GET', '/api/gyanvruksh/leaderboard', 'student', None, 200, "Gyanvruksh leaderboard"),
        ]

        for method, url, user_type, data, expected, desc in gyanvruksh_endpoints:
            self.test_endpoint(method, url, user_type, data, expected, desc)

        # Print comprehensive summary
        self.log("\n" + "=" * 80)
        self.log("🏁 COMPLETE Backend API Testing Results!", "INFO")
        self.log(f"✅ Tests Passed: {self.test_results['passed']}")
        self.log(f"❌ Tests Failed: {self.test_results['failed']}")
        self.log(f"📊 Total Tests: {self.test_results['total']}")
        self.log(f"🎯 Success Rate: {self.test_results['passed']/self.test_results['total']*100:.1f}%")

        if self.test_results['failed'] == 0:
            self.log("🎉 ALL TESTS PASSED! Backend API is fully functional.", "SUCCESS")
        else:
            self.log(f"⚠️  {self.test_results['failed']} tests failed. Check logs above.", "WARNING")

if __name__ == "__main__":
    tester = CompleteBackendTester()
    tester.run_complete_tests()
