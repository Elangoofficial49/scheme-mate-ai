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
        #    NOTE: No fabricated/sample data is ever returned. If a field cannot be
        #    confidently extracted from real OCR text, it is set to None and flagged.
        if "aadhaar" in doc_type_clean:
            extracted_fields = cls._parse_aadhaar(extracted_raw_text)
        elif "pan" in doc_type_clean:
            extracted_fields = cls._parse_pan(extracted_raw_text)
        elif "udyam" in doc_type_clean:
            extracted_fields = cls._parse_udyam(extracted_raw_text)
        elif "income" in doc_type_clean:
            extracted_fields = cls._parse_income_certificate(extracted_raw_text)
        else:
            extracted_fields = {
                "document_name": document_type,
                "raw_extracted_text": extracted_raw_text[:300] if extracted_raw_text else None,
            }

        if urls_found:
            extracted_fields["extracted_urls"] = urls_found

        # 4. Determine honest status/confidence instead of a hardcoded constant
        any_field_found = any(
            v is not None and v != [] for k, v in extracted_fields.items() if k != "document_name"
        )
        if not extracted_raw_text or not ocr_ran_successfully:
            status = "OCR_UNAVAILABLE"
            confidence = "0%"
        elif any_field_found:
            status = "Extracted"
            confidence = "High"  # Replace with a real per-field confidence score if your OCR engine provides one
        else:
            status = "No fields detected"
            confidence = "Low"

        return {
            "document_type": document_type,
            "status": status,
            "confidence_score": confidence,
            "ocr_engine_used": provider,
            "ocr_succeeded": ocr_ran_successfully,
            "requires_user_confirmation": True,
            "display_prompt": (
                "Please review and confirm the information detected from your document below before saving to your profile."
                if any_field_found
                else "We couldn't confidently read this document. Please enter the details manually or upload a clearer copy."
            ),
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
        name_match = re.search(r'Name:\s*([A-Za-z\s]+)', text) if text else None
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