from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_partner_locator_nearest_chennai():
    # Query Chennai coordinates
    response = client.get("/api/v1/partners/nearest?lat=13.0827&lon=80.2707&max_distance_km=50")
    assert response.status_code == 200
    data = response.json()
    assert data["success"] is True
    assert data["total_found"] > 0
    partners = data["partners"]
    
    # Verify distance sorting
    distances = [p["distance_km"] for p in partners if p["is_eligible_for_routing"]]
    assert distances == sorted(distances)
    
    # Verify NPA filtering label
    for p in partners:
        if p["npa_rate"] > 3.0 or not p["fund_utilization_eligible"]:
            assert p["is_eligible_for_routing"] is False
            assert "Ineligible" in p["status_label"]
        else:
            assert p["is_eligible_for_routing"] is True

def test_get_all_channel_partners():
    response = client.get("/api/v1/partners/all")
    assert response.status_code == 200
    data = response.json()
    assert data["success"] is True
    assert data["total"] >= 5

