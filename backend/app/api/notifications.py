from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List, Optional
import asyncio
import httpx
from pydantic import BaseModel
from datetime import datetime

from ..database import get_db
from ..models.notification import Notification
from ..schemas.notification import NotificationRead, NotificationCreate
from ..services.deps import get_current_user
from ..models.user import User
from ..utils.errors import not_found_error

router = APIRouter(prefix="/api/notifications", tags=["notifications"])

class FCMNotificationRequest(BaseModel):
    user_id: int
    title: str
    body: str
    data: Optional[dict] = None

class FCMTokenUpdateRequest(BaseModel):
    fcm_token: str

class NotificationCreateRequest(BaseModel):
    user_id: int
    title: str
    message: str
    notification_type: str = "general"  # class_reminder, streak, challenge, assignment, event, general

@router.get("/", response_model=List[NotificationRead])
def get_notifications(
    unread_only: bool = False,
    notification_type: Optional[str] = None,
    limit: int = 50,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Get user notifications with filtering options"""
    query = db.query(Notification).filter(Notification.user_id == current_user.id)

    if unread_only:
        query = query.filter(Notification.is_read == False)

    if notification_type:
        query = query.filter(Notification.notification_type == notification_type)

    notifications = query.order_by(Notification.created_at.desc()).limit(limit).all()
    return notifications

@router.post("/{notification_id}/read")
def mark_as_read(
    notification_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Mark a specific notification as read"""
    notification = db.query(Notification).filter(
        Notification.id == notification_id,
        Notification.user_id == current_user.id
    ).first()

    if not notification:
        raise not_found_error("Notification")

    notification.is_read = True
    db.commit()
    return {"message": "Notification marked as read"}

@router.post("/mark-all-read")
def mark_all_as_read(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Mark all user notifications as read"""
    db.query(Notification).filter(
        Notification.user_id == current_user.id,
        Notification.is_read == False
    ).update({"is_read": True})

    db.commit()
    return {"message": "All notifications marked as read"}

@router.delete("/{notification_id}")
def delete_notification(
    notification_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Delete a specific notification"""
    notification = db.query(Notification).filter(
        Notification.id == notification_id,
        Notification.user_id == current_user.id
    ).first()

    if not notification:
        raise not_found_error("Notification")

    db.delete(notification)
    db.commit()
    return {"message": "Notification deleted"}

@router.get("/unread-count")
def get_unread_count(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Get count of unread notifications"""
    count = db.query(Notification).filter(
        Notification.user_id == current_user.id,
        Notification.is_read == False
    ).count()

    return {"unread_count": count}

# Admin/Teacher endpoints for creating notifications
@router.post("/create")
def create_notification(
    request: NotificationCreateRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Create a notification (admin/teacher only)"""
    # Check if user can create notifications (admin or teacher)
    if current_user.role not in ["admin"] and current_user.sub_role not in ["teacher"]:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only admins and teachers can create notifications"
        )

    # Verify target user exists
    target_user = db.query(User).filter(User.id == request.user_id).first()
    if not target_user:
        raise not_found_error("User")

    notification = Notification(
        user_id=request.user_id,
        title=request.title,
        message=request.message,
        notification_type=request.notification_type,
        is_read=False
    )

    db.add(notification)
    db.commit()
    db.refresh(notification)

    return {
        "message": "Notification created successfully",
        "notification_id": notification.id
    }

@router.post("/broadcast")
def broadcast_notification(
    title: str,
    message: str,
    notification_type: str = "general",
    target_role: Optional[str] = None,
    target_sub_role: Optional[str] = None,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Broadcast notification to multiple users (admin only)"""
    if current_user.role != "admin":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only admins can broadcast notifications"
        )

    # Build query for target users
    query = db.query(User)

    if target_role:
        query = query.filter(User.role == target_role)

    if target_sub_role:
        query = query.filter(User.sub_role == target_sub_role)

    target_users = query.all()

    # Create notifications for all target users
    notifications_created = 0
    for user in target_users:
        notification = Notification(
            user_id=user.id,
            title=title,
            message=message,
            notification_type=notification_type,
            is_read=False
        )
        db.add(notification)
        notifications_created += 1

    db.commit()

    return {
        "message": f"Notification broadcast to {notifications_created} users",
        "recipients_count": notifications_created
    }


# FCM (Firebase Cloud Messaging) endpoints
@router.post("/fcm/send")
async def send_fcm_notification(
    request: FCMNotificationRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Send FCM push notification to a user"""
    # Check if user has permission to send notifications
    if current_user.role not in ["admin"] and current_user.sub_role not in ["teacher"]:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only admins and teachers can send FCM notifications"
        )

    # Get target user
    target_user = db.query(User).filter(User.id == request.user_id).first()
    if not target_user:
        raise not_found_error("User")

    if not target_user.fcm_token:
        return {"message": "User has no FCM token registered", "success": False}

    # FCM server configuration (you would get these from environment variables)
    FCM_SERVER_KEY = "YOUR_FCM_SERVER_KEY"  # Should be in environment variables

    try:
        async with httpx.AsyncClient() as client:
            fcm_response = await client.post(
                "https://fcm.googleapis.com/fcm/send",
                headers={
                    "Authorization": f"key={FCM_SERVER_KEY}",
                    "Content-Type": "application/json"
                },
                json={
                    "to": target_user.fcm_token,
                    "notification": {
                        "title": request.title,
                        "body": request.body,
                        "click_action": "FLUTTER_NOTIFICATION_CLICK"
                    },
                    "data": request.data or {}
                },
                timeout=10.0
            )

        if fcm_response.status_code == 200:
            result = fcm_response.json()

            # Create notification record in database
            notification = Notification(
                user_id=request.user_id,
                title=request.title,
                message=request.body,
                notification_type="push_notification",
                is_read=False
            )
            db.add(notification)
            db.commit()

            return {
                "message": "FCM notification sent successfully",
                "fcm_result": result,
                "notification_id": notification.id
            }
        else:
            return {
                "message": "Failed to send FCM notification",
                "error": fcm_response.text,
                "success": False
            }

    except Exception as e:
        return {
            "message": f"Error sending FCM notification: {str(e)}",
            "success": False
        }


@router.post("/fcm/token")
def update_fcm_token(
    request: FCMTokenUpdateRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Update user's FCM token"""
    current_user.fcm_token = request.fcm_token
    db.commit()

    return {
        "message": "FCM token updated successfully",
        "fcm_token": request.fcm_token
    }


@router.delete("/fcm/token")
def remove_fcm_token(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Remove user's FCM token"""
    current_user.fcm_token = None
    db.commit()

    return {"message": "FCM token removed successfully"}
