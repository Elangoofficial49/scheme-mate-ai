from fastapi import APIRouter, Depends, HTTPException, Query
from typing import Optional, List
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.models.scheme import Scheme
from app.models.match import SavedScheme
from app.security.rbac import get_current_user_token
from app.services.audit_service import AuditService

router = APIRouter(prefix="/schemes", tags=["Schemes Knowledge Base"])

@router.get("")
def list_schemes(
    search: Optional[str] = None,
    state: Optional[str] = None,
    scheme_type: Optional[str] = None,
    db: Session = Depends(get_db)
):
    query = db.query(Scheme).filter(Scheme.status == "Active")
    if state:
        query = query.filter((Scheme.state == state) | (Scheme.state == "All India"))
    if scheme_type:
        query = query.filter(Scheme.scheme_type.ilike(f"%{scheme_type}%"))
    if search:
        query = query.filter(
            (Scheme.scheme_name.ilike(f"%{search}%")) |
            (Scheme.description.ilike(f"%{search}%")) |
            (Scheme.ministry.ilike(f"%{search}%"))
        )

    schemes = query.all()
    return {
        "success": True,
        "count": len(schemes),
        "data": schemes
    }

@router.get("/{scheme_id}")
def get_scheme_details(scheme_id: str, db: Session = Depends(get_db)):
    scheme = db.query(Scheme).filter(Scheme.id == scheme_id).first()
    if not scheme:
        raise HTTPException(status_code=404, detail={"code": "NOT_FOUND", "message": "Scheme not found"})
    return {"success": True, "data": scheme}

@router.post("/{scheme_id}/save")
def save_scheme(scheme_id: str, payload: dict = Depends(get_current_user_token), db: Session = Depends(get_db)):
    user_id = payload.get("sub")
    scheme = db.query(Scheme).filter(Scheme.id == scheme_id).first()
    if not scheme:
        raise HTTPException(status_code=404, detail={"code": "NOT_FOUND", "message": "Scheme not found"})

    existing = db.query(SavedScheme).filter(SavedScheme.user_id == user_id, SavedScheme.scheme_id == scheme_id).first()
    if not existing:
        saved = SavedScheme(user_id=user_id, scheme_id=scheme_id)
        db.add(saved)
        db.commit()
        AuditService.log_action(db, "SCHEME_SAVE", user_id=user_id, resource=scheme_id)

    return {"success": True, "message": "Scheme saved to bookmarks"}
