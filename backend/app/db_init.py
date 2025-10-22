import sys
sys.path.append('..')
from app.database import Base, engine, SessionLocal
from app.models.user import User
from app.models.course import Course
from app.models.enrollment import Enrollment
from app.models.chat_message import ChatMessage
from app.models.course_video import CourseVideo
from app.models.course_note import CourseNote
from app.services.security import hash_password

def init():
    # Drop existing tables to recreate with updated schema
    # Drop tables with foreign keys first to avoid constraints
    from app.models.chat_message import ChatMessage
    from app.models.course_video import CourseVideo
    from app.models.course_note import CourseNote
    ChatMessage.__table__.drop(bind=engine, checkfirst=True)
    CourseVideo.__table__.drop(bind=engine, checkfirst=True)
    CourseNote.__table__.drop(bind=engine, checkfirst=True)
    Base.metadata.drop_all(bind=engine)
    Base.metadata.create_all(bind=engine)
    print("✅ Tables recreated")

    # Create default admin user
    db = SessionLocal()
    try:
        admin_email = "masarukaze041@gmail.com"
        admin_password = "masarukaze041@gmail.com"
        existing_admin = db.query(User).filter(User.email == admin_email).first()
        if existing_admin:
            print("⚠️ Default admin user already exists")
        else:
            admin_user = User(
                email=admin_email,
                full_name="Default Admin",
                hashed_password=hash_password(admin_password),
                age=30,
                gender="Other",
                role="admin",
                sub_role=None,
                educational_qualification=None,
                preferred_language=None,
                is_teacher=False
            )
            db.add(admin_user)
            db.commit()
            print("✅ Default admin user created")

        # Create default teacher user for testing
        teacher_email = "teacher@example.com"
        teacher_password = "pass-teacher123"
        existing_teacher = db.query(User).filter(User.email == teacher_email).first()
        if existing_teacher:
            print("⚠️ Default teacher user already exists")
        else:
            teacher_user = User(
                email=teacher_email,
                full_name="Default Teacher",
                hashed_password=hash_password(teacher_password),
                age=35,
                gender="Other",
                role="service_provider",
                sub_role="teacher",
                educational_qualification="Master's in Education",
                preferred_language="English",
                is_teacher=True
            )
            db.add(teacher_user)
            db.commit()
            print("✅ Default teacher user created")

        # Create default student user for testing
        student_email = "student@example.com"
        student_password = "pass-student123"
        existing_student = db.query(User).filter(User.email == student_email).first()
        if existing_student:
            print("⚠️ Default student user already exists")
        else:
            student_user = User(
                email=student_email,
                full_name="Default Student",
                hashed_password=hash_password(student_password),
                age=20,
                gender="Other",
                role="service_seeker",
                sub_role="student",
                educational_qualification="Bachelor's in Computer Science",
                preferred_language="English",
                is_teacher=False
            )
            db.add(student_user)
            db.commit()
            print("✅ Default student user created")

    except Exception as e:
        print(f"❌ Error creating default users: {e}")
    finally:
        db.close()

if __name__ == "__main__":
    init()
