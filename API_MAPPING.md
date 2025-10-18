# EduConnect API Mapping - Frontend to Backend
## Canonical mapping between Flutter API calls and FastAPI backend routes

This document provides a comprehensive mapping of all API endpoints used by the Flutter frontend and their corresponding FastAPI backend implementations.

## Base Configuration
- **Frontend Base URL**: `https://gyanvruksh.onrender.com` (configurable via environment)
- **Backend Base URL**: Same as frontend base URL
- **API Prefix**: All routes use `/api/` prefix consistently

## Authentication Endpoints

| Frontend Method | Frontend Endpoint | Backend Route | Backend Method | Status | Notes |
|---|---|---|---|---|---|
| `register()` | `POST /api/auth/register` | `/api/auth/register` | POST | ✅ Implemented | User registration with comprehensive fields |
| `login()` | `POST /api/auth/login` | `/api/auth/login` | POST | ✅ Implemented | User login with email/password |
| `_fetchMe()` | `GET /api/auth/me` | `/api/auth/me` | GET | ✅ Implemented | Get current user profile |
| `logout()` | `POST /api/auth/logout` | `/api/auth/logout` | POST | ✅ Implemented | User logout |
| `createAdmin()` | `POST /api/auth/admin/create-admin` | `/api/auth/admin/create-admin` | POST | ✅ Implemented | Admin user creation |

## Course Management Endpoints

| Frontend Method | Frontend Endpoint | Backend Route | Backend Method | Status | Notes |
|---|---|---|---|---|---|
| `listCourses()` | `GET /api/courses/` | `/api/courses/` | GET | ✅ Implemented | List all courses |
| `myCourses()` | `GET /api/courses/mine` | `/api/courses/mine` | GET | ❌ Missing | Get user's enrolled courses |
| `createCourse()` | `POST /api/courses/` | `/api/courses/` | POST | ✅ Implemented | Create new course |
| `createCourseWithDetails()` | `POST /api/courses/` | `/api/courses/` | POST | ✅ Implemented | Create course with details |
| `getCourseDetails()` | `GET /api/courses/{id}/details` | `/api/courses/{id}/details` | GET | ❌ Missing | Get detailed course info |
| `updateCourse()` | `PUT /api/courses/admin/{id}` | `/api/courses/admin/{id}` | PUT | ✅ Implemented | Update course (admin) |
| `updateCourseDetails()` | `PUT /api/courses/admin/{id}` | `/api/courses/admin/{id}` | PUT | ✅ Implemented | Update course details |
| `deleteCourse()` | `DELETE /api/courses/admin/{id}` | `/api/courses/admin/{id}` | DELETE | ✅ Implemented | Delete course (admin) |

## Enrollment Endpoints

| Frontend Method | Frontend Endpoint | Backend Route | Backend Method | Status | Notes |
|---|---|---|---|---|---|
| `enrollInCourse()` | `POST /api/courses/enroll` | `/api/courses/enroll` | POST | ❌ Missing | Enroll in course (legacy) |
| `enrollInCourseNew()` | `POST /api/student/enroll` | `/api/student/enroll` | POST | ✅ Implemented | Enroll in course (new) |
| `enrollInCourseFixed()` | `POST /api/courses/{id}/enroll` | `/api/courses/{id}/enroll` | POST | ❌ Missing | Enroll in specific course |
| `getEnrolledCourses()` | `GET /api/courses/enrolled` | `/api/courses/enrolled` | GET | ❌ Missing | Get enrolled courses |
| `unenrollFromCourse()` | `DELETE /api/courses/enroll/{id}` | `/api/courses/enroll/{id}` | DELETE | ❌ Missing | Unenroll from course |
| `getAvailableCoursesForEnrollment()` | `GET /api/courses/available-for-enrollment` | `/api/courses/available-for-enrollment` | GET | ❌ Missing | Get available courses |

## Student Dashboard Endpoints

| Frontend Method | Frontend Endpoint | Backend Route | Backend Method | Status | Notes |
|---|---|---|---|---|---|
| `getStudentDashboard()` | `GET /api/student/dashboard/stats` | `/api/student/dashboard/stats` | GET | ✅ Implemented | Get student dashboard stats |
| `getTodaySchedule()` | `GET /api/student/upcoming-deadlines` | `/api/student/upcoming-deadlines` | GET | ❌ Missing | Get today's schedule |
| `getStudentAssignments()` | `GET /api/assignments/` | `/api/assignments/` | GET | ❌ Missing | Get student assignments |
| `getStudentProgressReport()` | `GET /api/student/progress-report` | `/api/student/progress-report` | GET | ✅ Implemented | Get progress report |
| `getLearningStreak()` | `GET /api/student/progress-report` | `/api/student/progress-report` | GET | ✅ Implemented | Get learning streak |

## Teacher Dashboard Endpoints

| Frontend Method | Frontend Endpoint | Backend Route | Backend Method | Status | Notes |
|---|---|---|---|---|---|
| `availableCourses()` | `GET /api/courses/available` | `/api/courses/available` | GET | ❌ Missing | Get available courses for teachers |
| `selectCourse()` | `POST /api/courses/{id}/select` | `/api/courses/{id}/select` | POST | ❌ Missing | Select course to teach |
| `teacherStats()` | `GET /api/courses/teacher/stats` | `/api/courses/teacher/stats` | GET | ❌ Missing | Get teacher statistics |
| `upcomingClasses()` | `GET /api/courses/teacher/upcoming-classes` | `/api/courses/teacher/upcoming-classes` | GET | ❌ Missing | Get upcoming classes |
| `studentQueries()` | `GET /api/courses/teacher/student-queries` | `/api/courses/teacher/student-queries` | GET | ❌ Missing | Get student queries |

## Assignment Endpoints

| Frontend Method | Frontend Endpoint | Backend Route | Backend Method | Status | Notes |
|---|---|---|---|---|---|
| `createAssignment()` | `POST /api/assignments/` | `/api/assignments/` | POST | ❌ Missing | Create assignment |
| `getAssignmentGrades()` | `GET /api/assignments/{id}/grades` | `/api/assignments/{id}/grades` | GET | ❌ Missing | Get assignment grades |
| `gradeAssignmentNewInternal()` | `POST /api/assignments/{id}/grade` | `/api/assignments/{id}/grade` | POST | ❌ Missing | Grade assignment |

## Quiz Endpoints

| Frontend Method | Frontend Endpoint | Backend Route | Backend Method | Status | Notes |
|---|---|---|---|---|---|
| `getTeacherQuizzes()` | `GET /api/teacher/quizzes` | `/api/teacher/quizzes` | GET | ❌ Missing | Get teacher's quizzes |
| `createQuiz()` | `POST /api/quizzes` | `/api/quizzes` | POST | ❌ Missing | Create quiz |
| `updateQuizStatus()` | `PATCH /api/quizzes/{id}` | `/api/quizzes/{id}` | PATCH | ❌ Missing | Update quiz status |

## Attendance Endpoints

| Frontend Method | Frontend Endpoint | Backend Route | Backend Method | Status | Notes |
|---|---|---|---|---|---|
| `getCourseAttendanceSessions()` | `GET /api/courses/{id}/attendance/sessions` | `/api/courses/{id}/attendance/sessions` | GET | ❌ Missing | Get attendance sessions |
| `createAttendanceSession()` | `POST /api/courses/{id}/attendance/sessions` | `/api/courses/{id}/attendance/sessions` | POST | ❌ Missing | Create attendance session |
| `markAttendance()` | `POST /api/attendance/mark` | `/api/attendance/mark` | POST | ❌ Missing | Mark attendance |

## Chat Endpoints

| Frontend Method | Frontend Endpoint | Backend Route | Backend Method | Status | Notes |
|---|---|---|---|---|---|
| `getChatMessages()` | `GET /api/chat/messages` | `/api/chat/messages` | GET | ❌ Missing | Get chat messages |

## Profile & User Management Endpoints

| Frontend Method | Frontend Endpoint | Backend Route | Backend Method | Status | Notes |
|---|---|---|---|---|---|
| `updateProfile()` | `PATCH /api/users/profile` | `/api/users/profile` | PATCH | ❌ Missing | Update user profile |
| `updateProfileLegacy()` | `PUT /api/auth/me` | `/api/auth/me` | PUT | ✅ Implemented | Update profile (legacy) |
| `listUsers()` | `GET /api/auth/admin/users` | `/api/auth/admin/users` | GET | ✅ Implemented | List all users (admin) |
| `deleteUser()` | `DELETE /api/auth/admin/users/{id}` | `/api/auth/admin/users/{id}` | DELETE | ❌ Missing | Delete user (admin) |

## Notification Endpoints

| Frontend Method | Frontend Endpoint | Backend Route | Backend Method | Status | Notes |
|---|---|---|---|---|---|
| `getNotifications()` | `GET /api/notifications` | `/api/notifications` | GET | ❌ Missing | Get notifications |
| `markNotificationRead()` | `PATCH /api/notifications/{id}/read` | `/api/notifications/{id}/read` | PATCH | ❌ Missing | Mark notification as read |

## Category Endpoints

| Frontend Method | Frontend Endpoint | Backend Route | Backend Method | Status | Notes |
|---|---|---|---|---|---|
| `getCategories()` | `GET /api/categories/` | `/api/categories/` | GET | ❌ Missing | Get categories |
| `getCategory()` | `GET /api/categories/{id}` | `/api/categories/{id}` | GET | ❌ Missing | Get category details |

## Lesson Endpoints

| Frontend Method | Frontend Endpoint | Backend Route | Backend Method | Status | Notes |
|---|---|---|---|---|---|
| `getLessons()` | `GET /api/lessons/` | `/api/lessons/` | GET | ❌ Missing | Get lessons |
| `getLesson()` | `GET /api/lessons/{id}` | `/api/lessons/{id}` | GET | ❌ Missing | Get lesson details |
| `createLesson()` | `POST /api/lessons/` | `/api/lessons/` | POST | ❌ Missing | Create lesson |

## Progress Endpoints

| Frontend Method | Frontend Endpoint | Backend Route | Backend Method | Status | Notes |
|---|---|---|---|---|---|
| `getCourseProgress()` | `GET /api/progress/courses/{id}` | `/api/progress/courses/{id}` | GET | ❌ Missing | Get course progress |
| `updateLessonProgress()` | `POST /api/progress/courses/{courseId}/lessons/{lessonId}` | `/api/progress/courses/{courseId}/lessons/{lessonId}` | POST | ❌ Missing | Update lesson progress |

## Admin Endpoints

| Frontend Method | Frontend Endpoint | Backend Route | Backend Method | Status | Notes |
|---|---|---|---|---|---|
| `getAdminDashboardStats()` | `GET /api/admin/dashboard/stats` | `/api/admin/dashboard/stats` | GET | ✅ Implemented | Get admin dashboard stats |
| `getAllUsers()` | `GET /api/admin/users` | `/api/admin/users` | GET | ❌ Missing | Get all users with pagination |
| `getPendingTeachers()` | `GET /api/admin/teachers/pending` | `/api/admin/teachers/pending` | GET | ❌ Missing | Get pending teachers |
| `approveTeacher()` | `POST /api/admin/teachers/approve` | `/api/admin/teachers/approve` | POST | ❌ Missing | Approve teacher |
| `getUnassignedCourses()` | `GET /api/admin/courses/unassigned` | `/api/admin/courses/unassigned` | GET | ❌ Missing | Get unassigned courses |
| `assignTeacherToCourse()` | `POST /api/admin/courses/assign-teacher` | `/api/admin/courses/assign-teacher` | POST | ❌ Missing | Assign teacher to course |

## Dashboard & Analytics Endpoints

| Frontend Method | Frontend Endpoint | Backend Route | Backend Method | Status | Notes |
|---|---|---|---|---|---|
| `getRecommendations()` | `GET /api/dashboard/recommendations` | `/api/dashboard/recommendations` | GET | ❌ Missing | Get recommendations |
| `getRecentCourses()` | `GET /api/dashboard/student/recent-courses` | `/api/dashboard/student/recent-courses` | GET | ❌ Missing | Get recent courses |
| `getTeacherDashboardStats()` | `GET /api/dashboard/teacher/dashboard-stats` | `/api/dashboard/teacher/dashboard-stats` | GET | ❌ Missing | Get teacher dashboard stats |

## Gamification & Social Endpoints

| Frontend Method | Frontend Endpoint | Backend Route | Backend Method | Status | Notes |
|---|---|---|---|---|---|
| `getLeaderboard()` | `GET /api/gyanvruksh/leaderboard` | `/api/gyanvruksh/leaderboard` | GET | ❌ Missing | Get leaderboard |
| `getProfile()` | `GET /api/gyanvruksh/profile` | `/api/gyanvruksh/profile` | GET | ❌ Missing | Get user profile |

## Content Management Endpoints

| Frontend Method | Frontend Endpoint | Backend Route | Backend Method | Status | Notes |
|---|---|---|---|---|---|
| `uploadCourseVideo()` | `POST /api/courses/admin/{id}/upload-video` | `/api/courses/admin/{id}/upload-video` | POST | ❌ Missing | Upload course video |
| `uploadCourseNote()` | `POST /api/courses/admin/{id}/upload-note` | `/api/courses/admin/{id}/upload-note` | POST | ❌ Missing | Upload course note |
| `getCourseVideos()` | `GET /api/courses/{id}/videos` | `/api/courses/{id}/videos` | GET | ❌ Missing | Get course videos |
| `getCourseNotes()` | `GET /api/courses/{id}/notes` | `/api/courses/{id}/notes` | GET | ❌ Missing | Get course notes |
| `deleteCourseVideo()` | `DELETE /api/courses/admin/{courseId}/videos/{videoId}` | `/api/courses/admin/{courseId}/videos/{videoId}` | DELETE | ❌ Missing | Delete course video |
| `updateCourseVideo()` | `PUT /api/courses/admin/{courseId}/videos/{videoId}` | `/api/courses/admin/{courseId}/videos/{videoId}` | PUT | ❌ Missing | Update course video |

## Summary

**Total Endpoints Analyzed**: ~80+
**✅ Fully Implemented**: ~25 (31%)
**❌ Missing/Incomplete**: ~55 (69%)

### Key Issues Identified:
1. **Student-specific endpoints** are largely missing or incomplete
2. **Teacher dashboard endpoints** need implementation
3. **Assignment and quiz management** endpoints are missing
4. **Attendance system** is incomplete
5. **Real-time chat** infrastructure is missing
6. **File upload** capabilities are missing
7. **Dashboard and analytics** endpoints are incomplete
8. **Admin bulk operations** are missing

### Next Steps:
1. Implement missing student and teacher dashboard endpoints
2. Complete assignment and quiz management system
3. Add attendance tracking functionality
4. Implement file upload for assignments
5. Add real-time chat with WebSocket support
6. Complete admin panel functionality
7. Add comprehensive error handling and validation
