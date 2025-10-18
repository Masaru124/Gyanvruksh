from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from ..database import get_db
from ..models.user import User
from ..models.course import Course
from ..models.enrollment import Enrollment
from ..models.lesson import Lesson
from ..models.progress import UserProgress
from ..services.deps import get_current_user
from typing import List, Dict, Any
from datetime import datetime, timedelta

router = APIRouter(prefix="/api/dashboard", tags=["dashboard"])

@router.get("/student/stats")
def get_student_dashboard_stats(db: Session = Depends(get_db), user: User = Depends(get_current_user)):
    """Get dashboard statistics for students"""
    if user.role != "service_seeker" or user.sub_role != "student":
        raise HTTPException(status_code=403, detail="Only students can view student dashboard stats")

    # Get enrolled courses count
    enrolled_courses_count = db.query(Enrollment).filter(Enrollment.student_id == user.id).count()
    
    # Get completed courses count (assuming completion is tracked in progress)
    completed_courses = db.query(UserProgress).filter(
        UserProgress.user_id == user.id,
        UserProgress.progress_percentage >= 100
    ).count()
    
    # Get total study hours (sum of time spent)
    total_study_hours = db.query(UserProgress).filter(
        UserProgress.user_id == user.id
    ).with_entities(UserProgress.time_spent_minutes).all()
    
    total_minutes = sum([p.time_spent_minutes or 0 for p in total_study_hours])
    total_hours = total_minutes // 60
    
    # Get current streak (simplified - days with activity in last 30 days)
    thirty_days_ago = datetime.utcnow() - timedelta(days=30)
    recent_activity = db.query(UserProgress).filter(
        UserProgress.user_id == user.id,
        UserProgress.last_accessed >= thirty_days_ago
    ).count()
    
    current_streak = min(recent_activity, 30)  # Cap at 30 days
    
    return {
        "enrolled_courses": enrolled_courses_count,
        "completed_courses": completed_courses,
        "total_study_hours": total_hours,
        "current_streak": current_streak,
        "gyan_coins": user.gyan_coins,
        "achievements_count": 0,  # TODO: Implement achievements system
        "rank": "Beginner"  # TODO: Implement ranking system
    }

@router.get("/student/recent-courses")
def get_recent_courses(db: Session = Depends(get_db), user: User = Depends(get_current_user)):
    """Get recently accessed courses for student"""
    if user.role != "service_seeker" or user.sub_role != "student":
        raise HTTPException(status_code=403, detail="Only students can view recent courses")

    # Get courses with recent progress
    recent_progress = db.query(UserProgress).filter(
        UserProgress.user_id == user.id
    ).order_by(UserProgress.last_accessed.desc()).limit(5).all()
    
    recent_courses = []
    for progress in recent_progress:
        if progress.course_id:
            course = db.query(Course).filter(Course.id == progress.course_id).first()
            if course:
                recent_courses.append({
                    "id": course.id,
                    "title": course.title,
                    "description": course.description,
                    "progress_percentage": progress.progress_percentage,
                    "last_accessed": progress.last_accessed.isoformat() if progress.last_accessed else None,
                    "time_spent_minutes": progress.time_spent_minutes
                })
    
    return recent_courses

@router.get("/teacher/dashboard-stats")
def get_teacher_dashboard_stats(db: Session = Depends(get_db), user: User = Depends(get_current_user)):
    """Get comprehensive dashboard statistics for teachers"""
    if not user.is_teacher and user.role != "service_provider":
        raise HTTPException(status_code=403, detail="Only teachers can view teacher dashboard stats")

    # Get teacher's courses
    teacher_courses = db.query(Course).filter(Course.teacher_id == user.id).all()
    course_ids = [c.id for c in teacher_courses]
    
    # Total students across all courses
    total_students = db.query(Enrollment).filter(Enrollment.course_id.in_(course_ids)).count() if course_ids else 0
    
    # Active students (with recent activity in last 7 days)
    week_ago = datetime.utcnow() - timedelta(days=7)
    active_students = db.query(UserProgress).filter(
        UserProgress.course_id.in_(course_ids),
        UserProgress.last_accessed >= week_ago
    ).distinct(UserProgress.user_id).count() if course_ids else 0
    
    # Average completion rate
    if course_ids:
        all_progress = db.query(UserProgress).filter(UserProgress.course_id.in_(course_ids)).all()
        avg_completion = sum([p.progress_percentage for p in all_progress]) / len(all_progress) if all_progress else 0
    else:
        avg_completion = 0
    
    # Total lessons created
    total_lessons = db.query(Lesson).filter(Lesson.course_id.in_(course_ids)).count() if course_ids else 0
    
    return {
        "total_courses": len(teacher_courses),
        "total_students": total_students,
        "active_students": active_students,
        "average_completion_rate": round(avg_completion, 1),
        "total_lessons": total_lessons,
        "engagement_score": min(100, (active_students / max(total_students, 1)) * 100) if total_students > 0 else 0
    }

@router.get("/recommendations")
def get_recommendations(db: Session = Depends(get_db), user: User = Depends(get_current_user)):
    """Get personalized course recommendations"""
    
    # Get user's enrolled courses to understand preferences
    if user.role == "service_seeker" and user.sub_role == "student":
        enrolled_course_ids = [e.course_id for e in db.query(Enrollment).filter(Enrollment.student_id == user.id).all()]
        
        # Get courses not enrolled in
        available_courses = db.query(Course).filter(
            ~Course.id.in_(enrolled_course_ids),
            Course.teacher_id.isnot(None)
        ).limit(5).all()
        
        recommendations = []
        for course in available_courses:
            teacher = db.query(User).filter(User.id == course.teacher_id).first()
            enrolled_count = db.query(Enrollment).filter(Enrollment.course_id == course.id).count()
            
            recommendations.append({
                "id": course.id,
                "title": course.title,
                "description": course.description,
                "teacher_name": teacher.full_name if teacher else "Unknown",
                "enrolled_students": enrolled_count,
                "total_hours": course.total_hours,
                "recommendation_reason": "Popular course in your area of interest"
            })
        
        return recommendations
    
    return []

@router.get("/notifications")
def get_notifications(db: Session = Depends(get_db), user: User = Depends(get_current_user)):
    """Get user notifications"""
    
    notifications = []
    
    if user.role == "service_seeker" and user.sub_role == "student":
        # Check for new courses
        recent_courses = db.query(Course).filter(
            Course.created_at >= datetime.utcnow() - timedelta(days=7),
            Course.teacher_id.isnot(None)
        ).limit(3).all()
        
        for course in recent_courses:
            notifications.append({
                "id": f"new_course_{course.id}",
                "type": "new_course",
                "title": "New Course Available",
                "message": f"Check out the new course: {course.title}",
                "created_at": course.created_at.isoformat(),
                "action_url": f"/courses/{course.id}"
            })
    
    elif user.is_teacher or user.role == "service_provider":
        # Check for new enrollments
        teacher_courses = db.query(Course).filter(Course.teacher_id == user.id).all()
        course_ids = [c.id for c in teacher_courses]
        
        if course_ids:
            recent_enrollments = db.query(Enrollment).filter(
                Enrollment.course_id.in_(course_ids),
                Enrollment.enrolled_at >= datetime.utcnow() - timedelta(days=7)
            ).limit(5).all()
            
            for enrollment in recent_enrollments:
                student = db.query(User).filter(User.id == enrollment.student_id).first()
                course = db.query(Course).filter(Course.id == enrollment.course_id).first()
                
                notifications.append({
                    "id": f"new_enrollment_{enrollment.id}",
                    "type": "new_enrollment",
                    "title": "New Student Enrolled",
                    "message": f"{student.full_name if student else 'A student'} enrolled in {course.title if course else 'your course'}",
                    "created_at": enrollment.enrolled_at.isoformat(),
                    "action_url": f"/courses/{enrollment.course_id}"
                })
    
    return notifications[:10]  # Limit to 10 notifications

@router.get("/recommendations")
def get_dashboard_recommendations(db: Session = Depends(get_db), user: User = Depends(get_current_user)):
    """Get personalized recommendations for the dashboard"""
    if user.role != "service_seeker" or user.sub_role != "student":
        raise HTTPException(status_code=403, detail="Only students can get recommendations")

    # Use the AI recommendations system we implemented
    from ..api.gyanvruksh import _get_hybrid_recommendations

    recommendations = _get_hybrid_recommendations(user.id, db)

    # Format for dashboard display
    dashboard_recommendations = []
    for rec in recommendations[:5]:  # Limit to 5 for dashboard
        course = db.query(Course).filter(Course.id == rec["course_id"]).first()
        if course:
            dashboard_recommendations.append({
                "course_id": rec["course_id"],
                "title": rec["title"],
                "description": rec["description"],
                "difficulty": rec["difficulty"],
                "recommendation_score": rec["recommendation_score"],
                "reason": rec["reason"],
                "thumbnail_url": course.thumbnail_url,
                "total_hours": course.total_hours
            })

    return dashboard_recommendations

@router.get("/notifications")
def get_dashboard_notifications(db: Session = Depends(get_db), user: User = Depends(get_current_user)):
    """Get recent notifications for the dashboard"""
    # Get recent notifications for the user
    notifications = db.query(Notification).filter(
        Notification.user_id == user.id
    ).order_by(Notification.created_at.desc()).limit(5).all()

    dashboard_notifications = []
    for notification in notifications:
        dashboard_notifications.append({
            "id": notification.id,
            "title": notification.title,
            "message": notification.message,
            "type": notification.notification_type,
            "is_read": notification.is_read,
            "created_at": notification.created_at.isoformat()
        })

    return dashboard_notifications
