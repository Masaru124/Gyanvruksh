from sqlalchemy import String, Text, ForeignKey, DateTime, Integer, Boolean
from sqlalchemy.orm import Mapped, mapped_column
from typing import Optional
from datetime import datetime
from app.database import Base

class Quiz(Base):
    __tablename__ = "quizzes"
    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    lesson_id: Mapped[Optional[int]] = mapped_column(ForeignKey("lessons.id"), nullable=True)
    course_id: Mapped[int] = mapped_column(ForeignKey("courses.id"))
    title: Mapped[str] = mapped_column(String(255))
    description: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    time_limit_minutes: Mapped[Optional[int]] = mapped_column(Integer, nullable=True)
    passing_score: Mapped[int] = mapped_column(Integer, default=70)  # Percentage
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)

class Question(Base):
    __tablename__ = "questions"
    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    quiz_id: Mapped[int] = mapped_column(ForeignKey("quizzes.id"))
    question_text: Mapped[str] = mapped_column(Text)
    question_type: Mapped[str] = mapped_column(String(50))  # multiple_choice, true_false, short_answer
    options: Mapped[Optional[str]] = mapped_column(Text, nullable=True)  # JSON string for options
    correct_answer: Mapped[str] = mapped_column(Text)  # For multiple choice: option index, for others: text
    points: Mapped[int] = mapped_column(Integer, default=1)
    order_index: Mapped[int] = mapped_column(Integer, default=0)

class QuizAttempt(Base):
    __tablename__ = "quiz_attempts"
    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    quiz_id: Mapped[int] = mapped_column(ForeignKey("quizzes.id"))
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"))
    score: Mapped[int] = mapped_column(Integer, default=0)  # Percentage
    total_questions: Mapped[int] = mapped_column(Integer)
    correct_answers: Mapped[int] = mapped_column(Integer, default=0)
    time_taken_minutes: Mapped[Optional[int]] = mapped_column(Integer, nullable=True)
    completed_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
