"""
Migration to add gyan_coins column to users table
"""
from sqlalchemy import Column, String, Integer, text
from app.database import Base, engine

def upgrade():
    """Add gyan_coins column to users table"""
    with engine.connect() as conn:
        # Check if column already exists
        result = conn.execute(text("""
            SELECT column_name
            FROM information_schema.columns
            WHERE table_name = 'users' AND column_name = 'gyan_coins'
        """))

        if not result.fetchone():
            # Add the column
            conn.execute(text("""
                ALTER TABLE users
                ADD COLUMN gyan_coins INTEGER DEFAULT 0
            """))
            conn.commit()
            print("Added gyan_coins column to users table")
        else:
            print("gyan_coins column already exists")

def downgrade():
    """Remove gyan_coins column from users table"""
    with engine.connect() as conn:
        # Check if column exists
        result = conn.execute(text("""
            SELECT column_name
            FROM information_schema.columns
            WHERE table_name = 'users' AND column_name = 'gyan_coins'
        """))

        if result.fetchone():
            # Remove the column
            conn.execute(text("""
                ALTER TABLE users
                DROP COLUMN gyan_coins
            """))
            conn.commit()
            print("Removed gyan_coins column from users table")
        else:
            print("gyan_coins column doesn't exist")

if __name__ == "__main__":
    upgrade()
