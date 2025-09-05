from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    APP_ENV: str = "production"
    SECRET_KEY: str = "supersecret_dev_key_change_me"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60
    
    # Neon PostgreSQL Database URL
    # Format: postgresql://username:password@host:port/database?options
    DATABASE_URL: str = "sqlite:///./educonnect.db"

    model_config = {"env_file": ".env", "case_sensitive": False}

settings = Settings()
