from app.database import Base, engine, SessionLocal
from app.models.user import User
from app.models.course import Course
from app.services.security import hash_password

def init():
    # Drop existing tables to recreate with updated schema
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
    except Exception as e:
        print(f"❌ Error creating default admin: {e}")
    finally:
        db.close()

if __name__ == "__main__":
    init()
