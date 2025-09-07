#!/usr/bin/env python3
"""
Migration script to create chat_messages table.
"""

import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from sqlalchemy import text
from app.database import engine

def run_migration():
    """Run the migration to create chat_messages table"""
    try:
        with engine.connect() as conn:
            # Check if table already exists
            check_query = text("""
            SELECT table_name
            FROM information_schema.tables
            WHERE table_schema = 'public' AND table_name = 'chat_messages';
            """)
            result = conn.execute(check_query).fetchone()

            if result:
                return True

            # Create the chat_messages table
            create_query = text("""
            CREATE TABLE chat_messages (
                id SERIAL PRIMARY KEY,
                user_id INTEGER NOT NULL REFERENCES users(id),
                message VARCHAR(500) NOT NULL,
                timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            );
            """)
            conn.execute(create_query)
            conn.commit()
    except Exception as e:
        return False
    return True

if __name__ == "__main__":
    success = run_migration()
    if not success:
        sys.exit(1)
