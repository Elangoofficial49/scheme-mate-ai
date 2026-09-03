import logging
from typing import Dict, Any, List

logger = logging.getLogger(__name__)

# Dictionary for common phrase translations across Indian languages
TRANSLATIONS = {
    'ta': {
        # Chip messages
        "Minimum age criterion met": "குறைந்தபட்ச வயது வரம்பு பூர்த்தியானது",
        "State eligibility matched": "மாநில தகுதி பொருந்தியது",
        "Scheme operates in your region": "உங்கள் பிராந்தியத்தில் இத்திட்டம் செயல்படுகிறது",
        "Business sector eligible": "தொழில் துறை தகுதியானது",
        "Matches your funding requirement": "உங்கள் நிதியுதவி தேவைகளுடன் பொருந்துகிறது",
        "No strict eligibility criteria defined": "கடுமையான தகுதி வரம்புகள் எதுவும் வரையறுக்கப்படவில்லை",
        
        # Ministries
        "Ministry of Finance": "நிதி அமைச்சகம்",
        "Ministry of Micro, Small and Medium Enterprises": "குறு, சிறு மற்றும் நடுத்தர தொழில் அமைச்சகம் (MSME)",
        "Ministry of Housing and Urban Affairs": "வீட்டுவசதி மற்றும் நகர்ப்புற விவகாரங்கள் அமைச்சகம்",
        "Ministry of Agriculture and Farmers Welfare": "வேளாண்மை மற்றும் விவசாயிகள் நல அமைச்சகம்",
        "Ministry of Commerce and Industry": "வர்த்தகம் மற்றும் தொழில்துறை அமைச்சகம்",
        "Ministry of Textiles": "ஜவுளித் துறை அமைச்சகம்",
        
        # Deadlines & Badges
        "Open Year-Round": "ஆண்டு முழுவதும் திறந்திருக்கும்",
        "31 Dec 2026 (Open Year-Round)": "31 டிசம்பர் 2026 (ஆண்டு முழுவதும் திறந்திருக்கும்)",

        # Common scheme descriptions fallback
        "Loan from Rs. 50,001 up to Rs. 5,00,000 without requirement of collateral security.": "பிணைய உத்தரவாதம் இன்றி ரூ. 50,001 முதல் ரூ. 5,00,000 வரை கடன் உதவி.",
        "Suitable for Existing micro-enterprises seeking growth capital in All India": "அனைத்து இந்தியாவிலும் வளர்ச்சி நிதி தேடும் குறு நிறுவனங்களுக்கு ஏற்றது.",
        "Rs. 15,000 toolkit digital voucher, 5-7 days basic training with Rs. 500/day stipend, collateral-free loan of Rs. 1 Lakh (Tranche 1) and Rs. 2 Lakh (Tranche 2) at 5% interest rate.": "ரூ. 15,000 கருவித்தொகுப்பு டிஜிட்டல் வவுச்சர், நாள் ஒன்றுக்கு ரூ. 500 ஊக்கத்தொகையுடன் 5-7 நாட்கள் பயிற்சி, பிணையமற்ற கடன் ரூ. 1 லட்சம் மற்றும் ரூ. 2 லட்சம் 5% வட்டியில்.",
        "Suitable for Artisans and Craftsmen working with hands and tools in 18 traditional trades in All India": "18 பாரம்பரிய தொழில்களில் கையால் வேலை செய்யும் கைவினைஞர்களுக்கு ஏற்றது.",
        "Working capital loan of Rs. 10,000 (1st tranche), Rs. 20,000 (2nd tranche), and Rs. 50,000 (3rd tranche) with 7% interest subsidy and cashback on digital transactions.": "ரூ. 10,000, ரூ. 20,000 மற்றும் ரூ. 50,000 வரை 7% வட்டி மானியத்துடன் நடைமுறை மூலதனக் கடன் உதவி."
    },
    'hi': {
        # Chip messages
        "Minimum age criterion met": "न्यूनतम आयु मानदंड पूरा हुआ",
        "State eligibility matched": "राज्य की पात्रता मेल खाती है",
        "Scheme operates in your region": "यह योजना आपके क्षेत्र में संचालित है",
        "Business sector eligible": "व्यवसाय क्षेत्र पात्र है",
        "Matches your funding requirement": "आपकी फंडिंग आवश्यकता से मेल खाता है",
        "No strict eligibility criteria defined": "कोई सख्त पात्रता मानदंड परिभाषित नहीं है",

        # Ministries
        "Ministry of Finance": "वित्त मंत्रालय",
        "Ministry of Micro, Small and Medium Enterprises": "सूक्ष्म, लघु एवं मध्यम उद्यम मंत्रालय (MSME)",
        "Ministry of Housing and Urban Affairs": "आवास और शहरी कार्य मंत्रालय",
        "Ministry of Agriculture and Farmers Welfare": "कृषि एवं किसान कल्याण मंत्रालय",
        "Ministry of Commerce and Industry": "वाणिज्य एवं उद्योग मंत्रालय",
        "Ministry of Textiles": "कपड़ा मंत्रालय",

        # Deadlines & Badges
        "Open Year-Round": "वर्ष भर खुला",
        "31 Dec 2026 (Open Year-Round)": "31 दिसंबर 2026 (वर्ष भर खुला)",

        # Common scheme descriptions fallback
        "Loan from Rs. 50,001 up to Rs. 5,00,000 without requirement of collateral security.": "बिना किसी गारंटी के रु. 50,001 से रु. 5,00,000 तक का ऋण।",
        "Suitable for Existing micro-enterprises seeking growth capital in All India": "पूरे भारत में विकास पूंजी चाहने वाले मौजूदा सूक्ष्म उद्यमों के लिए उपयुक्त।",
        "Rs. 15,000 toolkit digital voucher, 5-7 days basic training with Rs. 500/day stipend, collateral-free loan of Rs. 1 Lakh (Tranche 1) and Rs. 2 Lakh (Tranche 2) at 5% interest rate.": "रु. 15,000 टूलकिट डिजिटल वाउचर, रु. 500/दिन वजीफे के साथ 5-7 दिनों का बुनियादी प्रशिक्षण, 5% ब्याज दर पर 1 लाख और 2 लाख का गारंटी-मुक्त ऋण।"
    },
    'te': {
        "Minimum age criterion met": "కనీస వయస్సు నిబంధన పూర్తయింది",
        "State eligibility matched": "రాష్ట్ర అర్హత సరిపోలింది",
        "Scheme operates in your region": "మీ ప్రాంతంలో ఈ పథకం అందుబాటులో ఉంది",
        "Business sector eligible": "వ్యాపార రంగం అర్హత పొందింది",
        "Ministry of Finance": "ఆర్థిక మంత్రిత్వ శాఖ",
        "Ministry of Micro, Small and Medium Enterprises": "సూక్ష్మ, చిన్న మరియు మధ్య తరహా పరిశ్రమల మంత్రిత్వ శాఖ",
        "Open Year-Round": "ఏడాది పొడవునా తెరిచి ఉంటుంది",
        "31 Dec 2026 (Open Year-Round)": "31 డిసెంబర్ 2026 (ఏడాది పొడవునా లభ్యం)"
    },
    'kn': {
        "Minimum age criterion met": "ಕನಿಷ್ಠ ವಯಸ್ಸಿನ ಮಾನದಂಡ ಪೂರೈಸಲಾಗಿದೆ",
        "State eligibility matched": "ರಾಜ್ಯದ ಅರ್ಹತೆ ಹೊಂದಾಣಿಕೆಯಾಗಿದೆ",
        "Scheme operates in your region": "ನಿಮ್ಮ ಪ್ರದೇಶದಲ್ಲಿ ಈ ಯೋಜನೆ ಲಭ್ಯವಿದೆ",
        "Business sector eligible": "ವ್ಯಾಪಾರ ಕ್ಷೇತ್ರವು ಅರ್ಹವಾಗಿದೆ",
        "Ministry of Finance": "ಹಣಕಾಸು ಸಚಿವಾಲಯ",
        "Ministry of Micro, Small and Medium Enterprises": "ಸೂಕ್ಷ್ಮ, ಸಣ್ಣ ಮತ್ತು ಮಧ್ಯಮ ಉದ್ಯಮಗಳ ಸಚಿವಾಲಯ",
        "Open Year-Round": "ವರ್ಷಪೂರ್ತಿ ಲಭ್ಯವಿದೆ",
        "31 Dec 2026 (Open Year-Round)": "31 ಡಿಸೆಂಬರ್ 2026 (ವರ್ಷಪೂರ್ತಿ ಲಭ್ಯವಿದೆ)"
    },
    'ml': {
        "Minimum age criterion met": "കുറഞ്ഞ പ്രായപരിധി യോഗ്യത നേടി",
        "State eligibility matched": "സംസ്ഥാന യോഗ്യത പൊരുത്തപ്പെട്ടു",
        "Scheme operates in your region": "നിങ്ങളുടെ പ്രദേശത്ത് ഈ പദ്ധതി ലഭ്യമാണ്",
        "Business sector eligible": "ബിസിനസ്സ് മേഖല യോഗ്യമാണ്",
        "Ministry of Finance": "ധനകാര്യ മന്ത്രാലയം",
        "Ministry of Micro, Small and Medium Enterprises": "മൈക്രോ, സ്മോൾ ആൻഡ് മീഡിയം എന്റർപ്രൈസസ് മന്ത്രാലയം",
        "Open Year-Round": "വർഷം മുഴുവൻ ലഭ്യമാണ്",
        "31 Dec 2026 (Open Year-Round)": "31 ഡിസംബർ 2026 (വർഷം മുഴുവൻ ലഭ്യമാണ്)"
    },
    'mr': {
        "Minimum age criterion met": "किमान वयोमर्यादा पूर्ण",
        "State eligibility matched": "राज्य पात्रता जुळली",
        "Scheme operates in your region": "तुमच्या क्षेत्रात योजना कार्यरत आहे",
        "Business sector eligible": "व्यवसाय क्षेत्र पात्र आहे",
        "Ministry of Finance": "वित्त मंत्रालय",
        "Ministry of Micro, Small and Medium Enterprises": "सूक्ष्म, लघु आणि मध्यम उद्यम मंत्रालय",
        "Open Year-Round": "वर्षभर उघडे",
        "31 Dec 2026 (Open Year-Round)": "31 डिसेंबर 2026 (वर्षभर उघडे)"
    },
    'bn': {
        "Minimum age criterion met": "নূন্যতম বয়স মাপকাঠি পূরণ হয়েছে",
        "State eligibility matched": "রাজ্যের যোগ্যতা মিলেছে",
        "Scheme operates in your region": "আপনার অঞ্চলে এই প্রকল্প চালু আছে",
        "Business sector eligible": "ব্যবসা খাত যোগ্য",
        "Ministry of Finance": "অর্থ মন্ত্রণালয়",
        "Ministry of Micro, Small and Medium Enterprises": "ক্ষুদ্র, ছোট ও মাঝারি শিল্প মন্ত্রণালয়",
        "Open Year-Round": "সারা বছর খোলা",
        "31 Dec 2026 (Open Year-Round)": "31 ডিসেম্বর 2026 (সারা বছর খোলা)"
    },
    'gu': {
        "Minimum age criterion met": "ન્યૂનતમ વય માનદંડ પૂર્ણ",
        "State eligibility matched": "રાજ્યની પાત્રતા મળી",
        "Scheme operates in your region": "આ યોજના તમારા વિસ્તારમાં કાર્યરત છે",
        "Business sector eligible": "વ્યવસાય ક્ષેત્ર પાત્ર છે",
        "Ministry of Finance": "નાણાં મંત્રાલય",
        "Ministry of Micro, Small and Medium Enterprises": "સૂક્ષ્મ, લઘુ અને મધ્યમ ઉદ્યોગ મંત્રાલય",
        "Open Year-Round": "આખું વર્ષ ખુલ્લું",
        "31 Dec 2026 (Open Year-Round)": "31 ડિસેમ્બર 2026 (આખું વર્ષ ખુલ્લું)"
    }
}


class SchemeTranslator:
    """Utility service to translate scheme output dictionaries into target Indian language."""

    @classmethod
    def translate_text(cls, text: str, lang: str) -> str:
        if not text or lang == 'en' or lang not in TRANSLATIONS:
            return text

        lang_dict = TRANSLATIONS.get(lang, {})
        
        # Check exact match
        if text in lang_dict:
            return lang_dict[text]
            
        # Check partial prefix matches for rule chips
        res = text
        for key, val in lang_dict.items():
            if key in text:
                res = res.replace(key, val)
                
        # Clean common English phrase patterns if translated partially
        res = res.replace("(Open Year-Round)", lang_dict.get("Open Year-Round", "(Open Year-Round)"))
        return res

    @classmethod
    def translate_scheme_dict(cls, scheme_dict: Dict[str, Any], lang: str) -> Dict[str, Any]:
        if not lang or lang == 'en' or lang not in TRANSLATIONS:
            return scheme_dict

        translated = dict(scheme_dict)
        
        # Translate ministry
        if "ministry" in translated and translated["ministry"]:
            translated["ministry"] = cls.translate_text(translated["ministry"], lang)
            
        # Translate why_matches chips
        if "why_matches" in translated and isinstance(translated["why_matches"], list):
            translated["why_matches"] = [cls.translate_text(w, lang) for w in translated["why_matches"]]
            
        # Translate key_benefits / benefits / description
        if "key_benefits" in translated and translated["key_benefits"]:
            translated["key_benefits"] = cls.translate_text(translated["key_benefits"], lang)
        if "benefits" in translated and translated["benefits"]:
            translated["benefits"] = cls.translate_text(translated["benefits"], lang)
        if "eligibility_summary" in translated and translated["eligibility_summary"]:
            translated["eligibility_summary"] = cls.translate_text(translated["eligibility_summary"], lang)
        if "description" in translated and translated["description"]:
            translated["description"] = cls.translate_text(translated["description"], lang)
            
        # Translate last_date_to_apply
        if "last_date_to_apply" in translated and translated["last_date_to_apply"]:
            translated["last_date_to_apply"] = cls.translate_text(translated["last_date_to_apply"], lang)
            
        return translated

