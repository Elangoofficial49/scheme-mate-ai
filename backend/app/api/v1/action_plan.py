from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.models.scheme import Scheme
from app.security.rbac import get_current_user_token

router = APIRouter(prefix="/action-plan", tags=["Action Plan Generator"])

@router.get("/{scheme_id}")
def generate_action_plan(scheme_id: str, payload: dict = Depends(get_current_user_token), db: Session = Depends(get_db)):
    scheme = db.query(Scheme).filter(Scheme.id == scheme_id).first()
    if not scheme:
        raise HTTPException(status_code=404, detail={"code": "NOT_FOUND", "message": "Scheme not found"})

    steps = [
        {
            "step_number": 1,
            "title": "Check Eligibility Criteria",
            "description": f"Verify that your business aligns with {scheme.scheme_name} rules.",
            "status": "Completed"
        },
        {
            "step_number": 2,
            "title": "Prepare Mandatory Document Checklist",
            "description": "Scan and upload Aadhaar, PAN, and Udyam Registration through SchemeMate OCR assistant.",
            "status": "In Progress"
        },
        {
            "step_number": 3,
            "title": "Complete Missing Requirements",
            "description": "Obtain Udyam Registration or Category Certificate if currently unverified.",
            "status": "Pending"
        },
        {
            "step_number": 4,
            "title": "Open Official Government Portal",
            "description": f"Navigate safely to official verified application portal at: {scheme.official_application_url}",
            "status": "Pending",
            "official_url": scheme.official_application_url
        },
        {
            "step_number": 5,
            "title": "Submit Application & Track Status",
            "description": "Submit application form on official portal and log reference ID in SchemeMate for reminders.",
            "status": "Pending"
        }
    ]

    return {
        "success": True,
        "data": {
            "scheme_id": scheme.id,
            "scheme_name": scheme.scheme_name,
            "ministry": scheme.ministry,
            "last_verified": scheme.last_verified,
            "official_application_url": scheme.official_application_url,
            "steps": steps
        }
    }
