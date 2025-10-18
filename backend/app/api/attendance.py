from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List, Optional
from ..database import get_db
from ..models.user import User
from ..models.course import Course
from ..models.enrollment import Enrollment
from ..models.lesson import Lesson
from ..models.attendance import Attendance, AttendanceSession
from ..services.deps import get_current_user
from ..utils.errors import authz_error, not_found_error
from pydantic import BaseModel
from datetime import datetime, date

router = APIRouter(prefix="/api/attendance", tags=["attendance"])

# Pydantic models
class AttendanceMarkRequest(BaseModel):
    lesson_id: int
    course_id: int
    student_attendances: List[dict]  # [{"student_id": int, "is_present": bool, "notes": str}]

class AttendanceSessionCreate(BaseModel):
    lesson_id: int
    course_id: int
    session_date: datetime

class AttendanceSessionCreateForCourse(BaseModel):
    session_name: str
    session_date: datetime

def verify_teacher(user: User = Depends(get_current_user)):
    """Verify that the current user is a teacher"""
    if user.sub_role != "teacher":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Teacher access required"
        )
    return user

@router.post("/sessions/create")
def create_attendance_session(
    request: AttendanceSessionCreate,
    db: Session = Depends(get_db),
    teacher: User = Depends(verify_teacher)
):
    """Create a new attendance session for a lesson"""
    
    # Verify teacher owns the course
    course = db.query(Course).filter(
        Course.id == request.course_id,
        Course.teacher_id == teacher.id
    ).first()
    if not course:
        raise HTTPException(status_code=404, detail="Course not found or not owned by teacher")
    
    # Verify lesson exists
    lesson = db.query(Lesson).filter(Lesson.id == request.lesson_id).first()
    if not lesson:
        raise HTTPException(status_code=404, detail="Lesson not found")
    
    # Get enrolled students count
    enrolled_students = db.query(Enrollment).filter(Enrollment.course_id == request.course_id).count()
    
    # Create attendance session
    session = AttendanceSession(
        lesson_id=request.lesson_id,
        course_id=request.course_id,
        teacher_id=teacher.id,
        session_date=request.session_date,
        total_students=enrolled_students,
        present_students=0,
        attendance_percentage=0.0,
        is_completed=False
    )
    
    db.add(session)
    db.commit()
    db.refresh(session)
    
    return {
        "message": "Attendance session created successfully",
        "session_id": session.id,
        "total_students": enrolled_students
    }

@router.post("/mark")
def mark_attendance(
    request: AttendanceMarkRequest,
    db: Session = Depends(get_db),
    teacher: User = Depends(verify_teacher)
):
    """Mark attendance for students in a lesson"""

    # Verify teacher owns the course
    course = db.query(Course).filter(
        Course.id == request.course_id,
        Course.teacher_id == teacher.id
    ).first()
    if not course:
        raise HTTPException(status_code=404, detail="Course not found or not owned by teacher")

    # Get or create attendance session
    session = db.query(AttendanceSession).filter(
        AttendanceSession.lesson_id == request.lesson_id,
        AttendanceSession.course_id == request.course_id,
        AttendanceSession.teacher_id == teacher.id
    ).first()

    if not session:
        # Create session if it doesn't exist
        enrolled_students = db.query(Enrollment).filter(Enrollment.course_id == request.course_id).count()
        session = AttendanceSession(
            lesson_id=request.lesson_id,
            course_id=request.course_id,
            teacher_id=teacher.id,
            session_date=datetime.utcnow(),
            total_students=enrolled_students,
            present_students=0,
            attendance_percentage=0.0,
            is_completed=False
        )
        db.add(session)
        db.commit()
        db.refresh(session)

    # Mark attendance for each student
    present_count = 0
    attendance_records = []

    for student_attendance in request.student_attendances:
        student_id = student_attendance["student_id"]
        is_present = student_attendance["is_present"]
        notes = student_attendance.get("notes", "")

        # Verify student is enrolled in the course
        enrollment = db.query(Enrollment).filter(
            Enrollment.student_id == student_id,
            Enrollment.course_id == request.course_id
        ).first()

        if not enrollment:
            continue  # Skip non-enrolled students

        # Check if attendance already exists for this student/lesson
        existing_attendance = db.query(Attendance).filter(
            Attendance.student_id == student_id,
            Attendance.lesson_id == request.lesson_id,
            Attendance.course_id == request.course_id
        ).first()

        if existing_attendance:
            # Update existing attendance
            existing_attendance.is_present = is_present
            existing_attendance.notes = notes
            existing_attendance.updated_at = datetime.utcnow()
        else:
            # Create new attendance record
            attendance = Attendance(
                student_id=student_id,
                lesson_id=request.lesson_id,
                course_id=request.course_id,
                is_present=is_present,
                marked_by=teacher.id,
                notes=notes,
                attendance_date=datetime.utcnow()
            )
            db.add(attendance)
            attendance_records.append(attendance)

        if is_present:
            present_count += 1

    # Update session statistics
    session.present_students = present_count
    session.attendance_percentage = (present_count / session.total_students) * 100 if session.total_students > 0 else 0
    session.is_completed = True

    db.commit()

    return {
        "message": "Attendance marked successfully",
        "session_id": session.id,
        "total_students": session.total_students,
        "present_students": present_count,
        "attendance_percentage": round(session.attendance_percentage, 2)
    }

# Additional endpoint for course-specific attendance session creation (matches frontend expectation)
@router.post("/course/{course_id}/sessions")
def create_course_attendance_session(
    course_id: int,
    request: AttendanceSessionCreateForCourse,
    db: Session = Depends(get_db),
    teacher: User = Depends(verify_teacher)
):
    """Create attendance session for a course (matches frontend API expectation)"""

    # Verify teacher owns the course
    course = db.query(Course).filter(
        Course.id == course_id,
        Course.teacher_id == teacher.id
    ).first()
    if not course:
        raise HTTPException(status_code=404, detail="Course not found or not owned by teacher")

    # Get enrolled students count
    enrolled_students = db.query(Enrollment).filter(Enrollment.course_id == course_id).count()

    # Create attendance session without specific lesson (general course session)
    session = AttendanceSession(
        lesson_id=None,  # General course session, not tied to specific lesson
        course_id=course_id,
        teacher_id=teacher.id,
        session_date=request.session_date,
        total_students=enrolled_students,
        present_students=0,
        attendance_percentage=0.0,
        is_completed=False
    )

    db.add(session)
    db.commit()
    db.refresh(session)

    return {
        "message": "Attendance session created successfully",
        "session_id": session.id,
        "session_name": request.session_name,
        "total_students": enrolled_students
    }

@router.get("/course/{course_id}/sessions")
def get_course_attendance_sessions(
    course_id: int,
    db: Session = Depends(get_db),
    teacher: User = Depends(verify_teacher)
):
    """Get all attendance sessions for a course"""
    
    # Verify teacher owns the course
    course = db.query(Course).filter(
        Course.id == course_id,
        Course.teacher_id == teacher.id
    ).first()
    if not course:
        raise HTTPException(status_code=404, detail="Course not found or not owned by teacher")
    
    sessions = db.query(AttendanceSession).filter(
        AttendanceSession.course_id == course_id
    ).order_by(AttendanceSession.session_date.desc()).all()
    
    return [{
        "session_id": session.id,
        "lesson_id": session.lesson_id,
        "session_date": session.session_date,
        "total_students": session.total_students,
        "present_students": session.present_students,
        "attendance_percentage": round(session.attendance_percentage, 2),
        "is_completed": session.is_completed
    } for session in sessions]

@router.get("/lesson/{lesson_id}/details")
def get_lesson_attendance_details(
    lesson_id: int,
    db: Session = Depends(get_db),
    teacher: User = Depends(verify_teacher)
):
    """Get detailed attendance for a specific lesson"""
    
    # Get lesson and verify teacher access
    lesson = db.query(Lesson).filter(Lesson.id == lesson_id).first()
    if not lesson:
        raise HTTPException(status_code=404, detail="Lesson not found")
    
    course = db.query(Course).filter(
        Course.id == lesson.course_id,
        Course.teacher_id == teacher.id
    ).first()
    if not course:
        raise HTTPException(status_code=404, detail="Course not found or not owned by teacher")
    
    # Get attendance records
    attendance_records = db.query(Attendance).filter(
        Attendance.lesson_id == lesson_id
    ).all()
    
    # Get all enrolled students
    enrolled_students = db.query(User).join(Enrollment).filter(
        Enrollment.course_id == lesson.course_id
    ).all()
    
    student_attendance = []
    for student in enrolled_students:
        attendance_record = next((a for a in attendance_records if a.student_id == student.id), None)
        student_attendance.append({
            "student_id": student.id,
            "student_name": student.full_name,
            "student_email": student.email,
            "is_present": attendance_record.is_present if attendance_record else False,
            "notes": attendance_record.notes if attendance_record else "",
            "marked_at": attendance_record.created_at if attendance_record else None
        })
    
    return {
        "lesson_id": lesson_id,
        "lesson_title": lesson.title,
        "course_title": course.title,
        "total_students": len(enrolled_students),
        "present_students": sum(1 for s in student_attendance if s["is_present"]),
        "student_attendance": student_attendance
    }

@router.get("/student/{student_id}/history")
def get_student_attendance_history(
    student_id: int,
    course_id: Optional[int] = None,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user)
):
    """Get attendance history for a student"""
    
    # Verify access (student can view own, teacher can view their course students, admin can view all)
    if user.role != "admin" and user.id != student_id:
        if user.sub_role == "teacher":
            # Teacher can only view students from their courses
            if course_id:
                course = db.query(Course).filter(
                    Course.id == course_id,
                    Course.teacher_id == user.id
                ).first()
                if not course:
                    raise HTTPException(status_code=403, detail="Access denied")
            else:
                raise HTTPException(status_code=403, detail="Course ID required for teacher access")
        else:
            raise HTTPException(status_code=403, detail="Access denied")
    
    query = db.query(Attendance).filter(Attendance.student_id == student_id)
    if course_id:
        query = query.filter(Attendance.course_id == course_id)
    
    attendance_records = query.order_by(Attendance.attendance_date.desc()).all()
    
    # Calculate statistics
    total_classes = len(attendance_records)
    present_classes = sum(1 for record in attendance_records if record.is_present)
    attendance_percentage = (present_classes / total_classes) * 100 if total_classes > 0 else 0
    
    return {
        "student_id": student_id,
        "total_classes": total_classes,
        "present_classes": present_classes,
        "absent_classes": total_classes - present_classes,
        "attendance_percentage": round(attendance_percentage, 2),
        "attendance_records": [{
            "lesson_id": record.lesson_id,
            "course_id": record.course_id,
            "is_present": record.is_present,
            "attendance_date": record.attendance_date,
            "notes": record.notes
        } for record in attendance_records]
    }

@router.get("/analytics/course/{course_id}")
def get_course_attendance_analytics(
    course_id: int,
    db: Session = Depends(get_db),
    teacher: User = Depends(verify_teacher)
):
    """Get attendance analytics for a course"""
    
    # Verify teacher owns the course
    course = db.query(Course).filter(
        Course.id == course_id,
        Course.teacher_id == teacher.id
    ).first()
    if not course:
        raise HTTPException(status_code=404, detail="Course not found or not owned by teacher")
    
    # Get all attendance sessions
    sessions = db.query(AttendanceSession).filter(
        AttendanceSession.course_id == course_id
    ).all()
    
    # Calculate overall statistics
    total_sessions = len(sessions)
    avg_attendance = sum(session.attendance_percentage for session in sessions) / total_sessions if total_sessions > 0 else 0
    
    # Get student-wise attendance
    enrolled_students = db.query(User).join(Enrollment).filter(
        Enrollment.course_id == course_id
    ).all()
    
    student_stats = []
    for student in enrolled_students:
        student_attendance = db.query(Attendance).filter(
            Attendance.student_id == student.id,
            Attendance.course_id == course_id
        ).all()
        
        total_classes = len(student_attendance)
        present_classes = sum(1 for record in student_attendance if record.is_present)
        percentage = (present_classes / total_classes) * 100 if total_classes > 0 else 0
        
        student_stats.append({
            "student_id": student.id,
            "student_name": student.full_name,
            "total_classes": total_classes,
            "present_classes": present_classes,
            "attendance_percentage": round(percentage, 2)
        })
    
    return {
        "course_id": course_id,
        "course_title": course.title,
        "total_sessions": total_sessions,
        "average_attendance": round(avg_attendance, 2),
        "enrolled_students": len(enrolled_students),
        "student_statistics": student_stats,
        "session_history": [{
            "session_id": session.id,
            "lesson_id": session.lesson_id,
            "session_date": session.session_date,
            "attendance_percentage": round(session.attendance_percentage, 2)
        } for session in sessions]
    }
