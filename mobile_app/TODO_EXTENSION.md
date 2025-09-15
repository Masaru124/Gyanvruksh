# Gyanvruksh App Extension Plan

## Overview
Extend the existing Flutter + FastAPI learning app to a comprehensive all-in-one platform for academic, skill, sports, and creative learning. Mission: Promote balanced growth with academic excellence + creative skills + physical fitness.

## Existing Structure
- **Backend**: FastAPI with SQLAlchemy, models: User (with gyan_coins), Course, Enrollment, ChatMessage, CourseNote, CourseVideo. APIs: auth, courses, gyanvruksh, chat.
- **Frontend**: Flutter with BLoC, repositories, viewmodels, futuristic theme, screens for login, dashboards, courses, chat.
- **Features**: Basic login, course listing, video player, quiz, chat, leaderboard, profile.

## New Feature Categories (8 Major Areas)

### 1. CORE LEARNING FEATURES
- User-Friendly UI: Clean layout, easy navigation, suitable for children/teens/adults.
- Personalized Learning Paths: Suggest lessons based on interests, skill level, progress.
- Multi-format Content Support: Text, video, audio, interactive quizzes, flashcards.
- Progress Tracking: Show streaks, scores, completion %, skill analytics.
- Advanced Search/Filter: Search courses by type, difficulty, category.
- Offline Support: Download content for offline use.
- Gamification: Points, badges, leaderboards, daily streaks.

### 2. MULTI-DISCIPLINE SUPPORT
- Structure content for 4 main categories: Academics, Skills, Sports, Creativity.
- Each has: Lessons (video + text + tasks), Practice activities, Progress tracker, Visual growth as "Skill Tree" 🌱.

### 3. TEACHER / MENTOR FEATURES
- Teacher Dashboard: Upload lessons, quizzes, monitor student progress.
- Live Class Scheduling: With integration (Zoom, Jitsi, or native WebRTC).
- Assignment Upload + Grading System.
- Peer Discussion Forums / Community Chat.
- Mentor Connect: One-on-one video booking & messaging system.

### 4. STUDENT FEATURES
- Talent Wall: Upload creative work (videos, drawings, coding projects).
- Daily Routine Builder: Smart planner balancing study + skill + exercise.
- Skill Coins/Points: Earn by completing lessons, redeem for badges/content.
- Micro-learning Mode: 2–5 min lessons or practice drills.
- Revision Flashcards: AI picks weak topics automatically.

### 5. MOTIVATION + GAMIFICATION
- Daily/Weekly Challenges (quizzes, workouts, creative contests).
- Level-Up System with Tags (e.g. "Math Master Lvl 3").
- Avatar Customization with unlockable items.
- Leaderboards: Friends, class, global.
- Habit Tracker: Calendar-based daily progress/streaks.

### 6. COMMUNITY & CONNECTIVITY
- Join clubs (e.g., Robotics, Dance Crew, etc.).
- Live Events: Webinars, Hackathons, Debates.
- Student Collaboration Projects (e.g., team up to build apps or performances).
- Talent Marketplace (Optional): Sell or showcase digital work.

### 7. ANALYTICS & TRACKING
- 360° Progress Dashboard (Academics, Fitness, Creativity).
- Smart Reports (AI-generated improvement tips).
- Parent Dashboard (see child's all-round growth).
- Skill Tracker vs. Grade Tracker.

### 8. ADVANCED FEATURES (Optional/Phase 2)
- AI Tutor Chatbot (doubt-solving 24/7 using LLMs).
- AR/VR Lessons (e.g., Virtual Labs, 3D Anatomy, Field Trips).
- Wearables Integration (fitness tracking via smartwatch).
- Career Mentor AI (Suggest future paths based on skills + interests).
- Certification & Scholarship Integration.

## Infrastructure & Extras
- Secure Auth: Phone, Email, Google login with OTP.
- Notifications: Reminders for classes, streaks, challenges.
- Multi-language UI support.
- Accessibility: Text-to-speech, font size control, dark mode.

## Implementation Plan (Phased Approach)

### Phase 1: Foundation & Core Learning Features (Priority)
1. **Database Models**:
   - Category (Academics, Skills, Sports, Creativity)
   - Lesson (belongs to Course, with content types)
   - Quiz, Question, Answer
   - Progress (user progress on lessons/quizzes)
   - Badge, Achievement
   - Streak, DailyChallenge
   - Download (for offline content)
   - UserPreferences (for personalization)

2. **APIs**:
   - categories, lessons, quizzes, progress, badges, challenges
   - Personalized recommendations
   - Search/filter courses/lessons
   - Offline download management

3. **Frontend**:
   - Update Course model to include categories, lessons
   - New screens: Lesson viewer, Quiz player, Progress dashboard, Search screen
   - Widgets: Skill tree, Progress bars, Badges display
   - Offline storage and sync

### Phase 2: Multi-Discipline & Teacher Features
1. **Models**: Assignment, Grade, LiveClass, ForumPost
2. **APIs**: Teacher dashboard APIs, assignment management, grading
3. **Frontend**: Teacher dashboard enhancements, assignment screens, live class integration

### Phase 3: Student & Gamification Features
1. **Models**: TalentPost, Routine, Flashcard, AvatarItem
2. **APIs**: Talent wall, routine builder, flashcard AI selection
3. **Frontend**: Talent wall screen, routine planner, avatar customization

### Phase 4: Community & Analytics
1. **Models**: Club, Event, CollaborationProject, AnalyticsReport
2. **APIs**: Club management, events, analytics generation
3. **Frontend**: Club screens, event calendar, analytics dashboard

### Phase 5: Advanced Features (Optional)
- AI integrations, AR/VR, wearables

## Technical Priorities
- Modular, reusable code
- Scalable architecture
- Performance optimization
- Security best practices
- Accessibility compliance

## Next Steps
- Start with Phase 1 database models and APIs
- Create migration scripts
- Update frontend models and repositories
- Build core screens
