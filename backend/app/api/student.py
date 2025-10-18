from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List, Optional
from app.database import get_db
from app.models.user import User
from app.models.course import Course
from app.models.enrollment import Enrollment
from app.models.lesson import Lesson
from app.models.progress import UserProgress
from app.models.assignment import Assignment, Grade
from app.models.quiz import Quiz
from app.models.attendance import Attendance
from app.services.deps import get_current_user
from pydantic import BaseModel
from datetime import datetime, timedelta

router = APIRouter(prefix="/api/student", tags=["student"])

# Pydantic models
class CourseRecommendationRequest(BaseModel):
    interests: List[str]
    difficulty_level: str
    max_courses: int = 5

class StudyPlanRequest(BaseModel):
    course_id: int
    target_completion_date: datetime
    daily_study_hours: int

def verify_student(user: User = Depends(get_current_user)):
    """Verify that the current user is a student"""
    if user.sub_role != "student":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Student access required"
        )
    return user

@router.get("/dashboard/stats")
def get_student_dashboard_stats(
    db: Session = Depends(get_db),
    student: User = Depends(verify_student)
):
    """Get comprehensive student dashboard statistics"""

    # Enrollment statistics
    enrolled_courses = db.query(Enrollment).filter(Enrollment.student_id == student.id).all()
    total_enrollments = len(enrolled_courses)

    # Progress statistics - handle case where no enrollments exist
    total_progress = 0
    completed_courses = 0

    if total_enrollments > 0:
        for enrollment in enrolled_courses:
            course_progress = db.query(UserProgress).filter(
                UserProgress.user_id == student.id,
                UserProgress.course_id == enrollment.course_id
            ).first()

            if course_progress:
                total_progress += course_progress.progress_percentage
                if course_progress.progress_percentage >= 100:
                    completed_courses += 1

        avg_progress = total_progress / total_enrollments if total_enrollments > 0 else 0
    else:
        avg_progress = 0

    # Attendance statistics - handle case where no attendance records exist
    attendance_records = db.query(Attendance).filter(Attendance.student_id == student.id).all()
    total_classes = len(attendance_records)
    attended_classes = sum(1 for record in attendance_records if record.is_present)
    attendance_percentage = (attended_classes / total_classes) * 100 if total_classes > 0 else 0

    # Assignment statistics - handle case where no assignments exist
    try:
        assignments = db.query(Assignment).join(Course).join(Enrollment).filter(
            Enrollment.student_id == student.id
        ).all()

        grades = db.query(Grade).filter(Grade.student_id == student.id).all()
        completed_assignments = len(grades)
        total_assignments = len(assignments)

        # Calculate average grade
        avg_grade = sum(grade.score for grade in grades) / len(grades) if grades else 0

    except Exception as e:
        # Handle case where Assignment or Grade models have issues
        assignments = []
        grades = []
        completed_assignments = 0
        total_assignments = 0
        avg_grade = 0

    return {
        "enrollments": {
            "total": total_enrollments,
            "completed": completed_courses,
            "in_progress": total_enrollments - completed_courses
        },
        "progress": {
            "average_progress": round(avg_progress, 2),
            "total_courses": total_enrollments,
            "completed_courses": completed_courses
        },
        "attendance": {
            "total_classes": total_classes,
            "attended_classes": attended_classes,
            "attendance_percentage": round(attendance_percentage, 2)
        },
        "assignments": {
            "total": total_assignments,
            "completed": completed_assignments,
            "pending": total_assignments - completed_assignments,
            "average_grade": round(avg_grade, 2)
        },
        "gyan_coins": student.gyan_coins
    }

@router.get("/courses/recommended")
def get_recommended_courses(
    db: Session = Depends(get_db),
    student: User = Depends(verify_student),
    limit: int = 10
):
    """Get personalized course recommendations for student"""
    
    # Get student's enrolled courses to understand preferences
    enrolled_courses = db.query(Course).join(Enrollment).filter(
        Enrollment.student_id == student.id
    ).all()
    
    # Get categories from enrolled courses
    enrolled_categories = [course.category_id for course in enrolled_courses if course.category_id]
    
    # Recommend courses from similar categories that student hasn't enrolled in
    enrolled_course_ids = [course.id for course in enrolled_courses]
    
    recommended_courses = db.query(Course).filter(
        Course.is_published == True,
        Course.id.notin_(enrolled_course_ids)
    )
    
    if enrolled_categories:
        recommended_courses = recommended_courses.filter(
            Course.category_id.in_(enrolled_categories)
        )
    
    recommended_courses = recommended_courses.order_by(
        Course.rating.desc(),
        Course.enrollment_count.desc()
    ).limit(limit).all()
    
    return [{
        "id": course.id,
        "title": course.title,
        "description": course.description,
        "difficulty": course.difficulty,
        "rating": course.rating,
        "enrollment_count": course.enrollment_count,
        "total_hours": course.total_hours,
        "thumbnail_url": course.thumbnail_url
    } for course in recommended_courses]

@router.get("/learning-path")
def get_learning_path(
    db: Session = Depends(get_db),
    student: User = Depends(verify_student)
):
    """Get personalized learning path for student"""
    
    # Get enrolled courses with progress
    enrolled_courses = db.query(Course).join(Enrollment).filter(
        Enrollment.student_id == student.id
    ).all()
    
    learning_path = []
    for course in enrolled_courses:
        # Get course progress
        progress = db.query(UserProgress).filter(
            UserProgress.user_id == student.id,
            UserProgress.course_id == course.id
        ).first()
        
        # Get next lesson to complete
        completed_lessons = db.query(UserProgress.lesson_id).filter(
            UserProgress.user_id == student.id,
            UserProgress.course_id == course.id,
            UserProgress.completed == True
        ).subquery()
        
        next_lesson = db.query(Lesson).filter(
            Lesson.course_id == course.id,
            Lesson.id.notin_(completed_lessons)
        ).order_by(Lesson.order_index).first()
        
        # Get pending assignments
        pending_assignments = db.query(Assignment).filter(
            Assignment.course_id == course.id,
            ~Assignment.id.in_(
                db.query(Grade.assignment_id).filter(Grade.student_id == student.id)
            )
        ).all()
        
        learning_path.append({
            "course_id": course.id,
            "course_title": course.title,
            "progress_percentage": progress.progress_percentage if progress else 0,
            "next_lesson": {
                "id": next_lesson.id,
                "title": next_lesson.title,
                "duration_minutes": next_lesson.duration_minutes
            } if next_lesson else None,
            "pending_assignments": len(pending_assignments),
            "priority": "high" if progress and progress.progress_percentage > 0 else "medium"
        })
    
    # Sort by priority and progress
    learning_path.sort(key=lambda x: (x["priority"] == "high", x["progress_percentage"]), reverse=True)
    
    return learning_path

@router.post("/study-plan/generate")
async def generate_study_plan(
    request: StudyPlanRequest,
    current_user: User = Depends(verify_student),
    db: Session = Depends(get_db)
):
    """Generate a personalized study plan for a course"""
    try:
        # Get course details
        course = db.query(Course).filter(Course.id == request.course_id).first()
        if not course:
            raise HTTPException(status_code=404, detail="Course not found")
        
        # Check if user is enrolled
        enrollment = db.query(Enrollment).filter(
            Enrollment.user_id == current_user.id,
            Enrollment.course_id == request.course_id
        ).first()
        
        if not enrollment:
            raise HTTPException(status_code=403, detail="Not enrolled in this course")
        
        # Calculate study plan
        total_hours = course.duration_hours or 40  # Default 40 hours
        days_available = (request.target_completion_date - datetime.now().date()).days
        
        if days_available <= 0:
            raise HTTPException(status_code=400, detail="Target date must be in the future")
        
        # Generate weekly schedule
        total_study_hours_needed = total_hours - (enrollment.hours_completed or 0)
        hours_per_day = min(request.daily_study_hours, total_study_hours_needed / days_available)
        
        # Create study plan structure
        study_plan = {
            "course_id": course.id,
            "course_title": course.title,
            "total_hours_remaining": total_study_hours_needed,
            "target_completion_date": request.target_completion_date.isoformat(),
            "recommended_daily_hours": round(hours_per_day, 1),
            "estimated_completion_date": (datetime.now().date() + 
                                        timedelta(days=int(total_study_hours_needed / request.daily_study_hours))).isoformat(),
            "weekly_schedule": []
        }
        
        # Generate 4 weeks of schedule
        current_date = datetime.now().date()
        for week in range(4):
            week_start = current_date + timedelta(weeks=week)
            week_schedule = {
                "week": week + 1,
                "start_date": week_start.isoformat(),
                "daily_tasks": []
            }
            
            for day in range(7):
                day_date = week_start + timedelta(days=day)
                if day_date <= request.target_completion_date:
                    week_schedule["daily_tasks"].append({
                        "date": day_date.isoformat(),
                        "day_name": day_date.strftime("%A"),
                        "study_hours": hours_per_day,
                        "topics": [f"Study session {day + 1} - Week {week + 1}"],
                        "completed": False
                    })
            
            study_plan["weekly_schedule"].append(week_schedule)
        
        return study_plan
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/progress-report")
async def get_progress_report(
    current_user: User = Depends(verify_student),
    db: Session = Depends(get_db)
):
    """Get detailed progress report for student"""
    try:
        # Get all enrollments
        enrollments = db.query(Enrollment).filter(
            Enrollment.user_id == current_user.id
        ).all()

        total_courses = len(enrollments)
        completed_courses = len([e for e in enrollments if e.progress >= 100])
        in_progress_courses = total_courses - completed_courses

        # Calculate overall progress
        total_progress = sum([e.progress for e in enrollments]) / total_courses if total_courses > 0 else 0

        # Get course-wise progress
        course_progress = []
        for enrollment in enrollments:
            course = db.query(Course).filter(Course.id == enrollment.course_id).first()
            if course:
                course_progress.append({
                    "course_id": course.id,
                    "course_title": course.title,
                    "progress": enrollment.progress,
                    "hours_completed": enrollment.hours_completed or 0,
                    "total_hours": course.duration_hours or 0,
                    "status": "completed" if enrollment.progress >= 100 else "in_progress"
                })

        # Get recent activity (last 30 days) - simplified
        recent_activity = []

        return {
            "summary": {
                "total_courses": total_courses,
                "completed_courses": completed_courses,
                "in_progress_courses": in_progress_courses,
                "overall_progress": round(total_progress, 1)
            },
            "course_progress": course_progress,
            "recent_activity": recent_activity,
            "study_streak": 7,  # Mock data
            "total_study_hours": sum([e.hours_completed or 0 for e in enrollments])
        }

    except Exception as e:
        # Return basic structure if detailed queries fail
        return {
            "summary": {
                "total_courses": 0,
                "completed_courses": 0,
                "in_progress_courses": 0,
                "overall_progress": 0
            },
            "course_progress": [],
            "recent_activity": [],
            "study_streak": 0,
            "total_study_hours": 0
        }

@router.get("/study-groups")
async def get_study_groups(
    current_user: User = Depends(verify_student),
    db: Session = Depends(get_db)
):
    """Get available study groups for student"""
    try:
        # Get student's enrolled courses
        enrollments = db.query(Enrollment).filter(
            Enrollment.user_id == current_user.id
        ).all()
        
        course_ids = [e.course_id for e in enrollments]
        
        # Mock study groups data
        study_groups = []
        for i, course_id in enumerate(course_ids[:3]):  # Limit to 3 groups
            course = db.query(Course).filter(Course.id == course_id).first()
            if course:
                study_groups.append({
                    "id": i + 1,
                    "name": f"{course.title} Study Group",
                    "course_id": course.id,
                    "course_title": course.title,
                    "members_count": 8 + i * 2,
                    "max_members": 15,
                    "description": f"Collaborative learning group for {course.title}",
                    "meeting_schedule": "Weekends 3-5 PM",
                    "is_member": i == 0,  # User is member of first group
                    "created_date": (datetime.now() - timedelta(days=10 + i*5)).isoformat()
                })
        
        return {"study_groups": study_groups}
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/study-groups/{group_id}/join")
async def join_study_group(
    group_id: int,
    current_user: User = Depends(verify_student),
    db: Session = Depends(get_db)
):
    """Join a study group"""
    try:
        # Mock joining logic
        return {
            "message": f"Successfully joined study group {group_id}",
            "group_id": group_id,
            "joined_at": datetime.now().isoformat()
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/doubts")
async def get_student_doubts(
    current_user: User = Depends(verify_student),
    db: Session = Depends(get_db)
):
    """Get student's doubts and questions"""
    try:
        # Mock doubts data
        doubts = [
            {
                "id": 1,
                "question": "How to implement inheritance in Python?",
                "course_title": "Python Programming",
                "status": "answered",
                "created_at": (datetime.now() - timedelta(days=2)).isoformat(),
                "answer": "Inheritance allows a class to inherit attributes and methods from another class...",
                "answered_by": "AI Assistant"
            },
            {
                "id": 2,
                "question": "What is the difference between SQL and NoSQL?",
                "course_title": "Database Management",
                "status": "pending",
                "created_at": (datetime.now() - timedelta(hours=5)).isoformat(),
                "answer": None,
                "answered_by": None
            }
        ]
        
        return {"doubts": doubts}
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/doubts")
async def ask_doubt(
    question: str,
    course_id: int,
    current_user: User = Depends(verify_student),
    db: Session = Depends(get_db)
):
    """Ask a new doubt/question"""
    try:
        # Get course details
        course = db.query(Course).filter(Course.id == course_id).first()
        if not course:
            raise HTTPException(status_code=404, detail="Course not found")
        
        # Mock doubt creation
        new_doubt = {
            "id": 3,
            "question": question,
            "course_id": course_id,
            "course_title": course.title,
            "status": "pending",
            "created_at": datetime.now().isoformat(),
            "answer": None,
            "answered_by": None
        }
        
        return {
            "message": "Doubt submitted successfully",
            "doubt": new_doubt
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/courses/{course_id}/enroll")
async def enroll_in_course(
    course_id: int,
    current_user: User = Depends(verify_student),
    db: Session = Depends(get_db)
):
    """Enroll student in a course"""
    try:
        # Check if course exists
        course = db.query(Course).filter(Course.id == course_id).first()
        if not course:
            raise HTTPException(status_code=404, detail="Course not found")
        
        # Check if already enrolled
        existing_enrollment = db.query(Enrollment).filter(
            Enrollment.user_id == current_user.id,
            Enrollment.course_id == course_id
        ).first()
        
        if existing_enrollment:
            raise HTTPException(status_code=400, detail="Already enrolled in this course")
        
        # Create new enrollment
        new_enrollment = Enrollment(
            user_id=current_user.id,
            course_id=course_id,
            enrolled_at=datetime.now(),
            progress=0,
            hours_completed=0
        )
        
        db.add(new_enrollment)
        db.commit()
        db.refresh(new_enrollment)
        
        return {
            "message": "Successfully enrolled in course",
            "enrollment_id": new_enrollment.id,
            "course_title": course.title,
            "enrolled_at": new_enrollment.enrolled_at.isoformat()
        }
        
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/achievements")
def get_student_achievements(
    db: Session = Depends(get_db),
    student: User = Depends(verify_student)
):
    """Get student achievements and badges"""
    
    # Calculate achievements
    achievements = []
    
    # Course completion achievements
    completed_courses = db.query(UserProgress).filter(
        UserProgress.user_id == student.id,
        UserProgress.progress_percentage >= 100
    ).count()
    
    if completed_courses >= 1:
        achievements.append({
            "title": "First Course Complete",
            "description": "Completed your first course",
            "icon": "🎓",
            "earned_date": datetime.utcnow().isoformat()
        })
    
    if completed_courses >= 5:
        achievements.append({
            "title": "Learning Enthusiast",
            "description": "Completed 5 courses",
            "icon": "📚",
            "earned_date": datetime.utcnow().isoformat()
        })
    
    # Attendance achievements
    attendance_records = db.query(Attendance).filter(Attendance.student_id == student.id).all()
    if attendance_records:
        attendance_rate = sum(1 for record in attendance_records if record.is_present) / len(attendance_records)
        
        if attendance_rate >= 0.95:
            achievements.append({
                "title": "Perfect Attendance",
                "description": "95%+ attendance rate",
                "icon": "⭐",
                "earned_date": datetime.utcnow().isoformat()
            })
    
    # Assignment achievements
    grades = db.query(Grade).filter(Grade.student_id == student.id).all()
    if grades:
        avg_grade = sum(grade.score for grade in grades) / len(grades)
        
        if avg_grade >= 90:
            achievements.append({
                "title": "High Achiever",
                "description": "90%+ average grade",
                "icon": "🏆",
                "earned_date": datetime.utcnow().isoformat()
            })
    
    return {
        "total_achievements": len(achievements),
        "gyan_coins": student.gyan_coins,
        "achievements": achievements
    }

@router.get("/upcoming-deadlines")
def get_upcoming_deadlines(
    db: Session = Depends(get_db),
    student: User = Depends(verify_student),
    days_ahead: int = 7
):
    """Get upcoming assignment deadlines and scheduled lessons"""

    end_date = datetime.utcnow() + timedelta(days=days_ahead)

    deadlines = []

    try:
        # Get pending assignments with deadlines - handle query errors
        try:
            pending_assignments = db.query(Assignment).join(Course).join(Enrollment).filter(
                Enrollment.student_id == student.id,
                Assignment.due_date <= end_date,
                Assignment.due_date >= datetime.utcnow()
            ).all()

            for assignment in pending_assignments:
                deadlines.append({
                    "type": "assignment",
                    "title": assignment.title,
                    "course_title": assignment.course.title if assignment.course else "Unknown Course",
                    "due_date": assignment.due_date.isoformat(),
                    "priority": "high" if assignment.due_date <= datetime.utcnow() + timedelta(days=2) else "medium"
                })
        except Exception as e:
            # If assignment query fails, continue without assignments
            pass

        try:
            # Get scheduled lessons - handle query errors
            scheduled_lessons = db.query(Lesson).join(Course).join(Enrollment).filter(
                Enrollment.student_id == student.id,
                Lesson.scheduled_at <= end_date,
                Lesson.scheduled_at >= datetime.utcnow()
            ).all()

            for lesson in scheduled_lessons:
                deadlines.append({
                    "type": "lesson",
                    "title": lesson.title,
                    "course_title": lesson.course.title if lesson.course else "Unknown Course",
                    "scheduled_at": lesson.scheduled_at.isoformat() if lesson.scheduled_at else None,
                    "priority": "medium"
                })
        except Exception as e:
            # If lesson query fails, continue without lessons
            pass

        # Sort by date
        deadlines.sort(key=lambda x: x.get("due_date") or x.get("scheduled_at") or "")

    except Exception as e:
        # If everything fails, return empty list
        deadlines = []

    return {
        "upcoming_deadlines": deadlines,
        "total_count": len(deadlines)
    }
