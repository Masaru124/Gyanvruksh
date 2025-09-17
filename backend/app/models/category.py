from sqlalchemy import String, Text, DateTime
from sqlalchemy.orm import Mapped, mapped_column
from datetime import datetime
from app.database import Base

class Category(Base):
    __tablename__ = "categories"
    id: Mapped[int] = mapped_column(primary_key=True, index=True)
    name: Mapped[str] = mapped_column(String(100), unique=True, index=True)
    description: Mapped[str] = mapped_column(Text, nullable=True)
    type: Mapped[str] = mapped_column(String(50))  # academics, skills, sports, creativity
    icon: Mapped[str] = mapped_column(String(255), nullable=True)  # icon URL or name
    color: Mapped[str] = mapped_column(String(7), nullable=True)  # hex color
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
