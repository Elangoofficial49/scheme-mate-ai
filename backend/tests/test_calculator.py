from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_financial_calculator_pmegp_subsidy():
    payload = {
        "loan_amount": 1000000.0,
        "interest_rate": 8.5,
        "tenure_months": 60,
        "moratorium_months": 6,
        "subsidy_percentage": 25.0
    }
    response = client.post("/api/v1/calculator/calculate", json=payload)
    assert response.status_code == 200
    data = response.json()
    assert data["success"] is True
    assert data["gross_loan_amount"] == 1000000.0
    assert data["subsidy_amount"] == 250000.0
    assert data["net_loan_amount"] == 750000.0
    assert data["moratorium_months"] == 6
    assert data["repayment_months"] == 54
    assert data["regular_monthly_emi"] > 0
    assert len(data["schedule_summary"]) > 0

def test_financial_calculator_zero_moratorium():
    payload = {
        "loan_amount": 500000.0,
        "interest_rate": 6.5,
        "tenure_months": 36,
        "moratorium_months": 0,
        "subsidy_percentage": 15.0
    }
    response = client.post("/api/v1/calculator/calculate", json=payload)
    assert response.status_code == 200
    data = response.json()
    assert data["success"] is True
    assert data["net_loan_amount"] == 425000.0
    assert data["moratorium_monthly_payment"] == 0.0
    assert data["regular_monthly_emi"] > 0
