// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/i18n/app_localizations.dart';
import '../core/theme/app_theme.dart';
import '../providers/locale_provider.dart';
import '../widgets/language_selector_sheet.dart';

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
        .replaceAll("Loan from Rs. 50,001 up to Rs. 5,00,000 without requirement of collateral security.", "பிணைய உத்தரவாதம் இன்றி ரூ. 50,001 முதல் ரூ. 5,00,000 வரை கடன் உதவி.")
        .replaceAll("Suitable for Existing micro-enterprises seeking growth capital in All India", "அனைத்து இந்தியாவிலும் வளர்ச்சி நிதி தேடும் குறு நிறுவனங்களுக்கு ஏற்றது.")
        .replaceAll("(Open Year-Round)", "(ஆண்டு முழுவதும் திறந்திருக்கும்)");
    } else if (langCode == 'hi') {
      res = res
        .replaceAll("Ministry of Finance", "वित्त मंत्रालय")
        .replaceAll("Ministry of Micro, Small and Medium Enterprises", "सूक्ष्म, लघु एवं मध्यम उद्यम मंत्रालय (MSME)")
        .replaceAll("Ministry of Housing and Urban Affairs", "आवास और शहरी कार्य मंत्रालय")
        .replaceAll("Minimum age criterion met", "न्यूनतम आयु मानदंड पूरा हुआ")
        .replaceAll("Business sector eligible", "व्यवसाय क्षेत्र पात्र है")
        .replaceAll("Scheme operates in your region", "यह योजना आपके क्षेत्र में संचालित है")
        .replaceAll("(Open Year-Round)", "(वर्ष भर खुला)");
    } else if (langCode == 'te') {
      res = res
        .replaceAll("Ministry of Finance", "ఆర్థిక మంత్రిత్వ శాఖ")
        .replaceAll("Ministry of Micro, Small and Medium Enterprises", "సూక్ష్మ, చిన్న మరియు మధ్య తరహా పరిశ్రమల మంత్రిత్వ శాఖ")
        .replaceAll("Minimum age criterion met", "కనీస వయస్సు నిబంధన పూర్తయింది")
        .replaceAll("Business sector eligible", "వ్యాపార రంగం అర్హత పొందింది")
        .replaceAll("Scheme operates in your region", "మీ ప్రాంతంలో ఈ పథకం అందుబాటులో ఉంది")
        .replaceAll("(Open Year-Round)", "(ఏడాది పొడవునా తెరిచి ఉంటుంది)");
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
    } else if (langCode == 'mr') {
      res = res
        .replaceAll("Ministry of Finance", "वित्त मंत्रालय")
        .replaceAll("Ministry of Micro, Small and Medium Enterprises", "सूक्ष्म, लघु आणि मध्यम उद्यम मंत्रालय")
        .replaceAll("Minimum age criterion met", "किमान वयोमर्यादा पूर्ण")
        .replaceAll("Business sector eligible", "व्यवसाय क्षेत्र पात्र आहे")
        .replaceAll("Scheme operates in your region", "तुमच्या क्षेत्रात योजना कार्यरत आहे")
        .replaceAll("(Open Year-Round)", "(वर्षभर उघडे)");
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
    }
    return res;
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
      appBar: AppBar(
        title: Text(context.tr("required_details_title")),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.language_rounded),
            tooltip: context.tr("change_language"),
            onPressed: () => LanguageSelectorSheet.show(context),
          ),
        ],
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
                            w.toString(),
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
                              docName,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                            ),
                            if (docType.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                docType,
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
