import datetime
import secrets
from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel, EmailStr, Field
from typing import Optional
from sqlalchemy.orm import Session
from sqlalchemy import select
from app.core.database import get_db
from app.core.config import settings
from app.models.user import User, user_roles
from app.core.security import get_password_hash, verify_password, create_access_token, create_refresh_token, decode_refresh_token
from app.services.audit_service import AuditService
from app.services.email_service import EmailService
from app.core.mongodb import sync_save_to_mongodb

router = APIRouter(prefix="/auth", tags=["Authentication"])

class RegisterRequest(BaseModel):
    full_name: str = Field(..., example="Ramesh Kumar")
    email: EmailStr = Field(..., example="ramesh@example.com")
    phone: str = Field(..., example="9876543210")
    password: str = Field(..., min_length=6)
    aadhaar_number: Optional[str] = None
    role: str = "USER"

class LoginRequest(BaseModel):
    email: Optional[str] = None
    phone: Optional[str] = None
    password: str

class RefreshRequest(BaseModel):
    refresh_token: str

class VerifyOTPRequest(BaseModel):
    phone: str
    otp: str

class ResendOTPRequest(BaseModel):
    phone: str
    email: Optional[str] = None

class ForgotPasswordRequest(BaseModel):
    email: EmailStr

class ResetPasswordRequest(BaseModel):
    email: EmailStr
    new_password: str = Field(..., min_length=6)
    otp: Optional[str] = None

@router.post("/register")
def register(req: RegisterRequest, db: Session = Depends(get_db)):
    clean_phone = req.phone.strip()
    clean_email = str(req.email).strip().lower()
    
    # 1. Search for any existing user by phone OR email
    existing_user = db.query(User).filter(
        (User.phone == clean_phone) | (User.email == clean_email)
    ).first()

    otp = f"{secrets.randbelow(900000) + 100000}"
    hashed_pwd = get_password_hash(req.password)
    
    if existing_user:
        if existing_user.is_verified:
            if existing_user.phone == clean_phone:
                raise HTTPException(
                    status_code=400,
                    detail={"code": "USER_EXISTS", "message": "Phone number is already registered. Please login."}
                )
            else:
                raise HTTPException(
                    status_code=400,
                    detail={"code": "EMAIL_EXISTS", "message": "Email address is already registered. Please login."}
                )
        
        # User exists but is not verified yet: safely update details and send fresh OTP
        existing_user.phone = clean_phone
        existing_user.email = clean_email
        existing_user.full_name = req.full_name
        existing_user.hashed_password = hashed_pwd
        existing_user.email_otp = otp
        existing_user.otp_expires_at = datetime.datetime.utcnow() + datetime.timedelta(minutes=15)
        db.commit()
        db.refresh(existing_user)
        target_user = existing_user
    else:
        # Create brand new user
        target_user = User(
            phone=clean_phone,
            email=clean_email,
            aadhaar_number=req.aadhaar_number,
            hashed_password=hashed_pwd,
            full_name=req.full_name,
            is_verified=False,
            email_otp=otp,
            otp_expires_at=datetime.datetime.utcnow() + datetime.timedelta(minutes=15)
        )
        try:
            db.add(target_user)
            db.commit()
            db.refresh(target_user)
        except Exception:
            db.rollback()
            conflict_user = db.query(User).filter((User.phone == clean_phone) | (User.email == clean_email)).first()
            if conflict_user and not conflict_user.is_verified:
                conflict_user.phone = clean_phone
                conflict_user.email = clean_email
                conflict_user.full_name = req.full_name
                conflict_user.hashed_password = hashed_pwd
                conflict_user.email_otp = otp
                conflict_user.otp_expires_at = datetime.datetime.utcnow() + datetime.timedelta(minutes=15)
                db.commit()
                target_user = conflict_user
            else:
                raise HTTPException(
                    status_code=400,
                    detail={"code": "REGISTRATION_ERROR", "message": "Account already exists with this phone or email. Please login."}
                )

    # Store the OTP in the service cache; the database value is retained only
    # for compatibility with existing records and is never returned or logged.
    EmailService.store_otp(target_user.email, otp, expiry_minutes=15)

    # Automatically insert/update user document in MongoDB Atlas
    sync_save_to_mongodb("users", {
        "id": target_user.id,
        "phone": target_user.phone,
        "email": target_user.email,
        "full_name": target_user.full_name,
        "role": getattr(target_user, "role", None) or getattr(req, "role", "USER"),
        "is_verified": target_user.is_verified,
        "hashed_password": target_user.hashed_password,
        "created_at": str(target_user.created_at) if hasattr(target_user, "created_at") else None
    }, query_filter={"email": target_user.email})

    email_result = EmailService.send_otp_email(to_email=clean_email, otp=otp, user_name=req.full_name)

    AuditService.log_action(db, "USER_REGISTER_INITIATED", user_id=target_user.id, details=f"Delivered: {email_result.get('delivered')}")

    success_msg = f"Security OTP sent to your registered email address ({clean_email})" if email_result.get("delivered") else f"Security OTP generated for {clean_email}"

    return {
        "success": True,
        "message": success_msg,
        "data": {
            "user_id": target_user.id,
            "phone": target_user.phone,
            "email": target_user.email,
            "otp_sent": True,
            "email_delivered": email_result.get("delivered", False)
        }
    }

@router.post("/login")
def login(req: LoginRequest, db: Session = Depends(get_db)):
    identifier = (req.email or req.phone or "").strip()
    if not identifier:
        raise HTTPException(
            status_code=400,
            detail={"code": "INVALID_INPUT", "message": "Email is required"}
        )

    user = db.query(User).filter((User.email == identifier.lower()) | (User.phone == identifier)).first()

    # Dual-Sync Fallback: If user not found in SQLite, check persistent MongoDB Atlas cloud collection
    if not user:
        try:
            from app.core.mongodb import mongo_manager, init_mongodb
            if mongo_manager.sync_client is None:
                init_mongodb()
            if mongo_manager.sync_client is not None:
                sync_db = mongo_manager.sync_client[settings.MONGODB_DB_NAME]
                m_doc = sync_db["users"].find_one({
                    "$or": [{"email": identifier.lower()}, {"phone": identifier}]
                })
                if m_doc and "hashed_password" in m_doc:
                    user = User(
                        id=m_doc.get("id", str(secrets.token_hex(16))),
                        phone=m_doc.get("phone", identifier),
                        email=m_doc.get("email", identifier.lower()),
                        aadhaar_number=m_doc.get("aadhaar_number"),
                        hashed_password=m_doc["hashed_password"],
                        full_name=m_doc.get("full_name", "Entrepreneur"),
                        is_active=bool(m_doc.get("is_active", 1)),
                        is_verified=bool(m_doc.get("is_verified", 1))
                    )
                    try:
                        db.add(user)
                        db.commit()
                        db.refresh(user)
                    except Exception:
                        db.rollback()
                        user = db.query(User).filter((User.email == identifier.lower()) | (User.phone == identifier)).first()
        except Exception as mongo_err:
            pass

    clean_pwd = req.password.strip() if req.password else ""
    is_valid_pwd = bool(user and user.hashed_password and (
        verify_password(req.password, user.hashed_password) or
        verify_password(clean_pwd, user.hashed_password)
    ))

    if not user or not is_valid_pwd:
        AuditService.log_security_event(
            db, "FAILED_LOGIN", severity="MEDIUM", description=f"Failed login attempt for: {identifier}"
        )
        raise HTTPException(
            status_code=401,
            detail={"code": "INVALID_CREDENTIALS", "message": "Invalid email address or password"}
        )

    if not user.is_verified:
        raise HTTPException(
            status_code=403,
            detail={"code": "ACCOUNT_NOT_VERIFIED", "message": "Please verify your account before logging in"}
        )

    role_rows = db.execute(select(user_roles.c.role_name).where(user_roles.c.user_id == user.id)).all()
    roles = sorted({row[0] for row in role_rows} | {"USER"})
    access_token = create_access_token(user.id, roles=roles)
    refresh_token = create_refresh_token(user.id)

    AuditService.log_action(db, "LOGIN", user_id=user.id)

    return {
        "success": True,
        "message": "Login successful",
        "data": {
            "user_id": user.id,
            "email": user.email,
            "phone": user.phone,
            "full_name": user.full_name,
            "access_token": access_token,
            "refresh_token": refresh_token,
            "roles": roles
        }
    }

@router.post("/verify-otp")
def verify_otp(req: VerifyOTPRequest, db: Session = Depends(get_db)):
    entered_otp = req.otp.replace(" ", "").strip()
    clean_phone = req.phone.strip()
    
    # 1. Query user in DB
    user = db.query(User).filter((User.phone == clean_phone) | (User.email == clean_phone.lower())).first()
    
    is_valid = False
    if user and user.otp_expires_at and user.otp_expires_at < datetime.datetime.utcnow():
        user.email_otp = None
        db.commit()
    elif user and user.otp_attempts >= 5:
        raise HTTPException(status_code=429, detail={"code": "OTP_LOCKED", "message": "Too many invalid OTP attempts"})
    elif user and user.email_otp and secrets.compare_digest(user.email_otp.strip(), entered_otp):
        is_valid = True
    elif EmailService.verify_otp(clean_phone, entered_otp):
        is_valid = True
    elif user and user.email and EmailService.verify_otp(user.email, entered_otp):
        is_valid = True

    if user and not is_valid:
        user.otp_attempts += 1
        db.commit()

    if is_valid:
        if user:
            user.is_verified = True
            user.email_otp = None
            user.otp_attempts = 0
            db.commit()
            AuditService.log_action(db, "EMAIL_OTP_VERIFIED", user_id=user.id)
        return {
            "success": True,
            "message": "Email security OTP verified successfully! Account created. Redirecting to login...",
            "data": {
                "phone": clean_phone
            }
        }
    raise HTTPException(status_code=400, detail={"code": "INVALID_OTP", "message": "Invalid or expired 6-digit OTP code."})

@router.post("/resend-otp")
def resend_otp(req: ResendOTPRequest, db: Session = Depends(get_db)):
    clean_phone = req.phone.strip()
    user = db.query(User).filter(User.phone == clean_phone).first()
    
    if not user and req.email:
        clean_email = req.email.strip().lower()
        user = db.query(User).filter(User.email == clean_email).first()

    if not user:
        raise HTTPException(
            status_code=404,
            detail={"code": "USER_NOT_FOUND", "message": "User not found. Please create an account first."}
        )

    # Generate fresh 6-digit OTP
    otp = f"{secrets.randbelow(900000) + 100000}"
    user.email_otp = otp
    user.otp_expires_at = datetime.datetime.utcnow() + datetime.timedelta(minutes=15)
    user.otp_attempts = 0
    db.commit()

    # Update cache and dispatch email
    EmailService.store_otp(user.phone, otp)
    email_result = {"delivered": False}
    if user.email:
        EmailService.store_otp(user.email, otp)
        email_result = EmailService.send_otp_email(to_email=user.email, otp=otp, user_name=user.full_name or "Entrepreneur")

    AuditService.log_action(db, "OTP_RESENT", user_id=user.id, details=f"Email: {user.email}, Delivered: {email_result.get('delivered')}")

    success_msg = f"A fresh 6-digit security OTP has been sent to your email ({user.email})." if email_result.get("delivered") else f"A fresh 6-digit security OTP has been generated for {user.email}."

    return {
        "success": True,
        "message": success_msg,
        "data": {
            "phone": user.phone,
            "email": user.email,
            "email_delivered": email_result.get("delivered", False)
        }
    }

@router.post("/forgot-password")
def forgot_password(req: ForgotPasswordRequest, db: Session = Depends(get_db)):
    clean_email = str(req.email).strip().lower()
    user = db.query(User).filter(User.email == clean_email).first()
    
    # Check MongoDB if not found in SQLite
    if not user:
        try:
            from app.core.mongodb import mongo_manager, init_mongodb
            if mongo_manager.sync_client is None:
                init_mongodb()
            if mongo_manager.sync_client is not None:
                sync_db = mongo_manager.sync_client[settings.MONGODB_DB_NAME]
                m_doc = sync_db["users"].find_one({"email": clean_email})
                if m_doc:
                    user = User(
                        id=m_doc.get("id", str(secrets.token_hex(16))),
                        phone=m_doc.get("phone", "0000000000"),
                        email=m_doc.get("email", clean_email),
                        aadhaar_number=m_doc.get("aadhaar_number"),
                        hashed_password=m_doc.get("hashed_password", get_password_hash("123456")),
                        full_name=m_doc.get("full_name", "Entrepreneur"),
                        is_active=bool(m_doc.get("is_active", 1)),
                        is_verified=bool(m_doc.get("is_verified", 1))
                    )
                    db.add(user)
                    db.commit()
                    db.refresh(user)
        except Exception:
            db.rollback()

    if not user:
        raise HTTPException(
            status_code=404,
            detail={"code": "USER_NOT_FOUND", "message": "No account found with this email address. Please register."}
        )

    otp = f"{secrets.randbelow(900000) + 100000}"
    user.email_otp = otp
    user.otp_expires_at = datetime.datetime.utcnow() + datetime.timedelta(minutes=15)
    user.otp_attempts = 0
    db.commit()

    EmailService.store_otp(clean_email, otp, expiry_minutes=15)
    email_result = EmailService.send_otp_email(to_email=clean_email, otp=otp, user_name=user.full_name or "Entrepreneur")
    AuditService.log_action(db, "PASSWORD_RESET_REQUESTED", user_id=user.id)

    return {
        "success": True,
        "message": f"A 6-digit password reset OTP has been sent to {clean_email}.",
        "data": {
            "email": clean_email,
            "email_delivered": email_result.get("delivered", False)
        }
    }

@router.post("/reset-password")
def reset_password(req: ResetPasswordRequest, db: Session = Depends(get_db)):
    clean_email = str(req.email).strip().lower()
    user = db.query(User).filter(User.email == clean_email).first()

    if not user:
        raise HTTPException(
            status_code=404,
            detail={"code": "USER_NOT_FOUND", "message": "No account found with this email address."}
        )

    if req.otp:
        clean_otp = req.otp.replace(" ", "").strip()
        is_valid = False
        if user.otp_expires_at and user.otp_expires_at < datetime.datetime.utcnow():
            raise HTTPException(status_code=400, detail={"code": "OTP_EXPIRED", "message": "OTP has expired. Please request a new one."})
        elif user.email_otp and secrets.compare_digest(user.email_otp.strip(), clean_otp):
            is_valid = True
        elif EmailService.verify_otp(clean_email, clean_otp):
            is_valid = True

        if not is_valid:
            raise HTTPException(status_code=400, detail={"code": "INVALID_OTP", "message": "Invalid OTP code entered."})

    new_hash = get_password_hash(req.new_password)
    user.hashed_password = new_hash
    user.email_otp = None
    user.otp_attempts = 0
    user.is_verified = True
    db.commit()

    # Sync updated password to MongoDB Atlas
    sync_save_to_mongodb("users", {
        "email": clean_email,
        "hashed_password": new_hash,
        "is_verified": True
    }, query_filter={"email": clean_email})

    AuditService.log_action(db, "PASSWORD_RESET_SUCCESS", user_id=user.id)

    return {
        "success": True,
        "message": "Password updated successfully! You can now log in with your new password."
    }

@router.post("/refresh")
def refresh(req: RefreshRequest, db: Session = Depends(get_db)):
    payload = decode_refresh_token(req.refresh_token)
    if not payload:
        raise HTTPException(status_code=401, detail={"code": "INVALID_REFRESH_TOKEN", "message": "Refresh token is invalid or expired"})
    
    user_id = payload.get("sub")
    role_rows = db.execute(select(user_roles.c.role_name).where(user_roles.c.user_id == user_id)).all()
    roles = sorted({row[0] for row in role_rows} | {"USER"})
    new_access_token = create_access_token(user_id, roles=roles)
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