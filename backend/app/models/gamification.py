from sqlalchemy import String, Text, ForeignKey, DateTime, Integer, Boolean
from sqlalchemy.orm import Mapped, mapped_column
from typing import Optional
from datetime import datetime
from app.database import Base

class Badge(Base):
    __tablename__ = "badges"
    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    name: Mapped[str] = mapped_column(String(100), unique=True)
    description: Mapped[str] = mapped_column(Text)
    icon_url: Mapped[Optional[str]] = mapped_column(String(500), nullable=True)
    category: Mapped[str] = mapped_column(String(50))  # academics, skills, sports, creativity, general
    criteria_type: Mapped[str] = mapped_column(String(50))  # courses_completed, streak, quiz_score, etc.
    criteria_value: Mapped[int] = mapped_column(Integer)  # e.g., 5 for 5 courses completed
    gyan_coins_reward: Mapped[int] = mapped_column(Integer, default=0)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)

class UserBadge(Base):
    __tablename__ = "user_badges"
    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"))
    badge_id: Mapped[int] = mapped_column(ForeignKey("badges.id"))
    earned_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)

class Streak(Base):
    __tablename__ = "streaks"
    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"))
    streak_type: Mapped[str] = mapped_column(String(50))  # daily_study, daily_quiz, etc.
    current_streak: Mapped[int] = mapped_column(Integer, default=0)
    longest_streak: Mapped[int] = mapped_column(Integer, default=0)
    last_activity: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)

class DailyChallenge(Base):
    __tablename__ = "daily_challenges"
    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    title: Mapped[str] = mapped_column(String(255))
    description: Mapped[str] = mapped_column(Text)
    challenge_type: Mapped[str] = mapped_column(String(50))  # quiz, study, creative, sports
    target_value: Mapped[int] = mapped_column(Integer)  # e.g., complete 3 quizzes
    gyan_coins_reward: Mapped[int] = mapped_column(Integer, default=10)
    date: Mapped[datetime] = mapped_column(DateTime)  # Date for the challenge
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)

class UserChallenge(Base):
    __tablename__ = "user_challenges"
    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"))
    challenge_id: Mapped[int] = mapped_column(ForeignKey("daily_challenges.id"))
    progress: Mapped[int] = mapped_column(Integer, default=0)  # Current progress towards target
    completed: Mapped[bool] = mapped_column(Boolean, default=False)
    completed_at: Mapped[Optional[datetime]] = mapped_column(DateTime, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
