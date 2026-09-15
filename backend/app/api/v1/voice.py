import io
import base64
from fastapi import APIRouter, HTTPException, Query
from fastapi.responses import StreamingResponse
from pydantic import BaseModel
from typing import Optional
from app.core.logging import logger

router = APIRouter(prefix="/voice", tags=["Voice & Audio Guidance"])

# Language code mapping to gTTS supported codes
LANG_CODE_MAP = {
    "hi": "hi",
    "ta": "ta",
    "te": "te",
    "kn": "kn",
    "ml": "ml",
    "mr": "mr",
    "bn": "bn",
    "gu": "gu",
    "pa": "pa",
    "ur": "ur",
    "ne": "ne",
    "or": "or",
    "as": "as",
    "sa": "sa",
    "en": "en",
    # Fallbacks for regional variations
    "mai": "hi", # Maithili -> Hindi fallback
    "doi": "hi", # Dogri -> Hindi fallback
    "ks": "ur",  # Kashmiri -> Urdu fallback
    "kok": "mr", # Konkani -> Marathi fallback
    "mni": "bn", # Manipuri -> Bengali fallback
    "sat": "hi", # Santali -> Hindi fallback
    "sd": "ur"   # Sindhi -> Urdu fallback
}

class TTSRequest(BaseModel):
    text: str
    lang: str = "en"

@router.post("/tts")
def generate_tts_audio(req: TTSRequest):
    """
    Generates MP3 audio for the given text in one of 23 official Indian languages.
    Returns Base64 audio payload and content type.
    """
    if not req.text or not req.text.strip():
        raise HTTPException(status_code=400, detail="Text parameter cannot be empty.")

    target_lang = LANG_CODE_MAP.get(req.lang.lower(), "hi" if req.lang != "en" else "en")
    clean_text = req.text.strip()[:1000] # Limit chunk length for TTS performance

    try:
        from gtts import gTTS
        tts = gTTS(text=clean_text, lang=target_lang, slow=False)
        mp3_fp = io.BytesIO()
        tts.write_to_fp(mp3_fp)
        mp3_fp.seek(0)

        audio_b64 = base64.b64encode(mp3_fp.read()).decode("utf-8")
        logger.info(f"🔊 TTS Audio synthesized successfully for lang='{target_lang}' (len={len(clean_text)})")

        return {
            "success": True,
            "lang": req.lang,
            "target_lang": target_lang,
            "mime_type": "audio/mp3",
            "audio_base64": audio_b64
        }
    except Exception as e:
        logger.warning(f"⚠ TTS generation fallback error: {e}")
        return {
            "success": False,
            "message": f"TTS synthesis error: {str(e)}",
            "fallback_text": clean_text
        }

@router.get("/stream")
def stream_tts_audio(text: str = Query(..., description="Text to synthesize"), lang: str = Query("en", description="Target language code")):
    """
    Streams raw MP3 audio directly for HTML5 / Flutter Audio player.
    """
    target_lang = LANG_CODE_MAP.get(lang.lower(), "hi" if lang != "en" else "en")
    clean_text = text.strip()[:1000]

    try:
        from gtts import gTTS
        tts = gTTS(text=clean_text, lang=target_lang, slow=False)
        mp3_fp = io.BytesIO()
        tts.write_to_fp(mp3_fp)
        mp3_fp.seek(0)
        return StreamingResponse(mp3_fp, media_type="audio/mpeg")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Audio streaming failed: {str(e)}")
