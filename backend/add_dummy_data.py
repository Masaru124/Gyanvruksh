#!/usr/bin/env python3
"""
Script to add dummy data to Gyanvruksh database for testing.
"""

import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from app.database import SessionLocal
from app.models.user import User
from app.models.category import Category
from app.models.course import Course
from app.models.lesson import Lesson
from app.models.quiz import Quiz
from app.models.progress import UserProgress
from app.models.gamification import Badge, Streak, DailyChallenge
from app.models.download import Download
from app.models.chat_message import ChatMessage
from datetime import datetime
from passlib.context import CryptContext

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def hash_password(password: str) -> str:
    return pwd_context.hash(password)

def add_dummy_users(db):
    """Add dummy users"""
    users_data = [
        {
            "email": "admin@gyanvruksh.com",
            "password": "admin123",
            "full_name": "System Admin",
            "role": "admin",
            "sub_role": "admin",
            "age": 35,
            "gender": "male",
            "gyan_coins": 1000,
            "is_active": True
        },
        {
            "email": "teacher1@gyanvruksh.com",
            "password": "teacher123",
            "full_name": "Dr. Sarah Johnson",
            "role": "service_provider",
            "sub_role": "teacher",
            "age": 42,
            "gender": "female",
            "educational_qualification": "PhD Mathematics",
            "year_of_experience": 15,
            "gyan_coins": 500,
            "is_teacher": True,
            "is_active": True
        },
        {
            "email": "teacher2@gyanvruksh.com",
            "password": "teacher123",
            "full_name": "Prof. Michael Chen",
            "role": "service_provider",
            "sub_role": "teacher",
            "age": 38,
            "gender": "male",
            "educational_qualification": "MSc Physics",
            "year_of_experience": 12,
            "gyan_coins": 450,
            "is_teacher": True,
            "is_active": True
        },
        {
            "email": "student1@gyanvruksh.com",
            "password": "student123",
            "full_name": "Alice Thompson",
            "role": "service_seeker",
            "sub_role": "student",
            "age": 16,
            "gender": "female",
            "gyan_coins": 250,
            "is_active": True
        },
        {
            "email": "student2@gyanvruksh.com",
            "password": "student123",
            "full_name": "Bob Wilson",
            "role": "service_seeker",
            "sub_role": "student",
            "age": 17,
            "gender": "male",
            "gyan_coins": 180,
            "is_active": True
        },
        {
            "email": "student3@gyanvruksh.com",
            "password": "student123",
            "full_name": "Carol Davis",
            "role": "service_seeker",
            "sub_role": "student",
            "age": 15,
            "gender": "female",
            "gyan_coins": 320,
            "is_active": True
        }
    ]

    for user_data in users_data:
        # Check if user already exists
        existing = db.query(User).filter(User.email == user_data["email"]).first()
        if existing:
            print(f"User {user_data['email']} already exists, skipping...")
            continue

        user_data["hashed_password"] = hash_password(user_data["password"])
        del user_data["password"]

        user = User(**user_data)
        db.add(user)
        print(f"Added user: {user_data['email']}")

    db.commit()

def add_dummy_categories(db):
    """Add dummy categories"""
    categories_data = [
        {"name": "Academics", "description": "Academic subjects like Math, Science, Languages", "icon": "📚"},
        {"name": "Skills", "description": "Practical skills like Coding, Design, Music", "icon": "💻"},
        {"name": "Sports", "description": "Physical activities and sports training", "icon": "⚽"},
        {"name": "Creativity", "description": "Arts, crafts, and creative expression", "icon": "🎨"}
    ]

    for cat_data in categories_data:
        # Check if category exists
        existing = db.query(Category).filter(Category.name == cat_data["name"]).first()
        if existing:
            print(f"Category {cat_data['name']} already exists, skipping...")
            continue

        category = Category(**cat_data)
        db.add(category)
        print(f"Added category: {cat_data['name']}")

    db.commit()

def add_dummy_courses(db):
    """Add dummy courses"""
    # Get teachers and categories
    teachers = db.query(User).filter(User.is_teacher == True).all()
    categories = db.query(Category).all()

    if not teachers or not categories:
        print("No teachers or categories found, skipping courses...")
        return

    courses_data = [
        {
            "title": "Advanced Mathematics",
            "description": "Master calculus, algebra, and geometry with interactive lessons",
            "teacher_id": teachers[0].id,
            "category_id": categories[0].id,  # Academics
            "total_hours": 40,
            "difficulty": "intermediate",
            "thumbnail_url": "https://example.com/math.jpg",
            "is_published": True
        },
        {
            "title": "Python Programming for Beginners",
            "description": "Learn Python from scratch with hands-on projects",
            "teacher_id": teachers[0].id,
            "category_id": categories[1].id,  # Skills
            "total_hours": 30,
            "difficulty": "beginner",
            "thumbnail_url": "https://example.com/python.jpg",
            "is_published": True
        },
        {
            "title": "Basketball Fundamentals",
            "description": "Master the basics of basketball with professional coaching",
            "teacher_id": teachers[1].id,
            "category_id": categories[2].id,  # Sports
            "total_hours": 25,
            "difficulty": "beginner",
            "thumbnail_url": "https://example.com/basketball.jpg",
            "is_published": True
        },
        {
            "title": "Digital Art with Photoshop",
            "description": "Create stunning digital artwork using Adobe Photoshop",
            "teacher_id": teachers[1].id,
            "category_id": categories[3].id,  # Creativity
            "total_hours": 35,
            "difficulty": "intermediate",
            "thumbnail_url": "https://example.com/photoshop.jpg",
            "is_published": True
        },
        {
            "title": "Physics: Mechanics",
            "description": "Understand the laws of motion and energy",
            "teacher_id": teachers[1].id,
            "category_id": categories[0].id,  # Academics
            "total_hours": 28,
            "difficulty": "intermediate",
            "thumbnail_url": "https://example.com/physics.jpg",
            "is_published": True
        }
    ]

    for course_data in courses_data:
        # Check if course exists
        existing = db.query(Course).filter(Course.title == course_data["title"]).first()
        if existing:
            print(f"Course {course_data['title']} already exists, skipping...")
            continue

        course = Course(**course_data)
        db.add(course)
        print(f"Added course: {course_data['title']}")

    db.commit()

def add_dummy_lessons(db):
    """Add dummy lessons"""
    courses = db.query(Course).all()

    if not courses:
        print("No courses found, skipping lessons...")
        return

    lessons_data = [
        {
            "course_id": courses[0].id,
            "title": "Introduction to Calculus",
            "description": "Learn the basics of differential and integral calculus",
            "content_type": "video",
            "content_url": "https://example.com/calculus-intro.mp4",
            "duration_minutes": 45,
            "order_index": 1,
            "is_free": True
        },
        {
            "course_id": courses[0].id,
            "title": "Limits and Continuity",
            "description": "Understanding limits and continuous functions",
            "content_type": "video",
            "content_url": "https://example.com/limits.mp4",
            "duration_minutes": 50,
            "order_index": 2,
            "is_free": False
        },
        {
            "course_id": courses[1].id,
            "title": "Python Basics",
            "description": "Variables, data types, and basic operations",
            "content_type": "video",
            "content_url": "https://example.com/python-basics.mp4",
            "duration_minutes": 40,
            "order_index": 1,
            "is_free": True
        },
        {
            "course_id": courses[2].id,
            "title": "Basketball Shooting Techniques",
            "description": "Master proper shooting form and techniques",
            "content_type": "video",
            "content_url": "https://example.com/shooting.mp4",
            "duration_minutes": 35,
            "order_index": 1,
            "is_free": True
        }
    ]

    for lesson_data in lessons_data:
        lesson = Lesson(**lesson_data)
        db.add(lesson)
        print(f"Added lesson: {lesson_data['title']}")

    db.commit()

def add_dummy_badges(db):
    """Add dummy badges"""
    badges_data = [
        {"name": "First Lesson", "description": "Completed your first lesson", "icon": "🎓", "points_required": 0},
        {"name": "Math Master", "description": "Completed 10 math lessons", "icon": "🧮", "points_required": 100},
        {"name": "Code Ninja", "description": "Completed 5 coding lessons", "icon": "👨‍💻", "points_required": 50},
        {"name": "Sports Star", "description": "Completed 8 sports lessons", "icon": "⭐", "points_required": 80}
    ]

    for badge_data in badges_data:
        existing = db.query(Badge).filter(Badge.name == badge_data["name"]).first()
        if existing:
            continue

        badge = Badge(**badge_data)
        db.add(badge)
        print(f"Added badge: {badge_data['name']}")

    db.commit()

def add_dummy_chat_messages(db):
    """Add dummy chat messages"""
    users = db.query(User).all()

    if len(users) < 3:
        print("Not enough users for chat messages, skipping...")
        return

    messages_data = [
        {
            "sender_id": users[0].id,
            "receiver_id": users[3].id,
            "message": "Welcome to Gyanvruksh! How can I help you today?",
            "message_type": "text"
        },
        {
            "sender_id": users[3].id,
            "receiver_id": users[0].id,
            "message": "Hi! I'm interested in learning mathematics.",
            "message_type": "text"
        },
        {
            "sender_id": users[1].id,
            "receiver_id": users[4].id,
            "message": "Great progress on your Python course!",
            "message_type": "text"
        }
    ]

    for msg_data in messages_data:
        message = ChatMessage(**msg_data)
        db.add(message)
        print(f"Added chat message from user {msg_data['sender_id']}")

    db.commit()

def main():
    print("🌱 Adding dummy data to Gyanvruksh database...")

    db = SessionLocal()
    try:
        add_dummy_users(db)
        add_dummy_categories(db)
        add_dummy_courses(db)
        add_dummy_lessons(db)
        add_dummy_badges(db)
        add_dummy_chat_messages(db)

        print("✅ Dummy data added successfully!")

    except Exception as e:
        print(f"❌ Error adding dummy data: {e}")
        db.rollback()
    finally:
        db.close()

if __name__ == "__main__":
    main()
