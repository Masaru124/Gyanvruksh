from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from app.database import get_db
from app.models.user import User
from app.schemas.auth import UserCreate, UserLogin, UserOut, Token
from app.services.security import hash_password, verify_password, create_access_token
from app.services.deps import get_current_user

router = APIRouter(prefix="/api/auth", tags=["auth"])

@router.post("/register", response_model=UserOut, status_code=201)
def register(payload: UserCreate, db: Session = Depends(get_db)):
    if db.query(User).filter(User.email == payload.email).first():
        raise HTTPException(status_code=400, detail="Email already registered")
    if payload.role == "admin":
        raise HTTPException(status_code=403, detail="Admin registration is not allowed")
    user = User(
        email=payload.email,
        full_name=payload.full_name,
        hashed_password=hash_password(payload.password),
        age=payload.age,
        gender=payload.gender,
        role=payload.role,
        sub_role=payload.sub_role,
        educational_qualification=payload.educational_qualification,
        preferred_language=payload.preferred_language,
        phone_number=payload.phone_number,
        address=payload.address,
        emergency_contact=payload.emergency_contact,
        aadhar_card=payload.aadhar_card,
        account_details=payload.account_details,
        dob=payload.dob,
        marital_status=payload.marital_status,
        year_of_experience=payload.year_of_experience,
        parents_contact_details=payload.parents_contact_details,
        parents_email=payload.parents_email,
        seller_type=payload.seller_type,
        company_id=payload.company_id,
        seller_record=payload.seller_record,
        company_details=payload.company_details,
        is_teacher=payload.is_teacher
    )
    db.add(user)
    db.commit()
    db.refresh(user)
    return user

@router.post("/login", response_model=Token)
def login(payload: UserLogin, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.email == payload.email).first()
    if not user or not verify_password(payload.password, user.hashed_password):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid credentials")
    token = create_access_token(user.email)
    return Token(access_token=token)

@router.get("/me", response_model=UserOut)
def me(user: User = Depends(get_current_user)):
    return user

@router.post("/admin/create-admin", response_model=UserOut, status_code=201)
def create_admin(payload: UserCreate, db: Session = Depends(get_db), user: User = Depends(get_current_user)):
    if user.role != "admin":
        raise HTTPException(status_code=403, detail="Only admins can create other admins")
    if db.query(User).filter(User.email == payload.email).first():
        raise HTTPException(status_code=400, detail="Email already registered")
    if payload.role != "admin":
        raise HTTPException(status_code=400, detail="This endpoint is only for creating admin users")
    admin_user = User(
        email=payload.email,
        full_name=payload.full_name,
        hashed_password=hash_password(payload.password),
        age=payload.age,
        gender=payload.gender,
        role=payload.role,
        sub_role=payload.sub_role,
        educational_qualification=payload.educational_qualification,
        preferred_language=payload.preferred_language,
        is_teacher=payload.is_teacher
    )
    db.add(admin_user)
    db.commit()
    db.refresh(admin_user)
    return admin_user

@router.get("/admin/users", response_model=List[UserOut])
def list_users(db: Session = Depends(get_db), user: User = Depends(get_current_user)):
    if user.role != "admin":
        raise HTTPException(status_code=403, detail="Only admins can list users")
    return db.query(User).all()

@router.put("/admin/users/{user_id}", response_model=UserOut)
def update_user(user_id: int, payload: UserCreate, db: Session = Depends(get_db), user: User = Depends(get_current_user)):
    if user.role != "admin":
        raise HTTPException(status_code=403, detail="Only admins can update users")
    db_user = db.query(User).filter(User.id == user_id).first()
    if not db_user:
        raise HTTPException(status_code=404, detail="User not found")
    for key, value in payload.model_dump().items():
        setattr(db_user, key, value)
    db.commit()
    db.refresh(db_user)
    return db_user

@router.delete("/admin/users/{user_id}")
def delete_user(user_id: int, db: Session = Depends(get_db), user: User = Depends(get_current_user)):
    if user.role != "admin":
        raise HTTPException(status_code=403, detail="Only admins can delete users")
    db_user = db.query(User).filter(User.id == user_id).first()
    if not db_user:
        raise HTTPException(status_code=404, detail="User not found")
    db.delete(db_user)
    db.commit()
    return {"message": "User deleted successfully"}

@router.post("/logout")
def logout(user: User = Depends(get_current_user)):
    # For JWT tokens, logout is handled client-side by clearing the token
    # In a production app, you might want to implement token blacklisting
    return {"message": "Logged out successfully"}

@router.put("/me", response_model=UserOut)
def update_profile(payload: UserCreate, db: Session = Depends(get_db), user: User = Depends(get_current_user)):
    """Update current user's profile"""
    # Update user fields
    for key, value in payload.model_dump(exclude_unset=True).items():
        if key == "password":
            # Hash password if being updated
            from app.services.security import hash_password
            setattr(user, "hashed_password", hash_password(value))
        elif key != "email":  # Don't allow email updates for security
            setattr(user, key, value)

    db.commit()
    db.refresh(user)
    return user
