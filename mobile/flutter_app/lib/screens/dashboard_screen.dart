import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/scheme_provider.dart';
import 'ocr_scan_screen.dart';
import 'scheme_detail_screen.dart';
import 'admin_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SchemeProvider>(context, listen: false).fetchRecommendations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final schemeProv = Provider.of<SchemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("SchemeMate AI"),
        actions: [
          IconButton(
            icon: const Icon(Icons.document_scanner_rounded),
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
        onRefresh: () async {
          await schemeProv.fetchRecommendations();
        },
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
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Hello, ${auth.fullName ?? 'Entrepreneur'} 👋",
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "Tailoring Business • Tamil Nadu • Micro Unit",
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 12),
                      const Row(
                        children: [
                          Text("Profile Completion: ", style: TextStyle(fontWeight: FontWeight.bold)),
                          Text("85%", style: TextStyle(color: AppTheme.successGreen, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: const LinearProgressIndicator(
                          value: 0.85,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Matched Schemes", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () => schemeProv.fetchRecommendations(),
                  )
                ],
              ),
              const SizedBox(height: 10),
              if (schemeProv.isLoading)
                const Center(child: Padding(padding: EdgeInsets.all(30), child: CircularProgressIndicator()))
              else if (schemeProv.recommendations.isEmpty)
                const Center(child: Text("No matched schemes available right now."))
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
            ],
          ),
        ),
      ),
    );
  }
}

