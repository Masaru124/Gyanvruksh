# EduConnect Feature Implementation TODO

## Backend Changes
- [x] Modify course creation logic - Admin-created courses should have teacher_id = None initially
- [x] Add enrollment model for student course enrollments
- [x] Add enrollment API endpoints for students (enroll, unenroll, list enrolled courses)
- [x] Add detailed course view endpoint with teacher info and enrolled students
- [x] Add profile update API endpoint (PUT /api/auth/me)

## Frontend Changes
- [x] Update teacher dashboard to ensure proper course selection flow
- [x] Add student enrollment UI in courses screen
- [x] Implement profile update functionality in profile screen
- [x] Add detailed course view screen with comprehensive information
- [x] Update API service with new endpoints (enrollment, profile update, detailed course view)

## Testing
- [ ] Test admin course creation (teacher_id should be null)
- [ ] Test teacher course selection
- [ ] Test student enrollment in courses
- [ ] Test profile update functionality
- [ ] Test detailed course view
