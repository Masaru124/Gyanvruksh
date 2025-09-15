import sys
sys.path.append('.')
from app.database import SessionLocal
from app.models.user import User
from app.services.security import hash_password

def add_users():
    db = SessionLocal()
    try:
        # Add admin user
        admin_email = "masarukaze041@gmail.com"
        admin_password = "admin123"
        existing_admin = db.query(User).filter(User.email == admin_email).first()
        if existing_admin:
            print("⚠️ Admin user already exists")
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
            print("✅ Admin user created")

        # Add teacher user
        teacher_email = "mail-teacher@example.com"
        teacher_password = "pass-teacher123"
        existing_teacher = db.query(User).filter(User.email == teacher_email).first()
        if existing_teacher:
            print("⚠️ Teacher user already exists")
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
            print("✅ Teacher user created")

        # Add student user
        student_email = "student@example.com"
        student_password = "pass-student123"
        existing_student = db.query(User).filter(User.email == student_email).first()
        if existing_student:
            print("⚠️ Student user already exists")
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
            print("✅ Student user created")

    except Exception as e:
        print(f"❌ Error: {e}")
        db.rollback()
    finally:
        db.close()

if __name__ == "__main__":
    add_users()
