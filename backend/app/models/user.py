from sqlalchemy import String, Boolean, DateTime, Integer
from sqlalchemy.orm import Mapped, mapped_column
from datetime import datetime
from app.database import Base

class User(Base):
    __tablename__ = "users"
    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    email: Mapped[str] = mapped_column(String(255), unique=True, index=True)
    hashed_password: Mapped[str] = mapped_column(String(255))
    full_name: Mapped[str] = mapped_column(String(255))
    age: Mapped[int] = mapped_column(Integer, nullable=True)
    gender: Mapped[str] = mapped_column(String(50), nullable=True)
    role: Mapped[str] = mapped_column(String(50), nullable=True)  # service_provider, service_seeker, admin
    sub_role: Mapped[str] = mapped_column(String(50), nullable=True)  # teacher, seller, student, buyer
    educational_qualification: Mapped[str] = mapped_column(String(255), nullable=True)
    preferred_language: Mapped[str] = mapped_column(String(50), nullable=True)  # kannada, english, hindi
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)
    is_teacher: Mapped[bool] = mapped_column(Boolean, default=False)  # Keep for backward compatibility
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
