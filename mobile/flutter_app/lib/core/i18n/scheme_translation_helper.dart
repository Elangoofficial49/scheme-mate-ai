import 'app_localizations.dart';

class SchemeTranslationHelper {
  static String localize(String input, String langCode) {
    if (input.isEmpty || langCode == 'en') return input;
    String res = input;

    // Direct string replacements for exact and partial matches
    res = _translateBenefit(res, langCode);
    res = _translateSummary(res, langCode);
    res = _translateSchemeName(res, langCode);
    res = _translateMinistry(res, langCode);
    res = _translateTag(res, langCode);

    return res;
  }

  // 1. Benefits & Descriptions Translation across all 23 languages
  static String _translateBenefit(String text, String lang) {
    // PM Vishwakarma benefit
    if (text.contains("15,000") && text.contains("toolkit") && text.contains("stipend")) {
      switch (lang) {
        case 'hi': case 'mr': case 'kok': case 'mai': case 'ne': case 'sa': case 'doi':
          return "रु. 15,000 टूलकिट वाउचर, 5-7 दिन का मुफ़्त प्रशिक्षण, रु. 500/दिन वज़ीफ़ा और 5% रियायती ब्याज पर रु. 3 लाख तक का गारंटी-मुक्त ऋण।";
        case 'ta':
          return "ரூ. 15,000 கருவித்தொகுப்பு டிஜிட்டல் வவுச்சர், நாள் ஒன்றுக்கு ரூ. 500 ஊக்கத்தொகையுடன் 5-7 நாட்கள் பயிற்சி, 5% வட்டியில் ரூ. 3 லட்சம் வரை பிணையமற்ற கடன்.";
        case 'te':
          return "రూ. 15,000 టూల్‌కిట్ డిజిటల్ వోచర్, రోజుకు రూ. 500 స్టైపెండ్‌తో 5-7 రోజుల శిక్షణ, 5% వడ్డీతో రూ. 3 లక్షల వరకు పూచీకత్తు లేని రుణం.";
        case 'kn':
          return "ರೂ. 15,000 ಟೂಲ್‌ಕಿಟ್ ವೋಚರ್, ದಿನಕ್ಕೆ ರೂ. 500 ಸ್ಟೈಪೆಂಡ್‌ನೊಂದಿಗೆ 5-7 ದಿನಗಳ ತರಬೇತಿ, 5% ಬಡ್ಡಿದರದಲ್ಲಿ ರೂ. 3 ಲಕ್ಷದವರೆಗೆ ಶ್ಯೂರಿಟಿ-ರಹಿತ ಸಾಲ.";
        case 'ml':
          return "10,000 രൂപ മുതൽ 15,000 രൂപ വരെയുള്ള ടൂൾകിറ്റ് വൗച്ചർ, ദിവസേന 500 രൂപ സ്റ്റൈപ്പന്റോടെ സൗജന്യ പരിശീലനം, 5% കുറഞ്ഞ പലിശ നിരക്കിൽ 3 ലക്ഷം രൂപ വരെ ഈടില്ലാത്ത വായ്പ.";
        case 'bn': case 'as':
          return "১৫,০০০ টাকার টুলকিট ভাউচার, প্রতিদিন ৫০০ টাকা বৃত্তিসহ ৫-৭ দিনের প্রশিক্ষণ, ৫% সুদে ৩ লাখ টাকা পর্যন্ত জামানতহীন ঋণ।";
        case 'gu':
          return "રૂ. ૧૫,૦૦૦ ટૂલકિટ વાઉચર, રૂ. ૫૦૦/દિવસના સ્ટાઇપેન્ડ સાથે તાલીમ, ૫% વ્યાજે રૂ. ૩ લાખ સુધીની વગર ગેરંટીની લોન.";
        case 'ur': case 'ks': case 'sd':
          return "15,000 روپے کا ٹول کٹ واؤچر، 500 روپے یومیہ وظیفہ کے ساتھ تربیت، 5% سود پر 3 لاکھ روپے تک کا بلا ضمانت قرض۔";
        case 'or':
          return "୧୫,୦୦୦ ଟଙ୍କାର ଟୁଲକିଟ୍ ଭାଉଚର, ପ୍ରତିଦିନ ୫୦୦ ଟଙ୍କା ଷ୍ଟାଇପେଣ୍ଡ ସହ ତାଲିମ, ୫% ସୁଧରେ ୩ ଲକ୍ଷ ଟଙ୍କା ପର୍ଯ୍ୟନ୍ତ ବିନା ଗ୍ୟାରେଣ୍ଟି ଋଣ।";
        case 'pa':
          return "ਰੁ. 15,000 ਟੂਲਕਿੱਟ ਵਾਊਚਰ, ਰੋਜ਼ਾਨਾ ਰੁ. 500 ਸਟਾਈਪੈਂਡ ਨਾਲ ਸਿਖਲਾਈ, 5% ਵਿਆਜ 'ਤੇ ਰੁ. 3 ਲੱਖ ਤੱਕ ਦਾ ਬਿਨਾਂ ਗਾਰੰਟੀ ਕਰਜ਼ਾ।";
        default:
          return "रु. 15,000 टूलकिट वाउचर, 5-7 दिन का मुफ़्त प्रशिक्षण, रु. 500/दिन वज़ीफ़ा और 5% रियायती ब्याज पर रु. 3 लाख तक का गारंटी-मुक्त ऋण।";
      }
    }

    // PM SVANidhi benefit
    if (text.contains("Working capital loan") || text.contains("SVANidhi") || (text.contains("10,000") && text.contains("tranche"))) {
      switch (lang) {
        case 'hi': case 'mr': case 'kok': case 'mai': case 'ne': case 'sa': case 'doi':
          return "7% ब्याज सब्सिडी और डिजिटल लेनदेन पर कैशबैक के साथ रु. 10,000 (प्रथम किस्त), रु. 20,000 (द्वितीय किस्त) और रु. 50,000 (तृतीय किस्त) का कार्यशील पूंजी ऋण।";
        case 'ta':
          return "7% வட்டி மானியம் மற்றும் டிஜிட்டல் பணப்பரிவர்த்தனைக்கு கேஷ்பேக் உடன் ரூ. 10,000 (1வது தவணை), ரூ. 20,000 (2வது தவணை), ரூ. 50,000 (3வது தவணை) நடைமுறை மூலதனக் கடன்.";
        case 'te':
          return "7% వడ్డీ రాయితీ మరియు డిజిటల్ లావాదేవీలపై క్యాష్‌బ్యాక్‌తో రూ. 10,000 (1వ విడత), రూ. 20,000 (2వ విడత), రూ. 50,000 (3వ విడత) వర్కింగ్ క్యాపిటల్ లోన్.";
        case 'kn':
          return "7% ಬಡ್ಡಿ ಸಬ್ಸಿಡಿಯೊಂದಿಗೆ ರೂ. 10,000 (1ನೇ ಕಂತು), ರೂ. 20,000 (2ನೇ ಕಂತು) ಮತ್ತು ರೂ. 50,000 (3ನೇ ಕಂತು) ದುಡಿಯುವ ಬಂಡವಾಳ ಸಾಲ.";
        case 'ml':
          return "7% പലിശ ഇളവോടും ഡിജിറ്റൽ ക്യാഷ്ബാക്കോടും കൂടി 10,000 രൂപ (ഒന്നാം ഗഡു), 20,000 രൂപ (രണ്ടാം ഗഡു), 50,000 രൂപ (മൂന്നാം ഗഡു) വായ്പ.";
        case 'bn': case 'as':
          return "৭% সুদ ছাড় ও ডিজিটাল ক্যাশব্যাকসহ ১০,০০০ টাকা (১ম কিস্তি), ২০,০০০ টাকা (২য় কিস্তি) এবং ৫০,০০০ টাকা (৩য় কিস্তি) চলতি মূলধন ঋণ।";
        case 'gu':
          return "૭% વ્યાજ સબસીડી સાથે રૂ. ૧૦,૦૦૦ (પ્રથમ હપ્તો), રૂ. ૨૦,૦૦૦ (બીજો હપ્તો) અને રૂ. ૫૦,૦૦૦ (ત્રીજો હપ્તો) ની કાર્યકારી મૂડી લોન.";
        case 'ur': case 'ks': case 'sd':
          return "7% سود کی چھوٹ کے ساتھ 10,000 روپے (پہلی قسط)، 20,000 روپے (دوسری قسط)، اور 50,000 روپے (تیسری قسط) کا ورکنگ کیپیٹل قرض۔";
        case 'or':
          return "୭% ସୁଧ ସବସିଡି ସହ ୧୦,୦୦୦ ଟଙ୍କା (୧ମ କିସ୍ତି), ୨୦,୦୦୦ ଟଙ୍କା (୨ୟ କିସ୍ତି) ଏବଂ ୫୦,୦୦୦ ଟଙ୍କା (୩ୟ କିସ୍ତି) ଚଳନ୍ତି ପୁଞ୍ଜି ଋଣ।";
        case 'pa':
          return "7% ਵਿਆਜ ਛੋਟ ਨਾਲ ਰੁ. 10,000 (ਪਹਿਲੀ ਕਿਸ਼ਤ), ਰੁ. 20,000 (ਦੂਜੀ ਕਿਸ਼ਤ) ਅਤੇ ਰੁ. 50,000 (ਤੀਜੀ ਕਿਸ਼ਤ) ਦਾ ਕੰਮਕਾਜੀ ਪੂੰਜੀ ਕਰਜ਼ਾ।";
        default:
          return "7% ब्याज सब्सिडी और डिजिटल लेनदेन पर कैशबैक के साथ रु. 10,000 (प्रथम किस्त), रु. 20,000 (द्वितीय किस्त) और रु. 50,000 (तृतीय किस्त) का कार्यशील पूंजी ऋण।";
      }
    }

    // CGTMSE benefit
    if (text.contains("Collateral-free credit facility up to Rs. 5 Crore") || text.contains("5 Crore") || text.contains("guarantee cover")) {
      switch (lang) {
        case 'hi': case 'mr': case 'kok': case 'mai': case 'ne': case 'sa': case 'doi':
          return "महिला/SC/ST/महत्वाकांक्षी जिलों के उद्यमियों के लिए 85% गारंटी कवर के साथ रु. 5 करोड़ तक की गारंटी-मुक्त क्रेडिट सुविधा।";
        case 'ta':
          return "பெண்கள்/SC/ST தொழில்முனைவோருக்கு 85% வரை உத்தரவாதத்துடன் ரூ. 5 கோடி வரை பிணையமற்ற கடன் வசதி.";
        case 'te':
          return "మహిళలు/SC/ST పారిశ్రామికవేత్తలకు 85% గ్యారెంటీ కవర్‌తో రూ. 5 కోట్ల వరకు పూచీకత్తు లేని క్రెడిట్ సదుపాయం.";
        case 'kn':
          return "ಮಹಿಳೆಯರು/SC/ST ಉದ್ಯಮಿಗಳಿಗೆ 85% ಗ್ಯಾರಂಟಿ ಕವರ್‌ನೊಂದಿಗೆ ರೂ. 5 ಕೋಟಿವರೆಗೂ ಶ್ಯೂರಿಟಿ-ರಹಿತ ಕ್ರೆಡಿಟ್ ಸೌಲಭ್ಯ.";
        case 'ml':
          return "വനിതകൾ/SC/ST സംരംഭകർക്ക് 85% വരെ ഗ്യാരണ്ടിയോടെ 5 കോടി രൂപ വരെ ഈടില്ലാത്ത ക്രെഡിറ്റ് സൗകര്യം.";
        case 'bn': case 'as':
          return "মহিলা/SC/ST উদ্যোক্তাদের জন্য ৮৫% গ্যারান্টি কভার সহ ৫ কোটি টাকা পর্যন্ত জামানতহীন ক্রেডিট সুবিধা।";
        case 'gu':
          return "મહિલાઓ/SC/ST ઉદ્યોગસાહસિકો માટે ૮૫% ગેરંટી કવર સાથે રૂ. ૫ કરોડ સુધીની વગર ગેરંટી ક્રેડિટ સુવિધા.";
        case 'ur': case 'ks': case 'sd':
          return "خواتین/SC/ST تاجروں کے لیے 85% ضمانت کے ساتھ 5 کروڑ روپے تک کی بلا ضمانت کریڈٹ سہولت۔";
        case 'or':
          return "ମହିଳା/SC/ST ଉଦ୍ୟମୀଙ୍କ ପାଇଁ ୮୫% ଗ୍ୟାରେଣ୍ଟି ସହ ୫ କୋଟି ଟଙ୍କା ପର୍ଯ୍ୟନ୍ତ ବିନା ଗ୍ୟାରେଣ୍ଟି କ୍ରେଡିଟ୍ ସୁବିଧା।";
        case 'pa':
          return "ਔਰਤਾਂ/SC/ST ਉੱਦਮੀਆਂ ਲਈ 85% ਗਾਰੰਟੀ ਕਵਰ ਨਾਲ ਰੁ. 5 ਕਰੋੜ ਤੱਕ ਦੀ ਬਿਨਾਂ ਗਾਰੰਟੀ ਕ੍ਰੈਡਿਟ ਸਹੂਲਤ।";
        default:
          return "महिला/SC/ST/महत्वाकांक्षी जिलों के उद्यमियों के लिए 85% गारंटी कवर के साथ रु. 5 करोड़ तक की गारंटी-मुक्त क्रेडिट सुविधा।";
      }
    }

    // PMFME benefit
    if (text.contains("35%") && (text.contains("10 Lakhs") || text.contains("10 Lakh"))) {
      switch (lang) {
        case 'hi': case 'mr': case 'kok': case 'mai': case 'ne': case 'sa': case 'doi':
          return "पात्र परियोजना लागत का 35% (अधिकतम रु. 10 लाख) क्रेडिट-लिंक्ड पूंजी सब्सिडी।";
        case 'ta':
          return "ரூ. 10 லட்சம் வரை தகுதியான திட்டச் செலவில் 35% மூலதன மானியம்.";
        case 'te':
          return "రూ. 10 లక్షల వరకు ప్రాజెక్ట్ వ్యయంలో 35% క్రెడిట్-లింక్డ్ మూలధన సబ్సిడీ.";
        case 'kn':
          return "ಅರ್ಹ ಯೋಜನೆ ವೆಚ್ಚದ 35% (ಗರಿಷ್ಠ ರೂ. 10 ಲಕ್ಷ) ಬಂಡವಾಳ ಸಬ್ಸಿಡಿ.";
        case 'ml':
          return "10 ലക്ഷം രൂപ വരെ യോഗ്യമായ പ്രോജക്ട് ചെലവിന്റെ 35% സബ്‌സിഡി.";
        case 'bn': case 'as':
          return "যোগ্য প্রকল্প ব্যয়ের ৩৫% (সর্বোচ্চ ১০ লাখ টাকা) মূলধন ভোজ্য ভর্তুকি।";
        case 'gu':
          return "પાત્ર પ્રોજેક્ટ ખર્ચના ૩૫% (મહત્તમ ૧૦ લાખ) કેપિટલ સબસીડી.";
        case 'ur': case 'ks': case 'sd':
          return "پروجیکٹ لاگت کا 35% (زیادہ سے زیادہ 10 لاکھ روپے) کیپیٹل سبسیڈی۔";
        case 'or':
          return "ପ୍ରକଳ୍ପ ଖର୍ଚ୍ଚର ୩୫% (ସର୍ବାଧିକ ୧୦ ଲକ୍ଷ ଟଙ୍କା) ସବସିଡି।";
        case 'pa':
          return "ਪ੍ਰੋਜੈਕਟ ਲਾਗਤ ਦਾ 35% (ਵੱਧ ਤੋਂ ਵੱਧ 10 ਲੱਖ ਰੁਪਏ) ਕੈਪੀਟਲ ਸਬਸਿਡੀ।";
        default:
          return "पात्र परियोजना लागत का 35% (अधिकतम रु. 10 लाख) क्रेडिट-लिंक्ड पूंजी सब्सिडी।";
      }
    }

    // NEEDS benefit
    if (text.contains("75 Lakhs") && text.contains("3%")) {
      switch (lang) {
        case 'hi': case 'mr': case 'kok': case 'mai': case 'ne': case 'sa': case 'doi':
          return "रु. 75 लाख तक 25% पूंजी सब्सिडी और 3% ब्याज अनुदान।";
        case 'ta':
          return "ரூ. 75 லட்சம் வரை 25% மூலதன மானியம் மற்றும் 3% வட்டி மானியம்.";
        case 'te':
          return "రూ. 75 లక్షల వరకు 25% మూలధన సబ్సిడీ మరియు 3% వడ్డీ రాయితీ.";
        case 'kn':
          return "ರೂ. 75 ಲಕ್ಷದವರೆಗೆ 25% ಬಂಡವಾಳ ಸಬ್ಸಿಡಿ ಮತ್ತು 3% ಬಡ್ಡಿ ರಿಯಾಯಿತಿ.";
        case 'ml':
          return "75 ലക്ഷം രൂപ വരെ 25% മൂലധന സബ്‌സിഡിയും 3% പലിശ ഇളവും.";
        case 'bn': case 'as':
          return "৭৫ লাখ টাকা পর্যন্ত ২৫% মূলধন ভর্তুকি এবং ৩% সুদ ছাড়।";
        case 'gu':
          return "૭૫ લાખ સુધી ૨૫% કેપિટલ સબસીડી અને ૩% વ્યાજ રાહત.";
        case 'ur': case 'ks': case 'sd':
          return "75 لاکھ روپے تک 25% کیپیٹل سبسیڈی اور 3% سود کی رعایت۔";
        case 'or':
          return "୭୫ ଲକ୍ଷ ଟଙ୍କା ପର୍ଯ୍ୟନ୍ତ ୨୫% ମୂଳଧନ ସବସିଡି।";
        case 'pa':
          return "75 ਲੱਖ ਰੁਪਏ ਤੱਕ 25% ਸਬਸਿਡੀ ਅਤੇ 3% ਵਿਆਜ ਛੋਟ।";
        default:
          return "रु. 75 लाख तक 25% पूंजी सब्सिडी और 3% ब्याज अनुदान।";
      }
    }

    // PMEGP benefit
    if (text.contains("15% to 35%") || text.contains("50 Lakhs for manufacturing")) {
      switch (lang) {
        case 'hi': case 'mr': case 'kok': case 'mai': case 'ne': case 'sa': case 'doi':
          return "विनिर्माण के लिए रु. 50 लाख और सेवा क्षेत्र के लिए रु. 20 लाख तक 15% से 35% सब्सिडी।";
        case 'ta':
          return "உற்பத்தித் துறைக்கு ரூ. 50 லட்சம் மற்றும் சேவைத் துறைக்கு ரூ. 20 லட்சம் வரை 15% முதல் 35% வரை மானியம்.";
        case 'te':
          return "తయారీ రంగానికి రూ. 50 లక్షలు మరియు సేవా రంగానికి రూ. 20 లక్షల వరకు 15% నుండి 35% సబ్సిడీ.";
        case 'kn':
          return "ತಯಾರಿಕೆ ವಲಯಕ್ಕೆ ರೂ. 50 ಲಕ್ಷ ಮತ್ತು ಸೇವಾ ವಲಯಕ್ಕೆ ರೂ. 20 ಲಕ್ಷದವರೆಗೆ 15% ರಿಂದ 35% ಸಬ್ಸಿಡಿ.";
        case 'ml':
          return "ഉൽപ്പാദന മേഖലയ്ക്ക് 50 ലക്ഷം രൂപ വരെയും സേവന മേഖലയ്ക്ക് 20 ലക്ഷം രൂപ വരെയും 15% മുതൽ 35% വരെ സബ്‌സിഡി.";
        case 'bn': case 'as':
          return "উৎপাদন খাতের জন্য ৫০ লাখ এবং সেবা খাতের জন্য ২০ লাখ টাকা পর্যন্ত ১৫% থেকে ৩৫% ভর্তুকি।";
        case 'gu':
          return "ઉત્પાદન માટે રૂ. ૫૦ લાખ અને સેવા ક્ષેત્ર માટે રૂ. ૨૦ લાખ સુધી ૧૫% થી ૩૫% સબસીડી.";
        case 'ur': case 'ks': case 'sd':
          return "مینوفیکچرنگ کے لیے 50 لاکھ روپے اور سروس سیکٹر کے لیے 20 لاکھ روپے تک 15% سے 35% سبسیڈی۔";
        case 'or':
          return "ନିର୍ମାଣ କ୍ଷେତ୍ର ପାଇଁ ୫୦ ଲକ୍ଷ ଏବଂ ସେବା କ୍ଷେତ୍ର ପାଇଁ ୨୦ ଲକ୍ଷ ଟଙ୍କା ପର୍ଯ୍ୟନ୍ତ ୧୫% ରୁ ୩୫% ସବସିଡି।";
        case 'pa':
          return "ਮੈਨੂਫੈਕਚਰਿੰਗ ਲਈ ਰੁ. 50 ਲੱਖ ਅਤੇ ਸਰਵਿਸ ਸੈਕਟਰ ਲਈ ਰੁ. 20 ਲੱਖ ਤੱਕ 15% ਤੋਂ 35% ਸਬਸਿਡੀ।";
        default:
          return "विनिर्माण के लिए रु. 50 लाख और सेवा क्षेत्र के लिए रु. 20 लाख तक 15% से 35% सब्सिडी।";
      }
    }

    // Mudra Shishu benefit
    if (text.contains("50,000") && text.contains("without collateral")) {
      switch (lang) {
        case 'hi': case 'mr': case 'kok': case 'mai': case 'ne': case 'sa': case 'doi':
          return "बिना गारंटी के किफायती ब्याज दरों पर रु. 50,000 तक का ऋण।";
        case 'ta':
          return "பிணைய உத்தரவாதம் இன்றி குறைந்த வட்டியில் ரூ. 50,000 வரை சிறு கடன்.";
        case 'te':
          return "పూచీకత్తు లేకుండా సరసమైన వడ్డీ రేట్లతో రూ. 50,000 వరకు రుణం.";
        case 'kn':
          return "ಶ್ಯೂರಿಟಿ ಇಲ್ಲದೆ ಕೈಗೆಟುಕುವ ಬಡ್ಡಿದರದಲ್ಲಿ ರೂ. 50,000 ವರೆಗೆ ಸಾಲ.";
        case 'ml':
          return "ഈടില്ലാതെ കുറഞ്ഞ പലിശ നിരക്കിൽ 50,000 രൂപ വരെ വായ്പ.";
        case 'bn': case 'as':
          return "জামানত ছাড়াই সাশ্রয়ী সুদে ৫০,০০০ টাকা পর্যন্ত ঋণ।";
        case 'gu':
          return "વગર ગેરંટીએ વ્યાજબી દરે રૂ. ૫૦,૦૦૦ સુધીની લોન.";
        case 'ur': case 'ks': case 'sd':
          return "بلا ضمانت مناسب سود کی شرح پر 50,000 روپے تک کا قرض۔";
        case 'or':
          return "ବିନା ଗ୍ୟାରେଣ୍ଟିରେ ସହଜ ସୁଧରେ ୫୦,୦୦୦ ଟଙ୍କା ପର୍ଯ୍ୟନ୍ତ ଋଣ।";
        case 'pa':
          return "ਬਿਨਾਂ ਗਾਰੰਟੀ ਤੋਂ ਘੱਟ ਵਿਆਜ 'ਤੇ ਰੁ. 50,000 ਤੱਕ ਦਾ ਕਰਜ਼ਾ।";
        default:
          return "बिना गारंटी के किफायती ब्याज दरों पर रु. 50,000 तक का ऋण।";
      }
    }

    // Mudra Kishor benefit
    if (text.contains("50,001") && text.contains("5,00,000")) {
      switch (lang) {
        case 'hi': case 'mr': case 'kok': case 'mai': case 'ne': case 'sa': case 'doi':
          return "बिना किसी गारंटी के रु. 50,001 से रु. 5,00,000 तक का ऋण।";
        case 'ta':
          return "பிணைய உத்தரவாதம் இன்றி ரூ. 50,001 முதல் ரூ. 5,00,000 வரை கடன் உதவி.";
        case 'te':
          return "పూచీకత్తు అవసరం లేకుండా రూ. 50,001 నుండి రూ. 5,00,000 వరకు రుణం.";
        case 'kn':
          return "ಶ್ಯೂರಿಟಿ ಇಲ್ಲದೆ ರೂ. 50,001 ರಿಂದ ರೂ. 5,00,000 ವರೆಗೆ ಸಾಲ.";
        case 'ml':
          return "ഈടില്ലാതെ 50,001 രൂപ മുതൽ 5,00,000 രൂപ വരെ വായ്പ.";
        case 'bn': case 'as':
          return "জামানত ছাড়াই ৫০,০০১ থেকে ৫,০০,০০০ টাকা পর্যন্ত ঋণ।";
        case 'gu':
          return "વગર ગેરંટીએ રૂ. ૫૦,૦૦૧ થી રૂ. ૫,૦૦,૦૦૦ સુધીની લોન.";
        case 'ur': case 'ks': case 'sd':
          return "بلا ضمانت 50,001 روپے سے 5,00,000 روپے تک کا قرض۔";
        case 'or':
          return "ବିନା ଗ୍ୟାରେଣ୍ଟିରେ ୫୦,୦୦୧ ରୁ ୫,୦୦,୦୦୦ ଟଙ୍କା ପର୍ଯ୍ୟନ୍ତ ଋଣ।";
        case 'pa':
          return "ਬਿਨਾਂ ਗਾਰੰਟੀ ਤੋਂ ਰੁ. 50,001 ਤੋਂ ਰੁ. 5,00,000 ਤੱਕ ਦਾ ਕਰਜ਼ਾ।";
        default:
          return "बिना किसी गारंटी के रु. 50,001 से रु. 5,00,000 तक का ऋण।";
      }
    }

    // Mudra Tarun benefit
    if (text.contains("5,00,001") && text.contains("10,00,000")) {
      switch (lang) {
        case 'hi': case 'mr': case 'kok': case 'mai': case 'ne': case 'sa': case 'doi':
          return "रु. 5,00,001 से रु. 10,00,000 तक का ऋण सहायता।";
        case 'ta':
          return "ரூ. 5,00,001 முதல் ரூ. 10,00,000 வரை கடன் உதவி.";
        case 'te':
          return "రూ. 5,00,001 నుండి రూ. 10,00,000 వరకు రుణం.";
        case 'kn':
          return "ರೂ. 5,00,001 ರಿಂದ ರೂ. 10,00,000 ವರೆಗೆ ಸಾಲ ಸಹಾಯ.";
        case 'ml':
          return "5,00,001 രൂപ മുതൽ 10,00,000 രൂപ വരെ വായ്പ.";
        case 'bn': case 'as':
          return "৫,০০,০০১ টাকা থেকে ১০,০০,০০০ টাকা পর্যন্ত ঋণ সহায়তা।";
        case 'gu':
          return "રૂ. ૫,૦૦,૦૦૧ થી રૂ. ૧૦,૦૦,૦૦૦ સુધીની લોન સહાય.";
        case 'ur': case 'ks': case 'sd':
          return "5,00,001 روپے سے 10,00,000 روپے تک کا قرض۔";
        case 'or':
          return "୫,୦୦,୦୦୧ ରୁ ୧୦,୦୦,୦୦୦ ଟଙ୍କା ପର୍ଯ୍ୟନ୍ତ ଋଣ ସହାୟତା।";
        case 'pa':
          return "ਰੁ. 5,00,001 ਤੋਂ ਰੁ. 10,00,000 ਤੱਕ ਦਾ ਕਰਜ਼ਾ।";
        default:
          return "रु. 5,00,001 से रु. 10,00,000 तक का ऋण सहायता।";
      }
    }

    return text;
  }

  // 2. Target Beneficiaries & Eligibility Summaries Translation across all 23 languages
  static String _translateSummary(String text, String lang) {
    // PM Vishwakarma summary
    if (text.contains("18 traditional trades") || text.contains("Artisans and Craftsmen")) {
      switch (lang) {
        case 'hi': case 'mr': case 'kok': case 'mai': case 'ne': case 'sa': case 'doi':
          return "18 पारंपरिक व्यवसायों में हाथों और औजारों से काम करने वाले कारीगरों और शिल्पकारों के लिए उपयुक्त।";
        case 'ta':
          return "18 பாரம்பரிய தொழில்களில் கையால் வேலை செய்யும் கைவினைஞர்களுக்கு ஏற்றது.";
        case 'te':
          return "18 సాంప్రదాయ వృత్తులలో చేతులతో మరియు పరికరాలతో పనిచేసే చేతివృత్తుల వారికి తగినది.";
        case 'kn':
          return "18 ಸಾಂಪ್ರದಾಯಿಕ ವೃತ್ತಿಗಳಲ್ಲಿ ಕೈ ಮತ್ತು ಉಪಕರಣಗಳಿಂದ ಕೆಲಸ ಮಾಡುವ ಕರಕುಶಲಕರ್ಮಿಗಳಿಗೆ ಸೂಕ್ತವಾಗಿದೆ.";
        case 'ml':
          return "18 ക പരമ്പരാഗത മേഖലകളിൽ കൈത്തൊഴിൽ ചെയ്യുന്ന കരകൗശല വിദഗ്ദ്ധർക്ക് അനുയോജ്യം.";
        case 'bn': case 'as':
          return "১৮টি ঐতিহ্যবাহী ব্যবসায় হাত ও সরঞ্জাম নিয়ে কর্মরত কারিগর ও শিল্পীদের জন্য উপযুক্ত।";
        case 'gu':
          return "૧૮ પરંપરાગત વ્યવસાયોમાં કામ કરતા કારીગરો અને શિલ્પકારો માટે યોગ્ય.";
        case 'ur': case 'ks': case 'sd':
          return "18 روایتی پیشوں میں ہاتھ اور اوزار سے کام کرنے والے دستکاروں کے لیے موزوں۔";
        case 'or':
          return "୧୮ଟି ପାରମ୍ପରିକ ବୃତ୍ତିରେ କାମ କରୁଥିବା କାରିଗରଙ୍କ ପାଇଁ ଉପଯୁକ୍ତ।";
        case 'pa':
          return "18 ਰਵਾਇਤੀ ਕੰਮਾਂ ਵਿੱਚ ਹੱਥਾਂ ਅਤੇ ਔਜ਼ਾਰਾਂ ਨਾਲ ਕੰਮ ਕਰਨ ਵਾਲੇ ਕਾਰੀਗਰਾਂ ਲਈ ਢੁਕਵਾਂ।";
        default:
          return "18 पारंपरिक व्यवसायों में हाथों और औजारों से काम करने वाले कारीगरों और शिल्पकारों के लिए उपयुक्त।";
      }
    }

    // PM SVANidhi summary
    if (text.contains("Street vendors") || text.contains("hawkers")) {
      switch (lang) {
        case 'hi': case 'mr': case 'kok': case 'mai': case 'ne': case 'sa': case 'doi':
          return "सड़क किनारे विक्रेताओं, फेरीवालों और रेहड़ी-पटरी दुकानदारों के लिए उपयुक्त।";
        case 'ta':
          return "தெருவோர வியாபாரிகள் மற்றும் சிறு கடைக்காரர்களுக்கு ஏற்றது.";
        case 'te':
          return "వీధి వ్యాపారులు, వీధి తిరిగే వ్యాపారులు మరియు రోడ్డు పక్కన దుకాణదారులకు తగినది.";
        case 'kn':
          return "ಬೀದಿ ಬದಿ ವ್ಯಾಪಾರಿಗಳು ಮತ್ತು ಸಣ್ಣ ಅಂಗಡಿಕಾರರಿಗೆ ಸೂಕ್ತವಾಗಿದೆ.";
        case 'ml':
          return "തെരുവ് കച്ചവടക്കാർക്കും വഴിയോര വ്യാപാരികൾക്കും അനുയോജ്യം.";
        case 'bn': case 'as':
          return "পথব্যবসায়ী, হকার এবং রাস্তার ধারের দোকানদারদের জন্য উপযুক্ত।";
        case 'gu':
          return "શેરી ફેરિયાઓ અને રસ્તા કિનારે દુકાન ધરાવતા વેપારીઓ માટે યોગ્ય.";
        case 'ur': case 'ks': case 'sd':
          return "اسٹریٹ وینڈرز، پھیری والوں اور سڑک کنارے دکان داروں کے لیے موزوں۔";
        case 'or':
          return "ରାସ୍ତା କଡ଼ ବ୍ୟବସାୟୀ ଏବଂ ଉଠା ଦୋକାନୀଙ୍କ ପାଇଁ ଉପଯୁକ୍ତ।";
        case 'pa':
          return "ਰੇਹੜੀ-ਫੜ੍ਹੀ ਵਾਲਿਆਂ ਅਤੇ ਸੜਕ ਕਿਨਾਰੇ ਦੁਕਾਨਦਾਰਾਂ ਲਈ ਢੁਕਵਾਂ।";
        default:
          return "सड़क किनारे विक्रेताओं, फेरीवालों और रेहड़ी-पटरी दुकानदारों के लिए उपयुक्त।";
      }
    }

    // CGTMSE summary
    if (text.contains("New and existing Micro and Small Enterprises")) {
      switch (lang) {
        case 'hi': case 'mr': case 'kok': case 'mai': case 'ne': case 'sa': case 'doi':
          return "अखिल भारतीय स्तर पर नए और मौजूदा सूक्ष्म और छोटे उद्यमों के लिए उपयुक्त।";
        case 'ta':
          return "அனைத்து இந்தியாவிலும் உள்ள புதிய மற்றும் ஏற்கனவே உள்ள குறு மற்றும் சிறு நிறுவனங்களுக்கு ஏற்றது.";
        case 'te':
          return "అఖిల భారత స్థాయిలో నూతన మరియు ఉన్న సూక్ష్మ మరియు చిన్న పరిశ్రమలకు తగినది.";
        case 'kn':
          return "ಹೊಸ ಮತ್ತು ಚಾಲ್ತಿಯಲ್ಲಿರುವ ಸೂಕ್ಷ್ಮ ಮತ್ತು ಸಣ್ಣ ಉದ್ಯಮಗಳಿಗೆ ಸೂಕ್ತವಾಗಿದೆ.";
        case 'ml':
          return "പുതിയതും നിലവിലുള്ളതുമായ ചെറുകിട സംരംഭങ്ങൾക്ക് അനുയോജ്യം.";
        case 'bn': case 'as':
          return "নতুন এবং বিদ্যমান ক্ষুদ্র ও ছোট শিল্পের জন্য উপযুক্ত।";
        case 'gu':
          return "નવા અને હયાત સૂક્ષ્મ અને લઘુ ઉદ્યોગો માટે યોગ્ય.";
        case 'ur': case 'ks': case 'sd':
          return "نئے اور موجودہ مائیکرو اور چھوٹے تاجروں کے لیے موزوں۔";
        case 'or':
          return "ନୂତନ ଏବଂ ପ୍ରଚଳିତ ସୂକ୍ଷ୍ମ ଓ କ୍ଷୁଦ୍ର ଉଦ୍ୟୋଗ ପାଇଁ ଉପଯୁକ୍ତ।";
        case 'pa':
          return "ਨਵੇਂ ਅਤੇ ਮੌਜੂਦਾ ਮਾਈਕ੍ਰੋ ਅਤੇ ਛੋਟੇ ਉਦਯੋਗਾਂ ਲਈ ਢੁਕਵਾਂ।";
        default:
          return "अखिल भारतीय स्तर पर नए और मौजूदा सूक्ष्म और छोटे उद्यमों के लिए उपयुक्त।";
      }
    }

    // PMFME summary
    if (text.contains("food processing") || text.contains("FPOs, SHGs")) {
      switch (lang) {
        case 'hi': case 'mr': case 'kok': case 'mai': case 'ne': case 'sa': case 'doi':
          return "सूक्ष्म खाद्य प्रसंस्करण इकाइयों, FPO, SHG और उत्पादक सहकारी समितियों के लिए उपयुक्त।";
        case 'ta':
          return "அனைத்து இந்தியாவிலும் உள்ள சிறு உணவு பதப்படுத்தும் பிரிவுகள், FPO, SHGகளுக்கு ஏற்றது.";
        case 'te':
          return "అఖిల భారత స్థాయిలో వ్యక్తిగత ఆహార ప్రాసెసింగ్ యూనిట్లు, FPOలు, SHGలకు తగినది.";
        case 'kn':
          return "ಸಣ್ಣ ಆಹಾರ ಸಂಸ್ಕರಣಾ ಘಟಕಗಳು, FPO ಗಳು ಮತ್ತು SHG ಗಳಿಗೆ ಸೂಕ್ತವಾಗಿದೆ.";
        case 'ml':
          return "ചെറുകിട ഭക്ഷ്യ സംസ്കരണ യൂണിറ്റുകൾക്കും SHG കൾക്കും അനുയോജ്യം.";
        case 'bn': case 'as':
          return "ক্ষুদ্র খাদ্য প্রক্রিয়াকরণ ইউনিট, FPO, SHGগুলির জন্য উপযুক্ত।";
        case 'gu':
          return "સૂક્ષ્મ ફૂડ પ્રોસેસિંગ યુનિટ્સ અને SHG માટે યોગ્ય.";
        case 'ur': case 'ks': case 'sd':
          return "فوڈ پروسیسنگ یونٹس اور سیلف ہیلپ گروپس کے لیے موزوں۔";
        case 'or':
          return "ଖାଦ୍ୟ ପ୍ରସଂସ୍କରଣ ୟୁନିଟ୍ ଏବଂ SHG ପାଇଁ ଉପଯୁକ୍ତ।";
        case 'pa':
          return "ਮਾਈਕ੍ਰੋ ਫੂਡ ਪ੍ਰੋਸੈਸਿੰਗ ਯੂਨਿਟਾਂ ਅਤੇ SHG ਲਈ ਢੁਕਵਾਂ।";
        default:
          return "सूक्ष्म खाद्य प्रसंस्करण इकाइयों, FPO, SHG और उत्पादक सहकारी समितियों के लिए उपयुक्त।";
      }
    }

    // NEEDS summary
    if (text.contains("First-generation entrepreneurs") || text.contains("Tamil Nadu")) {
      switch (lang) {
        case 'hi': case 'mr': case 'kok': case 'mai': case 'ne': case 'sa': case 'doi':
          return "तमिलनाडु में डिग्री/डिप्लोमा/आईटीआई वाले प्रथम पीढ़ी के उद्यमियों के लिए उपयुक्त।";
        case 'ta':
          return "தமிழ்நாட்டில் பட்டம்/டிப்ளமோ/ITI முடித்த முதல் தலைமுறை தொழில்முனைவோருக்கு ஏற்றது.";
        case 'te':
          return "తమిళనాడులోని డిగ్రీ/డిప్లొమా/ITI పూర్తి చేసిన తొలితరం పారిశ్రామికవేత్తలకు తగినది.";
        case 'kn':
          return "ತಮಿಳುನಾಡಿನ ಪದವಿ/ಡಿಪ್ಲೊಮಾ/ITI ಹೊಂದಿರುವ ಮೊದಲ ತಲೆಮಾರಿನ ಉದ್ಯಮಿಗಳಿಗೆ ಸೂಕ್ತ.";
        case 'ml':
          return "തമിഴ്‌നാട്ടിലെ ഒന്നാം തലമുറ സംരംഭകർക്ക് അനുയോജ്യം.";
        case 'bn': case 'as':
          return "তামিলনাড়ুতে ডিগ্রি/ডিপ্লোমা/ITI ধারী প্রথম প্রজন্মের উদ্যোক্তাদের জন্য উপযুক্ত।";
        case 'gu':
          return "તમિલનાડુના પ્રથમ પેઢીના ઉદ્યોગસાહસિકો માટે યોગ્ય.";
        case 'ur': case 'ks': case 'sd':
          return "تامل ناڈو کے پہلی نسل کے تاجروں کے لیے موزوں۔";
        case 'or':
          return "ପ୍ରଥମ ପିଢ଼ିର ଉଦ୍ୟମୀଙ୍କ ପାଇଁ ଉପଯୁକ୍ତ।";
        case 'pa':
          return "ਪਹਿਲੀ ਪੀੜ੍ਹੀ ਦੇ ਉੱਦਮੀਆਂ ਲਈ ਢੁਕਵਾਂ।";
        default:
          return "तमिलनाडु में डिग्री/डिप्लोमा/आईटीआई वाले प्रथम पीढ़ी के उद्यमियों के लिए उपयुक्त।";
      }
    }

    return text;
  }

  // 3. Scheme Titles Translation across all 23 languages
  static String _translateSchemeName(String name, String lang) {
    if (name.contains("PM Vishwakarma")) {
      switch (lang) {
        case 'hi': case 'mr': case 'kok': case 'mai': case 'ne': case 'sa': case 'doi':
          return "पीएम विश्वकर्मा योजना";
        case 'ta':
          return "பிரதமரின் விஸ்வகர்மா திட்டம்";
        case 'te':
          return "పీఎం విశ్వకర్మ పథకం";
        case 'kn':
          return "ಪಿಎಂ ವಿಶ್ವಕರ್ಮ ಯೋಜನೆ";
        case 'ml':
          return "പി എം വിശ്വകർമ്മ പദ്ധതി";
        case 'bn': case 'as':
          return "পিএম বিশ্বকর্মা যোজনা";
        case 'gu':
          return "પીએમ વિશ્વકર્મા યોજના";
        case 'ur': case 'ks': case 'sd':
          return "پی ایم وشوکرما اسکیم";
        case 'or':
          return "ପିଏମ୍ ବିଶ୍ୱକର୍ମା ଯୋଜନା";
        case 'pa':
          return "ਪੀਐਮ ਵਿਸ਼ਵਕਰਮਾ ਯੋਜਨਾ";
        default:
          return "पीएम विश्वकर्मा योजना";
      }
    }

    if (name.contains("PM SVANidhi") || name.contains("Street Vendor")) {
      switch (lang) {
        case 'hi': case 'mr': case 'kok': case 'mai': case 'ne': case 'sa': case 'doi':
          return "पीएम स्वनिधि (पीएम स्ट्रीट वेंडर्स आत्मनिर्भर निधि)";
        case 'ta':
          return "பிரதமரின் ஸ்வாநிதி (தெருவோர வியாபாரிகள் ஆத்மநிர்பார் நிதி)";
        case 'te':
          return "పీఎం స్వనిధి (పీఎం స్ట్రీట్ వెండర్స్ ఆత్మనిర్భర్ నిధి)";
        case 'kn':
          return "ಪಿಎಂ ಸ್ವನಿಧಿ (ಬೀದಿ ಬದಿ ವ್ಯಾಪಾರಿಗಳ ಆತ್ಮನಿರ್ಭರ ನಿಧಿ)";
        case 'ml':
          return "പി എം സ്വനിധി പദ്ധതി";
        case 'bn': case 'as':
          return "পিএম স্বনিধি প্রকল্প";
        case 'gu':
          return "પીએમ સ્વાનીધિ યોજના";
        case 'ur': case 'ks': case 'sd':
          return "پی ایم سواندھی اسکیم";
        case 'or':
          return "ପିଏମ୍ ସ୍ୱନିଧି ଯୋଜନା";
        case 'pa':
          return "ਪੀਐਮ ਸਵਾਨਿਧੀ ਯੋਜਨਾ";
        default:
          return "पीएम स्वनिधि (पीएम स्ट्रीट वेंडर्स आत्मनिर्भर निधि)";
      }
    }

    if (name.contains("CGTMSE") || name.contains("Credit Guarantee Fund")) {
      switch (lang) {
        case 'hi': case 'mr': case 'kok': case 'mai': case 'ne': case 'sa': case 'doi':
          return "सूक्ष्म एवं लघु उद्यम क्रेडिट गारंटी फंड ट्रस्ट (CGTMSE)";
        case 'ta':
          return "குறு மற்றும் சிறு நிறுவனங்களுக்கான கடன் உத்தரவாத நிதி அறக்கட்டளை (CGTMSE)";
        case 'te':
          return "సూక్ష్మ మరియు చిన్న పరిశ్రమల క్రెడిట్ గ్యారెంటీ నిధి ట్రస్ట్ (CGTMSE)";
        case 'kn':
          return "ಸೂಕ್ಷ್ಮ ಮತ್ತು ಸಣ್ಣ ಉದ್ಯಮಗಳ ಕ್ರೆಡಿಟ್ ಗ್ಯಾರಂಟಿ ಫಂಡ್ ಟ್ರಸ್ಟ್ (CGTMSE)";
        case 'ml':
          return "ചെറുകിട സംരംഭങ്ങളുടെ ക്രെഡിറ്റ് ഗ്യാരണ്ടി ഫണ്ട് ട്രസ്റ്റ് (CGTMSE)";
        case 'bn': case 'as':
          return "ক্ষুদ্র ও ছোট শিল্পের ক্রেডিট গ্যারান্টি ফান্ড ট্রাস্ট (CGTMSE)";
        case 'gu':
          return "સૂક્ષ્મ અને લઘુ ઉદ્યોગ ક્રેડિટ ગેરંટી ફંડ ટ્રસ્ટ (CGTMSE)";
        case 'ur': case 'ks': case 'sd':
          return "کریڈٹ گارنٹی فنڈ ٹرسٹ برائے مائیکرو اور سمال انٹرپرائزز (CGTMSE)";
        case 'or':
          return "ସୂକ୍ଷ୍ମ ଓ କ୍ଷୁଦ୍ର ଉଦ୍ୟୋଗ କ୍ରେଡିଟ୍ ଗ୍ୟାରେଣ୍ଟି ଫଣ୍ଡ ଟ୍ରଷ୍ଟ (CGTMSE)";
        case 'pa':
          return "ਮਾਈਕ੍ਰੋ ਅਤੇ ਸਮਾਲ ਇੰਟਰਪ੍ਰਾਈਜ਼ਿਜ਼ ਕ੍ਰੈਡਿਟ ਗਾਰੰਟੀ ਫੰਡ ਟਰੱਸਟ (CGTMSE)";
        default:
          return "सूक्ष्म एवं लघु उद्यम क्रेडिट गारंटी फंड ट्रस्ट (CGTMSE)";
      }
    }

    if (name.contains("PMFME")) {
      switch (lang) {
        case 'hi': case 'mr': case 'kok': case 'mai': case 'ne': case 'sa': case 'doi':
          return "पीएम सूक्ष्म खाद्य प्रसंस्करण उद्योग उन्नयन योजना (PMFME)";
        case 'ta':
          return "பிரதமரின் உணவு பதப்படுத்தும் நிறுவனங்கள் முறைப்படுத்தல் திட்டம் (PMFME)";
        case 'te':
          return "పీఎం మైక్రో ఫుడ్ ప్రాసెసింగ్ ఎంటర్‌ప్రైజెస్ పథకం (PMFME)";
        case 'kn':
          return "ಪಿಎಂ ಆಹಾರ ಸಂಸ್ಕರಣಾ ಉದ್ಯಮಗಳ ಯೋಜನೆ (PMFME)";
        case 'ml':
          return "പി എം ഭക്ഷ്യ സംസ്കരണ പദ്ധതി (PMFME)";
        case 'bn': case 'as':
          return "পিএম ক্ষুদ্র খাদ্য প্রক্রিয়াকরণ প্রকল্প (PMFME)";
        case 'gu':
          return "પીએમ સૂક્ષ્મ ફૂડ પ્રોસેસિંગ યોજના (PMFME)";
        case 'ur': case 'ks': case 'sd':
          return "پی ایم فوڈ پروسیسنگ اسکیم (PMFME)";
        case 'or':
          return "ପିଏମ୍ ଖାଦ୍ୟ ପ୍ରସଂସ୍କରଣ ଯୋଜନା (PMFME)";
        case 'pa':
          return "ਪੀਐਮ ਫੂਡ ਪ੍ਰੋਸੈਸਿੰਗ ਯੋਜਨਾ (PMFME)";
        default:
          return "पीएम सूक्ष्म खाद्य प्रसंस्करण उद्योग उन्नयन योजना (PMFME)";
      }
    }

    if (name.contains("NEEDS")) {
      switch (lang) {
        case 'hi': case 'mr': case 'kok': case 'mai': case 'ne': case 'sa': case 'doi':
          return "तमिलनाडु नए उद्यमी सह उद्यम विकास योजना (NEEDS)";
        case 'ta':
          return "தமிழ்நாடு புதிய தொழில்முனைவோர் மற்றும் தொழில் மேம்பாட்டுத் திட்டம் (NEEDS)";
        case 'te':
          return "తమిళనాడు నూతన పారిశ్రామికవేత్తల అభివృద్ధి పథకం (NEEDS)";
        case 'kn':
          return "ತಮಿಳುನಾಡು ನೂತನ ಉದ್ಯಮಿ ಅಭಿವೃದ್ಧಿ ಯೋಜನೆ (NEEDS)";
        case 'ml':
          return "തമിഴ്‌നാട് പുതിയ സംരംഭക വികസന പദ്ധതി (NEEDS)";
        case 'bn': case 'as':
          return "তামিলনাড়ু নতুন উদ্যোক্তা উন্নয়ন প্রকল্প (NEEDS)";
        case 'gu':
          return "તમિલનાડુ નવા ઉદ્યોગસાહસિક વિકાસ યોજના (NEEDS)";
        case 'ur': case 'ks': case 'sd':
          return "تامل ناڈو نیو انٹرپرینیور اسکیم (NEEDS)";
        case 'or':
          return "ତାମିଲନାଡୁ ନୂତନ ଉଦ୍ୟମୀ ଯୋଜନା (NEEDS)";
        case 'pa':
          return "ਤਮਿਲਨਾਡੂ ਨਵਾਂ ਉੱਦਮੀ ਵਿਕਾਸ ਯੋਜਨਾ (NEEDS)";
        default:
          return "तमिलनाडु नए उद्यमी सह उद्यम विकास योजना (NEEDS)";
      }
    }

    return name;
  }

  // 4. Ministries Translation across all 23 languages
  static String _translateMinistry(String ministry, String lang) {
    if (ministry.contains("Housing and Urban Affairs")) {
      switch (lang) {
        case 'hi': case 'mr': case 'kok': case 'mai': case 'ne': case 'sa': case 'doi':
          return "आवास और शहरी कार्य मंत्रालय";
        case 'ta':
          return "வீட்டுவசதி மற்றும் நகர்ப்புற விவகாரங்கள் அமைச்சகம்";
        case 'te':
          return "పట్టణాభివృద్ధి మరియు గృహనిర్మాణ మంత్రిత్వ శాఖ";
        case 'kn':
          return "ವಸತಿ ಮತ್ತು ನಗರ ವ್ಯವಹಾರಗಳ ಸಚಿವಾಲಯ";
        case 'ml':
          return "ഭവന വികസന മന്ത്രാലയം";
        case 'bn': case 'as':
          return "আবাসন ও নগর বিষয়ক মন্ত্রণালয়";
        case 'gu':
          return "આવાસ અને શહેરી બાબતોનું મંત્રાલય";
        case 'ur': case 'ks': case 'sd':
          return "وزارت رہائش و شہری امور";
        case 'or':
          return "ନଗର ଉନ୍ନୟନ ମନ୍ତ୍ରଣାଳୟ";
        case 'pa':
          return "ਸ਼ਹਿਰੀ ਵਿਕਾਸ ਮੰਤਰਾਲਾ";
        default:
          return "आवास और शहरी कार्य मंत्रालय";
      }
    }

    if (ministry.contains("Micro, Small and Medium Enterprises") || ministry.contains("MSME")) {
      switch (lang) {
        case 'hi': case 'mr': case 'kok': case 'mai': case 'ne': case 'sa': case 'doi':
          return "सूक्ष्म, लघु एवं मध्यम उद्यम मंत्रालय (MSME)";
        case 'ta':
          return "குறு, சிறு மற்றும் நடுத்தர தொழில் அமைச்சகம் (MSME)";
        case 'te':
          return "సూక్ష్మ, చిన్న మరియు మధ్య తరహా పరిశ్రమల మంత్రిత్వ శాఖ (MSME)";
        case 'kn':
          return "ಸೂಕ್ಷ್ಮ, ಸಣ್ಣ ಮತ್ತು ಮಧ್ಯಮ ಉದ್ಯಮಗಳ ಸಚಿವಾಲಯ (MSME)";
        case 'ml':
          return "മൈക്രോ, സ്മോൾ ആൻഡ് മീഡിയം എന്റർപ്രൈസസ് മന്ത്രാലയം (MSME)";
        case 'bn': case 'as':
          return "ক্ষুদ্র, ছোট ও মাঝারি শিল্প মন্ত্রণালয় (MSME)";
        case 'gu':
          return "સૂક્ષ્મ, લઘુ અને મધ્યમ ઉદ્યોગ મંત્રાલય (MSME)";
        case 'ur': case 'ks': case 'sd':
          return "وزارت مائیکرو، سمال اینڈ میڈیم انٹرپرائزز (MSME)";
        case 'or':
          return "ସୂକ୍ଷ୍ମ, କ୍ଷୁଦ୍ର ଓ ମଧ୍ୟମ ଉଦ୍ୟୋଗ ମନ୍ତ୍ରଣାଳୟ (MSME)";
        case 'pa':
          return "ਮਾਈਕ੍ਰੋ, ਸਮਾਲ ਅਤੇ ਮੀਡੀਅਮ ਇੰਟਰਪ੍ਰਾਈਜ਼ਿਜ਼ ਮੰਤਰਾਲਾ (MSME)";
        default:
          return "सूक्ष्म, लघु एवं मध्यम उद्यम मंत्रालय (MSME)";
      }
    }

    if (ministry.contains("Food Processing")) {
      switch (lang) {
        case 'hi': case 'mr': case 'kok': case 'mai': case 'ne': case 'sa': case 'doi':
          return "खाद्य प्रसंस्करण उद्योग मंत्रालय (MoFPI)";
        case 'ta':
          return "உணவு பதப்படுத்தும் தொழில்கள் அமைச்சகம் (MoFPI)";
        case 'te':
          return "ఆహార ప్రాసెసింగ్ పరిశ్రమల మంత్రిత్వ శాఖ (MoFPI)";
        case 'kn':
          return "ಆಹಾರ ಸಂಸ್ಕರಣಾ ಉದ್ಯಮಗಳ ಸಚಿವಾಲಯ (MoFPI)";
        case 'ml':
          return "ഭക്ഷ്യ സംസ്കരണ വ്യവസായ മന്ത്രാലയം (MoFPI)";
        case 'bn': case 'as':
          return "খাদ্য প্রক্রিয়াকরণ শিল্প মন্ত্রণালয় (MoFPI)";
        case 'gu':
          return "ફૂડ પ્રોસેસિંગ ઉદ્યોગ મંત્રાલય (MoFPI)";
        case 'ur': case 'ks': case 'sd':
          return "وزارت فوڈ پروسیسنگ انڈسٹریز (MoFPI)";
        case 'or':
          return "ଖାଦ୍ୟ ପ୍ରସଂସ୍କରଣ ଉଦ୍ୟୋଗ ମନ୍ତ୍ରଣାଳୟ (MoFPI)";
        case 'pa':
          return "ਫ਼ੂਡ ਪ੍ਰੋਸੈਸਿੰਗ ਉਦਯੋਗ ਮੰਤਰਾਲਾ (MoFPI)";
        default:
          return "खाद्य प्रसंस्करण उद्योग मंत्रालय (MoFPI)";
      }
    }

    if (ministry.contains("Government of Tamil Nadu")) {
      switch (lang) {
        case 'hi': case 'mr': case 'kok': case 'mai': case 'ne': case 'sa': case 'doi':
          return "तमिलनाडु सरकार";
        case 'ta':
          return "தமிழ்நாடு அரசு";
        case 'te':
          return "తమిళనాడు ప్రభుత్వం";
        case 'kn':
          return "ತಮಿಳುನಾಡು ಸರ್ಕಾರ";
        case 'ml':
          return "തമിഴ്‌നാട് സർക്കാർ";
        case 'bn': case 'as':
          return "তামিলনাড়ু সরকার";
        case 'gu':
          return "તમિલનાડુ સરકાર";
        case 'ur': case 'ks': case 'sd':
          return "حکومت تامل ناڈو";
        case 'or':
          return "ତାମିଲନାଡୁ ସରକାର";
        case 'pa':
          return "ਤਮਿਲਨਾਡੂ ਸਰਕਾਰ";
        default:
          return "तमिलनाडु सरकार";
      }
    }

    return ministry;
  }

  // 5. Tags & Criteria Chips Translation across all 23 languages
  static String _translateTag(String text, String lang) {
    if (text.contains("Minimum age") || text.contains("minimum_age")) {
      switch (lang) {
        case 'ta': return "குறைந்தபட்ச வயது வரம்பு பூர்த்தியானது";
        case 'te': return "కనీస వయస్సు నిబంధన పూర్తయింది";
        case 'kn': return "ಕನಿಷ್ಠ ವಯಸ್ಸಿನ ಮಾನದಂಡ ಪೂರೈಸಲಾಗಿದೆ";
        case 'ml': return "കുറഞ്ഞ പ്രായപരിധി യോഗ്യത നേടി";
        case 'bn': case 'as': return "নূন্যতম বয়স মাপকাঠি পূরণ হয়েছে";
        case 'gu': return "ન્યૂનતમ વય માનદંડ પૂર્ણ";
        case 'ur': return "کم از کم عمر کا معیار پورا ہے";
        default: return "न्यूनतम आयु मानदंड पूरा हुआ";
      }
    }

    if (text.contains("Maximum age") || text.contains("maximum_age")) {
      switch (lang) {
        case 'ta': return "அதிகபட்ச வயது வரம்பு பொருந்தியது";
        case 'te': return "గరిష్ట వయస్సు నిబంధన పూర్తయింది";
        case 'kn': return "ಗರಿಷ್ಠ ವಯಸ್ಸಿನ ಮಾನದಂಡ ಪೂರೈಸಲಾಗಿದೆ";
        case 'ml': return "പരമാവധി പ്രായപരിധി യോഗ്യത നേടി";
        case 'bn': case 'as': return "সর্বোচ্চ বয়স মাপকাঠি পূরণ হয়েছে";
        case 'gu': return "મહત્તમ વય માનદંડ પૂર્ણ";
        case 'ur': return "زیادہ سے زیادہ عمر کا معیار پورا ہے";
        default: return "अधिकतम आयु मानदंड पूरा हुआ";
      }
    }

    if (text.contains("operates in your region") || text.contains("All India")) {
      switch (lang) {
        case 'ta': return "உங்கள் பிராந்தியத்தில் இத்திட்டம் செயல்படுகிறது (அனைத்து இந்தியா)";
        case 'te': return "మీ ప్రాంతంలో ఈ పథకం అందుబాటులో ఉంది (అఖిల భారత)";
        case 'kn': return "ನಿಮ್ಮ ಪ್ರದೇಶದಲ್ಲಿ ಈ ಯೋಜನೆ ಲಭ್ಯವಿದೆ (ಸಮಗ್ರ ಭಾರತ)";
        case 'ml': return "നിങ്ങളുടെ പ്രദേശത്ത് ഈ പദ്ധതി ലഭ്യമാണ് (ആൾ ഇന്ത്യ)";
        case 'bn': case 'as': return "আপনার অঞ্চলে এই প্রকল্প চালু আছে (সর্বভারতীয়)";
        case 'gu': return "આ યોજના તમારા વિસ્તારમાં કાર્યરત છે (અખિલ ભારતીય)";
        case 'ur': return "اسکیم آپ کے علاقے میں فعال ہے (پورے ہندوستان میں)";
        default: return "यह योजना आपके क्षेत्र में संचालित है (अखिल भारतीय)";
      }
    }

    if (text.contains("State eligibility matched")) {
      switch (lang) {
        case 'ta': return "மாநில தகுதி பொருந்தியது";
        case 'te': return "రాష్ట్ర అర్హత సరిపోలింది";
        case 'kn': return "ರಾಜ್ಯ ಅರ್ಹತೆ ಹೊಂದಾಣಿಕೆಯಾಗಿದೆ";
        case 'ml': return "സംസ്ഥാന യോഗ്യത പൊരുത്തപ്പെട്ടു";
        case 'bn': case 'as': return "রাজ্যের যোগ্যতা মিলেছে";
        case 'gu': return "રાજ્યની પાત્રતા યોગ્ય છે";
        case 'ur': return "ریاستی اہلیت مطابق ہے";
        default: return "राज्य की पात्रता मेल खाती है";
      }
    }

    return text;
  }
}
