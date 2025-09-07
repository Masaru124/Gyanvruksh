
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.database import get_db
from app.models.course import Course
from app.models.user import User
from app.models.enrollment import Enrollment
from app.models.course_video import CourseVideo
from app.models.course_note import CourseNote
from app.schemas.course import CourseCreate, CourseOut, EnrollmentCreate, EnrollmentOut, CourseDetailOut
from app.services.deps import get_current_user
from typing import List
from datetime import datetime, timedelta

router = APIRouter(prefix="/api/courses", tags=["courses"])

@router.post("/", response_model=CourseOut, status_code=201)
def create_course(payload: CourseCreate, db: Session = Depends(get_db), user: User = Depends(get_current_user)):
    if not user.is_teacher and user.role != "admin":
        raise HTTPException(status_code=403, detail="Only teachers and admins can create courses")

    # Admin-created courses should have teacher_id = None so teachers can choose to teach them
    teacher_id = None if user.role == "admin" else user.id

    c = Course(title=payload.title, description=payload.description, teacher_id=teacher_id, total_hours=payload.total_hours)
    db.add(c)
    db.commit()
    db.refresh(c)
    return c

@router.get("/", response_model=List[CourseOut])
def list_courses(db: Session = Depends(get_db)):
    return db.query(Course).order_by(Course.id.desc()).all()

@router.get("/mine", response_model=List[CourseOut])
def my_courses(db: Session = Depends(get_db), user: User = Depends(get_current_user)):
    if user.is_teacher:
        return db.query(Course).filter(Course.teacher_id == user.id).all()
    return db.query(Course).order_by(Course.id.desc()).all()

@router.get("/available", response_model=List[CourseOut])
def available_courses(db: Session = Depends(get_db), user: User = Depends(get_current_user)):
    """Get courses available for teachers to select (not assigned to any teacher)"""
    if not user.is_teacher and user.role != "service_provider" and user.role != "admin" and user.role != "service_seeker":
        raise HTTPException(status_code=403, detail="Only teachers can view available courses")
    return db.query(Course).filter(Course.teacher_id.is_(None)).order_by(Course.id.desc()).all()

# Teachers cannot self-enroll - only admins can assign teachers
# Removed select_course endpoint to prevent self-enrollment

@router.get("/teacher/stats")
def teacher_stats(db: Session = Depends(get_db), user: User = Depends(get_current_user)):
    """Get performance stats for teacher dashboard"""
    if not user.is_teacher and user.role != "service_provider":
        raise HTTPException(status_code=403, detail="Only teachers can view stats")

    # Get teacher's courses
    teacher_courses = db.query(Course).filter(Course.teacher_id == user.id).all()

    # Mock stats - in real implementation, these would come from enrollment/attendance tables
    stats = {
        "totalCourses": len(teacher_courses),
        "totalStudents": 45,  # Mock data
        "averageAttendance": 92,  # Mock data
        "engagementRate": 87,  # Mock data
        "completedAssignments": 156,  # Mock data
    }

    return stats

@router.get("/teacher/upcoming-classes")
def upcoming_classes(db: Session = Depends(get_db), user: User = Depends(get_current_user)):
    """Get upcoming classes for teacher"""
    if not user.is_teacher and user.role != "service_provider":
        raise HTTPException(status_code=403, detail="Only teachers can view upcoming classes")

    # Mock upcoming classes - in real implementation, this would come from a schedule/classes table
    upcoming = [
        {"subject": "Mathematics", "time": "9:00 AM", "class": "Grade 10A", "date": (datetime.now() + timedelta(days=1)).strftime("%Y-%m-%d")},
        {"subject": "Physics", "time": "11:00 AM", "class": "Grade 11B", "date": (datetime.now() + timedelta(days=1)).strftime("%Y-%m-%d")},
        {"subject": "English", "time": "2:00 PM", "class": "Grade 9C", "date": (datetime.now() + timedelta(days=2)).strftime("%Y-%m-%d")},
    ]

    return upcoming

@router.get("/teacher/student-queries")
def student_queries(db: Session = Depends(get_db), user: User = Depends(get_current_user)):
    """Get recent student queries for teacher"""
    if not user.is_teacher and user.role != "service_provider":
        raise HTTPException(status_code=403, detail="Only teachers can view student queries")

    # Mock student queries - in real implementation, this would come from a queries/messages table
    queries = [
        {"student": "Alice Johnson", "query": "Need help with quadratic equations", "time": "2 hours ago", "id": 1},
        {"student": "Bob Smith", "query": "Clarification on Newton's laws", "time": "4 hours ago", "id": 2},
        {"student": "Carol Davis", "query": "Assignment deadline extension", "time": "1 day ago", "id": 3},
    ]

    return queries

# Enrollment endpoints
@router.post("/enroll", response_model=EnrollmentOut, status_code=201)
def enroll_student(payload: EnrollmentCreate, db: Session = Depends(get_db), user: User = Depends(get_current_user)):
    """Allow students to enroll in courses"""
    if user.role != "service_seeker" or user.sub_role != "student":
        raise HTTPException(status_code=403, detail="Only students can enroll in courses")

    course = db.query(Course).filter(Course.id == payload.course_id).first()
    if not course:
        raise HTTPException(status_code=404, detail="Course not found")

    if course.teacher_id is None:
        raise HTTPException(status_code=400, detail="Course is not available for enrollment yet (no teacher assigned)")

    # Check if already enrolled
    existing_enrollment = db.query(Enrollment).filter(
        Enrollment.student_id == user.id,
        Enrollment.course_id == payload.course_id
    ).first()
    if existing_enrollment:
        raise HTTPException(status_code=400, detail="Already enrolled in this course")

    enrollment = Enrollment(student_id=user.id, course_id=payload.course_id)
    db.add(enrollment)
    db.commit()
    db.refresh(enrollment)
    return enrollment

@router.get("/enrolled", response_model=List[CourseOut])
def get_enrolled_courses(db: Session = Depends(get_db), user: User = Depends(get_current_user)):
    """Get courses the student is enrolled in"""
    if user.role != "service_seeker" or user.sub_role != "student":
        raise HTTPException(status_code=403, detail="Only students can view enrolled courses")

    enrolled_courses = db.query(Course).join(Enrollment).filter(
        Enrollment.student_id == user.id
    ).all()
    return enrolled_courses

@router.delete("/enroll/{course_id}")
def unenroll_student(course_id: int, db: Session = Depends(get_db), user: User = Depends(get_current_user)):
    """Allow students to unenroll from courses"""
    if user.role != "service_seeker" or user.sub_role != "student":
        raise HTTPException(status_code=403, detail="Only students can unenroll from courses")

    enrollment = db.query(Enrollment).filter(
        Enrollment.student_id == user.id,
        Enrollment.course_id == course_id
    ).first()
    if not enrollment:
        raise HTTPException(status_code=404, detail="Enrollment not found")

    db.delete(enrollment)
    db.commit()
    return {"message": "Successfully unenrolled from course"}

@router.get("/available-for-enrollment", response_model=List[CourseOut])
def get_available_courses_for_enrollment(db: Session = Depends(get_db), user: User = Depends(get_current_user)):
    """Get courses available for students and teachers to enroll (have assigned teachers)"""
    if not ((user.role == "service_seeker" and user.sub_role == "student") or user.is_teacher or user.role == "admin"):
        raise HTTPException(status_code=403, detail="Only students and teachers can view available courses")

    # For teachers and admins, return all courses with assigned teachers
    if user.is_teacher or user.role == "admin":
        return db.query(Course).filter(
            Course.teacher_id.isnot(None)
        ).all()

    # For students, return courses that have teachers assigned and student is not already enrolled
    available_courses = db.query(Course).filter(
        Course.teacher_id.isnot(None)
    ).outerjoin(Enrollment, (Enrollment.course_id == Course.id) & (Enrollment.student_id == user.id)).filter(
        Enrollment.id.is_(None)
    ).all()
    return available_courses

@router.get("/{course_id}/details", response_model=CourseDetailOut)
def get_course_details(course_id: int, db: Session = Depends(get_db)):
    """Get detailed course information including teacher and enrollment count"""
    course = db.query(Course).filter(Course.id == course_id).first()
    if not course:
        raise HTTPException(status_code=404, detail="Course not found")

    # Get teacher name if assigned
    teacher_name = None
    if course.teacher_id:
        teacher = db.query(User).filter(User.id == course.teacher_id).first()
        teacher_name = teacher.full_name if teacher else None

    # Count enrolled students
    enrolled_count = db.query(Enrollment).filter(Enrollment.course_id == course_id).count()

    return CourseDetailOut(
        id=course.id,
        title=course.title,
        description=course.description,
        teacher_id=course.teacher_id,
        teacher_name=teacher_name,
        enrolled_students_count=enrolled_count,
        total_hours=course.total_hours,
        created_at=course.created_at
    )

@router.put("/enrollment/{enrollment_id}/hours")
def update_hours_completed(enrollment_id: int, hours: int, db: Session = Depends(get_db), user: User = Depends(get_current_user)):
    """Update hours completed for a student's enrollment and award gyan coins"""
    if user.role != "service_seeker" or user.sub_role != "student":
        raise HTTPException(status_code=403, detail="Only students can update hours")

    enrollment = db.query(Enrollment).filter(
        Enrollment.id == enrollment_id,
        Enrollment.student_id == user.id
    ).first()
    if not enrollment:
        raise HTTPException(status_code=404, detail="Enrollment not found")

    # Calculate new coins to award
    previous_hours = enrollment.hours_completed
    new_hours = hours
    hours_added = new_hours - previous_hours
    coins_to_award = hours_added // 10  # 1 coin per 10 hours

    if coins_to_award > 0:
        user.gyan_coins += coins_to_award
        db.commit()

    enrollment.hours_completed = new_hours
    db.commit()
    db.refresh(enrollment)

    return {"message": f"Hours updated. Awarded {coins_to_award} gyan coins.", "hours_completed": enrollment.hours_completed}

# Admin-only endpoints for course management

@router.post("/admin/{course_id}/assign-teacher")
def assign_teacher_to_course(course_id: int, teacher_id: int, db: Session = Depends(get_db), user: User = Depends(get_current_user)):
    """Admin assigns a teacher to a course"""
    if user.role != "admin":
        raise HTTPException(status_code=403, detail="Only admins can assign teachers to courses")

    course = db.query(Course).filter(Course.id == course_id).first()
    if not course:
        raise HTTPException(status_code=404, detail="Course not found")

    teacher = db.query(User).filter(User.id == teacher_id, User.is_teacher == True).first()
    if not teacher:
        raise HTTPException(status_code=404, detail="Teacher not found")

    course.teacher_id = teacher_id
    db.commit()
    db.refresh(course)
    return {"message": f"Teacher {teacher.full_name} assigned to course {course.title}"}

@router.post("/admin/{course_id}/upload-video")
def upload_course_video(course_id: int, title: str, url: str, description: str = None, db: Session = Depends(get_db), user: User = Depends(get_current_user)):
    """Admin uploads a video to a course"""
    if user.role != "admin":
        raise HTTPException(status_code=403, detail="Only admins can upload videos to courses")

    course = db.query(Course).filter(Course.id == course_id).first()
    if not course:
        raise HTTPException(status_code=404, detail="Course not found")

    video = CourseVideo(course_id=course_id, title=title, url=url, description=description)
    db.add(video)
    db.commit()
    db.refresh(video)
    return {"message": "Video uploaded successfully", "video_id": video.id}

@router.post("/admin/{course_id}/upload-note")
def upload_course_note(course_id: int, title: str, content: str, db: Session = Depends(get_db), user: User = Depends(get_current_user)):
    """Admin uploads a note to a course"""
    if user.role != "admin":
        raise HTTPException(status_code=403, detail="Only admins can upload notes to courses")

    course = db.query(Course).filter(Course.id == course_id).first()
    if not course:
        raise HTTPException(status_code=404, detail="Course not found")

    note = CourseNote(course_id=course_id, title=title, content=content)
    db.add(note)
    db.commit()
    db.refresh(note)
    return {"message": "Note uploaded successfully", "note_id": note.id}

@router.get("/admin/courses")
def admin_list_courses(db: Session = Depends(get_db), user: User = Depends(get_current_user)):
    """Admin: List all courses with details"""
    if user.role != "admin":
        raise HTTPException(status_code=403, detail="Only admins can view courses")

    courses = db.query(Course).order_by(Course.id.desc()).all()
    result = []
    for c in courses:
        teacher_name = None
        if c.teacher_id:
            teacher = db.query(User).filter(User.id == c.teacher_id).first()
            teacher_name = teacher.full_name if teacher else None
        enrolled_count = db.query(Enrollment).filter(Enrollment.course_id == c.id).count()
        result.append({
            "id": c.id,
            "title": c.title,
            "description": c.description,
            "teacher_id": c.teacher_id,
            "teacher_name": teacher_name,
            "enrolled_students_count": enrolled_count,
            "total_hours": c.total_hours,
            "created_at": c.created_at.isoformat()
        })
    return result

@router.delete("/admin/courses/{course_id}")
def admin_delete_course(course_id: int, db: Session = Depends(get_db), user: User = Depends(get_current_user)):
    """Admin: Delete a course"""
    if user.role != "admin":
        raise HTTPException(status_code=403, detail="Only admins can delete courses")

    course = db.query(Course).filter(Course.id == course_id).first()
    if not course:
        raise HTTPException(status_code=404, detail="Course not found")

    db.delete(course)
    db.commit()
    return {"message": "Course deleted successfully"}

@router.get("/admin/course-videos")
def admin_list_course_videos(db: Session = Depends(get_db), user: User = Depends(get_current_user)):
    """Admin: List all course videos"""
    if user.role != "admin":
        raise HTTPException(status_code=403, detail="Only admins can view course videos")

    videos = db.query(CourseVideo).order_by(CourseVideo.uploaded_at.desc()).all()
    result = []
    for v in videos:
        course = db.query(Course).filter(Course.id == v.course_id).first()
        result.append({
            "id": v.id,
            "course_id": v.course_id,
            "course_title": course.title if course else None,
            "title": v.title,
            "url": v.url,
            "description": v.description,
            "uploaded_at": v.uploaded_at.isoformat()
        })
    return result

@router.delete("/admin/course-videos/{video_id}")
def admin_delete_course_video(video_id: int, db: Session = Depends(get_db), user: User = Depends(get_current_user)):
    """Admin: Delete a course video"""
    if user.role != "admin":
        raise HTTPException(status_code=403, detail="Only admins can delete course videos")

    video = db.query(CourseVideo).filter(CourseVideo.id == video_id).first()
    if not video:
        raise HTTPException(status_code=404, detail="Course video not found")

    db.delete(video)
    db.commit()
    return {"message": "Course video deleted successfully"}

@router.get("/admin/course-notes")
def admin_list_course_notes(db: Session = Depends(get_db), user: User = Depends(get_current_user)):
    """Admin: List all course notes"""
    if user.role != "admin":
        raise HTTPException(status_code=403, detail="Only admins can view course notes")

    notes = db.query(CourseNote).order_by(CourseNote.uploaded_at.desc()).all()
    result = []
    for n in notes:
        course = db.query(Course).filter(Course.id == n.course_id).first()
        result.append({
            "id": n.id,
            "course_id": n.course_id,
            "course_title": course.title if course else None,
            "title": n.title,
            "content": n.content,
            "uploaded_at": n.uploaded_at.isoformat()
        })
    return result

@router.delete("/admin/course-notes/{note_id}")
def admin_delete_course_note(note_id: int, db: Session = Depends(get_db), user: User = Depends(get_current_user)):
    """Admin: Delete a course note"""
    if user.role != "admin":
        raise HTTPException(status_code=403, detail="Only admins can delete course notes")

    note = db.query(CourseNote).filter(CourseNote.id == note_id).first()
    if not note:
        raise HTTPException(status_code=404, detail="Course note not found")

    db.delete(note)
    db.commit()
    return {"message": "Course note deleted successfully"}

@router.get("/{course_id}/videos")
def get_course_videos(course_id: int, db: Session = Depends(get_db)):
    """Get all videos for a course"""
    videos = db.query(CourseVideo).filter(CourseVideo.course_id == course_id).order_by(CourseVideo.uploaded_at.desc()).all()
    # Return videos as is, no Google Drive to YouTube conversion
    updated_videos = []
    for v in videos:
        updated_videos.append({
            "id": v.id,
            "title": v.title,
            "url": v.url,
            "description": v.description,
            "uploaded_at": v.uploaded_at.isoformat()
        })
    return updated_videos

@router.get("/{course_id}/notes")
def get_course_notes(course_id: int, db: Session = Depends(get_db)):
    """Get all notes for a course"""
    notes = db.query(CourseNote).filter(CourseNote.course_id == course_id).order_by(CourseNote.uploaded_at.desc()).all()
    return [{"id": n.id, "title": n.title, "content": n.content, "uploaded_at": n.uploaded_at.isoformat()} for n in notes]
