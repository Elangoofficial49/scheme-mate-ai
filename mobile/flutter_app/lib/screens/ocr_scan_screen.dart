import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../core/network/api_client.dart';
import '../core/theme/app_theme.dart';
import '../services/document_scan_service.dart';
import 'dashboard_screen.dart';

class OCRScanScreen extends StatefulWidget {
  const OCRScanScreen({super.key});

  @override
  State<OCRScanScreen> createState() => _OCRScanScreenState();
}

class _OCRScanScreenState extends State<OCRScanScreen> {
  final _numberController = TextEditingController();
  final _nameController = TextEditingController();
  final _extraController = TextEditingController();
  String _selectedDocType = "Aadhaar";
  bool _isProcessing = false;
  bool _isSaving = false;
  XFile? _selectedImage;
  String? _scanSource;
  String? _scanMessage;

  bool get _isAadhaar => _selectedDocType == "Aadhaar";

  String get _extraFieldLabel {
    switch (_selectedDocType) {
      case "Aadhaar":
        return "State (optional)";
      case "Udyam":
        return "Enterprise name (optional)";
      case "Income":
        return "Annual income (optional)";
      default:
        return "Additional detail (optional)";
    }
  }

  Future<void> _pickAndScan(ImageSource source) async {
    try {
      final image = await ImagePicker().pickImage(
        source: source,
        imageQuality: 90,
        maxWidth: 2400,
      );
      if (image == null || !mounted) return;

      setState(() {
        _selectedImage = image;
        _isProcessing = true;
        _scanSource = null;
        _scanMessage = null;
        _numberController.clear();
        _nameController.clear();
        _extraController.clear();
      });

      final result =
          await DocumentScanService.scanImage(image.path, _selectedDocType);
      if (!mounted) return;

      setState(() {
        _isProcessing = false;
        _scanSource = result.source;
        if (result.identifier != null) {
          _numberController.text = result.identifier!;
          _scanMessage =
              "Found a possible document number. Review and correct it before confirming.";
        } else {
          _scanMessage =
              "No matching number was detected. Enter it manually below.";
        }
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
        _scanMessage = error is UnsupportedError
            ? error.message.toString()
            : "Could not scan this image. Check that it is clear, or enter the number manually.";
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_scanMessage!)),
      );
    }
  }

  Future<void> _confirmAndSave() async {
    final enteredNumber = _numberController.text.trim();
    final documentNumber = _isAadhaar
        ? enteredNumber.replaceAll(RegExp(r'[\s-]'), '')
        : enteredNumber;
    if (enteredNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter the document number to continue.")),
      );
      return;
    }
    if (_isAadhaar && !RegExp(r'^\d{12}$').hasMatch(documentNumber)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Aadhaar number must contain 12 digits.")),
      );
      return;
    }

    final payload = <String, dynamic>{
      "certificate_uploaded": true,
      "certificate_type": _selectedDocType == "Udyam"
          ? "Udyam Registration Certificate"
          : "$_selectedDocType Document",
      "certificate_number": documentNumber,
    };
    final name = _nameController.text.trim();
    final extra = _extraController.text.trim();
    if (name.isNotEmpty && _selectedDocType != "Udyam") {
      payload["full_name"] = name;
    }
    if (_isAadhaar && extra.isNotEmpty) {
      payload["state"] = extra;
    } else if (_selectedDocType == "Udyam") {
      if (extra.isNotEmpty) payload["company_name"] = extra;
      payload["has_udyam_registration"] = true;
    } else if (_selectedDocType == "Income") {
      final income = double.tryParse(extra.replaceAll(RegExp(r'[^0-9.]'), ''));
      if (income != null) payload["annual_income"] = income;
    }

    setState(() => _isSaving = true);
    try {
      final response = await ApiClient.put("/profile", payload);
      if (!mounted) return;
      if (response["success"] != true) {
        final message = response["error"]?["message"]?.toString() ??
            "The profile could not be updated.";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("$_selectedDocType details saved to your profile."),
          backgroundColor: AppTheme.successGreen,
        ),
      );
      Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _resetForDocumentType(String value) {
    setState(() {
      _selectedDocType = value;
      _selectedImage = null;
      _scanSource = null;
      _scanMessage = null;
      _numberController.clear();
      _nameController.clear();
      _extraController.clear();
    });
  }

  @override
  void dispose() {
    _numberController.dispose();
    _nameController.dispose();
    _extraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Document Verification"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          tooltip: "Back",
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const DashboardScreen()),
              );
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Scan a QR code first. If none is found, text recognition runs on your device.",
              style: TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 8),
            const Text(
              "Scanning only extracts possible text; it does not verify that a document is genuine.",
              style: TextStyle(color: Colors.black54, fontSize: 13),
            ),
            const SizedBox(height: 18),
            DropdownButtonFormField<String>(
              initialValue: _selectedDocType,
              decoration: const InputDecoration(
                labelText: "Document type",
                border: OutlineInputBorder(),
              ),
              items: ["Aadhaar", "PAN", "Udyam", "Income"]
                  .map((type) =>
                      DropdownMenuItem(value: type, child: Text(type)))
                  .toList(),
              onChanged: _isProcessing || _isSaving
                  ? null
                  : (value) {
                      if (value != null) _resetForDocumentType(value);
                    },
            ),
            const SizedBox(height: 16),
            if (DocumentScanService.supportsOnDeviceScanning) ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isProcessing || _isSaving
                          ? null
                          : () => _pickAndScan(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt_outlined),
                      label: const Text("Take photo"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isProcessing || _isSaving
                          ? null
                          : () => _pickAndScan(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library_outlined),
                      label: const Text("Choose image"),
                    ),
                  ),
                ],
              ),
            ] else ...[
              const Text(
                "On-device scanning is supported on Android and iOS. You can enter the details manually here.",
                style: TextStyle(color: Colors.black54),
              ),
            ],
            if (_selectedImage != null) ...[
              const SizedBox(height: 4),
              Text("Selected: ${_selectedImage!.name}",
                  style: const TextStyle(color: Colors.black54)),
            ],
            if (_isProcessing) ...[
              const SizedBox(height: 12),
              const LinearProgressIndicator(),
              const SizedBox(height: 8),
              const Text("Checking QR code, then reading document text…"),
            ],
            if (_scanSource != null) ...[
              const SizedBox(height: 12),
              Text("Extraction source: $_scanSource",
                  style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
            if (_scanMessage != null) ...[
              const SizedBox(height: 8),
              Text(_scanMessage!,
                  style: const TextStyle(color: Colors.black54)),
            ],
            const SizedBox(height: 20),
            TextField(
              controller: _numberController,
              keyboardType:
                  _isAadhaar ? TextInputType.number : TextInputType.text,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: _selectedDocType == "Udyam"
                    ? "Udyam registration number"
                    : _selectedDocType == "Income"
                        ? "Certificate number"
                        : "$_selectedDocType number",
                helperText: "Review the extracted value or enter it manually.",
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: _selectedDocType == "Udyam"
                    ? "Contact name (optional)"
                    : "Name (optional)",
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _extraController,
              keyboardType: _selectedDocType == "Income"
                  ? const TextInputType.numberWithOptions(decimal: true)
                  : TextInputType.text,
              decoration: InputDecoration(
                labelText: _extraFieldLabel,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                border: Border.all(color: Colors.amber.shade300),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: AppTheme.primaryBlue),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Check every value before confirming. OCR or a QR payload is not proof of authenticity.",
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isProcessing ||
                        _isSaving ||
                        _numberController.text.trim().isEmpty
                    ? null
                    : _confirmAndSave,
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check_circle_outline),
                label: Text(_isSaving ? "Saving…" : "Confirm and save"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
