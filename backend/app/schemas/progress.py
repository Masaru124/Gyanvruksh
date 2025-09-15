from pydantic import BaseModel
from typing import Optional
from datetime import datetime

class UserProgressBase(BaseModel):
    progress_percentage: float = 0.0
    completed: bool = False
    time_spent_minutes: int = 0

class UserProgressCreate(UserProgressBase):
    course_id: int
    lesson_id: Optional[int] = None

class UserProgressUpdate(BaseModel):
    progress_percentage: Optional[float] = None
    completed: Optional[bool] = None
    time_spent_minutes: Optional[int] = None

class UserProgress(UserProgressBase):
    id: int
    user_id: int
    course_id: int
    lesson_id: Optional[int]
    last_accessed: datetime
    created_at: datetime

    class Config:
        from_attributes = True

class UserPreferencesBase(BaseModel):
    preferred_categories: Optional[str] = None
    skill_level: str = "beginner"
    learning_goals: Optional[str] = None
    daily_study_time: int = 30
    notifications_enabled: bool = True

class UserPreferencesUpdate(BaseModel):
    preferred_categories: Optional[str] = None
    skill_level: Optional[str] = None
    learning_goals: Optional[str] = None
    daily_study_time: Optional[int] = None
    notifications_enabled: Optional[bool] = None

class UserPreferencesOut(UserPreferencesBase):
    id: int
    user_id: int
    created_at: datetime

    class Config:
        from_attributes = True
