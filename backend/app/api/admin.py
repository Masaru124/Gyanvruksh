from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List, Optional
from app.database import get_db
from app.models.user import User
from app.models.course import Course
from app.models.enrollment import Enrollment
from app.models.lesson import Lesson
from app.models.attendance import Attendance, AttendanceSession
from app.models.category import Category
from app.services.deps import get_current_user
from pydantic import BaseModel
from datetime import datetime

router = APIRouter(prefix="/api/admin", tags=["admin"])

# Pydantic models for admin operations
class CourseAssignmentRequest(BaseModel):
    course_id: int
    teacher_id: int

class TeacherApprovalRequest(BaseModel):
    teacher_id: int
    approved: bool

class UserRoleUpdate(BaseModel):
    user_id: int
    role: str
    sub_role: str

class CourseStatusUpdate(BaseModel):
    course_id: int
    is_published: bool

def verify_admin(user: User = Depends(get_current_user)):
    """Verify that the current user is an admin"""
    if user.role != "admin":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Admin access required"
        )
    return user

@router.get("/dashboard/stats")
def get_admin_dashboard_stats(
    db: Session = Depends(get_db),
    admin: User = Depends(verify_admin)
):
    """Get comprehensive admin dashboard statistics"""
    
    # User statistics
    total_users = db.query(User).count()
    total_students = db.query(User).filter(User.sub_role == "student").count()
    total_teachers = db.query(User).filter(User.sub_role == "teacher").count()
    pending_teachers = db.query(User).filter(
        User.sub_role == "teacher", 
        User.is_active == False
    ).count()
    
    # Course statistics
    total_courses = db.query(Course).count()
    published_courses = db.query(Course).filter(Course.is_published == True).count()
    unpublished_courses = db.query(Course).filter(Course.is_published == False).count()
    courses_without_teacher = db.query(Course).filter(Course.teacher_id == None).count()
    
    # Enrollment statistics
    total_enrollments = db.query(Enrollment).count()
    
    # Recent activity
    recent_users = db.query(User).order_by(User.created_at.desc()).limit(5).all()
    recent_courses = db.query(Course).order_by(Course.created_at.desc()).limit(5).all()
    
    return {
        "users": {
            "total": total_users,
            "students": total_students,
            "teachers": total_teachers,
            "pending_teachers": pending_teachers
        },
        "courses": {
            "total": total_courses,
            "published": published_courses,
            "unpublished": unpublished_courses,
            "unassigned": courses_without_teacher
        },
        "enrollments": {
            "total": total_enrollments
        },
        "recent_activity": {
            "users": [{"id": u.id, "name": u.full_name, "email": u.email, "role": u.sub_role} for u in recent_users],
            "courses": [{"id": c.id, "title": c.title, "teacher_id": c.teacher_id} for c in recent_courses]
        }
    }

@router.get("/users")
def get_all_users(
    skip: int = 0,
    limit: int = 100,
    role: Optional[str] = None,
    db: Session = Depends(get_db),
    admin: User = Depends(verify_admin)
):
    """Get all users with optional filtering"""
    query = db.query(User)
    
    if role:
        query = query.filter(User.sub_role == role)
    
    users = query.offset(skip).limit(limit).all()
    
    return [{
        "id": user.id,
        "email": user.email,
        "full_name": user.full_name,
        "role": user.role,
        "sub_role": user.sub_role,
        "is_active": user.is_active,
        "created_at": user.created_at,
        "gyan_coins": user.gyan_coins
    } for user in users]

@router.get("/teachers/pending")
def get_pending_teachers(
    db: Session = Depends(get_db),
    admin: User = Depends(verify_admin)
):
    """Get all pending teacher approvals"""
    pending_teachers = db.query(User).filter(
        User.sub_role == "teacher",
        User.is_active == False
    ).all()
    
    return [{
        "id": teacher.id,
        "email": teacher.email,
        "full_name": teacher.full_name,
        "educational_qualification": teacher.educational_qualification,
        "year_of_experience": teacher.year_of_experience,
        "phone_number": teacher.phone_number,
        "created_at": teacher.created_at
    } for teacher in pending_teachers]

@router.post("/teachers/approve")
def approve_teacher(
    request: TeacherApprovalRequest,
    db: Session = Depends(get_db),
    admin: User = Depends(verify_admin)
):
    """Approve or reject teacher application"""
    teacher = db.query(User).filter(User.id == request.teacher_id).first()
    if not teacher:
        raise HTTPException(status_code=404, detail="Teacher not found")
    
    if teacher.sub_role != "teacher":
        raise HTTPException(status_code=400, detail="User is not a teacher")
    
    teacher.is_active = request.approved
    db.commit()
    
    return {
        "message": f"Teacher {'approved' if request.approved else 'rejected'} successfully",
        "teacher_id": teacher.id,
        "status": "approved" if request.approved else "rejected"
    }

@router.get("/courses/unassigned")
def get_unassigned_courses(
    db: Session = Depends(get_db),
    admin: User = Depends(verify_admin)
):
    """Get all courses without assigned teachers"""
    unassigned_courses = db.query(Course).filter(Course.teacher_id == None).all()
    
    return [{
        "id": course.id,
        "title": course.title,
        "description": course.description,
        "difficulty": course.difficulty,
        "total_hours": course.total_hours,
        "enrollment_count": course.enrollment_count,
        "is_published": course.is_published,
        "created_at": course.created_at
    } for course in unassigned_courses]

@router.post("/courses/assign-teacher")
def assign_teacher_to_course(
    request: CourseAssignmentRequest,
    db: Session = Depends(get_db),
    admin: User = Depends(verify_admin)
):
    """Assign a teacher to a course"""
    course = db.query(Course).filter(Course.id == request.course_id).first()
    if not course:
        raise HTTPException(status_code=404, detail="Course not found")
    
    teacher = db.query(User).filter(
        User.id == request.teacher_id,
        User.sub_role == "teacher",
        User.is_active == True
    ).first()
    if not teacher:
        raise HTTPException(status_code=404, detail="Active teacher not found")
    
    course.teacher_id = request.teacher_id
    db.commit()
    
    return {
        "message": "Teacher assigned successfully",
        "course_id": course.id,
        "course_title": course.title,
        "teacher_id": teacher.id,
        "teacher_name": teacher.full_name
    }

@router.post("/courses/update-status")
def update_course_status(
    request: CourseStatusUpdate,
    db: Session = Depends(get_db),
    admin: User = Depends(verify_admin)
):
    """Publish or unpublish a course"""
    course = db.query(Course).filter(Course.id == request.course_id).first()
    if not course:
        raise HTTPException(status_code=404, detail="Course not found")
    
    course.is_published = request.is_published
    db.commit()
    
    return {
        "message": f"Course {'published' if request.is_published else 'unpublished'} successfully",
        "course_id": course.id,
        "title": course.title,
        "is_published": course.is_published
    }

@router.put("/users/{user_id}/role")
def update_user_role(
    user_id: int,
    request: UserRoleUpdate,
    db: Session = Depends(get_db),
    admin: User = Depends(verify_admin)
):
    """Update user role and sub_role"""
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    user.role = request.role
    user.sub_role = request.sub_role
    
    # If changing to teacher, set is_active to False for approval process
    if request.sub_role == "teacher":
        user.is_active = False
    
    db.commit()
    
    return {
        "message": "User role updated successfully",
        "user_id": user.id,
        "role": user.role,
        "sub_role": user.sub_role
    }

@router.delete("/users/{user_id}")
def delete_user(
    user_id: int,
    db: Session = Depends(get_db),
    admin: User = Depends(verify_admin)
):
    """Delete a user (soft delete by deactivating)"""
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    if user.role == "admin":
        raise HTTPException(status_code=400, detail="Cannot delete admin user")
    
    user.is_active = False
    db.commit()
    
    return {"message": "User deactivated successfully", "user_id": user_id}

@router.get("/analytics/overview")
def get_analytics_overview(
    db: Session = Depends(get_db),
    admin: User = Depends(verify_admin)
):
    """Get platform analytics overview"""
    
    # Course analytics
    courses_by_difficulty = db.query(Course.difficulty, db.func.count(Course.id)).group_by(Course.difficulty).all()
    
    # Enrollment trends (last 30 days)
    thirty_days_ago = datetime.utcnow().replace(day=1)  # Simplified for demo
    recent_enrollments = db.query(Enrollment).filter(
        Enrollment.enrolled_at >= thirty_days_ago
    ).count()
    
    # Top courses by enrollment
    top_courses = db.query(Course.title, Course.enrollment_count).order_by(
        Course.enrollment_count.desc()
    ).limit(10).all()
    
    return {
        "courses_by_difficulty": [{"difficulty": d, "count": c} for d, c in courses_by_difficulty],
        "recent_enrollments": recent_enrollments,
        "top_courses": [{"title": title, "enrollments": count} for title, count in top_courses]
    }

@router.post("/users/bulk-action")
def bulk_user_action(
    user_ids: List[int],
    action: str,  # "activate", "deactivate", "delete", "promote_to_teacher"
    db: Session = Depends(get_db),
    admin: User = Depends(verify_admin)
):
    """Perform bulk actions on multiple users"""
    users = db.query(User).filter(User.id.in_(user_ids)).all()
    
    if not users:
        raise HTTPException(status_code=404, detail="No users found")
    
    results = []
    for user in users:
        try:
            if action == "activate":
                user.is_active = True
            elif action == "deactivate":
                user.is_active = False
            elif action == "delete":
                if user.role != "admin":
                    user.is_active = False
            elif action == "promote_to_teacher":
                user.sub_role = "teacher"
                user.is_active = False  # Requires approval
            
            results.append({"user_id": user.id, "status": "success"})
        except Exception as e:
            results.append({"user_id": user.id, "status": "error", "message": str(e)})
    
    db.commit()
    return {"results": results}

@router.get("/system/health")
def get_system_health(
    db: Session = Depends(get_db),
    admin: User = Depends(verify_admin)
):
    """Get system health metrics"""
    try:
        # Database connection test
        db.execute("SELECT 1")
        db_status = "healthy"
    except:
        db_status = "unhealthy"
    
    # Get system stats
    total_users = db.query(User).count()
    active_users = db.query(User).filter(User.is_active == True).count()
    total_courses = db.query(Course).count()
    
    return {
        "database": db_status,
        "users": {
            "total": total_users,
            "active": active_users,
            "inactive": total_users - active_users
        },
        "courses": {
            "total": total_courses
        },
        "timestamp": datetime.utcnow()
    }

@router.post("/courses/bulk-publish")
def bulk_publish_courses(
    course_ids: List[int],
    publish: bool = True,
    db: Session = Depends(get_db),
    admin: User = Depends(verify_admin)
):
    """Bulk publish/unpublish courses"""
    courses = db.query(Course).filter(Course.id.in_(course_ids)).all()
    
    if not courses:
        raise HTTPException(status_code=404, detail="No courses found")
    
    for course in courses:
        course.is_published = publish
    
    db.commit()
    
    return {
        "message": f"Successfully {'published' if publish else 'unpublished'} {len(courses)} courses",
        "course_ids": course_ids
    }
