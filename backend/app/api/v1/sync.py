from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from typing import Dict, Any, List, Optional
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.models.profile import EntrepreneurProfile
from app.security.rbac import get_current_user_token
from app.services.audit_service import AuditService

router = APIRouter(prefix="/sync", tags=["Offline Data Synchronization"])

class SyncPayload(BaseModel):
    offline_profile: Optional[Dict[str, Any]] = None
    saved_scheme_ids: Optional[List[str]] = None
    last_sync_timestamp: Optional[str] = None

@router.post("/offline")
def sync_offline_data(req: SyncPayload, payload: dict = Depends(get_current_user_token), db: Session = Depends(get_db)):
    user_id = payload.get("sub")
    
    # 1. Sync offline profile edits
    if req.offline_profile:
        profile = db.query(EntrepreneurProfile).filter(EntrepreneurProfile.user_id == user_id).first()
        if not profile:
            profile = EntrepreneurProfile(user_id=user_id)
            db.add(profile)
        for key, val in req.offline_profile.items():
            if hasattr(profile, key) and val is not None:
                setattr(profile, key, val)
        db.commit()

    AuditService.log_action(db, "OFFLINE_DATA_SYNC", user_id=user_id)

    return {
        "success": True,
        "message": "Offline data synchronized safely with backend server.",
        "server_timestamp": "2026-08-28T13:30:00Z"
    }
