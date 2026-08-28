import uuid
import datetime
from sqlalchemy import Column, String, Integer, DateTime, Text
from app.core.database import Base

class Scheme(Base):
    __tablename__ = "schemes"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    scheme_name = Column(String, index=True, nullable=False)
    ministry = Column(String, nullable=False)
    department = Column(String, nullable=True)
    description = Column(Text, nullable=True)
    scheme_type = Column(String, nullable=True)
    target_beneficiary = Column(Text, nullable=True)
    benefits = Column(Text, nullable=True)
    application_method = Column(String, nullable=True)
    official_application_url = Column(String, nullable=False)
    official_source_url = Column(String, nullable=False)
    state = Column(String, default="All India")
    status = Column(String, default="Active")
    version = Column(Integer, default=1)
    last_verified = Column(String, default=datetime.datetime.utcnow().strftime("%Y-%m-%d"))
    
    # Serialized JSON strings for deterministic rules & document lists
    eligibility_rules = Column(Text, nullable=True)   # JSON string
    required_documents = Column(Text, nullable=True)  # JSON string
    
    created_at = Column(DateTime, default=datetime.datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.datetime.utcnow, onupdate=datetime.datetime.utcnow)

class SchemeVersion(Base):
    __tablename__ = "scheme_versions"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    scheme_id = Column(String, nullable=False)
    version = Column(Integer, nullable=False)
    scheme_name = Column(String, nullable=False)
    eligibility_rules = Column(Text, nullable=True)
    benefits = Column(Text, nullable=True)
    required_documents = Column(Text, nullable=True)
    source_url = Column(String, nullable=False)
    verified_by = Column(String, nullable=True)
    verified_at = Column(DateTime, default=datetime.datetime.utcnow)
    status = Column(String, default="Published")
