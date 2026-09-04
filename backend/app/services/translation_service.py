import logging
import re
from typing import Dict, Any, List

logger = logging.getLogger(__name__)

# Comprehensive Multilingual Translation Registry for Scheme Details across Indian Languages
TRANSLATIONS: Dict[str, Dict[str, str]] = {
    'ta': {
        # Chip Messages & Eligibility Rules
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

        # Scheme Benefits & Descriptions
        "Loan from Rs. 5,00,001 to Rs. 10,00,000.": "ரூ. 5,00,001 முதல் ரூ. 10,00,000 வரை கடன் உதவி.",
        "Loan from Rs. 50,001 up to Rs. 5,00,000 without requirement of collateral security.": "பிணைய உத்தரவாதம் இன்றி ரூ. 50,001 முதல் ரூ. 5,00,000 வரை கடன் உதவி.",
        "Loans up to Rs. 50,000 without collateral at affordable interest rates.": "பிணைய உத்தரவாதம் இன்றி குறைந்த வட்டியில் ரூ. 50,000 வரை சிறு கடன்.",
        "Subsidy of 15% to 35% of project cost up to Rs. 50 Lakhs for manufacturing and Rs. 20 Lakhs for service sector.": "உற்பத்தித் துறைக்கு ரூ. 50 லட்சம் மற்றும் சேவைத் துறைக்கு ரூ. 20 லட்சம் வரை 15% முதல் 35% வரை மானியம்.",
        "Bank loan between Rs. 10 Lakhs and Rs. 1 Crore for setting up a greenfield enterprise.": "புதிய நிறுவனம் தொடங்க ரூ. 10 லட்சம் முதல் ரூ. 1 கோடி வரை வங்கி கடன்.",
        "Rs. 15,000 toolkit digital voucher, 5-7 days basic training with Rs. 500/day stipend, collateral-free loan of Rs. 1 Lakh (Tranche 1) and Rs. 2 Lakh (Tranche 2) at 5% interest rate.": "ரூ. 15,000 கருவித்தொகுப்பு டிஜிட்டல் வவுச்சர், நாள் ஒன்றுக்கு ரூ. 500 ஊக்கத்தொகையுடன் 5-7 நாட்கள் பயிற்சி, பிணையமற்ற கடன் ரூ. 1 லட்சம் மற்றும் ரூ. 2 லட்சம் 5% வட்டியில்.",
        "Working capital loan of Rs. 10,000 (1st tranche), Rs. 20,000 (2nd tranche), and Rs. 50,000 (3rd tranche) with 7% interest subsidy and cashback on digital transactions.": "ரூ. 10,000, ரூ. 20,000 மற்றும் ரூ. 50,000 வரை 7% வட்டி மானியத்துடன் நடைமுறை மூலதனக் கடன் உதவி.",
        "Collateral-free credit facility up to Rs. 5 Crore with guarantee cover up to 85% for women/SC/ST/Aspirations districts.": "பெண்கள்/SC/ST தொழில்முனைவோருக்கு 85% வரை உத்தரவாதத்துடன் ரூ. 5 கோடி வரை பிணையமற்ற கடன் வசதி.",

        # Target Beneficiaries / Eligibility Summaries
        "Suitable for Growing small business owners and commercial units in All India": "அனைத்து இந்தியாவிலும் வளர்ச்சி அடையும் சிறு தொழில் உரிமையாளர்களுக்கு ஏற்றது.",
        "Suitable for Existing micro-enterprises seeking growth capital in All India": "அனைத்து இந்தியாவிலும் வளர்ச்சி நிதி தேடும் குறு நிறுவனங்களுக்கு ஏற்றது.",
        "Suitable for Micro entrepreneurs, shopkeepers, artisans, street vendors in All India": "குறு தொழில்முனைவோர், கடைக்காரர்கள், கைவினைஞர்களுக்கு ஏற்றது.",
        "Suitable for Individuals, SHGs, Institutions, Co-operative Societies in All India": "தனிநபர்கள், சுயஉதவிக் குழுக்கள் மற்றும் கூட்டுறவுச் சங்கங்களுக்கு ஏற்றது.",
        "Suitable for Women Entrepreneurs and SC / ST Entrepreneurs (first-time greenfield project) in All India": "பெண் தொழில்முனைவோர் மற்றும் SC / ST தொழில்முனைவோருக்கு ஏற்றது.",
        "Suitable for Artisans and Craftsmen working with hands and tools in 18 traditional trades in All India": "18 பாரம்பரிய தொழில்களில் கையால் வேலை செய்யும் கைவினைஞர்களுக்கு ஏற்றது.",
        "Suitable for Street vendors, hawkers, roadside shop owners in All India": "தெருவோர வியாபாரிகள் மற்றும் சிறு கடைக்காரர்களுக்கு ஏற்றது.",
        "Suitable for New and existing Micro and Small Enterprises in All India": "புதிய மற்றும் ஏற்கனவே உள்ள குறு மற்றும் சிறு நிறுவனங்களுக்கு ஏற்றது."
    },
    'hi': {
        # Chip Messages & Eligibility Rules
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

        # Scheme Benefits & Descriptions
        "Loan from Rs. 5,00,001 to Rs. 10,00,000.": "रु. 5,00,001 से रु. 10,00,000 तक का ऋण सहायता।",
        "Loan from Rs. 50,001 up to Rs. 5,00,000 without requirement of collateral security.": "बिना किसी गारंटी के रु. 50,001 से रु. 5,00,000 तक का ऋण।",
        "Loans up to Rs. 50,000 without collateral at affordable interest rates.": "बिना गारंटी के किफायती दरों पर रु. 50,000 तक का ऋण।",
        "Subsidy of 15% to 35% of project cost up to Rs. 50 Lakhs for manufacturing and Rs. 20 Lakhs for service sector.": "विनिर्माण के लिए 50 लाख और सेवा क्षेत्र के लिए 20 लाख रुपये तक 15% से 35% सब्सिडी।",
        "Bank loan between Rs. 10 Lakhs and Rs. 1 Crore for setting up a greenfield enterprise.": "नया उद्यम स्थापित करने के लिए 10 लाख से 1 करोड़ रुपये तक का बैंक ऋण।",
        "Rs. 15,000 toolkit digital voucher, 5-7 days basic training with Rs. 500/day stipend, collateral-free loan of Rs. 1 Lakh (Tranche 1) and Rs. 2 Lakh (Tranche 2) at 5% interest rate.": "रु. 15,000 टूलकिट वाउचर, रु. 500/दिन वजीफे के साथ प्रशिक्षण, 5% ब्याज दर पर 1 लाख और 2 लाख का ऋण।",
        "Working capital loan of Rs. 10,000 (1st tranche), Rs. 20,000 (2nd tranche), and Rs. 50,000 (3rd tranche) with 7% interest subsidy and cashback on digital transactions.": "7% ब्याज सब्सिडी के साथ रु. 10,000, 20,000 और 50,000 का कार्यशील पूंजी ऋण।",
        "Collateral-free credit facility up to Rs. 5 Crore with guarantee cover up to 85% for women/SC/ST/Aspirations districts.": "महिलाओं/SC/ST के लिए 85% गारंटी के साथ रु. 5 करोड़ तक की गारंटी-मुक्त ऋण सुविधा।",

        # Target Beneficiaries
        "Suitable for Growing small business owners and commercial units in All India": "पूरे भारत में बढ़ते छोटे व्यवसाय मालिकों और वाणिज्यिक इकाइयों के लिए उपयुक्त।",
        "Suitable for Existing micro-enterprises seeking growth capital in All India": "पूरे भारत में विकास पूंजी चाहने वाले मौजूदा सूक्ष्म उद्यमों के लिए उपयुक्त।",
        "Suitable for Micro entrepreneurs, shopkeepers, artisans, street vendors in All India": "सूक्ष्म उद्यमियों, दुकानदारों, कारीगरों, स्ट्रीट वेंडरों के लिए उपयुक्त।",
        "Suitable for Individuals, SHGs, Institutions, Co-operative Societies in All India": "व्यक्तियों, स्वयं सहायता समूहों और सहकारी समितियों के लिए उपयुक्त।",
        "Suitable for Women Entrepreneurs and SC / ST Entrepreneurs (first-time greenfield project) in All India": "महिला उद्यमियों और एससी/एसटी उद्यमियों के लिए उपयुक्त।",
        "Suitable for Artisans and Craftsmen working with hands and tools in 18 traditional trades in All India": "18 पारंपरिक व्यवसायों में काम करने वाले कारीगरों और शिल्पकारों के लिए उपयुक्त।",
        "Suitable for Street vendors, hawkers, roadside shop owners in All India": "स्ट्रीट वेंडरों, फेरीवालों और सड़क किनारे दुकान मालिकों के लिए उपयुक्त।",
        "Suitable for New and existing Micro and Small Enterprises in All India": "नए और मौजूदा सूक्ष्म और छोटे उद्यमों के लिए उपयुक्त।"
    },
    'te': {
        "Minimum age criterion met": "కనీస వయస్సు నిబంధన పూర్తయింది",
        "State eligibility matched": "రాష్ట్ర అర్హత సరిపోలింది",
        "Scheme operates in your region": "మీ ప్రాంతంలో ఈ పథకం అందుబాటులో ఉంది",
        "Business sector eligible": "వ్యాపార రంగం అర్హత పొందింది",
        "Matches your funding requirement": "మీ నిధుల అవసరానికి సరిపోలుతుంది",
        "Ministry of Finance": "ఆర్థిక మంత్రిత్వ శాఖ",
        "Ministry of Micro, Small and Medium Enterprises": "సూక్ష్మ, చిన్న మరియు మధ్య తరహా పరిశ్రమల మంత్రిత్వ శాఖ",
        "Open Year-Round": "ఏడాది పొడవునా తెరిచి ఉంటుంది",
        "31 Dec 2026 (Open Year-Round)": "31 డిసెంబర్ 2026 (ఏడాది పొడవునా లభ్యం)",
        "Loan from Rs. 5,00,001 to Rs. 10,00,000.": "రూ. 5,00,001 నుండి రూ. 10,00,000 వరకు రుణం.",
        "Loan from Rs. 50,001 up to Rs. 5,00,000 without requirement of collateral security.": "పూచీకత్తు లేకుండా రూ. 50,001 నుండి రూ. 5,00,000 వరకు రుణం.",
        "Suitable for Growing small business owners and commercial units in All India": "భారతదేశవ్యాప్తంగా అభివృద్ధి చెందుతున్న చిన్న వ్యాపార యజమానులకు అనుకూలం.",
        "Suitable for Existing micro-enterprises seeking growth capital in All India": "అభివృద్ధి మూలధనం కోరుకునే సూక్ష్మ పరిశ్రమలకు అనుకూలం."
    },
    'kn': {
        "Minimum age criterion met": "ಕನಿಷ್ಠ ವಯಸ್ಸಿನ ಮಾನದಂಡ ಪೂರೈಸಲಾಗಿದೆ",
        "State eligibility matched": "ರಾಜ್ಯದ ಅರ್ಹತೆ ಹೊಂದಾಣಿಕೆಯಾಗಿದೆ",
        "Scheme operates in your region": "ನಿಮ್ಮ ಪ್ರದೇಶದಲ್ಲಿ ಈ ಯೋಜನೆ ಲಭ್ಯವಿದೆ",
        "Business sector eligible": "ವ್ಯಾಪಾರ ಕ್ಷೇತ್ರವು ಅರ್ಹವಾಗಿದೆ",
        "Matches your funding requirement": "ನಿಮ್ಮ ಹಣಕಾಸಿನ ಅಗತ್ಯಕ್ಕೆ ಸೂಕ್ತವಾಗಿದೆ",
        "Ministry of Finance": "ಹಣಕಾಸು ಸಚಿವಾಲಯ",
        "Ministry of Micro, Small and Medium Enterprises": "ಸೂಕ್ಷ್ಮ, ಸಣ್ಣ ಮತ್ತು ಮಧ್ಯಮ ಉದ್ಯಮಗಳ ಸಚಿವಾಲಯ",
        "Open Year-Round": "ವರ್ಷಪೂರ್ತಿ ಲಭ್ಯವಿದೆ",
        "31 Dec 2026 (Open Year-Round)": "31 ಡಿಸೆಂಬರ್ 2026 (ವರ್ಷಪೂರ್ತಿ ಲಭ್ಯವಿದೆ)",
        "Loan from Rs. 5,00,001 to Rs. 10,00,000.": "ರೂ. 5,00,001 ರಿಂದ ರೂ. 10,00,000 ವರೆಗೆ ಸಾಲ ಸಹಾಯ.",
        "Loan from Rs. 50,001 up to Rs. 5,00,000 without requirement of collateral security.": "ಶ್ಯೂರಿಟಿ ಇಲ್ಲದೆ ರೂ. 50,001 ರಿಂದ ರೂ. 5,00,000 ವರೆಗೆ ಸಾಲ.",
        "Suitable for Growing small business owners and commercial units in All India": "ಬೆಳೆಯುತ್ತಿರುವ ಸಣ್ಣ ಉದ್ಯಮಿಗಳಿಗೆ ಸೂಕ್ತವಾಗಿದೆ.",
        "Suitable for Existing micro-enterprises seeking growth capital in All India": "ಬೆಳವಣಿಗೆಯ ಬಂಡವಾಳ ಬಯಸುವ ಸೂಕ್ಷ್ಮ ಉದ್ಯಮಗಳಿಗೆ ಸೂಕ್ತವಾಗಿದೆ."
    },
    'ml': {
        "Minimum age criterion met": "കുറഞ്ഞ പ്രായപരിധി യോഗ്യത നേടി",
        "State eligibility matched": "സംസ്ഥാന യോഗ്യത പൊരുത്തപ്പെട്ടു",
        "Scheme operates in your region": "നിങ്ങളുടെ പ്രദേശത്ത് ഈ പദ്ധതി ലഭ്യമാണ്",
        "Business sector eligible": "ബിസിനസ്സ് മേഖല യോഗ്യമാണ്",
        "Matches your funding requirement": "നിങ്ങളുടെ ധനസഹായ ആവശ്യത്തിന് അനുയോജ്യമാണ്",
        "Ministry of Finance": "ധനകാര്യ മന്ത്രാലയം",
        "Ministry of Micro, Small and Medium Enterprises": "മൈക്രോ, സ്മോൾ ആൻഡ് മീഡിയം എന്റർപ്രൈസസ് മന്ത്രാലയം",
        "Open Year-Round": "വർഷം മുഴുവൻ ലഭ്യമാണ്",
        "31 Dec 2026 (Open Year-Round)": "31 ഡിസംബർ 2026 (വർഷം മുഴുവൻ ലഭ്യമാണ്)",
        "Loan from Rs. 5,00,001 to Rs. 10,00,000.": "രൂപ 5,00,001 മുതൽ 10,00,000 രൂപ വരെ വായ്പ ധനസഹായം.",
        "Loan from Rs. 50,001 up to Rs. 5,00,000 without requirement of collateral security.": "ഈടില്ലാതെ 50,001 മുതൽ 5,00,000 രൂപ വരെ വായ്പ.",
        "Suitable for Growing small business owners and commercial units in All India": "വളർന്നുവരുന്ന ചെറുകിട സംരംഭകർക്ക് അനുയോജ്യം.",
        "Suitable for Existing micro-enterprises seeking growth capital in All India": "വളർച്ചാ മൂലധനം ആഗ്രഹിക്കുന്ന സംരംഭങ്ങൾക്ക് അനുയോജ്യം."
    },
    'mr': {
        "Minimum age criterion met": "किमान वयोमर्यादा पूर्ण",
        "State eligibility matched": "राज्य पात्रता जुळली",
        "Scheme operates in your region": "तुमच्या क्षेत्रात योजना कार्यरत आहे",
        "Business sector eligible": "व्यवसाय क्षेत्र पात्र आहे",
        "Ministry of Finance": "वित्त मंत्रालय",
        "Ministry of Micro, Small and Medium Enterprises": "सूक्ष्म, लघु आणि मध्यम उद्यम मंत्रालय",
        "Open Year-Round": "वर्षभर उघडे",
        "31 Dec 2026 (Open Year-Round)": "31 डिसेंबर 2026 (वर्षभर उघडे)",
        "Loan from Rs. 5,00,001 to Rs. 10,00,000.": "रु. 5,00,001 ते रु. 10,00,000 पर्यंत कर्ज सहाय्य.",
        "Loan from Rs. 50,001 up to Rs. 5,00,000 without requirement of collateral security.": "विनातारण रु. 50,001 ते रु. 5,00,000 पर्यंत कर्ज.",
        "Suitable for Growing small business owners and commercial units in All India": "वाढत्या लहान व्यवसाय मालकांसाठी योग्य.",
        "Suitable for Existing micro-enterprises seeking growth capital in All India": "विकास भांडवल शोधणाऱ्या सूक्ष्म उपक्रमांसाठी योग्य."
    },
    'bn': {
        "Minimum age criterion met": "নূন্যতম বয়স মাপকাঠি পূরণ হয়েছে",
        "State eligibility matched": "রাজ্যের যোগ্যতা মিলেছে",
        "Scheme operates in your region": "আপনার অঞ্চলে এই প্রকল্প চালু আছে",
        "Business sector eligible": "ব্যবসা খাত যোগ্য",
        "Ministry of Finance": "অর্থ মন্ত্রণালয়",
        "Ministry of Micro, Small and Medium Enterprises": "ক্ষুদ্র, ছোট ও মাঝারি শিল্প মন্ত্রণালয়",
        "Open Year-Round": "সারা বছর খোলা",
        "31 Dec 2026 (Open Year-Round)": "31 ডিসেম্বর 2026 (সারা বছর খোলা)",
        "Loan from Rs. 5,00,001 to Rs. 10,00,000.": "৫,০০,০০১ টাকা থেকে ১০,০০,০০০ টাকা পর্যন্ত ঋণ সহায়তা।",
        "Loan from Rs. 50,001 up to Rs. 5,00,000 without requirement of collateral security.": "জামানত ছাড়াই ৫০,০০১ থেকে ৫,০০,০০০ টাকা পর্যন্ত ঋণ।"
    },
    'gu': {
        "Minimum age criterion met": "ન્યૂનતમ વય માનદંડ પૂર્ણ",
        "State eligibility matched": "રાજ્યની પાત્રતા મળી",
        "Scheme operates in your region": "આ યોજના તમારા વિસ્તારમાં કાર્યરત છે",
        "Business sector eligible": "વ્યવસાય ક્ષેત્ર પાત્ર છે",
        "Ministry of Finance": "નાણાં મંત્રાલય",
        "Ministry of Micro, Small and Medium Enterprises": "સૂક્ષ્મ, લઘુ અને મધ્યમ ઉદ્યોગ મંત્રાલય",
        "Open Year-Round": "આખું વર્ષ ખુલ્લું",
        "31 Dec 2026 (Open Year-Round)": "31 ડિસેમ્બર 2026 (આખું વર્ષ ખુલ્લું)",
        "Loan from Rs. 5,00,001 to Rs. 10,00,000.": "રૂ. 5,00,001 થી રૂ. 10,00,000 સુધીની લોન సహాయ."
    }
}


class SchemeTranslator:
    """Utility service to translate scheme output dictionaries into target Indian language."""

    @classmethod
    def translate_text(cls, text: str, lang: str) -> str:
        if not text or lang == 'en':
            return text

        lang_dict = TRANSLATIONS.get(lang, {})
        res = str(text)

        # 1. Exact match in dictionary
        if res in lang_dict:
            return lang_dict[res]

        # 2. Substring replacements from dictionary (sorted by key length descending)
        sorted_keys = sorted(lang_dict.keys(), key=len, reverse=True)
        for key in sorted_keys:
            if key in res:
                res = res.replace(key, lang_dict[key])

        # 3. Clean common English phrase patterns if translated partially
        res = res.replace("(Open Year-Round)", lang_dict.get("Open Year-Round", "(Open Year-Round)"))
        return res

    @classmethod
    def translate_scheme_dict(cls, scheme_dict: Dict[str, Any], lang: str) -> Dict[str, Any]:
        if not lang or lang == 'en':
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
