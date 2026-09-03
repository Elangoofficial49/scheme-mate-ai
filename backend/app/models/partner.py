import datetime
from sqlalchemy import Column, Integer, String, Float, Boolean, DateTime
from app.core.database import Base

class ChannelPartner(Base):
    __tablename__ = "channel_partners"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False, index=True)
    partner_type = Column(String, nullable=False)  # SCA, Bank, RRB, NBFC-MFI
    branch_name = Column(String, nullable=False)
    state = Column(String, nullable=False, index=True)
    district = Column(String, nullable=False, index=True)
    pincode = Column(String, nullable=True)
    latitude = Column(Float, nullable=False)
    longitude = Column(Float, nullable=False)
    npa_rate = Column(Float, default=1.5)  # NPA Percentage
    fund_utilization_eligible = Column(Boolean, default=True)  # True if low overdue & active quota
    max_loan_cap = Column(Float, default=5000000.0)  # Max loan limit in Rs
    contact_phone = Column(String, nullable=True)
    contact_email = Column(String, nullable=True)
    address = Column(String, nullable=True)
    created_at = Column(DateTime, default=datetime.datetime.utcnow)
