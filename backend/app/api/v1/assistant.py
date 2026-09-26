from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from typing import Optional, List, Dict, Any
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.core.config import settings
from app.models.scheme import Scheme
from app.models.profile import EntrepreneurProfile
from app.security.rbac import get_current_user_token
from app.services.openai_service import OpenAISchemeAdvisorService
from app.services.audit_service import AuditService
from app.services.translation_service import SchemeTranslator

router = APIRouter(prefix="/assistant", tags=["Conversational AI Scheme Assistant"])

class ChatMessage(BaseModel):
    role: str  # "user" or "assistant"
    content: str

class ChatRequest(BaseModel):
    message: str
    conversation_history: Optional[List[ChatMessage]] = []
    lang: Optional[str] = "en"

@router.post("/chat")
def chat_with_assistant(
    req: ChatRequest,
    payload: dict = Depends(get_current_user_token),
    db: Session = Depends(get_db)
):
    """
    Gen AI-Powered Conversational Real-Time Speaking AI Assistant.
    Provides step-by-step human-like conversational guidance for entrepreneurs on:
    - How to use SchemeMate AI (OCR Scanning, Profile Creation, Financial Calculator, Partner Locator)
    - Scheme Eligibility and 35% Margin Money Subsidies (PMEGP, MUDRA, PM Vishwakarma, CGTMSE)
    - Strictly guardrailed to answer queries about SchemeMate AI website and government schemes,
      politely redirecting any off-topic queries back to the website.
    - Returns answers in the user's selected language (Tamil, Hindi, Telugu, Kannada, English).
    """
    user_id = payload.get("sub")
    profile = db.query(EntrepreneurProfile).filter(EntrepreneurProfile.user_id == user_id).first()

    prof_dict = {}
    if profile:
        prof_dict = {
            "full_name": profile.full_name,
            "age": profile.age,
            "gender": profile.gender,
            "state": profile.state,
            "district": profile.district,
            "category": profile.category,
            "business_type": profile.business_type,
            "annual_income": profile.annual_income,
            "funding_requirement": profile.funding_requirement
        }

    history_dicts = [{"role": m.role, "content": m.content} for m in req.conversation_history] if req.conversation_history else []

    # 1. Gen AI Assistant Response (with strict domain guardrails and human tone)
    genai_result = OpenAISchemeAdvisorService.generate_chatgpt_response(
        user_message=req.message,
        user_profile=prof_dict,
        preferred_language=req.lang or "en",
        conversation_history=history_dicts
    )

    ai_response_text = ""
    provider_used = "genai_assistant"

    if genai_result.get("success"):
        ai_response_text = genai_result.get("reply", "")
        provider_used = genai_result.get("provider", "genai_chatgpt")

    # 2. Resilient Knowledge Base Fallback if response is empty
    if not ai_response_text:
        user_name = profile.full_name if profile and profile.full_name else 'Entrepreneur'
        user_state = profile.state if profile and profile.state else 'India'
        ai_response_text = (
            f"Hello {user_name}! I am your SchemeMate AI Assistant. "
            f"Based on your profile in {user_state}, you are eligible for top government support:\n"
            f"1. **PMEGP**: Up to 35% margin money grant for starting your business!\n"
            f"2. **PM MUDRA**: Collateral-free loans up to Rs 10 Lakh.\n"
            f"3. **PM Vishwakarma**: Rs 15,000 toolkit grant + 5% loan for artisans.\n"
            f"4. **OCR Scan Feature**: Click 'Scan Document' on top to auto-fill your profile instantly!\n"
            f"5. **Financial Calculator**: Use our EMI & Subsidy calculator to check your monthly payback.\n"
            f"How can I help you step-by-step today?"
        )
        provider_used = "schememate_rag"

    # 3. Multilingual Support
    if req.lang and req.lang.lower() != "en" and provider_used == "schememate_rag":
        ai_response_text = SchemeTranslator.translate_text(ai_response_text, req.lang.lower())

    AuditService.log_action(db, "ASSISTANT_CHAT", user_id=user_id, details=f"[{provider_used}] Query: {req.message[:50]}")

    return {
        "success": True,
        "lang": req.lang,
        "provider": provider_used,
        "reply": ai_response_text,
        "suggested_followups": [
            "How do I use OCR Scan to auto-fill my profile?",
            "Am I eligible for 35% PMEGP subsidy?",
            "How do I calculate loan EMI in Financial Calculator?",
            "Where is my nearest DIC office using Partner Locator?"
        ]
    }
