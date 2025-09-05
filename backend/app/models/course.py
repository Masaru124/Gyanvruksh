from sqlalchemy import String, Text, ForeignKey, DateTime, Integer
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
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
