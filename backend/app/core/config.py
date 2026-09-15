import os
from typing import List, Optional, Union
from pydantic import field_validator
from pydantic_settings import BaseSettings
from dotenv import load_dotenv

# Explicitly load .env from backend and project root
load_dotenv()
load_dotenv(os.path.join(os.path.dirname(__file__), "../../../.env"))
load_dotenv(os.path.join(os.path.dirname(__file__), "../../.env"))

class Settings(BaseSettings):
    PROJECT_NAME: str = "SchemeMate AI"
    VERSION: str = "1.0.0"
    API_V1_STR: str = "/api/v1"
    
    # Environment
    ENVIRONMENT: str = "development"
    DEBUG: Union[bool, str] = False

    @field_validator("DEBUG", mode="before")
    @classmethod
    def parse_debug(cls, v):
        if isinstance(v, bool):
            return v
        if isinstance(v, str):
            if v.lower() in ("true", "1", "yes", "on"):
                return True
            if v.lower() in ("false", "0", "no", "off"):
                return False
        return True
    
    # Security
    JWT_SECRET: str = ""
    JWT_REFRESH_SECRET: str = ""
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60
    REFRESH_TOKEN_EXPIRE_DAYS: int = 7
    
    # Database (PostgreSQL with fallback to SQLite for local standalone test)
    DATABASE_URL: str = "sqlite:///./schememate.db"
    
    # MongoDB Connection (Local or MongoDB Atlas cluster)
    MONGODB_URL: Optional[str] = "mongodb://localhost:27017"
    MONGODB_DB_NAME: str = "schememate_ai"
    
    # Redis
    REDIS_URL: str = "redis://localhost:6379/0"
    
    # AI Providers
    AI_PROVIDER: str = "gemini"  # "gemini", "openai", "local"
    AI_API_KEY: Optional[str] = None
    GEMINI_API_KEY: Optional[str] = None
    GEMINI_MODEL: str = "gemini-3.6-flash"
    EMBEDDING_MODEL: str = "all-MiniLM-L6-v2"

    @property
    def effective_gemini_api_key(self) -> Optional[str]:
        return (
            self.GEMINI_API_KEY or
            self.AI_API_KEY or
            os.getenv("GEMINI_API_KEY") or
            os.getenv("GOOGLE_API_KEY") or
            os.getenv("AI_API_KEY")
        )
    
    # OCR Provider
    OCR_PROVIDER: str = "local_regex"  # "tesseract", "paddleocr", "local_regex"
    UPLOAD_DIR: str = "uploads"
    MAX_UPLOAD_SIZE_BYTES: int = 5 * 1024 * 1024
    
    # Email / SMTP Service
    SMTP_HOST: Optional[str] = "smtp.gmail.com"
    SMTP_PORT: int = 587
    SMTP_USER: Optional[str] = None
    SMTP_PASSWORD: Optional[str] = None
    SMTP_FROM_EMAIL: str = "noreply.schememate@gmail.com"
    SMTP_USE_TLS: bool = True
    
    # CORS
    BACKEND_CORS_ORIGINS: List[str] = [
        "http://localhost:3000",
        "http://localhost:8000",
        "http://127.0.0.1:3000",
        "http://127.0.0.1:8000",
    ]

    class Config:
        env_file = ".env"
        extra = "allow"

settings = Settings()

if settings.ENVIRONMENT.lower() in {"production", "staging"}:
    if len(settings.JWT_SECRET) < 32 or len(settings.JWT_REFRESH_SECRET) < 32:
        raise RuntimeError("JWT_SECRET and JWT_REFRESH_SECRET must be at least 32 characters in non-development environments")
    if settings.DEBUG:
        raise RuntimeError("DEBUG must be disabled in non-development environments")
