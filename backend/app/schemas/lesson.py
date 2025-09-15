from pydantic import BaseModel
from typing import Optional
from datetime import datetime

class LessonBase(BaseModel):
    title: str
    description: Optional[str] = None
    content_type: str
    content_url: Optional[str] = None
    content_text: Optional[str] = None
    duration_minutes: int = 0
    order_index: int = 0
    is_free: bool = False

class LessonCreate(LessonBase):
    course_id: int

class LessonUpdate(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    content_type: Optional[str] = None
    content_url: Optional[str] = None
    content_text: Optional[str] = None
    duration_minutes: Optional[int] = None
    order_index: Optional[int] = None
    is_free: Optional[bool] = None

class LessonOut(LessonBase):
    id: int
    course_id: int
    created_at: datetime

    class Config:
        from_attributes = True
