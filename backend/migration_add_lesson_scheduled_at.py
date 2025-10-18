#!/usr/bin/env python3

import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from sqlalchemy import create_engine, text
from app.settings import settings

def run_migration():
    engine = create_engine(settings.DATABASE_URL)
    
    with engine.connect() as conn:
        # Add scheduled_at column to lessons table
        try:
            conn.execute(text("""
                ALTER TABLE lessons 
                ADD COLUMN scheduled_at TIMESTAMP NULL;
            """))
            conn.commit()
            print("✅ Added scheduled_at column to lessons table")
        except Exception as e:
            if "already exists" in str(e).lower() or "duplicate column" in str(e).lower():
                print("⚠️  Column scheduled_at already exists in lessons table")
            else:
                print(f"❌ Error adding scheduled_at column: {e}")
                raise

if __name__ == "__main__":
    run_migration()
