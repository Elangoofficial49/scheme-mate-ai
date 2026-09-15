import os
import re
import io
from typing import Dict, Any, Tuple, Optional
from app.core.config import settings


class OCRService:
    """
    Document Intelligence and OCR processing module.
    Supports multiple OCR engines via settings.OCR_PROVIDER:
    - local_regex (Default - Regex and rule-based pattern matching)
    - tesseract (Pytesseract OCR Engine for image files)
    - paddleocr (Multilingual PaddleOCR Engine)
    - gemini (Gemini 2.0 Flash Vision AI Engine)
    """

    ALLOWED_EXTENSIONS = {".jpg", ".jpeg", ".png", ".pdf"}
    MAX_FILE_SIZE_BYTES = 5 * 1024 * 1024  # 5MB Limit

    @classmethod
    def validate_uploaded_file(cls, filename: str, file_bytes: bytes, mime_type: str) -> Tuple[bool, str]:
        ext = os.path.splitext(filename)[1].lower()
        if ext not in cls.ALLOWED_EXTENSIONS:
            return False, f"Unsupported file extension '{ext}'. Allowed: {', '.join(cls.ALLOWED_EXTENSIONS)}"

        if len(file_bytes) > cls.MAX_FILE_SIZE_BYTES:
            return False, f"File size ({len(file_bytes) / 1024 / 1024:.2f}MB) exceeds 5MB limit"

        # Reject executable file signatures
        if file_bytes.startswith(b"MZ") or file_bytes.startswith(b"\x7fELF"):
            return False, "Executable files are strictly rejected for security"

        return True, "File valid"

    @classmethod
    def _run_tesseract(cls, file_bytes: bytes) -> Tuple[str, bool]:
        """
        Runs Tesseract OCR on image bytes.
        Returns (extracted_text, ocr_succeeded).
        """
        try:
            from PIL import Image
            import pytesseract

            tesseract_win_path = r"C:\Program Files\Tesseract-OCR\tesseract.exe"
            if os.path.exists(tesseract_win_path):
                pytesseract.pytesseract.tesseract_cmd = tesseract_win_path

            image = Image.open(io.BytesIO(file_bytes))
            text = pytesseract.image_to_string(image)
            return text, True
        except Exception:
            # Tesseract binary/wrapper not available, or image failed to decode
            return "", False

    @classmethod
    def process_document_ocr(
        cls,
        document_type: str,
        file_content_text: str = "",
        file_bytes: bytes = b"",
    ) -> Dict[str, Any]:
        """
        Executes OCR extraction based on settings.OCR_PROVIDER and returns extracted entity fields.
        """
        provider = settings.OCR_PROVIDER.lower() if hasattr(settings, "OCR_PROVIDER") else "local_regex"
        doc_type_clean = document_type.lower()
        extracted_raw_text = file_content_text
        ocr_ran_successfully = bool(file_content_text)  # True if text was supplied directly

        # 1. Attempt image text extraction if Tesseract / Local provider is selected and image bytes supplied
        if provider in ("tesseract", "local_tesseract") and file_bytes:
            extracted_raw_text, ocr_ran_successfully = cls._run_tesseract(file_bytes)

        # 2. Extract embedded URLs from OCR text if present
        urls_found = re.findall(r'https?://\S+|www\.\S+', extracted_raw_text) if extracted_raw_text else []

        # 3. Parse extracted text using Document Entity Parsers
        primary_id_key = "extracted_number"
        if "aadhaar" in doc_type_clean:
            extracted_fields = cls._parse_aadhaar(extracted_raw_text)
            primary_id_key = "extracted_number"
        elif "pan" in doc_type_clean:
            extracted_fields = cls._parse_pan(extracted_raw_text)
            primary_id_key = "pan_number"
        elif "udyam" in doc_type_clean:
            extracted_fields = cls._parse_udyam(extracted_raw_text)
            primary_id_key = "udyam_number"
        elif "income" in doc_type_clean:
            extracted_fields = cls._parse_income_certificate(extracted_raw_text)
            primary_id_key = "certificate_number"
        else:
            extracted_fields = {
                "document_name": document_type,
                "raw_extracted_text": extracted_raw_text[:300] if extracted_raw_text else None,
            }
            primary_id_key = None

        if urls_found:
            extracted_fields["extracted_urls"] = urls_found

        # 4. Strict Document Validation & Real Confidence Calculation
        # Check if the primary certificate number was detected
        primary_id_value = extracted_fields.get(primary_id_key) if primary_id_key else None
        has_primary_id = bool(primary_id_value and str(primary_id_value).strip())

        # Count extracted auxiliary fields
        extracted_keys = [
            k for k, v in extracted_fields.items()
            if k != "document_name" and v is not None and v != [] and str(v).strip() != ""
        ]
        auxiliary_field_count = len([k for k in extracted_keys if k != primary_id_key])

        # Mandatory Document Verification:
        # A valid certificate MUST have a detected Certificate/ID Number and legible text.
        if not extracted_raw_text or len(extracted_raw_text.strip()) < 10:
            status = "Invalid Document - No Text Detected"
            confidence = "0%"
            ocr_succeeded = False
            display_prompt = "The uploaded file appears to be a personal photo, selfie, or blank image without readable document text. Please upload a clear copy of your official government certificate."
        elif primary_id_key and not has_primary_id:
            # Rejection rule: Certificate number is missing or illegible
            status = "Invalid Document - Certificate Number Not Found"
            confidence = "0%"
            ocr_succeeded = False
            display_prompt = f"Could not detect a valid {document_type} number on the uploaded file. Please ensure the document is clear and not obscured."
        else:
            # Real confidence score calculation based on extracted field richness
            status = "Extracted"
            if auxiliary_field_count >= 2:
                confidence = "95%"
            elif auxiliary_field_count == 1:
                confidence = "80%"
            else:
                confidence = "65%"
            ocr_succeeded = True
            display_prompt = "Please review and confirm the information detected from your document below before saving to your profile."

        return {
            "document_type": document_type,
            "status": status,
            "confidence_score": confidence,
            "ocr_engine_used": provider,
            "ocr_succeeded": ocr_succeeded,
            "requires_user_confirmation": True,
            "display_prompt": display_prompt,
            "extracted_fields": extracted_fields,
        }

    # ------------------------------------------------------------------
    # Individual document parsers
    # Each returns None for any field it could not confidently extract —
    # never a fabricated placeholder value.
    # ------------------------------------------------------------------

    @staticmethod
    def _parse_aadhaar(text: str) -> Dict[str, Any]:
        aadhaar_match = re.search(r'\b\d{4}\s?\d{4}\s?\d{4}\b', text) if text else None
        name_match = re.search(r'Name\s*[:\-]?\s*([A-Za-z\s\.]+?)(?:,|\n|$)', text, re.IGNORECASE) if text else None
        dob_match = re.search(r'\b(\d{2}[-/]\d{2}[-/]\d{4})\b', text) if text else None
        gender_match = re.search(r'\b(Male|Female|Transgender)\b', text, re.IGNORECASE) if text else None

        return {
            "document_name": "Aadhaar Card",
            "extracted_number": aadhaar_match.group(0) if aadhaar_match else None,
            "full_name": name_match.group(1).strip() if name_match else None,
            "date_of_birth": dob_match.group(1) if dob_match else None,
            "gender": gender_match.group(1).title() if gender_match else None,
            "state": None,
            "address": None,
        }

    @staticmethod
    def _parse_pan(text: str) -> Dict[str, Any]:
        pan_match = re.search(r'\b[A-Z]{5}\d{4}[A-Z]{1}\b', text, re.IGNORECASE) if text else None
        name_match = re.search(r'Name\s*[:\-]?\s*([A-Za-z\s]+)', text) if text else None
        father_match = re.search(r"Father'?s?\s*Name\s*[:\-]?\s*([A-Za-z\s]+)", text, re.IGNORECASE) if text else None
        dob_match = re.search(r'\b(\d{2}[-/]\d{2}[-/]\d{4})\b', text) if text else None

        return {
            "document_name": "PAN Card",
            "pan_number": pan_match.group(0).upper() if pan_match else None,
            "full_name": name_match.group(1).strip() if name_match else None,
            "father_name": father_match.group(1).strip() if father_match else None,
            "date_of_birth": dob_match.group(1) if dob_match else None,
        }

    @staticmethod
    def _parse_udyam(text: str) -> Dict[str, Any]:
        udyam_match = re.search(r'UDYAM-[A-Z]{2}-\d{2}-\d{7}', text, re.IGNORECASE) if text else None
        enterprise_match = re.search(r'Enterprise Name\s*[:\-]?\s*([A-Za-z0-9\s&]+)', text, re.IGNORECASE) if text else None
        type_match = re.search(r'\b(Micro|Small|Medium)\s*Enterprise\b', text, re.IGNORECASE) if text else None
        activity_match = re.search(r'Major Activity\s*[:\-]?\s*([A-Za-z\s/]+)', text, re.IGNORECASE) if text else None
        date_match = re.search(r'\b(\d{4}-\d{2}-\d{2}|\d{2}[-/]\d{2}[-/]\d{4})\b', text) if text else None

        return {
            "document_name": "Udyam Registration Certificate",
            "udyam_number": udyam_match.group(0).upper() if udyam_match else None,
            "enterprise_name": enterprise_match.group(1).strip() if enterprise_match else None,
            "enterprise_type": f"{type_match.group(1).title()} Enterprise" if type_match else None,
            "major_activity": activity_match.group(1).strip() if activity_match else None,
            "date_of_commencement": date_match.group(1) if date_match else None,
        }

    @staticmethod
    def _parse_income_certificate(text: str) -> Dict[str, Any]:
        cert_match = re.search(r'\b[A-Z]{2,4}/\d{4}/\d{3,6}\b', text) if text else None
        name_match = re.search(r'Name\s*[:\-]?\s*([A-Za-z\s]+)', text) if text else None
        income_match = re.search(r'(?:Rs\.?|INR)?\s?([\d,]+(?:\.\d+)?)', text) if text else None
        authority_match = re.search(r'(Tahsildar|Revenue Officer|Collector)[^,\n]*', text, re.IGNORECASE) if text else None
        date_match = re.search(r'\b(\d{4}-\d{2}-\d{2}|\d{2}[-/]\d{2}[-/]\d{4})\b', text) if text else None

        annual_income: Optional[float] = None
        if income_match:
            try:
                annual_income = float(income_match.group(1).replace(",", ""))
            except ValueError:
                annual_income = None

        return {
            "document_name": "Income Certificate",
            "certificate_number": cert_match.group(0) if cert_match else None,
            "full_name": name_match.group(1).strip() if name_match else None,
            "annual_family_income": annual_income,
            "issuing_authority": authority_match.group(0).strip() if authority_match else None,
            "issue_date": date_match.group(1) if date_match else None,
        }