from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from app.database import get_db
from app.models.quiz import Quiz, Question, QuizAttempt
from app.models.course import Course
from app.schemas.quiz import QuizOut as QuizSchema, QuizCreate, QuizUpdate, QuestionOut, QuizAttemptOut, QuizAttemptCreate
from app.services.deps import get_current_user
from app.models.user import User
import json

router = APIRouter(prefix="/api/quizzes", tags=["quizzes"])

@router.get("/", response_model=List[QuizSchema])
def get_quizzes(course_id: int = None, db: Session = Depends(get_db)):
    """
    Get all quizzes, optionally filtered by course_id
    """
    query = db.query(Quiz)
    if course_id:
        query = query.filter(Quiz.course_id == course_id)
    return query.filter(Quiz.is_active == True).all()

@router.get("/{quiz_id}", response_model=QuizSchema)
def get_quiz(quiz_id: int, db: Session = Depends(get_db)):
    """
    Get a specific quiz by ID
    """
    quiz = db.query(Quiz).filter(Quiz.id == quiz_id).first()
    if not quiz:
        raise HTTPException(status_code=404, detail="Quiz not found")
    return quiz

@router.get("/{quiz_id}/questions", response_model=List[QuestionOut])
def get_quiz_questions(quiz_id: int, db: Session = Depends(get_db)):
    """
    Get all questions for a quiz
    """
    questions = db.query(Question).filter(Question.quiz_id == quiz_id).order_by(Question.order_index).all()
    return questions

@router.post("/", response_model=QuizSchema)
def create_quiz(quiz: QuizCreate, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    """
    Create a new quiz with questions (Teacher/Admin only)
    """
    course = db.query(Course).filter(Course.id == quiz.course_id).first()
    if not course:
        raise HTTPException(status_code=404, detail="Course not found")
    
    if current_user.role != "admin" and course.teacher_id != current_user.id:
        raise HTTPException(status_code=403, detail="Not authorized to create quiz for this course")
    
    # Create quiz
    quiz_data = quiz.model_dump()
    questions = quiz_data.pop("questions")
    db_quiz = Quiz(**quiz_data)
    db.add(db_quiz)
    db.commit()
    db.refresh(db_quiz)
    
    # Create questions
    for question_data in questions:
        question = Question(quiz_id=db_quiz.id, **question_data)
        db.add(question)
    
    db.commit()
    return db_quiz

@router.put("/{quiz_id}", response_model=QuizSchema)
def update_quiz(quiz_id: int, quiz_update: QuizUpdate, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    """
    Update a quiz (Teacher/Admin only)
    """
    quiz = db.query(Quiz).filter(Quiz.id == quiz_id).first()
    if not quiz:
        raise HTTPException(status_code=404, detail="Quiz not found")
    
    course = db.query(Course).filter(Course.id == quiz.course_id).first()
    if current_user.role != "admin" and course.teacher_id != current_user.id:
        raise HTTPException(status_code=403, detail="Not authorized to update this quiz")
    
    for key, value in quiz_update.model_dump(exclude_unset=True).items():
        setattr(quiz, key, value)
    
    db.commit()
    db.refresh(quiz)
    return quiz

@router.post("/{quiz_id}/attempt", response_model=QuizAttemptOut)
def submit_quiz_attempt(quiz_id: int, attempt: QuizAttemptCreate, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    """
    Submit a quiz attempt and calculate score
    """
    quiz = db.query(Quiz).filter(Quiz.id == quiz_id).first()
    if not quiz:
        raise HTTPException(status_code=404, detail="Quiz not found")
    
    questions = db.query(Question).filter(Question.quiz_id == quiz_id).all()
    total_questions = len(questions)
    correct_answers = 0
    
    for question in questions:
        user_answer = attempt.answers.get(str(question.id))
        if user_answer == question.correct_answer:
            correct_answers += 1
    
    score = int((correct_answers / total_questions) * 100) if total_questions > 0 else 0
    
    db_attempt = QuizAttempt(
        quiz_id=quiz_id,
        user_id=current_user.id,
        score=score,
        total_questions=total_questions,
        correct_answers=correct_answers
    )
    db.add(db_attempt)
    db.commit()
    db.refresh(db_attempt)
    
    # Award gyan_coins if passed
    if score >= quiz.passing_score:
        current_user.gyan_coins += 10  # Reward for passing
        db.commit()
    
    return db_attempt

@router.get("/{quiz_id}/attempts", response_model=List[QuizAttemptOut])
def get_quiz_attempts(quiz_id: int, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    """
    Get user's attempts for a quiz
    """
    attempts = db.query(QuizAttempt).filter(
        QuizAttempt.quiz_id == quiz_id,
        QuizAttempt.user_id == current_user.id
    ).order_by(QuizAttempt.completed_at.desc()).all()
    return attempts
