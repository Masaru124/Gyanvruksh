from pydantic import BaseModel
from typing import Optional
from datetime import datetime

class CourseCreate(BaseModel):
    title: str
    description: str
    total_hours: int = 0

class CourseOut(BaseModel):
    id: int
    title: str
    description: str
    teacher_id: Optional[int]
    total_hours: int

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
    enrolled_students_count: int
    total_hours: int
    created_at: datetime

    model_config = {"from_attributes": True}
