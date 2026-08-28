import uuid
import datetime
from sqlalchemy import Column, String, Integer, Float, Boolean, DateTime, ForeignKey, Text
from sqlalchemy.orm import relationship
from app.core.database import Base

class EntrepreneurProfile(Base):
    __tablename__ = "entrepreneur_profiles"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = Column(String, ForeignKey("users.id", ondelete="CASCADE"), unique=True, nullable=False)
    
    full_name = Column(String, nullable=True)
    age = Column(Integer, nullable=True)
    gender = Column(String, nullable=True)
    state = Column(String, nullable=True)
    district = Column(String, nullable=True)
    urban_rural = Column(String, nullable=True)  # "Urban", "Rural"
    category = Column(String, nullable=True)     # "General", "OBC", "SC", "ST", "Minority"
    disability_status = Column(String, nullable=True)
    
    occupation = Column(String, nullable=True)
    business_type = Column(String, nullable=True)   # "Manufacturing", "Service", "Trading", "Agro"
    business_stage = Column(String, nullable=True)  # "Idea", "New Enterprise", "Existing"
    annual_income = Column(Float, nullable=True)
    investment_requirement = Column(Float, nullable=True)
    funding_requirement = Column(Float, nullable=True)
    business_registration_status = Column(String, nullable=True) # "Registered", "Unregistered"
    has_udyam_registration = Column(Boolean, default=False)
    education_level = Column(String, nullable=True) # "Illiterate", "8th Pass", "10th Pass", "12th Pass", "Degree/Diploma"
    
    created_at = Column(DateTime, default=datetime.datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.datetime.utcnow, onupdate=datetime.datetime.utcnow)

    user = relationship("User", back_populates="profile")
