from sqlalchemy import ForeignKey, DateTime, Integer, Boolean, String
from sqlalchemy.orm import Mapped, mapped_column
from datetime import datetime
from app.database import Base

class Attendance(Base):
    __tablename__ = "attendance"
    
    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    student_id: Mapped[int] = mapped_column(ForeignKey("users.id"))
    lesson_id: Mapped[int] = mapped_column(ForeignKey("lessons.id"))
    course_id: Mapped[int] = mapped_column(ForeignKey("courses.id"))
    is_present: Mapped[bool] = mapped_column(Boolean, default=False)
    attendance_date: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    marked_by: Mapped[int] = mapped_column(ForeignKey("users.id"))  # Teacher who marked attendance
    notes: Mapped[str] = mapped_column(String(500), nullable=True)  # Optional notes
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    updated_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

class AttendanceSession(Base):
    __tablename__ = "attendance_sessions"
    
    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    lesson_id: Mapped[int] = mapped_column(ForeignKey("lessons.id"))
    course_id: Mapped[int] = mapped_column(ForeignKey("courses.id"))
    teacher_id: Mapped[int] = mapped_column(ForeignKey("users.id"))
    session_date: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    total_students: Mapped[int] = mapped_column(Integer, default=0)
    present_students: Mapped[int] = mapped_column(Integer, default=0)
    attendance_percentage: Mapped[float] = mapped_column(default=0.0)
    is_completed: Mapped[bool] = mapped_column(Boolean, default=False)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
