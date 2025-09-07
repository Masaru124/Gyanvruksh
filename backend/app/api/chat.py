from fastapi import APIRouter, WebSocket, WebSocketDisconnect, Depends
from sqlalchemy.orm import Session
from app.database import get_db
from app.models.chat_message import ChatMessage
from app.models.user import User
from app.services.deps import get_current_user
from typing import List
import json

router = APIRouter(prefix="/api/chat", tags=["chat"])

# Store active connections
active_connections: List[WebSocket] = []

@router.websocket("/ws")
async def websocket_endpoint(websocket: WebSocket, db: Session = Depends(get_db)):
    await websocket.accept()
    active_connections.append(websocket)
    try:
        while True:
            data = await websocket.receive_text()
            message_data = json.loads(data)
            user_id = message_data.get("user_id")
            message = message_data.get("message")

            if user_id and message:
                # Save message to DB
                chat_message = ChatMessage(user_id=user_id, message=message)
                db.add(chat_message)
                db.commit()
                db.refresh(chat_message)

                # Get user details
                user = db.query(User).filter(User.id == user_id).first()
                if user:
                    # Broadcast to all connected clients
                    for connection in active_connections:
                        await connection.send_text(json.dumps({
                            "user_id": user_id,
                            "full_name": user.full_name,
                            "message": message,
                            "timestamp": chat_message.timestamp.isoformat()
                        }))
    except WebSocketDisconnect:
        active_connections.remove(websocket)

@router.get("/messages", response_model=List[dict])
def get_chat_messages(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    """
    Get recent chat messages (last 50)
    """
    messages = db.query(ChatMessage).order_by(ChatMessage.timestamp.desc()).limit(50).all()
    result = []
    for msg in reversed(messages):
        user = db.query(User).filter(User.id == msg.user_id).first()
        if user:
            result.append({
                "id": msg.id,
                "user_id": msg.user_id,
                "full_name": user.full_name,
                "message": msg.message,
                "timestamp": msg.timestamp.isoformat()
            })
    return result
