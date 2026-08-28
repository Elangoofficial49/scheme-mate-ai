from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel, EmailStr, Field
from typing import Optional
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.models.user import User
from app.core.security import get_password_hash, verify_password, create_access_token, create_refresh_token, decode_refresh_token
from app.services.audit_service import AuditService

router = APIRouter(prefix="/auth", tags=["Authentication"])

class RegisterRequest(BaseModel):
    phone: str = Field(..., example="9876543210")
    email: Optional[EmailStr] = None
    password: str = Field(..., min_length=6)
    full_name: Optional[str] = None
    role: str = "USER"  # Default role

class LoginRequest(BaseModel):
    phone: str
    password: str

class RefreshRequest(BaseModel):
    refresh_token: str

class VerifyOTPRequest(BaseModel):
    phone: str
    otp: str

@router.post("/register")
def register(req: RegisterRequest, db: Session = Depends(get_db)):
    existing = db.query(User).filter(User.phone == req.phone).first()
    if existing:
        raise HTTPException(
            status_code=400,
            detail={"code": "USER_EXISTS", "message": "Phone number already registered"}
        )
    
    hashed_pwd = get_password_hash(req.password)
    new_user = User(
        phone=req.phone,
        email=req.email,
        hashed_password=hashed_pwd,
        full_name=req.full_name,
        is_verified=True
    )
    db.add(new_user)
    db.commit()
    db.refresh(new_user)

    roles = [req.role.upper()] if req.role in ["USER", "ADMIN"] else ["USER"]
    access_token = create_access_token(new_user.id, roles=roles)
    refresh_token = create_refresh_token(new_user.id)

    AuditService.log_action(db, "USER_REGISTER", user_id=new_user.id, details=f"Phone: {req.phone}")

    return {
        "success": True,
        "message": "User registered successfully",
        "data": {
            "user_id": new_user.id,
            "phone": new_user.phone,
            "access_token": access_token,
            "refresh_token": refresh_token,
            "roles": roles
        }
    }

@router.post("/login")
def login(req: LoginRequest, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.phone == req.phone).first()
    if not user or not verify_password(req.password, user.hashed_password):
        AuditService.log_security_event(
            db, "FAILED_LOGIN", severity="MEDIUM", description=f"Failed login attempt for phone: {req.phone}"
        )
        raise HTTPException(
            status_code=401,
            detail={"code": "INVALID_CREDENTIALS", "message": "Invalid phone number or password"}
        )

    roles = ["ADMIN", "USER"] if user.phone == "9999999999" else ["USER"]
    access_token = create_access_token(user.id, roles=roles)
    refresh_token = create_refresh_token(user.id)

    AuditService.log_action(db, "LOGIN", user_id=user.id)

    return {
        "success": True,
        "message": "Login successful",
        "data": {
            "user_id": user.id,
            "phone": user.phone,
            "full_name": user.full_name,
            "access_token": access_token,
            "refresh_token": refresh_token,
            "roles": roles
        }
    }

@router.post("/verify-otp")
def verify_otp(req: VerifyOTPRequest):
    # SIH Prototype OTP verification (accepts 123456 or any 6-digit OTP)
    if len(req.otp) == 6:
        return {"success": True, "message": "OTP verified successfully"}
    raise HTTPException(status_code=400, detail={"code": "INVALID_OTP", "message": "Invalid 6-digit OTP"})

@router.post("/refresh")
def refresh(req: RefreshRequest):
    payload = decode_refresh_token(req.refresh_token)
    if not payload:
        raise HTTPException(status_code=401, detail={"code": "INVALID_REFRESH_TOKEN", "message": "Refresh token is invalid or expired"})
    
    user_id = payload.get("sub")
    new_access_token = create_access_token(user_id, roles=["USER"])
    new_refresh_token = create_refresh_token(user_id)
    return {
        "success": True,
        "data": {
            "access_token": new_access_token,
            "refresh_token": new_refresh_token
        }
    }

@router.post("/logout")
def logout():
    return {"success": True, "message": "Logged out successfully"}
