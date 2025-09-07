import sys
sys.path.append('..')
from app.database import Base, engine
from app.models.course_note import CourseNote

def create_course_notes_table():
    """Create course_notes table"""
    try:
        CourseNote.__table__.create(bind=engine, checkfirst=True)
    except Exception as e:
        pass

if __name__ == "__main__":
    create_course_notes_table()
