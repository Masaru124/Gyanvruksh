from sqlalchemy import String, Boolean, DateTime, Integer
from sqlalchemy.orm import Mapped, mapped_column
from datetime import datetime
from app.database import Base

class User(Base):
    __tablename__ = "users"
    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    email: Mapped[str] = mapped_column(String(255), unique=True, index=True)
    hashed_password: Mapped[str] = mapped_column(String(255))
    full_name: Mapped[str] = mapped_column(String(255))
    age: Mapped[int] = mapped_column(Integer, nullable=True)
    gender: Mapped[str] = mapped_column(String(50), nullable=True)
    role: Mapped[str] = mapped_column(String(50), nullable=True)  # service_provider, service_seeker, admin
    sub_role: Mapped[str] = mapped_column(String(50), nullable=True)  # teacher, seller, student, buyer
    educational_qualification: Mapped[str] = mapped_column(String(255), nullable=True)
    preferred_language: Mapped[str] = mapped_column(String(50), nullable=True)  # kannada, english, hindi
    phone_number: Mapped[str] = mapped_column(String(20), nullable=True)
    address: Mapped[str] = mapped_column(String(255), nullable=True)
    emergency_contact: Mapped[str] = mapped_column(String(20), nullable=True)
    aadhar_card: Mapped[str] = mapped_column(String(20), nullable=True)
    account_details: Mapped[str] = mapped_column(String(255), nullable=True)
    dob: Mapped[datetime] = mapped_column(DateTime, nullable=True)
    marital_status: Mapped[str] = mapped_column(String(50), nullable=True)
    year_of_experience: Mapped[int] = mapped_column(Integer, nullable=True)
    parents_contact_details: Mapped[str] = mapped_column(String(255), nullable=True)
    parents_email: Mapped[str] = mapped_column(String(255), nullable=True)
    seller_type: Mapped[str] = mapped_column(String(50), nullable=True)  # common seller, business model
    company_id: Mapped[str] = mapped_column(String(255), nullable=True)
    seller_record: Mapped[str] = mapped_column(String(255), nullable=True)
    company_details: Mapped[str] = mapped_column(String(255), nullable=True)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)
    is_teacher: Mapped[bool] = mapped_column(Boolean, default=False)  # Keep for backward compatibility
    gyan_coins: Mapped[int] = mapped_column(Integer, default=0)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
