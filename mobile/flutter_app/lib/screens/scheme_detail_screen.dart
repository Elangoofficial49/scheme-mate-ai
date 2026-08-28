import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../models/match_result_model.dart';
import 'action_plan_screen.dart';
import 'ocr_scan_screen.dart';

class SchemeDetailScreen extends StatelessWidget {
  final MatchResultModel match;
  const SchemeDetailScreen({Key? key, required this.match}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scheme Details")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(match.schemeName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(match.ministry, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: match.matchScore >= 80 ? AppTheme.successGreen : AppTheme.warningOrange,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(match.matchLabel, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 10),
                      Text("Verified: ${match.lastVerified}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text("Why This Scheme Matches You", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ...match.whyMatches.map((reason) => Padding(
              padding: const EdgeInsets.only(bottom: 6.0),
              child: Text(reason, style: const TextStyle(fontSize: 15, color: AppTheme.successGreen, fontWeight: FontWeight.w600)),
            )),
            if (match.whyNot.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text("Important Verification Considerations", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              ...match.whyNot.map((note) => Padding(
                padding: const EdgeInsets.only(bottom: 6.0),
                child: Text(note, style: const TextStyle(fontSize: 15, color: AppTheme.warningOrange)),
              )),
            ],
            const SizedBox(height: 20),
            const Text("Required Document Checklist", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            if (match.requiredDocuments.isEmpty)
              const Text("Standard KYC documents (Aadhaar, PAN, Bank Passbook)")
            else
              ...match.requiredDocuments.map((doc) {
                String docName = doc is Map ? doc["name"] ?? "" : doc.toString();
                bool mandatory = doc is Map ? doc["mandatory"] == true : true;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        mandatory ? Icons.check_circle_outline : Icons.info_outline,
                        color: mandatory ? AppTheme.successGreen : Colors.grey,
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: Text(docName, style: const TextStyle(fontSize: 15))),
                      if (mandatory)
                        const Text("Required", style: TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.bold))
                    ],
                  ),
                );
              }),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const OCRScanScreen()),
                      );
                    },
                    icon: const Icon(Icons.document_scanner),
                    label: const Text("Scan Document"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ActionPlanScreen(match: match),
                        ),
                      );
                    },
                    icon: const Icon(Icons.list_alt),
                    label: const Text("Action Plan"),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

