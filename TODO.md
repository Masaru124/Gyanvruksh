# TODO: Add Real-Time Chatroom Feature

## Backend Tasks
- [x] Create ChatMessage model in backend/app/models/chat_message.py
- [x] Create chat API router in backend/app/api/chat.py with WebSocket endpoint
- [x] Update backend/app/main.py to include chat router
- [x] Run database migration for new ChatMessage table

## Mobile App Tasks
- [x] Add web_socket_channel dependency to mobile_app/pubspec.yaml
- [x] Create chatroom screen in mobile_app/lib/screens/chatroom_screen.dart
- [x] Update navigation in mobile_app/lib/screens/navigation.dart to include chatroom
- [x] Update API service in mobile_app/lib/services/api.dart to handle WebSocket connections

## Testing and Followup
- [ ] Test WebSocket connection between backend and mobile app
- [ ] Verify real-time messaging works for teachers and students
- [ ] Update UI if needed for better user experience
