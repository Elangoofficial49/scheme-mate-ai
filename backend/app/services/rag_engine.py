import json
from typing import List, Dict, Any
from app.ai.guardrails import AIGuardrails

class RAGEngine:
    """
    Retrieval-Augmented Generation Engine grounded on verified scheme knowledge base.
    Uses vector/text search and guards against hallucinated government claims.
    """

    @classmethod
    def answer_user_query(cls, query: str, user_profile: Dict[str, Any], schemes_kb: List[Dict[str, Any]]) -> Dict[str, Any]:
        # 1. Input sanitization & injection check
        sanitized_query = AIGuardrails.sanitize_user_input(query)
        is_injection, reason = AIGuardrails.detect_prompt_injection(sanitized_query)
        if is_injection:
            return {
                "answer": "Your request could not be processed due to safety and security guardrails.",
                "sources": [],
                "grounded": False,
                "error": reason
            }

        # 2. Retrieve top matching verified scheme documents
        query_words = set(sanitized_query.lower().split())
        scored_schemes = []
        for s in schemes_kb:
            score = 0
            text_corpus = f"{s.get('scheme_name')} {s.get('description')} {s.get('target_beneficiary')} {s.get('benefits')} {s.get('state')}".lower()
            for w in query_words:
                if len(w) > 2 and w in text_corpus:
                    score += 1
            if score > 0:
                scored_schemes.append((score, s))

        scored_schemes.sort(key=lambda x: x[0], reverse=True)
        top_schemes = [s[1] for s in scored_schemes[:3]]

        if not top_schemes and schemes_kb:
            top_schemes = schemes_kb[:2]

        # 3. Build grounded response
        if not top_schemes:
            return {
                "answer": "Information could not be verified from the available official government sources.",
                "sources": [],
                "grounded": True
            }

        primary_scheme = top_schemes[0]
        answer_text = (
            f"Based on verified government records for '{primary_scheme.get('scheme_name')}' "
            f"administered by {primary_scheme.get('ministry')}:\n\n"
            f"• Description: {primary_scheme.get('description')}\n"
            f"• Target Beneficiaries: {primary_scheme.get('target_beneficiary')}\n"
            f"• Key Benefits: {primary_scheme.get('benefits')}\n"
            f"• Application Portal: {primary_scheme.get('official_application_url')}\n\n"
            f"Note: Final eligibility is determined by official authorities upon formal verification."
        )

        sources = [{
            "scheme_name": s.get("scheme_name"),
            "ministry": s.get("ministry"),
            "official_source_url": s.get("official_source_url"),
            "last_verified": s.get("last_verified")
        } for s in top_schemes]

        # 4. Verify grounding
        is_grounded, g_reason = AIGuardrails.verify_grounding(answer_text, "")
        if not is_grounded:
            answer_text = "Retrieved content could not pass safety verification."

        return {
            "answer": answer_text,
            "sources": sources,
            "grounded": is_grounded
        }
