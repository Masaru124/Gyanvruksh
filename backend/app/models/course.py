from sqlalchemy import String, Text, ForeignKey, DateTime, Integer, Float
from sqlalchemy.orm import Mapped, mapped_column
from typing import Optional
from datetime import datetime
from app.database import Base

class Course(Base):
    __tablename__ = "courses"
    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    title: Mapped[str] = mapped_column(String(255), index=True)
    description: Mapped[str] = mapped_column(Text)
    teacher_id: Mapped[Optional[int]] = mapped_column(ForeignKey("users.id"), nullable=True)
    category_id: Mapped[Optional[int]] = mapped_column(ForeignKey("categories.id"), nullable=True)
    total_hours: Mapped[int] = mapped_column(Integer, default=0)
    difficulty: Mapped[str] = mapped_column(String(50), default="beginner")  # beginner, intermediate, advanced
    thumbnail_url: Mapped[Optional[str]] = mapped_column(String(500), nullable=True)
    rating: Mapped[float] = mapped_column(Float, default=0.0)
    enrollment_count: Mapped[int] = mapped_column(Integer, default=0)
    is_published: Mapped[bool] = mapped_column(default=False)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
