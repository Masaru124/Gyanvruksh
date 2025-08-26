from app.database import Base, engine
from app.models.user import User
from app.models.course import Course

def init():
    Base.metadata.create_all(bind=engine)
    print("✅ Tables created")

if __name__ == "__main__":
    init()
