from fastapi import APIRouter, WebSocket, WebSocketDisconnect, Depends, HTTPException, status
from sqlalchemy.orm import Session
from ..database import get_db
from ..models.chat_message import ChatMessage
from ..models.user import User
from ..services.deps import get_current_user
from ..utils.errors import auth_error
from typing import List, Dict
import json
import asyncio
from datetime import datetime

router = APIRouter(prefix="/api/chat", tags=["chat"])

# Connection manager for WebSocket connections
class ConnectionManager:
    def __init__(self):
        self.active_connections: Dict[int, WebSocket] = {}  # user_id -> websocket
        self.user_rooms: Dict[int, str] = {}  # user_id -> room_id

    async def connect(self, websocket: WebSocket, user_id: int, room_id: str = "general"):
        await websocket.accept()
        self.active_connections[user_id] = websocket
        self.user_rooms[user_id] = room_id

    def disconnect(self, user_id: int):
        if user_id in self.active_connections:
            del self.active_connections[user_id]
        if user_id in self.user_rooms:
            del self.user_rooms[user_id]

    async def send_personal_message(self, message: str, user_id: int):
        if user_id in self.active_connections:
            try:
                await self.active_connections[user_id].send_text(message)
            except:
                self.disconnect(user_id)

    async def broadcast_to_room(self, message: str, room_id: str = "general"):
        disconnected_users = []
        for user_id, user_room in self.user_rooms.items():
            if user_room == room_id and user_id in self.active_connections:
                try:
                    await self.active_connections[user_id].send_text(message)
                except:
                    disconnected_users.append(user_id)

        # Clean up disconnected users
        for user_id in disconnected_users:
            self.disconnect(user_id)

    async def broadcast_to_all(self, message: str):
        disconnected_users = []
        for user_id, websocket in self.active_connections.items():
            try:
                await websocket.send_text(message)
            except:
                disconnected_users.append(user_id)

        # Clean up disconnected users
        for user_id in disconnected_users:
            self.disconnect(user_id)

manager = ConnectionManager()

@router.websocket("/ws/{room_id}")
async def websocket_endpoint(
    websocket: WebSocket,
    room_id: str,
    token: str,
    db: Session = Depends(get_db)
):
    """
    WebSocket endpoint for real-time chat with authentication
    """
    try:
        # Authenticate user from token
        from ..services.security import decode_token, get_token_subject
        payload = decode_token(token)
        if not payload:
            await websocket.close(code=status.WS_1008_POLICY_VIOLATION)
            return

        user_email = get_token_subject(token)
        if not user_email:
            await websocket.close(code=status.WS_1008_POLICY_VIOLATION)
            return

        user = db.query(User).filter(User.email == user_email).first()
        if not user:
            await websocket.close(code=status.WS_1008_POLICY_VIOLATION)
            return

        # Connect user to WebSocket
        await manager.connect(websocket, user.id, room_id)

        # Send connection confirmation
        await manager.send_personal_message(json.dumps({
            "type": "system",
            "message": f"Connected to room: {room_id}",
            "timestamp": datetime.utcnow().isoformat()
        }), user.id)

        try:
            while True:
                data = await websocket.receive_text()
                message_data = json.loads(data)

                # Handle different message types
                message_type = message_data.get("type", "chat")

                if message_type == "chat":
                    message_text = message_data.get("message", "").strip()
                    if message_text:
                        # Save message to database
                        chat_message = ChatMessage(
                            user_id=user.id,
                            message=message_text,
                            room_id=room_id
                        )
                        db.add(chat_message)
                        db.commit()
                        db.refresh(chat_message)

                        # Broadcast message to room
                        await manager.broadcast_to_room(json.dumps({
                            "type": "chat",
                            "user_id": user.id,
                            "full_name": user.full_name,
                            "message": message_text,
                            "room_id": room_id,
                            "timestamp": chat_message.timestamp.isoformat(),
                            "message_id": chat_message.id
                        }), room_id)

                elif message_type == "typing":
                    # Broadcast typing indicator to room (excluding sender)
                    typing_message = json.dumps({
                        "type": "typing",
                        "user_id": user.id,
                        "full_name": user.full_name,
                        "room_id": room_id,
                        "is_typing": message_data.get("is_typing", False)
                    })

                    for uid, connection in manager.active_connections.items():
                        if uid != user.id and manager.user_rooms.get(uid) == room_id:
                            try:
                                await connection.send_text(typing_message)
                            except:
                                pass

        except WebSocketDisconnect:
            manager.disconnect(user.id)
            # Broadcast user left to room
            await manager.broadcast_to_room(json.dumps({
                "type": "system",
                "message": f"{user.full_name} left the chat",
                "room_id": room_id,
                "timestamp": datetime.utcnow().isoformat()
            }), room_id)

    except Exception as e:
        print(f"WebSocket error: {e}")
        await websocket.close(code=status.WS_1011_INTERNAL_ERROR)

@router.get("/messages", response_model=List[dict])
def get_chat_messages(
    room_id: str = "general",
    limit: int = 50,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Get recent chat messages for a specific room
    """
    messages = db.query(ChatMessage).filter(
        ChatMessage.room_id == room_id
    ).order_by(ChatMessage.timestamp.desc()).limit(limit).all()

    result = []
    for msg in reversed(messages):
        user = db.query(User).filter(User.id == msg.user_id).first()
        if user:
            result.append({
                "id": msg.id,
                "user_id": msg.user_id,
                "full_name": user.full_name,
                "message": msg.message,
                "room_id": msg.room_id,
                "timestamp": msg.timestamp.isoformat(),
                "type": "chat"
            })

    return result

@router.get("/rooms")
def get_chat_rooms(current_user: User = Depends(get_current_user)):
    """
    Get available chat rooms
    """
    # For now, return static rooms, but this could be dynamic based on courses/enrollments
    return [
        {"id": "general", "name": "General", "description": "General discussion"},
        {"id": "help", "name": "Help & Support", "description": "Get help from teachers and admins"},
        {"id": "announcements", "name": "Announcements", "description": "Important announcements"}
    ]

@router.post("/messages/{message_id}/ack")
async def acknowledge_message(
    message_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Acknowledge receipt of a message (for reliability)
    """
    message = db.query(ChatMessage).filter(ChatMessage.id == message_id).first()
    if not message:
        raise HTTPException(status_code=404, detail="Message not found")

    # In a production system, you might want to track acknowledgments
    # For now, just return success
    return {"message": "Message acknowledged", "message_id": message_id}
