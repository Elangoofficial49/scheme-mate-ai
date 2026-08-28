from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from typing import Optional, Dict, Any, List
from sqlalchemy.orm import Session
import json, datetime
from app.core.database import get_db
from app.models.scheme import Scheme, SchemeVersion
from app.models.audit import AuditLog, SecurityEvent
from app.security.rbac import require_roles
from app.services.audit_service import AuditService

router = APIRouter(prefix="/admin", tags=["Admin Portal"])

class SchemeCreateUpdateRequest(BaseModel):
    scheme_name: str
    ministry: str
    department: Optional[str] = None
    description: str
    scheme_type: str
    target_beneficiary: str
    benefits: str
    application_method: str
    official_application_url: str
    official_source_url: str
    state: str = "All India"
    eligibility_rules: Optional[Dict[str, Any]] = None
    required_documents: Optional[List[Dict[str, Any]]] = None

@router.get("/schemes", dependencies=[Depends(require_roles(["ADMIN"]))])
def admin_list_schemes(db: Session = Depends(get_db)):
    schemes = db.query(Scheme).all()
    return {"success": True, "count": len(schemes), "data": schemes}

@router.post("/schemes", dependencies=[Depends(require_roles(["ADMIN"]))])
def create_scheme(req: SchemeCreateUpdateRequest, token: dict = Depends(require_roles(["ADMIN"])), db: Session = Depends(get_db)):
    admin_id = token.get("sub")
    new_scheme = Scheme(
        scheme_name=req.scheme_name,
        ministry=req.ministry,
        department=req.department,
        description=req.description,
        scheme_type=req.scheme_type,
        target_beneficiary=req.target_beneficiary,
        benefits=req.benefits,
        application_method=req.application_method,
        official_application_url=req.official_application_url,
        official_source_url=req.official_source_url,
        state=req.state,
        status="Draft",
        eligibility_rules=json.dumps(req.eligibility_rules) if req.eligibility_rules else "{}",
        required_documents=json.dumps(req.required_documents) if req.required_documents else "[]"
    )
    db.add(new_scheme)
    db.commit()
    db.refresh(new_scheme)

    AuditService.log_action(db, "ADMIN_SCHEME_CREATED", user_id=admin_id, resource=new_scheme.id)

    return {"success": True, "message": "Scheme created in Draft status", "data": new_scheme}

@router.post("/schemes/{scheme_id}/publish", dependencies=[Depends(require_roles(["ADMIN"]))])
def publish_scheme(scheme_id: str, token: dict = Depends(require_roles(["ADMIN"])), db: Session = Depends(get_db)):
    admin_id = token.get("sub")
    scheme = db.query(Scheme).filter(Scheme.id == scheme_id).first()
    if not scheme:
        raise HTTPException(status_code=404, detail={"code": "NOT_FOUND", "message": "Scheme not found"})

    scheme.status = "Active"
    scheme.version += 1
    scheme.last_verified = datetime.datetime.utcnow().strftime("%Y-%m-%d")

    # Record version
    ver = SchemeVersion(
        scheme_id=scheme.id,
        version=scheme.version,
        scheme_name=scheme.scheme_name,
        eligibility_rules=scheme.eligibility_rules,
        benefits=scheme.benefits,
        required_documents=scheme.required_documents,
        source_url=scheme.official_source_url,
        verified_by=admin_id,
        status="Published"
    )
    db.add(ver)
    db.commit()

    AuditService.log_action(db, "ADMIN_SCHEME_PUBLISHED", user_id=admin_id, resource=scheme.id)

    return {"success": True, "message": f"Scheme published as Version {scheme.version}", "data": scheme}

@router.get("/audit-logs", dependencies=[Depends(require_roles(["ADMIN"]))])
def get_audit_logs(db: Session = Depends(get_db)):
    logs = db.query(AuditLog).order_by(AuditLog.created_at.desc()).limit(100).all()
    return {"success": True, "count": len(logs), "data": logs}

@router.get("/security-events", dependencies=[Depends(require_roles(["ADMIN"]))])
def get_security_events(db: Session = Depends(get_db)):
    events = db.query(SecurityEvent).order_by(SecurityEvent.created_at.desc()).limit(100).all()
    return {"success": True, "count": len(events), "data": events}
