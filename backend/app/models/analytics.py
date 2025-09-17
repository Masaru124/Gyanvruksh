from sqlalchemy import String, Text, ForeignKey, DateTime, Integer, Float
from sqlalchemy.orm import Mapped, mapped_column, relationship
from datetime import datetime
from app.database import Base

class Analytics(Base):
    __tablename__ = "analytics"
    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"))
    analytics_type: Mapped[str] = mapped_column(String(50))  # progress, performance, habits
    category: Mapped[str] = mapped_column(String(50))  # academics, skills, sports, creativity
    metric_name: Mapped[str] = mapped_column(String(100))  # completion_rate, average_score, streak_days
    metric_value: Mapped[float] = mapped_column(Float)
    period: Mapped[str] = mapped_column(String(20))  # daily, weekly, monthly
    recorded_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)

    # Relationships
    user = relationship("User")

class ParentDashboard(Base):
    __tablename__ = "parent_dashboards"
    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    parent_id: Mapped[int] = mapped_column(ForeignKey("users.id"))
    child_id: Mapped[int] = mapped_column(ForeignKey("users.id"))
    report_data: Mapped[str] = mapped_column(Text)  # JSON string with report data
    generated_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)

    # Relationships
    parent = relationship("User", foreign_keys=[parent_id])
    child = relationship("User", foreign_keys=[child_id])
