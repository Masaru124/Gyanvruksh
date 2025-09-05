from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, DeclarativeBase
from app.settings import settings

class Base(DeclarativeBase): pass

# Database connection configuration for PostgreSQL/Neon
connect_args = {}
if settings.DATABASE_URL.startswith("postgresql"):
    connect_args = {
        "keepalives": 1,
        "keepalives_idle": 30,
        "keepalives_interval": 10,
        "keepalives_count": 5,
    }

engine = create_engine(
    settings.DATABASE_URL, 
    pool_pre_ping=True, 
    connect_args=connect_args,
    # PostgreSQL connection pool settings
    pool_size=5 if settings.DATABASE_URL.startswith("postgresql") else None,
    max_overflow=10 if settings.DATABASE_URL.startswith("postgresql") else None,
    pool_timeout=30 if settings.DATABASE_URL.startswith("postgresql") else None,
    pool_recycle=1800 if settings.DATABASE_URL.startswith("postgresql") else None,
)
SessionLocal = sessionmaker(bind=engine, autoflush=False, autocommit=False)

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
