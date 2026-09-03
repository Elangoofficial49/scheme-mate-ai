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
                    ministry,
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  if (benefits.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      benefits,
                      style: const TextStyle(fontSize: 13, color: Colors.black87),
                    ),
                  ],
                  if (eligibility.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      eligibility,
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
                            "${context.tr('last_date')}: ${scheme['last_date_to_apply'] ?? '31 Dec 2026 (Open Year-Round)'}",
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
