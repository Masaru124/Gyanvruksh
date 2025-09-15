import requests

BASE_URL = "http://localhost:8000"

def test_login():
    # Test admin login
    response = requests.post(f"{BASE_URL}/api/auth/login", json={"email": "masarukaze041@gmail.com", "password": "masarukaze041@gmail.com"})
    print(f"Admin login: {response.status_code}")
    if response.status_code == 200:
        print("✅ Admin login successful")
        return response.json()['access_token']
    else:
        print(f"❌ Admin login failed: {response.text}")
        return None

def test_teacher_login():
    # Test teacher login
    response = requests.post(f"{BASE_URL}/api/auth/login", json={"email": "mail-teacher@example.com", "password": "pass-teacher123"})
    print(f"Teacher login: {response.status_code}")
    if response.status_code == 200:
        print("✅ Teacher login successful")
        return response.json()['access_token']
    else:
        print(f"❌ Teacher login failed: {response.text}")
        return None

def test_student_login():
    # Test student login
    response = requests.post(f"{BASE_URL}/api/auth/login", json={"email": "student@example.com", "password": "pass-student123"})
    print(f"Student login: {response.status_code}")
    if response.status_code == 200:
        print("✅ Student login successful")
        return response.json()['access_token']
    else:
        print(f"❌ Student login failed: {response.text}")
        return None

if __name__ == "__main__":
    print("Testing login functionality...")
    test_login()
    test_teacher_login()
    test_student_login()
