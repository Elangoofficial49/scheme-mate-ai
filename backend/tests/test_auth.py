import pytest
from app.core.security import get_password_hash, verify_password, create_access_token, decode_access_token

def test_password_hashing():
    pwd = "SecurePassword123!"
    hashed = get_password_hash(pwd)
    assert hashed != pwd
    assert verify_password(pwd, hashed) is True
    assert verify_password("WrongPassword", hashed) is False

def test_jwt_access_token():
    user_id = "test-uuid-1234"
    token = create_access_token(user_id, roles=["USER", "ADMIN"])
    payload = decode_access_token(token)
    assert payload is not None
    assert payload.get("sub") == user_id
    assert "ADMIN" in payload.get("roles", [])
    assert payload.get("type") == "access"
