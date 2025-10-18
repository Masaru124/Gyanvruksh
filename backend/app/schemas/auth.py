from pydantic import BaseModel, EmailStr, field_validator
from typing import Optional
from datetime import datetime

class Token(BaseModel):
    access_token: str
    token_type: str = "bearer"

class UserCreate(BaseModel):
    email: EmailStr
    password: str
    full_name: str
    age: Optional[int] = None
    gender: Optional[str] = None
    role: str  # service_provider, service_seeker, admin
    sub_role: str  # teacher, seller, student, buyer
    educational_qualification: Optional[str] = None
    preferred_language: Optional[str] = None
    phone_number: Optional[str] = None
    address: Optional[str] = None
    emergency_contact: Optional[str] = None
    aadhar_card: Optional[str] = None
    account_details: Optional[str] = None
    dob: Optional[datetime] = None
    marital_status: Optional[str] = None
    year_of_experience: Optional[int] = None
    parents_contact_details: Optional[str] = None
    parents_email: Optional[str] = None
    seller_type: Optional[str] = None
    company_id: Optional[str] = None
    seller_record: Optional[str] = None
    company_details: Optional[str] = None
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

    @field_validator('phone_number')
    @classmethod
    def validate_phone_number(cls, v, info):
        sub_role = info.data.get('sub_role')
        if sub_role in ['teacher', 'student', 'seller', 'buyer'] and not v:
            raise ValueError('Phone number is required')
        return v

    @field_validator('address')
    @classmethod
    def validate_address(cls, v, info):
        sub_role = info.data.get('sub_role')
        if sub_role in ['teacher', 'student', 'seller', 'buyer'] and not v:
            raise ValueError('Address is required')
        return v

    @field_validator('emergency_contact')
    @classmethod
    def validate_emergency_contact(cls, v, info):
        sub_role = info.data.get('sub_role')
        if sub_role in ['teacher', 'student', 'seller', 'buyer'] and not v:
            raise ValueError('Emergency contact is required')
        return v

    @field_validator('aadhar_card')
    @classmethod
    def validate_aadhar_card(cls, v, info):
        sub_role = info.data.get('sub_role')
        if sub_role in ['teacher', 'student', 'seller'] and not v:
            raise ValueError('Aadhar card is required')
        return v

    @field_validator('account_details')
    @classmethod
    def validate_account_details(cls, v, info):
        sub_role = info.data.get('sub_role')
        if sub_role in ['teacher', 'student', 'seller', 'buyer'] and not v:
            raise ValueError('Account details are required')
        return v

    @field_validator('dob')
    @classmethod
    def validate_dob(cls, v, info):
        sub_role = info.data.get('sub_role')
        if sub_role in ['teacher', 'student'] and not v:
            raise ValueError('Date of birth is required')
        return v

    @field_validator('marital_status')
    @classmethod
    def validate_marital_status(cls, v, info):
        if info.data.get('sub_role') == 'teacher' and not v:
            raise ValueError('Marital status is required for teachers')
        return v

    @field_validator('year_of_experience')
    @classmethod
    def validate_year_of_experience(cls, v, info):
        sub_role = info.data.get('sub_role')
        if sub_role in ['teacher', 'seller'] and not v:
            raise ValueError('Year of experience is required')
        return v

    @field_validator('parents_contact_details')
    @classmethod
    def validate_parents_contact_details(cls, v, info):
        if info.data.get('sub_role') == 'student' and not v:
            raise ValueError('Parents contact details are required for students')
        return v

    @field_validator('parents_email')
    @classmethod
    def validate_parents_email(cls, v, info):
        if info.data.get('sub_role') == 'student' and not v:
            raise ValueError('Parents email is required for students')
        return v

    @field_validator('seller_type')
    @classmethod
    def validate_seller_type(cls, v, info):
        if info.data.get('sub_role') == 'seller' and not v:
            raise ValueError('Seller type is required for sellers')
        return v

    @field_validator('company_id')
    @classmethod
    def validate_company_id(cls, v, info):
        if info.data.get('sub_role') == 'seller' and not v:
            raise ValueError('Company ID is required for sellers')
        return v

    @field_validator('seller_record')
    @classmethod
    def validate_seller_record(cls, v, info):
        if info.data.get('sub_role') == 'seller' and not v:
            raise ValueError('Seller record is required for sellers')
        return v

    @field_validator('company_details')
    @classmethod
    def validate_company_details(cls, v, info):
        if info.data.get('sub_role') == 'seller' and not v:
            raise ValueError('Company details are required for sellers')
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
    phone_number: Optional[str]
    address: Optional[str]
    emergency_contact: Optional[str]
    aadhar_card: Optional[str]
    account_details: Optional[str]
    dob: Optional[datetime]
    marital_status: Optional[str]
    year_of_experience: Optional[int]
    parents_contact_details: Optional[str]
    parents_email: Optional[str]
    seller_type: Optional[str]
    company_id: Optional[str]
    seller_record: Optional[str]
    company_details: Optional[str]
    is_teacher: bool
    gyan_coins: int

    model_config = {"from_attributes": True}

class Token(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    expires_in: int  # seconds until access token expires

class TokenRefresh(BaseModel):
    refresh_token: str
