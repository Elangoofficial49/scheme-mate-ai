from fastapi.testclient import TestClient
from app.main import app
from app.core.database import init_db

init_db()
client = TestClient(app)

def test_root_endpoint():
    response = client.get("/")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "online"
    assert data["system"] == "SchemeMate AI"

def test_health_endpoint():
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json()["status"] == "healthy"

def test_schemes_list_endpoint():
    response = client.get("/api/v1/schemes")
    assert response.status_code == 200
    data = response.json()
    assert data["success"] is True
    assert data["count"] > 0
    assert len(data["data"]) >= 5
