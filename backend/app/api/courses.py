from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.database import get_db
from app.models.course import Course
from app.models.user import User
from app.schemas.course import CourseCreate, CourseOut
from app.services.deps import get_current_user
from typing import List

router = APIRouter(prefix="/api/courses", tags=["courses"])

@router.post("/", response_model=CourseOut, status_code=201)
def create_course(payload: CourseCreate, db: Session = Depends(get_db), user: User = Depends(get_current_user)):
    if not user.is_teacher:
        raise HTTPException(status_code=403, detail="Only teachers can create courses")
    c = Course(title=payload.title, description=payload.description, teacher_id=user.id)
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
