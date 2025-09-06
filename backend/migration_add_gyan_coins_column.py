#!/usr/bin/env python3
"""
Migration script to add gyan_coins column to users table.
"""

import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from sqlalchemy import text
from app.database import engine

def run_migration():
    """Run the migration to add gyan_coins column"""
    try:
        with engine.connect() as conn:
            # Check if column already exists
            check_query = text("""
            SELECT column_name
            FROM information_schema.columns
            WHERE table_name = 'users' AND column_name = 'gyan_coins';
            """)
            result = conn.execute(check_query).fetchone()

            if result:
                print("✅ Column 'gyan_coins' already exists in users table. Skipping migration.")
                return True

            # Add the gyan_coins column with default 0
            alter_query = text("""
            ALTER TABLE users
            ADD COLUMN gyan_coins INTEGER DEFAULT 0 NOT NULL;
            """)
            conn.execute(alter_query)
            conn.commit()
            print("✅ Migration completed: gyan_coins column added to users table")
    except Exception as e:
        print(f"❌ Migration failed: {e}")
        return False
    return True

if __name__ == "__main__":
    print("Running migration to add gyan_coins column to users table...")
    success = run_migration()
    if success:
        print("Migration completed successfully!")
    else:
        print("Migration failed!")
        sys.exit(1)
