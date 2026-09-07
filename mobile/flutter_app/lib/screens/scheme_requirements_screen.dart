// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/i18n/app_localizations.dart';
import '../core/i18n/scheme_translation_helper.dart';
import '../core/theme/app_theme.dart';
import '../providers/locale_provider.dart';
import '../widgets/gov_top_header.dart';
import '../widgets/gov_footer.dart';
import '../widgets/language_selector_sheet.dart';
import 'financial_calculator_screen.dart';
import 'partner_locator_screen.dart';

class SchemeRequirementsScreen extends StatelessWidget {
  final Map<String, dynamic> scheme;

  const SchemeRequirementsScreen({Key? key, required this.scheme}) : super(key: key);

  void _applyForScheme(BuildContext context) {
    final String url = (scheme['official_application_url'] ?? '').toString().trim();
    final String fallback = (scheme['official_source_url'] ?? '').toString().trim();
    final String portalUrl = url.isNotEmpty ? url : fallback;

    if (portalUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr("no_portal_url")),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    html.window.open(portalUrl, '_blank');
  }

  String _localizeReqText(String input, String langCode) {
    if (input.isEmpty || langCode == 'en') return input;
    String res = input;
    if (langCode == 'ta') {
      res = res
        .replaceAll("Ministry of Finance", "நிதி அமைச்சகம்")
        .replaceAll("Ministry of Micro, Small and Medium Enterprises", "குறு, சிறு மற்றும் நடுத்தர தொழில் அமைச்சகம் (MSME)")
        .replaceAll("Ministry of Housing and Urban Affairs", "வீட்டுவசதி மற்றும் நகர்ப்புற விவகாரங்கள் அமைச்சகம்")
        .replaceAll("Minimum age criterion met", "குறைந்தபட்ச வயது வரம்பு பூர்த்தியானது")
        .replaceAll("Business sector eligible", "தொழில் துறை தகுதியானது")
        .replaceAll("Scheme operates in your region", "உங்கள் பிராந்தியத்தில் இத்திட்டம் செயல்படுகிறது")
        .replaceAll("State eligibility matched", "மாநில தகுதி பொருந்தியது")
        .replaceAll("Matches your funding requirement", "உங்கள் நிதியுதவி தேவைகளுடன் பொருந்துகிறது")
        .replaceAll("(All India)", "(அனைத்து இந்தியா)")
        .replaceAll("(Transportation & Logistics)", "(போக்குவரத்து மற்றும் தளவாடங்கள்)")
        .replaceAll("31 Dec 2026 (Open Year-Round)", "31 டிசம்பர் 2026 (ஆண்டு முழுவதும் திறந்திருக்கும்)")
        .replaceAll("Loan from Rs. 5,00,001 to Rs. 10,00,000.", "ரூ. 5,00,001 முதல் ரூ. 10,00,000 வரை கடன் உதவி.")
        .replaceAll("Loan from Rs. 50,001 up to Rs. 5,00,000 without requirement of collateral security.", "பிணைய உத்தரவாதம் இன்றி ரூ. 50,001 முதல் ரூ. 5,00,000 வரை கடன் உதவி.")
        .replaceAll("Loans up to Rs. 50,000 without collateral at affordable interest rates.", "பிணைய உத்தரவாதம் இன்றி குறைந்த வட்டியில் ரூ. 50,000 வரை சிறு கடன்.")
        .replaceAll("Suitable for Growing small business owners and commercial units in All India", "அனைத்து இந்தியாவிலும் வளர்ச்சி அடையும் சிறு தொழில் உரிமையாளர்களுக்கு ஏற்றது.")
        .replaceAll("(Open Year-Round)", "(ஆண்டு முழுவதும் திறந்திருக்கும்)");
    } else if (langCode == 'hi') {
      res = res
        .replaceAll("Ministry of Finance", "वित्त मंत्रालय")
        .replaceAll("Ministry of Micro, Small and Medium Enterprises", "सूक्ष्म, लघु एवं मध्यम उद्यम मंत्रालय (MSME)")
        .replaceAll("Ministry of Housing and Urban Affairs", "आवास और शहरी कार्य मंत्रालय")
        .replaceAll("Minimum age criterion met", "न्यूनतम आयु मानदंड पूरा हुआ")
        .replaceAll("Business sector eligible", "व्यवसाय क्षेत्र पात्र है")
        .replaceAll("Scheme operates in your region", "यह योजना आपके क्षेत्र में संचालित है")
        .replaceAll("(All India)", "(अखिल भारतीय)")
        .replaceAll("(Transportation & Logistics)", "(परिवहन और लॉजिस्टिक्स)")
        .replaceAll("31 Dec 2026 (Open Year-Round)", "31 दिसंबर 2026 (वर्ष भर खुला)")
        .replaceAll("Loan from Rs. 5,00,001 to Rs. 10,00,000.", "रु. 5,00,001 से रु. 10,00,000 तक का ऋण सहायता।")
        .replaceAll("Loan from Rs. 50,001 up to Rs. 5,00,000 without requirement of collateral security.", "बिना किसी गारंटी के रु. 50,001 से रु. 5,00,000 तक का ऋण।")
        .replaceAll("Loans up to Rs. 50,000 without collateral at affordable interest rates.", "बिना गारंटी के किफायती दरों पर रु. 50,000 तक का ऋण।")
        .replaceAll("Suitable for Growing small business owners and commercial units in All India", "पूरे भारत में बढ़ते छोटे व्यवसाय मालिकों और वाणिज्यिक इकाइयों के लिए उपयुक्त।")
        .replaceAll("(Open Year-Round)", "(वर्ष भर खुला)");
    } else if (langCode == 'kok') {
      res = res
        .replaceAll("Ministry of Finance", "अर्थ मंत्रालय")
        .replaceAll("Ministry of Micro, Small and Medium Enterprises", "सूक्ष्म, ल्हान आनी मध्यम उद्योग मंत्रालय (MSME)")
        .replaceAll("Ministry of Housing and Urban Affairs", "घराणी आनी शारी कामकाज मंत्रालय")
        .replaceAll("Minimum age criterion met", "उण्यांत उणी पिरायेची अट पुरा जाली")
        .replaceAll("Business sector eligible", "वेवसाय मळ तजविजीक योग्य आसा")
        .replaceAll("Scheme operates in your region", "ही येवजण तुमच्या वाठारांत कार्यान्वीत आसा")
        .replaceAll("(All India)", "(अखिल भारत)")
        .replaceAll("(Transportation & Logistics)", "(येरादारी आनी लॉजिस्टिक्स)")
        .replaceAll("31 Dec 2026 (Open Year-Round)", "31 डिसेंबर 2026 (वर्सभर उഗ്ते)")
        .replaceAll("Loan from Rs. 5,00,001 to Rs. 10,00,000.", "रु. 5,00,001 ते रु. 10,00,000 ची रीण पालव.");
    } else if (langCode == 'mr') {
      res = res
        .replaceAll("Ministry of Finance", "वित्त मंत्रालय")
        .replaceAll("Ministry of Micro, Small and Medium Enterprises", "सूक्ष्म, लघु आणि मध्यम उद्यम मंत्रालय (MSME)")
        .replaceAll("Ministry of Housing and Urban Affairs", "गृहनिर्माण आणि शहरी व्यवहार मंत्रालय")
        .replaceAll("Minimum age criterion met", "किमान वयोमर्यादा पूर्ण")
        .replaceAll("Business sector eligible", "व्यवसाय क्षेत्र पात्र आहे")
        .replaceAll("Scheme operates in your region", "ही योजना तुमच्या क्षेत्रात कार्यरत आहे")
        .replaceAll("(All India)", "(सर्व भारत)")
        .replaceAll("(Transportation & Logistics)", "(वाहतूक आणि लॉजिस्टिक)")
        .replaceAll("31 Dec 2026 (Open Year-Round)", "31 डिसेंबर 2026 (वर्षभर उघडे)");
    } else if (langCode == 'te') {
      res = res
        .replaceAll("Ministry of Finance", "ఆర్థిక మంత్రిత్వ శాఖ")
        .replaceAll("Ministry of Micro, Small and Medium Enterprises", "సూక్ష్మ, చిన్న మరియు మధ్య తరహా పరిశ్రమల మంత్రిత్వ శాఖ")
        .replaceAll("Minimum age criterion met", "కనీస వయస్సు నిబంధన పూర్తయింది")
        .replaceAll("Business sector eligible", "వ్యాపార రంగం అర్హత పొందింది")
        .replaceAll("Scheme operates in your region", "మీ ప్రాంతంలో ఈ పథకం అందుబాటులో ఉంది")
        .replaceAll("(All India)", "(అఖిల భారత)")
        .replaceAll("(Open Year-Round)", "(ఏడాది పొడవునా తెరిచి ఉంటుంది)")
        .replaceAll("Aadhaar & PAN Card", "ఆధార్ & పాన్ కార్డ్")
        .replaceAll("IT Returns for last 2 years", "గత 2 సంవత్సరాల IT రిటర్నులు")
        .replaceAll("Udyam Registration Certificate", "ఉద్యమ్ రిజిస్ట్రేషన్ సర్టిఫికేట్")
        .replaceAll("Project report & 12-month projected financials", "ప్రాజెక్ట్ నివేదిక & 12 నెలల ఆర్థిక అంచనాలు")
        .replaceAll("Identity", "గుర్తింపు")
        .replaceAll("Financial", "ఆర్థిక")
        .replaceAll("Business", "వ్యాపారం");
    } else if (langCode == 'kn') {
      res = res
        .replaceAll("Ministry of Finance", "ಹಣಕಾಸು ಸಚಿವಾಲಯ")
        .replaceAll("Ministry of Micro, Small and Medium Enterprises", "ಸೂಕ್ಷ್ಮ, ಸಣ್ಣ ಮತ್ತು ಮಧ್ಯಮ ಉದ್ಯಮಗಳ ಸಚಿವಾಲಯ")
        .replaceAll("Minimum age criterion met", "ಕನಿಷ್ಠ ವಯಸ್ಸಿನ ಮಾನದಂಡ ಪೂರೈಸಲಾಗಿದೆ")
        .replaceAll("Business sector eligible", "ವ್ಯಾಪಾರ ಕ್ಷೇತ್ರವು ಅರ್ಹವಾಗಿದೆ")
        .replaceAll("Scheme operates in your region", "ನಿಮ್ಮ ಪ್ರದೇಶದಲ್ಲಿ ಈ ಯೋಜನೆ ಲಭ್ಯವಿದೆ")
        .replaceAll("(Open Year-Round)", "(ವರ್ಷಪೂರ್ತಿ ಲಭ್ಯವಿದೆ)");
    } else if (langCode == 'ml') {
      res = res
        .replaceAll("Ministry of Finance", "ധനകാര്യ മന്ത്രാലയം")
        .replaceAll("Ministry of Micro, Small and Medium Enterprises", "മൈക്രോ, സ്മോൾ ആൻഡ് മീഡിയം എന്റർപ്രൈസസ് മന്ത്രാലയം")
        .replaceAll("Minimum age criterion met", "കുറഞ്ഞ പ്രായപരിധി യോഗ്യത നേടി")
        .replaceAll("Business sector eligible", "ബിസിനസ്സ് മേഖല യോഗ്യമാണ്")
        .replaceAll("Scheme operates in your region", "നിങ്ങളുടെ പ്രദേശത്ത് ഈ പദ്ധതി ലഭ്യമാണ്")
        .replaceAll("(Open Year-Round)", "(വർഷം മുഴുവൻ ലഭ്യമാണ്)");
    } else if (langCode == 'bn') {
      res = res
        .replaceAll("Ministry of Finance", "অর্থ মন্ত্রণালয়")
        .replaceAll("Ministry of Micro, Small and Medium Enterprises", "ক্ষুদ্র, ছোট ও মাঝারি শিল্প মন্ত্রণালয়")
        .replaceAll("Minimum age criterion met", "নূন্যতম বয়স মাপকাঠি পূরণ হয়েছে")
        .replaceAll("Business sector eligible", "ব্যবসা খাত যোগ্য")
        .replaceAll("Scheme operates in your region", "আপনার অঞ্চলে এই প্রকল্প চালু আছে")
        .replaceAll("(Open Year-Round)", "(সারা বছর খোলা)");
    } else if (langCode == 'gu') {
      res = res
        .replaceAll("Ministry of Finance", "નાણાં મંત્રાલય")
        .replaceAll("Ministry of Micro, Small and Medium Enterprises", "સૂક્ષ્મ, લઘુ અને મધ્યમ ઉદ્યોગ મંત્રાલય")
        .replaceAll("Minimum age criterion met", "ન્યૂનતમ વય માનદંડ પૂર્ણ")
        .replaceAll("Business sector eligible", "વ્યવસાય ક્ષેત્ર પાત્ર છે")
        .replaceAll("Scheme operates in your region", "આ યોજના તમારા વિસ્તારમાં કાર્યરત છે")
        .replaceAll("(Open Year-Round)", "(આખું વર્ષ ખુલ્લું)");

    final Map<String, Map<String, String>> dict = {
      'ta': {
        "Ministry of Finance": "நிதி அமைச்சகம்",
        "Ministry of Micro, Small and Medium Enterprises": "குறு, சிறு மற்றும் நடுத்தர தொழில் அமைச்சகம் (MSME)",
        "Ministry of Housing and Urban Affairs": "வீட்டுவசதி மற்றும் நகர்ப்புற விவகாரங்கள் அமைச்சகம்",
        "Minimum age criterion met": "குறைந்தபட்ச வயது வரம்பு பூர்த்தியானது",
        "Business sector eligible": "தொழில் துறை தகுதியானது",
        "Scheme operates in your region": "உங்கள் பிராந்தியத்தில் இத்திட்டம் செயல்படுகிறது",
        "State eligibility matched": "மாநில தகுதி பொருந்தியது",
        "Matches your funding requirement": "உங்கள் நிதியுதவி தேவைகளுடன் பொருந்துகிறது",
        "Aadhaar & PAN Card": "ஆதார் மற்றும் பான் கார்டு",
        "IT Returns for last 2 years": "கடந்த 2 ஆண்டுகளுக்கான IT கணக்குలు",
        "Udyam Registration Certificate": "உத்யம் பதிவு சான்றிதழ்",
        "Project report & 12-month projected financials": "திட்ட அறிக்கை மற்றும் 12 மாத நிதி கணிப்பு",
        "Identity": "அடையாளம்",
        "Financial": "நிதி",
        "Business": "வணிகம்",
        "(All India)": "(அனைத்து இந்தியா)",
        "(Open Year-Round)": "(ஆண்டு முழுவதும் திறந்திருக்கும்)"
      },
      'hi': {
        "Ministry of Finance": "वित्त मंत्रालय",
        "Ministry of Micro, Small and Medium Enterprises": "सूक्ष्म, लघु एवं मध्यम उद्यम मंत्रालय (MSME)",
        "Ministry of Housing and Urban Affairs": "आवास और शहरी कार्य मंत्रालय",
        "Minimum age criterion met": "न्यूनतम आयु मानदंड पूरा हुआ",
        "Business sector eligible": "व्यवसाय क्षेत्र पात्र है",
        "Scheme operates in your region": "यह योजना आपके क्षेत्र में संचालित है",
        "State eligibility matched": "राज्य पात्रता का मिलान हुआ",
        "Matches your funding requirement": "आपकी फंडिंग आवश्यकता से मेल खाता है",
        "Aadhaar & PAN Card": "आधार और पैन कार्ड",
        "IT Returns for last 2 years": "पिछले 2 वर्षों का IT रिटर्न",
        "Udyam Registration Certificate": "उद्यम पंजीकरण प्रमाणपत्र",
        "Project report & 12-month projected financials": "प्रोजेक्ट रिपोर्ट और 12 महीने का वित्तीय विवरण",
        "Identity": "पहचान",
        "Financial": "वित्तीय",
        "Business": "व्यवसाय",
        "(All India)": "(अखिल भारतीय)",
        "(Open Year-Round)": "(वर्ष भर खुला)"
      },
      'te': {
        "Ministry of Finance": "ఆర్థిక మంత్రిత్వ శాఖ",
        "Ministry of Micro, Small and Medium Enterprises": "సూక్ష్మ, చిన్న మరియు మధ్య తరహా పరిశ్రమల మంత్రిత్వ శాఖ",
        "Ministry of Housing and Urban Affairs": "పట్టణాభివృద్ధి మంత్రిత్వ శాఖ",
        "Minimum age criterion met": "కనీస వయస్సు నిబంధన పూర్తయింది",
        "Business sector eligible": "వ్యాపార రంగం అర్హత పొందింది",
        "Scheme operates in your region": "మీ ప్రాంతంలో ఈ పథకం అందుబాటులో ఉంది",
        "State eligibility matched": "రాష్ట్ర అర్హత సరిపోలింది",
        "Matches your funding requirement": "మీ ఆర్థిక అవసరాలకు సరిపోతుంది",
        "Aadhaar & PAN Card": "ఆధార్ & పాన్ కార్డ్",
        "IT Returns for last 2 years": "గత 2 సంవత్సరాల IT రిటర్నులు",
        "Udyam Registration Certificate": "ఉద్యమ్ రిజిస్ట్రేషన్ సర్టిఫికేట్",
        "Project report & 12-month projected financials": "ప్రాజెక్ట్ నివేదిక & 12 నెలల ఆర్థిక అంచనాలు",
        "Identity": "గుర్తింపు",
        "Financial": "ఆర్థిక",
        "Business": "వ్యాపారం",
        "(All India)": "(అఖిల భారత)",
        "(Open Year-Round)": "(ఏడాది పొడవునా తెరిచి ఉంటుంది)"
      },
      'bn': {
        "Ministry of Finance": "অর্থ মন্ত্রণালয়",
        "Ministry of Micro, Small and Medium Enterprises": "ক্ষুদ্র, ছোট ও মাঝারি শিল্প মন্ত্রণালয়",
        "Ministry of Housing and Urban Affairs": "আবাসন ও নগর বিষয়ক মন্ত্রণালয়",
        "Minimum age criterion met": "নূন্যতম বয়স মাপকাঠি পূরণ হয়েছে",
        "Business sector eligible": "ব্যবসা খাত যোগ্য",
        "Scheme operates in your region": "আপনার অঞ্চলে এই প্রকল্প চালু আছে",
        "State eligibility matched": "রাজ্যের যোগ্যতা মিলেছে",
        "Matches your funding requirement": "আপনার তহবিলের প্রয়োজনের সাথে মেলে",
        "Aadhaar & PAN Card": "আধার ও প্যান কার্ড",
        "IT Returns for last 2 years": "গত ২ বছরের আইটি রিটার্ন",
        "Udyam Registration Certificate": "উদ্যম রেজিস্ট্রেশন সার্টিফিকেট",
        "Project report & 12-month projected financials": "প্রকল্প রিপোর্ট ও ১২ মাসের আর্থিক হিসাব",
        "Identity": "পরিচয়",
        "Financial": "আর্থিক",
        "Business": "ব্যবসা",
        "(All India)": "(সর্বভারতীয়)",
        "(Open Year-Round)": "(সারা বছর খোলা)"
      },
      'kn': {
        "Ministry of Finance": "ಹಣಕಾಸು ಸಚಿವಾಲಯ",
        "Ministry of Micro, Small and Medium Enterprises": "ಸೂಕ್ಷ್ಮ, ಸಣ್ಣ ಮತ್ತು ಮಧ್ಯಮ ಉದ್ಯಮಗಳ ಸಚಿವಾಲಯ",
        "Ministry of Housing and Urban Affairs": "ವಸತಿ ಮತ್ತು ನಗರ ವ್ಯವಹಾರಗಳ ಸಚಿವಾಲಯ",
        "Minimum age criterion met": "ಕನಿಷ್ಠ ವಯಸ್ಸಿನ ಮಾನದಂಡ ಪೂರೈಸಲಾಗಿದೆ",
        "Business sector eligible": "ವ್ಯಾಪಾರ ಕ್ಷೇತ್ರವು ಅರ್ಹವಾಗಿದೆ",
        "Scheme operates in your region": "ನಿಮ್ಮ ಪ್ರದೇಶದಲ್ಲಿ ಈ ಯೋಜನೆ ಲಭ್ಯವಿದೆ",
        "State eligibility matched": "ರಾಜ್ಯ ಅರ್ಹತೆ ಹೊಂದಾಣಿಕೆಯಾಗಿದೆ",
        "Matches your funding requirement": "ನಿಮ್ಮ ಹಣಕಾಸಿನ ಅಗತ್ಯಕ್ಕೆ ಸೂಕ್ತವಾಗಿದೆ",
        "Aadhaar & PAN Card": "ಆಧಾರ್ ಮತ್ತು ಪಾನ್ ಕಾರ್ಡ್",
        "IT Returns for last 2 years": "ಕಳೆದ 2 ವರ್ಷಗಳ IT ರಿಟರ್ನ್ಸ್",
        "Udyam Registration Certificate": "ಉದ್ಯಮ್ ನೋಂದಣಿ ಪ್ರಮಾಣಪತ್ರ",
        "Project report & 12-month projected financials": "ಪ್ರಾಜೆಕ್ಟ್ ವರದಿ ಮತ್ತು 12 ತಿಂಗಳ ಆರ್ಥಿಕ ಅಂದಾಜು",
        "Identity": "ಗುರುತು",
        "Financial": "ಆರ್ಥಿಕ",
        "Business": "ಉದ್ಯಮ",
        "(All India)": "(ಅಖಿಲ ಭಾರತ)",
        "(Open Year-Round)": "(ವರ್ಷಪೂರ್ತಿ ಲಭ್ಯವಿದೆ)"
      },
      'ml': {
        "Ministry of Finance": "ധനകാര്യ മന്ത്രാലയം",
        "Ministry of Micro, Small and Medium Enterprises": "എംഎസ്എംഇ മന്ത്രാലയം",
        "Ministry of Housing and Urban Affairs": "ഭവന വികസന മന്ത്രാലയം",
        "Minimum age criterion met": "കുറഞ്ഞ പ്രായപരിധി യോഗ്യത നേടി",
        "Business sector eligible": "ബിസിനസ്സ് മേഖല യോഗ്യമാണ്",
        "Scheme operates in your region": "നിങ്ങളുടെ പ്രദേശത്ത് ഈ പദ്ധതി ലഭ്യമാണ്",
        "State eligibility matched": "സംസ്ഥാന യോഗ്യത പൊരുത്തപ്പെട്ടു",
        "Matches your funding requirement": "നിങ്ങളുടെ സാമ്പത്തിക ആവശ്യത്തിന് അനുയോജ്യം",
        "Aadhaar & PAN Card": "ആധാർ & പാൻ കാർഡ്",
        "IT Returns for last 2 years": "കഴിഞ്ഞ 2 വർഷത്തെ IT റിട്ടേണുകൾ",
        "Udyam Registration Certificate": "ഉദ്യം രജിസ്ട്രേഷൻ സർട്ടിഫിക്കറ്റ്",
        "Project report & 12-month projected financials": "പ്രോജക്ട് റിപ്പോർട്ടും സാമ്പത്തിക കണക്കുകളും",
        "Identity": "തിരിച്ചറിയൽ",
        "Financial": "സാമ്പത്തികം",
        "Business": "ബിസിനസ്സ്",
        "(All India)": "(ആൾ ഇന്ത്യ)",
        "(Open Year-Round)": "(വർഷം മുഴുവൻ ലഭ്യമാണ്)"
      },
      'mr': {
        "Ministry of Finance": "वित्त मंत्रालय",
        "Ministry of Micro, Small and Medium Enterprises": "सूक्ष्म, लघु आणि मध्यम उद्यम मंत्रालय",
        "Ministry of Housing and Urban Affairs": "गृहनिर्माण आणि शहरी व्यवहार मंत्रालय",
        "Minimum age criterion met": "किमान वयोमर्यादा पूर्ण",
        "Business sector eligible": "व्यवसाय क्षेत्र पात्र आहे",
        "Scheme operates in your region": "ही योजना तुमच्या क्षेत्रात कार्यरत आहे",
        "State eligibility matched": "राज्य पात्रता जुळली",
        "Matches your funding requirement": "तुमच्या निधीच्या गरजेनुसार योग्य",
        "Aadhaar & PAN Card": "आधार आणि पॅन कार्ड",
        "IT Returns for last 2 years": "मागील २ वर्षांचे IT रिटर्न",
        "Udyam Registration Certificate": "उद्यम नोंदणी प्रमाणपत्र",
        "Project report & 12-month projected financials": "प्रकल्प अहवाल आणि १२ महिन्यांचे आर्थिक अंदाज",
        "Identity": "ओळख",
        "Financial": "आर्थिक",
        "Business": "व्यवसाय",
        "(All India)": "(सर्व भारत)",
        "(Open Year-Round)": "(वर्षभर उघडे)"
      },
      'gu': {
        "Ministry of Finance": "નાણાં મંત્રાલય",
        "Ministry of Micro, Small and Medium Enterprises": "સૂક્ષ્મ, લઘુ અને મધ્યમ ઉદ્યોગ મંત્રાલય",
        "Ministry of Housing and Urban Affairs": "આવાસ અને શહેરી બાબતોનું મંત્રાલય",
        "Minimum age criterion met": "ન્યૂનતમ વય માનદંડ પૂર્ણ",
        "Business sector eligible": "વ્યવસાય ક્ષેત્ર પાત્ર છે",
        "Scheme operates in your region": "આ યોજના તમારા વિસ્તારમાં કાર્યરત છે",
        "State eligibility matched": "રાજ્યની પાત્રતા યોગ્ય છે",
        "Matches your funding requirement": "તમારી ફંડિંગ જરૂરિયાત મુજબ",
        "Aadhaar & PAN Card": "આધાર અને પાન કાર્ડ",
        "IT Returns for last 2 years": "છેલ્લા ૨ વર્ષનું IT રિટર્ન",
        "Udyam Registration Certificate": "ઉદ્યમ નોંધણી પ્રમાણપત્ર",
        "Project report & 12-month projected financials": "પ્રોજેક્ટ રિપોર્ટ અને ૧૨ મહિનાનો આર્થિક અંદાજ",
        "Identity": "ઓળખ",
        "Financial": "નાણાકીય",
        "Business": "વ્યવસાય",
        "(All India)": "(અખિલ ભારતીય)",
        "(Open Year-Round)": "(આખું વર્ષ ખુલ્લું)"
      },
      'as': {
        "Ministry of Finance": "বিত্ত মন্ত্ৰালয়",
        "Ministry of Micro, Small and Medium Enterprises": "MSME মন্ত্ৰালয়",
        "Ministry of Housing and Urban Affairs": "গৃহনিৰ্মাণ আৰু নগৰ পৰিক্ৰমা মন্ত্ৰালয়",
        "Minimum age criterion met": "নূন্যতম বয়সৰ মাপকাঠি পূৰণ হৈছে",
        "Business sector eligible": "ব্যৱસાય খণ্ড উপযুক্ত",
        "Scheme operates in your region": "আপোনাৰ অঞ্চলত এই আঁচনি কাৰ্যকৰী",
        "State eligibility matched": "ৰাজ্যিক যোগ্যতা মিলিছে",
        "Matches your funding requirement": "আপোনাৰ পুঁজিৰ প্ৰয়োজনৰ সৈতে খাপ খায়",
        "Aadhaar & PAN Card": "আধাৰ আৰু পান কাৰ্ড",
        "IT Returns for last 2 years": "বিগত ২ বছৰৰ IT ৰিটাৰ্ন",
        "Udyam Registration Certificate": "উদ্যম পঞ্জীয়ন প্ৰমাণপত্ৰ",
        "Project report & 12-month projected financials": "প্ৰকল্প প্ৰতিবেদন আৰু ১২ মাহৰ বিত্তীয় হিসাব",
        "Identity": "পৰিচয়",
        "Financial": "বিত্তীয়",
        "Business": "ব্যৱસાય",
        "(All India)": "(সমগ্ৰ ভাৰত)",
        "(Open Year-Round)": "(বছৰজুৰি খোলা)"
      },
      'ur': {
        "Ministry of Finance": "وزارت مالیات",
        "Ministry of Micro, Small and Medium Enterprises": "وزارت MSME",
        "Ministry of Housing and Urban Affairs": "وزارت رہائش و شہری امور",
        "Minimum age criterion met": "کم از کم عمر کا معیار پورا ہے",
        "Business sector eligible": "کاروباری شعبہ اہل ہے",
        "Scheme operates in your region": "اسکیم آپ کے علاقے میں فعال ہے",
        "State eligibility matched": "ریاستی اہلیت مطابق ہے",
        "Matches your funding requirement": "آپ کی مالی ضروریات کے مطابق",
        "Aadhaar & PAN Card": "آدھار اور پین کارڈ",
        "IT Returns for last 2 years": "گزشتہ 2 سالوں کے IT ریٹرنز",
        "Udyam Registration Certificate": "ادیم رجسٹریشن سرٹیفکیٹ",
        "Project report & 12-month projected financials": "پروجیکٹ رپورٹ اور 12 مہینے کا تخمینہ",
        "Identity": "شناخت",
        "Financial": "مالیاتی",
        "Business": "کاروبار",
        "(All India)": "(پورے ہندوستان میں)",
        "(Open Year-Round)": "(سال بھر جاری)"
      },
      'or': {
        "Ministry of Finance": "ଅର୍ଥ ମନ୍ତ୍ରଣାଳୟ",
        "Ministry of Micro, Small and Medium Enterprises": "MSME ମନ୍ତ୍ରଣାଳୟ",
        "Ministry of Housing and Urban Affairs": "ନଗର ଉନ୍ନୟନ ମନ୍ତ୍ରଣାଳୟ",
        "Minimum age criterion met": "ନୂନ୍ଯତମ ବୟସ ଯୋଗ୍ୟତା ପୂରଣ ହୋଇଛି",
        "Business sector eligible": "ବ୍ୟବସାୟ କ୍ଷେତ୍ର ଯୋଗ୍ୟ",
        "Scheme operates in your region": "ଆପଣଙ୍କ ଅଞ୍ଚଳରେ ଯୋଜନା ସକ୍ରିୟ",
        "State eligibility matched": "ରାଜ୍ୟ ଯୋଗ୍ୟତା ମିଳିଛି",
        "Matches your funding requirement": "ଆପଣଙ୍କ ଆର୍ଥିକ ଆବଶ୍ୟକତା ସହ ମେଳ ଖାଉଛି",
        "Aadhaar & PAN Card": "ଆଧାର ଏବଂ ପାନ୍ କାର୍ଡ",
        "IT Returns for last 2 years": "ଗତ ୨ ବର୍ଷର IT ରିଟର୍ନ୍",
        "Udyam Registration Certificate": "ଉଦ୍ୟମ ପଞ୍ଜୀକରଣ ପ୍ରମାଣପତ୍ର",
        "Project report & 12-month projected financials": "ପ୍ରକଳ୍ପ ରିପୋର୍ଟ ଏବଂ ୧୨ ମାସର ଆର୍ଥିକ ଅନୁମାନ",
        "Identity": "ପରିଚୟ",
        "Financial": "ଆର୍ଥିକ",
        "Business": "ବ୍ୟବସାୟ",
        "(All India)": "(ସମଗ୍ର ଭାରତ)",
        "(Open Year-Round)": "(ସାରା ବର୍ଷ ଖୋଲା)"
      },
      'pa': {
        "Ministry of Finance": "ਵਿੱਤ ਮੰਤਰਾਲਾ",
        "Ministry of Micro, Small and Medium Enterprises": "MSME ਮੰਤਰਾਲਾ",
        "Ministry of Housing and Urban Affairs": "ਸ਼ਹਿਰੀ ਵਿਕਾਸ ਮੰਤਰਾਲਾ",
        "Minimum age criterion met": "ਘੱਟੋ-ਘੱਟ ਉਮਰ ਪੂਰੀ ਹੈ",
        "Business sector eligible": "ਕਾਰੋਬਾਰ ਖੇਤਰ ਯੋਗ ਹੈ",
        "Scheme operates in your region": "ਇਹ ਸਕੀਮ ਤੁਹਾਡੇ ਖੇਤਰ ਵਿੱਚ ਲਾਗੂ ਹੈ",
        "State eligibility matched": "ਰਾਜ ਦੀ ਯੋਗਤਾ ਪੂਰੀ ਹੈ",
        "Matches your funding requirement": "ਤੁਹਾਡੀ ਫੰਡ ਦੀ ਲੋੜ ਨਾਲ ਮੇਲ ਖਾਂਦਾ ਹੈ",
        "Aadhaar & PAN Card": "ਆਧਾਰ ਅਤੇ ਪੈਨ ਕਾਰਡ",
        "IT Returns for last 2 years": "ਪਿਛਲੇ 2 ਸਾਲਾਂ ਦੀਆਂ IT ਰਿਟਰਨਾਂ",
        "Udyam Registration Certificate": "ਉਦਯਮ ਰਜਿਸਟ੍ਰੇਸ਼ਨ ਸਰਟੀਫਿਕੇਟ",
        "Project report & 12-month projected financials": "ਪ੍ਰੋਜੈਕਟ ਰਿਪੋਰਟ ਅਤੇ 12 ਮਹੀਨਿਆਂ ਦਾ ਵਿੱਤੀ ਵੇਰਵਾ",
        "Identity": "ਪਛਾਣ",
        "Financial": "ਵਿੱਤੀ",
        "Business": "ਕਾਰੋਬਾਰ",
        "(All India)": "(ਪੂਰੇ ਭਾਰਤ ਵਿੱਚ)",
        "(Open Year-Round)": "(ਸਾਰਾ ਸਾਲ ਖੁੱਲ੍ਹਾ)"
      }
    };

    final langDict = dict[langCode];
    if (langDict != null) {
      langDict.forEach((key, val) {
        res = res.replaceAll(key, val);
      });
    }

    return res;
    return SchemeTranslationHelper.localize(input, langCode);
  }

  @override
  Widget build(BuildContext context) {
    final localeProv = Provider.of<LocaleProvider>(context);
    final currentLang = localeProv.languageCode;

    final String schemeName = scheme['scheme_name'] ?? '';
    final String ministry = scheme['ministry'] ?? '';
    final String benefits = (scheme['key_benefits'] ?? scheme['benefits'] ?? '').toString();
    final String eligibility = (scheme['eligibility_summary'] ?? '').toString();
    final List<dynamic> whyMatches = scheme['why_matches'] as List<dynamic>? ?? [];

    // Parse required documents
    List<dynamic> requiredDocs = [];
    final rawDocs = scheme['required_documents'];
    if (rawDocs is List) {
      requiredDocs = rawDocs;
    }

    return Scaffold(
      appBar: GovTopHeader(
        title: context.tr("required_details_title"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Scheme header card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withOpacity(0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    schemeName,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _localizeReqText(ministry, currentLang),
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  if (benefits.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      _localizeReqText(benefits, currentLang),
                      style: const TextStyle(fontSize: 13, color: Colors.black87),
                    ),
                  ],
                  if (eligibility.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      _localizeReqText(eligibility, currentLang),
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.event_available, color: Colors.red, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "${context.tr('last_date')}: ${_localizeReqText(scheme['last_date_to_apply'] ?? '31 Dec 2026 (Open Year-Round)', currentLang)}",
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FinancialCalculatorScreen(prefillScheme: scheme),
                              ),
                            );
                          },
                          icon: const Icon(Icons.calculate, size: 16, color: AppTheme.primaryBlue),
                          label: Text(
                            context.tr('calculate_emi'),
                            style: const TextStyle(fontSize: 12, color: AppTheme.primaryBlue, fontWeight: FontWeight.bold),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppTheme.primaryBlue),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PartnerLocatorScreen(initialSchemeName: schemeName),
                              ),
                            );
                          },
                          icon: const Icon(Icons.near_me, size: 16, color: AppTheme.successGreen),
                          label: Text(
                            context.tr('locate_partner'),
                            style: const TextStyle(fontSize: 12, color: AppTheme.successGreen, fontWeight: FontWeight.bold),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppTheme.successGreen),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Why it matches you
            if (whyMatches.isNotEmpty) ...[
              Text(
                context.tr("why_matches_heading"),
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ...whyMatches.map((w) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check_circle, color: AppTheme.successGreen, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _localizeReqText(w.toString(), currentLang),
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppTheme.successGreen,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
              const SizedBox(height: 20),
            ],

            // Required certificates & documents
            Text(
              context.tr("required_certificates_heading"),
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              context.tr("prepare_before_applying"),
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 12),

            if (requiredDocs.isEmpty)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Text(
                  context.tr("standard_kyc_note"),
                  style: const TextStyle(fontSize: 14),
                ),
              )
            else
              ...requiredDocs.asMap().entries.map((entry) {
                final doc = entry.value;
                final String docName = doc is Map ? (doc['name'] ?? '').toString() : doc.toString();
                final String docType = doc is Map ? (doc['type'] ?? '').toString() : '';
                final bool mandatory = doc is Map ? doc['mandatory'] == true : true;

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: mandatory ? AppTheme.primaryBlue.withOpacity(0.3) : Colors.grey.shade300,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        mandatory ? Icons.description_rounded : Icons.description_outlined,
                        color: mandatory ? AppTheme.primaryBlue : Colors.grey,
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _localizeReqText(docName, currentLang),
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                            ),
                            if (docType.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                _localizeReqText(docType, currentLang),
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: mandatory
                              ? Colors.red.shade50
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          mandatory ? context.tr("badge_required") : context.tr("badge_optional"),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: mandatory ? Colors.red.shade700 : Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),

            const SizedBox(height: 30),

            // Apply button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _applyForScheme(context),
                icon: const Icon(Icons.launch_rounded),
                label: Text(
                  context.tr("apply_online_btn"),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                context.tr("redirect_notice"),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
