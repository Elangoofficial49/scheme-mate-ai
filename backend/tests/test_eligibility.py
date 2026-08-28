import pytest
from app.services.eligibility_engine import DeterministicEligibilityEngine

def test_pmegp_eligibility_success():
    profile = {
        "age": 25,
        "state": "Tamil Nadu",
        "category": "OBC",
        "business_type": "Manufacturing",
        "education_level": "10th Pass"
    }
    rules = {
        "minimum_age": 18,
        "state": "All India",
        "allowed_categories": ["General", "OBC", "SC", "ST", "Women"],
        "eligible_business_types": ["Manufacturing", "Service", "Trading"]
    }
    result = DeterministicEligibilityEngine.evaluate(profile, rules)
    assert result["eligible"] is True
    assert result["status"] == "Eligible"
    assert len(result["failed_rules"]) == 0

def test_eligibility_age_failure():
    profile = {
        "age": 16,
        "state": "Tamil Nadu",
        "category": "General",
        "business_type": "Trading"
    }
    rules = {
        "minimum_age": 18,
        "eligible_business_types": ["Trading"]
    }
    result = DeterministicEligibilityEngine.evaluate(profile, rules)
    assert result["eligible"] is False
    assert result["status"] == "Ineligible"
    assert any("Minimum age" in err for err in result["failed_rules"])

def test_eligibility_missing_information():
    profile = {
        "age": 25,
        "business_type": "Service"
    }
    rules = {
        "minimum_age": 18,
        "state": "Tamil Nadu",
        "annual_family_income_max": 500000
    }
    result = DeterministicEligibilityEngine.evaluate(profile, rules)
    assert result["status"] == "Potentially Eligible"
    assert "State location" in result["missing_information"]
    assert "Annual Income" in result["missing_information"]
