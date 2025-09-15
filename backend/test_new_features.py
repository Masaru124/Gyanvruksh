import requests
import json

BASE_URL = "http://localhost:8000"

def test_health():
    """Test health endpoint"""
    response = requests.get(f"{BASE_URL}/healthz")
    if response.status_code == 200:
        print("✅ Health check passed")
        return True
    else:
        print(f"❌ Health check failed: {response.status_code}")
        return False

def test_login(email, password):
    """Test login and return token"""
    response = requests.post(f"{BASE_URL}/api/auth/login", json={"email": email, "password": password})
    if response.status_code == 200:
        data = response.json()
        print(f"✅ Login successful for {email}")
        return data['access_token']
    else:
        print(f"❌ Login failed for {email}: {response.status_code} - {response.text}")
        return None

def test_register():
    """Test user registration"""
    data = {
        "email": "newuser@example.com",
        "password": "newuser123",
        "full_name": "New Test User",
        "role": "service_seeker",
        "sub_role": "student",
        "age": 25,
        "gender": "male"
    }
    response = requests.post(f"{BASE_URL}/api/auth/register", json=data)
    if response.status_code == 201:
        print("✅ User registration successful")
        return True
    else:
        print(f"❌ Registration failed: {response.status_code} - {response.text}")
        return False

def test_auth_me(token):
    """Test get current user"""
    headers = {"Authorization": f"Bearer {token}"}
    response = requests.get(f"{BASE_URL}/api/auth/me", headers=headers)
    if response.status_code == 200:
        user = response.json()
        print(f"✅ Auth me: {user['full_name']} ({user['role']})")
        return user
    else:
        print(f"❌ Auth me failed: {response.status_code} - {response.text}")
        return None

def test_courses(token):
    """Test courses API"""
    headers = {"Authorization": f"Bearer {token}"}

    # List courses
    response = requests.get(f"{BASE_URL}/api/courses/", headers=headers)
    if response.status_code == 200:
        courses = response.json()
        print(f"✅ Courses listed: {len(courses)} courses")
    else:
        print(f"❌ Courses list failed: {response.status_code}")

    # My courses
    response = requests.get(f"{BASE_URL}/api/courses/mine", headers=headers)
    if response.status_code == 200:
        my_courses = response.json()
        print(f"✅ My courses: {len(my_courses)} courses")
    else:
        print(f"❌ My courses failed: {response.status_code}")

def test_categories(token):
    """Test categories API"""
    headers = {"Authorization": f"Bearer {token}"}
    response = requests.get(f"{BASE_URL}/api/categories/", headers=headers)
    if response.status_code == 200:
        categories = response.json()
        print(f"✅ Categories fetched: {len(categories)} categories")
        if categories:
            print(f"Sample category: {categories[0]}")
        return categories
    else:
        print(f"❌ Categories fetch failed: {response.status_code} - {response.text}")
        return []

def test_create_course(token, title="Test Course", description="Test Description"):
    """Test course creation"""
    headers = {"Authorization": f"Bearer {token}", "Content-Type": "application/json"}
    data = {"title": title, "description": description}
    response = requests.post(f"{BASE_URL}/api/courses/", headers=headers, json=data)
    if response.status_code == 201:
        course = response.json()
        print(f"✅ Course created: {course['title']} (ID: {course['id']})")
        return course['id']
    else:
        print(f"❌ Course creation failed: {response.status_code} - {response.text}")
        return None

def test_enrollment(token, course_id):
    """Test course enrollment"""
    headers = {"Authorization": f"Bearer {token}", "Content-Type": "application/json"}
    data = {"course_id": course_id}
    response = requests.post(f"{BASE_URL}/api/courses/enroll", headers=headers, json=data)
    if response.status_code == 201:
        print("✅ Course enrollment successful")
        return True
    else:
        print(f"❌ Enrollment failed: {response.status_code} - {response.text}")
        return False

def test_create_lesson(token, course_id):
    """Test lesson creation"""
    headers = {"Authorization": f"Bearer {token}", "Content-Type": "application/json"}
    data = {
        "course_id": course_id,
        "title": "Test Lesson",
        "description": "Test lesson description",
        "content_type": "video",
        "content_url": "https://example.com/video.mp4",
        "duration_minutes": 30,
        "order_index": 1,
        "is_free": True
    }
    response = requests.post(f"{BASE_URL}/api/lessons/", headers=headers, json=data)
    if response.status_code in [200, 201]:
        lesson = response.json()
        print(f"✅ Lesson created: {lesson['title']} (ID: {lesson['id']})")
        return lesson['id']
    else:
        print(f"❌ Lesson creation failed: {response.status_code} - {response.text}")
        return None

def test_create_quiz(token, course_id):
    """Test quiz creation"""
    headers = {"Authorization": f"Bearer {token}", "Content-Type": "application/json"}
    data = {
        "course_id": course_id,
        "title": "Test Quiz",
        "passing_score": 70,
        "questions": [
            {
                "question_text": "What is 2+2?",
                "question_type": "multiple_choice",
                "options": '["3", "4", "5", "6"]',
                "correct_answer": "4",
                "points": 1,
                "order_index": 1
            },
            {
                "question_text": "What is the capital of France?",
                "question_type": "multiple_choice",
                "options": '["London", "Berlin", "Paris", "Madrid"]',
                "correct_answer": "Paris",
                "points": 1,
                "order_index": 2
            }
        ]
    }
    response = requests.post(f"{BASE_URL}/api/quizzes/", headers=headers, json=data)
    if response.status_code in [200, 201]:
        quiz = response.json()
        print(f"✅ Quiz created: {quiz['title']} (ID: {quiz['id']})")
        return quiz['id']
    else:
        print(f"❌ Quiz creation failed: {response.status_code} - {response.text}")
        return None

def test_progress(token, course_id, lesson_id):
    """Test progress tracking"""
    headers = {"Authorization": f"Bearer {token}", "Content-Type": "application/json"}

    # Update lesson progress
    data = {
        "progress_percentage": 100.0,
        "completed": True,
        "time_spent_minutes": 30
    }
    response = requests.post(f"{BASE_URL}/api/progress/courses/{course_id}/lessons/{lesson_id}",
                           headers=headers, json=data)
    if response.status_code == 200:
        print("✅ Lesson progress updated")
    else:
        print(f"❌ Progress update failed: {response.status_code} - {response.text}")

    # Get course progress
    response = requests.get(f"{BASE_URL}/api/progress/courses/{course_id}", headers=headers)
    if response.status_code == 200:
        progress = response.json()
        print(f"✅ Course progress: {progress}")
    else:
        print(f"❌ Course progress fetch failed: {response.status_code} - {response.text}")

def test_leaderboard(token):
    """Test leaderboard"""
    headers = {"Authorization": f"Bearer {token}"}
    response = requests.get(f"{BASE_URL}/api/gyanvruksh/leaderboard", headers=headers)
    if response.status_code == 200:
        leaderboard = response.json()
        print(f"✅ Leaderboard fetched: {len(leaderboard)} users")
        if leaderboard:
            print(f"Top user: {leaderboard[0]}")
    else:
        print(f"❌ Leaderboard fetch failed: {response.status_code} - {response.text}")

def test_chat(token):
    """Test chat API"""
    headers = {"Authorization": f"Bearer {token}"}
    response = requests.get(f"{BASE_URL}/api/chat/messages", headers=headers)
    if response.status_code == 200:
        messages = response.json()
        print(f"✅ Chat messages fetched: {len(messages)} messages")
    else:
        print(f"❌ Chat messages failed: {response.status_code}")

def test_admin_functions(token):
    """Test admin functions"""
    headers = {"Authorization": f"Bearer {token}"}

    # List users
    response = requests.get(f"{BASE_URL}/api/auth/admin/users", headers=headers)
    if response.status_code == 200:
        users = response.json()
        print(f"✅ Admin users listed: {len(users)} users")
    else:
        print(f"❌ Admin users failed: {response.status_code}")

    # Create admin
    data = {
        "email": "newadmin@example.com",
        "password": "admin123",
        "full_name": "New Admin",
        "age": 30,
        "gender": "male",
        "role": "admin",
        "sub_role": "admin"
    }
    response = requests.post(f"{BASE_URL}/api/auth/admin/create-admin", headers=headers, json=data)
    if response.status_code == 201:
        print("✅ Admin user created")
    else:
        print(f"❌ Admin creation failed: {response.status_code}")

def main():
    print("🧪 Testing Gyanvruksh Backend - All Features")
    print("=" * 50)

    # Health check
    test_health()

    # Test registration
    test_register()

    # Test credentials
    creds = [
        ("admin@gyanvruksh.com", "admin123"),  # Admin
        ("teacher1@gyanvruksh.com", "teacher123"),  # Teacher
        ("student1@gyanvruksh.com", "student123"),  # Student
    ]

    for email, password in creds:
        print(f"\n🔐 Testing with {email}")
        token = test_login(email, password)
        if not token:
            continue

        # Auth tests
        user = test_auth_me(token)

        # Courses tests
        test_courses(token)

        # Categories tests
        test_categories(token)

        # Leaderboard
        test_leaderboard(token)

        # Chat
        test_chat(token)

        # Admin functions
        if "admin" in email:
            test_admin_functions(token)

        # For teacher/admin, test creation
        if "teacher" in email or "admin" in email:
            course_id = test_create_course(token, f"Test Course by {email.split('@')[0]}")
            if course_id:
                lesson_id = test_create_lesson(token, course_id)
                quiz_id = test_create_quiz(token, course_id)
                if lesson_id:
                    test_progress(token, course_id, lesson_id)

        # For student, test enrollment
        if "student" in email and course_id:
            test_enrollment(token, course_id)

    print("\n🎉 Testing completed!")

if __name__ == "__main__":
    main()
