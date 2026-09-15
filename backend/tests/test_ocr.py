from app.services.ocr_service import OCRService

def test_file_validation_safety():
    # Valid image file
    valid, msg = OCRService.validate_uploaded_file("aadhaar.jpg", b"\xFF\xD8\xFF\xE0 sample image bytes", "image/jpeg")
    assert valid is True

    # Executable file rejection
    invalid_exe, msg_exe = OCRService.validate_uploaded_file("malicious.exe", b"MZ\x90\x00\x03\x00\x00\x00", "application/x-msdownload")
    assert invalid_exe is False
    assert "Unsupported file extension" in msg_exe or "Executable" in msg_exe

def test_ocr_aadhaar_extraction():
    res = OCRService.process_document_ocr("Aadhaar Card", "Name: Kavitha R, Aadhaar No: 3489 1204 9871")
    assert "Extracted" in res["status"]
    assert res["requires_user_confirmation"] is True
    assert res["extracted_fields"]["full_name"] == "Kavitha R"

def test_qr_code_payload_parsing():
    qr_payload = '<PrintLetterBarcodeData uid="987654321098" name="Senthil Kumar" gender="M" dob="15/08/1985"/>'
    res = OCRService._parse_qr_payload(qr_payload, "Aadhaar Card")
    assert res["extracted_number"] == "987654321098"
    assert res["full_name"] == "Senthil Kumar"
    assert res["gender"] == "Male"
    assert res["verification_method"] == "Official Cryptographic QR Code"

