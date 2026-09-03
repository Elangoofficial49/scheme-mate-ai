import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/i18n/app_localizations.dart';
import '../core/network/api_client.dart';
import '../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/scheme_provider.dart';
import '../widgets/language_selector_sheet.dart';
import 'business_profile_form_screen.dart';
import 'ocr_scan_screen.dart';
import 'scheme_requirements_screen.dart';
import 'admin_screen.dart';

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
        schemeProv.fetchRecommendations(),
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

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final schemeProv = Provider.of<SchemeProvider>(context);
    final localeProv = Provider.of<LocaleProvider>(context);
    final currentLang = localeProv.languageCode;
    final completionPct = _calculateProfileCompletion();

    final companyName = _userProfile?["company_name"] ?? "Sri Lakshmi Textiles";
    final businessDesc = _userProfile?["business_description"] ?? "Garment manufacturing and tailoring unit";
    final age = _userProfile?["age"] ?? 28;
    final category = _userProfile?["category"] ?? "OBC";
    final incomeSource = _userProfile?["source_of_income"] ?? "Self-Employed";
    final annualIncome = _userProfile?["annual_income"] ?? 150000;
    final stateName = _userProfile?["state"] ?? "Tamil Nadu";
    final certNumber = _userProfile?["certificate_number"];
    final isCertUploaded = (_userProfile?["certificate_uploaded"] == true) ||
        ((certNumber ?? "").toString().trim().isNotEmpty);
    final certType = _userProfile?["certificate_type"] ?? "Certificate";

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr("app_title")),
        actions: [
          IconButton(
            icon: const Icon(Icons.language_rounded),
            tooltip: context.tr("change_language"),
            onPressed: () => LanguageSelectorSheet.show(context),
          ),
          IconButton(
            icon: const Icon(Icons.edit_note_rounded),
            tooltip: context.tr("edit_form"),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BusinessProfileFormScreen()),
              ).then((_) => _loadDashboardData());
            },
          ),
          IconButton(
            icon: const Icon(Icons.document_scanner_rounded),
            tooltip: "OCR Document Scan",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const OCRScanScreen()),
              );
            },
          ),
          if (auth.isAdmin)
            IconButton(
              icon: const Icon(Icons.admin_panel_settings_rounded),
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
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (schemeProv.isOffline)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.only(bottom: 16),
                  color: Colors.amber.shade800,
                  child: Row(
                    children: [
                      const Icon(Icons.wifi_off, color: Colors.white),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          context.tr("offline_mode_active"),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),

              // Entrepreneur Profile Card
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
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
                                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "🏢 $companyName",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.primaryBlue,
                                  ),
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
                            icon: const Icon(Icons.edit, size: 16),
                            label: Text(context.tr("edit_form")),
                            style: OutlinedButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                              foregroundColor: AppTheme.primaryBlue,
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "${context.tr('details_prefix')}$businessDesc",
                        style: TextStyle(color: Colors.grey.shade800, fontSize: 14),
                      ),
                      const Divider(height: 24),
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        children: [
                          Chip(
                            avatar: const Icon(Icons.cake, size: 16),
                            label: Text(context.tr("age_chip", {"age": "$age"})),
                            backgroundColor: Colors.grey.shade100,
                          ),
                          Chip(
                            avatar: const Icon(Icons.location_on, size: 16),
                            label: Text(stateName),
                            backgroundColor: Colors.grey.shade100,
                          ),
                          Chip(
                            avatar: const Icon(Icons.groups, size: 16),
                            label: Text(context.tr("category_chip", {"category": category})),
                            backgroundColor: Colors.grey.shade100,
                          ),
                          Chip(
                            avatar: const Icon(Icons.account_balance_wallet, size: 16),
                            label: Text(context.tr("income_chip", {"income": "$annualIncome", "source": incomeSource})),
                            backgroundColor: Colors.grey.shade100,
                          ),
                          if (isCertUploaded)
                            Chip(
                              avatar: const Icon(
                                Icons.verified,
                                size: 16,
                                color: AppTheme.successGreen,
                              ),
                              label: Text(
                                (certNumber != null && certNumber.toString().trim().isNotEmpty)
                                    ? context.tr("verified_chip", {"type": certType, "number": "$certNumber"})
                                    : context.tr("verified_chip_no_num", {"type": certType}),
                              ),
                              backgroundColor: AppTheme.successGreen.withValues(alpha: 0.12),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Text(context.tr("profile_completion"), style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                            "$completionPct%",
                            style: const TextStyle(color: AppTheme.successGreen, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: completionPct / 100.0,
                          minHeight: 8,
                          color: AppTheme.successGreen,
                          backgroundColor: Colors.black12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Suggested Schemes Section - powered by Gemini AI
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      context.tr("suggested_schemes"),
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    tooltip: context.tr("refresh_suggestions"),
                    onPressed: () async {
                      await schemeProv.fetchGeminiSuggestions();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),

              if (schemeProv.isLoadingGemini || _isLoadingProfile)
                const Center(child: Padding(padding: EdgeInsets.all(30), child: CircularProgressIndicator()))
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
                      margin: const EdgeInsets.only(bottom: 14),
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
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
                                        item["scheme_name"] ?? "",
                                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        item["ministry"] ?? "",
                                        style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade50,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: Colors.red.shade200),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.event_available, size: 14, color: Colors.red),
                                      const SizedBox(width: 4),
                                      Text(
                                        "${context.tr('last_date')}: ${item['last_date_to_apply'] ?? '31 Dec 2026 (Open Year-Round)'}",
                                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.red),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if ((item["key_benefits"] ?? "").toString().isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                item["key_benefits"].toString(),
                                style: const TextStyle(fontSize: 13, color: Colors.black87),
                              ),
                            ],
                            if ((item["eligibility_summary"] ?? "").toString().isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                item["eligibility_summary"].toString(),
                                style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                              ),
                            ],
                            if (whyMatches.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 6,
                                runSpacing: 4,
                                children: whyMatches.map((w) => Chip(
                                  label: Text(
                                    w.toString(),
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                                  backgroundColor: AppTheme.successGreen.withOpacity(0.1),
                                  side: BorderSide(color: AppTheme.successGreen.withOpacity(0.3)),
                                  labelStyle: const TextStyle(color: AppTheme.successGreen, fontWeight: FontWeight.w600),
                                )).toList(),
                              ),
                            ],
                            const SizedBox(height: 14),
                            const Divider(height: 1),
                            const SizedBox(height: 10),
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
                                icon: const Icon(Icons.assignment_outlined, size: 18),
                                label: Text(context.tr("view_required_details_btn")),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  backgroundColor: AppTheme.primaryBlue,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
