from sqlalchemy import String, Text, ForeignKey, DateTime, Integer, Boolean
from sqlalchemy.orm import Mapped, mapped_column
from typing import Optional
from datetime import datetime
from app.database import Base

class Lesson(Base):
    __tablename__ = "lessons"
    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    course_id: Mapped[int] = mapped_column(ForeignKey("courses.id"))
    title: Mapped[str] = mapped_column(String(255))
    description: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    content_type: Mapped[str] = mapped_column(String(50))  # video, text, audio, quiz, interactive
    content_url: Mapped[Optional[str]] = mapped_column(String(500), nullable=True)  # URL for video/audio
    content_text: Mapped[Optional[str]] = mapped_column(Text, nullable=True)  # For text content
    duration_minutes: Mapped[int] = mapped_column(Integer, default=0)
    order_index: Mapped[int] = mapped_column(Integer, default=0)  # Order in course
    is_free: Mapped[bool] = mapped_column(Boolean, default=False)  # Preview lesson
    scheduled_at: Mapped[Optional[datetime]] = mapped_column(DateTime, nullable=True)  # When lesson is scheduled
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
