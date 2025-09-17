from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from app.database import get_db
from app.models.assignment import Assignment, Grade
from app.schemas.assignment import AssignmentCreate, AssignmentRead, GradeCreate, GradeRead
from app.services.deps import get_current_user
from app.models.user import User

router = APIRouter(prefix="/api/assignments", tags=["assignments"])

@router.post("/", response_model=AssignmentRead)
def create_assignment(
    assignment_in: AssignmentCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    if current_user.sub_role != "teacher":
        raise HTTPException(status_code=403, detail="Only teachers can create assignments")
    assignment = Assignment(**assignment_in.dict(), teacher_id=current_user.id)
    db.add(assignment)
    db.commit()
    db.refresh(assignment)
    return assignment

@router.get("/", response_model=List[AssignmentRead])
def list_assignments(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    if current_user.sub_role == "teacher":
        assignments = db.query(Assignment).filter(Assignment.teacher_id == current_user.id).all()
    else:
        assignments = db.query(Assignment).all()
    return assignments

@router.post("/{assignment_id}/grade", response_model=GradeRead)
def grade_assignment(
    assignment_id: int,
    grade_in: GradeCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    if current_user.sub_role != "teacher":
        raise HTTPException(status_code=403, detail="Only teachers can grade assignments")
    assignment = db.query(Assignment).filter(Assignment.id == assignment_id).first()
    if not assignment:
        raise HTTPException(status_code=404, detail="Assignment not found")
    grade = Grade(
        assignment_id=assignment_id,
        student_id=grade_in.student_id,
        score=grade_in.score,
        feedback=grade_in.feedback,
        graded_by=current_user.id,
    )
    db.add(grade)
    db.commit()
    db.refresh(grade)
    return grade

@router.get("/{assignment_id}/grades", response_model=List[GradeRead])
def get_grades(
    assignment_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    grades = db.query(Grade).filter(Grade.assignment_id == assignment_id).all()
    return grades
