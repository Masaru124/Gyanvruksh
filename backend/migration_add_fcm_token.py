"""
Migration to add fcm_token column to users table
"""
from sqlalchemy import Column, String, text
from app.database import Base, engine

def upgrade():
    """Add fcm_token column to users table"""
    with engine.connect() as conn:
        # Check if column already exists
        result = conn.execute(text("""
            SELECT column_name
            FROM information_schema.columns
            WHERE table_name = 'users' AND column_name = 'fcm_token'
        """))

        if not result.fetchone():
            # Add the column
            conn.execute(text("""
                ALTER TABLE users
                ADD COLUMN fcm_token VARCHAR(255)
            """))
            conn.commit()
            print("Added fcm_token column to users table")
        else:
            print("fcm_token column already exists")

def downgrade():
    """Remove fcm_token column from users table"""
    with engine.connect() as conn:
        # Check if column exists
        result = conn.execute(text("""
            SELECT column_name
            FROM information_schema.columns
            WHERE table_name = 'users' AND column_name = 'fcm_token'
        """))

        if result.fetchone():
            # Remove the column
            conn.execute(text("""
                ALTER TABLE users
                DROP COLUMN fcm_token
            """))
            conn.commit()
            print("Removed fcm_token column from users table")
        else:
            print("fcm_token column doesn't exist")

if __name__ == "__main__":
    upgrade()
