# -*- coding: utf-8 -*-
import json
import os

helper_path = r"C:\dev\scheme-mate-ai\mobile\flutter_app\lib\core\i18n\scheme_translation_helper.dart"

dart_code = '''class SchemeTranslationHelper {
  static String localize(String input, String langCode) {
    if (input.isEmpty || langCode == 'en') return input;
    String res = input;

    final Map<String, Map<String, String>> dict = {
      'hi': {
        "Ministry of Micro, Small and Medium Enterprises": "सूक्ष्म, लघु एवं मध्यम उद्यम मंत्रालय (MSME)",
        "Ministry of Finance": "वित्त मंत्रालय",
        "Ministry of Housing and Urban Affairs": "आवास और शहरी कार्य मंत्रालय",
        "Ministry of Food Processing Industries (MoFPI)": "खाद्य प्रसंस्करण उद्योग मंत्रालय (MoFPI)",
        "Government of Tamil Nadu": "तमिलनाडु सरकार",
        "Government of Uttar Pradesh": "उत्तर प्रदेश सरकार",
        "Government of Maharashtra": "महाराष्ट्र सरकार",
        "Government of Rajasthan": "राजस्थान सरकार",
        "Government of Bihar": "बिहार सरकार",
        "Development Commissioner (MSME)": "विकास आयुक्त (MSME)",

        "Subsidy of 15% to 35% of project cost up to Rs. 50 Lakhs for manufacturing and Rs. 20 Lakhs for service sector.": "विनिर्माण के लिए रु. 50 लाख और सेवा क्षेत्र के लिए रु. 20 लाख तक परियोजना लागत की 15% से 35% सब्सिडी।",
        "Loans up to Rs. 50,000 without collateral at affordable interest rates.": "किफायती ब्याज दरों पर बिना किसी गारंटी के रु. 50,000 तक का ऋण।",
        "Loan from Rs. 50,001 up to Rs. 5,00,000 without requirement of collateral security.": "बिना किसी गारंटी के रु. 50,001 से रु. 5,00,000 तक का ऋण।",
        "Loan from Rs. 5,00,001 to Rs. 10,00,000.": "रु. 5,00,001 से रु. 10,00,000 तक का ऋण सहायता।",
        "Bank loan between Rs. 10 Lakhs and Rs. 1 Crore for setting up a greenfield enterprise.": "नया उद्यम शुरू करने के लिए रु. 10 लाख से रु. 1 करोड़ तक का बैंक ऋण।",
        "Rs. 15,000 toolkit digital voucher, 5-7 days basic training with Rs. 500/day stipend, collateral-free loan of Rs. 1 Lakh (Tranche 1) and Rs. 2 Lakh (Tranche 2) at 5% interest rate.": "रु. 15,000 टूलकिट वाउचर, रु. 500/दिन वजीफे के साथ प्रशिक्षण, 5% ब्याज दर पर 1 लाख और 2 लाख का ऋण।",
        "Working capital loan of Rs. 10,00,000 (1st tranche), Rs. 20,000 (2nd tranche), and Rs. 50,000 (3rd tranche) with 7% interest subsidy and cashback on digital transactions.": "7% ब्याज सब्सिडी के साथ रु. 10,00,000 तक का कार्यशील पूंजी ऋण।",
        "Working capital loan of Rs. 10,000 (1st tranche), Rs. 20,000 (2nd tranche), and Rs. 50,000 (3rd tranche) with 7% interest subsidy and cashback on digital transactions.": "7% ब्याज सब्सिडी के साथ रु. 10,000 का कार्यशील पूंजी ऋण।",
        "Collateral-free credit facility up to Rs. 5 Crore with guarantee cover up to 85% for women/SC/ST/Aspirations districts.": "महिलाओं/SC/ST के लिए 85% गारंटी के साथ रु. 5 करोड़ तक की गारंटी-मुक्त ऋण सुविधा।",
        "GOI grant up to 30% of total project cost evaluated by lending bank.": "बैंक द्वारा मूल्यांकित कुल परियोजना लागत का 30% तक सरकारी अनुदान।",
        "Credit-linked capital subsidy at 35% of eligible project cost up to Rs. 10 Lakhs.": "पात्र परियोजना लागत का 35% (अधिकतम रु. 10 लाख) क्रेडिट-लिंक्ड पूंजी सब्सिडी।",
        "25% capital subsidy up to Rs. 75 Lakhs and 3% interest subvention.": "रु. 75 लाख तक 25% पूंजी सब्सिडी और 3% ब्याज अनुदान।",
        "25% subsidy of project cost up to Rs. 3.75 Lakhs for Manufacturing, Rs. 1.25 Lakhs for Service, Rs. 1.25 Lakhs for Business.": "विनिर्माण के लिए रु. 3.75 लाख, सेवा और व्यापार के लिए रु. 1.25 लाख तक 25% सब्सिडी।",
        "Margin money subsidy up to 25% of total project cost (max subsidy Rs. 20 Lakhs).": "कुल परियोजना लागत का 25% तक मार्जिन मनी सब्सिडी (अधिकतम रु. 20 लाख)।",
        "Subsidy of 15% to 35% of project cost up to Rs. 50 Lakhs for Manufacturing and Rs. 20 Lakhs for Service.": "विनिर्माण के लिए रु. 50 लाख और सेवा के लिए रु. 20 लाख तक 15% से 35% सब्सिडी।",
        "Interest subsidy of 8% for loans up to Rs. 25 Lakhs, 6% up to Rs. 5 Crores, and 5% up to Rs. 10 Crores.": "रु. 25 लाख तक 8%, रु. 5 करोड़ तक 6% और रु. 10 करोड़ तक 5% ब्याज अनुदान।",
        "Total support of Rs. 10 Lakhs (50% Grant of Rs. 5 Lakhs + 50% Interest-free Loan of Rs. 5 Lakhs repayable in 84 installments).": "रु. 10 लाख की कुल सहायता (5 लाख अनुदान + 84 किश्तों में 5 लाख ब्याज-मुक्त ऋण)।",

        "Suitable for Individuals, SHGs, Institutions, Co-operative Societies in All India": "अखिल भारतीय स्तर पर व्यक्तियों, स्वयं सहायता समूहों, संस्थानों और सहकारी समितियों के लिए उपयुक्त",
        "Suitable for Micro entrepreneurs, shopkeepers, artisans, street vendors in All India": "सूक्ष्म उद्यमियों, दुकानदारों, कारीगरों, स्ट्रीट वेंडरों के लिए उपयुक्त।",
        "Suitable for Existing micro-enterprises seeking growth capital in All India": "विकास पूंजी चाहने वाले मौजूदा सूक्ष्म उद्यमों के लिए उपयुक्त।",
        "Suitable for Growing small business owners and commercial units in All India": "बढ़ते छोटे व्यवसाय मालिकों और वाणिज्यिक इकाइयों के लिए उपयुक्त।",
        "Suitable for Women Entrepreneurs and SC / ST Entrepreneurs (first-time greenfield project) in All India": "महिला उद्यमियों और SC/ST उद्यमियों (प्रथम बार नया उद्यम) के लिए उपयुक्त।",
        "Suitable for Artisans and Craftsmen working with hands and tools in 18 traditional trades in All India": "18 पारंपरिक व्यवसायों में हाथों और औजारों से काम करने वाले कारीगरों के लिए उपयुक्त।",
        "Suitable for Street vendors, hawkers, roadside shop owners in All India": "स्ट्रीट वेंडरों, फेरीवालों और सड़क किनारे दुकान मालिकों के लिए उपयुक्त।",
        "Suitable for New and existing Micro and Small Enterprises in All India": "नए और मौजूदा सूक्ष्म और छोटे उद्यमों के लिए उपयुक्त।",
        "Suitable for Women entrepreneurs in groups or individually backed by eligible NGOs in All India": "महिला उद्यमियों और स्वयं सहायता समूहों के लिए उपयुक्त।",
        "Suitable for Individual micro food processing units, FPOs, SHGs, Producer Co-operatives in All India": "व्यक्तिगत सूक्ष्म खाद्य प्रसंस्करण इकाइयों, एफपीओ, एसएचजी के लिए उपयुक्त।",
        "Suitable for First-generation entrepreneurs in Tamil Nadu with Degree/Diploma/ITI in Tamil Nadu": "डिग्री/डिप्लोमा/आईटीआई धारक तमिलनाडु के प्रथम पीढ़ी के उद्यमियों के लिए उपयुक्त।",
        "Suitable for Unemployed youth belonging to socially disadvantaged/economically weaker sections in Tamil Nadu": "तमिलनाडु के शिक्षित बेरोजगार युवाओं के लिए उपयुक्त।",
        "Suitable for Entrepreneurs and artisans producing designated ODOP products in UP in Uttar Pradesh": "उत्तर प्रदेश के ODOP उत्पादों का निर्माण करने वाले कारीगरों के लिए उपयुक्त।",
        "Suitable for Unemployed educated youth and entrepreneurs in Maharashtra in Maharashtra": "महाराष्ट्र के शिक्षित बेरोजगार युवाओं और उद्यमियों के लिए उपयुक्त।",
        "Suitable for Individual entrepreneurs, SHGs, Partnership firms, Private Limited companies in Rajasthan in Rajasthan": "राजस्थान के उद्यमियों, स्वयं सहायता समूहों और साझेदारी फर्मों के लिए उपयुक्त।",
        "Suitable for Unemployed youth and women residents of Bihar (Intermediate / ITI / Diploma passed) in Bihar": "बिहार के बेरोजगार युवाओं और महिलाओं (इंटरमीडिएट/आईटीआई/डिप्लोमा) के लिए उपयुक्त।",

        "Minimum age criterion met": "न्यूनतम आयु मानदंड पूरा हुआ",
        "Maximum age criterion met": "अधिकतम आयु मानदंड पूरा हुआ",
        "Business sector eligible": "व्यवसाय क्षेत्र पात्र है",
        "Scheme operates in your region": "यह योजना आपके क्षेत्र में संचालित है",
        "State eligibility matched": "राज्य की पात्रता मेल खाती है",
        "Matches your funding requirement": "आपकी फंडिंग आवश्यकता से मेल खाता है"
      },
      'ta': {
        "Ministry of Micro, Small and Medium Enterprises": "குறு, சிறு மற்றும் நடுத்தர தொழில் அமைச்சகம் (MSME)",
        "Ministry of Finance": "நிதி அமைச்சகம்",
        "Ministry of Housing and Urban Affairs": "வீட்டுவசதி மற்றும் நகர்ப்புற விவகாரங்கள் அமைச்சகம்",
        "Ministry of Food Processing Industries (MoFPI)": "உணவு பதப்படுத்தும் தொழில்கள் அமைச்சகம் (MoFPI)",
        "Government of Tamil Nadu": "தமிழ்நாடு அரசு",
        "Government of Uttar Pradesh": "உத்தரப் பிரதேச அரசு",
        "Government of Maharashtra": "மகாராஷ்டிர அரசு",
        "Government of Rajasthan": "ராஜஸ்தான் அரசு",
        "Government of Bihar": "பீகார் அரசு",

        "Subsidy of 15% to 35% of project cost up to Rs. 50 Lakhs for manufacturing and Rs. 20 Lakhs for service sector.": "ரூ. 50 லட்சம் வரை உற்பத்திக்கும், ரூ. 20 லட்சம் வரை சேவைத் துறைக்கும் 15% முதல் 35% வரை மானியம்.",
        "Loans up to Rs. 50,000 without collateral at affordable interest rates.": "பிணைய உத்தரவாதம் இன்றி குறைந்த வட்டியில் ரூ. 50,000 வரை சிறு கடன்.",
        "Loan from Rs. 50,001 up to Rs. 5,00,000 without requirement of collateral security.": "பிணைய உத்தரவாதம் இன்றி ரூ. 50,001 முதல் ரூ. 5,00,000 வரை கடன் உதவி.",
        "Loan from Rs. 5,00,001 to Rs. 10,00,000.": "ரூ. 5,00,001 முதல் ரூ. 10,00,000 வரை கடன் உதவி.",
        "Bank loan between Rs. 10 Lakhs and Rs. 1 Crore for setting up a greenfield enterprise.": "புதிய தொழில் தொடங்குவதற்கு ரூ. 10 லட்சம் முதல் ரூ. 1 கோடி வரை வங்கி கடன்.",
        "Rs. 15,000 toolkit digital voucher, 5-7 days basic training with Rs. 500/day stipend, collateral-free loan of Rs. 1 Lakh (Tranche 1) and Rs. 2 Lakh (Tranche 2) at 5% interest rate.": "ரூ. 15,000 கருவித்தொகுப்பு வவுச்சர், பயிற்சி மற்றும் 5% வட்டியில் பிணையமற்ற கடன்.",
        "Working capital loan of Rs. 10,00,000 (1st tranche), Rs. 20,000 (2nd tranche), and Rs. 50,000 (3rd tranche) with 7% interest subsidy and cashback on digital transactions.": "7% வட்டி மானியத்துடன் நடைமுறை மூலதனக் கடன் உதவி.",
        "Working capital loan of Rs. 10,000 (1st tranche), Rs. 20,000 (2nd tranche), and Rs. 50,000 (3rd tranche) with 7% interest subsidy and cashback on digital transactions.": "7% வட்டி மானியத்துடன் ரூ. 10,000 நடைமுறை மூலதனக் கடன்.",
        "Collateral-free credit facility up to Rs. 5 Crore with guarantee cover up to 85% for women/SC/ST/Aspirations districts.": "பெண்கள்/SC/ST தொழில்முனைவோருக்கு 85% உத்தரவாதத்துடன் ரூ. 5 கோடி வரை பிணையற்ற கடன்.",
        "GOI grant up to 30% of total project cost evaluated by lending bank.": "மொத்த திட்டச் செலவில் 30% வரை மத்திய அரசு மானியம்.",
        "Credit-linked capital subsidy at 35% of eligible project cost up to Rs. 10 Lakhs.": "ரூ. 10 லட்சம் வரை தகுதியான திட்டச் செலவில் 35% மூலதன மானியம்.",
        "25% capital subsidy up to Rs. 75 Lakhs and 3% interest subvention.": "ரூ. 75 லட்சம் வரை 25% மூலதன மானியம் மற்றும் 3% வட்டி மானியம்.",
        "25% subsidy of project cost up to Rs. 3.75 Lakhs for Manufacturing, Rs. 1.25 Lakhs for Service, Rs. 1.25 Lakhs for Business.": "உற்பத்திக்கு ரூ. 3.75 லட்சம், சேவைக்கு ரூ. 1.25 லட்சம் வரை 25% மானியம்.",

        "Minimum age criterion met": "குறைந்தபட்ச வயது வரம்பு பூர்த்தியானது",
        "Maximum age criterion met": "அதிகபட்ச வயது வரம்பு பொருந்தியது",
        "Business sector eligible": "தொழில் துறை தகுதியானது",
        "Scheme operates in your region": "உங்கள் பிராந்தியத்தில் இத்திட்டம் செயல்படுகிறது",
        "State eligibility matched": "மாநில தகுதி பொருந்தியது",
        "Matches your funding requirement": "உங்கள் நிதியுதவி தேவைகளுடன் பொருந்துகிறது"
      },
      'te': {
        "Ministry of Micro, Small and Medium Enterprises": "సూక్ష్మ, చిన్న మరియు మధ్య తరహా పరిశ్రమల మంత్రిత్వ శాఖ (MSME)",
        "Ministry of Finance": "ఆర్థిక మంత్రిత్వ శాఖ",
        "Ministry of Housing and Urban Affairs": "పట్టణాభివృద్ధి మంత్రిత్వ శాఖ",
        "Ministry of Food Processing Industries (MoFPI)": "ఆహార ప్రాసెసింగ్ పరిశ్రమల మంత్రిత్వ శాఖ",
        "Government of Tamil Nadu": "తమిళనాడు ప్రభుత్వం",
        "Government of Uttar Pradesh": "ఉత్తర ప్రదేశ్ ప్రభుత్వం",
        "Government of Maharashtra": "మహారాష్ట్ర ప్రభుత్వం",
        "Government of Rajasthan": "రాజస్థాన్ ప్రభుత్వం",
        "Government of Bihar": "బీహార్ ప్రభుత్వం",

        "Subsidy of 15% to 35% of project cost up to Rs. 50 Lakhs for manufacturing and Rs. 20 Lakhs for service sector.": "ఉత్పత్తి రంగానికి రూ. 50 లక్షలు, సేవా రంగానికి రూ. 20 లక్షల వరకు 15% నుండి 35% సబ్సిడీ.",
        "Loans up to Rs. 50,000 without collateral at affordable interest rates.": "హామీ లేకుండా తక్కువ వడ్డీతో రూ. 50,000 వరకు రుణం.",
        "Loan from Rs. 50,001 up to Rs. 5,00,000 without requirement of collateral security.": "హామీ లేకుండా రూ. 50,001 నుండి రూ. 5,00,000 వరకు రుణం.",
        "Loan from Rs. 5,00,001 to Rs. 10,00,000.": "రూ. 5,00,001 నుండి రూ. 10,00,000 వరకు రుణ సదుపాయం.",
        "Bank loan between Rs. 10 Lakhs and Rs. 1 Crore for setting up a greenfield enterprise.": "కొత్త పరిశ్రమ స్థాపనకు రూ. 10 లక్షల నుండి రూ. 1 కోటి వరకు బ్యాంక్ రుణం.",
        "Rs. 15,000 toolkit digital voucher, 5-7 days basic training with Rs. 500/day stipend, collateral-free loan of Rs. 1 Lakh (Tranche 1) and Rs. 2 Lakh (Tranche 2) at 5% interest rate.": "రూ. 15,000 టూల్‌కిట్ వోచర్, శిక్షణ మరియు 5% వడ్డీకే రూ. 3 లక్షల వరకు రుణం.",
        "Working capital loan of Rs. 10,00,000 (1st tranche), Rs. 20,000 (2nd tranche), and Rs. 50,000 (3rd tranche) with 7% interest subsidy and cashback on digital transactions.": "7% వడ్డీ సబ్సిడీతో పని మూలధన రుణం.",
        "Working capital loan of Rs. 10,000 (1st tranche), Rs. 20,000 (2nd tranche), and Rs. 50,000 (3rd tranche) with 7% interest subsidy and cashback on digital transactions.": "7% వడ్డీ సబ్సిడీతో రూ. 10,000 పని మూలధన రుణం.",
        "Collateral-free credit facility up to Rs. 5 Crore with guarantee cover up to 85% for women/SC/ST/Aspirations districts.": "మహిళలు/SC/ST ల కోసం 85% పూచీకత్తుతో రూ. 5 కోట్ల వరకు హామీ లేని రుణం.",
        "GOI grant up to 30% of total project cost evaluated by lending bank.": "మొత్తం ప్రాజెక్ట్ వ్యయంలో 30% వరకు కేంద్ర ప్రభుత్వ గ్రాంట్.",
        "Credit-linked capital subsidy at 35% of eligible project cost up to Rs. 10 Lakhs.": "రూ. 10 లక్షల వరకు ప్రాజెక్ట్ వ్యయంలో 35% క్రెడిట్-లింక్డ్ మూలధన సబ్సిడీ.",
        "25% capital subsidy up to Rs. 75 Lakhs and 3% interest subvention.": "రూ. 75 లక్షల వరకు 25% మూలధన సబ్సిడీ మరియు 3% వడ్డీ రాయితీ.",
        "25% subsidy of project cost up to Rs. 3.75 Lakhs for Manufacturing, Rs. 1.25 Lakhs for Service, Rs. 1.25 Lakhs for Business.": "తయారీ రంగానికి రూ. 3.75 లక్షలు, సేవలకు రూ. 1.25 లక్షల వరకు 25% సబ్సిడీ.",

        "Minimum age criterion met": "కనీస వయస్సు నిబంధన పూర్తయింది",
        "Maximum age criterion met": "గరిష్ట వయస్సు నిబంధన పూర్తయింది",
        "Business sector eligible": "వ్యాపార రంగం అర్హత పొందింది",
        "Scheme operates in your region": "మీ ప్రాంతంలో ఈ పథకం అందుబాటులో ఉంది",
        "State eligibility matched": "రాష్ట్ర అర్హత సరిపోలింది",
        "Matches your funding requirement": "మీ ఆర్థిక అవసరాలకు సరిపోతుంది"
      }
    };

    final langDict = dict[langCode];
    if (langDict != null) {
      langDict.forEach((key, val) {
        res = res.replaceAll(key, val);
      });
    }

    // Generic replacements for all Indian languages (for common patterns)
    if (langCode != 'en') {
      res = res
        .replaceAll("Ministry of Finance", langCode == 'hi' ? "वित्त मंत्रालय" : (langCode == 'te' ? "ఆర్థిక మంత్రిత్వ శాఖ" : (langCode == 'ta' ? "நிதி அமைச்சகம்" : "Ministry of Finance")))
        .replaceAll("Ministry of Micro, Small and Medium Enterprises", langCode == 'hi' ? "सूक्ष्म, लघु एवं मध्यम उद्यम मंत्रालय" : (langCode == 'te' ? "సూక్ష్మ, చిన్న మరియు మధ్య తరహా పరిశ్రమల మంత్రిత్వ శాఖ" : "Ministry of MSME"))
        .replaceAll("Government of Tamil Nadu", langCode == 'hi' ? "तमिलनाडु सरकार" : (langCode == 'te' ? "తమిళనాడు ప్రభుత్వం" : "Government of Tamil Nadu"))
        .replaceAll("Government of Uttar Pradesh", langCode == 'hi' ? "उत्तर प्रदेश सरकार" : "Government of Uttar Pradesh")
        .replaceAll("Government of Maharashtra", langCode == 'hi' ? "महाराष्ट्र सरकार" : "Government of Maharashtra")
        .replaceAll("Government of Rajasthan", langCode == 'hi' ? "राजस्थान सरकार" : "Government of Rajasthan")
        .replaceAll("Government of Bihar", langCode == 'hi' ? "बिहार सरकार" : "Government of Bihar")
        .replaceAll("Minimum age criterion met", langCode == 'hi' ? "न्यूनतम आयु मानदंड पूरा हुआ" : (langCode == 'te' ? "కనీస వయస్సు నిబంధన పూర్తయింది" : "Minimum age criterion met"))
        .replaceAll("Maximum age criterion met", langCode == 'hi' ? "अधिकतम आयु मानदंड पूरा हुआ" : (langCode == 'te' ? "గరిష్ట వయస్సు నిబంధన పూర్తయింది" : "Maximum age criterion met"))
        .replaceAll("Business sector eligible", langCode == 'hi' ? "व्यवसाय क्षेत्र पात्र है" : (langCode == 'te' ? "వ్యాపార రంగం అర్హత పొందింది" : "Business sector eligible"))
        .replaceAll("Scheme operates in your region", langCode == 'hi' ? "यह योजना आपके क्षेत्र में संचालित है" : (langCode == 'te' ? "మీ ప్రాంతంలో ఈ పథకం అందుబాటులో ఉంది" : "Scheme operates in your region"))
        .replaceAll("State eligibility matched", langCode == 'hi' ? "राज्य की पात्रता मेल खाती है" : (langCode == 'te' ? "రాష్ట్ర అర్హత సరిపోలింది" : "State eligibility matched"))
        .replaceAll("(All India)", langCode == 'hi' ? "(अखिल भारतीय)" : (langCode == 'te' ? "(అఖిల భారత)" : "(All India)"))
        .replaceAll("(Manufacturing)", langCode == 'hi' ? "(विनिर्माण)" : (langCode == 'te' ? "(తయారీ రంగం)" : "(Manufacturing)"))
        .replaceAll("(Service)", langCode == 'hi' ? "(सेवा क्षेत्र)" : (langCode == 'te' ? "(సేవా రంగం)" : "(Service)"))
        .replaceAll("(Trading)", langCode == 'hi' ? "(व्यापार)" : (langCode == 'te' ? "(వ్యాపారం)" : "(Trading)"));
    }

    return res;
  }
}
'''

with open(helper_path, "w", encoding="utf-8") as f:
    f.write(dart_code)

print("SchemeTranslationHelper written!")
'''

with open("build_scheme_translation_helper.py", "w", encoding="utf-8") as f:
    f.write(script_content)

