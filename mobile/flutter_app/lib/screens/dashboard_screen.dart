import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/network/api_client.dart';
import '../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/scheme_provider.dart';
import 'business_profile_form_screen.dart';
import 'ocr_scan_screen.dart';
import 'scheme_detail_screen.dart';
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
    
    // Fetch profile and scheme recommendations in parallel
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
      await schemeProv.fetchRecommendations();
      setState(() => _isLoadingProfile = false);
      schemeProv.fetchGeminiSuggestions();
    }
  }

  int _calculateProfileCompletion() {
    if (_userProfile == null) return 50;
    int score = 20; // Base score for registration
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
        title: const Text("SchemeMate AI"),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_note_rounded),
            tooltip: "Edit Business Profile",
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
                  child: const Row(
                    children: [
                      Icon(Icons.wifi_off, color: Colors.white),
                      SizedBox(width: 10),
                      Text(
                        "Offline Mode Active - Showing Cached Schemes",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
                                  "Hello, ${auth.fullName ?? 'Entrepreneur'} 👋",
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
                            label: const Text("Edit Form"),
                            style: OutlinedButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                              foregroundColor: AppTheme.primaryBlue,
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "📝 Details: $businessDesc",
                        style: TextStyle(color: Colors.grey.shade800, fontSize: 14),
                      ),
                      const Divider(height: 24),
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        children: [
                          Chip(
                            avatar: const Icon(Icons.cake, size: 16),
                            label: Text("Age: $age yrs"),
                            backgroundColor: Colors.grey.shade100,
                          ),
                          Chip(
                            avatar: const Icon(Icons.location_on, size: 16),
                            label: Text(stateName),
                            backgroundColor: Colors.grey.shade100,
                          ),
                          Chip(
                            avatar: const Icon(Icons.groups, size: 16),
                            label: Text("Category: $category"),
                            backgroundColor: Colors.grey.shade100,
                          ),
                          Chip(
                            avatar: const Icon(Icons.account_balance_wallet, size: 16),
                            label: Text("Income: ₹$annualIncome/yr ($incomeSource)"),
                            backgroundColor: Colors.grey.shade100,
                          ),
                          Chip(
                            avatar: Icon(
                              isCertUploaded ? Icons.verified : Icons.error_outline,
                              size: 16,
                              color: isCertUploaded ? AppTheme.successGreen : AppTheme.warningOrange,
                            ),
                            label: Text(isCertUploaded
                                ? "Verified: $certType${(certNumber != null && certNumber.toString().trim().isNotEmpty) ? ' (#$certNumber)' : ''}"
                                : "No Certificate Linked"),
                            backgroundColor: isCertUploaded
                                ? AppTheme.successGreen.withValues(alpha: 0.12)
                                : AppTheme.warningOrange.withValues(alpha: 0.12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Text("Profile Completion: ", style: TextStyle(fontWeight: FontWeight.bold)),
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

              // Matched Schemes Section Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Suggested Schemes for You", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    tooltip: "Refresh Scheme Matches",
                    onPressed: () => _loadDashboardData(),
                  )
                ],
              ),
              const SizedBox(height: 10),

              if (_isLoadingProfile || schemeProv.isLoading)
                const Center(child: Padding(padding: EdgeInsets.all(30), child: CircularProgressIndicator()))
              else if (schemeProv.recommendations.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text("No matched schemes available right now."),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: schemeProv.recommendations.length,
                  itemBuilder: (context, index) {
                    final item = schemeProv.recommendations[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 14),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SchemeDetailScreen(match: item),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      item.schemeName,
                                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: item.matchScore >= 80 ? AppTheme.successGreen : AppTheme.warningOrange,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      item.matchLabel,
                                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(item.ministry, style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
                              const SizedBox(height: 12),
                              if (item.whyMatches.isNotEmpty) ...[
                                Text(item.whyMatches.first, style: const TextStyle(fontSize: 13, color: AppTheme.successGreen)),
                              ],
                              if (item.missingInformation.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  "⚠ Missing: ${item.missingInformation.join(', ')}",
                                  style: const TextStyle(fontSize: 13, color: AppTheme.warningOrange),
                                ),
                              ],
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  Text("Verified: ${item.lastVerified}", style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                  const Spacer(),
                                  const Text("View Details ->", style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold)),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                            // Gemini AI Suggestions Section
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Gemini AI Suggestions", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      tooltip: "Refresh Gemini Suggestions",
                      onPressed: () async {
                        await schemeProv.fetchGeminiSuggestions();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (schemeProv.isLoadingGemini)
                  const Center(child: Padding(padding: EdgeInsets.all(30), child: CircularProgressIndicator()))
                else if (schemeProv.geminiSuggestions.isEmpty)
                  const Center(child: Padding(padding: EdgeInsets.all(20), child: Text("No Gemini suggestions available.")))
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: schemeProv.geminiSuggestions.length,
                    itemBuilder: (context, index) {
                      final item = schemeProv.geminiSuggestions[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 14),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item["scheme_name"] ?? "", style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 6),
                              Text(item["ministry"] ?? "", style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
                              const SizedBox(height: 6),
                              Text(item["key_benefits"] ?? ""),
                              const SizedBox(height: 4),
                              Text(item["eligibility_summary"] ?? ""),
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 6,
                                children: (item["why_matches"] as List<dynamic>? ?? []).map((w) => Chip(label: Text(w.toString()))).toList(),
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


