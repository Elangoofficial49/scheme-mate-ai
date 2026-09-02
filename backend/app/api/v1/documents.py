from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, Form
from pydantic import BaseModel
from typing import Optional, Dict, Any
from sqlalchemy.orm import Session
import os, uuid
from app.core.database import get_db
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
    storage_dir = os.path.join(os.path.dirname(__file__), "../../../uploads")
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

    # 2. Run OCR extraction
    text_content = ""
    try:
        text_content = contents.decode("utf-8", errors="ignore")
    except Exception:
        text_content = ""
        
    ocr_result = OCRService.process_document_ocr(document_type, text_content, contents)

    extraction = DocumentExtraction(
        document_id=doc.id,
        extracted_text=text_content[:500],
        extracted_data_json=str(ocr_result["extracted_fields"]),
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
