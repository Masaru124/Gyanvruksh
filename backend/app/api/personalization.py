from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List, Dict, Optional
from app.database import get_db
from app.models.user import User
from app.models.course import Course
from app.models.enrollment import Enrollment
from app.models.progress import UserProgress
from app.models.lesson import Lesson
from app.models.category import Category
from app.services.deps import get_current_user
from pydantic import BaseModel
from datetime import datetime, timedelta

router = APIRouter(prefix="/api/personalization", tags=["personalization"])

class LearningStyleRequest(BaseModel):
    preferred_content_type: str  # video, text, interactive, audio
    study_time_preference: str   # morning, afternoon, evening, night
    learning_pace: str          # slow, medium, fast
    interaction_style: str      # visual, auditory, kinesthetic, reading

class StudyPlanRequest(BaseModel):
    target_course_ids: List[int]
    daily_study_hours: int
    target_completion_date: datetime
    break_intervals: int  # minutes between study sessions

class AdaptiveDifficultyRequest(BaseModel):
    content_id: int
    current_performance: float  # 0-100
    time_taken: int  # minutes
    difficulty_feedback: str   # too_easy, just_right, too_hard

@router.get("/analytics")
def get_personalization_analytics(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Get user's personalization analytics and insights"""
    # Get user's learning patterns
    progress_records = db.query(UserProgress).filter(
        UserProgress.user_id == current_user.id,
        UserProgress.last_accessed >= datetime.utcnow() - timedelta(days=30)
    ).all()

    # Time-based analysis
    hourly_activity = {}
    daily_activity = {}
    content_type_preferences = {}

    for progress in progress_records:
        if progress.last_accessed:
            hour = progress.last_accessed.hour
            hourly_activity[hour] = hourly_activity.get(hour, 0) + 1

            day = progress.last_accessed.strftime("%A")
            daily_activity[day] = daily_activity.get(day, 0) + 1

    # Content type preferences (mock data - would need content_type field)
    content_type_preferences = {
        "video": 45,
        "text": 30,
        "interactive": 15,
        "audio": 10
    }

    # Performance metrics
    total_lessons = len(progress_records)
    completed_lessons = len([p for p in progress_records if p.completed])
    avg_progress = sum(p.progress_percentage for p in progress_records) / total_lessons if total_lessons > 0 else 0

    # Learning consistency
    consistency_score = 85  # Mock calculation

    # Strengths and weaknesses (mock data)
    category_performance = {}
    categories = db.query(Category).all()
    for category in categories:
        courses_in_category = db.query(Course).filter(Course.category_id == category.id).all()
        if courses_in_category:
            course_ids = [c.id for c in courses_in_category]
            category_progress = db.query(UserProgress).filter(
                UserProgress.user_id == current_user.id,
                UserProgress.course_id.in_(course_ids)
            ).all()

            if category_progress:
                avg_category_progress = sum(p.progress_percentage for p in category_progress) / len(category_progress)
                category_performance[category.name] = avg_category_progress

    strengths = [name for name, score in list(category_performance.items())[:2] if score > 70]
    improvements = [name for name, score in list(category_performance.items())[-2:] if score < 50]

    return {
        "learning_patterns": {
            "hourly_activity": hourly_activity,
            "daily_activity": daily_activity,
            "content_type_preferences": content_type_preferences,
            "most_productive_hour": max(hourly_activity.items(), key=lambda x: x[1])[0] if hourly_activity else 10,
            "average_session_time": 25  # minutes
        },
        "performance_metrics": {
            "total_lessons": total_lessons,
            "completed_lessons": completed_lessons,
            "average_progress": avg_progress,
            "consistency_score": consistency_score
        },
        "category_performance": category_performance,
        "strengths": strengths,
        "improvements": improvements,
        "recommendations": [
            "Focus on improving in areas with low performance",
            "Study during your most productive hours",
            "Take regular breaks to maintain focus"
        ]
    }

@router.get("/recommendations")
def get_personalized_recommendations(
    limit: int = 10,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Get personalized course recommendations"""
    # Get user's enrolled courses and progress
    enrollments = db.query(Enrollment).filter(Enrollment.student_id == current_user.id).all()

    if not enrollments:
        # New user - recommend popular courses
        recommended_courses = db.query(Course).filter(
            Course.is_published == True
        ).order_by(Course.rating.desc(), Course.enrollment_count.desc()).limit(limit).all()
    else:
        # Existing user - personalized recommendations based on:
        # 1. Categories of completed courses
        # 2. Performance in different categories
        # 3. Learning style preferences

        enrolled_course_ids = [e.course_id for e in enrollments]
        enrolled_courses = db.query(Course).filter(Course.id.in_(enrolled_course_ids)).all()

        # Get categories from enrolled courses
        category_ids = list(set([c.category_id for c in enrolled_courses if c.category_id]))

        # Recommend courses from similar categories
        recommended_courses = db.query(Course).filter(
            Course.is_published == True,
            Course.id.notin_(enrolled_course_ids)
        )

        if category_ids:
            recommended_courses = recommended_courses.filter(
                Course.category_id.in_(category_ids)
            )

        recommended_courses = recommended_courses.order_by(
            Course.rating.desc(),
            Course.enrollment_count.desc()
        ).limit(limit).all()

    # Format recommendations
    recommendations = []
    for course in recommended_courses:
        # Calculate recommendation score (mock logic)
        recommendation_score = (course.rating * 0.4 + course.enrollment_count * 0.6) / 10

        recommendations.append({
            "id": course.id,
            "title": course.title,
            "description": course.description,
            "difficulty": course.difficulty,
            "rating": course.rating,
            "enrollment_count": course.enrollment_count,
            "total_hours": course.total_hours,
            "thumbnail_url": course.thumbnail_url,
            "teacher_name": course.teacher.full_name if course.teacher else "Admin",
            "category": course.category.name if course.category else None,
            "recommendation_score": recommendation_score,
            "reason": "Similar to your interests" if course.category_id in category_ids else "Popular choice"
        })

    return {
        "recommendations": recommendations,
        "total_recommendations": len(recommendations),
        "based_on": "course_history" if enrollments else "popularity"
    }

@router.post("/track")
def track_learning_activity(
    activity_type: str,  # lesson_view, quiz_attempt, assignment_submit, etc.
    content_id: int,
    time_spent: int,  # minutes
    metadata: Optional[Dict] = None,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Track user's learning activity for personalization"""
    # In a real implementation, this would create activity tracking records
    # For now, just update last accessed time on relevant progress records

    if activity_type == "lesson_view":
        progress = db.query(UserProgress).filter(
            UserProgress.user_id == current_user.id,
            UserProgress.lesson_id == content_id
        ).first()

        if progress:
            progress.last_accessed = datetime.utcnow()
            progress.time_spent_minutes = (progress.time_spent_minutes or 0) + time_spent
            db.commit()

    return {
        "message": "Activity tracked successfully",
        "activity_type": activity_type,
        "content_id": content_id,
        "time_spent": time_spent,
        "tracked_at": datetime.utcnow().isoformat()
    }

@router.post("/study-plan")
def generate_personalized_study_plan(
    request: StudyPlanRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Generate personalized study plan"""
    # Verify user has access to the target courses
    for course_id in request.target_course_ids:
        enrollment = db.query(Enrollment).filter(
            Enrollment.student_id == current_user.id,
            Enrollment.course_id == course_id
        ).first()

        if not enrollment:
            raise HTTPException(
                status_code=403,
                detail=f"You must be enrolled in course {course_id} to include it in study plan"
            )

    # Calculate total study hours needed
    total_hours = 0
    courses_data = []

    for course_id in request.target_course_ids:
        course = db.query(Course).filter(Course.id == course_id).first()
        if course:
            enrollment = db.query(Enrollment).filter(
                Enrollment.student_id == current_user.id,
                Enrollment.course_id == course_id
            ).first()

            remaining_hours = (course.total_hours or 40) - (enrollment.hours_completed or 0)
            total_hours += remaining_hours

            courses_data.append({
                "course_id": course.id,
                "course_title": course.title,
                "remaining_hours": remaining_hours,
                "current_progress": enrollment.progress if enrollment else 0
            })

    # Calculate study plan
    days_available = (request.target_completion_date.date() - datetime.now().date()).days

    if days_available <= 0:
        raise HTTPException(status_code=400, detail="Target date must be in the future")

    hours_per_day = total_hours / days_available
    adjusted_hours_per_day = min(request.daily_study_hours, hours_per_day)

    # Generate weekly schedule
    study_plan = {
        "target_courses": courses_data,
        "total_hours_needed": total_hours,
        "days_available": days_available,
        "recommended_daily_hours": adjusted_hours_per_day,
        "target_completion_date": request.target_completion_date.isoformat(),
        "weekly_schedule": []
    }

    # Generate 4 weeks of schedule
    current_date = datetime.now().date()
    for week in range(4):
        week_start = current_date + timedelta(weeks=week)
        week_schedule = {
            "week": week + 1,
            "start_date": week_start.isoformat(),
            "daily_sessions": []
        }

        for day in range(7):
            day_date = week_start + timedelta(days=day)
            if day_date <= request.target_completion_date.date():
                # Determine which course to study based on priority
                primary_course = courses_data[week % len(courses_data)]

                week_schedule["daily_sessions"].append({
                    "date": day_date.isoformat(),
                    "day_name": day_date.strftime("%A"),
                    "study_hours": adjusted_hours_per_day,
                    "primary_course": {
                        "id": primary_course["course_id"],
                        "title": primary_course["course_title"]
                    },
                    "break_intervals": request.break_intervals,
                    "focus_topics": ["Core concepts", "Practice exercises"]
                })

        study_plan["weekly_schedule"].append(week_schedule)

    return study_plan

@router.post("/learning-style")
def update_learning_style(
    learning_style: LearningStyleRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Update user's learning style preferences"""
    # In a real implementation, this would update a user preferences table
    # For now, just return the preferences

    return {
        "message": "Learning style updated successfully",
        "learning_style": learning_style.model_dump(),
        "updated_at": datetime.utcnow().isoformat(),
        "recommendations": [
            f"Content will be prioritized in {learning_style.preferred_content_type} format",
            f"Study reminders scheduled for {learning_style.study_time_preference}",
            f"Learning pace adjusted to {learning_style.learning_pace}",
            f"Content adapted for {learning_style.interaction_style} learning style"
        ]
    }

@router.post("/adaptive-difficulty/{content_id}")
def adjust_adaptive_difficulty(
    content_id: int,
    request: AdaptiveDifficultyRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Adjust difficulty based on user performance"""
    # In a real implementation, this would update content difficulty recommendations
    # For now, return adaptive suggestions

    performance = request.current_performance
    time_taken = request.time_taken
    feedback = request.difficulty_feedback

    # Calculate new difficulty recommendation
    if feedback == "too_easy":
        new_difficulty = "increase"
        suggestion = "Try more challenging content or increase study pace"
    elif feedback == "too_hard":
        new_difficulty = "decrease"
        suggestion = "Review prerequisite concepts or take more time"
    else:
        new_difficulty = "maintain"
        suggestion = "Continue with current difficulty level"

    # Mock adaptive content suggestions
    adaptive_suggestions = {
        "next_content": [
            {"id": content_id + 1, "title": "Advanced Topic", "difficulty": "medium"},
            {"id": content_id + 2, "title": "Practice Session", "difficulty": "easy"}
        ],
        "review_content": [
            {"id": content_id - 1, "title": "Prerequisite Review", "difficulty": "easy"}
        ] if feedback == "too_hard" else []
    }

    return {
        "content_id": content_id,
        "current_performance": performance,
        "time_taken": time_taken,
        "difficulty_feedback": feedback,
        "recommended_action": new_difficulty,
        "suggestion": suggestion,
        "adaptive_suggestions": adaptive_suggestions,
        "adjusted_at": datetime.utcnow().isoformat()
    }

@router.get("/pacing")
def get_personalized_pacing(
    course_id: Optional[int] = None,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Get personalized learning pace recommendations"""
    # Calculate user's learning pace based on past performance
    progress_records = db.query(UserProgress).filter(
        UserProgress.user_id == current_user.id,
        UserProgress.last_accessed >= datetime.utcnow() - timedelta(days=30)
    ).all()

    if not progress_records:
        return {
            "recommended_pace": "medium",
            "daily_study_time": 60,  # minutes
            "session_frequency": "daily",
            "break_intervals": 15,   # minutes
            "reasoning": "Based on new user status"
        }

    # Calculate average time per lesson
    total_time = sum(p.time_spent_minutes or 0 for p in progress_records)
    total_lessons = len(progress_records)
    avg_time_per_lesson = total_time / total_lessons if total_lessons > 0 else 25

    # Calculate completion rate
    completed_lessons = len([p for p in progress_records if p.completed])
    completion_rate = completed_lessons / total_lessons if total_lessons > 0 else 0

    # Determine pace based on performance
    if completion_rate > 0.8 and avg_time_per_lesson < 20:
        recommended_pace = "fast"
        daily_time = 90
    elif completion_rate < 0.5 or avg_time_per_lesson > 40:
        recommended_pace = "slow"
        daily_time = 30
    else:
        recommended_pace = "medium"
        daily_time = 60

    # Adjust based on user's historical preferences (mock)
    session_frequency = "daily"  # Could be based on consistency patterns
    break_intervals = 15 if recommended_pace == "fast" else 10

    return {
        "recommended_pace": recommended_pace,
        "daily_study_time": daily_time,
        "session_frequency": session_frequency,
        "break_intervals": break_intervals,
        "performance_metrics": {
            "average_time_per_lesson": avg_time_per_lesson,
            "completion_rate": completion_rate,
            "total_lessons_studied": total_lessons,
            "total_time_studied": total_time
        },
        "reasoning": f"Based on your {completion_rate:.1%} completion rate and {avg_time_per_lesson:.1f}min average per lesson"
    }
