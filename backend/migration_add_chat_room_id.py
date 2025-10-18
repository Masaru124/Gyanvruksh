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
        # Add room_id column to chat_messages table
        try:
            conn.execute(text("""
                ALTER TABLE chat_messages
                ADD COLUMN room_id VARCHAR(50) DEFAULT 'general';
            """))
            conn.commit()
            print("✅ Added room_id column to chat_messages table")
        except Exception as e:
            if "already exists" in str(e).lower() or "duplicate column" in str(e).lower():
                print("⚠️  Column room_id already exists in chat_messages table")
            else:
                print(f"❌ Error adding room_id column: {e}")
                raise

if __name__ == "__main__":
    run_migration()
