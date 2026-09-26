import os
import re
import logging
from typing import List, Dict, Any, Optional

logger = logging.getLogger(__name__)

class OpenAISchemeAdvisorService:
    """
    Gen AI-Powered Conversational Scheme Assistant for SchemeMate AI.
    - Speaks conversationally and empathetically like a helpful human advisor.
    - Directly answers relevant questions about SchemeMate AI website features,
      government schemes (PMEGP, MUDRA, Vishwakarma, etc.), 35% subsidies,
      financial loan calculators, and partner DIC offices.
    - Strictly guardrailed: Any question apart from the website/schemes is politely
      declined, directing the user back to the website.
    """

    GUARDRAIL_RESPONSES: Dict[str, str] = {
        "en": (
            "I am your SchemeMate AI Assistant, dedicated exclusively to assisting you with "
            "SchemeMate AI, government schemes, business subsidies, and entrepreneur loans. "
            "Please feel free to ask me questions about our website features or government schemes! 😊"
        ),
        "ta": (
            "நான் உங்கள் SchemeMate AI உதவி முகவர்! இந்த இணையதளம், அரசு திட்டங்கள், மானியங்கள் "
            "மற்றும் தொழில் கடன்கள் தொடர்பான கேள்விகளுக்கு மட்டுமே நான் வழிகாட்டுகிறேன். "
            "தயவுசெய்து எங்களது இணையதள அம்சங்கள் அல்லது அரசு திட்டங்கள் பற்றி கேளுங்கள்! 😊"
        ),
        "hi": (
            "मैं आपका SchemeMate AI सहायक हूँ! मैं विशेष रूप से हमारी वेबसाइट, सरकारी योजनाओं, "
            "सब्सिडी और व्यवसाय ऋण के संबंध में सहायता करने के लिए उपलब्ध हूँ। "
            "कृपया हमारी वेबसाइट की सुविधाओं या सरकारी योजनाओं से संबंधित प्रश्न पूछें! 😊"
        ),
        "te": (
            "నేను మీ SchemeMate AI సహాయకుడిని! మా వెబ్‌సైట్, ప్రభుత్వ పథకాలు, సబ్సిడీలు "
            "మరియు వ్యాపార రుణాల గురించి మాత్రమే మీకు మార్గదర్శనం చేస్తాను. "
            "దయచేసి మా వెబ్‌సైట్ ఫీచర్లు లేదా ప్రభుత్వ పథకాల గురించి ప్రశ్నలు అడగండి! 😊"
        ),
        "kn": (
            "ನಾನು ನಿಮ್ಮ SchemeMate AI ಸಹಾಯಕ! ನಮ್ಮ ವೆಬ್‌ಸೈಟ್, ಸರ್ಕಾರಿ ಯೋಜನೆಗಳು, ಸಬ್ಸಿಡಿಗಳು "
            "ಮತ್ತು ವ್ಯಾಪಾರ ಸಾಲಗಳ ಬಗ್ಗೆ ಮಾತ್ರ ನಾನು ನಿಮಗೆ ಮಾರ್ಗದರ್ಶನ ನೀಡಬಲ್ಲೆ. "
            "ದಯವಿಟ್ಟು ನಮ್ಮ ವೆಬ್‌ಸೈಟ್ ಅಥವಾ ಸರ್ಕಾರಿ ಯೋಜನೆಗಳಿಗೆ ಸಂಬಂಧಿಸಿದ ಪ್ರಶ್ನೆಗಳನ್ನು ಕೇಳಿ! 😊"
        ),
    }

    # Out-of-domain keywords that indicate queries apart from the website
    OUT_OF_DOMAIN_PATTERNS = [
        # Programming & coding
        r"\b(python|javascript|typescript|c\+\+|java|html|css|react|angular|vue|django|flask|php|sql|regex)\b",
        r"\b(write\s+code|debug|function|algorithm|binary\s+search|leetcode|github\s+repo|compiler|programming)\b",
        # Sports & gaming
        r"\b(cricket|football|soccer|tennis|badminton|world\s+cup|ipl|fifa|olympics|messi|ronaldo|virat\s+kohli|dhoni)\b",
        r"\b(pubg|free\s+fire|gta|fortnite|minecraft|playstation|xbox|video\s+game)\b",
        # Entertainment & cinema
        r"\b(movie|cinema|film|actor|actress|bollywood|hollywood|kollywood|tollywood|box\s+office|netflix|song|singer|trailer)\b",
        # Weather & geography trivia
        r"\b(weather|temperature|forecast|monsoon|rain\s+today|climate\s+change)\b",
        r"\b(capital\s+of|planet|solar\s+system|photosynthesis|gravity|quantum|dinosaur|who\s+invented|president\s+of\s+usa)\b",
        # Cooking & recipes
        r"\b(recipe|how\s+to\s+cook|how\s+to\s+bake|biryani|pasta|curry|ingredients\s+for)\b",
        # Math & homework
        r"\b(solve\s+for\s+x|calculus|derivative|integral|algebra|equation\s+\d)\b",
        # Personal non-business
        r"\b(weight\s+loss|diet\s+plan|horoscope|zodiac|astrology|love\s+advice|dating)\b"
    ]

    # In-domain keywords representing website features and schemes
    IN_DOMAIN_PATTERNS = [
        r"\b(schememate|website|portal|app|page|feature|menu|navigat\w*|login|signup|account|profile)\b",
        r"\b(ocr|scan|document|upload|aadhaar|pan|income\s+cert|caste\s+cert|camera|photo)\b",
        r"\b(scheme|yojana|thittam|pmegp|mudra|vishwakarma|cgtmse|stand[\s\-]?up\s+india|standup|msme|kvic|kvib)\b",
        r"\b(subsidy|subsidies|grant|margin\s+money|35%|25%|15%|interest\s+rate|subvention)\b",
        r"\b(calculator|emi|financial\s+calculator|monthly\s+payment|repay|tenure)\b",
        r"\b(partner|locator|dic|district\s+industr|bank|branch|office|handhold)\b",
        r"\b(eligib\w*|qualif\w*|criteria|apply|application|process|steps|sanction|disburse)\b",
        r"\b(business|enterprise|startup|micro|shop|bakery|tailor|artisan|craft|manufactur|service|trading)\b",
        r"\b(loan|funding|fund|capital|project\s+report|dpr|investment|cost|lakh|crore)\b"
    ]

    GREETING_PATTERNS = [
        r"^(hi|hello|hey|namaste|vanakkam|namaskara|namaskaram|good\s+morning|good\s+afternoon|good\s+evening|greetings)[\s!.]*$",
        r"^(who\s+are\s+you|what\s+can\s+you\s+do|how\s+can\s+you\s+help|what\s+is\s+schememate)[\s?!.]*$"
    ]

    @classmethod
    def is_out_of_domain(cls, user_message: str) -> bool:
        """Determines if the user's question is apart from the website/schemes."""
        msg = user_message.lower().strip()
        
        # Check if query matches pure greetings
        for pattern in cls.GREETING_PATTERNS:
            if re.search(pattern, msg):
                return False

        has_in_domain = any(re.search(pat, msg) for pat in cls.IN_DOMAIN_PATTERNS)
        has_out_of_domain = any(re.search(pat, msg) for pat in cls.OUT_OF_DOMAIN_PATTERNS)

        if has_out_of_domain and not has_in_domain:
            return True

        # If it doesn't match in-domain and is longer than a short phrase, treat as out of domain
        if not has_in_domain and len(msg.split()) >= 3:
            return True

        return False

    @classmethod
    def get_guardrail_message(cls, lang: str = "en") -> str:
        """Returns the polite disclaimer directing the user to ask about the website."""
        lang_code = (lang or "en").lower()[:2]
        return cls.GUARDRAIL_RESPONSES.get(lang_code, cls.GUARDRAIL_RESPONSES["en"])

    @classmethod
    def generate_chatgpt_response(
        cls,
        user_message: str,
        user_profile: Dict[str, Any],
        preferred_language: str = "en",
        conversation_history: Optional[List[Dict[str, str]]] = None
    ) -> Dict[str, Any]:
        """
        Generate conversational guidance using Gen AI (OpenAI API when key is available,
        or our conversational Gen AI engine with human persona and domain guardrails).
        """
        lang = (preferred_language or "en").lower()[:2]

        # 1. Fast domain check
        if cls.is_out_of_domain(user_message):
            return {
                "success": True,
                "reply": cls.get_guardrail_message(lang),
                "provider": "genai_domain_guardrail",
                "is_guardrail": True
            }

        # 2. Check for OpenAI API configuration
        api_key = os.getenv("OPENAI_API_KEY")
        if api_key and not api_key.startswith("your_") and len(api_key) > 20:
            try:
                from openai import OpenAI
                client = OpenAI(api_key=api_key)

                system_prompt = (
                    "You are SchemeMate AI Assistant, a warm, kind, and empathetic human-like advisor for the SchemeMate AI platform.\n"
                    "Your role is to guide Indian micro-entrepreneurs on government schemes, subsidies, loans, and navigating our website.\n\n"
                    "USER PROFILE CONTEXT:\n"
                    f"- Full Name: {user_profile.get('full_name', 'Entrepreneur')}\n"
                    f"- Location: {user_profile.get('district', '')}, {user_profile.get('state', 'India')}\n"
                    f"- Category: {user_profile.get('category', 'General')}\n"
                    f"- Business Type: {user_profile.get('business_type', 'Micro Enterprise')}\n"
                    f"- Annual Income: ₹{user_profile.get('annual_income', 'N/A')}\n"
                    f"- Funding Requirement: ₹{user_profile.get('funding_requirement', 'N/A')}\n\n"
                    "WEBSITE FEATURES & SCHEME KNOWLEDGE:\n"
                    "1. OCR Document Scanner: Users can click 'Scan Document' at the top of the dashboard to upload Aadhaar, PAN card, or Income certificate. "
                    "The AI automatically extracts text and populates their profile without manual typing.\n"
                    "2. PMEGP (Prime Minister's Employment Generation Programme): Provides 15% to 35% margin money government subsidy. "
                    "Rural special categories (Women, SC, ST, OBC, Minorities, Ex-servicemen, PH) get 35% subsidy (beneficiary contributes only 5%). "
                    "Urban special categories get 25%. General category gets 25% rural, 15% urban. Limits: ₹50 Lakhs manufacturing, ₹20 Lakhs service.\n"
                    "3. PM MUDRA Yojana: Collateral-free micro loans: Shishu (up to ₹50,000), Kishore (₹50,000 to ₹5 Lakhs), Tarun (₹5 Lakhs to ₹10/20 Lakhs).\n"
                    "4. PM Vishwakarma: For 18 traditional artisan trades (tailors, carpenters, blacksmiths, etc.). Offers ₹15,000 toolkit voucher, 5-7 days skill training with ₹500/day stipend, and 5% interest loan up to ₹3 Lakhs without collateral.\n"
                    "5. Financial Calculator: Interactive tool to compute upfront government subsidy deductions, net bank loan, and exact monthly EMI schedules.\n"
                    "6. Partner Locator: Maps nearest District Industries Centres (DIC), MSME offices, and bank branches for physical document verification and handholding.\n\n"
                    "CRITICAL GUARDRAIL:\n"
                    "You are strictly an assistant for SchemeMate AI and government entrepreneurship schemes. "
                    "If the user asks ANY question apart from the website or government schemes (such as programming, cricket/sports, movies, weather, general trivia, recipes, games, math homework, general news, etc.), "
                    "DO NOT answer that question. Instead, reply politely like a human: "
                    f"'{cls.get_guardrail_message(lang)}'\n\n"
                    "BEHAVIOR RULES:\n"
                    "- Speak naturally, conversationally, and empathetically like a caring human mentor.\n"
                    "- Directly answer what the user asked with clear, relevant, and actionable advice.\n"
                    f"- Respond in the language: {preferred_language}."
                )

                messages = [{"role": "system", "content": system_prompt}]
                if conversation_history:
                    for msg in conversation_history[-6:]:
                        messages.append({"role": msg.get("role", "user"), "content": msg.get("content", "")})
                messages.append({"role": "user", "content": user_message})

                response = client.chat.completions.create(
                    model=os.getenv("OPENAI_MODEL", "gpt-4o-mini"),
                    messages=messages,
                    max_tokens=600,
                    temperature=0.7
                )
                reply = response.choices[0].message.content or ""
                return {"success": True, "reply": reply.strip(), "provider": "openai_chatgpt"}
            except Exception as e:
                logger.warning(f"OpenAI API call failed: {e}. Falling back to internal conversational engine.")

        # 3. Conversational Gen AI Engine (Human-Like, Empathetic, Relevant)
        reply = cls._generate_conversational_response(user_message, user_profile, lang)
        return {
            "success": True,
            "reply": reply,
            "provider": "genai_conversational_engine"
        }

    @classmethod
    def _generate_conversational_response(
        cls,
        user_message: str,
        user_profile: Dict[str, Any],
        lang: str = "en"
    ) -> str:
        """
        Conversational engine that generates direct, human-like, empathetic answers
        for all in-domain queries regarding SchemeMate AI and government schemes.
        """
        msg = user_message.lower().strip()
        user_name = user_profile.get("full_name") or "there"
        state = user_profile.get("state") or "India"
        category = user_profile.get("category") or "General"
        business_type = user_profile.get("business_type") or "enterprise"
        funding_req = user_profile.get("funding_requirement")

        # 1. Greeting
        if any(re.search(pat, msg) for pat in cls.GREETING_PATTERNS) or msg in ["hi", "hello", "hey"]:
            if lang == "ta":
                return (
                    f"வணக்கம் {user_name}! 🙏 நான் உங்கள் SchemeMate AI உதவி முகவர். "
                    "நமது இணையதளத்தின் OCR ஆவண ஸ்கேனர், 35% வரை PMEGP அரசு மானியம், முத்ரா கடன்கள், "
                    "கடன் தவணை கணிப்பான் (EMI Calculator) மற்றும் அருகிலுள்ள DIC அலுவலக வழிகாட்டுதல்களைப் பெற நான் உங்களுக்கு உதவ முடியும்.\n\n"
                    "இன்று உங்கள் தொழிலுக்கு என்ன உதவி தேவை? கீழே கேளுங்கள்!"
                )
            elif lang == "hi":
                return (
                    f"नमस्ते {user_name}! 🙏 मैं आपका SchemeMate AI सहायक हूँ। "
                    "मैं आपको हमारी वेबसाइट के OCR दस्तावेज़ स्कैनर, 35% PMEGP सरकारी सब्सिडी, मुद्रा ऋण, "
                    "वित्तीय कैलकुलेटर और आपके नजदीकी DIC कार्यालय के बारे में पूरी जानकारी दे सकता हूँ।\n\n"
                    "आज मैं आपके व्यवसाय के लिए क्या सहायता कर सकता हूँ?"
                )
            else:
                return (
                    f"Hello {user_name}! 👋 I am your SchemeMate AI Assistant. "
                    "I'm here to guide you step-by-step through our website features, government subsidies, and loan schemes. "
                    "You can ask me about:\n"
                    "• **OCR Document Scanner**: Auto-filling your profile with Aadhaar/PAN\n"
                    "• **35% PMEGP Margin Money Subsidy**: How to claim maximum government grant\n"
                    "• **PM MUDRA & PM Vishwakarma Loans**: Collateral-free funding up to ₹10-20 Lakhs\n"
                    "• **Financial & EMI Calculator**: Estimating your monthly repayment\n"
                    "• **Partner Locator**: Finding your local District Industries Centre (DIC)\n\n"
                    "What would you like to explore today?"
                )

        # 2. OCR / Document Scan
        if any(k in msg for k in ["ocr", "scan", "document", "upload", "aadhaar", "pan card", "camera"]):
            if lang == "ta":
                return (
                    "எங்கள் இணையதளத்தில் உங்கள் சுயவிவரத்தை தட்டச்சு செய்யாமல் எளிதாக நிரப்பலாம்!\n\n"
                    "1. முகப்பு பக்கத்தின் மேலே உள்ள **'Scan Document'** பொத்தானை கிளிக் செய்யவும்.\n"
                    "2. உங்கள் ஆதார் அட்டை, பான் கார்டு அல்லது வருமானச் சான்றிதழின் புகைப்படத்தை பதிவேற்றவும்.\n"
                    "3. எங்களது AI தொழில்நுட்பம் உங்கள் பெயர், பிறந்த தேதி, முகவரி மற்றும் தகுதி விவரங்களை தானாகவே படித்து உங்கள் சுயவிவரத்தில் பூர்த்தி செய்துவிடும்!"
                )
            elif lang == "hi":
                return (
                    "आप बिना टाइप किए आसानी से अपनी प्रोफ़ाइल भर सकते हैं!\n\n"
                    "1. डैशबोर्ड के शीर्ष पर स्थित **'Scan Document'** बटन पर क्लिक करें।\n"
                    "2. अपने आधार कार्ड, पैन कार्ड या आय प्रमाण पत्र की फोटो अपलोड करें।\n"
                    "3. हमारा AI स्वचालित रूप से आपका नाम, पता और श्रेणी पढ़कर आपकी प्रोफ़ाइल में दर्ज कर देगा!"
                )
            else:
                return (
                    "You can save time and avoid manual typing using our **OCR Document Scanner**! 📄✨\n\n"
                    "**How to use it:**\n"
                    "1. Click the **'Scan Document'** button at the top of your dashboard.\n"
                    "2. Upload a clear photo or PDF of your **Aadhaar Card, PAN Card, or Income Certificate**.\n"
                    "3. Our AI instantly extracts your name, age, district, and business category, automatically updating your entrepreneur profile in seconds!\n\n"
                    "Once scanned, your eligibility scores for all top government schemes will update automatically."
                )

        # 3. PMEGP / 35% Margin Money Subsidy
        if any(k in msg for k in ["pmegp", "subsidy", "35%", "margin money", "grant"]):
            if lang == "ta":
                return (
                    "**PMEGP (பிரதமரின் வேலைவாய்ப்பு உருவாக்கும் திட்டம்)** மூலம் நீங்கள் 35% வரை அரசு மானியம் பெறலாம்!\n\n"
                    "• **கிராமப்புற சிறப்பு பிரிவினர் (பெண்கள், SC/ST, OBC, சிறுபான்மையினர்)**: 35% அரசு மானியம் (உங்கள் பங்களிப்பு வெறும் 5%).\n"
                    "• **நகர்ப்புற சிறப்பு பிரிவினர்**: 25% மானியம் (உங்கள் பங்களிப்பு 10%).\n"
                    "• **பொதுப் பிரிவு**: கிராமப்புறம் 25%, நகர்ப்புறம் 15%.\n"
                    "• **திட்ட வரம்பு**: உற்பத்தித் தொழில்களுக்கு ₹50 லட்சம் வரை, சேவைத் தொழில்களுக்கு ₹20 லட்சம் வரை.\n\n"
                    "உங்கள் சரியான தவணை மற்றும் மானியக் கழிவை கணக்கிட எங்கள் **Financial Calculator** அம்சத்தைப் பயன்படுத்தலாம்!"
                )
            elif lang == "hi":
                return (
                    "**PMEGP (प्रधानमंत्री रोजगार सृजन कार्यक्रम)** के तहत आपको 35% तक सरकारी सब्सिडी (मार्जिन मनी) मिल सकती है!\n\n"
                    "• **ग्रामीण क्षेत्र एवं विशेष वर्ग (महिलाएं, SC/ST, OBC, अल्पसंख्यक)**: 35% सब्सिडी (आपका योगदान केवल 5%)।\n"
                    "• **शहरी क्षेत्र एवं विशेष वर्ग**: 25% सब्सिडी (आपका योगदान 10%)।\n"
                    "• **सामान्य वर्ग**: ग्रामीण क्षेत्र में 25%, शहरी क्षेत्र में 15%।\n"
                    "• **परियोजना सीमा**: विनिर्माण (Manufacturing) के लिए ₹50 लाख तक और सेवा क्षेत्र (Service) के लिए ₹20 लाख तक।\n\n"
                    "अपनी सटीक EMI और सब्सिडी जानने के लिए हमारे **Financial Calculator** का उपयोग करें!"
                )
            else:
                return (
                    "Under the **PMEGP (Prime Minister's Employment Generation Programme)**, you can receive up to a **35% government subsidy** (Margin Money Grant)! 💰\n\n"
                    "**Subsidy Breakdown:**\n"
                    "• **Rural Areas (Special Categories: Women, SC/ST, OBC, Minorities, Ex-servicemen, PH)**: **35% subsidy** (you invest only 5% of project cost).\n"
                    "• **Urban Areas (Special Categories)**: **25% subsidy** (you invest 10%).\n"
                    "• **General Category**: 25% for rural, 15% for urban areas.\n"
                    "• **Maximum Project Size**: Up to ₹50 Lakhs for manufacturing units and up to ₹20 Lakhs for service/business units.\n\n"
                    "💡 *Pro-tip*: Visit our **Financial Calculator** tab on the website to see exactly how much upfront subsidy reduces your loan amount and monthly EMI!"
                )

        # 4. MUDRA Loan
        if any(k in msg for k in ["mudra", "shishu", "kishore", "tarun", "collateral"]):
            if lang == "ta":
                return (
                    "**பிரதான் மந்திரி முத்ரா யோஜனா (PM MUDRA)** சிறு தொழில்களுக்கு பிணையமற்ற (Collateral-Free) கடன் வழங்குகிறது:\n\n"
                    "1. **சிஷு (Shishu)**: ₹50,000 வரை புதிய சிறு தொழில்களுக்கு.\n"
                    "2. **கிஷோர் (Kishore)**: ₹50,000 முதல் ₹5 லட்சம் வரை உபகரணங்கள் வாங்க.\n"
                    "3. **தருண் (Tarun)**: ₹5 லட்சம் முதல் ₹10-20 லட்சம் வரை வளர்ந்த நிறுவனங்களுக்கு.\n\n"
                    "இதற்கு எந்தவித மூன்றாம் நபர் உத்தரவாதமும் அல்லது அடமானமும் தேவையில்லை!"
                )
            elif lang == "hi":
                return (
                    "**प्रधानमंत्री मुद्रा योजना (PM MUDRA)** छोटे व्यवसायों के लिए बिना किसी गारंटी (Collateral-Free) के ऋण प्रदान करती है:\n\n"
                    "1. **शिशु (Shishu)**: ₹50,000 तक (छोटे दुकानदारों और नए काम के लिए)।\n"
                    "2. **किशोर (Kishore)**: ₹50,000 से ₹5 लाख तक (मशीनरी या व्यवसाय विस्तार के लिए)।\n"
                    "3. **तरुण (Tarun)**: ₹5 लाख से ₹10 लाख (₹20 लाख तक विस्तारित) स्थापित उद्योगों के लिए।\n\n"
                    "इसके लिए किसी भी संपार्श्विक (Collateral) की आवश्यकता नहीं होती!"
                )
            else:
                return (
                    "The **PM MUDRA Yojana** provides collateral-free institutional credit to micro and small enterprises! 🤝\n\n"
                    "**Three Loan Categories:**\n"
                    "1. **Shishu**: Loans up to **₹50,000** (ideal for start-up street vendors, micro-shops, and home ventures).\n"
                    "2. **Kishore**: Loans from **₹50,000 to ₹5 Lakhs** (for purchasing equipment, machinery, or raw materials).\n"
                    "3. **Tarun**: Loans from **₹5 Lakhs up to ₹10 Lakhs** (extendable to ₹20 Lakhs for established enterprises).\n\n"
                    "No collateral security or third-party guarantee is required. You can apply through any commercial bank, RRB, or MFI!"
                )

        # 5. PM Vishwakarma
        if any(k in msg for k in ["vishwakarma", "artisan", "craft", "toolkit", "15000"]):
            if lang == "ta":
                return (
                    "**PM விஸ்வகர்மா திட்டம்** 18 பாரம்பரிய கைவினைத் தொழிலாளர்களுக்கு (தச்சர், தையல்காரர், கொல்லர், குயவர் போன்றவை) பிரத்யேக நன்மைகளை வழங்குகிறது:\n\n"
                    "• **₹15,000 இலவச கருவித்தொகுப்பு வவுச்சர்** (Toolkit Incentive).\n"
                    "• நாள் ஒன்றுக்கு ₹500 உதவித்தொகையுடன் 5-7 நாட்கள் இலவச திறன் பயிற்சி.\n"
                    "• **5% குறைந்த வட்டியில் பிணையற்ற கடன்**: முதல் கட்டமாக ₹1 லட்சம், இரண்டாம் கட்டமாக ₹2 லட்சம்!\n\n"
                    "விவரங்களுக்கு எங்கள் Partner Locator மூலம் அருகிலுள்ள CSC அல்லது DIC மையத்தை அணுகலாம்."
                )
            elif lang == "hi":
                return (
                    "**पीएम विश्वकर्मा योजना** 18 पारंपरिक कारीगरों और शिल्पकारों (जैसे दर्जी, बढ़ई, लोहार, कुम्हार) के लिए बनाई गई है:\n\n"
                    "• **₹15,000 का मुफ्त टूलकिट ई-वाउचर**।\n"
                    "• ₹500/दिन वजीफे के साथ 5-7 दिनों का बुनियादी कौशल प्रशिक्षण।\n"
                    "• **मात्र 5% ब्याज दर पर बिना गारंटी ऋण**: पहली किस्त में ₹1 लाख और दूसरी किस्त में ₹2 लाख!\n\n"
                    "आप अपने नजदीकी सीएससी या डीआईसी केंद्र के माध्यम से आवेदन कर सकते हैं।"
                )
            else:
                return (
                    "The **PM Vishwakarma Scheme** is designed for traditional artisans and craftspeople across 18 artisan trades (such as carpenters, tailors, blacksmiths, masons, and potters): 🔨🧵\n\n"
                    "**Key Benefits:**\n"
                    "• **₹15,000 Digital Toolkit Incentive**: Provided as an e-voucher to buy modern tools.\n"
                    "• **Skill Training**: 5-7 days of basic training with a **₹500/day stipend**.\n"
                    "• **Subsidized Enterprise Loan**: Up to **₹1 Lakh** (Tranche 1) and **₹2 Lakhs** (Tranche 2) at a concessional interest rate of just **5%** (collateral-free)!\n\n"
                    "You can locate your nearest District Industries Centre using our **Partner Locator** to get verified!"
                )

        # 6. Financial Calculator / EMI
        if any(k in msg for k in ["calculator", "emi", "interest", "repay", "monthly", "tenure"]):
            if lang == "ta":
                return (
                    "எங்கள் **Financial Calculator** அம்சத்தின் மூலம் உங்கள் கடன் திட்டத்தை எளிதாக திட்டமிடலாம்:\n\n"
                    "1. மெனுவில் உள்ள **'Financial Calculator'** பகுதிக்குச் செல்லவும்.\n"
                    "2. உங்கள் திட்ட முதலீட்டுத் தொகையை (Project Cost) உள்ளிடவும்.\n"
                    "3. உங்கள் பிரிவைத் தேர்ந்தெடுத்ததும், அரசு வழங்கும் **மானியம் (35% வரை)** தானாகவே கழிக்கப்பட்டு நிகர கடன் தொகை கணக்கிடப்படும்.\n"
                    "4. நீங்கள் மாதந்தோறும் செலுத்த வேண்டிய துல்லியமான **EMI அட்டவணை** உடனே திரையில் தோன்றும்!"
                )
            elif lang == "hi":
                return (
                    "हमारे **Financial Calculator** की सहायता से आप ऋण लेने से पहले अपनी वित्तीय योजना बना सकते हैं:\n\n"
                    "1. नेविगेशन बार में **'Financial Calculator'** पर क्लिक करें।\n"
                    "2. अपनी कुल अनुमानित परियोजना लागत और ऋण अवधि दर्ज करें।\n"
                    "3. अपनी श्रेणी चुनते ही आपकी **सरकारी सब्सिडी** तुरंत घट जाएगी और शुद्ध ऋण राशि दिखाई देगी।\n"
                    "4. कैलकुलेटर आपकी मासिक **EMI** और ब्याज दर का पूरा शेड्यूल दिखा देगा!"
                )
            else:
                return (
                    "Our **Financial Calculator** helps you plan your business finances with complete clarity! 🧮📊\n\n"
                    "**How it works:**\n"
                    "1. Navigate to the **'Financial Calculator'** tab on SchemeMate AI.\n"
                    "2. Enter your estimated project cost (e.g., ₹5,00,000) and desired loan tenure (e.g., 5 years).\n"
                    "3. Select your category (e.g. Rural Woman, OBC, SC/ST) to automatically deduct up to **35% Government Subsidy**.\n"
                    "4. The calculator instantly generates your **net loan requirement** and monthly **EMI payment schedule**, so you know your exact financial commitment before applying!"
                )

        # 7. Partner Locator / DIC Offices / Banks
        if any(k in msg for k in ["partner", "locator", "dic", "district", "office", "bank branch", "map", "nearest"]):
            if lang == "ta":
                return (
                    "நேரடி ஆவண சரிபார்ப்பு மற்றும் வங்கி விண்ணப்பங்களுக்கு எங்கள் **Partner Locator** உங்களுக்கு வழிகாட்டுகிறது:\n\n"
                    "1. மெனுவில் உள்ள **'Partner Locator'** என்பதை கிளிக் செய்யவும்.\n"
                    "2. உங்கள் மாவட்டம் மற்றும் தாலுகாவில் உள்ள அருகிலுள்ள **மாவட்ட தொழில் மையம் (DIC)** மற்றும் அரசு அங்கீகரிக்கப்பட்ட வங்கி கிளைகளை வரைபடத்தில் பார்க்கலாம்.\n"
                    "3. அங்கு சென்று உங்கள் திட்ட அறிக்கை (DPR) மற்றும் மானிய விண்ணப்பத்தை அதிகாரிகளிடம் நேரடியாக சமர்ப்பிக்கலாம்!"
                )
            elif lang == "hi":
                return (
                    "अपने नजदीकी सहायता केंद्र और बैंक खोजने के लिए **Partner Locator** का उपयोग करें:\n\n"
                    "1. मेनू में **'Partner Locator'** विकल्प चुनें।\n"
                    "2. यह आपके जिले में स्थित **जिला उद्योग केंद्र (DIC)**, MSME कार्यालय और बैंक शाखाओं का नक्शा दिखाता है।\n"
                    "3. आप सीधे इन कार्यालयों में जाकर अपने दस्तावेज सत्यापित करवा सकते हैं और आवेदन जमा कर सकते हैं!"
                )
            else:
                return (
                    "To find physical handholding centers in your area, use our **Partner Locator** feature! 📍🗺️\n\n"
                    "**What you can locate:**\n"
                    "• **District Industries Centres (DIC)**: Official government offices where officers verify your application, offer project guidance, and forward your file for subsidy sanction.\n"
                    "• **MSME Development Institutes**: For project reports, technical mentoring, and entrepreneurship development.\n"
                    "• **Accredited Partner Banks**: Where you can submit your sanctioned loan documents.\n\n"
                    "Click on **'Partner Locator'** in the navigation bar to find the exact addresses and contact details for your district!"
                )

        # 8. Eligibility & Personalized Profile guidance
        if any(k in msg for k in ["eligib", "qualif", "which scheme", "can i get", "my business", "bakery", "shop"]):
            target_funding = f"₹{funding_req}" if funding_req else "your required funding"
            return (
                f"Based on your profile, {user_name} ({category} category in {state}):\n\n"
                f"1. **PMEGP 35% Subsidy**: Since you are registered in {state}, you are eligible for up to a **35% margin money grant** for {business_type}, significantly reducing your loan burden!\n"
                f"2. **PM MUDRA**: Provides collateral-free loans up to ₹10 Lakhs suited for {target_funding}.\n"
                f"3. **PM Vishwakarma / State Incentives**: If you engage in artisanal, manufacturing, or service trades, you also qualify for concessional 5% interest rates.\n\n"
                f"Would you like me to guide you through calculating your monthly EMI or locating your local DIC office?"
            )

        # 9. How to apply / Getting Started
        if any(k in msg for k in ["how to apply", "apply", "process", "steps", "start"]):
            return (
                "Here is your simple 4-step path on SchemeMate AI to secure your government scheme and subsidy: 🚀\n\n"
                "1. **Step 1 - Profile & Document Scan**: Click **'Scan Document'** to auto-fill your profile using Aadhaar/PAN, or update your profile details manually.\n"
                "2. **Step 2 - Scheme Match**: View your personalized eligibility score for central & state schemes (PMEGP, MUDRA, Stand-Up India).\n"
                "3. **Step 3 - Financial Calculator**: Calculate your upfront subsidy deduction (up to 35%) and monthly EMI schedule.\n"
                "4. **Step 4 - Apply & Connect**: Use our **Partner Locator** to visit your nearest DIC office or apply directly on the official government portal (e.g. kviconline / udyamimitra).\n\n"
                "Which step would you like to start with right now?"
            )

        # 10. Default In-Domain Conversational Response
        return (
            f"Hello {user_name}! As your SchemeMate AI advisor, I can guide you through every feature of our platform:\n\n"
            "• **Scan Document**: Use AI to extract your details from Aadhaar/PAN and auto-fill your profile.\n"
            "• **PMEGP Scheme**: Claim up to **35% margin money subsidy** for your business in {state}.\n"
            "• **PM MUDRA Loan**: Access collateral-free micro finance up to ₹10-20 Lakhs.\n"
            "• **Financial Calculator**: Check your monthly EMI and subsidy deductions.\n"
            "• **Partner Locator**: Discover your nearest District Industries Centre (DIC) and partner banks.\n\n"
            "How can I assist you with your business goals today?"
        )
