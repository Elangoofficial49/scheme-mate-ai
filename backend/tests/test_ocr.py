from io import BytesIO

import pytesseract
from PIL import Image

from app.services.ocr_service import OCRService

def test_file_validation_safety():
    # Valid image file
    valid, msg = OCRService.validate_uploaded_file("aadhaar.jpg", b"\xFF\xD8\xFF\xE0 sample image bytes", "image/jpeg")
    assert valid is True

    # Executable file rejection
    invalid_exe, msg_exe = OCRService.validate_uploaded_file("malicious.exe", b"MZ\x90\x00\x03\x00\x00\x00", "application/x-msdownload")
    assert invalid_exe is False
    assert "Unsupported file extension" in msg_exe or "Executable" in msg_exe

def test_qr_proof_is_verified(monkeypatch):
    monkeypatch.setattr(
        OCRService,
        "decode_qr_code",
        lambda file_bytes: '<PrintLetterBarcodeData uid="348912049871" name="Kavitha R" />',
    )

    res = OCRService.scan_qr_proof("Aadhaar Card", b"qr image bytes")

    assert res["status"] == "Verified QR Proof"
    assert res["verified"] is True
    assert res["scanner_used"] in ("qr_code", "official_qr_code")
    assert res["extracted_fields"]["full_name"] == "Kavitha R"


def test_qr_proof_without_identifier_is_unverified(monkeypatch):
    monkeypatch.setattr(OCRService, "decode_qr_code", lambda file_bytes: "not a certificate proof")

    res = OCRService.scan_qr_proof("Aadhaar Card", b"qr image bytes")

    assert "Unverified" in res["status"]
    assert res["verified"] is False
    assert res["requires_user_confirmation"] is False


def test_aadhaar_ocr_normalizes_common_separators_and_digit_confusions():
    res = OCRService._parse_aadhaar(
        "Aadhaar Number: l234-\n56S8 / 9O12"
    )

    assert res["extracted_number"] == "123456589012"


def test_aadhaar_ocr_does_not_accept_masked_or_virtual_id():
    assert OCRService._parse_aadhaar(
        "Masked Aadhaar: XXXX XXXX 9012"
    )["extracted_number"] is None
    assert OCRService._parse_aadhaar(
        "VID: 1234 5678 9012 3456"
    )["extracted_number"] is None


def test_aadhaar_scan_extracts_number_from_ocr_text(monkeypatch):
    monkeypatch.setattr(OCRService, "decode_qr_code", lambda file_bytes: None)
    monkeypatch.setattr(
        OCRService,
        "_run_tesseract",
        lambda file_bytes: ("Aadhaar Number: 1234 5678 9012", True),
    )

    res = OCRService.scan_qr_proof("Aadhaar Card", b"image bytes")

    assert res["scan_succeeded"] is True
    assert res["extracted_fields"]["extracted_number"] == "123456789012"


def test_tesseract_uses_number_only_pass_when_general_ocr_misses(monkeypatch):
    image = Image.new("RGB", (100, 60), "white")
    image_bytes = BytesIO()
    image.save(image_bytes, format="PNG")
    configs = []

    def fake_image_to_string(image, config):
        configs.append(config)
        if "tessedit_char_whitelist" in config:
            return "1234 5678 9012"
        return ""

    monkeypatch.setattr(pytesseract, "image_to_string", fake_image_to_string)

    text, succeeded = OCRService._run_tesseract(image_bytes.getvalue())

    assert succeeded is True
    assert OCRService._extract_aadhaar_number(text) == "123456789012"
    assert any("tessedit_char_whitelist" in config for config in configs)
