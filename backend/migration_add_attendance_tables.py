"""
Database migration script to add attendance tracking tables
Run this script to create the attendance and attendance_sessions tables
"""

import os
import sys
from sqlalchemy import create_engine, text
from datetime import datetime

# Add the parent directory to the path so we can import from app
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app.database import engine

def run_migration():
    
    print("Starting attendance tables migration...")
    
    try:
        with engine.connect() as connection:
            # Create attendance table
            connection.execute(text("""
                CREATE TABLE IF NOT EXISTS attendance (
                    id SERIAL PRIMARY KEY,
                    student_id INTEGER NOT NULL REFERENCES users(id),
                    lesson_id INTEGER NOT NULL REFERENCES lessons(id),
                    course_id INTEGER NOT NULL REFERENCES courses(id),
                    is_present BOOLEAN DEFAULT FALSE,
                    attendance_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    marked_by INTEGER NOT NULL REFERENCES users(id),
                    notes VARCHAR(500),
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                );
            """))
            
            # Create attendance_sessions table
            connection.execute(text("""
                CREATE TABLE IF NOT EXISTS attendance_sessions (
                    id SERIAL PRIMARY KEY,
                    lesson_id INTEGER NOT NULL REFERENCES lessons(id),
                    course_id INTEGER NOT NULL REFERENCES courses(id),
                    teacher_id INTEGER NOT NULL REFERENCES users(id),
                    session_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    total_students INTEGER DEFAULT 0,
                    present_students INTEGER DEFAULT 0,
                    attendance_percentage FLOAT DEFAULT 0.0,
                    is_completed BOOLEAN DEFAULT FALSE,
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                );
            """))
            
            # Create indexes for better performance
            connection.execute(text("""
                CREATE INDEX IF NOT EXISTS idx_attendance_student_id ON attendance(student_id);
            """))
            
            connection.execute(text("""
                CREATE INDEX IF NOT EXISTS idx_attendance_lesson_id ON attendance(lesson_id);
            """))
            
            connection.execute(text("""
                CREATE INDEX IF NOT EXISTS idx_attendance_course_id ON attendance(course_id);
            """))
            
            connection.execute(text("""
                CREATE INDEX IF NOT EXISTS idx_attendance_sessions_course_id ON attendance_sessions(course_id);
            """))
            
            connection.execute(text("""
                CREATE INDEX IF NOT EXISTS idx_attendance_sessions_teacher_id ON attendance_sessions(teacher_id);
            """))
            
            connection.commit()
            print("✅ Attendance tables created successfully!")
            
    except Exception as e:
        print(f"❌ Error during migration: {e}")
        raise

if __name__ == "__main__":
    run_migration()
    print("🎉 Migration completed!")
