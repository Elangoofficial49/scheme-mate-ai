// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/i18n/app_localizations.dart';
import '../core/theme/app_theme.dart';
import '../models/match_result_model.dart';
import '../providers/locale_provider.dart';

class ActionPlanScreen extends StatelessWidget {
  final MatchResultModel match;
  const ActionPlanScreen({Key? key, required this.match}) : super(key: key);

  void _launchUrl(BuildContext context, String urlString) {
    if (urlString.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr("no_portal_url")),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    // Open the URL in a new browser tab
    html.window.open(urlString, '_blank');
  }

  @override
  Widget build(BuildContext context) {
    final localeProv = Provider.of<LocaleProvider>(context);
    final currentLang = localeProv.languageCode;

    final List<Map<String, String>> steps = [
      {
        "title": context.tr("step_1_title"),
        "desc": context.tr("step_1_desc"),
        "status": "Completed"
      },
      {
        "title": context.tr("step_2_title"),
        "desc": context.tr("step_2_desc"),
        "status": "In Progress"
      },
      {
        "title": context.tr("step_3_title"),
        "desc": context.tr("step_3_desc"),
        "status": "Pending"
      },
      {
        "title": context.tr("step_4_title"),
        "desc": context.tr("step_4_desc"),
        "status": "Pending"
      },
      {
        "title": context.tr("step_5_title"),
        "desc": context.tr("step_5_desc"),
        "status": "Pending"
      }
    ];

    final String portalUrl = match.officialApplicationUrl.isNotEmpty
        ? match.officialApplicationUrl
        : match.officialSourceUrl;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr("action_plan_title")),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.language_rounded),
            tooltip: context.tr("change_language"),
            onSelected: (code) => localeProv.setLocale(code),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'en',
                child: Row(
                  children: [
                    const Text("🇬🇧 English"),
                    if (currentLang == 'en') ...[
                      const Spacer(),
                      const Icon(Icons.check, color: AppTheme.primaryBlue, size: 18),
                    ],
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'ta',
                child: Row(
                  children: [
                    const Text("🇮🇳 தமிழ் (Tamil)"),
                    if (currentLang == 'ta') ...[
                      const Spacer(),
                      const Icon(Icons.check, color: AppTheme.primaryBlue, size: 18),
                    ],
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'hi',
                child: Row(
                  children: [
                    const Text("🇮🇳 हिन्दी (Hindi)"),
                    if (currentLang == 'hi') ...[
                      const Spacer(),
                      const Icon(Icons.check, color: AppTheme.primaryBlue, size: 18),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.tr("action_plan_for", {"scheme": match.schemeName}),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              context.tr("administered_by", {"ministry": match.ministry}),
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
            if (portalUrl.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                "Portal: $portalUrl",
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.blue.shade700,
                  decoration: TextDecoration.underline,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: steps.length,
                itemBuilder: (context, index) {
                  final s = steps[index];
                  final bool isDone = s["status"] == "Completed";
                  final bool isInProgress = s["status"] == "In Progress";
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDone
                            ? AppTheme.successGreen
                            : (isInProgress
                                ? AppTheme.accentSaffron
                                : Colors.grey.shade300),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: isDone
                              ? AppTheme.successGreen
                              : (isInProgress
                                  ? AppTheme.accentSaffron
                                  : Colors.grey.shade400),
                          child: Text(
                            "${index + 1}",
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                s["title"]!,
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                s["desc"]!,
                                style: const TextStyle(
                                    fontSize: 13, color: Colors.black87),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _launchUrl(context, portalUrl),
                icon: const Icon(Icons.open_in_new),
                label: Text(context.tr("open_verified_portal_btn")),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
