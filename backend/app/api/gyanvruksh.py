from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy import func, and_, or_
from ..database import get_db
from ..models.user import User
from ..models.course import Course
from ..models.enrollment import Enrollment
from ..models.progress import UserProgress
from ..models.category import Category
from ..services.deps import get_current_user
from ..utils.errors import auth_error
from typing import List, Dict, Optional
from datetime import datetime, timedelta

router = APIRouter(prefix="/api/gyanvruksh", tags=["gyanvruksh"])

@router.get("/leaderboard", response_model=List[dict])
def get_leaderboard(
    category: Optional[str] = None,
    limit: int = 20,
    db: Session = Depends(get_db)
):
    """
    Returns top students ordered by gyan_coins descending.
    Optionally filter by category.
    """
    query = db.query(User).filter(User.sub_role == "student")

    if category:
        # Get courses in the category and their enrolled students
        category_courses = db.query(Course.id).join(Category).filter(Category.name == category).subquery()
        enrolled_users = db.query(Enrollment.student_id).filter(Enrollment.course_id.in_(category_courses)).subquery()
        query = query.filter(User.id.in_(enrolled_users))

    users = query.order_by(User.gyan_coins.desc()).limit(limit).all()
    return [{"id": u.id, "full_name": u.full_name, "gyan_coins": u.gyan_coins} for u in users]

@router.get("/profile")
def get_profile(user: User = Depends(get_current_user)):
    """
    Returns current user profile including gyan_coins and learning stats.
    """
    return {
        "id": user.id,
        "full_name": user.full_name,
        "email": user.email,
        "gyan_coins": user.gyan_coins,
        "role": user.role,
        "sub_role": user.sub_role,
        "preferred_language": user.preferred_language,
        "educational_qualification": user.educational_qualification,
        "is_teacher": user.is_teacher,
        "is_active": user.is_active,
        "created_at": user.created_at,
    }

@router.get("/recommendations")
def get_recommendations(
    limit: int = 10,
    algorithm: str = "collaborative",  # collaborative, content_based, popularity
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Get AI-powered course recommendations for the current user.
    Uses multiple recommendation algorithms.
    """
    if current_user.sub_role != "student":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only students can get course recommendations"
        )

    recommendations = []

    if algorithm == "collaborative":
        recommendations = _get_collaborative_recommendations(current_user.id, db)
    elif algorithm == "content_based":
        recommendations = _get_content_based_recommendations(current_user.id, db)
    elif algorithm == "popularity":
        recommendations = _get_popularity_recommendations(current_user.id, db)
    else:
        # Hybrid approach - combine all algorithms
        recommendations = _get_hybrid_recommendations(current_user.id, db)

    # Limit results and exclude already enrolled courses
    enrolled_course_ids = db.query(Enrollment.course_id).filter(
        Enrollment.student_id == current_user.id
    ).subquery()

    recommendations = [
        rec for rec in recommendations
        if rec["course_id"] not in enrolled_course_ids
    ][:limit]

    return recommendations

@router.get("/recommendations/debug")
def debug_recommendations(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Debug endpoint to see recommendation scores and explanations.
    """
    if current_user.role != "admin":
        raise HTTPException(status_code=403, detail="Admin access required")

    all_recommendations = {
        "collaborative": _get_collaborative_recommendations(current_user.id, db),
        "content_based": _get_content_based_recommendations(current_user.id, db),
        "popularity": _get_popularity_recommendations(current_user.id, db),
        "hybrid": _get_hybrid_recommendations(current_user.id, db),
    }

    return all_recommendations

def _get_collaborative_recommendations(user_id: int, db: Session) -> List[Dict]:
    """Collaborative filtering based on similar users' preferences"""
    recommendations = []

    # Get user's enrolled courses and progress
    user_enrollments = db.query(Enrollment).filter(Enrollment.student_id == user_id).all()
    if not user_enrollments:
        return []

    user_course_ids = [e.course_id for e in user_enrollments]

    # Find users with similar course enrollments
    similar_users = db.query(Enrollment.student_id).filter(
        Enrollment.course_id.in_(user_course_ids),
        Enrollment.student_id != user_id
    ).subquery()

    # Get courses that similar users enrolled in but current user hasn't
    recommended_courses = db.query(Enrollment.course_id).filter(
        Enrollment.student_id.in_(similar_users),
        ~Enrollment.course_id.in_(user_course_ids)
    ).subquery()

    # Get course details with recommendation scores
    courses = db.query(Course).filter(
        Course.id.in_(recommended_courses),
        Course.is_published == True
    ).all()

    for course in courses:
        # Calculate recommendation score based on popularity among similar users
        popularity = db.query(Enrollment).filter(
            Enrollment.course_id == course.id
        ).count()

        recommendations.append({
            "course_id": course.id,
            "title": course.title,
            "description": course.description,
            "difficulty": course.difficulty,
            "total_hours": course.total_hours,
            "recommendation_score": min(popularity * 10, 100),  # Scale to 0-100
            "algorithm": "collaborative",
            "reason": f"Popular among users with similar interests ({popularity} enrollments)"
        })

    return sorted(recommendations, key=lambda x: x["recommendation_score"], reverse=True)

def _get_content_based_recommendations(user_id: int, db: Session) -> List[Dict]:
    """Content-based filtering based on user's preferences and course content"""
    recommendations = []

    # Get user's preferences and enrolled courses
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        return []

    user_enrollments = db.query(Enrollment).filter(Enrollment.student_id == user_id).all()
    enrolled_course_ids = [e.course_id for e in user_enrollments]

    # Get categories of user's enrolled courses
    user_categories = db.query(Course.category_id).filter(
        Course.id.in_(enrolled_course_ids)
    ).subquery()

    # Find courses in similar categories that user hasn't enrolled in
    courses = db.query(Course).filter(
        Course.category_id.in_(user_categories),
        ~Course.id.in_(enrolled_course_ids),
        Course.is_published == True
    ).all()

    for course in courses:
        # Calculate recommendation score based on category similarity and course quality
        base_score = 70  # Base score for category match

        # Boost score for courses with good ratings/popularity
        enrollment_count = db.query(Enrollment).filter(
            Enrollment.course_id == course.id
        ).count()

        quality_score = min(enrollment_count * 5, 30)  # Up to 30 points for popularity

        total_score = min(base_score + quality_score, 100)

        recommendations.append({
            "course_id": course.id,
            "title": course.title,
            "description": course.description,
            "difficulty": course.difficulty,
            "total_hours": course.total_hours,
            "recommendation_score": total_score,
            "algorithm": "content_based",
            "reason": f"Matches your interest in this category ({enrollment_count} students enrolled)"
        })

    return sorted(recommendations, key=lambda x: x["recommendation_score"], reverse=True)

def _get_popularity_recommendations(user_id: int, db: Session) -> List[Dict]:
    """Popularity-based recommendations for trending courses"""
    recommendations = []

    # Get recently published popular courses
    thirty_days_ago = datetime.utcnow() - timedelta(days=30)

    courses = db.query(Course).filter(
        Course.is_published == True,
        Course.created_at >= thirty_days_ago
    ).all()

    for course in courses:
        # Calculate popularity score
        enrollment_count = db.query(Enrollment).filter(
            Enrollment.course_id == course.id
        ).count()

        # Recent enrollments get higher score
        recent_enrollments = db.query(Enrollment).filter(
            Enrollment.course_id == course.id,
            Enrollment.enrolled_at >= thirty_days_ago
        ).count()

        # Base score from total enrollments
        base_score = min(enrollment_count * 2, 50)

        # Bonus for recent activity
        recent_bonus = min(recent_enrollments * 10, 50)

        total_score = min(base_score + recent_bonus, 100)

        recommendations.append({
            "course_id": course.id,
            "title": course.title,
            "description": course.description,
            "difficulty": course.difficulty,
            "total_hours": course.total_hours,
            "recommendation_score": total_score,
            "algorithm": "popularity",
            "reason": f"Trending course ({enrollment_count} total enrollments, {recent_enrollments} recent)"
        })

    return sorted(recommendations, key=lambda x: x["recommendation_score"], reverse=True)

def _get_hybrid_recommendations(user_id: int, db: Session) -> List[Dict]:
    """Hybrid approach combining multiple recommendation algorithms"""
    collaborative = _get_collaborative_recommendations(user_id, db)
    content_based = _get_content_based_recommendations(user_id, db)
    popularity = _get_popularity_recommendations(user_id, db)

    # Combine and deduplicate recommendations
    all_recommendations = {}
    course_scores = {}

    # Weight different algorithms
    algorithm_weights = {
        "collaborative": 0.4,
        "content_based": 0.3,
        "popularity": 0.3
    }

    for rec in collaborative:
        course_id = rec["course_id"]
        if course_id not in all_recommendations:
            all_recommendations[course_id] = rec.copy()
            course_scores[course_id] = rec["recommendation_score"] * algorithm_weights["collaborative"]
        else:
            # Update score with weighted average
            existing_score = course_scores[course_id]
            new_score = rec["recommendation_score"] * algorithm_weights["collaborative"]
            course_scores[course_id] = (existing_score + new_score) / 2

    for rec in content_based:
        course_id = rec["course_id"]
        if course_id not in all_recommendations:
            all_recommendations[course_id] = rec.copy()
            course_scores[course_id] = rec["recommendation_score"] * algorithm_weights["content_based"]
        else:
            existing_score = course_scores[course_id]
            new_score = rec["recommendation_score"] * algorithm_weights["content_based"]
            course_scores[course_id] = (existing_score + new_score) / 2

    for rec in popularity:
        course_id = rec["course_id"]
        if course_id not in all_recommendations:
            all_recommendations[course_id] = rec.copy()
            course_scores[course_id] = rec["recommendation_score"] * algorithm_weights["popularity"]
        else:
            existing_score = course_scores[course_id]
            new_score = rec["recommendation_score"] * algorithm_weights["popularity"]
            course_scores[course_id] = (existing_score + new_score) / 2

    # Update recommendation scores and algorithm info
    for course_id, rec in all_recommendations.items():
        rec["recommendation_score"] = int(course_scores[course_id])
        rec["algorithm"] = "hybrid"
        rec["reason"] = "Combined recommendation from multiple algorithms"

    return sorted(
        list(all_recommendations.values()),
        key=lambda x: x["recommendation_score"],
        reverse=True
    )

@router.get("/learning-path")
def get_learning_path(
    skill_level: Optional[str] = None,
    interests: Optional[List[str]] = None,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Generate a personalized learning path based on user's current progress and goals.
    """
    if current_user.sub_role != "student":
        raise HTTPException(status_code=403, detail="Only students can get learning paths")

    # Get user's current enrollments and progress
    enrollments = db.query(Enrollment).filter(Enrollment.student_id == current_user.id).all()
    progress_records = db.query(UserProgress).filter(UserProgress.user_id == current_user.id).all()

    # Determine current skill level from progress
    completed_courses = len([p for p in progress_records if p.progress_percentage >= 80])

    if skill_level:
        current_level = skill_level
    elif completed_courses >= 10:
        current_level = "advanced"
    elif completed_courses >= 5:
        current_level = "intermediate"
    else:
        current_level = "beginner"

    # Generate learning path based on skill level
    learning_path = []

    if current_level == "beginner":
        learning_path = _generate_beginner_path(db)
    elif current_level == "intermediate":
        learning_path = _generate_intermediate_path(db)
    else:
        learning_path = _generate_advanced_path(db)

    # Filter out already completed courses
    completed_course_ids = [p.course_id for p in progress_records if p.progress_percentage >= 80]

    learning_path = [
        course for course in learning_path
        if course["course_id"] not in completed_course_ids
    ]

    return {
        "current_skill_level": current_level,
        "completed_courses": completed_courses,
        "recommended_path": learning_path[:5],  # Limit to 5 courses
        "total_path_courses": len(learning_path)
    }

def _generate_beginner_path(db: Session) -> List[Dict]:
    """Generate learning path for beginners"""
    courses = db.query(Course).filter(
        Course.difficulty == "beginner",
        Course.is_published == True
    ).order_by(Course.total_hours).all()

    return [{
        "course_id": course.id,
        "title": course.title,
        "description": course.description,
        "difficulty": course.difficulty,
        "total_hours": course.total_hours,
        "category": course.category.name if course.category else "General",
        "order": idx + 1
    } for idx, course in enumerate(courses)]

def _generate_intermediate_path(db: Session) -> List[Dict]:
    """Generate learning path for intermediate learners"""
    courses = db.query(Course).filter(
        Course.difficulty.in_(["beginner", "intermediate"]),
        Course.is_published == True
    ).all()

    return [{
        "course_id": course.id,
        "title": course.title,
        "description": course.description,
        "difficulty": course.difficulty,
        "total_hours": course.total_hours,
        "category": course.category.name if course.category else "General",
        "order": idx + 1
    } for idx, course in enumerate(courses)]

def _generate_advanced_path(db: Session) -> List[Dict]:
    """Generate learning path for advanced learners"""
    courses = db.query(Course).filter(
        Course.difficulty.in_(["intermediate", "advanced"]),
        Course.is_published == True
    ).all()

    return [{
        "course_id": course.id,
        "title": course.title,
        "description": course.description,
        "difficulty": course.difficulty,
        "total_hours": course.total_hours,
        "category": course.category.name if course.category else "General",
        "order": idx + 1
    } for idx, course in enumerate(courses)]

@router.get("/trending-courses")
def get_trending_courses(
    limit: int = 10,
    days: int = 7,
    db: Session = Depends(get_db)
):
    """
    Get trending courses based on recent enrollments.
    """
    cutoff_date = datetime.utcnow() - timedelta(days=days)

    # Get courses with most enrollments in the last N days
    trending_courses = db.query(
        Enrollment.course_id,
        func.count(Enrollment.id).label('enrollment_count')
    ).filter(
        Enrollment.enrolled_at >= cutoff_date
    ).group_by(
        Enrollment.course_id
    ).subquery()

    courses = db.query(Course).join(
        trending_courses,
        Course.id == trending_courses.c.course_id
    ).filter(
        Course.is_published == True
    ).order_by(
        trending_courses.c.enrollment_count.desc()
    ).limit(limit).all()

    return [{
        "course_id": course.id,
        "title": course.title,
        "description": course.description,
        "difficulty": course.difficulty,
        "total_hours": course.total_hours,
        "enrollment_count": db.query(Enrollment).filter(
            Enrollment.course_id == course.id,
            Enrollment.enrolled_at >= cutoff_date
        ).count(),
        "category": course.category.name if course.category else "General"
    } for course in courses]
