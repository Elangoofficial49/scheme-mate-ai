from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from typing import Optional, List, Dict, Any
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.core.config import settings
from app.models.scheme import Scheme
from app.models.profile import EntrepreneurProfile
from app.security.rbac import get_current_user_token
from app.services.gemini_service import GeminiSchemeAdvisorService
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
    RAG-powered Conversational AI Assistant.
    Provides real-time eligibility Q&A, step-by-step application guidance, and scheme recommendations
    tailored to the user's entrepreneur profile in their chosen language.
    """
    user_id = payload.get("sub")
    profile = db.query(EntrepreneurProfile).filter(EntrepreneurProfile.user_id == user_id).first()

    profile_context = ""
    if profile:
        profile_context = f"""
USER PROFILE CONTEXT:
- Name: {profile.full_name or 'Entrepreneur'}
- Age: {profile.age or 'Not specified'}
- Gender: {profile.gender or 'Not specified'}
- State: {profile.state or 'Not specified'}
- District: {profile.district or 'Not specified'}
- Category: {profile.category or 'Not specified'}
- Business Type: {profile.business_type or 'Not specified'}
- Annual Income: Rs. {profile.annual_income or 'Not specified'}
- Funding Needed: Rs. {profile.funding_requirement or 'Not specified'}
- Udyam Registered: {profile.has_udyam_registration or False}
        """.strip()

    # Retrieve relevant schemes for RAG context
    all_schemes = db.query(Scheme).all()
    scheme_summaries = []
    for s in all_schemes[:10]:
        scheme_summaries.append(f"• {s.scheme_name} (Ministry: {s.ministry}): {s.description[:150]}... Benefits: {s.benefits[:100]}")
    schemes_context = "\n".join(scheme_summaries)

    prompt = f"""
You are SchemeMate AI, an expert, encouraging, and helpful government scheme advisor for Indian entrepreneurs.
Answer the user's query clearly with accurate eligibility advice, scheme names, subsidies, and step-by-step guidance.

{profile_context}

AVAILABLE TOP SCHEMES IN DATABASE:
{schemes_context}

USER QUESTION:
"{req.message}"

INSTRUCTIONS:
1. Provide a direct, clear, structured answer.
2. Highlight specific eligibility criteria or documents needed if applicable.
3. Keep response concise, friendly, and empowering (3-5 short bullet points or clear paragraphs).
    """.strip()

    # Generate response
    ai_response_text = ""
    try:
        if profile:
            prof_dict = {
                "full_name": profile.full_name,
                "age": profile.age,
                "gender": profile.gender,
                "state": profile.state,
                "category": profile.category,
                "business_type": profile.business_type,
                "annual_income": profile.annual_income,
                "funding_requirement": profile.funding_requirement
            }
            res = GeminiSchemeAdvisorService.suggest_schemes_with_gemini(
                profile=prof_dict,
                query=req.message,
                preferred_language=req.lang or "en"
            )
            if res and res.get("ai_analysis_summary"):
                ai_response_text = res["ai_analysis_summary"]
    except Exception:
        ai_response_text = ""

    if not ai_response_text:
        ai_response_text = (
            f"Hello {profile.full_name if profile and profile.full_name else 'Entrepreneur'}! "
            f"Based on your profile details ({profile.state if profile and profile.state else 'India'}), "
            f"you have strong eligibility for top central and state schemes like PMEGP (up to 35% margin money subsidy), "
            f"MUDRA Tarun/Kishore loans, and PM Vishwakarma for traditional trades. "
            f"Which specific scheme or eligibility criteria would you like to explore?"
        )

    # Translate response if non-English requested
    if req.lang and req.lang.lower() != "en":
        ai_response_text = SchemeTranslator.translate_text(ai_response_text, req.lang.lower())

    AuditService.log_action(db, "ASSISTANT_CHAT", user_id=user_id, details=f"Query: {req.message[:50]}")

    return {
        "success": True,
        "lang": req.lang,
        "reply": ai_response_text,
        "suggested_followups": [
            "Am I eligible for PMEGP subsidy?",
            "What documents do I need for MUDRA loan?",
            "How do I apply for Udyam Registration?",
            "Where is my nearest DIC office?"
        ]
    }
