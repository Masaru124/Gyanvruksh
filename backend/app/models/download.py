from sqlalchemy import String, Text, ForeignKey, DateTime, Integer, Boolean
from sqlalchemy.orm import Mapped, mapped_column
from typing import Optional
from datetime import datetime
from app.database import Base

class Download(Base):
    __tablename__ = "downloads"
    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"))
    content_type: Mapped[str] = mapped_column(String(50))  # course, lesson, quiz
    content_id: Mapped[int] = mapped_column(Integer)  # ID of the content
    file_path: Mapped[str] = mapped_column(String(500))  # Local path on device
    file_size_bytes: Mapped[int] = mapped_column(Integer, default=0)
    download_date: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    last_accessed: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    is_available: Mapped[bool] = mapped_column(Boolean, default=True)  # Check if file still exists
