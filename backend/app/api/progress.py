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
from app.models.category import Category
from app.models.gamification import Badge, Streak, DailyChallenge
from app.models.enrollment import Enrollment
from sqlalchemy import func, desc
from datetime import datetime, timedelta

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
    Calculate and update overall course progress based on lesson completion
    """
    # Get all lessons for the course
    lessons = db.query(Lesson).filter(Lesson.course_id == course_id).all()
    if not lessons:
        return

    total_lessons = len(lessons)
    completed_lessons = 0
    total_progress = 0

    # Calculate progress from individual lesson progress records
    for lesson in lessons:
        lesson_progress = db.query(UserProgress).filter(
            UserProgress.user_id == user_id,
            UserProgress.course_id == course_id,
            UserProgress.lesson_id == lesson.id
        ).first()

        if lesson_progress:
            if lesson_progress.completed:
                completed_lessons += 1
            total_progress += lesson_progress.progress_percentage

    # Calculate average progress across all lessons
    avg_progress = total_progress / total_lessons if total_lessons > 0 else 0
    course_completed = completed_lessons == total_lessons

    # Update or create course-level progress
    course_progress = db.query(UserProgress).filter(
        UserProgress.user_id == user_id,
        UserProgress.course_id == course_id,
        UserProgress.lesson_id.is_(None)
    ).first()

    if course_progress:
        course_progress.progress_percentage = avg_progress
        course_progress.completed = course_completed
        course_progress.last_accessed = datetime.utcnow()
    else:
        course_progress = UserProgress(
            user_id=user_id,
            course_id=course_id,
            lesson_id=None,  # Course-level progress
            progress_percentage=avg_progress,
            completed=course_completed,
            last_accessed=datetime.utcnow()
        )
        db.add(course_progress)

    db.commit()

    # Also update enrollment progress for consistency
    enrollment = db.query(Enrollment).filter(
        Enrollment.student_id == user_id,
        Enrollment.course_id == course_id
    ).first()

    if enrollment:
        enrollment.progress = avg_progress
        if course_completed:
            enrollment.completed_at = datetime.utcnow()
        db.commit()

@router.get("/overall")
def get_overall_progress(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    """
    Get overall user progress across all courses
    """
    # Get total lessons completed
    completed_lessons = db.query(UserProgress).filter(
        UserProgress.user_id == current_user.id,
        UserProgress.completed == True,
        UserProgress.lesson_id.isnot(None)
    ).count()

    # Get total lessons available
    total_lessons = db.query(Lesson).join(Course).filter(
        Course.teacher_id.isnot(None)  # Only courses with assigned teachers
    ).count()

    # Get total time spent
    time_spent_result = db.query(func.sum(UserProgress.time_spent_minutes)).filter(
        UserProgress.user_id == current_user.id
    ).scalar()
    time_spent_minutes = time_spent_result or 0

    # Calculate overall progress percentage
    overall_progress = (completed_lessons / total_lessons * 100) if total_lessons > 0 else 0.0

    return {
        "overall_progress": overall_progress,
        "completed_lessons": completed_lessons,
        "total_lessons": total_lessons,
        "time_spent_minutes": time_spent_minutes
    }

@router.get("/detailed")
def get_detailed_progress(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    """
    Get detailed progress information including analytics
    """
    # Lesson progress
    lesson_progress = db.query(UserProgress).filter(
        UserProgress.user_id == current_user.id,
        UserProgress.lesson_id.isnot(None)
    ).order_by(desc(UserProgress.last_accessed)).all()

    lesson_progress_data = []
    for progress in lesson_progress:
        lesson = db.query(Lesson).filter(Lesson.id == progress.lesson_id).first()
        course = db.query(Course).filter(Course.id == progress.course_id).first()
        if lesson and course:
            lesson_progress_data.append({
                "course_id": progress.course_id,
                "course_title": course.title,
                "lesson_id": progress.lesson_id,
                "lesson_title": lesson.title,
                "progress_percentage": progress.progress_percentage,
                "completed": progress.completed,
                "time_spent_minutes": progress.time_spent_minutes,
                "last_accessed": progress.last_accessed.isoformat() if progress.last_accessed else None
            })

    # Course progress
    course_progress = db.query(UserProgress).filter(
        UserProgress.user_id == current_user.id,
        UserProgress.lesson_id.is_(None)
    ).all()

    course_progress_data = []
    for progress in course_progress:
        course = db.query(Course).filter(Course.id == progress.course_id).first()
        if course:
            course_progress_data.append({
                "course_id": progress.course_id,
                "course_title": course.title,
                "progress_percentage": progress.progress_percentage,
                "completed": progress.completed,
                "time_spent_minutes": progress.time_spent_minutes,
                "last_accessed": progress.last_accessed.isoformat() if progress.last_accessed else None
            })

    # Weekly progress (last 7 days)
    week_ago = datetime.utcnow() - timedelta(days=7)
    weekly_progress = db.query(
        func.sum(UserProgress.time_spent_minutes).label('time_spent'),
        func.count(UserProgress.id).filter(UserProgress.completed == True).label('lessons_completed')
    ).filter(
        UserProgress.user_id == current_user.id,
        UserProgress.last_accessed >= week_ago
    ).first()

    weekly_data = {
        "time_spent_minutes": weekly_progress.time_spent or 0,
        "lessons_completed": weekly_progress.lessons_completed or 0,
        "streak_maintained": True  # Placeholder - would need streak logic
    }

    # Monthly progress (last 30 days)
    month_ago = datetime.utcnow() - timedelta(days=30)
    monthly_progress = db.query(
        func.sum(UserProgress.time_spent_minutes).label('time_spent'),
        func.count(UserProgress.id).filter(UserProgress.completed == True).label('lessons_completed')
    ).filter(
        UserProgress.user_id == current_user.id,
        UserProgress.last_accessed >= month_ago
    ).first()

    monthly_data = {
        "time_spent_minutes": monthly_progress.time_spent or 0,
        "lessons_completed": monthly_progress.lessons_completed or 0
    }

    # Learning analytics (placeholder)
    analytics = {
        "average_session_time": 25,  # minutes
        "most_productive_day": "Monday",
        "preferred_content_type": "video",
        "consistency_score": 85
    }

    # Learning patterns (placeholder)
    patterns = [
        {"pattern": "Morning learner", "description": "Most active between 8-10 AM"},
        {"pattern": "Video preference", "description": "85% of content consumed is video"}
    ]

    # Strength and improvement areas (placeholder)
    strengths = ["Mathematics", "Problem Solving"]
    improvements = ["Time Management", "Practice Sessions"]

    return {
        "lesson_progress": lesson_progress_data,
        "course_progress": course_progress_data,
        "weekly_progress": weekly_data,
        "monthly_progress": monthly_data,
        "analytics": analytics,
        "patterns": patterns,
        "strengths": strengths,
        "improvements": improvements
    }

@router.get("/skills")
def get_skill_progress(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    """
    Get progress grouped by skills/categories
    """
    # Get all categories
    categories = db.query(Category).all()
    category_progress = []

    for category in categories:
        # Get courses in this category (assuming courses have category_id)
        courses_in_category = db.query(Course).filter(Course.category_id == category.id).all()
        course_ids = [c.id for c in courses_in_category]

        if course_ids:
            # Get progress for courses in this category
            progress_in_category = db.query(UserProgress).filter(
                UserProgress.user_id == current_user.id,
                UserProgress.course_id.in_(course_ids)
            ).all()

            total_lessons = sum(len(db.query(Lesson).filter(Lesson.course_id == cid).all()) for cid in course_ids)
            completed_lessons = sum(1 for p in progress_in_category if p.completed and p.lesson_id is not None)

            progress_percentage = (completed_lessons / total_lessons * 100) if total_lessons > 0 else 0.0

            category_progress.append({
                "id": category.id,
                "name": category.name,
                "progress": progress_percentage,
                "completed": completed_lessons,
                "total": total_lessons
            })

    # For now, return categories as skills
    return {
        "skills": category_progress,
        "categories": category_progress
    }

@router.get("/gamification")
def get_gamification_data(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    """
    Get gamification data including streaks, points, badges
    """
    # Current streak (placeholder - would need proper streak calculation)
    current_streak = 5  # Placeholder

    # Longest streak
    longest_streak = 12  # Placeholder

    # Total points (using gyan_coins)
    total_points = current_user.gyan_coins

    # Total badges (placeholder)
    total_badges = 8  # Placeholder

    # Recent achievements (placeholder)
    recent_achievements = [
        {"id": 1, "name": "First Lesson Completed", "earned_date": "2024-01-15", "points": 10},
        {"id": 2, "name": "Week Streak", "earned_date": "2024-01-20", "points": 50}
    ]

    # Badges (placeholder)
    badges = [
        {"id": 1, "name": "Beginner", "description": "Complete first lesson", "earned": True},
        {"id": 2, "name": "Consistent", "description": "7 day streak", "earned": True},
        {"id": 3, "name": "Scholar", "description": "Complete 10 lessons", "earned": False}
    ]

    return {
        "current_streak": current_streak,
        "longest_streak": longest_streak,
        "total_points": total_points,
        "total_badges": total_badges,
        "recent_achievements": recent_achievements,
        "badges": badges
    }

@router.post("/streak")
def update_streak(learning_activity: bool, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    """
    Update user's learning streak
    """
    # Placeholder implementation - would need proper streak tracking
    return {"message": "Streak updated", "current_streak": 5}
