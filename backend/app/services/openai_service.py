import os
from typing import List, Dict, Any, Optional

class OpenAISchemeAdvisorService:
    @classmethod
    def generate_chatgpt_response(
        cls,
        user_message: str,
        user_profile: Dict[str, Any],
        preferred_language: str = "en",
        conversation_history: Optional[List[Dict[str, str]]] = None
    ) -> Dict[str, Any]:
        """
        Generate conversational guidance using OpenAI API if configured,
        or return a graceful fallback result so Gemini / RAG handles it.
        """
        api_key = os.getenv("OPENAI_API_KEY")
        if not api_key:
            return {"success": False, "reply": "", "error": "OPENAI_API_KEY not configured"}

        try:
            from openai import OpenAI
            client = OpenAI(api_key=api_key)

            system_prompt = (
                "You are SchemeMate AI, a kind and helpful government scheme advisor for Indian micro-entrepreneurs. "
                f"User Profile: {user_profile}. "
                f"Respond in language: {preferred_language}."
            )

            messages = [{"role": "system", "content": system_prompt}]
            if conversation_history:
                for msg in conversation_history[-6:]:
                    messages.append({"role": msg.get("role", "user"), "content": msg.get("content", "")})
            messages.append({"role": "user", "content": user_message})

            response = client.chat.completions.create(
                model=os.getenv("OPENAI_MODEL", "gpt-3.5-turbo"),
                messages=messages,
                max_tokens=500,
                temperature=0.7
            )
            reply = response.choices[0].message.content or ""
            return {"success": True, "reply": reply.strip()}
        except Exception as e:
            return {"success": False, "reply": "", "error": str(e)}
