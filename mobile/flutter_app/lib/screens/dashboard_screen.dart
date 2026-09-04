import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/i18n/app_localizations.dart';
import '../core/network/api_client.dart';
import '../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/scheme_provider.dart';
import '../widgets/gov_top_header.dart';
import '../widgets/gov_footer.dart';
import '../widgets/language_selector_sheet.dart';
import 'business_profile_form_screen.dart';
import 'ocr_scan_screen.dart';
import 'scheme_requirements_screen.dart';
import 'admin_screen.dart';
import 'financial_calculator_screen.dart';
import 'partner_locator_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? _userProfile;
  bool _isLoadingProfile = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDashboardData();
    });
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoadingProfile = true);
    
    final profileRes = await ApiClient.get("/profile");
    if (profileRes["success"] == true && profileRes["data"] != null) {
      if (mounted) {
        setState(() {
          _userProfile = profileRes["data"];
        });
      }
    }

    if (mounted) {
      final schemeProv = Provider.of<SchemeProvider>(context, listen: false);
      final localeProv = Provider.of<LocaleProvider>(context, listen: false);
      
      Future.wait([
        schemeProv.fetchRecommendations(preferredLanguage: localeProv.languageCode),
        schemeProv.fetchGeminiSuggestions(preferredLanguage: localeProv.languageCode),
      ]).then((_) {
        if (mounted) setState(() => _isLoadingProfile = false);
      });
    }
  }

  int _calculateProfileCompletion() {
    if (_userProfile == null) return 50;
    int score = 20;
    if ((_userProfile!["company_name"] ?? "").toString().isNotEmpty) score += 15;
    if ((_userProfile!["business_description"] ?? "").toString().isNotEmpty) score += 15;
    if (_userProfile!["age"] != null) score += 10;
    if ((_userProfile!["category"] ?? "").toString().isNotEmpty) score += 15;
    if ((_userProfile!["source_of_income"] ?? "").toString().isNotEmpty) score += 10;
    if (_userProfile!["annual_income"] != null) score += 10;
    final hasCert = (_userProfile!["certificate_uploaded"] == true) ||
        ((_userProfile!["certificate_number"] ?? "").toString().trim().isNotEmpty);
    if (hasCert) score += 5;
    return score.clamp(0, 100);
  }

  String _localizeText(String input, String langCode) {
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
        .replaceAll("State eligibility matched", "राज्य की पात्रता मेल खाती है")
        .replaceAll("Matches your funding requirement", "आपकी वित्त पोषण आवश्यकता से मेल खाता है");
    }
    return res;
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final schemeProv = Provider.of<SchemeProvider>(context);
    final currentLang = Provider.of<LocaleProvider>(context).languageCode;

    final companyName = _userProfile?["company_name"] ?? context.tr("not_set");
    final businessDesc = _userProfile?["business_description"] ?? context.tr("not_set");
    final age = _userProfile?["age"] ?? context.tr("not_set");
    final category = _userProfile?["category"] ?? context.tr("general");
    final annualIncome = _userProfile?["annual_income"] ?? 0;
    final incomeSource = _userProfile?["source_of_income"] ?? context.tr("not_set");
    final stateName = _userProfile?["state"] ?? context.tr("all_india");
    final isCertUploaded = _userProfile?["certificate_uploaded"] == true;
    final certType = _userProfile?["certificate_type"] ?? context.tr("caste_income_cert");
    final certNumber = _userProfile?["certificate_number"];

    final completionPct = _calculateProfileCompletion();

    return Scaffold(
      appBar: GovTopHeader(
        title: "SchemeMate AI",
        actions: [
          IconButton(
            icon: const Icon(Icons.calculate_outlined, color: Colors.white),
            tooltip: "Financial & EMI Calculator",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FinancialCalculatorScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.near_me_outlined, color: Colors.white),
            tooltip: "Geo-Spatial Partner Locator",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PartnerLocatorScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.document_scanner_outlined, color: Colors.white),
            tooltip: "OCR Verification",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const OCRScanScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit_note_outlined, color: Colors.white),
            tooltip: context.tr("edit_form"),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BusinessProfileFormScreen()),
              ).then((_) => _loadDashboardData());
            },
          ),
          if (auth.isAdmin)
            IconButton(
              icon: const Icon(Icons.admin_panel_settings_outlined, color: AppTheme.accentSaffron),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AdminScreen()),
                );
              },
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (schemeProv.isOffline)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  color: AppTheme.warningOrange,
                  child: Row(
                    children: [
                      const Icon(Icons.wifi_off, color: Colors.white, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          context.tr("offline_mode_active"),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Official Citizen / Entrepreneur Credentials Card
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(color: AppTheme.primaryNavy, width: 1.2),
                      ),
                      child: Column(
                        children: [
                          // Official Header Banner on Card
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: const BoxDecoration(
                              color: AppTheme.primaryNavy,
                              borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.verified_user, color: AppTheme.accentSaffron, size: 16),
                                const SizedBox(width: 8),
                                const Text(
                                  "OFFICIAL CITIZEN ENTREPRENEUR PROFILE",
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 0.5),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppTheme.govGreen,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    "VALIDATED",
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 9),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            context.tr("hello_user", {"name": auth.fullName ?? 'Entrepreneur'}),
                                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              const Icon(Icons.business_outlined, size: 16, color: AppTheme.primaryNavy),
                                              const SizedBox(width: 6),
                                              Expanded(
                                                child: Text(
                                                  "$companyName",
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                    color: AppTheme.primaryNavy,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    OutlinedButton.icon(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => const BusinessProfileFormScreen()),
                                        ).then((_) => _loadDashboardData());
                                      },
                                      icon: const Icon(Icons.edit, size: 14),
                                      label: Text(context.tr("edit_form")),
                                      style: OutlinedButton.styleFrom(
                                        visualDensity: VisualDensity.compact,
                                        foregroundColor: AppTheme.primaryNavy,
                                      ),
                                    )
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  "${context.tr('details_prefix')}$businessDesc",
                                  style: TextStyle(color: Colors.grey.shade800, fontSize: 13),
                                ),
                                const Divider(height: 20),

                                // Citizen Attribute Chips
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    _buildGovAttributeChip(Icons.cake, context.tr("age_chip", {"age": "$age"})),
                                    _buildGovAttributeChip(Icons.location_on, stateName),
                                    _buildGovAttributeChip(Icons.groups, context.tr("category_chip", {"category": category})),
                                    _buildGovAttributeChip(Icons.account_balance_wallet, context.tr("income_chip", {"income": "$annualIncome", "source": incomeSource})),
                                    if (isCertUploaded)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: AppTheme.govGreen.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(color: AppTheme.govGreen.withOpacity(0.3)),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.verified, size: 14, color: AppTheme.govGreen),
                                            const SizedBox(width: 6),
                                            Text(
                                              (certNumber != null && certNumber.toString().trim().isNotEmpty)
                                                  ? context.tr("verified_chip", {"type": certType, "number": "$certNumber"})
                                                  : context.tr("verified_chip_no_num", {"type": certType}),
                                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.govGreen),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                // Profile Readiness Progress
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Government Scheme Eligibility Readiness:",
                                      style: TextStyle(color: Colors.grey.shade800, fontWeight: FontWeight.bold, fontSize: 12),
                                    ),
                                    Text(
                                      "$completionPct%",
                                      style: const TextStyle(color: AppTheme.govGreen, fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: completionPct / 100.0,
                                    minHeight: 8,
                                    color: AppTheme.govGreen,
                                    backgroundColor: Colors.grey.shade200,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Section Title: Official Scheme Recommendations
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 4,
                              height: 20,
                              color: AppTheme.accentSaffron,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              context.tr("suggested_schemes"),
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh, color: AppTheme.primaryNavy),
                          tooltip: context.tr("refresh_suggestions"),
                          onPressed: () async {
                            await schemeProv.fetchGeminiSuggestions();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Scheme Cards List
                    if (schemeProv.isLoadingGemini || _isLoadingProfile)
                      const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()))
                    else if (schemeProv.geminiSuggestions.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Text(context.tr("no_suggestions")),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: schemeProv.geminiSuggestions.length,
                        itemBuilder: (context, index) {
                          final item = schemeProv.geminiSuggestions[index];
                          final List<dynamic> whyMatches = item["why_matches"] as List<dynamic>? ?? [];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: const BorderSide(color: AppTheme.borderGrey, width: 1),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Ministry Header Ribbon
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.account_balance, size: 14, color: AppTheme.primaryNavy),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          _localizeText(item["ministry"] ?? "Ministry of MSME, Govt of India", currentLang),
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.primaryNavy,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.red.shade50,
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border.all(color: Colors.red.shade200),
                                        ),
                                        child: Text(
                                          "${context.tr('last_date')}: ${_localizeText(item['last_date_to_apply'] ?? '31 Dec 2026', currentLang)}",
                                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Scheme Name Title
                                      Text(
                                        item["scheme_name"] ?? "",
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                                      ),
                                      const SizedBox(height: 8),

                                      // Benefits & Description
                                      if ((item["key_benefits"] ?? "").toString().isNotEmpty) ...[
                                        Text(
                                          _localizeText(item["key_benefits"].toString(), currentLang),
                                          style: const TextStyle(fontSize: 13, color: Colors.black87),
                                        ),
                                        const SizedBox(height: 6),
                                      ],
                                      if ((item["eligibility_summary"] ?? "").toString().isNotEmpty) ...[
                                        Text(
                                          _localizeText(item["eligibility_summary"].toString(), currentLang),
                                          style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                                        ),
                                      ],

                                      // Why Matches Tag Chips
                                      if (whyMatches.isNotEmpty) ...[
                                        const SizedBox(height: 10),
                                        Wrap(
                                          spacing: 6,
                                          runSpacing: 4,
                                          children: whyMatches.map((w) => Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: AppTheme.govGreen.withOpacity(0.08),
                                              borderRadius: BorderRadius.circular(4),
                                              border: Border.all(color: AppTheme.govGreen.withOpacity(0.3)),
                                            ),
                                            child: Text(
                                              "✔ ${_localizeText(w.toString(), currentLang)}",
                                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.govGreen),
                                            ),
                                          )).toList(),
                                        ),
                                      ],

                                      const SizedBox(height: 14),
                                      const Divider(height: 1),
                                      const SizedBox(height: 12),

                                      // Action Buttons
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton.icon(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => SchemeRequirementsScreen(scheme: item),
                                              ),
                                            );
                                          },
                                          icon: const Icon(Icons.assignment_turned_in_outlined, size: 16),
                                          label: Text(context.tr("view_required_details_btn")),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppTheme.primaryNavy,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(vertical: 12),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),

              // Official Portal Footer
              const GovFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGovAttributeChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.primaryNavy),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textDark),
          ),
        ],
      ),
    );
  }
}
