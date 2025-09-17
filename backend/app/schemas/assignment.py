from pydantic import BaseModel
from datetime import datetime
from typing import Optional

class AssignmentBase(BaseModel):
    title: str
    description: str
    course_id: int
    lesson_id: Optional[int] = None
    due_date: datetime
    max_score: int = 100
    instructions: Optional[str] = None
    attachment_url: Optional[str] = None

class AssignmentCreate(AssignmentBase):
    pass

class AssignmentRead(AssignmentBase):
    id: int
    teacher_id: int
    is_active: bool
    created_at: datetime

    class Config:
        from_attributes = True

class GradeBase(BaseModel):
    assignment_id: int
    student_id: int
    score: int
    feedback: Optional[str] = None

class GradeCreate(GradeBase):
    pass

class GradeRead(GradeBase):
    id: int
    graded_by: int
    graded_at: datetime

    class Config:
        from_attributes = True
