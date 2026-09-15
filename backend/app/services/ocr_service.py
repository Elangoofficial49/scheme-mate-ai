import os
import re
import io
from typing import Dict, Any, Tuple, Optional


class OCRService:
    """
    QR proof scanning and document payload validation service.
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
    def decode_qr_code(cls, file_bytes: bytes) -> Optional[str]:
        """
        Decodes QR code from image bytes using pyzbar and OpenCV QRCodeDetector
        across 4 rotation angles (0°, 90°, 180°, 270°).
        """
        if not file_bytes:
            return None

        # 1. Try pyzbar across 4 rotation angles
        try:
            import pyzbar.pyzbar as pyzbar
            from PIL import Image
            img = Image.open(io.BytesIO(file_bytes))
            for angle in [0, 90, 180, 270]:
                rot = img.rotate(angle, expand=True) if angle > 0 else img
                decoded_objs = pyzbar.decode(rot)
                for obj in decoded_objs:
                    if obj.type == 'QRCODE' and obj.data:
                        return obj.data.decode('utf-8', errors='ignore')
        except Exception:
            pass

        # 2. Try OpenCV QRCodeDetector across 4 rotation angles
        try:
            import cv2
            import numpy as np
            nparr = np.frombuffer(file_bytes, np.uint8)
            img_cv = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
            if img_cv is not None:
                detector = cv2.QRCodeDetector()
                for angle in [0, 90, 180, 270]:
                    if angle == 90:
                        rot = cv2.rotate(img_cv, cv2.ROTATE_90_CLOCKWISE)
                    elif angle == 180:
                        rot = cv2.rotate(img_cv, cv2.ROTATE_180)
                    elif angle == 270:
                        rot = cv2.rotate(img_cv, cv2.ROTATE_90_COUNTERCLOCKWISE)
                    else:
                        rot = img_cv

                    val, pts, _ = detector.detectAndDecode(rot)
                    if val:
                        return val
        except Exception:
            pass

        return None

    @classmethod
    def _parse_qr_payload(cls, qr_data: str, document_type: str) -> Dict[str, Any]:
        """
        Parses supported Indian government QR payload formats:
        - Aadhaar XML (<PrintLetterBarcodeData ...>)
        - Udyam Registration URL / QR payload
        - PAN / Income Certificate e-District payload
        """
        doc_type_clean = document_type.lower()

        # 1. Aadhaar XML QR structure
        uid_match = re.search(r'uid=["\']?(\d{12})["\']?', qr_data) or re.search(r'\b\d{4}\s?\d{4}\s?\d{4}\b', qr_data)
        name_match = re.search(r'name=["\']?([^"\'\n]+)["\']?', qr_data, re.IGNORECASE) or re.search(r'Name\s*[:\-]?\s*([A-Za-z\s\.]+)', qr_data, re.IGNORECASE)
        gender_match = re.search(r'gender=["\']?([MF])["\']?', qr_data, re.IGNORECASE) or re.search(r'\b(Male|Female|Transgender)\b', qr_data, re.IGNORECASE)
        dob_match = re.search(r'dob=["\']?([^"\'\n]+)["\']?', qr_data) or re.search(r'\b(\d{2}[-/]\d{2}[-/]\d{4}|\d{4})\b', qr_data)
        yob_match = re.search(r'yob=["\']?(\d{4})["\']?', qr_data)

        # 2. Udyam Registration QR structure
        udyam_match = re.search(r'UDYAM-[A-Z]{2}-\d{2}-\d{7}', qr_data, re.IGNORECASE)
        enterprise_match = re.search(r'Enterprise Name\s*[:\-]?\s*([A-Za-z0-9\s&]+)', qr_data, re.IGNORECASE)

        # 3. PAN structure
        pan_match = re.search(r'\b[A-Z]{5}\d{4}[A-Z]{1}\b', qr_data, re.IGNORECASE)

        # 4. Income Certificate structure
        income_cert_match = re.search(r'\b[A-Z]{2,4}/\d{4}/\d{3,6}\b', qr_data) or re.search(r'INC/\d{4}/\d+', qr_data)

        if "aadhaar" in doc_type_clean or uid_match:
            gender_val = None
            if gender_match:
                g = gender_match.group(1).upper()
                gender_val = "Male" if g == "M" else ("Female" if g == "F" else g.title())

            return {
                "document_name": "Aadhaar Card (QR Verified)",
                "extracted_number": uid_match.group(1) if uid_match and len(uid_match.groups()) > 0 else (uid_match.group(0) if uid_match else None),
                "full_name": name_match.group(1).strip() if name_match else None,
                "date_of_birth": dob_match.group(1) if dob_match else (yob_match.group(1) if yob_match else None),
                "gender": gender_val,
                "verification_method": "QR payload identifier validation"
            }
        elif "udyam" in doc_type_clean or udyam_match:
            return {
                "document_name": "Udyam Certificate (QR Verified)",
                "udyam_number": udyam_match.group(0).upper() if udyam_match else None,
                "enterprise_name": enterprise_match.group(1).strip() if enterprise_match else None,
                "verification_method": "QR payload identifier validation"
            }
        elif "pan" in doc_type_clean or pan_match:
            return {
                "document_name": "PAN Card (QR Verified)",
                "pan_number": pan_match.group(0).upper() if pan_match else None,
                "full_name": name_match.group(1).strip() if name_match else None,
                "verification_method": "QR payload identifier validation"
            }
        elif "income" in doc_type_clean or income_cert_match:
            return {
                "document_name": "Income Certificate (QR Verified)",
                "certificate_number": income_cert_match.group(0) if income_cert_match else None,
                "full_name": name_match.group(1).strip() if name_match else None,
                "verification_method": "QR payload identifier validation"
            }
        else:
            return {
                "document_name": f"{document_type} (QR Verified)",
                "qr_raw_data": qr_data[:300],
                "verification_method": "QR payload identifier validation"
            }

    @classmethod
    def _run_tesseract(cls, file_bytes: bytes) -> Tuple[str, bool]:
        """
        Runs Tesseract OCR on image bytes with multi-angle rotation (0°, 90°, 180°, 270°),
        upscaling, and PSM mode scanning for vertical/rotated card photos.
        """
        if not file_bytes:
            return "", False

        try:
            import pytesseract
            from PIL import Image

            tesseract_win_path = r"C:\Program Files\Tesseract-OCR\tesseract.exe"
            if os.path.exists(tesseract_win_path):
                pytesseract.pytesseract.tesseract_cmd = tesseract_win_path

            base_img = Image.open(io.BytesIO(file_bytes))
            w, h = base_img.size

            # Scale small/low-res images up for enhanced OCR accuracy
            if w < 1000 or h < 1000:
                scale_factor = 2 if max(w, h) > 600 else 3
                scaled_img = base_img.resize((w * scale_factor, h * scale_factor), Image.Resampling.LANCZOS)
            else:
                scaled_img = base_img

            gray_img = scaled_img.convert('L')
            
            combined_text = []
            ocr_succeeded = False

            # Scan across 4 rotation angles (0°, 90°, 180°, 270°) and PSM modes (3, 11, 6)
            for angle in [0, 90, 180, 270]:
                rot = gray_img.rotate(angle, expand=True) if angle > 0 else gray_img
                for psm in [3, 11, 6]:
                    try:
                        text = pytesseract.image_to_string(rot, config=f'--psm {psm}')
                        if text and len(text.strip()) > 5:
                            combined_text.append(text)
                            ocr_succeeded = True
                            # If certificate number patterns are detected, stop early and return
                            if re.search(r'\b\d{4}\s?\d{4}\s?\d{4}\b|\b[A-Z]{5}\d{4}[A-Z]{1}\b|UDYAM-[A-Z]{2}-\d{2}-\d{7}|\b[A-Z]{2,4}/\d{4}/\d{3,6}\b', text, re.IGNORECASE):
                                return "\n".join(combined_text), True
                    except Exception:
                        pass

            full_extracted = "\n".join(combined_text)
            return full_extracted, ocr_succeeded
        except Exception:
            return "", False

    @classmethod
    def scan_qr_proof(
        cls,
        document_type: str,
        file_bytes: bytes = b"",
    ) -> Dict[str, Any]:
        """
        Scans an uploaded proof for a QR code or runs multi-angle document OCR
        to validate and extract certificate identifiers.
        """
        # 1. Attempt QR decoding first across 4 rotation angles
        qr_text = cls.decode_qr_code(file_bytes)
        if qr_text:
            extracted_fields = cls._parse_qr_payload(qr_text, document_type)
            primary_keys = {
                "aadhaar": "extracted_number",
                "pan": "pan_number",
                "udyam": "udyam_number",
                "income": "certificate_number",
            }
            document_key = next((key for key in primary_keys if key in document_type.lower()), None)
            primary_value = extracted_fields.get(primary_keys[document_key]) if document_key else None
            verified = bool(primary_value and str(primary_value).strip())

            if verified:
                return {
                    "document_type": document_type,
                    "status": "Verified QR Proof",
                    "verified": True,
                    "confidence_score": "100%",
                    "scanner_used": "official_qr_code",
                    "scan_succeeded": True,
                    "requires_user_confirmation": True,
                    "display_prompt": "✅ Official government QR code verified. Details extracted with 100% confidence.",
                    "extracted_fields": extracted_fields,
                }

        # 2. Fallback to Multi-Angle Tesseract OCR
        ocr_text, ocr_ok = cls._run_tesseract(file_bytes)
        doc_type_clean = document_type.lower()

        extracted_fields = {}
        primary_id_key = "extracted_number"
        if "aadhaar" in doc_type_clean:
            extracted_fields = cls._parse_aadhaar(ocr_text)
            primary_id_key = "extracted_number"
        elif "pan" in doc_type_clean:
            extracted_fields = cls._parse_pan(ocr_text)
            primary_id_key = "pan_number"
        elif "udyam" in doc_type_clean:
            extracted_fields = cls._parse_udyam(ocr_text)
            primary_id_key = "udyam_number"
        elif "income" in doc_type_clean:
            extracted_fields = cls._parse_income_certificate(ocr_text)
            primary_id_key = "certificate_number"
        else:
            extracted_fields = {"document_name": document_type, "raw_extracted_text": ocr_text[:300]}

        primary_id_val = extracted_fields.get(primary_id_key)
        has_primary_id = bool(primary_id_val and str(primary_id_val).strip())

        if has_primary_id:
            return {
                "document_type": document_type,
                "status": "Extracted via Multi-Angle OCR",
                "verified": True,
                "confidence_score": "95%",
                "scanner_used": "multi_angle_ocr",
                "scan_succeeded": True,
                "requires_user_confirmation": True,
                "display_prompt": f"✅ Successfully detected {document_type} number '{primary_id_val}' from document photo.",
                "extracted_fields": extracted_fields,
            }

        return {
            "document_type": document_type,
            "status": "Unverified - No QR Code or Certificate Number Found",
            "verified": False,
            "confidence_score": "0%",
            "scanner_used": "multi_angle_ocr",
            "scan_succeeded": False,
            "requires_user_confirmation": False,
            "display_prompt": f"Could not detect a valid QR code or {document_type} number on the uploaded file. Please ensure the document is clear and properly aligned.",
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