from unittest.mock import patch
from fastapi.testclient import TestClient
from app.main import app
from app.core.database import init_db

init_db()
client = TestClient(app)

def test_root_endpoint():
    response = client.get("/")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "online"
    assert data["system"] == "SchemeMate AI"

def test_health_endpoint():
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json()["status"] == "healthy"

def test_schemes_list_endpoint():
    response = client.get("/api/v1/schemes")
    assert response.status_code == 200
    data = response.json()
    assert data["success"] is True
    assert data["count"] > 0
    assert len(data["data"]) >= 5

def test_auth_email_register_and_login_flow():
    # 1. Register with email
    test_email = "testuser_email_auth@example.com"
    test_phone = "9870001122"
    test_password = "SecurePassword123!"

    # Force a deterministic OTP so we don't have to guess the random one.
    # auth.py generates it as: f"{secrets.randbelow(900000) + 100000}"
    # randbelow(900000) returning 23456 -> otp = "123456"
    with patch("app.api.v1.auth.secrets.randbelow", return_value=23456):
        reg_res = client.post("/api/v1/auth/register", json={
            "full_name": "Test User",
            "email": test_email,
            "phone": test_phone,
            "password": test_password
        })
    assert reg_res.status_code == 200
    assert reg_res.json()["success"] is True

    # 2. Verify OTP — now matches the OTP forced above
    verify_res = client.post("/api/v1/auth/verify-otp", json={
        "phone": test_phone,
        "otp": "123456"
    })
    assert verify_res.status_code == 200
    assert verify_res.json()["success"] is True

    # 3. Login with registered email & correct password
    login_res = client.post("/api/v1/auth/login", json={
        "email": test_email,
        "password": test_password
    })
    assert login_res.status_code == 200
    login_data = login_res.json()
    assert login_data["success"] is True
    assert login_data["data"]["email"] == test_email
    assert "access_token" in login_data["data"]

    # 4. Login with wrong password should fail
    wrong_pwd_res = client.post("/api/v1/auth/login", json={
        "email": test_email,
        "password": "WrongPassword!"
    })
    assert wrong_pwd_res.status_code == 401

    # 5. Login with non-existent email should fail
    wrong_email_res = client.post("/api/v1/auth/login", json={
        "email": "nonexistent_email_123@example.com",
        "password": test_password
    })
    assert wrong_email_res.status_code == 401