import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/i18n/app_localizations.dart';
import '../core/i18n/scheme_translation_helper.dart';
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
  String? _lastLanguageCode;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDashboardData();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final localeProv = Provider.of<LocaleProvider>(context);
    if (_lastLanguageCode != null && _lastLanguageCode != localeProv.languageCode) {
      _lastLanguageCode = localeProv.languageCode;
      _loadDashboardData();
    } else {
      _lastLanguageCode = localeProv.languageCode;
    }
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
    return SchemeTranslationHelper.localize(input, langCode);
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
                            await schemeProv.fetchGeminiSuggestions(preferredLanguage: currentLang);
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
                                        _localizeText(item["scheme_name"] ?? "", currentLang),
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                                      ),
                                      const SizedBox(height: 8),

                                      // Benefits & Description
                                      if ((item["key_benefits"] ?? item["benefits"] ?? item["description"] ?? "").toString().isNotEmpty) ...[
                                        Text(
                                          _localizeText((item["key_benefits"] ?? item["benefits"] ?? item["description"]).toString(), currentLang),
                                          style: const TextStyle(fontSize: 13, color: Colors.black87),
                                        ),
                                        const SizedBox(height: 6),
                                      ],
                                      if ((item["eligibility_summary"] ?? item["target_beneficiary"] ?? "").toString().isNotEmpty) ...[
                                        Text(
                                          _localizeText((item["eligibility_summary"] ?? item["target_beneficiary"]).toString(), currentLang),
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
