from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from app.database import get_db
from app.models.progress import UserProgress, UserPreferences
from app.schemas.progress import UserProgress as UserProgressSchema, UserProgressCreate, UserProgressUpdate, UserPreferencesOut, UserPreferencesUpdate
from app.services.deps import get_current_user
from app.models.user import User
from app.models.course import Course
from app.models.lesson import Lesson
from datetime import datetime

router = APIRouter(prefix="/api/progress", tags=["progress"])

@router.get("/courses/{course_id}", response_model=UserProgressSchema)
def get_course_progress(course_id: int, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    """
    Get user's progress for a specific course
    """
    progress = db.query(UserProgress).filter(
        UserProgress.user_id == current_user.id,
        UserProgress.course_id == course_id,
        UserProgress.lesson_id.is_(None)  # Course-level progress
    ).first()
    
    if not progress:
        # Return default progress
        return UserProgressSchema(
            id=0,
            user_id=current_user.id,
            course_id=course_id,
            progress_percentage=0.0,
            completed=False,
            time_spent_minutes=0,
            last_accessed=datetime.utcnow()
        )
    
    return progress

@router.post("/courses/{course_id}/lessons/{lesson_id}", response_model=UserProgressSchema)
def update_lesson_progress(course_id: int, lesson_id: int, progress_data: UserProgressUpdate, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    """
    Update or create progress for a specific lesson
    """
    # Verify lesson belongs to course
    lesson = db.query(Lesson).filter(Lesson.id == lesson_id, Lesson.course_id == course_id).first()
    if not lesson:
        raise HTTPException(status_code=404, detail="Lesson not found in this course")
    
    progress = db.query(UserProgress).filter(
        UserProgress.user_id == current_user.id,
        UserProgress.course_id == course_id,
        UserProgress.lesson_id == lesson_id
    ).first()
    
    if progress:
        for key, value in progress_data.model_dump(exclude_unset=True).items():
            setattr(progress, key, value)
        progress.last_accessed = datetime.utcnow()
    else:
        progress = UserProgress(
            user_id=current_user.id,
            course_id=course_id,
            lesson_id=lesson_id,
            **progress_data.model_dump()
        )
        db.add(progress)
    
    db.commit()
    db.refresh(progress)
    
    # Update course-level progress
    _update_course_progress(db, current_user.id, course_id)
    
    return progress

@router.get("/preferences", response_model=UserPreferencesOut)
def get_user_preferences(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    """
    Get user's learning preferences
    """
    preferences = db.query(UserPreferences).filter(UserPreferences.user_id == current_user.id).first()
    if not preferences:
        # Return default preferences
        return UserPreferencesOut(
            id=0,
            user_id=current_user.id,
            skill_level="beginner",
            daily_study_time=30,
            notifications_enabled=True
        )
    return preferences

@router.put("/preferences", response_model=UserPreferencesOut)
def update_user_preferences(preferences: UserPreferencesUpdate, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    """
    Update user's learning preferences
    """
    db_preferences = db.query(UserPreferences).filter(UserPreferences.user_id == current_user.id).first()
    
    if db_preferences:
        for key, value in preferences.model_dump(exclude_unset=True).items():
            setattr(db_preferences, key, value)
    else:
        db_preferences = UserPreferences(user_id=current_user.id, **preferences.model_dump())
        db.add(db_preferences)
    
    db.commit()
    db.refresh(db_preferences)
    return db_preferences

def _update_course_progress(db: Session, user_id: int, course_id: int):
    """
    Calculate and update overall course progress
    """
    lesson_progresses = db.query(UserProgress).filter(
        UserProgress.user_id == user_id,
        UserProgress.course_id == course_id,
        UserProgress.lesson_id.isnot(None)
    ).all()
    
    if not lesson_progresses:
        return
    
    total_lessons = db.query(Lesson).filter(Lesson.course_id == course_id).count()
    completed_lessons = sum(1 for p in lesson_progresses if p.completed)
    avg_progress = sum(p.progress_percentage for p in lesson_progresses) / len(lesson_progresses)
    
    course_progress = db.query(UserProgress).filter(
        UserProgress.user_id == user_id,
        UserProgress.course_id == course_id,
        UserProgress.lesson_id.is_(None)
    ).first()
    
    if course_progress:
        course_progress.progress_percentage = avg_progress
        course_progress.completed = completed_lessons == total_lessons
    else:
        course_progress = UserProgress(
            user_id=user_id,
            course_id=course_id,
            progress_percentage=avg_progress,
            completed=completed_lessons == total_lessons
        )
        db.add(course_progress)
    
    db.commit()
