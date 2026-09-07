import 'app_localizations.dart';

class SchemeTranslationHelper {
  static String localize(String input, String langCode) {
    if (input.isEmpty || langCode == 'en') return input;
    String res = input;

    // Master replacement dictionary for scheme titles, ministries, benefits, summaries, and why_matches
    final Map<String, Map<String, String>> dict = {
      'hi': {
        "Ministry of Food Processing Industries (MoFPI)": "खाद्य प्रसंस्करण उद्योग मंत्रालय (MoFPI)",
        "Government of Tamil Nadu": "तमिलनाडु सरकार",
        "Government of Uttar Pradesh": "उत्तर प्रदेश सरकार",
        "Government of Maharashtra": "महाराष्ट्र सरकार",
        "Government of Rajasthan": "राजस्थान सरकार",
        "Government of Bihar": "बिहार सरकार",
        "Ministry of Micro, Small and Medium Enterprises": "सूक्ष्म, लघु एवं मध्यम उद्यम मंत्रालय (MSME)",
        "Ministry of Finance": "वित्त मंत्रालय",
        "Ministry of Housing and Urban Affairs": "आवास और शहरी कार्य मंत्रालय",

        "Credit-linked capital subsidy at 35% of eligible project cost up to Rs. 10 Lakhs.": "पात्र परियोजना लागत का 35% (अधिकतम रु. 10 लाख) क्रेडिट-लिंक्ड पूंजी सब्सिडी।",
        "Suitable for Individual micro food processing units, FPOs, SHGs, Producer Co-operatives in All India": "अखिल भारतीय स्तर पर सूक्ष्म खाद्य प्रसंस्करण इकाइयों, FPO, SHG और उत्पादक सहकारी समितियों के लिए उपयुक्त।",
        "25% capital subsidy up to Rs. 75 Lakhs and 3% interest subvention.": "रु. 75 लाख तक 25% पूंजी सब्सिडी और 3% ब्याज अनुदान।",
        "Suitable for First-generation entrepreneurs in Tamil Nadu with Degree/Diploma/ITI in Tamil Nadu": "तमिलनाडु में डिग्री/डिप्लोमा/आईटीआई वाले प्रथम पीढ़ी के उद्यमियों के लिए उपयुक्त।",

        "Subsidy of 15% to 35% of project cost up to Rs. 50 Lakhs for manufacturing and Rs. 20 Lakhs for service sector.": "विनिर्माण के लिए रु. 50 लाख और सेवा क्षेत्र के लिए रु. 20 लाख तक 15% से 35% सब्सिडी।",
        "Loans up to Rs. 50,000 without collateral at affordable interest rates.": "बिना गारंटी के किफायती दरों पर रु. 50,000 तक का ऋण।",
        "Loan from Rs. 50,001 up to Rs. 5,00,000 without requirement of collateral security.": "बिना किसी गारंटी के रु. 50,001 से रु. 5,00,000 तक का ऋण।",
        "Loan from Rs. 5,00,001 to Rs. 10,00,000.": "रु. 5,00,001 से रु. 10,00,000 तक का ऋण सहायता।",
        "Bank loan between Rs. 10 Lakhs and Rs. 1 Crore for setting up a greenfield enterprise.": "नया उद्यम शुरू करने के लिए रु. 10 लाख से रु. 1 करोड़ तक का बैंक ऋण।",
        "Rs. 15,000 toolkit digital voucher, 5-7 days basic training with Rs. 500/day stipend, collateral-free loan of Rs. 1 Lakh (Tranche 1) and Rs. 2 Lakh (Tranche 2) at 5% interest rate.": "रु. 15,000 टूलकिट वाउचर, 5-7 दिन का प्रशिक्षण, 5% ब्याज पर रु. 3 लाख तक का ऋण।",
        "Working capital loan of Rs. 10,00,000 (1st tranche), Rs. 20,000 (2nd tranche), and Rs. 50,000 (3rd tranche) with 7% interest subsidy and cashback on digital transactions.": "7% ब्याज सब्सिडी के साथ कार्यशील पूंजी ऋण।",
        "Working capital loan of Rs. 10,000 (1st tranche), Rs. 20,000 (2nd tranche), and Rs. 50,000 (3rd tranche) with 7% interest subsidy and cashback on digital transactions.": "7% ब्याज सब्सिडी के साथ रु. 10,000 का कार्यशील पूंजी ऋण।",
        "Collateral-free credit facility up to Rs. 5 Crore with guarantee cover up to 85% for women/SC/ST/Aspirations districts.": "महिलाओं/SC/ST के लिए 85% गारंटी के साथ रु. 5 करोड़ तक की गारंटी-मुक्त ऋण सुविधा।",
        "GOI grant up to 30% of total project cost evaluated by lending bank.": "बैंक द्वारा मूल्यांकित कुल परियोजना लागत का 30% तक सरकारी अनुदान।",

        "Minimum age criterion met": "न्यूनतम आयु मानदंड पूरा हुआ",
        "Maximum age criterion met": "अधिकतम आयु मानदंड पूरा हुआ",
        "Business sector eligible": "व्यवसाय क्षेत्र पात्र है",
        "Scheme operates in your region": "यह योजना आपके क्षेत्र में संचालित है",
        "State eligibility matched": "राज्य की पात्रता मेल खाती है",
        "Matches your funding requirement": "आपकी फंडिंग आवश्यकता से मेल खाता है"
      },
      'ta': {
        "Ministry of Food Processing Industries (MoFPI)": "உணவு பதப்படுத்தும் தொழில்கள் அமைச்சகம் (MoFPI)",
        "Government of Tamil Nadu": "தமிழ்நாடு அரசு",
        "Government of Uttar Pradesh": "உத்தரப் பிரதேச அரசு",
        "Government of Maharashtra": "மகாராஷ்டிர அரசு",
        "Government of Rajasthan": "ராஜஸ்தான் அரசு",
        "Government of Bihar": "பீகார் அரசு",
        "Ministry of Micro, Small and Medium Enterprises": "குறு, சிறு மற்றும் நடுத்தர தொழில் அமைச்சகம் (MSME)",
        "Ministry of Finance": "நிதி அமைச்சகம்",
        "Ministry of Housing and Urban Affairs": "வீட்டுவசதி மற்றும் நகர்ப்புற விவகாரங்கள் அமைச்சகம்",

        "Credit-linked capital subsidy at 35% of eligible project cost up to Rs. 10 Lakhs.": "ரூ. 10 லட்சம் வரை தகுதியான திட்டச் செலவில் 35% மூலதன மானியம்.",
        "Suitable for Individual micro food processing units, FPOs, SHGs, Producer Co-operatives in All India": "அனைத்து இந்தியாவிலும் உள்ள சிறு உணவு பதப்படுத்தும் பிரிவுகள், FPO, SHGகளுக்கு ஏற்றது.",
        "25% capital subsidy up to Rs. 75 Lakhs and 3% interest subvention.": "ரூ. 75 லட்சம் வரை 25% மூலதன மானியம் மற்றும் 3% வட்டி மானியம்.",
        "Suitable for First-generation entrepreneurs in Tamil Nadu with Degree/Diploma/ITI in Tamil Nadu": "தமிழ்நாட்டில் பட்டம்/டிப்ளமோ/ITI முடித்த முதல் தலைமுறை தொழில்முனைவோருக்கு ஏற்றது.",

        "Minimum age criterion met": "குறைந்தபட்ச வயது வரம்பு பூர்த்தியானது",
        "Maximum age criterion met": "அதிகபட்ச வயது வரம்பு பொருந்தியது",
        "Business sector eligible": "தொழில் துறை தகுதியானது",
        "Scheme operates in your region": "உங்கள் பிராந்தியத்தில் இத்திட்டம் செயல்படுகிறது",
        "State eligibility matched": "மாநில தகுதி பொருந்தியது",
        "Matches your funding requirement": "உங்கள் நிதியுதவி தேவைகளுடன் பொருந்துகிறது"
      },
      'te': {
        "Ministry of Food Processing Industries (MoFPI)": "ఆహార ప్రాసెసింగ్ పరిశ్రమల మంత్రిత్వ శాఖ (MoFPI)",
        "Government of Tamil Nadu": "తమిళనాడు ప్రభుత్వం",
        "Government of Uttar Pradesh": "ఉత్తర ప్రదేశ్ ప్రభుత్వం",
        "Government of Maharashtra": "మహారాష్ట్ర ప్రభుత్వం",
        "Government of Rajasthan": "రాజస్థాన్ ప్రభుత్వం",
        "Government of Bihar": "బీహార్ ప్రభుత్వం",
        "Ministry of Micro, Small and Medium Enterprises": "సూక్ష్మ, చిన్న మరియు మధ్య తరహా పరిశ్రమల మంత్రిత్వ శాఖ (MSME)",
        "Ministry of Finance": "ఆర్థిక మంత్రిత్వ శాఖ",

        "Credit-linked capital subsidy at 35% of eligible project cost up to Rs. 10 Lakhs.": "రూ. 10 లక్షల వరకు ప్రాజెక్ట్ వ్యయంలో 35% క్రెడిట్-లింక్డ్ మూలధన సబ్సిడీ.",
        "Suitable for Individual micro food processing units, FPOs, SHGs, Producer Co-operatives in All India": "అఖిల భారత స్థాయిలో వ్యక్తిగత ఆహార ప్రాసెసింగ్ యూనిట్లు, FPOలు, SHGలకు తగినది.",
        "25% capital subsidy up to Rs. 75 Lakhs and 3% interest subvention.": "రూ. 75 లక్షల వరకు 25% మూలధన సబ్సిడీ మరియు 3% వడ్డీ రాయితీ.",
        "Suitable for First-generation entrepreneurs in Tamil Nadu with Degree/Diploma/ITI in Tamil Nadu": "తమిళనాడులోని డిగ్రీ/డిప్లొమా/ITI పూర్తి చేసిన తొలితరం పారిశ్రామికవేత్తలకు తగినది.",

        "Minimum age criterion met": "కనీస వయస్సు నిబంధన పూర్తయింది",
        "Maximum age criterion met": "గరిష్ట వయస్సు నిబంధన పూర్తయింది",
        "Business sector eligible": "వ్యాపార రంగం అర్హత పొందింది",
        "Scheme operates in your region": "మీ ప్రాంతంలో ఈ పథకం అందుబాటులో ఉంది",
        "State eligibility matched": "రాష్ట్ర అర్హత సరిపోలింది",
        "Matches your funding requirement": "మీ ఆర్థిక అవసరాలకు సరిపోతుంది"
      },
      'bn': {
        "Ministry of Food Processing Industries (MoFPI)": "খাদ্য প্রক্রিয়াকরণ শিল্প মন্ত্রণালয় (MoFPI)",
        "Government of Tamil Nadu": "তামিলনাড়ু সরকার",
        "Government of Uttar Pradesh": "উত্তর প্রদেশ সরকার",
        "Government of Maharashtra": "মহারাষ্ট্র সরকার",
        "Government of Rajasthan": "রাজস্থান সরকার",
        "Government of Bihar": "বিহার সরকার",

        "Credit-linked capital subsidy at 35% of eligible project cost up to Rs. 10 Lakhs.": "যোগ্য প্রকল্প ব্যয়ের ৩৫% (সর্বোচ্চ ১০ লাখ টাকা) মূলধন ভোজ্য ভর্তুকি।",
        "Suitable for Individual micro food processing units, FPOs, SHGs, Producer Co-operatives in All India": "সারা ভারতে ক্ষুদ্র খাদ্য প্রক্রিয়াকরণ ইউনিট, FPO, SHGগুলির জন্য উপযুক্ত।",
        "25% capital subsidy up to Rs. 75 Lakhs and 3% interest subvention.": "৭৫ লাখ টাকা পর্যন্ত ২৫% মূলধন ভর্তুকি এবং ৩% সুদ ছা়ড।",
        "Suitable for First-generation entrepreneurs in Tamil Nadu with Degree/Diploma/ITI in Tamil Nadu": "তামিলনাড়ুতে ডিগ্রি/ডিপ্লোমা/ITI ধারী প্রথম প্রজন্মের উদ্যোক্তাদের জন্য উপযুক্ত।",

        "Minimum age criterion met": "নূন্যতম বয়স মাপকাঠি পূরণ হয়েছে",
        "Maximum age criterion met": "সর্বোচ্চ বয়স মাপকাঠি পূরণ হয়েছে",
        "Business sector eligible": "ব্যবসা খাত যোগ্য",
        "Scheme operates in your region": "আপনার অঞ্চলে এই প্রকল্প চালু আছে",
        "State eligibility matched": "রাজ্যের যোগ্যতা মিলেছে",
        "Matches your funding requirement": "আপনার তহবিলের প্রয়োজনের সাথে মেলে"
      },
      'kn': {
        "Ministry of Food Processing Industries (MoFPI)": "ಆಹಾರ ಸಂಸ್ಕರಣಾ ಉದ್ಯಮಗಳ ಸಚಿವಾಲಯ (MoFPI)",
        "Government of Tamil Nadu": "ತಮಿಳುನಾಡು ಸರ್ಕಾರ",
        "Government of Uttar Pradesh": "ಉತ್ತರ ಪ್ರದೇಶ ಸರ್ಕಾರ",
        "Government of Maharashtra": "ಮಹಾರಾಷ್ಟ್ರ ಸರ್ಕಾರ",
        "Government of Rajasthan": "ರಾಜಸ್ಥಾನ ಸರ್ಕಾರ",
        "Government of Bihar": "ಬಿಹಾರ ಸರ್ಕಾರ",

        "Credit-linked capital subsidy at 35% of eligible project cost up to Rs. 10 Lakhs.": "ಅರ್ಹ ಯೋಜನೆ ವೆಚ್ಚದ 35% (ಗರಿಷ್ಠ ರೂ. 10 ಲಕ್ಷ) ಬಂಡವಾಳ ಸಬ್ಸಿಡಿ.",
        "Suitable for Individual micro food processing units, FPOs, SHGs, Producer Co-operatives in All India": "ಸಣ್ಣ ಆಹಾರ ಸಂಸ್ಕರಣಾ ಘಟಕಗಳು, FPO ಗಳು ಮತ್ತು SHG ಗಳಿಗೆ ಸೂಕ್ತವಾಗಿದೆ.",
        "25% capital subsidy up to Rs. 75 Lakhs and 3% interest subvention.": "ರೂ. 75 ಲಕ್ಷದವರೆಗೆ 25% ಬಂಡವಾಳ ಸಬ್ಸಿಡಿ ಮತ್ತು 3% ಬಡ್ಡಿ ರಿಯಾಯಿತಿ.",
        "Suitable for First-generation entrepreneurs in Tamil Nadu with Degree/Diploma/ITI in Tamil Nadu": "ತಮಿಳುನಾಡಿನ ಪದವಿ/ಡಿಪ್ಲೊಮಾ/ITI ಹೊಂದಿರುವ ಮೊದಲ ತಲೆಮಾರಿನ ಉದ್ಯಮಿಗಳಿಗೆ ಸೂಕ್ತ.",

        "Minimum age criterion met": "ಕನಿಷ್ಠ ವಯಸ್ಸಿನ ಮಾನದಂಡ ಪೂರೈಸಲಾಗಿದೆ",
        "Maximum age criterion met": "ಗರಿಷ್ಠ ವಯಸ್ಸಿನ ಮಾನದಂಡ ಪೂರೈಸಲಾಗಿದೆ",
        "Business sector eligible": "ವ್ಯಾಪಾರ ಕ್ಷೇತ್ರವು ಅರ್ಹವಾಗಿದೆ",
        "Scheme operates in your region": "ನಿಮ್ಮ ಪ್ರದೇಶದಲ್ಲಿ ಈ ಯೋಜನೆ ಲಭ್ಯವಿದೆ",
        "State eligibility matched": "ರಾಜ್ಯ ಅರ್ಹತೆ ಹೊಂದಾಣಿಕೆಯಾಗಿದೆ",
        "Matches your funding requirement": "ನಿಮ್ಮ ಹಣಕಾಸಿನ ಅಗತ್ಯಕ್ಕೆ ಸೂಕ್ತವಾಗಿದೆ"
      },
      'ml': {
        "Ministry of Food Processing Industries (MoFPI)": "ഭക്ഷ്യ സംസ്കരണ വ്യവസായ മന്ത്രാലയം (MoFPI)",
        "Government of Tamil Nadu": "തമിഴ്‌നാട് സർക്കാർ",
        "Government of Uttar Pradesh": "ഉത്തർപ്രദേശ് സർക്കാർ",
        "Government of Maharashtra": "മഹാരാഷ്ട്ര സർക്കാർ",
        "Government of Rajasthan": "രാജസ്ഥാൻ സർക്കാർ",
        "Government of Bihar": "ബീഹാർ സർക്കാർ",

        "Credit-linked capital subsidy at 35% of eligible project cost up to Rs. 10 Lakhs.": "10 ലക്ഷം രൂപ വരെ യോഗ്യമായ പ്രോജക്ട് ചെലവിന്റെ 35% സബ്‌സിഡി.",
        "Suitable for Individual micro food processing units, FPOs, SHGs, Producer Co-operatives in All India": "ചെറുകിട ഭക്ഷ്യ സംസ്കരണ യൂണിറ്റുകൾക്കും SHG കൾക്കും അനുയോജ്യം.",
        "25% capital subsidy up to Rs. 75 Lakhs and 3% interest subvention.": "75 ലക്ഷം രൂപ വരെ 25% മൂലധന സബ്‌സിഡിയും 3% പലിശ ഇളവും.",
        "Suitable for First-generation entrepreneurs in Tamil Nadu with Degree/Diploma/ITI in Tamil Nadu": "തമിഴ്‌നാട്ടിലെ ഒന്നാം തലമുറ സംരംഭകർക്ക് അനുയോജ്യം.",

        "Minimum age criterion met": "കുറഞ്ഞ പ്രായപരിധി യോഗ്യത നേടി",
        "Maximum age criterion met": "പരമാവധി പ്രായപരിധി യോഗ്യത നേടി",
        "Business sector eligible": "ബിസിനസ്സ് മേഖല യോഗ്യമാണ്",
        "Scheme operates in your region": "നിങ്ങളുടെ പ്രദേശത്ത് ഈ പദ്ധതി ലഭ്യമാണ്",
        "State eligibility matched": "സംസ്ഥാന യോഗ്യത പൊരുത്തപ്പെട്ടു",
        "Matches your funding requirement": "നിങ്ങളുടെ സാമ്പത്തിക ആവശ്യത്തിന് അനുയോജ്യം"
      },
      'mr': {
        "Ministry of Food Processing Industries (MoFPI)": "अन्न प्रक्रिया उद्योग मंत्रालय (MoFPI)",
        "Government of Tamil Nadu": "तमिळनाडू शासन",
        "Government of Uttar Pradesh": "उत्तर प्रदेश शासन",
        "Government of Maharashtra": "महाराष्ट्र शासन",
        "Government of Rajasthan": "राजस्थान शासन",
        "Government of Bihar": "बिहार शासन",

        "Credit-linked capital subsidy at 35% of eligible project cost up to Rs. 10 Lakhs.": "पात्र प्रकल्प खर्चाच्या ३५% (जास्तीत जास्त १० लाख रुपये) भांडवली सबसिडी.",
        "Suitable for Individual micro food processing units, FPOs, SHGs, Producer Co-operatives in All India": "सूक्ष्म अन्न प्रक्रिया युनिट्स आणि महिला बचत गटांसाठी उपयुक्त.",
        "25% capital subsidy up to Rs. 75 Lakhs and 3% interest subvention.": "७५ लाख रुपयांपर्यंत २५% भांडवली सबसिडी आणि ३% व्याज सवलत.",
        "Suitable for First-generation entrepreneurs in Tamil Nadu with Degree/Diploma/ITI in Tamil Nadu": "तमिळनाडूतील पदवी/डिप्लोमाधारक प्रथम पिढीतील उद्योजकांसाठी उपयुक्त.",

        "Minimum age criterion met": "किमान वयोमर्यादा पूर्ण",
        "Maximum age criterion met": "कमाल वयोमर्यादा पूर्ण",
        "Business sector eligible": "व्यवसाय क्षेत्र पात्र आहे",
        "Scheme operates in your region": "ही योजना तुमच्या क्षेत्रात कार्यरत आहे",
        "State eligibility matched": "राज्य पात्रता जुळली",
        "Matches your funding requirement": "तुमच्या निधीच्या गरजेनुसार योग्य"
      },
      'gu': {
        "Ministry of Food Processing Industries (MoFPI)": "ફૂડ પ્રોસેસિંગ ઉદ્યોગ મંત્રાલય (MoFPI)",
        "Government of Tamil Nadu": "તમિલનાડુ સરકાર",
        "Government of Uttar Pradesh": "ઉત્તર પ્રદેશ સરકાર",
        "Government of Maharashtra": "મહારાષ્ટ્ર સરકાર",
        "Government of Rajasthan": "રાજસ્થાન સરકાર",
        "Government of Bihar": "બિહાર સરકાર",

        "Credit-linked capital subsidy at 35% of eligible project cost up to Rs. 10 Lakhs.": "પાત્ર પ્રોજેક્ટ ખર્ચના ૩૫% (મહત્તમ ૧૦ લાખ) કેપિટલ સબસીડી.",
        "Suitable for Individual micro food processing units, FPOs, SHGs, Producer Co-operatives in All India": "સૂક્ષ્મ ફૂડ પ્રોસેસિંગ યુનિટ્સ અને SHG માટે યોગ્ય.",
        "25% capital subsidy up to Rs. 75 Lakhs and 3% interest subvention.": "૭૫ લાખ સુધી ૨૫% કેપિટલ સબસીડી અને ૩% વ્યાજ રાહત.",
        "Suitable for First-generation entrepreneurs in Tamil Nadu with Degree/Diploma/ITI in Tamil Nadu": "તમિલનાડુના પ્રથમ પેઢીના ઉદ્યોગસાહસિકો માટે યોગ્ય.",

        "Minimum age criterion met": "ન્યૂનતમ વય માનદંડ પૂર્ણ",
        "Maximum age criterion met": "મહત્તમ વય માનદંડ પૂર્ણ",
        "Business sector eligible": "વ્યવસાય ક્ષેત્ર પાત્ર છે",
        "Scheme operates in your region": "આ યોજના તમારા વિસ્તારમાં કાર્યરત છે",
        "State eligibility matched": "રાજ્યની પાત્રતા યોગ્ય છે",
        "Matches your funding requirement": "તમારી ફંડિંગ જરૂરિયાત મુજબ"
      },
      'as': {
        "Ministry of Food Processing Industries (MoFPI)": "খাদ্য প্ৰসংস୍କৰণ উদ্যোগ মন্ত্ৰালয় (MoFPI)",
        "Government of Tamil Nadu": "তামিলনাডু চৰকাৰ",
        "Government of Uttar Pradesh": "উত্তৰ প্ৰদেশ চৰকাৰ",
        "Government of Maharashtra": "ಮഹാৰাষ্ট্ৰ চৰকাৰ",
        "Government of Rajasthan": "ৰাজস্থান চৰকাৰ",
        "Government of Bihar": "বিহাৰ চৰকাৰ",

        "Credit-linked capital subsidy at 35% of eligible project cost up to Rs. 10 Lakhs.": "উপযুক্ত প্ৰকল্প ব্যয়ৰ ৩৫% (সর্বোচ্চ ১০ লাখ টকা) ৰাজসাহায্য।",
        "Suitable for Individual micro food processing units, FPOs, SHGs, Producer Co-operatives in All India": "ক্ষুদ্ৰ খাদ্য প্ৰসংস্কৰণ গোটৰ বাবে উপযুক্ত।",
        "25% capital subsidy up to Rs. 75 Lakhs and 3% interest subvention.": "৭৫ লাখ টকালৈকে ২৫% মূলধন ৰাজসাহায্য।",
        "Suitable for First-generation entrepreneurs in Tamil Nadu with Degree/Diploma/ITI in Tamil Nadu": "প্ৰথম প্ৰজন্মৰ উদ্যোগীসকলৰ বাবে উপযুক্ত।",

        "Minimum age criterion met": "নূন্যতম বয়সৰ মাপকাঠি পূৰণ হৈছে",
        "Maximum age criterion met": "সর্বোচ্চ বয়সৰ মাপকাঠি পূৰণ হৈছে",
        "Business sector eligible": "ব্যৱસાય খণ্ড উপযুক্ত",
        "Scheme operates in your region": "আপোনাৰ অঞ্চলত এই আঁচনি কাৰ্যকৰী",
        "State eligibility matched": "ৰাজ্যিক যোগ্যতা মিলিছে",
        "Matches your funding requirement": "আপোনাৰ পুঁজিৰ প্ৰয়োজনৰ সৈতে খাপ খায়"
      },
      'ur': {
        "Ministry of Food Processing Industries (MoFPI)": "وزارت فوڈ پروسیسنگ انڈسٹریز (MoFPI)",
        "Government of Tamil Nadu": "حکومت تامل ناڈو",
        "Government of Uttar Pradesh": "حکومت اتر پردیش",
        "Government of Maharashtra": "حکومت مہاراشٹرا",
        "Government of Rajasthan": "حکومت راجستھان",
        "Government of Bihar": "حکومت بہار",

        "Credit-linked capital subsidy at 35% of eligible project cost up to Rs. 10 Lakhs.": "پروجیکٹ لاگت کا 35% (زیادہ سے زیادہ 10 لاکھ روپے) کیپیٹل سبسیڈی۔",
        "Suitable for Individual micro food processing units, FPOs, SHGs, Producer Co-operatives in All India": "فوڈ پروسیسنگ یونٹس اور سیلف ہیلپ گروپس کے لیے موزوں۔",
        "25% capital subsidy up to Rs. 75 Lakhs and 3% interest subvention.": "75 لاکھ روپے تک 25% کیپیٹل سبسیڈی اور 3% سود کی رعایت۔",
        "Suitable for First-generation entrepreneurs in Tamil Nadu with Degree/Diploma/ITI in Tamil Nadu": "تامل ناڈو کے پہلی نسل کے تاجروں کے لیے موزوں۔",

        "Minimum age criterion met": "کم از کم عمر کا معیار پورا ہے",
        "Maximum age criterion met": "زیادہ سے زیادہ عمر کا معیار پورا ہے",
        "Business sector eligible": "کاروباری شعبہ اہل ہے",
        "Scheme operates in your region": "اسکیم آپ کے علاقے میں فعال ہے",
        "State eligibility matched": "ریاستی اہلیت مطابق ہے",
        "Matches your funding requirement": "آپ کی مالی ضروریات کے مطابق"
      },
      'or': {
        "Ministry of Food Processing Industries (MoFPI)": "ଖାଦ୍ୟ ପ୍ରସଂସ୍କରଣ ଉଦ୍ୟୋଗ ମନ୍ତ୍ରଣାଳୟ (MoFPI)",
        "Government of Tamil Nadu": "ତାମିଲନାଡୁ ସରକାର",
        "Government of Uttar Pradesh": "ଉତ୍ତର ପ୍ରଦେଶ ସରକାର",
        "Government of Maharashtra": "ମହାରାଷ୍ଟ୍ର ସରକାର",
        "Government of Rajasthan": "ରାଜସ୍ଥାନ ସରକାର",
        "Government of Bihar": "ବିହାର ସରକାର",

        "Credit-linked capital subsidy at 35% of eligible project cost up to Rs. 10 Lakhs.": "ପ୍ରକଳ୍ପ ଖର୍ଚ୍ଚର ୩୫% (ସର୍ବାଧିକ ୧୦ ଲକ୍ଷ ଟଙ୍କା) ସବସିଡି।",
        "25% capital subsidy up to Rs. 75 Lakhs and 3% interest subvention.": "୭୫ ଲକ୍ଷ ଟଙ୍କା ପର୍ଯ୍ୟନ୍ତ ᱒୫% ମୂଳଧନ ସବସିଡି।",

        "Minimum age criterion met": "ନୂନ୍ଯତମ ବୟସ ଯୋଗ୍ୟତା ପୂରଣ ହୋଇଛି",
        "Maximum age criterion met": "ସର୍ବାଧିକ ବୟସ ଯୋଗ୍ୟତା ପୂରଣ ହୋଇଛି",
        "Business sector eligible": "ବ୍ୟବସାୟ କ୍ଷେତ୍ର ଯୋଗ୍ୟ",
        "Scheme operates in your region": "ଆପଣଙ୍କ ଅଞ୍ଚଳରେ ଯୋଜନା ସକ୍ରିୟ",
        "State eligibility matched": "ରାଜ୍ୟ ଯୋଗ୍ୟତା ମିଳିଛି",
        "Matches your funding requirement": "ଆପଣଙ୍କ ଆର୍ଥିକ ଆବଶ୍ୟକତା ସହ ମେଳ ଖାଉଛି"
      },
      'pa': {
        "Ministry of Food Processing Industries (MoFPI)": "ਫ਼ੂਡ ਪ੍ਰੋਸੈਸਿੰਗ ਉਦਯੋਗ ਮੰਤਰਾਲਾ (MoFPI)",
        "Government of Tamil Nadu": "ਤਮਿਲਨਾਡੂ ਸਰਕਾਰ",
        "Government of Uttar Pradesh": "ਉੱਤਰ ਪ੍ਰਦੇਸ਼ ਸਰਕਾਰ",
        "Government of Maharashtra": "ਮਹਾਰਾਸ਼ਟਰ ਸਰਕਾਰ",
        "Government of Rajasthan": "ਰਾਜਸਥਾਨ ਸਰਕਾਰ",
        "Government of Bihar": "ਬਿਹਾਰ ਸਰਕਾਰ",

        "Credit-linked capital subsidy at 35% of eligible project cost up to Rs. 10 Lakhs.": "ਪ੍ਰੋਜੈਕਟ ਲਾਗਤ ਦਾ 35% (ਵੱਧ ਤੋਂ ਵੱਧ 10 ਲੱਖ ਰੁਪਏ) ਕੈਪੀਟਲ ਸਬਸਿਡੀ।",
        "25% capital subsidy up to Rs. 75 Lakhs and 3% interest subvention.": "75 ਲੱਖ ਰੁਪਏ ਤੱਕ 25% ਸਬਸਿਡੀ ਅਤੇ 3% ਵਿਆਜ ਛੋਟ।",

        "Minimum age criterion met": "ਘੱਟੋ-ਘੱਟ ਉਮਰ ਪੂਰੀ ਹੈ",
        "Maximum age criterion met": "ਵੱਧ ਤੋਂ ਵੱਧ ਉਮਰ ਪੂਰੀ ਹੈ",
        "Business sector eligible": "ਕਾਰੋਬਾਰ ਖੇਤਰ ਯੋਗ ਹੈ",
        "Scheme operates in your region": "ਇਹ ਸਕੀਮ ਤੁਹਾਡੇ ਖੇਤਰ ਵਿੱਚ ਲਾਗੂ ਹੈ",
        "State eligibility matched": "ਰਾਜ ਦੀ ਯੋਗਤਾ ਪੂਰੀ ਹੈ",
        "Matches your funding requirement": "ਤੁਹਾਡੀ ਫੰਡ ਦੀ ਲੋੜ ਨਾਲ ਮੇਲ ਖਾਂਦਾ ਹੈ"
      }
    };

    final langDict = dict[langCode];
    if (langDict != null) {
      langDict.forEach((key, val) {
        res = res.replaceAll(key, val);
      });
    }

    // Dynamic pattern fallbacks for all non-English languages
    if (langCode != 'en') {
      res = res
        .replaceAll("Ministry of Food Processing Industries (MoFPI)", langCode == 'hi' ? "खाद्य प्रसंस्करण उद्योग मंत्रालय (MoFPI)" : (langCode == 'te' ? "ఆహార ప్రాసెసింగ్ పరిశ్రమల మంత్రిత్వ శాఖ" : (langCode == 'ta' ? "உணவு பதப்படுத்தும் தொழில்கள் அமைச்சகம்" : "Ministry of Food Processing Industries (MoFPI)")))
        .replaceAll("Government of Tamil Nadu", langCode == 'hi' ? "तमिलनाडु सरकार" : (langCode == 'te' ? "తమిళనాడు ప్రభుత్వం" : (langCode == 'ta' ? "தமிழ்நாடு அரசு" : "Government of Tamil Nadu")))
        .replaceAll("Government of Uttar Pradesh", langCode == 'hi' ? "उत्तर प्रदेश सरकार" : "Government of Uttar Pradesh")
        .replaceAll("Government of Maharashtra", langCode == 'hi' ? "महाराष्ट्र सरकार" : "Government of Maharashtra")
        .replaceAll("Government of Rajasthan", langCode == 'hi' ? "राजस्थान सरकार" : "Government of Rajasthan")
        .replaceAll("Government of Bihar", langCode == 'hi' ? "बिहार सरकार" : "Government of Bihar")
        .replaceAll("Minimum age criterion met", langCode == 'hi' ? "न्यूनतम आयु मानदंड पूरा हुआ" : (langCode == 'te' ? "కనీస వయస్సు నిబంధన పూర్తయింది" : (langCode == 'ta' ? "குறைந்தபட்ச வயது வரம்பு பூர்த்தியானது" : "Minimum age criterion met")))
        .replaceAll("Maximum age criterion met", langCode == 'hi' ? "अधिकतम आयु मानदंड पूरा हुआ" : (langCode == 'te' ? "గరిష్ట వయస్సు నిబంధన పూర్తయింది" : (langCode == 'ta' ? "அதிகபட்ச வயது வரம்பு பொருந்தியது" : "Maximum age criterion met")))
        .replaceAll("Business sector eligible", langCode == 'hi' ? "व्यवसाय क्षेत्र पात्र है" : (langCode == 'te' ? "వ్యాపార రంగం అర్హత పొందింది" : (langCode == 'ta' ? "தொழில் துறை தகுதியானது" : "Business sector eligible")))
        .replaceAll("Scheme operates in your region", langCode == 'hi' ? "यह योजना आपके क्षेत्र में संचालित है" : (langCode == 'te' ? "మీ ప్రాంతంలో ఈ పథకం అందుబాటులో ఉంది" : (langCode == 'ta' ? "உங்கள் பிராந்தியத்தில் இத்திட்டம் செயல்படுகிறது" : "Scheme operates in your region")))
        .replaceAll("State eligibility matched", langCode == 'hi' ? "राज्य की पात्रता मेल खाती है" : (langCode == 'te' ? "రాష్ట్ర అర్హత సరిపోలింది" : (langCode == 'ta' ? "மாநில தகுதி பொருந்தியது" : "State eligibility matched")))
        .replaceAll("Matches your funding requirement", langCode == 'hi' ? "आपकी फंडिंग आवश्यकता से मेल खाता है" : (langCode == 'te' ? "మీ ఆర్థిక అవసరాలకు సరిపోతుంది" : (langCode == 'ta' ? "உங்கள் நிதியுதவி தேவைகளுடன் பொருந்துகிறது" : "Matches your funding requirement")))
        .replaceAll("(All India)", langCode == 'hi' ? "(अखिल भारतीय)" : (langCode == 'te' ? "(అఖిల భారత)" : (langCode == 'ta' ? "(அனைத்து இந்தியா)" : "(All India)")))
        .replaceAll("(Manufacturing)", langCode == 'hi' ? "(विनिर्माण)" : (langCode == 'te' ? "(తయారీ రంగం)" : (langCode == 'ta' ? "(உற்பத்தி)" : "(Manufacturing)")))
        .replaceAll("(Service)", langCode == 'hi' ? "(सेवा)" : (langCode == 'te' ? "(సేవ)" : (langCode == 'ta' ? "(சேவை)" : "(Service)")))
        .replaceAll("(Trading)", langCode == 'hi' ? "(व्यापार)" : (langCode == 'te' ? "(వ్యాపారం)" : (langCode == 'ta' ? "(வணிகம்)" : "(Trading)")));
    }

    return res;
  }
}
