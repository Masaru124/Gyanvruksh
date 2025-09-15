from pydantic import BaseModel
from typing import Optional
from datetime import datetime

class CourseCreate(BaseModel):
    title: str
    description: str
    category_id: Optional[int] = None
    total_hours: int = 0
    difficulty: str = "beginner"
    thumbnail_url: Optional[str] = None
    is_published: bool = False

class CourseUpdate(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    category_id: Optional[int] = None
    total_hours: Optional[int] = None
    difficulty: Optional[str] = None
    thumbnail_url: Optional[str] = None
    is_published: Optional[bool] = None

class CourseOut(BaseModel):
    id: int
    title: str
    description: str
    teacher_id: Optional[int]
    category_id: Optional[int]
    total_hours: int
    difficulty: str
    thumbnail_url: Optional[str]
    rating: float
    enrollment_count: int
    is_published: bool
    created_at: datetime

    model_config = {"from_attributes": True}

class EnrollmentCreate(BaseModel):
    course_id: int

class EnrollmentOut(BaseModel):
    id: int
    student_id: int
    course_id: int
    hours_completed: int
    enrolled_at: datetime

    model_config = {"from_attributes": True}

class CourseDetailOut(BaseModel):
    id: int
    title: str
    description: str
    teacher_id: Optional[int]
    teacher_name: Optional[str]
    category_id: Optional[int]
    category_name: Optional[str]
    enrolled_students_count: int
    total_hours: int
    difficulty: str
    thumbnail_url: Optional[str]
    rating: float
    is_published: bool
    created_at: datetime

    model_config = {"from_attributes": True}
