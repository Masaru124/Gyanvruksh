from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, Form
from sqlalchemy.orm import Session
from typing import List, Optional
from ..database import get_db
from ..models.assignment import Assignment, Grade, AssignmentSubmission
from ..schemas.assignment import AssignmentCreate, AssignmentRead, GradeCreate, GradeRead, AssignmentSubmissionCreate, AssignmentSubmissionRead
from ..services.deps import get_current_user
from ..models.user import User
from ..utils.errors import not_found_error, authz_error
from pydantic import BaseModel
import shutil
import os
from datetime import datetime

router = APIRouter(prefix="/api/assignments", tags=["assignments"])

class AssignmentSubmissionRequest(BaseModel):
    content: str
    attachment_url: Optional[str] = None

class AssignmentSubmissionResponse(BaseModel):
    id: int
    assignment_id: int
    student_id: int
    content: str
    attachment_url: Optional[str]
    submitted_at: datetime
    status: str

@router.post("/", response_model=AssignmentRead)
def create_assignment(
    assignment_in: AssignmentCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Create a new assignment (teachers only)"""
    if current_user.sub_role != "teacher":
        raise authz_error("Only teachers can create assignments")

    assignment = Assignment(**assignment_in.model_dump(), teacher_id=current_user.id)
    db.add(assignment)
    db.commit()
    db.refresh(assignment)
    return assignment

@router.get("/", response_model=List[AssignmentRead])
def list_assignments(
    course_id: Optional[int] = None,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """List assignments with optional course filtering"""
    query = db.query(Assignment)

    if current_user.sub_role == "teacher":
        query = query.filter(Assignment.teacher_id == current_user.id)
    elif course_id:
        query = query.filter(Assignment.course_id == course_id)
    else:
        # For students, show assignments from their enrolled courses
        enrolled_course_ids = db.query(Enrollment.course_id).filter(
            Enrollment.student_id == current_user.id
        ).subquery()
        query = query.filter(Assignment.course_id.in_(enrolled_course_ids))

    assignments = query.all()
    return assignments

@router.post("/{assignment_id}/submit", response_model=AssignmentSubmissionResponse)
async def submit_assignment(
    assignment_id: int,
    content: str = Form(...),
    file: Optional[UploadFile] = File(None),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Submit assignment with optional file upload"""
    if current_user.sub_role != "student":
        raise authz_error("Only students can submit assignments")

    # Verify assignment exists
    assignment = db.query(Assignment).filter(Assignment.id == assignment_id).first()
    if not assignment:
        raise not_found_error("Assignment")

    # Verify student is enrolled in the course
    enrollment = db.query(Enrollment).filter(
        Enrollment.student_id == current_user.id,
        Enrollment.course_id == assignment.course_id
    ).first()
    if not enrollment:
        raise HTTPException(status_code=403, detail="Not enrolled in this course")

    # Check if assignment deadline has passed
    if assignment.due_date and assignment.due_date < datetime.utcnow():
        raise HTTPException(status_code=400, detail="Assignment deadline has passed")

    # Handle file upload if provided
    attachment_url = None
    if file and file.filename:
        # Create uploads directory if it doesn't exist
        uploads_dir = "uploads/assignments"
        os.makedirs(uploads_dir, exist_ok=True)

        # Save file
        file_path = os.path.join(uploads_dir, f"{current_user.id}_{assignment_id}_{file.filename}")
        with open(file_path, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)

        attachment_url = file_path

    # Check if student already submitted
    existing_submission = db.query(AssignmentSubmission).filter(
        AssignmentSubmission.assignment_id == assignment_id,
        AssignmentSubmission.student_id == current_user.id
    ).first()

    if existing_submission:
        # Update existing submission
        existing_submission.content = content
        existing_submission.attachment_url = attachment_url
        existing_submission.submitted_at = datetime.utcnow()
        existing_submission.status = "submitted"
        db.commit()
        db.refresh(existing_submission)
        return existing_submission
    else:
        # Create new submission
        submission = AssignmentSubmission(
            assignment_id=assignment_id,
            student_id=current_user.id,
            content=content,
            attachment_url=attachment_url,
            status="submitted"
        )
        db.add(submission)
        db.commit()
        db.refresh(submission)
        return submission

@router.get("/{assignment_id}/submissions")
def get_assignment_submissions(
    assignment_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Get all submissions for an assignment (teachers only)"""
    if current_user.sub_role != "teacher":
        raise authz_error("Only teachers can view submissions")

    # Verify assignment belongs to teacher
    assignment = db.query(Assignment).filter(
        Assignment.id == assignment_id,
        Assignment.teacher_id == current_user.id
    ).first()
    if not assignment:
        raise not_found_error("Assignment")

    submissions = db.query(AssignmentSubmission).filter(
        AssignmentSubmission.assignment_id == assignment_id
    ).all()

    return [{
        "id": sub.id,
        "assignment_id": sub.assignment_id,
        "student_id": sub.student_id,
        "student_name": sub.student.full_name,
        "content": sub.content,
        "attachment_url": sub.attachment_url,
        "submitted_at": sub.submitted_at.isoformat(),
        "status": sub.status,
        "grade": sub.grade,
        "feedback": sub.feedback
    } for sub in submissions]

@router.get("/my-submissions")
def get_my_submissions(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Get current user's assignment submissions"""
    if current_user.sub_role != "student":
        raise authz_error("Only students can view their submissions")

    submissions = db.query(AssignmentSubmission).filter(
        AssignmentSubmission.student_id == current_user.id
    ).order_by(AssignmentSubmission.submitted_at.desc()).all()

    return [{
        "id": sub.id,
        "assignment_id": sub.assignment_id,
        "assignment_title": sub.assignment.title,
        "course_title": sub.assignment.course.title,
        "content": sub.content,
        "attachment_url": sub.attachment_url,
        "submitted_at": sub.submitted_at.isoformat(),
        "status": sub.status,
        "grade": sub.grade,
        "feedback": sub.feedback,
        "max_score": sub.assignment.max_score
    } for sub in submissions]

@router.post("/{assignment_id}/grade", response_model=GradeRead)
def grade_assignment(
    assignment_id: int,
    student_id: int,
    score: float,
    feedback: Optional[str] = None,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Grade a student's assignment submission"""
    if current_user.sub_role != "teacher":
        raise authz_error("Only teachers can grade assignments")

    # Verify assignment belongs to teacher
    assignment = db.query(Assignment).filter(
        Assignment.id == assignment_id,
        Assignment.teacher_id == current_user.id
    ).first()
    if not assignment:
        raise not_found_error("Assignment")

    # Verify student submitted the assignment
    submission = db.query(AssignmentSubmission).filter(
        AssignmentSubmission.assignment_id == assignment_id,
        AssignmentSubmission.student_id == student_id
    ).first()
    if not submission:
        raise not_found_error("Assignment submission")

    # Check if already graded
    existing_grade = db.query(Grade).filter(
        Grade.assignment_id == assignment_id,
        Grade.student_id == student_id
    ).first()

    if existing_grade:
        # Update existing grade
        existing_grade.score = score
        existing_grade.feedback = feedback
        existing_grade.graded_at = datetime.utcnow()
        db.commit()
        db.refresh(existing_grade)
        return existing_grade
    else:
        # Create new grade
        grade = Grade(
            assignment_id=assignment_id,
            student_id=student_id,
            score=score,
            feedback=feedback,
            graded_by=current_user.id,
            graded_at=datetime.utcnow()
        )
        db.add(grade)

        # Update submission status
        submission.status = "graded"
        submission.grade = score
        submission.feedback = feedback

        db.commit()
        db.refresh(grade)
        return grade

@router.get("/{assignment_id}/grades", response_model=List[GradeRead])
def get_grades(
    assignment_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Get all grades for an assignment"""
    # Verify assignment exists and user has access
    assignment = db.query(Assignment).filter(Assignment.id == assignment_id).first()
    if not assignment:
        raise not_found_error("Assignment")

    # Teachers can see all grades, students can only see their own
    if current_user.sub_role == "teacher":
        if assignment.teacher_id != current_user.id:
            raise authz_error("Access denied")
        grades = db.query(Grade).filter(Grade.assignment_id == assignment_id).all()
    else:
        grades = db.query(Grade).filter(
            Grade.assignment_id == assignment_id,
            Grade.student_id == current_user.id
        ).all()

    return grades

@router.get("/{assignment_id}")
def get_assignment_details(
    assignment_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Get detailed assignment information"""
    assignment = db.query(Assignment).filter(Assignment.id == assignment_id).first()
    if not assignment:
        raise not_found_error("Assignment")

    # Check if user has access (teacher or enrolled student)
    has_access = False
    if current_user.sub_role == "teacher" and assignment.teacher_id == current_user.id:
        has_access = True
    elif current_user.sub_role == "student":
        enrollment = db.query(Enrollment).filter(
            Enrollment.student_id == current_user.id,
            Enrollment.course_id == assignment.course_id
        ).first()
        if enrollment:
            has_access = True

    if not has_access:
        raise authz_error("Access denied")

    # Get submission if student
    submission = None
    if current_user.sub_role == "student":
        submission = db.query(AssignmentSubmission).filter(
            AssignmentSubmission.assignment_id == assignment_id,
            AssignmentSubmission.student_id == current_user.id
        ).first()

    return {
        "id": assignment.id,
        "title": assignment.title,
        "description": assignment.description,
        "course_id": assignment.course_id,
        "course_title": assignment.course.title,
        "teacher_name": assignment.teacher.full_name,
        "due_date": assignment.due_date.isoformat() if assignment.due_date else None,
        "max_score": assignment.max_score,
        "instructions": assignment.instructions,
        "attachment_url": assignment.attachment_url,
        "created_at": assignment.created_at.isoformat(),
        "submission": {
            "id": submission.id if submission else None,
            "content": submission.content if submission else None,
            "attachment_url": submission.attachment_url if submission else None,
            "submitted_at": submission.submitted_at.isoformat() if submission and submission.submitted_at else None,
            "status": submission.status if submission else "not_submitted",
            "grade": submission.grade if submission else None,
            "feedback": submission.feedback if submission else None
        } if submission else None
    }
