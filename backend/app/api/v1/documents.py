from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, Form
from pydantic import BaseModel
from typing import Optional, Dict, Any
from sqlalchemy.orm import Session
import json
import os
import uuid
from app.core.database import get_db
from app.core.config import settings
from app.models.document import Document, DocumentExtraction
from app.services.ocr_service import OCRService
from app.security.rbac import get_current_user_token
from app.services.audit_service import AuditService

router = APIRouter(prefix="/documents", tags=["Document Intelligence & OCR"])

class ConfirmExtractionRequest(BaseModel):
    document_id: str
    confirmed_data: Dict[str, Any]

@router.post("/upload")
async def upload_document(
    file: UploadFile = File(...),
    document_type: str = Form("Aadhaar"),
    payload: dict = Depends(get_current_user_token),
    db: Session = Depends(get_db)
):
    user_id = payload.get("sub")
    contents = await file.read()
    
    # 1. File security validation
    is_valid, err_msg = OCRService.validate_uploaded_file(file.filename, contents, file.content_type)
    if not is_valid:
        AuditService.log_security_event(db, "SUSPICIOUS_FILE_UPLOAD", severity="HIGH", description=err_msg, user_id=user_id)
        raise HTTPException(status_code=400, detail={"code": "INVALID_FILE", "message": err_msg})

    # Save file safely to storage folder
    storage_dir = os.path.abspath(settings.UPLOAD_DIR)
    os.makedirs(storage_dir, exist_ok=True)
    file_id = str(uuid.uuid4())
    safe_filename = f"{file_id}_{os.path.basename(file.filename)}"
    file_path = os.path.join(storage_dir, safe_filename)
    
    with open(file_path, "wb") as f:
        f.write(contents)

    doc = Document(
        id=file_id,
        user_id=user_id,
        document_type=document_type,
        file_name=file.filename,
        file_path=file_path,
        file_size=f"{len(contents)/1024:.1f} KB",
        mime_type=file.content_type
    )
    db.add(doc)
    db.commit()

    # 2. Scan the proof QR code and verify its payload
    ocr_result = OCRService.scan_qr_proof(document_type, contents)

    extraction = DocumentExtraction(
        document_id=doc.id,
        extracted_text="",
        extracted_data_json=json.dumps(ocr_result["extracted_fields"], ensure_ascii=True),
        confidence_score=ocr_result["confidence_score"]
    )
    db.add(extraction)
    db.commit()

    AuditService.log_action(db, "DOCUMENT_UPLOAD", user_id=user_id, resource=doc.id, details=f"Type: {document_type}")

    return {
        "success": True,
        "message": "Document uploaded and processed successfully. Please review and confirm the detected details.",
        "data": {
            "document_id": doc.id,
            "document_type": document_type,
            "file_name": file.filename,
            "ocr_result": ocr_result
        }
    }

@router.delete("/{document_id}")
def delete_document(
    document_id: str,
    payload: dict = Depends(get_current_user_token),
    db: Session = Depends(get_db)
):
    user_id = payload.get("sub")
    doc = db.query(Document).filter(Document.id == document_id, Document.user_id == user_id).first()
    if not doc:
        raise HTTPException(status_code=404, detail={"code": "NOT_FOUND", "message": "Document record not found"})

    if doc.file_path and os.path.isfile(doc.file_path):
        os.remove(doc.file_path)
    db.delete(doc)
    db.commit()
    AuditService.log_action(db, "DOCUMENT_DELETE", user_id=user_id, resource=document_id)
    return {"success": True, "message": "Document deleted successfully"}

@router.post("/confirm")
def confirm_extraction(req: ConfirmExtractionRequest, payload: dict = Depends(get_current_user_token), db: Session = Depends(get_db)):
    user_id = payload.get("sub")
    doc = db.query(Document).filter(Document.id == req.document_id, Document.user_id == user_id).first()
    if not doc:
        raise HTTPException(status_code=404, detail={"code": "NOT_FOUND", "message": "Document record not found"})

    doc.is_verified = True
    extraction = db.query(DocumentExtraction).filter(DocumentExtraction.document_id == doc.id).first()
    if extraction:
        extraction.user_confirmed = True
        extraction.extracted_data_json = str(req.confirmed_data)

    db.commit()
    AuditService.log_action(db, "DOCUMENT_CONFIRM", user_id=user_id, resource=doc.id)

    return {
        "success": True,
        "message": "Document details verified and updated in user profile.",
        "data": req.confirmed_data
    }

class AutoFillProfileRequest(BaseModel):
    document_type: str
    extracted_fields: Dict[str, Any]

@router.post("/auto-fill-profile")
def auto_fill_profile_from_ocr(
    req: AutoFillProfileRequest,
    payload: dict = Depends(get_current_user_token),
    db: Session = Depends(get_db)
):
    """
    Applies OCR-extracted document fields directly to the entrepreneur profile.
    Automatically syncs to SQLite database and MongoDB Atlas.
    """
    from app.models.profile import EntrepreneurProfile
    from app.core.mongodb import sync_save_to_mongodb

    user_id = payload.get("sub")
    profile = db.query(EntrepreneurProfile).filter(EntrepreneurProfile.user_id == user_id).first()
    if not profile:
        profile = EntrepreneurProfile(user_id=user_id)
        db.add(profile)

    fields = req.extracted_fields
    updated_keys = []

    # Aadhaar fields
    if fields.get("full_name"):
        profile.full_name = fields["full_name"]
        updated_keys.append("full_name")
    if fields.get("gender"):
        profile.gender = fields["gender"]
        updated_keys.append("gender")
    if fields.get("state"):
        profile.state = fields["state"]
        updated_keys.append("state")

    # PAN / Certificate fields
    if fields.get("pan_number"):
        profile.certificate_number = fields["pan_number"]
        profile.certificate_type = "PAN"
        profile.certificate_uploaded = True
        updated_keys.append("certificate_number")
    elif fields.get("certificate_number"):
        profile.certificate_number = fields["certificate_number"]
        profile.certificate_uploaded = True
        updated_keys.append("certificate_number")

    # Udyam Registration fields
    if fields.get("udyam_number"):
        profile.has_udyam_registration = True
        profile.certificate_number = fields["udyam_number"]
        profile.certificate_type = "Udyam"
        profile.certificate_uploaded = True
        updated_keys.append("has_udyam_registration")
    if fields.get("enterprise_name"):
        profile.company_name = fields["enterprise_name"]
        updated_keys.append("company_name")
    if fields.get("major_activity"):
        profile.business_type = fields["major_activity"]
        updated_keys.append("business_type")

    # Income Certificate fields
    if fields.get("annual_family_income") is not None:
        try:
            profile.annual_income = float(fields["annual_family_income"])
            updated_keys.append("annual_income")
        except ValueError:
            pass

    db.commit()
    db.refresh(profile)

    # Sync profile to MongoDB Atlas automatically
    sync_save_to_mongodb("entrepreneur_profiles", {
        "id": profile.id,
        "user_id": profile.user_id,
        "full_name": profile.full_name,
        "age": profile.age,
        "gender": profile.gender,
        "state": profile.state,
        "district": profile.district,
        "category": profile.category,
        "company_name": profile.company_name,
        "business_type": profile.business_type,
        "annual_income": profile.annual_income,
        "certificate_type": profile.certificate_type,
        "certificate_number": profile.certificate_number,
        "has_udyam_registration": profile.has_udyam_registration
    }, query_filter={"user_id": profile.user_id})

    AuditService.log_action(db, "PROFILE_AUTOFILL_OCR", user_id=user_id, details=f"Document: {req.document_type}, Updated: {', '.join(updated_keys)}")

    return {
        "success": True,
        "message": f"Successfully auto-filled {len(updated_keys)} profile fields from your {req.document_type}!",
        "updated_fields": updated_keys,
        "data": {
            "full_name": profile.full_name,
            "company_name": profile.company_name,
            "business_type": profile.business_type,
            "annual_income": profile.annual_income,
            "has_udyam_registration": profile.has_udyam_registration,
            "certificate_number": profile.certificate_number
        }
    }
