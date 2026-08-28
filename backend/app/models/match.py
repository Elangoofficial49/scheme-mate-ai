import uuid
import datetime
from sqlalchemy import Column, String, Float, DateTime, ForeignKey, Text
from sqlalchemy.orm import relationship
from app.core.database import Base

class UserSchemeMatch(Base):
    __tablename__ = "user_scheme_matches"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = Column(String, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    scheme_id = Column(String, ForeignKey("schemes.id", ondelete="CASCADE"), nullable=False)
    
    match_score = Column(Float, nullable=False) # 0.0 to 100.0
    eligibility_status = Column(String, nullable=False) # "Eligible", "Potentially Eligible", "Ineligible"
    
    explanation_json = Column(Text, nullable=True) # Serialized JSON string of matching details
    missing_requirements_json = Column(Text, nullable=True)
    
    created_at = Column(DateTime, default=datetime.datetime.utcnow)

    user = relationship("User", back_populates="matches")
    scheme = relationship("Scheme")

class SavedScheme(Base):
    __tablename__ = "saved_schemes"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = Column(String, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    scheme_id = Column(String, ForeignKey("schemes.id", ondelete="CASCADE"), nullable=False)
    created_at = Column(DateTime, default=datetime.datetime.utcnow)

    user = relationship("User", back_populates="saved_schemes")
    scheme = relationship("Scheme")
