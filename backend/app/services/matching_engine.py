import json
from typing import Dict, Any, List
from app.services.eligibility_engine import DeterministicEligibilityEngine

class AIMatchingEngine:
    """
    Hybrid AI matching and transparent ranking engine.
    Calculates weighted score and formats explainable AI (XAI) output.
    """
    
    @classmethod
    def analyze_scheme_match(cls, profile: Dict[str, Any], scheme: Dict[str, Any]) -> Dict[str, Any]:
        # 1. Parse rules from scheme
        raw_rules = scheme.get("eligibility_rules")
        rules = {}
        if isinstance(raw_rules, str) and raw_rules:
            try:
                rules = json.loads(raw_rules)
            except Exception:
                rules = {}
        elif isinstance(raw_rules, dict):
            rules = raw_rules

        # 2. Hard deterministic rule check
        eval_result = DeterministicEligibilityEngine.evaluate(profile, rules)
        
        # 3. Calculate dimension scores (0 to 100)
        # Eligibility Match (30%)
        if eval_result["status"] == "Eligible":
            eligibility_score = 100.0
        elif eval_result["status"] == "Potentially Eligible":
            eligibility_score = 70.0
        else:
            eligibility_score = 20.0
            
        # Business Type Match (20%)
        user_bt = (profile.get("business_type") or "").lower()
        scheme_bt = (scheme.get("description") or "" + scheme.get("target_beneficiary") or "").lower()
        if user_bt and user_bt in scheme_bt:
            business_score = 100.0
        elif user_bt:
            business_score = 70.0
        else:
            business_score = 50.0

        # Financial Need Match (15%)
        req_amount = profile.get("funding_requirement") or profile.get("investment_requirement") or 0
        benefits_text = (scheme.get("benefits") or "").lower()
        if req_amount > 0 and ("subsidy" in benefits_text or "loan" in benefits_text or "lakh" in benefits_text):
            financial_score = 95.0
        else:
            financial_score = 75.0

        # Location Match (15%)
        user_state = profile.get("state") or ""
        scheme_state = scheme.get("state") or "All India"
        if scheme_state == "All India" or (user_state and user_state.lower() == scheme_state.lower()):
            location_score = 100.0
        else:
            location_score = 0.0

        # User Goal Match (10%)
        goal_score = 85.0
        
        # Overall Relevance (10%)
        relevance_score = 80.0

        # Weighted final score calculation
        total_score = (
            (eligibility_score * 0.30) +
            (business_score * 0.20) +
            (financial_score * 0.15) +
            (location_score * 0.15) +
            (goal_score * 0.10) +
            (relevance_score * 0.10)
        )
        
        # Penalize if hard failed rules present
        if eval_result["status"] == "Ineligible":
            total_score = min(total_score, 45.0)

        # 4. Generate Explainable AI (XAI) bullet points
        why_matches = []
        why_not = []
        
        for rule_msg in eval_result["matched_rules"]:
            why_matches.append(f"✓ {rule_msg}")
            
        if location_score == 100.0:
            why_matches.append(f"✓ Scheme operates in your region ({scheme_state})")
            
        if req_amount > 0 and financial_score > 80:
            why_matches.append(f"✓ Matches your funding requirement of Rs. {req_amount:,.0f}")
            
        for fail_msg in eval_result["failed_rules"]:
            why_not.append(f"✗ {fail_msg}")
            
        for missing_msg in eval_result["missing_information"]:
            why_not.append(f"⚠ Missing verification for: {missing_msg}")

        # 5. Parse required documents
        raw_docs = scheme.get("required_documents")
        docs_list = []
        if isinstance(raw_docs, str) and raw_docs:
            try:
                docs_list = json.loads(raw_docs)
            except Exception:
                docs_list = []
        elif isinstance(raw_docs, list):
            docs_list = raw_docs

        return {
            "scheme_id": scheme.get("id"),
            "scheme_name": scheme.get("scheme_name"),
            "ministry": scheme.get("ministry"),
            "match_score": round(total_score, 1),
            "match_label": f"{round(total_score, 1)}% profile-to-scheme match",
            "eligibility_status": eval_result["status"],
            "why_matches": why_matches,
            "why_not": why_not,
            "missing_information": eval_result["missing_information"],
            "required_documents": docs_list,
            "official_application_url": scheme.get("official_application_url"),
            "official_source_url": scheme.get("official_source_url"),
            "last_verified": scheme.get("last_verified"),
            "last_date_to_apply": scheme.get("last_date_to_apply") or "31 Dec 2026 (Open Year-Round)"
        }
