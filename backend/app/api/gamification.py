from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy import func, and_, or_
from ..database import get_db
from ..models.user import User
from ..models.course import Course
from ..models.enrollment import Enrollment
from ..models.progress import UserProgress
from ..models.gamification import Badge, UserBadge, Streak, DailyChallenge, UserChallenge
from ..models.assignment import Assignment, Grade
from ..models.quiz import Quiz
from ..models.attendance import Attendance
from ..services.deps import get_current_user
from ..utils.errors import not_found_error
from typing import List, Dict, Optional
from datetime import datetime, timedelta, date
from pydantic import BaseModel

router = APIRouter(prefix="/api/gamification", tags=["gamification"])

# Pydantic models
class BadgeResponse(BaseModel):
    id: int
    name: str
    description: str
    icon_url: Optional[str]
    category: str
    criteria_type: str
    criteria_value: int
    gyan_coins_reward: int
    is_active: bool

class UserBadgeResponse(BaseModel):
    id: int
    badge_id: int
    badge_name: str
    badge_description: str
    earned_at: datetime
    category: str

class StreakResponse(BaseModel):
    streak_type: str
    current_streak: int
    longest_streak: int
    last_activity: datetime

class DailyChallengeResponse(BaseModel):
    id: int
    title: str
    description: str
    challenge_type: str
    target_value: int
    gyan_coins_reward: int
    date: date
    is_active: bool

class UserChallengeResponse(BaseModel):
    id: int
    challenge_id: int
    challenge_title: str
    challenge_description: str
    progress: int
    target_value: int
    completed: bool
    completed_at: Optional[datetime]

class LeaderboardEntry(BaseModel):
    user_id: int
    user_name: str
    gyan_coins: int
    rank: int
    badges_count: int

class PointsResponse(BaseModel):
    current_points: int
    total_earned: int
    points_history: List[Dict]

# Points system endpoints
@router.get("/points", response_model=PointsResponse)
def get_user_points(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Get user's current points and points history"""
    # Get points history from various activities
    points_history = []

    # Points from completed challenges
    completed_challenges = db.query(UserChallenge).filter(
        UserChallenge.user_id == current_user.id,
        UserChallenge.completed == True
    ).all()

    for challenge in completed_challenges:
        daily_challenge = db.query(DailyChallenge).filter(
            DailyChallenge.id == challenge.challenge_id
        ).first()
        if daily_challenge:
            points_history.append({
                "type": "challenge_completed",
                "description": f"Completed: {daily_challenge.title}",
                "points": daily_challenge.gyan_coins_reward,
                "earned_at": challenge.completed_at.isoformat() if challenge.completed_at else None
            })

    # Points from badges earned
    user_badges = db.query(UserBadge).filter(UserBadge.user_id == current_user.id).all()
    for user_badge in user_badges:
        badge = db.query(Badge).filter(Badge.id == user_badge.badge_id).first()
        if badge:
            points_history.append({
                "type": "badge_earned",
                "description": f"Earned badge: {badge.name}",
                "points": badge.gyan_coins_reward,
                "earned_at": user_badge.earned_at.isoformat()
            })

    # Calculate total points earned
    total_earned = sum(entry["points"] for entry in points_history)

    return {
        "current_points": current_user.gyan_coins,
        "total_earned": total_earned,
        "points_history": points_history[-20:]  # Last 20 entries
    }

@router.post("/points/add")
def add_points(
    points: int,
    reason: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Manually add points to user (admin/teacher only)"""
    # Only admins and teachers can manually add points
    if not (current_user.role == "admin" or current_user.sub_role == "teacher"):
        raise HTTPException(status_code=403, detail="Only admins and teachers can add points")

    if points <= 0:
        raise HTTPException(status_code=400, detail="Points must be positive")

    # Add points to user
    current_user.gyan_coins += points
    db.commit()

    return {
        "message": f"Added {points} points to user",
        "reason": reason,
        "new_balance": current_user.gyan_coins
    }

# Achievement checking
@router.post("/achievements/check")
def check_achievements(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Check and award any new achievements for the current user"""
    _check_and_award_badges(current_user.id, db)

    # Check for new badges since last check
    recent_badges = db.query(UserBadge).filter(
        UserBadge.user_id == current_user.id,
        UserBadge.earned_at >= datetime.utcnow() - timedelta(minutes=5)
    ).all()

    new_badges = []
    for user_badge in recent_badges:
        badge = db.query(Badge).filter(Badge.id == user_badge.badge_id).first()
        if badge:
            new_badges.append({
                "badge_id": badge.id,
                "badge_name": badge.name,
                "description": badge.description,
                "points_awarded": badge.gyan_coins_reward,
                "category": badge.category
            })

    return {
        "message": f"Checked achievements. {len(new_badges)} new badges awarded.",
        "new_badges": new_badges,
        "current_points": current_user.gyan_coins,
        "total_badges": db.query(UserBadge).filter(UserBadge.user_id == current_user.id).count()
    }

# Streak management endpoints
@router.post("/streak/update")
def update_streak(
    streak_type: str = "daily_study",
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Update user's streak for a specific activity"""
    if streak_type not in ["daily_study", "weekly_study", "quiz_completion", "assignment_completion"]:
        raise HTTPException(status_code=400, detail="Invalid streak type")

    # Get or create streak record
    streak = db.query(Streak).filter(
        Streak.user_id == current_user.id,
        Streak.streak_type == streak_type
    ).first()

    today = date.today()

    if not streak:
        # Create new streak
        streak = Streak(
            user_id=current_user.id,
            streak_type=streak_type,
            current_streak=1,
            longest_streak=1,
            last_activity=datetime.utcnow()
        )
        db.add(streak)
    else:
        # Check if last activity was yesterday (for daily streaks)
        last_activity_date = streak.last_activity.date() if streak.last_activity else None

        if last_activity_date == today - timedelta(days=1):
            # Consecutive day - increment streak
            streak.current_streak += 1
            if streak.current_streak > streak.longest_streak:
                streak.longest_streak = streak.current_streak
        elif last_activity_date == today:
            # Same day - no change
            pass
        else:
            # Streak broken - reset to 1
            streak.current_streak = 1

        streak.last_activity = datetime.utcnow()

    db.commit()
    db.refresh(streak)

    return {
        "message": "Streak updated successfully",
        "streak_type": streak_type,
        "current_streak": streak.current_streak,
        "longest_streak": streak.longest_streak
    }

@router.post("/streak/freeze")
def freeze_streak(
    streak_type: str = "daily_study",
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Freeze a streak to prevent it from being broken (costs points)"""
    if current_user.gyan_coins < 10:
        raise HTTPException(status_code=400, detail="Insufficient points to freeze streak (costs 10 points)")

    # Deduct points for freezing
    current_user.gyan_coins -= 10
    db.commit()

    # Update streak freeze status (extend freeze by 1 day)
    streak = db.query(Streak).filter(
        Streak.user_id == current_user.id,
        Streak.streak_type == streak_type
    ).first()

    if not streak:
        # Create streak with freeze
        streak = Streak(
            user_id=current_user.id,
            streak_type=streak_type,
            current_streak=1,
            longest_streak=1,
            last_activity=datetime.utcnow(),
            is_frozen=True,
            frozen_until=datetime.utcnow() + timedelta(days=1)
        )
        db.add(streak)
    else:
        streak.is_frozen = True
        streak.frozen_until = datetime.utcnow() + timedelta(days=1)
        streak.last_activity = datetime.utcnow()  # Update last activity to today

    db.commit()

    return {
        "message": "Streak frozen for 1 day",
        "cost": 10,
        "remaining_points": current_user.gyan_coins,
        "frozen_until": streak.frozen_until.isoformat()
    }

# Challenge completion endpoint
@router.post("/challenges/{challenge_id}/complete")
def complete_challenge(
    challenge_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Mark a challenge as completed"""
    challenge = db.query(DailyChallenge).filter(
        DailyChallenge.id == challenge_id,
        DailyChallenge.date == date.today(),
        DailyChallenge.is_active == True
    ).first()

    if not challenge:
        raise not_found_error("Active challenge")

    # Get or create user challenge
    user_challenge = db.query(UserChallenge).filter(
        UserChallenge.user_id == current_user.id,
        UserChallenge.challenge_id == challenge_id
    ).first()

    if not user_challenge:
        user_challenge = UserChallenge(
            user_id=current_user.id,
            challenge_id=challenge_id,
            progress=0,
            completed=False
        )
        db.add(user_challenge)

    # Mark as completed and award points
    user_challenge.completed = True
    user_challenge.completed_at = datetime.utcnow()
    user_challenge.progress = challenge.target_value

    # Award gyan coins
    current_user.gyan_coins += challenge.gyan_coins_reward
    db.commit()

    # Check for new badges
    _check_and_award_badges(current_user.id, db)

    return {
        "message": "Challenge completed successfully!",
        "challenge_title": challenge.title,
        "points_awarded": challenge.gyan_coins_reward,
        "total_points": current_user.gyan_coins,
        "new_badges_count": db.query(UserBadge).filter(
            UserBadge.user_id == current_user.id,
            UserBadge.earned_at >= datetime.utcnow() - timedelta(minutes=1)
        ).count()
    }

# Rewards system endpoints
@router.get("/rewards")
def get_available_rewards(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Get available rewards for purchase"""
    rewards = [
        {
            "id": 1,
            "name": "Extra Quiz Attempt",
            "description": "Get one extra attempt on any quiz",
            "cost": 25,
            "category": "academic",
            "is_available": current_user.gyan_coins >= 25
        },
        {
            "id": 2,
            "name": "Assignment Extension",
            "description": "Get a 24-hour extension on any assignment",
            "cost": 30,
            "category": "academic",
            "is_available": current_user.gyan_coins >= 30
        },
        {
            "id": 3,
            "name": "Streak Freeze",
            "description": "Freeze your streak for 1 day",
            "cost": 10,
            "category": "streak",
            "is_available": current_user.gyan_coins >= 10
        },
        {
            "id": 4,
            "name": "Custom Avatar",
            "description": "Unlock a special avatar for your profile",
            "cost": 50,
            "category": "cosmetic",
            "is_available": current_user.gyan_coins >= 50
        }
    ]

    return {
        "current_points": current_user.gyan_coins,
        "rewards": rewards
    }

@router.post("/rewards/{reward_id}/claim")
def claim_reward(
    reward_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Claim a reward using points"""
    rewards = {
        1: {"name": "Extra Quiz Attempt", "cost": 25, "type": "quiz_attempt"},
        2: {"name": "Assignment Extension", "cost": 30, "type": "assignment_extension"},
        3: {"name": "Streak Freeze", "cost": 10, "type": "streak_freeze"},
        4: {"name": "Custom Avatar", "cost": 50, "type": "cosmetic"}
    }

    if reward_id not in rewards:
        raise HTTPException(status_code=404, detail="Reward not found")

    reward = rewards[reward_id]
    if current_user.gyan_coins < reward["cost"]:
        raise HTTPException(status_code=400, detail="Insufficient points")

    # Deduct points
    current_user.gyan_coins -= reward["cost"]
    db.commit()

    # Award the reward (in a real system, this would create a reward record)
    # For now, just return success
    return {
        "message": f"Successfully claimed: {reward['name']}",
        "reward_type": reward["type"],
        "cost": reward["cost"],
        "remaining_points": current_user.gyan_coins
    }

# Badge endpoints
@router.get("/badges", response_model=List[BadgeResponse])
def get_all_badges(
    category: Optional[str] = None,
    db: Session = Depends(get_db)
):
    """Get all available badges with optional category filtering"""
    query = db.query(Badge).filter(Badge.is_active == True)

    if category:
        query = query.filter(Badge.category == category)

    badges = query.order_by(Badge.category, Badge.criteria_value).all()
    return badges

@router.get("/badges/{badge_id}", response_model=BadgeResponse)
def get_badge_details(badge_id: int, db: Session = Depends(get_db)):
    """Get detailed information about a specific badge"""
    badge = db.query(Badge).filter(Badge.id == badge_id, Badge.is_active == True).first()
    if not badge:
        raise not_found_error("Badge")
    return badge

@router.get("/user/badges", response_model=List[UserBadgeResponse])
def get_user_badges(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Get all badges earned by the current user"""
    user_badges = db.query(UserBadge).filter(UserBadge.user_id == current_user.id).all()

    result = []
    for user_badge in user_badges:
        badge = db.query(Badge).filter(Badge.id == user_badge.badge_id).first()
        if badge:
            result.append({
                "id": user_badge.id,
                "badge_id": user_badge.badge_id,
                "badge_name": badge.name,
                "badge_description": badge.description,
                "earned_at": user_badge.earned_at,
                "category": badge.category
            })

    return result

@router.get("/user/streaks", response_model=List[StreakResponse])
def get_user_streaks(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Get user's learning streaks"""
    streaks = db.query(Streak).filter(Streak.user_id == current_user.id).all()

    result = []
    for streak in streaks:
        result.append({
            "streak_type": streak.streak_type,
            "current_streak": streak.current_streak,
            "longest_streak": streak.longest_streak,
            "last_activity": streak.last_activity
        })

    # If no streaks exist, return default streak data
    if not result:
        result = [{
            "streak_type": "daily_study",
            "current_streak": 0,
            "longest_streak": 0,
            "last_activity": datetime.utcnow()
        }]

    return result

# Challenge endpoints
@router.get("/challenges/today", response_model=List[DailyChallengeResponse])
def get_today_challenges(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Get today's active challenges"""
    today = date.today()

    challenges = db.query(DailyChallenge).filter(
        DailyChallenge.date == today,
        DailyChallenge.is_active == True
    ).all()

    return challenges

@router.get("/user/challenges", response_model=List[UserChallengeResponse])
def get_user_challenges(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Get user's challenge progress"""
    user_challenges = db.query(UserChallenge).filter(
        UserChallenge.user_id == current_user.id
    ).all()

    result = []
    for user_challenge in user_challenges:
        challenge = db.query(DailyChallenge).filter(
            DailyChallenge.id == user_challenge.challenge_id
        ).first()

        if challenge:
            result.append({
                "id": user_challenge.id,
                "challenge_id": user_challenge.challenge_id,
                "challenge_title": challenge.title,
                "challenge_description": challenge.description,
                "progress": user_challenge.progress,
                "target_value": challenge.target_value,
                "completed": user_challenge.completed,
                "completed_at": user_challenge.completed_at
            })

    return result

@router.post("/challenges/{challenge_id}/progress")
def update_challenge_progress(
    challenge_id: int,
    progress_increment: int = 1,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Update progress for a daily challenge"""
    today = date.today()

    # Get or create user challenge
    user_challenge = db.query(UserChallenge).filter(
        UserChallenge.user_id == current_user.id,
        UserChallenge.challenge_id == challenge_id
    ).first()

    challenge = db.query(DailyChallenge).filter(
        DailyChallenge.id == challenge_id,
        DailyChallenge.date == today,
        DailyChallenge.is_active == True
    ).first()

    if not challenge:
        raise not_found_error("Active challenge")

    if not user_challenge:
        user_challenge = UserChallenge(
            user_id=current_user.id,
            challenge_id=challenge_id,
            progress=0,
            completed=False
        )
        db.add(user_challenge)

    # Update progress
    user_challenge.progress += progress_increment

    # Check if challenge is completed
    if user_challenge.progress >= challenge.target_value and not user_challenge.completed:
        user_challenge.completed = True
        user_challenge.completed_at = datetime.utcnow()

        # Award gyan coins
        current_user.gyan_coins += challenge.gyan_coins_reward
        db.commit()

        return {
            "message": "Challenge completed!",
            "challenge_title": challenge.title,
            "coins_awarded": challenge.gyan_coins_reward,
            "total_coins": current_user.gyan_coins
        }

    db.commit()
    db.refresh(user_challenge)

    return {
        "message": "Progress updated",
        "challenge_title": challenge.title,
        "current_progress": user_challenge.progress,
        "target": challenge.target_value
    }

# Leaderboard endpoints
@router.get("/leaderboard", response_model=List[LeaderboardEntry])
def get_gamification_leaderboard(
    limit: int = 20,
    timeframe: str = "all_time",  # all_time, monthly, weekly
    db: Session = Depends(get_db)
):
    """Get gamification leaderboard"""
    query = db.query(User).filter(User.sub_role == "student")

    # Apply timeframe filter
    if timeframe == "weekly":
        week_ago = datetime.utcnow() - timedelta(days=7)
        # Filter by recent activity (simplified - would need proper activity tracking)
        pass
    elif timeframe == "monthly":
        month_ago = datetime.utcnow() - timedelta(days=30)
        # Filter by recent activity
        pass

    users = query.order_by(User.gyan_coins.desc()).limit(limit).all()

    result = []
    for idx, user in enumerate(users, 1):
        # Count user's badges
        badges_count = db.query(UserBadge).filter(UserBadge.user_id == user.id).count()

        result.append({
            "user_id": user.id,
            "user_name": user.full_name,
            "gyan_coins": user.gyan_coins,
            "rank": idx,
            "badges_count": badges_count
        })

    return result

@router.get("/user/stats")
def get_user_gamification_stats(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Get comprehensive gamification stats for the current user"""
    # Calculate streaks
    daily_study_streak = _calculate_daily_study_streak(current_user.id, db)

    # Get badges earned
    badges_earned = db.query(UserBadge).filter(UserBadge.user_id == current_user.id).count()

    # Get challenges completed
    challenges_completed = db.query(UserChallenge).filter(
        UserChallenge.user_id == current_user.id,
        UserChallenge.completed == True
    ).count()

    # Get total gyan coins earned from challenges
    challenge_coins = db.query(func.sum(DailyChallenge.gyan_coins_reward)).join(
        UserChallenge
    ).filter(
        UserChallenge.user_id == current_user.id,
        UserChallenge.completed == True,
        UserChallenge.challenge_id == DailyChallenge.id
    ).scalar() or 0

    # Get recent achievements (last 30 days)
    thirty_days_ago = datetime.utcnow() - timedelta(days=30)
    recent_badges = db.query(UserBadge).filter(
        UserBadge.user_id == current_user.id,
        UserBadge.earned_at >= thirty_days_ago
    ).count()

    return {
        "gyan_coins": current_user.gyan_coins,
        "badges_earned": badges_earned,
        "challenges_completed": challenges_completed,
        "challenge_coins_earned": challenge_coins,
        "daily_study_streak": daily_study_streak,
        "recent_achievements": recent_badges,
        "total_achievements": badges_earned + challenges_completed
    }

# Utility functions
def _calculate_daily_study_streak(user_id: int, db: Session) -> int:
    """Calculate current daily study streak"""
    # Get user's recent progress records
    recent_progress = db.query(UserProgress).filter(
        UserProgress.user_id == user_id,
        UserProgress.last_accessed >= datetime.utcnow() - timedelta(days=30)
    ).order_by(UserProgress.last_accessed.desc()).all()

    if not recent_progress:
        return 0

    # Group by date and check consecutive days
    study_dates = set()
    for progress in recent_progress:
        if progress.last_accessed:
            study_dates.add(progress.last_accessed.date())

    # Sort dates and check for consecutive days
    sorted_dates = sorted(study_dates)

    if not sorted_dates:
        return 0

    current_streak = 1
    for i in range(len(sorted_dates) - 1, 0, -1):
        current_date = sorted_dates[i]
        previous_date = sorted_dates[i - 1]

        if (current_date - previous_date).days == 1:
            current_streak += 1
        else:
            break

    return current_streak

def _check_and_award_badges(user_id: int, db: Session):
    """Check if user qualifies for any badges and award them"""
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        return

    # Check various badge criteria
    badge_criteria = {
        "First Course": lambda u: _get_completed_courses_count(u.id, db) >= 1,
        "Course Collector": lambda u: _get_completed_courses_count(u.id, db) >= 5,
        "Dedicated Learner": lambda u: _get_daily_study_streak(u.id, db) >= 7,
        "Perfect Attendance": lambda u: _get_attendance_rate(u.id, db) >= 0.95,
        "Quiz Master": lambda u: _get_average_quiz_score(u.id, db) >= 90,
        "Assignment Ace": lambda u: _get_average_assignment_score(u.id, db) >= 90,
    }

    for badge_name, criteria_func in badge_criteria.items():
        if criteria_func(user):
            # Check if user already has this badge
            badge = db.query(Badge).filter(Badge.name == badge_name).first()
            if badge:
                existing_user_badge = db.query(UserBadge).filter(
                    UserBadge.user_id == user_id,
                    UserBadge.badge_id == badge.id
                ).first()

                if not existing_user_badge:
                    # Award the badge
                    user_badge = UserBadge(
                        user_id=user_id,
                        badge_id=badge.id
                    )
                    db.add(user_badge)

                    # Award gyan coins
                    user.gyan_coins += badge.gyan_coins_reward

    db.commit()

def _get_completed_courses_count(user_id: int, db: Session) -> int:
    """Get count of completed courses for a user"""
    return db.query(UserProgress).filter(
        UserProgress.user_id == user_id,
        UserProgress.completed == True,
        UserProgress.lesson_id.is_(None)  # Course-level progress
    ).count()

def _get_daily_study_streak(user_id: int, db: Session) -> int:
    """Get current daily study streak"""
    return _calculate_daily_study_streak(user_id, db)

def _get_attendance_rate(user_id: int, db: Session) -> float:
    """Calculate attendance rate for a user"""
    attendance_records = db.query(Attendance).filter(Attendance.student_id == user_id).all()
    if not attendance_records:
        return 0.0

    present_count = sum(1 for record in attendance_records if record.is_present)
    return present_count / len(attendance_records)

def _get_average_quiz_score(user_id: int, db: Session) -> float:
    """Calculate average quiz score for a user"""
    # This would need to be implemented based on quiz attempt results
    # For now, return a placeholder
    return 85.0

def _get_average_assignment_score(user_id: int, db: Session) -> float:
    """Calculate average assignment score for a user"""
    grades = db.query(Grade).filter(Grade.student_id == user_id).all()
    if not grades:
        return 0.0

    return sum(grade.score for grade in grades) / len(grades)

# Auto-badge checking (can be called after progress updates)
@router.post("/check-badges")
def check_and_award_badges_endpoint(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Manually trigger badge checking for the current user"""
    _check_and_award_badges(current_user.id, db)

    new_badges = db.query(UserBadge).filter(
        UserBadge.user_id == current_user.id,
        UserBadge.earned_at >= datetime.utcnow() - timedelta(minutes=1)  # Recently earned
    ).count()

    return {
        "message": f"Badge check completed. {new_badges} new badges awarded.",
        "new_badges_count": new_badges,
        "total_badges": db.query(UserBadge).filter(UserBadge.user_id == current_user.id).count()
    }

# Achievement feed
@router.get("/achievements/feed")
def get_achievements_feed(
    limit: int = 20,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Get recent achievements feed (user's own + friends/following)"""
    # For now, just return user's own recent badges
    recent_badges = db.query(UserBadge).filter(
        UserBadge.user_id == current_user.id
    ).order_by(UserBadge.earned_at.desc()).limit(limit).all()

    achievements = []
    for user_badge in recent_badges:
        badge = db.query(Badge).filter(Badge.id == user_badge.badge_id).first()
        if badge:
            achievements.append({
                "type": "badge_earned",
                "title": f"Earned badge: {badge.name}",
                "description": badge.description,
                "icon_url": badge.icon_url,
                "gyan_coins_reward": badge.gyan_coins_reward,
                "earned_at": user_badge.earned_at.isoformat(),
                "category": badge.category
            })

    return achievements

# Initialize default badges
@router.post("/admin/initialize-badges")
def initialize_default_badges(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Initialize default badges (admin only)"""
    if current_user.role != "admin":
        raise HTTPException(status_code=403, detail="Admin access required")

    default_badges = [
        {
            "name": "First Steps",
            "description": "Complete your first course",
            "category": "academics",
            "criteria_type": "courses_completed",
            "criteria_value": 1,
            "gyan_coins_reward": 50
        },
        {
            "name": "Scholar",
            "description": "Complete 5 courses",
            "category": "academics",
            "criteria_type": "courses_completed",
            "criteria_value": 5,
            "gyan_coins_reward": 200
        },
        {
            "name": "Dedicated Learner",
            "description": "Maintain a 7-day study streak",
            "category": "general",
            "criteria_type": "daily_streak",
            "criteria_value": 7,
            "gyan_coins_reward": 100
        },
        {
            "name": "Perfect Attendance",
            "description": "Achieve 95%+ attendance rate",
            "category": "general",
            "criteria_type": "attendance_rate",
            "criteria_value": 95,
            "gyan_coins_reward": 150
        },
        {
            "name": "Quiz Master",
            "description": "Score 90%+ on average in quizzes",
            "category": "academics",
            "criteria_type": "quiz_average",
            "criteria_value": 90,
            "gyan_coins_reward": 100
        },
        {
            "name": "Assignment Ace",
            "description": "Score 90%+ on average in assignments",
            "category": "academics",
            "criteria_type": "assignment_average",
            "criteria_value": 90,
            "gyan_coins_reward": 100
        }
    ]

    created_count = 0
    for badge_data in default_badges:
        existing_badge = db.query(Badge).filter(Badge.name == badge_data["name"]).first()
        if not existing_badge:
            badge = Badge(**badge_data)
            db.add(badge)
            created_count += 1

    db.commit()
    return {"message": f"Initialized {created_count} default badges"}

# Generate daily challenges
@router.post("/admin/generate-challenges")
def generate_daily_challenges(
    challenge_date: Optional[date] = None,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Generate daily challenges for a specific date (admin only)"""
    if current_user.role != "admin":
        raise HTTPException(status_code=403, detail="Admin access required")

    target_date = challenge_date or date.today()

    # Check if challenges already exist for this date
    existing_challenges = db.query(DailyChallenge).filter(
        DailyChallenge.date == target_date
    ).count()

    if existing_challenges > 0:
        return {"message": f"Challenges already exist for {target_date}"}

    # Create sample challenges for the day
    challenges = [
        {
            "title": "Quiz Champion",
            "description": "Complete 3 quizzes today",
            "challenge_type": "quiz",
            "target_value": 3,
            "gyan_coins_reward": 25,
            "date": target_date
        },
        {
            "title": "Study Session",
            "description": "Study for 2 hours today",
            "challenge_type": "study",
            "target_value": 120,  # minutes
            "gyan_coins_reward": 20,
            "date": target_date
        },
        {
            "title": "Assignment Master",
            "description": "Submit 2 assignments",
            "challenge_type": "creative",
            "target_value": 2,
            "gyan_coins_reward": 30,
            "date": target_date
        }
    ]

    created_count = 0
    for challenge_data in challenges:
        challenge = DailyChallenge(**challenge_data)
        db.add(challenge)
        created_count += 1

    db.commit()
    return {"message": f"Generated {created_count} challenges for {target_date}"}

# Additional missing endpoints that frontend expects

# Points system endpoints (simplified versions of existing functionality)
@router.get("/points", response_model=PointsResponse)
def get_user_points(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Get user's current points and points history"""
    # Get points history from various activities
    points_history = []

    # Points from completed challenges
    completed_challenges = db.query(UserChallenge).filter(
        UserChallenge.user_id == current_user.id,
        UserChallenge.completed == True
    ).all()

    for challenge in completed_challenges:
        daily_challenge = db.query(DailyChallenge).filter(
            DailyChallenge.id == challenge.challenge_id
        ).first()
        if daily_challenge:
            points_history.append({
                "type": "challenge_completed",
                "description": f"Completed: {daily_challenge.title}",
                "points": daily_challenge.gyan_coins_reward,
                "earned_at": challenge.completed_at.isoformat() if challenge.completed_at else None
            })

    # Points from badges earned
    user_badges = db.query(UserBadge).filter(UserBadge.user_id == current_user.id).all()
    for user_badge in user_badges:
        badge = db.query(Badge).filter(Badge.id == user_badge.badge_id).first()
        if badge:
            points_history.append({
                "type": "badge_earned",
                "description": f"Earned badge: {badge.name}",
                "points": badge.gyan_coins_reward,
                "earned_at": user_badge.earned_at.isoformat()
            })

    # Calculate total points earned
    total_earned = sum(entry["points"] for entry in points_history)

    return {
        "current_points": current_user.gyan_coins,
        "total_earned": total_earned,
        "points_history": points_history[-20:]  # Last 20 entries
    }

@router.post("/points/add")
def add_points(
    points: int,
    reason: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Manually add points to user (admin/teacher only)"""
    # Only admins and teachers can manually add points
    if not (current_user.role == "admin" or current_user.sub_role == "teacher"):
        raise HTTPException(status_code=403, detail="Only admins and teachers can add points")

    if points <= 0:
        raise HTTPException(status_code=400, detail="Points must be positive")

    # Add points to user
    current_user.gyan_coins += points
    db.commit()

    return {
        "message": f"Added {points} points to user",
        "reason": reason,
        "new_balance": current_user.gyan_coins
    }

# Achievement checking
@router.post("/achievements/check")
def check_achievements(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Check and award any new achievements for the current user"""
    _check_and_award_badges(current_user.id, db)

    # Check for new badges since last check
    recent_badges = db.query(UserBadge).filter(
        UserBadge.user_id == current_user.id,
        UserBadge.earned_at >= datetime.utcnow() - timedelta(minutes=5)
    ).all()

    new_badges = []
    for user_badge in recent_badges:
        badge = db.query(Badge).filter(Badge.id == user_badge.badge_id).first()
        if badge:
            new_badges.append({
                "badge_id": badge.id,
                "badge_name": badge.name,
                "description": badge.description,
                "points_awarded": badge.gyan_coins_reward,
                "category": badge.category
            })

    return {
        "message": f"Checked achievements. {len(new_badges)} new badges awarded.",
        "new_badges": new_badges,
        "current_points": current_user.gyan_coins,
        "total_badges": db.query(UserBadge).filter(UserBadge.user_id == current_user.id).count()
    }

# Streak management endpoints
@router.post("/streak/update")
def update_streak(
    streak_type: str = "daily_study",
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Update user's streak for a specific activity"""
    if streak_type not in ["daily_study", "weekly_study", "quiz_completion", "assignment_completion"]:
        raise HTTPException(status_code=400, detail="Invalid streak type")

    # Get or create streak record
    streak = db.query(Streak).filter(
        Streak.user_id == current_user.id,
        Streak.streak_type == streak_type
    ).first()

    today = date.today()

    if not streak:
        # Create new streak
        streak = Streak(
            user_id=current_user.id,
            streak_type=streak_type,
            current_streak=1,
            longest_streak=1,
            last_activity=datetime.utcnow()
        )
        db.add(streak)
    else:
        # Check if last activity was yesterday (for daily streaks)
        last_activity_date = streak.last_activity.date() if streak.last_activity else None

        if last_activity_date == today - timedelta(days=1):
            # Consecutive day - increment streak
            streak.current_streak += 1
            if streak.current_streak > streak.longest_streak:
                streak.longest_streak = streak.current_streak
        elif last_activity_date == today:
            # Same day - no change
            pass
        else:
            # Streak broken - reset to 1
            streak.current_streak = 1

        streak.last_activity = datetime.utcnow()

    db.commit()
    db.refresh(streak)

    return {
        "message": "Streak updated successfully",
        "streak_type": streak_type,
        "current_streak": streak.current_streak,
        "longest_streak": streak.longest_streak
    }

@router.post("/streak/freeze")
def freeze_streak(
    streak_type: str = "daily_study",
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Freeze a streak to prevent it from being broken (costs points)"""
    if current_user.gyan_coins < 10:
        raise HTTPException(status_code=400, detail="Insufficient points to freeze streak (costs 10 points)")

    # Deduct points for freezing
    current_user.gyan_coins -= 10
    db.commit()

    # Update streak freeze status (extend freeze by 1 day)
    streak = db.query(Streak).filter(
        Streak.user_id == current_user.id,
        Streak.streak_type == streak_type
    ).first()

    if not streak:
        # Create streak with freeze
        streak = Streak(
            user_id=current_user.id,
            streak_type=streak_type,
            current_streak=1,
            longest_streak=1,
            last_activity=datetime.utcnow(),
            is_frozen=True,
            frozen_until=datetime.utcnow() + timedelta(days=1)
        )
        db.add(streak)
    else:
        streak.is_frozen = True
        streak.frozen_until = datetime.utcnow() + timedelta(days=1)
        streak.last_activity = datetime.utcnow()  # Update last activity to today

    db.commit()

    return {
        "message": "Streak frozen for 1 day",
        "cost": 10,
        "remaining_points": current_user.gyan_coins,
        "frozen_until": streak.frozen_until.isoformat()
    }

# Challenge completion endpoint (alternative to existing progress endpoint)
@router.post("/challenges/{challenge_id}/complete")
def complete_challenge(
    challenge_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Mark a challenge as completed"""
    challenge = db.query(DailyChallenge).filter(
        DailyChallenge.id == challenge_id,
        DailyChallenge.date == date.today(),
        DailyChallenge.is_active == True
    ).first()

    if not challenge:
        raise not_found_error("Active challenge")

    # Get or create user challenge
    user_challenge = db.query(UserChallenge).filter(
        UserChallenge.user_id == current_user.id,
        UserChallenge.challenge_id == challenge_id
    ).first()

    if not user_challenge:
        user_challenge = UserChallenge(
            user_id=current_user.id,
            challenge_id=challenge_id,
            progress=0,
            completed=False
        )
        db.add(user_challenge)

    # Mark as completed and award points
    user_challenge.completed = True
    user_challenge.completed_at = datetime.utcnow()
    user_challenge.progress = challenge.target_value

    # Award gyan coins
    current_user.gyan_coins += challenge.gyan_coins_reward
    db.commit()

    # Check for new badges
    _check_and_award_badges(current_user.id, db)

    return {
        "message": "Challenge completed successfully!",
        "challenge_title": challenge.title,
        "points_awarded": challenge.gyan_coins_reward,
        "total_points": current_user.gyan_coins,
        "new_badges_count": db.query(UserBadge).filter(
            UserBadge.user_id == current_user.id,
            UserBadge.earned_at >= datetime.utcnow() - timedelta(minutes=1)
        ).count()
    }

# Rewards system endpoints
@router.get("/rewards")
def get_available_rewards(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Get available rewards for purchase"""
    rewards = [
        {
            "id": 1,
            "name": "Extra Quiz Attempt",
            "description": "Get one extra attempt on any quiz",
            "cost": 25,
            "category": "academic",
            "is_available": current_user.gyan_coins >= 25
        },
        {
            "id": 2,
            "name": "Assignment Extension",
            "description": "Get a 24-hour extension on any assignment",
            "cost": 30,
            "category": "academic",
            "is_available": current_user.gyan_coins >= 30
        },
        {
            "id": 3,
            "name": "Streak Freeze",
            "description": "Freeze your streak for 1 day",
            "cost": 10,
            "category": "streak",
            "is_available": current_user.gyan_coins >= 10
        },
        {
            "id": 4,
            "name": "Custom Avatar",
            "description": "Unlock a special avatar for your profile",
            "cost": 50,
            "category": "cosmetic",
            "is_available": current_user.gyan_coins >= 50
        }
    ]

    return {
        "current_points": current_user.gyan_coins,
        "rewards": rewards
    }

@router.post("/rewards/{reward_id}/claim")
def claim_reward(
    reward_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Claim a reward using points"""
    rewards = {
        1: {"name": "Extra Quiz Attempt", "cost": 25, "type": "quiz_attempt"},
        2: {"name": "Assignment Extension", "cost": 30, "type": "assignment_extension"},
        3: {"name": "Streak Freeze", "cost": 10, "type": "streak_freeze"},
        4: {"name": "Custom Avatar", "cost": 50, "type": "cosmetic"}
    }

    if reward_id not in rewards:
        raise HTTPException(status_code=404, detail="Reward not found")

    reward = rewards[reward_id]
    if current_user.gyan_coins < reward["cost"]:
        raise HTTPException(status_code=400, detail="Insufficient points")

    # Deduct points
    current_user.gyan_coins -= reward["cost"]
    db.commit()

    # Award the reward (in a real system, this would create a reward record)
    # For now, just return success
    return {
        "message": f"Successfully claimed: {reward['name']}",
        "reward_type": reward["type"],
        "cost": reward["cost"],
        "remaining_points": current_user.gyan_coins
    }
