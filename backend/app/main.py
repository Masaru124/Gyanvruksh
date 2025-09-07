from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.api import auth, courses, gyanvruksh, chat
from contextlib import asynccontextmanager
import asyncio
import httpx
from app.database import Base, engine

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

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth.router)
app.include_router(courses.router)
app.include_router(gyanvruksh.router)
app.include_router(chat.router)

@app.get("/healthz")
def health():
    return {"status": "ok"}
