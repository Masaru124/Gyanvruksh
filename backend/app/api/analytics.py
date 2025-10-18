from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from ..database import get_db
from ..models.analytics import Analytics, ParentDashboard
from ..schemas.analytics import AnalyticsRead, ParentDashboardRead
from ..services.deps import get_current_user
from ..models.user import User

router = APIRouter(prefix="/api/analytics", tags=["analytics"])

@router.get("/user", response_model=List[AnalyticsRead])
def get_user_analytics(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    analytics = db.query(Analytics).filter(Analytics.user_id == current_user.id).order_by(Analytics.recorded_at.desc()).all()
    return analytics

@router.get("/parent/{child_id}", response_model=List[ParentDashboardRead])
def get_parent_dashboard(
    child_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    # Check if current user is parent of the child
    dashboard = db.query(ParentDashboard).filter(
        ParentDashboard.parent_id == current_user.id,
        ParentDashboard.child_id == child_id
    ).order_by(ParentDashboard.generated_at.desc()).all()
    return dashboard

@router.post("/record")
def record_analytics(
    analytics_data: dict,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    analytics = Analytics(
        user_id=current_user.id,
        analytics_type=analytics_data["analytics_type"],
        category=analytics_data["category"],
        metric_name=analytics_data["metric_name"],
        metric_value=analytics_data["metric_value"],
        period=analytics_data.get("period", "daily"),
    )
    db.add(analytics)
    db.commit()
    db.refresh(analytics)
    return {"message": "Analytics recorded", "id": analytics.id}
