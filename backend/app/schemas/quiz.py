from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime

class QuestionBase(BaseModel):
    question_text: str
    question_type: str
    options: Optional[str] = None  # JSON string
    correct_answer: str
    points: int = 1
    order_index: int = 0

class QuestionCreate(QuestionBase):
    pass

class QuestionUpdate(BaseModel):
    question_text: Optional[str] = None
    question_type: Optional[str] = None
    options: Optional[str] = None
    correct_answer: Optional[str] = None
    points: Optional[int] = None
    order_index: Optional[int] = None

class QuestionOut(QuestionBase):
    id: int
    quiz_id: int

    class Config:
        from_attributes = True

class QuizBase(BaseModel):
    title: str
    description: Optional[str] = None
    time_limit_minutes: Optional[int] = None
    passing_score: int = 70

class QuizCreate(QuizBase):
    course_id: int
    lesson_id: Optional[int] = None
    questions: List[QuestionCreate]

class QuizUpdate(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    time_limit_minutes: Optional[int] = None
    passing_score: Optional[int] = None
    is_active: Optional[bool] = None

class QuizOut(QuizBase):
    id: int
    course_id: int
    lesson_id: Optional[int]
    is_active: bool
    created_at: datetime

    class Config:
        from_attributes = True

class QuizAttemptCreate(BaseModel):
    quiz_id: int
    answers: dict  # question_id -> answer

class QuizAttemptOut(BaseModel):
    id: int
    quiz_id: int
    user_id: int
    score: int
    total_questions: int
    correct_answers: int
    time_taken_minutes: Optional[int]
    completed_at: datetime

    class Config:
        from_attributes = True
