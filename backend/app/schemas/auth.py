from pydantic import BaseModel, EmailStr, field_validator
from typing import Optional

class Token(BaseModel):
    access_token: str
    token_type: str = "bearer"

class UserCreate(BaseModel):
    email: EmailStr
    password: str
    full_name: str
    age: int
    gender: str
    role: str  # service_provider, service_seeker, admin
    sub_role: str  # teacher, seller, student, buyer
    educational_qualification: Optional[str] = None
    preferred_language: Optional[str] = None
    is_teacher: bool = False  # Keep for backward compatibility

    @field_validator('educational_qualification')
    @classmethod
    def validate_educational_qualification(cls, v, info):
        if info.data.get('sub_role') == 'teacher' and not v:
            raise ValueError('Educational qualification is required for teachers')
        return v

    @field_validator('preferred_language')
    @classmethod
    def validate_preferred_language(cls, v, info):
        if info.data.get('sub_role') == 'student' and not v:
            raise ValueError('Preferred language is required for students')
        return v

class UserLogin(BaseModel):
    email: EmailStr
    password: str

class UserOut(BaseModel):
    id: int
    email: EmailStr
    full_name: str
    age: Optional[int]
    gender: Optional[str]
    role: Optional[str]
    sub_role: Optional[str]
    educational_qualification: Optional[str]
    preferred_language: Optional[str]
    is_teacher: bool

    model_config = {"from_attributes": True}
