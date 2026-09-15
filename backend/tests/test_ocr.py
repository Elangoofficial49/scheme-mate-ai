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
