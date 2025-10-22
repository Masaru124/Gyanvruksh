from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List, Optional
import asyncio
import httpx
from pydantic import BaseModel
from datetime import datetime

from ..database import get_db
from ..services.deps import get_current_user
from ..models.user import User
from ..models.course import Course
from ..models.lesson import Lesson
from ..utils.errors import not_found_error

router = APIRouter(prefix="/api/ai", tags=["ai"])

class AIChatRequest(BaseModel):
    message: str
    context: Optional[str] = None  # Course/lesson context
    conversation_id: Optional[str] = None

class AIChatResponse(BaseModel):
    response: str
    conversation_id: str
    suggestions: Optional[List[str]] = None

class AITutorRequest(BaseModel):
    course_id: int
    lesson_id: Optional[int] = None
    question: str
    difficulty_level: str = "intermediate"

@router.post("/chat")
async def ai_chat(
    request: AIChatRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Chat with AI tutor"""
    try:
        # OpenAI API configuration (should be in environment variables)
        OPENAI_API_KEY = "YOUR_OPENAI_API_KEY"  # Should be in environment variables

        # Prepare the context for the AI
        system_prompt = """You are an AI tutor for an educational platform called Gyanvruksh.
        You help students learn various subjects including programming, mathematics, science, and more.
        Be helpful, encouraging, and provide clear explanations.
        If the user asks about a specific course or lesson, provide relevant educational content."""

        if request.context:
            system_prompt += f"\nContext: {request.context}"

        # Make request to OpenAI
        async with httpx.AsyncClient() as client:
            openai_response = await client.post(
                "https://api.openai.com/v1/chat/completions",
                headers={
                    "Authorization": f"Bearer {OPENAI_API_KEY}",
                    "Content-Type": "application/json"
                },
                json={
                    "model": "gpt-3.5-turbo",
                    "messages": [
                        {"role": "system", "content": system_prompt},
                        {"role": "user", "content": request.message}
                    ],
                    "max_tokens": 1000,
                    "temperature": 0.7
                },
                timeout=30.0
            )

        if openai_response.status_code == 200:
            result = openai_response.json()
            ai_response = result["choices"][0]["message"]["content"]

            return {
                "response": ai_response,
                "conversation_id": request.conversation_id or f"conv_{current_user.id}_{datetime.now().isoformat()}",
                "success": True
            }
        else:
            return {
                "response": "I'm sorry, I'm having trouble responding right now. Please try again later.",
                "conversation_id": request.conversation_id or f"conv_{current_user.id}_{datetime.now().isoformat()}",
                "success": False,
                "error": "OpenAI API error"
            }

    except Exception as e:
        return {
            "response": "I'm experiencing technical difficulties. Please try again later.",
            "conversation_id": request.conversation_id or f"conv_{current_user.id}_{datetime.now().isoformat()}",
            "success": False,
            "error": str(e)
        }


@router.post("/tutor")
async def ai_tutor_help(
    request: AITutorRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Get AI tutoring help for specific course/lesson"""
    try:
        # Verify course exists and user has access
        course = db.query(Course).filter(Course.id == request.course_id).first()
        if not course:
            raise not_found_error("Course")

        # Check if user is enrolled in the course
        if current_user.sub_role == "student":
            enrollment = db.query(Enrollment).filter(
                Enrollment.student_id == current_user.id,
                Enrollment.course_id == request.course_id
            ).first()
            if not enrollment:
                raise HTTPException(
                    status_code=status.HTTP_403_FORBIDDEN,
                    detail="You must be enrolled in this course to get AI tutoring help"
                )

        # Get lesson context if provided
        lesson_context = ""
        if request.lesson_id:
            lesson = db.query(Lesson).filter(
                Lesson.id == request.lesson_id,
                Lesson.course_id == request.course_id
            ).first()
            if lesson:
                lesson_context = f"Lesson: {lesson.title}\nContent: {lesson.content_text or 'No content available'}"

        # OpenAI API configuration
        OPENAI_API_KEY = "YOUR_OPENAI_API_KEY"  # Should be in environment variables

        # Create specific prompt for tutoring
        system_prompt = f"""You are an AI tutor helping a student with {course.title}.
        The student is asking about: {request.question}
        Difficulty level: {request.difficulty_level}

        Course context: {course.description}
        {lesson_context}

        Provide a helpful, educational response that's appropriate for the student's level.
        Include examples and explanations where appropriate."""

        async with httpx.AsyncClient() as client:
            openai_response = await client.post(
                "https://api.openai.com/v1/chat/completions",
                headers={
                    "Authorization": f"Bearer {OPENAI_API_KEY}",
                    "Content-Type": "application/json"
                },
                json={
                    "model": "gpt-3.5-turbo",
                    "messages": [
                        {"role": "system", "content": system_prompt},
                        {"role": "user", "content": request.question}
                    ],
                    "max_tokens": 1500,
                    "temperature": 0.7
                },
                timeout=30.0
            )

        if openai_response.status_code == 200:
            result = openai_response.json()
            ai_response = result["choices"][0]["message"]["content"]

            # Generate follow-up suggestions
            suggestions = [
                "Can you explain this concept with a different example?",
                "What are the most common mistakes students make with this topic?",
                "How does this relate to real-world applications?"
            ]

            return {
                "response": ai_response,
                "suggestions": suggestions,
                "course_title": course.title,
                "lesson_title": lesson.title if request.lesson_id and lesson else None,
                "success": True
            }
        else:
            return {
                "response": "I'm sorry, I'm having trouble providing tutoring help right now. Please try again later.",
                "success": False,
                "error": "OpenAI API error"
            }

    except Exception as e:
        return {
            "response": "I'm experiencing technical difficulties. Please try again later.",
            "success": False,
            "error": str(e)
        }


@router.get("/suggestions/{course_id}")
async def get_ai_suggestions(
    course_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Get AI-powered learning suggestions for a course"""
    try:
        # Verify course exists
        course = db.query(Course).filter(Course.id == course_id).first()
        if not course:
            raise not_found_error("Course")

        # Check if user is enrolled
        if current_user.sub_role == "student":
            enrollment = db.query(Enrollment).filter(
                Enrollment.student_id == current_user.id,
                Enrollment.course_id == course_id
            ).first()
            if not enrollment:
                raise HTTPException(
                    status_code=status.HTTP_403_FORBIDDEN,
                    detail="You must be enrolled in this course to get suggestions"
                )

        # Generate suggestions based on course content and user progress
        suggestions = [
            {
                "type": "practice",
                "title": "Practice Exercises",
                "description": f"Work on additional practice problems for {course.title}",
                "difficulty": "intermediate"
            },
            {
                "type": "review",
                "title": "Review Session",
                "description": "Review key concepts from recent lessons",
                "difficulty": "beginner"
            },
            {
                "type": "extension",
                "title": "Advanced Topics",
                "description": "Explore advanced concepts related to this course",
                "difficulty": "advanced"
            }
        ]

        return {
            "course_title": course.title,
            "suggestions": suggestions,
            "total_suggestions": len(suggestions)
        }

    except Exception as e:
        return {
            "suggestions": [],
            "error": str(e),
            "success": False
        }
