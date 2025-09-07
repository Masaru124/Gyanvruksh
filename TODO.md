# TODO: Add Real-Time Chatroom Feature and Admin Course Management

## Backend Tasks
- [x] Create ChatMessage model in backend/app/models/chat_message.py
- [x] Create chat API router in backend/app/api/chat.py with WebSocket endpoint
- [x] Update backend/app/main.py to include chat router
- [x] Run database migration for new ChatMessage table
- [x] Create CourseVideo model in backend/app/models/course_video.py
- [x] Create CourseNote model in backend/app/models/course_note.py
- [x] Add admin endpoints for teacher assignment, video/note uploads in backend/app/api/courses.py
- [x] Remove select_course endpoint to prevent teacher self-enrollment
- [x] Create migration scripts for new tables
- [x] Update backend/app/db_init.py to include new models

## Mobile App Tasks
- [x] Add web_socket_channel dependency to mobile_app/pubspec.yaml
- [x] Create chatroom screen in mobile_app/lib/screens/chatroom_screen.dart
- [x] Update navigation in mobile_app/lib/screens/navigation.dart to include chatroom
- [x] Update API service in mobile_app/lib/services/api.dart to handle WebSocket connections and admin methods
- [x] Update admin dashboard in mobile_app/lib/screens/admin_dashboard.dart with course management, user management, logout
- [x] Enhance manage users screen in mobile_app/lib/screens/manage_users.dart to show all user details
- [x] Update teacher dashboard in mobile_app/lib/screens/teacher_dashboard.dart to remove self-enrollment, add logout

## Testing and Followup
- [ ] Test WebSocket connection between backend and mobile app
- [ ] Test admin course management features (assign teachers, upload videos/notes)
- [ ] Test enhanced user management UI
- [ ] Test logout functionality for admin and teacher dashboards
- [ ] Verify real-time messaging works for teachers and students
- [ ] Update UI if needed for better user experience
