from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from typing import Optional, List
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.models.profile import EntrepreneurProfile
from app.models.scheme import Scheme
from app.services.matching_engine import AIMatchingEngine
from app.services.rag_engine import RAGEngine
from app.security.rbac import get_current_user_token
from app.services.audit_service import AuditService

router = APIRouter(prefix="/matching", tags=["AI Scheme Matching"])

class RAGQueryRequest(BaseModel):
    query: str

@router.post("/analyze")
def analyze_scheme_matching(payload: dict = Depends(get_current_user_token), db: Session = Depends(get_db)):
    user_id = payload.get("sub")
    profile_orm = db.query(EntrepreneurProfile).filter(EntrepreneurProfile.user_id == user_id).first()
    
    profile_dict = {}
    if profile_orm:
        profile_dict = {
            "full_name": profile_orm.full_name,
            "age": profile_orm.age,
            "gender": profile_orm.gender,
            "state": profile_orm.state,
            "district": profile_orm.district,
            "urban_rural": profile_orm.urban_rural,
            "category": profile_orm.category,
            "disability_status": profile_orm.disability_status,
            "occupation": profile_orm.occupation,
            "business_type": profile_orm.business_type,
            "business_stage": profile_orm.business_stage,
            "annual_income": profile_orm.annual_income,
            "funding_requirement": profile_orm.funding_requirement,
            "education_level": profile_orm.education_level
        }

    schemes_orm = db.query(Scheme).filter(Scheme.status == "Active").all()
    results = []
    for s in schemes_orm:
        s_dict = {
            "id": s.id,
            "scheme_name": s.scheme_name,
            "ministry": s.ministry,
            "description": s.description,
            "target_beneficiary": s.target_beneficiary,
            "benefits": s.benefits,
            "state": s.state,
            "official_application_url": s.official_application_url,
            "official_source_url": s.official_source_url,
            "last_verified": s.last_verified,
            "eligibility_rules": s.eligibility_rules,
            "required_documents": s.required_documents
        }
        res = AIMatchingEngine.analyze_scheme_match(profile_dict, s_dict)
        results.append(res)

    results.sort(key=lambda x: x["match_score"], reverse=True)

    AuditService.log_action(db, "SCHEME_MATCHING_ANALYZE", user_id=user_id, details=f"Analyzed {len(schemes_orm)} schemes")

    return {
        "success": True,
        "disclaimer": "Recommendations are based on currently available profile data. Final eligibility is determined by official authorities.",
        "total_analyzed": len(results),
        "data": results
    }

@router.post("/rag-assistant")
def query_rag_assistant(req: RAGQueryRequest, payload: dict = Depends(get_current_user_token), db: Session = Depends(get_db)):
    user_id = payload.get("sub")
    schemes_orm = db.query(Scheme).filter(Scheme.status == "Active").all()
    kb = [{
        "scheme_name": s.scheme_name,
        "ministry": s.ministry,
        "description": s.description,
        "target_beneficiary": s.target_beneficiary,
        "benefits": s.benefits,
        "state": s.state,
        "official_application_url": s.official_application_url,
        "official_source_url": s.official_source_url,
        "last_verified": s.last_verified
    } for s in schemes_orm]

    result = RAGEngine.answer_user_query(req.query, {}, kb)
    AuditService.log_action(db, "RAG_QUERY", user_id=user_id, details=req.query[:100])
    return {"success": True, "data": result}
