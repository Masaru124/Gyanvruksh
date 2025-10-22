from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from sqlalchemy import func
from datetime import datetime, timedelta
from typing import List, Optional

from ..database import get_db
from ..models.user import User
from ..models.course import Course
from ..models.enrollment import Enrollment
from ..models.attendance import Attendance, AttendanceSession
from .attendance import verify_teacher
from ..schemas.course import CourseCreate, CourseOut

router = APIRouter(prefix="/api/teacher", tags=["teacher"])

@router.get("/dashboard/stats")
async def get_teacher_dashboard_stats(
    current_user: User = Depends(verify_teacher),
    db: Session = Depends(get_db)
):
    """Get teacher dashboard statistics"""
    try:
        # Get teacher's courses
        courses = db.query(Course).filter(Course.teacher_id == current_user.id).all()
        course_ids = [course.id for course in courses]
        
        # Calculate stats
        total_courses = len(courses)
        published_courses = len([c for c in courses if c.is_published])
        
        # Get total enrollments across all teacher's courses
        total_enrollments = db.query(Enrollment).filter(
            Enrollment.course_id.in_(course_ids)
        ).count() if course_ids else 0
        
        # Get recent enrollments (last 30 days)
        thirty_days_ago = datetime.now() - timedelta(days=30)
        recent_enrollments = db.query(Enrollment).filter(
            Enrollment.course_id.in_(course_ids),
            Enrollment.enrolled_at >= thirty_days_ago
        ).count() if course_ids else 0
        
        # Get attendance sessions count
        attendance_sessions = db.query(AttendanceSession).filter(
            AttendanceSession.course_id.in_(course_ids)
        ).count() if course_ids else 0
        
        return {
            "total_courses": total_courses,
            "published_courses": published_courses,
            "draft_courses": total_courses - published_courses,
            "total_enrollments": total_enrollments,
            "recent_enrollments": recent_enrollments,
            "attendance_sessions": attendance_sessions,
            "average_rating": 4.2,  # Mock data
            "completion_rate": 78.5  # Mock data
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/analytics/performance")
async def get_teacher_performance_analytics(
    current_user: User = Depends(verify_teacher),
    db: Session = Depends(get_db)
):
    """Get detailed performance analytics for teacher"""
    try:
        # Get teacher's courses
        courses = db.query(Course).filter(Course.teacher_id == current_user.id).all()
        course_ids = [course.id for course in courses]
        
        # Course performance data
        course_performance = []
        for course in courses:
            enrollments = db.query(Enrollment).filter(
                Enrollment.course_id == course.id
            ).all()
            
            total_enrolled = len(enrollments)
            completed = len([e for e in enrollments if e.progress >= 100])
            avg_progress = sum([e.progress for e in enrollments]) / total_enrolled if total_enrolled > 0 else 0
            
            course_performance.append({
                "course_id": course.id,
                "course_title": course.title,
                "total_enrolled": total_enrolled,
                "completed_students": completed,
                "completion_rate": (completed / total_enrolled * 100) if total_enrolled > 0 else 0,
                "average_progress": round(avg_progress, 1),
                "rating": 4.3,  # Mock data
                "revenue": total_enrolled * 299  # Mock pricing
            })
        
        # Monthly enrollment trends (last 6 months)
        monthly_trends = []
        for i in range(6):
            month_start = datetime.now().replace(day=1) - timedelta(days=i*30)
            month_end = month_start + timedelta(days=30)
            
            enrollments_count = db.query(Enrollment).filter(
                Enrollment.course_id.in_(course_ids),
                Enrollment.enrolled_at >= month_start,
                Enrollment.enrolled_at < month_end
            ).count() if course_ids else 0
            
            monthly_trends.append({
                "month": month_start.strftime("%B %Y"),
                "enrollments": enrollments_count,
                "revenue": enrollments_count * 299  # Mock pricing
            })
        
        return {
            "course_performance": course_performance,
            "monthly_trends": list(reversed(monthly_trends)),
            "total_revenue": sum([cp["revenue"] for cp in course_performance]),
            "top_performing_course": max(course_performance, key=lambda x: x["completion_rate"]) if course_performance else None
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/students/management")
async def get_student_management_data(
    current_user: User = Depends(verify_teacher),
    db: Session = Depends(get_db)
):
    """Get student management data for teacher's courses"""
    try:
        # Get teacher's courses
        courses = db.query(Course).filter(Course.teacher_id == current_user.id).all()
        course_ids = [course.id for course in courses]
        
        # Get all students enrolled in teacher's courses
        enrollments = db.query(Enrollment).filter(
            Enrollment.course_id.in_(course_ids)
        ).all() if course_ids else []
        
        student_data = []
        for enrollment in enrollments:
            student = db.query(User).filter(User.id == enrollment.user_id).first()
            course = db.query(Course).filter(Course.id == enrollment.course_id).first()
            
            if student and course:
                # Get attendance data
                attendance_sessions = db.query(AttendanceSession).filter(
                    AttendanceSession.course_id == course.id
                ).count()
                
                attended_sessions = db.query(Attendance).filter(
                    Attendance.student_id == student.id,
                    Attendance.attendance_session_id.in_(
                        db.query(AttendanceSession.id).filter(
                            AttendanceSession.course_id == course.id
                        )
                    )
                ).count()
                
                attendance_rate = (attended_sessions / attendance_sessions * 100) if attendance_sessions > 0 else 0
                
                student_data.append({
                    "student_id": student.id,
                    "student_name": student.full_name,
                    "student_email": student.email,
                    "course_id": course.id,
                    "course_title": course.title,
                    "enrollment_date": enrollment.enrolled_at.isoformat(),
                    "progress": enrollment.progress,
                    "hours_completed": enrollment.hours_completed or 0,
                    "attendance_rate": round(attendance_rate, 1),
                    "last_activity": (enrollment.enrolled_at + timedelta(days=5)).isoformat(),  # Mock data
                    "performance_grade": "A" if enrollment.progress > 80 else "B" if enrollment.progress > 60 else "C"
                })
        
        return {
            "students": student_data,
            "total_students": len(student_data),
            "active_students": len([s for s in student_data if s["progress"] > 0]),
            "high_performers": len([s for s in student_data if s["progress"] > 80]),
            "at_risk_students": len([s for s in student_data if s["progress"] < 30])
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/communication/announcement")
async def create_announcement(
    course_id: int,
    title: str,
    message: str,
    current_user: User = Depends(verify_teacher),
    db: Session = Depends(get_db)
):
    """Create an announcement for a course"""
    try:
        # Verify teacher owns the course
        course = db.query(Course).filter(
            Course.id == course_id,
            Course.teacher_id == current_user.id
        ).first()
        
        if not course:
            raise HTTPException(status_code=404, detail="Course not found or not authorized")
        
        # Mock announcement creation
        announcement = {
            "id": 1,
            "course_id": course_id,
            "title": title,
            "message": message,
            "created_at": datetime.now().isoformat(),
            "created_by": current_user.full_name,
            "recipients_count": db.query(Enrollment).filter(Enrollment.course_id == course_id).count()
        }
        
        return {
            "message": "Announcement created successfully",
            "announcement": announcement
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/quizzes")
async def get_teacher_quizzes(
    current_user: User = Depends(verify_teacher),
    db: Session = Depends(get_db)
):
    """Get quizzes created by the teacher"""
    try:
        # Get teacher's courses
        courses = db.query(Course).filter(Course.teacher_id == current_user.id).all()
        course_ids = [course.id for course in courses]

        # Get all quizzes for teacher's courses
        quizzes = db.query(Quiz).filter(
            Quiz.course_id.in_(course_ids)
        ).all()

        # Format response
        quiz_data = []
        for quiz in quizzes:
            course = next((c for c in courses if c.id == quiz.course_id), None)
            quiz_data.append({
                "id": quiz.id,
                "title": quiz.title,
                "course_id": quiz.course_id,
                "course_title": course.title if course else "Unknown",
                "is_published": quiz.is_published,
                "total_questions": len(quiz.questions) if hasattr(quiz, 'questions') else 0,
                "passing_score": quiz.passing_score,
                "time_limit": quiz.time_limit,
                "created_at": quiz.created_at.isoformat() if quiz.created_at else None,
                "attempts_count": len(quiz.attempts) if hasattr(quiz, 'attempts') else 0
            })

        return {
            "quizzes": quiz_data,
            "total_count": len(quiz_data)
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/communication/messages")
async def get_teacher_messages(
    current_user: User = Depends(verify_teacher),
    db: Session = Depends(get_db)
):
    """Get messages and communications for teacher"""
    try:
        # Mock messages data
        messages = [
            {
                "id": 1,
                "from_student": "John Doe",
                "course_title": "Python Programming",
                "subject": "Question about Assignment 3",
                "message": "Hi, I'm having trouble with the loops section...",
                "received_at": (datetime.now() - timedelta(hours=2)).isoformat(),
                "status": "unread"
            },
            {
                "id": 2,
                "from_student": "Jane Smith",
                "course_title": "Web Development",
                "subject": "Request for Extension",
                "message": "Could I get an extension for the final project?",
                "received_at": (datetime.now() - timedelta(days=1)).isoformat(),
                "status": "read"
            }
        ]
        
        return {
            "messages": messages,
            "unread_count": len([m for m in messages if m["status"] == "unread"]),
            "total_messages": len(messages)
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/grading/assignment")
async def grade_assignment(
    student_id: int,
    course_id: int,
    assignment_id: int,
    grade: float,
    feedback: str,
    current_user: User = Depends(verify_teacher),
    db: Session = Depends(get_db)
):
    """Grade a student assignment"""
    try:
        # Verify teacher owns the course
        course = db.query(Course).filter(
            Course.id == course_id,
            Course.teacher_id == current_user.id
        ).first()
        
        if not course:
            raise HTTPException(status_code=404, detail="Course not found or not authorized")
        
        # Verify student is enrolled
        enrollment = db.query(Enrollment).filter(
            Enrollment.user_id == student_id,
            Enrollment.course_id == course_id
        ).first()
        
        if not enrollment:
            raise HTTPException(status_code=404, detail="Student not enrolled in course")
        
        # Mock grading
        graded_assignment = {
            "assignment_id": assignment_id,
            "student_id": student_id,
            "course_id": course_id,
            "grade": grade,
            "feedback": feedback,
            "graded_at": datetime.now().isoformat(),
            "graded_by": current_user.full_name
        }
        
        return {
            "message": "Assignment graded successfully",
            "graded_assignment": graded_assignment
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/content/library")
async def get_content_library(
    current_user: User = Depends(verify_teacher),
    db: Session = Depends(get_db)
):
    """Get teacher's content library and resources"""
    try:
        # Mock content library data
        content_library = {
            "videos": [
                {
                    "id": 1,
                    "title": "Introduction to Python",
                    "duration": "15:30",
                    "upload_date": "2024-01-15",
                    "views": 245,
                    "course_usage": 3
                },
                {
                    "id": 2,
                    "title": "Advanced Functions",
                    "duration": "22:45",
                    "upload_date": "2024-01-20",
                    "views": 189,
                    "course_usage": 2
                }
            ],
            "documents": [
                {
                    "id": 1,
                    "title": "Python Cheat Sheet",
                    "type": "PDF",
                    "size": "2.3 MB",
                    "upload_date": "2024-01-10",
                    "downloads": 156
                },
                {
                    "id": 2,
                    "title": "Assignment Template",
                    "type": "DOCX",
                    "size": "1.1 MB",
                    "upload_date": "2024-01-12",
                    "downloads": 89
                }
            ],
            "quizzes": [
                {
                    "id": 1,
                    "title": "Python Basics Quiz",
                    "questions": 10,
                    "created_date": "2024-01-18",
                    "attempts": 67,
                    "avg_score": 78.5
                }
            ]
        }
        
        return content_library
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/courses/teacher/stats")
async def teacher_stats(
    current_user: User = Depends(verify_teacher),
    db: Session = Depends(get_db)
):
    """Get teacher statistics for courses"""
    try:
        # Get teacher's courses
        courses = db.query(Course).filter(Course.teacher_id == current_user.id).all()

        total_courses = len(courses)
        published_courses = len([c for c in courses if c.is_published])

        # Get total enrollments across all courses
        course_ids = [course.id for course in courses]
        total_enrollments = db.query(Enrollment).filter(
            Enrollment.course_id.in_(course_ids)
        ).count() if course_ids else 0

        # Get recent enrollments (last 30 days)
        thirty_days_ago = datetime.now() - timedelta(days=30)
        recent_enrollments = db.query(Enrollment).filter(
            Enrollment.course_id.in_(course_ids),
            Enrollment.enrolled_at >= thirty_days_ago
        ).count() if course_ids else 0

        # Calculate average rating (mock data for now)
        average_rating = 4.2

        # Calculate completion rate (mock data for now)
        completion_rate = 78.5

        return {
            "total_courses": total_courses,
            "published_courses": published_courses,
            "total_enrollments": total_enrollments,
            "recent_enrollments": recent_enrollments,
            "average_rating": average_rating,
            "completion_rate": completion_rate
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/courses/teacher/upcoming-classes")
async def upcoming_classes(
    current_user: User = Depends(verify_teacher),
    db: Session = Depends(get_db)
):
    """Get upcoming classes for teacher"""
    try:
        # Get teacher's courses
        courses = db.query(Course).filter(Course.teacher_id == current_user.id).all()
        course_ids = [course.id for course in courses]

        # Get lessons scheduled for the next 7 days
        upcoming_date = datetime.now() + timedelta(days=7)

        upcoming_lessons = []
        for course in courses:
            lessons = db.query(Lesson).filter(
                Lesson.course_id == course.id,
                Lesson.scheduled_at <= upcoming_date,
                Lesson.scheduled_at >= datetime.now()
            ).order_by(Lesson.scheduled_at).all()

            for lesson in lessons:
                upcoming_lessons.append({
                    "id": lesson.id,
                    "title": lesson.title,
                    "course_title": course.title,
                    "scheduled_at": lesson.scheduled_at.isoformat() if lesson.scheduled_at else None,
                    "duration_minutes": lesson.duration_minutes,
                    "is_live": lesson.scheduled_at is not None
                })

        # Sort by scheduled time
        upcoming_lessons.sort(key=lambda x: x.get("scheduled_at") or "")

        return {
            "upcoming_classes": upcoming_lessons,
            "total_count": len(upcoming_lessons)
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/courses/teacher/student-queries")
async def student_queries(
    current_user: User = Depends(verify_teacher),
    db: Session = Depends(get_db)
):
    """Get student queries for teacher's courses"""
    try:
        # Mock student queries data - in a real implementation,
        # this would come from a questions/doubts system
        queries = [
            {
                "id": 1,
                "student_name": "John Doe",
                "course_title": "Python Programming",
                "question": "How do I handle exceptions in Python?",
                "asked_at": (datetime.now() - timedelta(hours=2)).isoformat(),
                "status": "unanswered"
            },
            {
                "id": 2,
                "student_name": "Jane Smith",
                "course_title": "Web Development",
                "question": "What's the difference between margin and padding in CSS?",
                "asked_at": (datetime.now() - timedelta(days=1)).isoformat(),
                "status": "answered"
            },
            {
                "id": 3,
                "student_name": "Mike Johnson",
                "course_title": "Python Programming",
                "question": "Can you explain list comprehensions?",
                "asked_at": (datetime.now() - timedelta(hours=5)).isoformat(),
                "status": "unanswered"
            }
        ]

        return {
            "queries": queries,
            "total_count": len(queries),
            "unanswered_count": len([q for q in queries if q["status"] == "unanswered"])
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
