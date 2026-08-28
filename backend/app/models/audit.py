import uuid
import datetime
from sqlalchemy import Column, String, DateTime, Text
from app.core.database import Base

class AuditLog(Base):
    __tablename__ = "audit_logs"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = Column(String, nullable=True)
    action = Column(String, index=True, nullable=False) # e.g., LOGIN, SCHEME_SEARCH, RULE_UPDATED
    resource = Column(String, nullable=True)
    details = Column(Text, nullable=True)
    ip_address = Column(String, nullable=True)
    created_at = Column(DateTime, default=datetime.datetime.utcnow)

class SecurityEvent(Base):
    __tablename__ = "security_events"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    event_type = Column(String, index=True, nullable=False) # FAILED_LOGIN, PROMPT_INJECTION, RATE_LIMIT_EXCEEDED
    severity = Column(String, default="MEDIUM") # LOW, MEDIUM, HIGH, CRITICAL
    description = Column(Text, nullable=False)
    ip_address = Column(String, nullable=True)
    user_id = Column(String, nullable=True)
    created_at = Column(DateTime, default=datetime.datetime.utcnow)
