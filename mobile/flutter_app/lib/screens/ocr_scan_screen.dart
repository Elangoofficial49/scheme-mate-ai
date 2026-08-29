import 'package:flutter/material.dart';
import '../core/network/api_client.dart';
import '../core/theme/app_theme.dart';

class OCRScanScreen extends StatefulWidget {
  const OCRScanScreen({Key? key}) : super(key: key);

  @override
  State<OCRScanScreen> createState() => _OCRScanScreenState();
}

class _OCRScanScreenState extends State<OCRScanScreen> {
  String _selectedDocType = "Aadhaar";
  bool _isProcessing = false;
  Map<String, dynamic>? _extractedData;

  void _simulateScan() async {
    setState(() {
      _isProcessing = true;
      _extractedData = null;
    });

    await Future.delayed(const Duration(seconds: 2));

    // Simulate OCR entity extraction result payload
    Map<String, dynamic> dummyExtracted = {};
    if (_selectedDocType == "Aadhaar") {
      dummyExtracted = {
        "Document Name": "Aadhaar Card",
        "Name": "Kavitha R",
        "Aadhaar Number": "3489 1204 9871",
        "Gender": "Female",
        "State": "Tamil Nadu"
      };
    } else if (_selectedDocType == "PAN") {
      dummyExtracted = {
        "Document Name": "PAN Card",
        "Name": "Kavitha R",
        "PAN Number": "ABCDE1234F",
        "Father Name": "Ramasamy M"
      };
    } else if (_selectedDocType == "Udyam") {
      dummyExtracted = {
        "Document Name": "Udyam Certificate",
        "Udyam Number": "UDYAM-TN-03-0012345",
        "Enterprise": "Kavitha Tailoring",
        "Category": "Micro Enterprise"
      };
    } else {
      dummyExtracted = {
        "Document Name": "Income Certificate",
        "Certificate No": "INC/2026/98231",
        "Annual Income": "Rs. 1,80,000"
      };
    }

    setState(() {
      _isProcessing = false;
      _extractedData = dummyExtracted;
    });
  }

  void _confirmAndSave() async {
    Map<String, dynamic> updatePayload = {
      "certificate_uploaded": true,
      "certificate_type": _selectedDocType == "Udyam"
          ? "Udyam Registration Certificate"
          : "${_selectedDocType} Document",
    };
    if (_selectedDocType == "Aadhaar") {
      updatePayload["full_name"] = _extractedData?["Name"] ?? "Kavitha R";
      updatePayload["state"] = _extractedData?["State"] ?? "Tamil Nadu";
    } else if (_selectedDocType == "Udyam") {
      updatePayload["company_name"] = _extractedData?["Enterprise"] ?? "Kavitha Tailoring";
      updatePayload["has_udyam_registration"] = true;
      updatePayload["business_type"] = "Manufacturing";
    } else if (_selectedDocType == "Income") {
      updatePayload["annual_income"] = 180000.0;
    }

    await ApiClient.put("/profile", updatePayload);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("✓ $_selectedDocType details verified and updated in user profile!"),
          backgroundColor: AppTheme.successGreen,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Document OCR Assistant")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Select Document Type to Scan", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedDocType,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: ["Aadhaar", "PAN", "Udyam", "Income"]
                  .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                  .toList(),
              onChanged: (val) => setState(() => _selectedDocType = val!),
            ),
            const SizedBox(height: 20),
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade400, style: BorderStyle.solid),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt_outlined, size: 50, color: Colors.grey.shade700),
                    const SizedBox(height: 10),
                    const Text("Capture or Upload Document Photo", style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isProcessing ? null : _simulateScan,
                icon: const Icon(Icons.document_scanner),
                label: Text(_isProcessing ? "Scanning OCR..." : "Start OCR Extraction"),
              ),
            ),
            const SizedBox(height: 24),
            if (_isProcessing)
              const Center(child: CircularProgressIndicator())
            else if (_extractedData != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.shade400),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.security, color: AppTheme.primaryBlue),
                        SizedBox(width: 8),
                        Text(
                          "Information Detected (User Confirmation Required)",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    ..._extractedData!.entries.map((entry) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Text("${entry.key}: ", style: const TextStyle(fontWeight: FontWeight.bold)),
                          Expanded(child: Text(entry.value.toString())),
                        ],
                      ),
                    )),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => _extractedData = null),
                      child: const Text("Edit / Re-scan"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _confirmAndSave,
                      child: const Text("Confirm & Update"),
                    ),
                  ),
                ],
              )
            ]
          ],
        ),
      ),
    );
  }
}

