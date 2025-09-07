import sys
sys.path.append('..')
from app.database import Base, engine
from app.models.course_video import CourseVideo

def create_course_videos_table():
    """Create course_videos table"""
    try:
        CourseVideo.__table__.create(bind=engine, checkfirst=True)
        print("✅ course_videos table created successfully")
    except Exception as e:
        print(f"❌ Error creating course_videos table: {e}")

if __name__ == "__main__":
    create_course_videos_table()
