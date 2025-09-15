from sqlalchemy import String, Text, ForeignKey, DateTime, Integer, Boolean, Float
from sqlalchemy.orm import Mapped, mapped_column
from typing import Optional
from datetime import datetime
from app.database import Base

class UserProgress(Base):
    __tablename__ = "user_progress"
    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"))
    course_id: Mapped[int] = mapped_column(ForeignKey("courses.id"))
    lesson_id: Mapped[Optional[int]] = mapped_column(ForeignKey("lessons.id"), nullable=True)
    progress_percentage: Mapped[float] = mapped_column(Float, default=0.0)  # 0-100
    completed: Mapped[bool] = mapped_column(Boolean, default=False)
    time_spent_minutes: Mapped[int] = mapped_column(Integer, default=0)
    last_accessed: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)

class UserPreferences(Base):
    __tablename__ = "user_preferences"
    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"))
    preferred_categories: Mapped[Optional[str]] = mapped_column(Text, nullable=True)  # JSON array of category IDs
    skill_level: Mapped[str] = mapped_column(String(50), default="beginner")  # beginner, intermediate, advanced
    learning_goals: Mapped[Optional[str]] = mapped_column(Text, nullable=True)  # JSON array
    daily_study_time: Mapped[int] = mapped_column(Integer, default=30)  # minutes
    notifications_enabled: Mapped[bool] = mapped_column(Boolean, default=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
