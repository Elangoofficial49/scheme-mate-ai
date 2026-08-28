from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.security.rbac import get_current_user_token

router = APIRouter(prefix="/notifications", tags=["Notifications"])

@router.get("")
def get_notifications(payload: dict = Depends(get_current_user_token)):
    notifications = [
        {
            "id": "notif-001",
            "title": "PM Vishwakarma Scheme Update",
            "body": "Verification deadline extended for micro-artisan toolkits in your state.",
            "category": "Scheme Update",
            "created_at": "2026-08-27T10:00:00Z",
            "is_read": False
        },
        {
            "id": "notif-002",
            "title": "Document Checklist Reminder",
            "body": "Upload Udyam Registration Certificate to boost profile readiness for MUDRA Loan.",
            "category": "Reminder",
            "created_at": "2026-08-26T14:30:00Z",
            "is_read": True
        }
    ]
    return {"success": True, "count": len(notifications), "data": notifications}
