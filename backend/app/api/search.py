from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from typing import List, Optional, Dict
from app.database import get_db
from app.models.course import Course
from app.models.category import Category
from app.models.user import User
from app.models.enrollment import Enrollment
from app.services.deps import get_current_user
from datetime import datetime, timedelta

router = APIRouter(prefix="/api/search", tags=["search"])

# Search history storage (in production, this would be a database table)
search_history_storage: Dict[int, List[str]] = {}
bookmarks_storage: Dict[int, List[int]] = {}

@router.get("/")
def search_courses(
    q: str = Query(..., description="Search query"),
    category: Optional[str] = Query(None, description="Filter by category"),
    difficulty: Optional[str] = Query(None, description="Filter by difficulty"),
    min_rating: Optional[float] = Query(None, description="Minimum rating"),
    sort_by: str = Query("relevance", description="Sort by: relevance, rating, popularity"),
    limit: int = Query(20, description="Number of results"),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Main search endpoint that frontend expects"""
    # Store search in history
    if current_user.id not in search_history_storage:
        search_history_storage[current_user.id] = []
    search_history_storage[current_user.id].append(q)
    # Keep only last 20 searches
    search_history_storage[current_user.id] = search_history_storage[current_user.id][-20:]

    query = db.query(Course).filter(Course.is_published == True)

    # Text search in title and description
    if q:
        search_term = f"%{q}%"
        query = query.filter(
            Course.title.ilike(search_term) |
            Course.description.ilike(search_term)
        )

    # Category filter
    if category:
        query = query.filter(Course.category_id == category)

    # Difficulty filter
    if difficulty:
        query = query.filter(Course.difficulty == difficulty)

    # Rating filter
    if min_rating:
        query = query.filter(Course.rating >= min_rating)

    # Sorting
    if sort_by == "rating":
        query = query.order_by(Course.rating.desc())
    elif sort_by == "popularity":
        query = query.order_by(Course.enrollment_count.desc())
    else:  # relevance
        query = query.order_by(
            Course.title.ilike(f"{q}%").desc(),
            Course.rating.desc()
        )

    courses = query.limit(limit).all()

    # Format results
    results = []
    for course in courses:
        results.append({
            "id": course.id,
            "title": course.title,
            "description": course.description,
            "difficulty": course.difficulty,
            "rating": course.rating,
            "enrollment_count": course.enrollment_count,
            "total_hours": course.total_hours,
            "thumbnail_url": course.thumbnail_url,
            "teacher_name": course.teacher.full_name if course.teacher else "Admin",
            "category": course.category.name if course.category else None,
            "is_enrolled": db.query(Enrollment).filter(
                Enrollment.student_id == current_user.id,
                Enrollment.course_id == course.id
            ).first() is not None if current_user.sub_role == "student" else False,
            "is_bookmarked": course.id in bookmarks_storage.get(current_user.id, [])
        })

    return {
        "query": q,
        "total_results": len(results),
        "courses": results,
        "filters_applied": {
            "category": category,
            "difficulty": difficulty,
            "min_rating": min_rating,
            "sort_by": sort_by
        }
    }

@router.get("/categories")
def search_by_categories(db: Session = Depends(get_db)):
    """Get all categories for search filtering"""
    categories = db.query(Category).all()

    return {
        "categories": [{
            "id": category.id,
            "name": category.name,
            "description": category.description,
            "course_count": db.query(Course).filter(
                Course.category_id == category.id,
                Course.is_published == True
            ).count()
        } for category in categories]
    }

@router.get("/history")
def get_search_history(
    limit: int = Query(20, description="Number of history items to return"),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Get user's search history"""
    user_history = search_history_storage.get(current_user.id, [])

    return {
        "search_history": user_history[-limit:],
        "total_searches": len(user_history)
    }

@router.get("/popular")
def get_popular_searches(
    limit: int = Query(10, description="Number of popular searches to return"),
    db: Session = Depends(get_db)
):
    """Get popular/trending search terms"""
    # In a real implementation, this would analyze search logs
    # For now, return mock popular searches
    popular_searches = [
        "Python", "Machine Learning", "Web Development", "Data Science",
        "JavaScript", "React", "Database", "Mobile Development",
        "Cloud Computing", "Cybersecurity"
    ]

    return {
        "popular_searches": popular_searches[:limit],
        "trending_topics": ["AI", "Blockchain", "DevOps", "UI/UX"]
    }

@router.get("/trending")
def get_trending_courses(db: Session = Depends(get_db)):
    """Get trending/popular courses"""
    # Get courses ordered by recent enrollments and ratings
    week_ago = datetime.utcnow() - timedelta(days=7)

    trending_courses = db.query(Course).filter(
        Course.is_published == True
    ).order_by(
        Course.rating.desc(),
        Course.enrollment_count.desc()
    ).limit(20).all()

    results = []
    for course in trending_courses:
        results.append({
            "id": course.id,
            "title": course.title,
            "description": course.description,
            "difficulty": course.difficulty,
            "rating": course.rating,
            "enrollment_count": course.enrollment_count,
            "total_hours": course.total_hours,
            "thumbnail_url": course.thumbnail_url,
            "teacher_name": course.teacher.full_name if course.teacher else "Admin",
            "category": course.category.name if course.category else None,
            "trend_score": (course.rating * 0.4 + course.enrollment_count * 0.6)  # Mock trend score
        })

    return {
        "trending_courses": results,
        "total_trending": len(results)
    }

@router.get("/recent")
def get_recent_courses(
    limit: int = Query(10, description="Number of recent courses to return"),
    db: Session = Depends(get_db)
):
    """Get recently published courses"""
    recent_courses = db.query(Course).filter(
        Course.is_published == True
    ).order_by(Course.created_at.desc()).limit(limit).all()

    results = []
    for course in recent_courses:
        results.append({
            "id": course.id,
            "title": course.title,
            "description": course.description,
            "difficulty": course.difficulty,
            "rating": course.rating,
            "enrollment_count": course.enrollment_count,
            "total_hours": course.total_hours,
            "thumbnail_url": course.thumbnail_url,
            "teacher_name": course.teacher.full_name if course.teacher else "Admin",
            "category": course.category.name if course.category else None,
            "published_at": course.created_at.isoformat()
        })

    return {
        "recent_courses": results,
        "total_recent": len(results)
    }

@router.get("/bookmarks")
def get_bookmarked_courses(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Get user's bookmarked courses"""
    bookmarked_course_ids = bookmarks_storage.get(current_user.id, [])

    if not bookmarked_course_ids:
        return {"bookmarked_courses": [], "total_bookmarks": 0}

    bookmarked_courses = db.query(Course).filter(
        Course.id.in_(bookmarked_course_ids),
        Course.is_published == True
    ).all()

    results = []
    for course in bookmarked_courses:
        results.append({
            "id": course.id,
            "title": course.title,
            "description": course.description,
            "difficulty": course.difficulty,
            "rating": course.rating,
            "enrollment_count": course.enrollment_count,
            "total_hours": course.total_hours,
            "thumbnail_url": course.thumbnail_url,
            "teacher_name": course.teacher.full_name if course.teacher else "Admin",
            "category": course.category.name if course.category else None,
            "bookmarked_at": datetime.utcnow().isoformat()  # Mock timestamp
        })

    return {
        "bookmarked_courses": results,
        "total_bookmarks": len(results)
    }

@router.post("/history/add")
def add_search_to_history(
    search_term: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Add a search term to user's history"""
    if current_user.id not in search_history_storage:
        search_history_storage[current_user.id] = []

    # Avoid duplicates in recent history
    if search_term not in search_history_storage[current_user.id][-5:]:
        search_history_storage[current_user.id].append(search_term)

    # Keep only last 20 searches
    search_history_storage[current_user.id] = search_history_storage[current_user.id][-20:]

    return {
        "message": "Search added to history",
        "search_term": search_term,
        "total_history_items": len(search_history_storage[current_user.id])
    }

@router.delete("/history/remove")
def remove_search_from_history(
    search_term: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Remove a search term from user's history"""
    if current_user.id in search_history_storage:
        search_history_storage[current_user.id] = [
            term for term in search_history_storage[current_user.id]
            if term != search_term
        ]

    return {
        "message": "Search removed from history",
        "search_term": search_term,
        "remaining_items": len(search_history_storage.get(current_user.id, []))
    }

@router.delete("/history/clear")
def clear_search_history(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Clear user's search history"""
    search_history_storage[current_user.id] = []

    return {
        "message": "Search history cleared successfully",
        "cleared_items": 0
    }

@router.post("/bookmarks/toggle")
def toggle_course_bookmark(
    course_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Toggle bookmark status for a course"""
    # Verify course exists
    course = db.query(Course).filter(
        Course.id == course_id,
        Course.is_published == True
    ).first()

    if not course:
        raise HTTPException(status_code=404, detail="Course not found")

    # Initialize bookmarks for user if not exists
    if current_user.id not in bookmarks_storage:
        bookmarks_storage[current_user.id] = []

    # Toggle bookmark
    if course_id in bookmarks_storage[current_user.id]:
        bookmarks_storage[current_user.id].remove(course_id)
        action = "removed"
    else:
        bookmarks_storage[current_user.id].append(course_id)
        action = "added"

    return {
        "message": f"Course {action} to bookmarks",
        "course_id": course_id,
        "course_title": course.title,
        "is_bookmarked": action == "added",
        "total_bookmarks": len(bookmarks_storage[current_user.id])
    }

@router.get("/advanced")
def advanced_search(
    q: Optional[str] = Query(None, description="Search query"),
    categories: Optional[List[str]] = Query(None, description="Category IDs"),
    difficulties: Optional[List[str]] = Query(None, description="Difficulty levels"),
    min_rating: Optional[float] = Query(None, description="Minimum rating"),
    max_rating: Optional[float] = Query(None, description="Maximum rating"),
    min_duration: Optional[int] = Query(None, description="Minimum duration in hours"),
    max_duration: Optional[int] = Query(None, description="Maximum duration in hours"),
    has_teacher: Optional[bool] = Query(None, description="Filter by teacher availability"),
    sort_by: str = Query("relevance", description="Sort by: relevance, rating, popularity, newest"),
    limit: int = Query(20, description="Number of results"),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Advanced search with multiple filters"""
    query = db.query(Course).filter(Course.is_published == True)

    # Text search
    if q:
        search_term = f"%{q}%"
        query = query.filter(
            Course.title.ilike(search_term) |
            Course.description.ilike(search_term)
        )

    # Categories filter
    if categories:
        query = query.filter(Course.category_id.in_(categories))

    # Difficulties filter
    if difficulties:
        query = query.filter(Course.difficulty.in_(difficulties))

    # Rating filter
    if min_rating:
        query = query.filter(Course.rating >= min_rating)
    if max_rating:
        query = query.filter(Course.rating <= max_rating)

    # Duration filter
    if min_duration:
        query = query.filter(Course.total_hours >= min_duration)
    if max_duration:
        query = query.filter(Course.total_hours <= max_duration)

    # Teacher filter
    if has_teacher is not None:
        if has_teacher:
            query = query.filter(Course.teacher_id.isnot(None))
        else:
            query = query.filter(Course.teacher_id.is_(None))

    # Sorting
    if sort_by == "rating":
        query = query.order_by(Course.rating.desc())
    elif sort_by == "popularity":
        query = query.order_by(Course.enrollment_count.desc())
    elif sort_by == "newest":
        query = query.order_by(Course.created_at.desc())
    else:  # relevance
        query = query.order_by(
            Course.title.ilike(f"{q}%").desc() if q else Course.rating.desc(),
            Course.rating.desc()
        )

    courses = query.limit(limit).all()

    # Format results
    results = []
    for course in courses:
        results.append({
            "id": course.id,
            "title": course.title,
            "description": course.description,
            "difficulty": course.difficulty,
            "rating": course.rating,
            "enrollment_count": course.enrollment_count,
            "total_hours": course.total_hours,
            "thumbnail_url": course.thumbnail_url,
            "teacher_name": course.teacher.full_name if course.teacher else "Admin",
            "category": course.category.name if course.category else None,
            "is_enrolled": db.query(Enrollment).filter(
                Enrollment.student_id == current_user.id,
                Enrollment.course_id == course.id
            ).first() is not None if current_user.sub_role == "student" else False,
            "is_bookmarked": course.id in bookmarks_storage.get(current_user.id, [])
        })

    return {
        "query": q,
        "total_results": len(results),
        "courses": results,
        "filters_applied": {
            "categories": categories,
            "difficulties": difficulties,
            "min_rating": min_rating,
            "max_rating": max_rating,
            "min_duration": min_duration,
            "max_duration": max_duration,
            "has_teacher": has_teacher,
            "sort_by": sort_by
        },
        "search_metadata": {
            "total_available": db.query(Course).filter(Course.is_published == True).count(),
            "total_categories": db.query(Category).count()
        }
    }
