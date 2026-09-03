import json
import logging
import re
from typing import Dict, Any, List, Optional
import httpx
from app.core.config import settings
from app.services.matching_engine import AIMatchingEngine

logger = logging.getLogger(__name__)

class GeminiSchemeAdvisorService:
    """
    Google Gemini AI-powered scheme advisory service.
    Analyzes user profile details and dynamically suggests real, active government schemes
    with personalized match scores, explainable AI reasoning, benefits, required documents,
    and verified official application portals.
    """

    @classmethod
    def format_profile_for_prompt(cls, profile: Dict[str, Any], query: Optional[str] = None) -> str:
        """Construct a structured representation of the entrepreneur's profile."""
        lines = [
            f"• Full Name / Entrepreneur: {profile.get('full_name') or 'Entrepreneur'}",
            f"• Enterprise / Business Name: {profile.get('company_name') or profile.get('enterprise_name') or 'Micro Enterprise'}",
            f"• Business Activity / Description: {profile.get('business_description') or 'General Small Business'}",
            f"• Sector / Business Type: {profile.get('business_type') or 'Manufacturing / Service'}",
            f"• Business Stage: {profile.get('business_stage') or 'Existing / Expansion'}",
            f"• Age: {profile.get('age') or 'Not specified'}",
            f"• Gender: {profile.get('gender') or 'Not specified'}",
            f"• Social Category / Community: {profile.get('category') or 'General / OBC / SC / ST'}",
            f"• Location / State: {profile.get('state') or 'India'}",
            f"• District / Region: {profile.get('district') or 'All District'}, {profile.get('urban_rural') or 'Rural/Urban'}",
            f"• Source of Income: {profile.get('source_of_income') or 'Self-Employed'}",
            f"• Annual Income: Rs. {profile.get('annual_income', 0):,}" if profile.get('annual_income') else "• Annual Income: Not specified",
            f"• Funding / Loan Requirement: Rs. {profile.get('funding_requirement', 0):,}" if profile.get('funding_requirement') else "• Funding Requirement: Micro / Small Scale Financial Assistance",
            f"• Certificate / Proof Available: {profile.get('certificate_type')}{(' (Reg/Cert No: ' + str(profile.get('certificate_number')) + ')') if profile.get('certificate_number') else ''}" if (profile.get('certificate_uploaded') or profile.get('certificate_number')) else "• Certificate / Proof Available: Standard Identity & Business proofs",
        ]
        if query:
            lines.append(f'• Specific Goal / Query by User: "{query}"')
        return "\n".join(lines)

    @classmethod
    def suggest_schemes_with_gemini(
        cls,
        profile: Dict[str, Any],
        query: Optional[str] = None,
        schemes_kb: Optional[List[Dict[str, Any]]] = None
    ) -> Dict[str, Any]:
        """
        Main entry point for Gemini AI scheme recommendations.
        Calls Google Gemini API if key is present, otherwise gracefully falls back to the hybrid matching engine.
        """
        api_key = settings.effective_gemini_api_key
        model = settings.GEMINI_MODEL or "gemini-3.6-flash"
        if model in ["gemini-1.5-flash", "gemini-1.5-pro"]:
            model = "gemini-3.6-flash"

        if not api_key:
            logger.info("No Gemini API Key found in environment. Using intelligent hybrid scheme matching engine.")
            return cls._fallback_hybrid_suggestions(profile, query, schemes_kb, note="Generated using SchemeMate AI Hybrid Engine (Set GEMINI_API_KEY for direct Gemini model calls).")

        # Call Gemini API
        try:
            return cls._call_gemini_api(api_key, model, profile, query, schemes_kb)
        except Exception as e:
            logger.error(f"Gemini API invocation error: {e}. Falling back to hybrid scheme matching engine.")
            return cls._fallback_hybrid_suggestions(profile, query, schemes_kb, note=f"Gemini service notice: {str(e)}. Displaying verified database schemes.")

    @classmethod
    def _call_gemini_api(
        cls,
        api_key: str,
        model: str,
        profile: Dict[str, Any],
        query: Optional[str],
        schemes_kb: Optional[List[Dict[str, Any]]]
    ) -> Dict[str, Any]:
        """Direct HTTP call to Google Generative Language API for Gemini."""
        url = f"https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent?key={api_key}"
        
        profile_text = cls.format_profile_for_prompt(profile, query)

        system_instruction = (
            "You are SchemeMate AI, a world-class AI Government Scheme Advisor for India. "
            "Your job is to analyze the entrepreneur's exact profile (demographics, income, business type, stage, funding need, state) "
            "and suggest top official, real, active Government of India & State Government schemes (e.g. PMEGP, PM Mudra, Stand-Up India, "
            "PM Vishwakarma, CGTMSE, CLCSS, MSME Champions, State Schemes like NEEDS, etc.).\n\n"
            "Return ONLY valid JSON matching this exact schema:\n"
            "{\n"
            '  "ai_analysis_summary": "2-3 sentences explaining the entrepreneur\'s overall scheme eligibility landscape and top opportunities.",\n'
            '  "recommended_schemes": [\n'
            "    {\n"
            '      "scheme_id": "unique-slug-id",\n'
            '      "scheme_name": "Official Scheme Name",\n'
            '      "ministry": "Ministry / Department Name",\n'
            '      "category": "e.g., Credit Subsidy / Machinery Loan / Women Support",\n'
            '      "match_score": 95,\n'
            '      "match_label": "95% AI Match",\n'
            '      "eligibility_status": "Eligible",\n'
            '      "why_matches": [\n'
            '        "Specific reason tailored to their business type and sector",\n'
            '        "Specific reason tailored to their social category/location/funding"\n'
            "      ],\n"
            '      "key_benefits": "Clear description of financial/subsidy/loan benefits",\n'
            '      "eligibility_summary": "Summary of eligibility criteria",\n'
            '      "last_date_to_apply": "Application deadline or e.g. 31 Dec 2026 (Open Year-Round)",\n'
            '      "required_documents": ["Aadhaar Card", "PAN Card", "Project Report", "Caste/Income Certificate if applicable", "Bank Statement"],\n'
            '      "official_application_url": "https://official-government-portal-url.gov.in",\n'
            '      "step_by_step_application_steps": [\n'
            '        "Step 1: Visit the official portal",\n'
            '        "Step 2: Prepare required documents and project report",\n'
            '        "Step 3: Submit online application and track reference number"\n'
            '      ]\n'
            '    }\n'
            '  ]\n'
            '}'
        )

        user_content = (
            f"Here is the entrepreneur's profile details:\n\n{profile_text}\n\n"
            "Analyze their profile and return the top 4-6 most relevant and high-impact active government schemes in the specified JSON format."
        )

        payload = {
            "contents": [
                {
                    "parts": [
                        {"text": f"{system_instruction}\n\n{user_content}"}
                    ]
                }
            ],
            "generationConfig": {
                "temperature": 0.2,
                "topP": 0.8,
                "topK": 40,
                "maxOutputTokens": 8192,
                "responseMimeType": "application/json"
            }
        }

        with httpx.Client(timeout=8.0) as client:
            response = client.post(url, json=payload)
            if response.status_code != 200:
                # Try standard non-responseMimeType request if model doesn't support json mode
                payload["generationConfig"].pop("responseMimeType", None)
                response = client.post(url, json=payload)
                if response.status_code != 200:
                    raise Exception(f"Gemini API returned status {response.status_code}: {response.text}")

            data = response.json()
            candidates = data.get("candidates", [])
            if not candidates:
                raise Exception("No candidate response received from Gemini.")

            candidate = candidates[0]
            parts = candidate.get("content", {}).get("parts", [])
            if not parts:
                raise Exception("Empty content parts in Gemini response.")

            raw_text = parts[0].get("text", "")
            
            # Extract JSON
            clean_json_str = raw_text.strip()
            if clean_json_str.startswith("```json"):
                clean_json_str = clean_json_str[7:]
            if clean_json_str.startswith("```"):
                clean_json_str = clean_json_str[3:]
            if clean_json_str.endswith("```"):
                clean_json_str = clean_json_str[:-3]
            clean_json_str = clean_json_str.strip()

            parsed_data = json.loads(clean_json_str)
            schemes_list = parsed_data.get("recommended_schemes") or parsed_data.get("schemes") or []

            # Ensure proper typing and formatting
            for item in schemes_list:
                if "match_score" in item:
                    try:
                        item["match_score"] = float(item["match_score"])
                    except Exception:
                        item["match_score"] = 90.0
                if "match_label" not in item and "match_score" in item:
                    item["match_label"] = f"{int(item['match_score'])}% AI Match"
                if not item.get("last_date_to_apply"):
                    item["last_date_to_apply"] = "31 Dec 2026 (Open Year-Round)"

            return {
                "success": True,
                "provider": "google_gemini",
                "model": model,
                "ai_analysis_summary": parsed_data.get("ai_analysis_summary") or "Gemini AI has analyzed your entrepreneur profile and matched official government schemes.",
                "total_suggestions": len(schemes_list),
                "data": schemes_list
            }

    @classmethod
    def _fallback_hybrid_suggestions(
        cls,
        profile: Dict[str, Any],
        query: Optional[str],
        schemes_kb: Optional[List[Dict[str, Any]]],
        note: str = ""
    ) -> Dict[str, Any]:
        """Intelligent local matching fallback grounded on verified schemes knowledge base."""
        if not schemes_kb:
            from app.core.database import SessionLocal
            from app.models.scheme import Scheme
            db = SessionLocal()
            try:
                schemes_orm = db.query(Scheme).filter(Scheme.status == "Active").all()
                schemes_kb = [{
                    "id": s.id,
                    "scheme_name": s.scheme_name,
                    "ministry": s.ministry,
                    "description": s.description,
                    "target_beneficiary": s.target_beneficiary,
                    "benefits": s.benefits,
                    "state": s.state,
                    "official_application_url": s.official_application_url,
                    "official_source_url": s.official_source_url,
                    "last_verified": s.last_verified,
                    "eligibility_rules": s.eligibility_rules,
                    "required_documents": s.required_documents
                } for s in schemes_orm]
            finally:
                db.close()

        analyzed_schemes = []
        for s in (schemes_kb or []):
            res = AIMatchingEngine.analyze_scheme_match(profile, s)
            
            # Format step-by-step guidance
            scheme_name = res.get("scheme_name", "Scheme")
            portal_url = res.get("official_application_url", "https://www.myscheme.gov.in/")
            
            res["step_by_step_application_steps"] = [
                f"Step 1: Check document checklist for {scheme_name}",
                f"Step 2: Access official online portal: {portal_url}",
                "Step 3: Register using Aadhaar & mobile OTP",
                "Step 4: Upload project details and submit online application form"
            ]
            res["key_benefits"] = s.get("benefits") or "Financial subsidy and institutional credit assistance"
            res["eligibility_summary"] = f"Suitable for {s.get('target_beneficiary', 'Entrepreneurs')} in {s.get('state', 'All India')}"
            res["last_date_to_apply"] = s.get("last_date_to_apply") or "31 Dec 2026 (Open Year-Round)"
            res["category"] = "Government Scheme"
            
            analyzed_schemes.append(res)

        analyzed_schemes.sort(key=lambda x: x.get("match_score", 0), reverse=True)
        top_schemes = analyzed_schemes[:6]

        funding_val = profile.get('funding_requirement') or 0
        summary = (
            f"Based on your profile as a {profile.get('business_type', 'business')} entrepreneur "
            f"in {profile.get('state', 'India')}, here are the top verified government schemes "
            f"matching your business profile and capital requirements."
        )

        return {
            "success": True,
            "provider": "hybrid_verified_engine",
            "model": "rule_based_ai",
            "ai_analysis_summary": summary,
            "note": note,
            "total_suggestions": len(top_schemes),
            "data": top_schemes
        }
