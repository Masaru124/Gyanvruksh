from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.database import get_db
from app.models.user import User
from app.services.deps import get_current_user
from typing import List

router = APIRouter(prefix="/api/gyanvruksh", tags=["gyanvruksh"])

@router.get("/leaderboard", response_model=List[dict])
def get_leaderboard(db: Session = Depends(get_db)):
    """
    Returns top students ordered by gyan_coins descending.
    """
    users = db.query(User).filter(User.sub_role == "student").order_by(User.gyan_coins.desc()).limit(20).all()
    return [{"id": u.id, "full_name": u.full_name, "gyan_coins": u.gyan_coins} for u in users]

@router.get("/profile")
def get_profile(user: User = Depends(get_current_user)):
    """
    Returns current user profile including gyan_coins.
    """
    return {
        "id": user.id,
        "full_name": user.full_name,
        "email": user.email,
        "gyan_coins": user.gyan_coins,
        "role": user.role,
        "sub_role": user.sub_role,
        # Add other fields as needed
    }
