#!/usr/bin/env python3
import requests

def test_login():
    login_data = {
        'email': 'student@example.com',
        'password': 'pass-student123'
    }

    try:
        response = requests.post('http://localhost:8000/api/auth/login', json=login_data, timeout=10)
        print(f"Student login status: {response.status_code}")
        print(f"Response: {response.text}")

        if response.status_code == 200:
            token_data = response.json()
            token = token_data['access_token']
            print(f"✅ Student login successful! Token: {token[:20]}...")

            # Test a student endpoint
            headers = {'Authorization': f'Bearer {token}'}
            student_response = requests.get('http://localhost:8000/api/student/dashboard/stats', headers=headers, timeout=10)
            print(f"Student dashboard status: {student_response.status_code}")
            if student_response.status_code == 200:
                print("✅ Student endpoints working!")
            else:
                print(f"❌ Student endpoints failed: {student_response.text}")
        else:
            print("❌ Student login failed")

    except Exception as e:
        print(f"❌ Error: {e}")

if __name__ == "__main__":
    test_login()
