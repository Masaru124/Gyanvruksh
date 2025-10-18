# TODO: Fix Complete API Test Issues

## Steps to Complete
- [ ] Update student email in complete_api_test.py from 'mail-student@example.com' to 'student@example.com' to match add_users.py
- [ ] Update admin password in complete_api_test.py from 'masarukaze041@gmail.com' to 'admin123' to match add_users.py
- [ ] Change registration test email to 'testuser@example.com' to avoid 409 conflict
- [ ] Update endpoint tests requiring authentication (e.g., /api/courses/available-for-enrollment, /api/courses/recommended, /api/assignments/, /api/notifications, /api/chat/messages, /api/student/progress-report) to use appropriate user_type like 'student'
- [ ] Run the complete_api_test.py again to verify fixes
