import 'package:flutter/material.dart';
import '../core/network/api_client.dart';
import '../core/theme/app_theme.dart';
import 'dashboard_screen.dart';

class BusinessProfileFormScreen extends StatefulWidget {
  const BusinessProfileFormScreen({Key? key}) : super(key: key);

  @override
  State<BusinessProfileFormScreen> createState() => _BusinessProfileFormScreenState();
}

class _BusinessProfileFormScreenState extends State<BusinessProfileFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _companyNameController = TextEditingController(text: "Sri Lakshmi Textiles");
  final _businessDescController = TextEditingController(text: "Garment manufacturing and stitching unit");
  final _ageController = TextEditingController(text: "28");
  final _annualIncomeController = TextEditingController(text: "150000");
  
  String _selectedIncomeSource = "Self-Employed";
  String _selectedCategory = "OBC";
  String _selectedState = "Tamil Nadu";
  String _selectedBusinessType = "Manufacturing";

  bool _isCertificateAttached = false;
  String _attachedCertificateType = "Income Certificate";
  bool _isLoading = false;

  final List<String> _incomeSources = [
    "Self-Employed",
    "Daily Wage / Laborer",
    "Agriculture",
    "Salaried",
    "New Entrepreneur / Unemployed"
  ];

  final List<String> _categories = [
    "General",
    "OBC",
    "SC",
    "ST",
    "Minority"
  ];

  final List<String> _states = [
    "Tamil Nadu",
    "Uttar Pradesh",
    "Bihar",
    "Maharashtra",
    "Karnataka",
    "Gujarat",
    "All India"
  ];

  final List<String> _businessTypes = [
    "Manufacturing",
    "Service & Retail",
    "Trading",
    "Agro & Allied"
  ];

  final List<String> _certificateOptions = [
    "Income Certificate",
    "Community / Caste Certificate",
    "Udyam Registration Certificate",
    "Aadhaar / Identity Proof"
  ];

  void _submitProfileForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final payload = {
      "company_name": _companyNameController.text.trim(),
      "business_description": _businessDescController.text.trim(),
      "age": int.tryParse(_ageController.text.trim()) ?? 28,
      "source_of_income": _selectedIncomeSource,
      "annual_income": double.tryParse(_annualIncomeController.text.trim()) ?? 150000.0,
      "category": _selectedCategory,
      "state": _selectedState,
      "business_type": _selectedBusinessType,
      "certificate_uploaded": _isCertificateAttached,
      "certificate_type": _isCertificateAttached ? _attachedCertificateType : null,
    };

    final res = await ApiClient.put("/profile", payload);

    setState(() => _isLoading = false);

    if (res["success"] == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ Profile saved! Fetching matching scheme recommendations..."),
          backgroundColor: AppTheme.successGreen,
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res["error"]?["message"] ?? "Failed to save profile. Please check connections."),
          backgroundColor: AppTheme.warningOrange,
        ),
      );
    }
  }

  void _simulateCertificateUpload() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Select Certificate Type to Attach",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ..._certificateOptions.map((type) => ListTile(
                    leading: const Icon(Icons.verified_user_outlined, color: AppTheme.primaryBlue),
                    title: Text(type),
                    trailing: const Icon(Icons.upload_file_rounded),
                    onTap: () {
                      Navigator.pop(ctx);
                      setState(() {
                        _isCertificateAttached = true;
                        _attachedCertificateType = type;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("📄 $type attached & verified!"),
                          backgroundColor: AppTheme.successGreen,
                        ),
                      );
                    },
                  )),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Entrepreneur Business Profile"),
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: AppTheme.primaryBlue),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Enter your business details below. Our AI Rule Engine will match eligible government schemes & subsidies tailored for you.",
                        style: TextStyle(fontSize: 13, height: 1.3),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 1. Company Name
              const Text("1. Company / Enterprise Name", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _companyNameController,
                decoration: const InputDecoration(
                  hintText: "e.g. Sri Lakshmi Textiles",
                  prefixIcon: Icon(Icons.business),
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val == null || val.isEmpty ? "Please enter company name" : null,
              ),
              const SizedBox(height: 18),

              // 2. Proposed Business Description
              const Text("2. Details of Proposed Business", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _businessDescController,
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText: "e.g. Garment manufacturing, stitching unit & retail sales",
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val == null || val.isEmpty ? "Please enter business description" : null,
              ),
              const SizedBox(height: 18),

              // 3. Business Type & State
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("3. Business Type", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          value: _selectedBusinessType,
                          decoration: const InputDecoration(border: OutlineInputBorder()),
                          items: _businessTypes
                              .map((type) => DropdownMenuItem(value: type, child: Text(type, style: const TextStyle(fontSize: 13))))
                              .toList(),
                          onChanged: (val) => setState(() => _selectedBusinessType = val!),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("4. State", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          value: _selectedState,
                          decoration: const InputDecoration(border: OutlineInputBorder()),
                          items: _states
                              .map((st) => DropdownMenuItem(value: st, child: Text(st, style: const TextStyle(fontSize: 13))))
                              .toList(),
                          onChanged: (val) => setState(() => _selectedState = val!),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // 4. Age & Annual Income
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("5. Entrepreneur Age", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _ageController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            hintText: "Age",
                            prefixIcon: Icon(Icons.cake),
                            border: OutlineInputBorder(),
                          ),
                          validator: (val) => val == null || val.isEmpty ? "Enter age" : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("6. Annual Income (₹)", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _annualIncomeController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            hintText: "Annual Income",
                            prefixIcon: Icon(Icons.currency_rupee),
                            border: OutlineInputBorder(),
                          ),
                          validator: (val) => val == null || val.isEmpty ? "Enter income" : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // 5. Source of Income
              const Text("7. Primary Source of Income", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _selectedIncomeSource,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.account_balance_wallet),
                  border: OutlineInputBorder(),
                ),
                items: _incomeSources
                    .map((src) => DropdownMenuItem(value: src, child: Text(src)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedIncomeSource = val!),
              ),
              const SizedBox(height: 18),

              // 6. Community / Category
              const Text("8. Community / Social Category", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.people_alt_outlined),
                  border: OutlineInputBorder(),
                ),
                items: _categories
                    .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedCategory = val!),
              ),
              const SizedBox(height: 22),

              // 7. Certificate Upload Section
              const Text("9. Attach Certificate (Optional)", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              InkWell(
                onTap: _simulateCertificateUpload,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _isCertificateAttached ? AppTheme.successGreen.withOpacity(0.1) : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _isCertificateAttached ? AppTheme.successGreen : Colors.grey.shade400,
                      width: _isCertificateAttached ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _isCertificateAttached ? Icons.check_circle : Icons.upload_file_rounded,
                        color: _isCertificateAttached ? AppTheme.successGreen : AppTheme.primaryBlue,
                        size: 30,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isCertificateAttached ? _attachedCertificateType : "Tap to Upload Certificate",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: _isCertificateAttached ? AppTheme.successGreen : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _isCertificateAttached
                                  ? "Document verified & linked to profile"
                                  : "Upload Income / Category / Udyam Certificate for hard verification",
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _simulateCertificateUpload,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          backgroundColor: _isCertificateAttached ? AppTheme.successGreen : AppTheme.primaryBlue,
                        ),
                        child: Text(_isCertificateAttached ? "Change" : "Upload"),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitProfileForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: AppTheme.primaryBlue,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Save Profile & Get Scheme Suggestions ->",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
