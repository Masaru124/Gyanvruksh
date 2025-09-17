#!/usr/bin/env python3
"""
Migration script to add new columns to courses table.
"""

import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from app.database import SessionLocal, engine
from sqlalchemy import text

def migrate_courses_table():
    """Add new columns to courses table"""
    db = SessionLocal()

    try:
        # Add category_id column
        db.execute(text("ALTER TABLE courses ADD COLUMN IF NOT EXISTS category_id INTEGER REFERENCES categories(id)"))
        print("✅ Added category_id column to courses table")

        # Add total_hours column
        db.execute(text("ALTER TABLE courses ADD COLUMN IF NOT EXISTS total_hours INTEGER DEFAULT 0"))
        print("✅ Added total_hours column to courses table")

        # Add difficulty column
        db.execute(text("ALTER TABLE courses ADD COLUMN IF NOT EXISTS difficulty VARCHAR(50) DEFAULT 'beginner'"))
        print("✅ Added difficulty column to courses table")

        # Add thumbnail_url column
        db.execute(text("ALTER TABLE courses ADD COLUMN IF NOT EXISTS thumbnail_url VARCHAR(500)"))
        print("✅ Added thumbnail_url column to courses table")

        # Add rating column
        db.execute(text("ALTER TABLE courses ADD COLUMN IF NOT EXISTS rating FLOAT DEFAULT 0.0"))
        print("✅ Added rating column to courses table")

        # Add enrollment_count column
        db.execute(text("ALTER TABLE courses ADD COLUMN IF NOT EXISTS enrollment_count INTEGER DEFAULT 0"))
        print("✅ Added enrollment_count column to courses table")

        # Add is_published column
        db.execute(text("ALTER TABLE courses ADD COLUMN IF NOT EXISTS is_published BOOLEAN DEFAULT FALSE"))
        print("✅ Added is_published column to courses table")

        db.commit()
        print("✅ Migration completed successfully!")

    except Exception as e:
        print(f"❌ Migration failed: {e}")
        db.rollback()
    finally:
        db.close()

def create_categories_table():
    """Create categories table if it doesn't exist"""
    db = SessionLocal()

    try:
        # Create categories table
        db.execute(text("""
            CREATE TABLE IF NOT EXISTS categories (
                id SERIAL PRIMARY KEY,
                name VARCHAR(100) UNIQUE NOT NULL,
                description TEXT,
                type VARCHAR(50),
                icon VARCHAR(10),
                color VARCHAR(7),
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        """))
        print("✅ Created categories table")

        # Add missing columns if table already exists
        db.execute(text("ALTER TABLE categories ADD COLUMN IF NOT EXISTS type VARCHAR(50)"))
        db.execute(text("ALTER TABLE categories ADD COLUMN IF NOT EXISTS icon VARCHAR(10)"))
        db.execute(text("ALTER TABLE categories ADD COLUMN IF NOT EXISTS color VARCHAR(7)"))
        print("✅ Added missing columns to categories table")

        db.commit()

    except Exception as e:
        print(f"❌ Failed to create categories table: {e}")
        db.rollback()
    finally:
        db.close()

def create_lessons_table():
    """Create lessons table if it doesn't exist"""
    db = SessionLocal()

    try:
        # Create lessons table
        db.execute(text("""
            CREATE TABLE IF NOT EXISTS lessons (
                id SERIAL PRIMARY KEY,
                course_id INTEGER REFERENCES courses(id) ON DELETE CASCADE,
                title VARCHAR(255) NOT NULL,
                description TEXT,
                content_type VARCHAR(50) DEFAULT 'video',
                content_url TEXT,
                duration_minutes INTEGER DEFAULT 0,
                order_index INTEGER DEFAULT 0,
                is_free BOOLEAN DEFAULT TRUE,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        """))
        print("✅ Created lessons table")

        db.commit()

    except Exception as e:
        print(f"❌ Failed to create lessons table: {e}")
        db.rollback()
    finally:
        db.close()

def create_quizzes_table():
    """Create quizzes table if it doesn't exist"""
    db = SessionLocal()

    try:
        # Create quizzes table
        db.execute(text("""
            CREATE TABLE IF NOT EXISTS quizzes (
                id SERIAL PRIMARY KEY,
                lesson_id INTEGER REFERENCES lessons(id),
                course_id INTEGER REFERENCES courses(id) ON DELETE CASCADE,
                title VARCHAR(255) NOT NULL,
                description TEXT,
                time_limit_minutes INTEGER,
                passing_score INTEGER DEFAULT 70,
                is_active BOOLEAN DEFAULT TRUE,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        """))
        print("✅ Created quizzes table")

        db.commit()

    except Exception as e:
        print(f"❌ Failed to create quizzes table: {e}")
        db.rollback()
    finally:
        db.close()

def create_questions_table():
    """Create questions table if it doesn't exist"""
    db = SessionLocal()

    try:
        # Create questions table
        db.execute(text("""
            CREATE TABLE IF NOT EXISTS questions (
                id SERIAL PRIMARY KEY,
                quiz_id INTEGER REFERENCES quizzes(id) ON DELETE CASCADE,
                question_text TEXT NOT NULL,
                question_type VARCHAR(50) DEFAULT 'multiple_choice',
                options TEXT,
                correct_answer TEXT NOT NULL,
                points INTEGER DEFAULT 1,
                order_index INTEGER DEFAULT 0
            )
        """))
        print("✅ Created questions table")

        db.commit()

    except Exception as e:
        print(f"❌ Failed to create questions table: {e}")
        db.rollback()
    finally:
        db.close()

def create_quiz_attempts_table():
    """Create quiz_attempts table if it doesn't exist"""
    db = SessionLocal()

    try:
        # Create quiz_attempts table
        db.execute(text("""
            CREATE TABLE IF NOT EXISTS quiz_attempts (
                id SERIAL PRIMARY KEY,
                quiz_id INTEGER REFERENCES quizzes(id) ON DELETE CASCADE,
                user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
                score INTEGER DEFAULT 0,
                total_questions INTEGER NOT NULL,
                correct_answers INTEGER DEFAULT 0,
                time_taken_minutes INTEGER,
                completed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        """))
        print("✅ Created quiz_attempts table")

        db.commit()

    except Exception as e:
        print(f"❌ Failed to create quiz_attempts table: {e}")
        db.rollback()
    finally:
        db.close()

def create_user_progress_table():
    """Create user_progress table if it doesn't exist"""
    db = SessionLocal()

    try:
        # Create user_progress table
        db.execute(text("""
            CREATE TABLE IF NOT EXISTS user_progress (
                id SERIAL PRIMARY KEY,
                user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
                course_id INTEGER REFERENCES courses(id) ON DELETE CASCADE,
                lesson_id INTEGER REFERENCES lessons(id) ON DELETE CASCADE,
                progress_percentage FLOAT DEFAULT 0.0,
                completed BOOLEAN DEFAULT FALSE,
                time_spent_minutes INTEGER DEFAULT 0,
                last_accessed TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        """))
        print("✅ Created user_progress table")

        db.commit()

    except Exception as e:
        print(f"❌ Failed to create user_progress table: {e}")
        db.rollback()
    finally:
        db.close()

def create_user_preferences_table():
    """Create user_preferences table if it doesn't exist"""
    db = SessionLocal()

    try:
        # Create user_preferences table
        db.execute(text("""
            CREATE TABLE IF NOT EXISTS user_preferences (
                id SERIAL PRIMARY KEY,
                user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
                preferred_categories TEXT,
                skill_level VARCHAR(50) DEFAULT 'beginner',
                learning_goals TEXT,
                daily_study_time INTEGER DEFAULT 30,
                notifications_enabled BOOLEAN DEFAULT TRUE,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        """))
        print("✅ Created user_preferences table")

        db.commit()

    except Exception as e:
        print(f"❌ Failed to create user_preferences table: {e}")
        db.rollback()
    finally:
        db.close()

def create_badges_table():
    """Create badges table if it doesn't exist"""
    db = SessionLocal()

    try:
        # Create badges table
        db.execute(text("""
            CREATE TABLE IF NOT EXISTS badges (
                id SERIAL PRIMARY KEY,
                name VARCHAR(100) UNIQUE NOT NULL,
                description TEXT,
                icon_url VARCHAR(500),
                category VARCHAR(50),
                criteria_type VARCHAR(50),
                criteria_value INTEGER,
                gyan_coins_reward INTEGER DEFAULT 0,
                is_active BOOLEAN DEFAULT TRUE,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        """))
        print("✅ Created badges table")

        db.commit()

    except Exception as e:
        print(f"❌ Failed to create badges table: {e}")
        db.rollback()
    finally:
        db.close()

def create_user_badges_table():
    """Create user_badges table if it doesn't exist"""
    db = SessionLocal()

    try:
        # Create user_badges table
        db.execute(text("""
            CREATE TABLE IF NOT EXISTS user_badges (
                id SERIAL PRIMARY KEY,
                user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
                badge_id INTEGER REFERENCES badges(id) ON DELETE CASCADE,
                earned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        """))
        print("✅ Created user_badges table")

        db.commit()

    except Exception as e:
        print(f"❌ Failed to create user_badges table: {e}")
        db.rollback()
    finally:
        db.close()

def create_streaks_table():
    """Create streaks table if it doesn't exist"""
    db = SessionLocal()

    try:
        # Create streaks table
        db.execute(text("""
            CREATE TABLE IF NOT EXISTS streaks (
                id SERIAL PRIMARY KEY,
                user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
                streak_type VARCHAR(50),
                current_streak INTEGER DEFAULT 0,
                longest_streak INTEGER DEFAULT 0,
                last_activity TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        """))
        print("✅ Created streaks table")

        db.commit()

    except Exception as e:
        print(f"❌ Failed to create streaks table: {e}")
        db.rollback()
    finally:
        db.close()

def create_daily_challenges_table():
    """Create daily_challenges table if it doesn't exist"""
    db = SessionLocal()

    try:
        # Create daily_challenges table
        db.execute(text("""
            CREATE TABLE IF NOT EXISTS daily_challenges (
                id SERIAL PRIMARY KEY,
                title VARCHAR(255) NOT NULL,
                description TEXT,
                challenge_type VARCHAR(50),
                target_value INTEGER,
                gyan_coins_reward INTEGER DEFAULT 10,
                date DATE NOT NULL,
                is_active BOOLEAN DEFAULT TRUE,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        """))
        print("✅ Created daily_challenges table")

        db.commit()

    except Exception as e:
        print(f"❌ Failed to create daily_challenges table: {e}")
        db.rollback()
    finally:
        db.close()

def create_user_challenges_table():
    """Create user_challenges table if it doesn't exist"""
    db = SessionLocal()

    try:
        # Create user_challenges table
        db.execute(text("""
            CREATE TABLE IF NOT EXISTS user_challenges (
                id SERIAL PRIMARY KEY,
                user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
                challenge_id INTEGER REFERENCES daily_challenges(id) ON DELETE CASCADE,
                progress INTEGER DEFAULT 0,
                completed BOOLEAN DEFAULT FALSE,
                completed_at TIMESTAMP,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        """))
        print("✅ Created user_challenges table")

        db.commit()

    except Exception as e:
        print(f"❌ Failed to create user_challenges table: {e}")
        db.rollback()
    finally:
        db.close()

def create_downloads_table():
    """Create downloads table if it doesn't exist"""
    db = SessionLocal()

    try:
        # Create downloads table
        db.execute(text("""
            CREATE TABLE IF NOT EXISTS downloads (
                id SERIAL PRIMARY KEY,
                user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
                course_id INTEGER REFERENCES courses(id) ON DELETE CASCADE,
                lesson_id INTEGER REFERENCES lessons(id) ON DELETE CASCADE,
                download_type VARCHAR(50),
                file_path TEXT,
                downloaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        """))
        print("✅ Created downloads table")

        db.commit()

    except Exception as e:
        print(f"❌ Failed to create downloads table: {e}")
        db.rollback()
    finally:
        db.close()

def create_assignments_table():
    """Create assignments table if it doesn't exist"""
    db = SessionLocal()

    try:
        # Create assignments table
        db.execute(text("""
            CREATE TABLE IF NOT EXISTS assignments (
                id SERIAL PRIMARY KEY,
                course_id INTEGER REFERENCES courses(id) ON DELETE CASCADE,
                lesson_id INTEGER REFERENCES lessons(id),
                teacher_id INTEGER REFERENCES users(id),
                title VARCHAR(255) NOT NULL,
                description TEXT,
                assignment_type VARCHAR(50) DEFAULT 'homework',
                due_date TIMESTAMP,
                max_score INTEGER DEFAULT 100,
                instructions TEXT,
                attachments TEXT,
                is_active BOOLEAN DEFAULT TRUE,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        """))
        print("✅ Created assignments table")

        db.commit()

    except Exception as e:
        print(f"❌ Failed to create assignments table: {e}")
        db.rollback()
    finally:
        db.close()

def create_assignment_submissions_table():
    """Create assignment_submissions table if it doesn't exist"""
    db = SessionLocal()

    try:
        # Create assignment_submissions table
        db.execute(text("""
            CREATE TABLE IF NOT EXISTS assignment_submissions (
                id SERIAL PRIMARY KEY,
                assignment_id INTEGER REFERENCES assignments(id) ON DELETE CASCADE,
                student_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
                submission_text TEXT,
                attachments TEXT,
                score INTEGER,
                feedback TEXT,
                submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                graded_at TIMESTAMP,
                status VARCHAR(50) DEFAULT 'pending'
            )
        """))
        print("✅ Created assignment_submissions table")

        db.commit()

    except Exception as e:
        print(f"❌ Failed to create assignment_submissions table: {e}")
        db.rollback()
    finally:
        db.close()

def create_clubs_table():
    """Create clubs table if it doesn't exist"""
    db = SessionLocal()

    try:
        # Create clubs table
        db.execute(text("""
            CREATE TABLE IF NOT EXISTS clubs (
                id SERIAL PRIMARY KEY,
                name VARCHAR(255) NOT NULL,
                description TEXT,
                category VARCHAR(50),
                admin_id INTEGER REFERENCES users(id),
                max_members INTEGER DEFAULT 50,
                is_private BOOLEAN DEFAULT FALSE,
                club_image_url VARCHAR(500),
                meeting_schedule TEXT,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        """))
        print("✅ Created clubs table")

        db.commit()

    except Exception as e:
        print(f"❌ Failed to create clubs table: {e}")
        db.rollback()
    finally:
        db.close()

def create_club_members_table():
    """Create club_members table if it doesn't exist"""
    db = SessionLocal()

    try:
        # Create club_members table
        db.execute(text("""
            CREATE TABLE IF NOT EXISTS club_members (
                id SERIAL PRIMARY KEY,
                club_id INTEGER REFERENCES clubs(id) ON DELETE CASCADE,
                user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
                role VARCHAR(50) DEFAULT 'member',
                joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        """))
        print("✅ Created club_members table")

        db.commit()

    except Exception as e:
        print(f"❌ Failed to create club_members table: {e}")
        db.rollback()
    finally:
        db.close()

def create_notifications_table():
    """Create notifications table if it doesn't exist"""
    db = SessionLocal()

    try:
        # Create notifications table
        db.execute(text("""
            CREATE TABLE IF NOT EXISTS notifications (
                id SERIAL PRIMARY KEY,
                user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
                title VARCHAR(255) NOT NULL,
                message TEXT,
                notification_type VARCHAR(50),
                is_read BOOLEAN DEFAULT FALSE,
                related_id INTEGER,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        """))
        print("✅ Created notifications table")

        db.commit()

    except Exception as e:
        print(f"❌ Failed to create notifications table: {e}")
        db.rollback()
    finally:
        db.close()

def create_analytics_table():
    """Create analytics table if it doesn't exist"""
    db = SessionLocal()

    try:
        # Create analytics table
        db.execute(text("""
            CREATE TABLE IF NOT EXISTS analytics (
                id SERIAL PRIMARY KEY,
                user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
                event_type VARCHAR(100),
                event_data TEXT,
                session_id VARCHAR(255),
                timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        """))
        print("✅ Created analytics table")

        db.commit()

    except Exception as e:
        print(f"❌ Failed to create analytics table: {e}")
        db.rollback()
    finally:
        db.close()

def main():
    print("🔄 Running database migrations...")

    # Create all tables
    create_categories_table()
    create_lessons_table()
    create_quizzes_table()
    create_questions_table()
    create_quiz_attempts_table()
    create_user_progress_table()
    create_user_preferences_table()
    create_badges_table()
    create_user_badges_table()
    create_streaks_table()
    create_daily_challenges_table()
    create_user_challenges_table()
    create_downloads_table()
    create_assignments_table()
    create_assignment_submissions_table()
    create_clubs_table()
    create_club_members_table()
    create_notifications_table()
    create_analytics_table()

    # Migrate existing courses table
    migrate_courses_table()

    print("✅ All migrations completed!")

if __name__ == "__main__":
    main()
