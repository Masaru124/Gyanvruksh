from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.exceptions import HTTPException
from .api import auth, courses, lessons, progress, chat, admin, attendance, student, teacher, gyanvruksh, ai_tutor
from .api.lessons import router as lessons_router
from .api.quizzes import router as quizzes_router
from .api.progress import router as progress_router
from .api.assignments import router as assignments_router
from .api.notifications import router as notifications_router
from .api.categories import router as categories_router
from .api.analytics import router as analytics_router
from .api.dashboard import router as dashboard_router
from .api.gamification import router as gamification_router
from .api.attendance import router as attendance_router
from .api.student import router as student_router
from .api.ai_tutor import router as ai_tutor_router
from .api.search import router as search_router
from .api.personalization import router as personalization_router
from .utils.errors import custom_http_exception_handler
from contextlib import asynccontextmanager
import asyncio
import httpx
from .database import Base, engine
# Import models to ensure they are registered
from .models import user, course, enrollment, chat_message, course_video, course_note
from .models.category import Category
from .models.lesson import Lesson
from .models.quiz import Quiz
from .models.progress import UserProgress, UserPreferences
from .models.gamification import Badge, Streak, DailyChallenge, UserBadge, UserChallenge
from .models.download import Download
from .models.assignment import Assignment, Grade, AssignmentSubmission
from .models.notification import Notification
from .models.analytics import Analytics, ParentDashboard
from .models.attendance import Attendance, AttendanceSession

APP_URL = "https://gyanvruksh.onrender.com"
PING_INTERVAL = 5 * 60  # 5 minutes

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Create DB tables
    Base.metadata.create_all(bind=engine)

    # Start self-ping loop in background
    async def self_ping():
        await asyncio.sleep(5)  # small delay to let server start fully
        while True:
            try:
                async with httpx.AsyncClient() as client:
                    res = await client.get(APP_URL)
            except Exception as e:
                pass
            await asyncio.sleep(PING_INTERVAL)

    asyncio.create_task(self_ping())

    yield  # 👈 App runs here

app = FastAPI(title="Gyanvruksh API", version="0.1.0", lifespan=lifespan)

# Add custom exception handler
app.add_exception_handler(HTTPException, custom_http_exception_handler)

app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:3000",
        "http://127.0.0.1:3000",
        "http://localhost:8000",
        "http://127.0.0.1:8000",
        "http://10.0.2.2:8000",  # Android emulator
        "http://10.0.2.2:3000",  # Android emulator alternative
        "https://gyanvruksh.onrender.com",
        "http://localhost:8080",
        "http://127.0.0.1:8080",
        "*",
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth.router)
app.include_router(courses.router)
app.include_router(gyanvruksh.router)
app.include_router(chat.router)
app.include_router(categories_router)
app.include_router(lessons_router)
app.include_router(quizzes_router)
app.include_router(progress_router)
app.include_router(assignments_router)
app.include_router(notifications_router)
app.include_router(analytics_router)
app.include_router(dashboard_router)
app.include_router(admin.router)
app.include_router(teacher.router)
app.include_router(attendance_router)
app.include_router(student_router)
app.include_router(gamification_router)
app.include_router(ai_tutor_router)
app.include_router(search_router)
app.include_router(personalization_router)

def health():
    return {"status": "ok"}
