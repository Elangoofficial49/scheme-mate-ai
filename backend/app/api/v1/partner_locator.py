import math
from fastapi import APIRouter, Depends, Query, HTTPException
from typing import Optional, List
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.models.partner import ChannelPartner

router = APIRouter(prefix="/partners", tags=["Geo-Spatial Partner Locator & Router"])

# Seed data of verified Channel Partners across India (SCAs, Banks, RRBs, NBFC-MFIs)
SEED_PARTNERS = [
    {
        "name": "Tamil Nadu Backward Classes Economic Development Corporation (TABCEDCO)",
        "partner_type": "State Channelizing Agency (SCA)",
        "branch_name": "Head Office - Chennai",
        "state": "Tamil Nadu",
        "district": "Chennai",
        "pincode": "600006",
        "latitude": 13.0604,
        "longitude": 80.2496,
        "npa_rate": 1.2,
        "fund_utilization_eligible": True,
        "max_loan_cap": 1500000.0,
        "contact_phone": "+91 44 2824 1675",
        "contact_email": "tabcedco@tn.gov.in",
        "address": "No. 735, Anna Salai, Chennai, Tamil Nadu 600006"
    },
    {
        "name": "State Bank of India (MSME Intensive Branch)",
        "partner_type": "Public Sector Bank",
        "branch_name": "Guindy Industrial Estate Branch",
        "state": "Tamil Nadu",
        "district": "Chennai",
        "pincode": "600032",
        "latitude": 13.0102,
        "longitude": 80.2084,
        "npa_rate": 2.1,
        "fund_utilization_eligible": True,
        "max_loan_cap": 10000000.0,
        "contact_phone": "+91 44 2250 0812",
        "contact_email": "sbi.01824@sbi.co.in",
        "address": "SIDCO Industrial Estate, Guindy, Chennai, Tamil Nadu 600032"
    },
    {
        "name": "Odisha Scheduled Castes & Scheduled Tribes Development Finance Corporation (OSFDC)",
        "partner_type": "State Channelizing Agency (SCA)",
        "branch_name": "Bhubaneswar Regional Hub",
        "state": "Odisha",
        "district": "Khordha",
        "pincode": "751001",
        "latitude": 20.2961,
        "longitude": 85.8245,
        "npa_rate": 1.8,
        "fund_utilization_eligible": True,
        "max_loan_cap": 2000000.0,
        "contact_phone": "+91 674 253 0122",
        "contact_email": "osfdc.odisha@gov.in",
        "address": "Lewis Road, Bhubaneswar, Odisha 751001"
    },
    {
        "name": "Odisha Gramya Bank",
        "partner_type": "Regional Rural Bank (RRB)",
        "branch_name": "Cuttack Main Branch",
        "state": "Odisha",
        "district": "Cuttack",
        "pincode": "753001",
        "latitude": 20.4625,
        "longitude": 85.8828,
        "npa_rate": 2.4,
        "fund_utilization_eligible": True,
        "max_loan_cap": 3000000.0,
        "contact_phone": "+91 671 230 4589",
        "contact_email": "cuttack@ogb.co.in",
        "address": "Choudhury Bazar, Cuttack, Odisha 753001"
    },
    {
        "name": "Canara Bank (MSME Hub)",
        "partner_type": "Public Sector Bank",
        "branch_name": "Coimbatore Main Branch",
        "state": "Tamil Nadu",
        "district": "Coimbatore",
        "pincode": "641001",
        "latitude": 11.0168,
        "longitude": 76.9558,
        "npa_rate": 1.9,
        "fund_utilization_eligible": True,
        "max_loan_cap": 5000000.0,
        "contact_phone": "+91 422 239 1204",
        "contact_email": "cb1204@canarabank.com",
        "address": "Oppanakara Street, Coimbatore, Tamil Nadu 641001"
    },
    {
        "name": "National Minorities Development Finance Corporation (NMDFC Channel)",
        "partner_type": "SCA Channelizing Agency",
        "branch_name": "New Delhi Central Hub",
        "state": "Delhi",
        "district": "New Delhi",
        "pincode": "110003",
        "latitude": 28.5862,
        "longitude": 77.2289,
        "npa_rate": 1.1,
        "fund_utilization_eligible": True,
        "max_loan_cap": 3000000.0,
        "contact_phone": "+91 11 2436 6034",
        "contact_email": "info@nmdfc.org",
        "address": "Scope Complex, Core-1, Lodhi Road, New Delhi 110003"
    },
    {
        "name": "Stressed NBFC-MFI Branch (High Overdues)",
        "partner_type": "NBFC-MFI",
        "branch_name": "Restricted Access Branch",
        "state": "Tamil Nadu",
        "district": "Chennai",
        "pincode": "600001",
        "latitude": 13.0827,
        "longitude": 80.2707,
        "npa_rate": 8.5,  # High NPA > 3.0% -> Excluded by eligibility router!
        "fund_utilization_eligible": False,
        "max_loan_cap": 500000.0,
        "contact_phone": "+91 44 2525 0000",
        "contact_email": "restricted@nbfc.com",
        "address": "Parrys Corner, Chennai, Tamil Nadu 600001"
    }
]

def haversine_km(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
    """Calculate the Great Circle / Haversine distance between two coordinates in kilometers."""
    R = 6371.0  # Earth radius in kilometers
    dlat = math.radians(lat2 - lat1)
    dlon = math.radians(lon2 - lon1)
    a = (math.sin(dlat / 2.0) ** 2 +
         math.cos(math.radians(lat1)) * math.cos(math.radians(lat2)) * (math.sin(dlon / 2.0) ** 2))
    c = 2.0 * math.atan2(math.sqrt(a), math.sqrt(1.0 - a))
    return round(R * c, 2)

def seed_partners_if_empty(db: Session):
    count = db.query(ChannelPartner).count()
    if count == 0:
        for p in SEED_PARTNERS:
            partner_obj = ChannelPartner(**p)
            db.add(partner_obj)
        db.commit()

@router.get("/nearest")
def locate_nearest_eligible_partners(
    lat: float = Query(13.0827, description="User Latitude"),
    lon: float = Query(80.2707, description="User Longitude"),
    state: Optional[str] = Query(None, description="Filter by State"),
    district: Optional[str] = Query(None, description="Filter by District"),
    max_distance_km: float = Query(100.0, description="Max search radius in km"),
    max_npa_threshold: float = Query(3.0, description="Maximum allowed NPA rate %"),
    db: Session = Depends(get_db)
):
    seed_partners_if_empty(db)
    
    query = db.query(ChannelPartner)
    if state:
        query = query.filter(ChannelPartner.state.ilike(f"%{state}%"))
    if district:
        query = query.filter(ChannelPartner.district.ilike(f"%{district}%"))
        
    partners = query.all()
    results = []
    
    for p in partners:
        dist_km = haversine_km(lat, lon, p.latitude, p.longitude)
        if dist_km <= max_distance_km:
            # Check eligibility routing status
            is_eligible = (p.npa_rate <= max_npa_threshold) and p.fund_utilization_eligible
            status_label = "Eligible - Healthy Fund Quota" if is_eligible else f"Ineligible (High NPA: {p.npa_rate}%)"
            
            results.append({
                "id": p.id,
                "name": p.name,
                "partner_type": p.partner_type,
                "branch_name": p.branch_name,
                "state": p.state,
                "district": p.district,
                "pincode": p.pincode,
                "latitude": p.latitude,
                "longitude": p.longitude,
                "npa_rate": p.npa_rate,
                "fund_utilization_eligible": p.fund_utilization_eligible,
                "is_eligible_for_routing": is_eligible,
                "status_label": status_label,
                "max_loan_cap": p.max_loan_cap,
                "contact_phone": p.contact_phone,
                "contact_email": p.contact_email,
                "address": p.address,
                "distance_km": dist_km,
                "maps_navigation_url": f"https://www.google.com/maps/dir/?api=1&destination={p.latitude},{p.longitude}"
            })
            
    # Sort results: First by eligibility (eligible first), then by nearest distance
    results.sort(key=lambda x: (not x["is_eligible_for_routing"], x["distance_km"]))
    
    return {
        "success": True,
        "user_coordinates": {"latitude": lat, "longitude": lon},
        "search_radius_km": max_distance_km,
        "total_found": len(results),
        "eligible_count": sum(1 for r in results if r["is_eligible_for_routing"]),
        "partners": results
    }

@router.get("/all")
def get_all_channel_partners(db: Session = Depends(get_db)):
    seed_partners_if_empty(db)
    partners = db.query(ChannelPartner).all()
    return {"success": True, "total": len(partners), "partners": partners}
