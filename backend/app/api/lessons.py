from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from app.database import get_db
from app.models.lesson import Lesson
from app.models.course import Course
from app.schemas.lesson import LessonOut as LessonSchema, LessonCreate, LessonUpdate
from app.services.deps import get_current_user
from app.models.user import User

router = APIRouter(prefix="/api/lessons", tags=["lessons"])

@router.get("/", response_model=List[LessonSchema])
def get_lessons(course_id: int = None, db: Session = Depends(get_db)):
    """
    Get all lessons, optionally filtered by course_id
    """
    query = db.query(Lesson)
    if course_id:
        query = query.filter(Lesson.course_id == course_id)
    return query.order_by(Lesson.order_index).all()

@router.get("/{lesson_id}", response_model=LessonSchema)
def get_lesson(lesson_id: int, db: Session = Depends(get_db)):
    """
    Get a specific lesson by ID
    """
    lesson = db.query(Lesson).filter(Lesson.id == lesson_id).first()
    if not lesson:
        raise HTTPException(status_code=404, detail="Lesson not found")
    return lesson

@router.post("/", response_model=LessonSchema)
def create_lesson(lesson: LessonCreate, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    """
    Create a new lesson (Teacher/Admin only)
    """
    # Check if user is teacher of the course or admin
    course = db.query(Course).filter(Course.id == lesson.course_id).first()
    if not course:
        raise HTTPException(status_code=404, detail="Course not found")
    
    if current_user.role != "admin" and course.teacher_id != current_user.id:
        raise HTTPException(status_code=403, detail="Not authorized to add lessons to this course")
    
    db_lesson = Lesson(**lesson.model_dump())
    db.add(db_lesson)
    db.commit()
    db.refresh(db_lesson)
    return db_lesson

@router.put("/{lesson_id}", response_model=LessonSchema)
def update_lesson(lesson_id: int, lesson_update: LessonUpdate, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    """
    Update a lesson (Teacher/Admin only)
    """
    lesson = db.query(Lesson).filter(Lesson.id == lesson_id).first()
    if not lesson:
        raise HTTPException(status_code=404, detail="Lesson not found")
    
    course = db.query(Course).filter(Course.id == lesson.course_id).first()
    if current_user.role != "admin" and course.teacher_id != current_user.id:
        raise HTTPException(status_code=403, detail="Not authorized to update this lesson")
    
    for key, value in lesson_update.model_dump(exclude_unset=True).items():
        setattr(lesson, key, value)
    
    db.commit()
    db.refresh(lesson)
    return lesson

@router.delete("/{lesson_id}")
def delete_lesson(lesson_id: int, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    """
    Delete a lesson (Teacher/Admin only)
    """
    lesson = db.query(Lesson).filter(Lesson.id == lesson_id).first()
    if not lesson:
        raise HTTPException(status_code=404, detail="Lesson not found")
    
    course = db.query(Course).filter(Course.id == lesson.course_id).first()
    if current_user.role != "admin" and course.teacher_id != current_user.id:
        raise HTTPException(status_code=403, detail="Not authorized to delete this lesson")
    
    db.delete(lesson)
    db.commit()
    return {"message": "Lesson deleted successfully"}
