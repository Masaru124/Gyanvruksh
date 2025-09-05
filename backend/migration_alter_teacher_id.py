#!/usr/bin/env python3
"""
Migration script to alter teacher_id column in courses table to allow NULL values.
This fixes the issue where admin-created courses need teacher_id to be nullable.
"""

import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from sqlalchemy import text
from app.database import engine

def run_migration():
    """Run the migration to alter teacher_id column to be nullable"""
    try:
        with engine.connect() as conn:
            # Alter the teacher_id column to allow NULL values
            alter_query = text("""
            ALTER TABLE courses
            ALTER COLUMN teacher_id DROP NOT NULL;
            """)
            conn.execute(alter_query)
            conn.commit()
            print("✅ Migration completed: teacher_id column now allows NULL values")
    except Exception as e:
        print(f"❌ Migration failed: {e}")
        return False
    return True

if __name__ == "__main__":
    print("Running migration to make teacher_id nullable in courses table...")
    success = run_migration()
    if success:
        print("Migration completed successfully!")
    else:
        print("Migration failed!")
        sys.exit(1)
