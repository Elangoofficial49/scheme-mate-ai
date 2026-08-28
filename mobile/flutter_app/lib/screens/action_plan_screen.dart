import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../models/match_result_model.dart';

class ActionPlanScreen extends StatelessWidget {
  final MatchResultModel match;
  const ActionPlanScreen({Key? key, required this.match}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> steps = [
      {
        "step": "Step 1",
        "title": "Check Eligibility Criteria",
        "desc": "Verify age, income, and business type alignment with scheme rules.",
        "status": "Completed"
      },
      {
        "step": "Step 2",
        "title": "Prepare Required Document Checklist",
        "desc": "Gather Aadhaar, PAN, and Udyam Registration Certificate.",
        "status": "In Progress"
      },
      {
        "step": "Step 3",
        "title": "Complete Missing Requirements",
        "desc": "Scan and confirm document extraction using OCR assistant.",
        "status": "Pending"
      },
      {
        "step": "Step 4",
        "title": "Open Official Application Portal",
        "desc": "Navigate safely to verified portal URL.",
        "status": "Pending"
      },
      {
        "step": "Step 5",
        "title": "Submit Application & Track Status",
        "desc": "Submit on official portal and log reference number.",
        "status": "Pending"
      }
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Application Action Plan")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Action Plan for ${match.schemeName}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text("Administered by ${match.ministry}", style: const TextStyle(fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: steps.length,
                itemBuilder: (context, index) {
                  final s = steps[index];
                  bool isDone = s["status"] == "Completed";
                  bool isInProgress = s["status"] == "In Progress";
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDone
                            ? AppTheme.successGreen
                            : (isInProgress ? AppTheme.accentSaffron : Colors.grey.shade300),
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
                              : (isInProgress ? AppTheme.accentSaffron : Colors.grey.shade400),
                          child: Text("${index + 1}", style: const TextStyle(color: Colors.white, fontSize: 12)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(s["title"]!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(s["desc"]!, style: const TextStyle(fontSize: 13, color: Colors.black87)),
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
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Redirecting to Official Verified Portal: ${match.officialApplicationUrl}")),
                  );
                },
                icon: const Icon(Icons.open_in_new),
                label: const Text("Open Verified Official Application Portal"),
              ),
            )
          ],
        ),
      ),
    );
  }
}

