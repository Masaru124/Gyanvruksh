from pydantic_settings import BaseSettings
from pathlib import Path
BASE_DIR = Path(__file__).resolve().parent.parent

class Settings(BaseSettings):
    APP_ENV: str = "dev"
    SECRET_KEY: str = "supersecret_dev_key_change_me"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60
    DATABASE_URL: str = f"sqlite:///{BASE_DIR / 'educonnect.db'}"

    model_config = {"env_file": ".env", "case_sensitive": False}

settings = Settings()
