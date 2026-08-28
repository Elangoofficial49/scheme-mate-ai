import re
from typing import Dict, Any, Tuple

class AIGuardrails:
    """
    Security guardrails for LLM input sanitization, prompt injection detection,
    PII masking, and grounding verification.
    """
    
    PROMPT_INJECTION_PATTERNS = [
        r"ignore (all )?previous instructions",
        r"system prompt",
        r"you are now an unfiltered",
        r"bypass eligibility",
        r"grant approval guaranteed",
        r"fake government link",
        r"sudo mode",
        r"jailbreak"
    ]
    
    @classmethod
    def sanitize_user_input(cls, text: str) -> str:
        if not text:
            return ""
        # Remove malicious control characters and limit length
        cleaned = re.sub(r'[\x00-\x08\x0B\x0C\x0E-\x1F]', '', text)
        return cleaned[:2000]

    @classmethod
    def detect_prompt_injection(cls, text: str) -> Tuple[bool, str]:
        text_lower = text.lower()
        for pattern in cls.PROMPT_INJECTION_PATTERNS:
            if re.search(pattern, text_lower):
                return True, f"Blocked potential prompt injection pattern: {pattern}"
        return False, ""

    @classmethod
    def mask_pii(cls, text: str) -> str:
        if not text:
            return ""
        # Mask Aadhaar numbers (12 digits)
        text = re.sub(r'\b\d{4}\s?\d{4}\s?\d{4}\b', 'XXXX-XXXX-XXXX', text)
        # Mask PAN numbers (5 letters, 4 digits, 1 letter)
        text = re.sub(r'\b[A-Z]{5}\d{4}[A-Z]{1}\b', '[PAN-MASKED]', text, flags=re.IGNORECASE)
        # Mask Phone numbers (10 digits)
        text = re.sub(r'\b[6-9]\d{9}\b', '[PHONE-MASKED]', text)
        return text

    @classmethod
    def verify_grounding(cls, llm_response: str, verified_scheme_context: str) -> Tuple[bool, str]:
        """
        Verify that LLM does not make unsupported financial promises or fake guarantees.
        """
        lower_resp = llm_response.lower()
        prohibited_phrases = [
            "100% guaranteed approval",
            "approval is guaranteed",
            "we guarantee you will get",
            "click here to claim free cash instantly"
        ]
        for phrase in prohibited_phrases:
            if phrase in lower_resp:
                return False, f"Response contained illegal guarantee claim: '{phrase}'"
        return True, ""
