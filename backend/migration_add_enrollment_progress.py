#!/usr/bin/env python3

import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from sqlalchemy import create_engine, text
from app.settings import Settings

def run_migration():
    # Use the DATABASE_URL from settings
    settings = Settings()
    engine = create_engine(settings.DATABASE_URL)

    with engine.connect() as conn:
        # Add progress column to enrollments table
        try:
            conn.execute(text("""
                ALTER TABLE enrollments
                ADD COLUMN progress INTEGER DEFAULT 0;
            """))
            conn.commit()
            print("✅ Added progress column to enrollments table")
        except Exception as e:
            if "already exists" in str(e).lower() or "duplicate column" in str(e).lower():
                print("⚠️  Column progress already exists in enrollments table")
            else:
                print(f"❌ Error adding progress column: {e}")
                raise

if __name__ == "__main__":
    run_migration()
