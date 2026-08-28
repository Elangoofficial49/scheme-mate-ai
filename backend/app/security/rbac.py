from typing import List
from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from app.core.security import decode_access_token

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/v1/auth/login")

def get_current_user_token(token: str = Depends(oauth2_scheme)) -> dict:
    payload = decode_access_token(token)
    if not payload:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail={"code": "INVALID_TOKEN", "message": "Access token is invalid or expired"},
            headers={"WWW-Authenticate": "Bearer"},
        )
    return payload

def require_roles(required_roles: List[str]):
    def role_checker(token_payload: dict = Depends(get_current_user_token)):
        user_roles = token_payload.get("roles", [])
        has_permission = any(role in user_roles for role in required_roles)
        if not has_permission:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail={"code": "FORBIDDEN", "message": f"Access denied. Requires one of roles: {required_roles}"}
            )
        return token_payload
    return role_checker
