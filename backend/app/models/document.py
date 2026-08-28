import uuid
import datetime
from sqlalchemy import Column, String, DateTime, ForeignKey, Text, Boolean
from sqlalchemy.orm import relationship
from app.core.database import Base

class Document(Base):
    __tablename__ = "documents"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = Column(String, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    
    document_type = Column(String, nullable=False) # "Aadhaar", "PAN", "Udyam", "Income", "BankPassbook"
    file_name = Column(String, nullable=False)
    file_path = Column(String, nullable=False)
    file_size = Column(String, nullable=True)
    mime_type = Column(String, nullable=True)
    
    is_verified = Column(Boolean, default=False)
    created_at = Column(DateTime, default=datetime.datetime.utcnow)

    user = relationship("User", back_populates="documents")
    extractions = relationship("DocumentExtraction", back_populates="document", cascade="all, delete-orphan")

class DocumentExtraction(Base):
    __tablename__ = "document_extractions"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    document_id = Column(String, ForeignKey("documents.id", ondelete="CASCADE"), nullable=False)
    
    extracted_text = Column(Text, nullable=True)
    extracted_data_json = Column(Text, nullable=True) # JSON string of extracted key-values
    confidence_score = Column(String, default="High")
    user_confirmed = Column(Boolean, default=False)
    created_at = Column(DateTime, default=datetime.datetime.utcnow)

    document = relationship("Document", back_populates="extractions")
