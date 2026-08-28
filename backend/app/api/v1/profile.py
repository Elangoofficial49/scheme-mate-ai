from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from typing import Optional
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.models.profile import EntrepreneurProfile
from app.security.rbac import get_current_user_token
from app.services.audit_service import AuditService

router = APIRouter(prefix="/profile", tags=["Entrepreneur Profile"])

class ProfileUpdateRequest(BaseModel):
    full_name: Optional[str] = None
    age: Optional[int] = None
    gender: Optional[str] = None
    state: Optional[str] = None
    district: Optional[str] = None
    urban_rural: Optional[str] = None
    category: Optional[str] = None
    disability_status: Optional[str] = None
    company_name: Optional[str] = None
    business_description: Optional[str] = None
    source_of_income: Optional[str] = None
    certificate_uploaded: Optional[bool] = None
    certificate_type: Optional[str] = None
    occupation: Optional[str] = None
    business_type: Optional[str] = None
    business_stage: Optional[str] = None
    annual_income: Optional[float] = None
    investment_requirement: Optional[float] = None
    funding_requirement: Optional[float] = None
    business_registration_status: Optional[str] = None
    has_udyam_registration: Optional[bool] = None
    education_level: Optional[str] = None

class ConversationalOnboardRequest(BaseModel):
    user_message: str

@router.get("")
def get_profile(payload: dict = Depends(get_current_user_token), db: Session = Depends(get_db)):
    user_id = payload.get("sub")
    profile = db.query(EntrepreneurProfile).filter(EntrepreneurProfile.user_id == user_id).first()
    if not profile:
        # Create empty default profile
        profile = EntrepreneurProfile(user_id=user_id)
        db.add(profile)
        db.commit()
        db.refresh(profile)
        
    return {
        "success": True,
        "data": {
            "id": profile.id,
            "user_id": profile.user_id,
            "full_name": profile.full_name,
            "age": profile.age,
            "gender": profile.gender,
            "state": profile.state,
            "district": profile.district,
            "urban_rural": profile.urban_rural,
            "category": profile.category,
            "disability_status": profile.disability_status,
            "company_name": profile.company_name,
            "business_description": profile.business_description,
            "source_of_income": profile.source_of_income,
            "certificate_uploaded": profile.certificate_uploaded or False,
            "certificate_type": profile.certificate_type,
            "occupation": profile.occupation,
            "business_type": profile.business_type,
            "business_stage": profile.business_stage,
            "annual_income": profile.annual_income,
            "investment_requirement": profile.investment_requirement,
            "funding_requirement": profile.funding_requirement,
            "business_registration_status": profile.business_registration_status,
            "has_udyam_registration": profile.has_udyam_registration,
            "education_level": profile.education_level
        }
    }

@router.put("")
def update_profile(req: ProfileUpdateRequest, payload: dict = Depends(get_current_user_token), db: Session = Depends(get_db)):
    user_id = payload.get("sub")
    profile = db.query(EntrepreneurProfile).filter(EntrepreneurProfile.user_id == user_id).first()
    if not profile:
        profile = EntrepreneurProfile(user_id=user_id)
        db.add(profile)
        
    for key, value in req.model_dump(exclude_unset=True).items():
        setattr(profile, key, value)
        
    db.commit()
    db.refresh(profile)

    AuditService.log_action(db, "PROFILE_UPDATE", user_id=user_id)

    return {
        "success": True,
        "message": "Profile updated successfully",
        "data": profile
    }

@router.post("/onboard-dialogue")
def conversational_onboarding(req: ConversationalOnboardRequest, payload: dict = Depends(get_current_user_token), db: Session = Depends(get_db)):
    """
    AI-assisted conversational profile extraction dialogue.
    Converts unstructured natural language into profile attributes and suggests the next question.
    """
    user_id = payload.get("sub")
    text = req.user_message.lower()
    
    profile = db.query(EntrepreneurProfile).filter(EntrepreneurProfile.user_id == user_id).first()
    if not profile:
        profile = EntrepreneurProfile(user_id=user_id)
        db.add(profile)

    extracted_attributes = {}
    
    if "tailor" in text or "stitching" in text or "garment" in text:
        profile.business_type = "Textile & Tailoring"
        extracted_attributes["business_type"] = "Textile & Tailoring"
    elif "shop" in text or "store" in text or "retail" in text:
        profile.business_type = "Retail Trading"
        extracted_attributes["business_type"] = "Retail Trading"
    elif "food" in text or "bakery" in text or "pickle" in text:
        profile.business_type = "Food Processing"
        extracted_attributes["business_type"] = "Food Processing"
    elif "farm" in text or "agri" in text or "dairy" in text:
        profile.business_type = "Agro Allied"
        extracted_attributes["business_type"] = "Agro Allied"
        
    if "tamil nadu" in text or "tn" in text:
        profile.state = "Tamil Nadu"
        extracted_attributes["state"] = "Tamil Nadu"
    elif "bihar" in text:
        profile.state = "Bihar"
        extracted_attributes["state"] = "Bihar"
    elif "up" in text or "uttar pradesh" in text:
        profile.state = "Uttar Pradesh"
        extracted_attributes["state"] = "Uttar Pradesh"

    db.commit()

    # Determine next missing attribute to ask
    next_question = "What is your location/state and estimated annual family income?"
    if not profile.business_type:
        next_question = "What kind of business or enterprise are you running or planning to start?"
    elif not profile.funding_requirement:
        next_question = "How much financial support or loan requirement do you need for your business?"

    return {
        "success": True,
        "data": {
            "extracted_attributes": extracted_attributes,
            "ai_response": f"Got it! I updated your profile with {list(extracted_attributes.keys())}.",
            "next_question": next_question
        }
    }
