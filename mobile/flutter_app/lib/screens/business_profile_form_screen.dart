import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/network/api_client.dart';
import '../core/theme/app_theme.dart';
import '../providers/locale_provider.dart';
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
  final _certificateNumberController = TextEditingController();
  final _customCasteController = TextEditingController();
  final _customBusinessTypeController = TextEditingController();
  final _customStateController = TextEditingController();
  
  String _selectedIncomeSource = "Self-Employed";
  String _selectedCategory = "OBC (Other Backward Class)";
  String _selectedState = "Tamil Nadu";
  String _selectedBusinessType = "Manufacturing";
  String _selectedCertificateType = "Udyam Registration Certificate";
  bool _isLoading = false;

  final List<String> _incomeSources = [
    "Self-Employed",
    "Daily Wage / Laborer",
    "Agriculture",
    "Salaried",
    "New Entrepreneur / Unemployed"
  ];

  final List<String> _categories = [
    "General / OC",
    "OBC (Other Backward Class)",
    "BC (Backward Class)",
    "MBC (Most Backward Class)",
    "SC (Scheduled Caste)",
    "ST (Scheduled Tribe)",
    "EWS (Economically Weaker Section)",
    "Minority (Muslim/Christian/Sikh/etc.)",
    "DNT / NT (Denotified / Nomadic)",
    "Other (Specify manually)"
  ];

  final List<String> _states = [
    "Andhra Pradesh",
    "Arunachal Pradesh",
    "Assam",
    "Bihar",
    "Chhattisgarh",
    "Goa",
    "Gujarat",
    "Haryana",
    "Himachal Pradesh",
    "Jharkhand",
    "Karnataka",
    "Kerala",
    "Madhya Pradesh",
    "Maharashtra",
    "Manipur",
    "Meghalaya",
    "Mizoram",
    "Nagaland",
    "Odisha",
    "Punjab",
    "Rajasthan",
    "Sikkim",
    "Tamil Nadu",
    "Telangana",
    "Tripura",
    "Uttar Pradesh",
    "Uttarakhand",
    "West Bengal",
    "Andaman and Nicobar Islands",
    "Chandigarh",
    "Dadra and Nagar Haveli and Daman and Diu",
    "Delhi (NCT)",
    "Jammu and Kashmir",
    "Ladakh",
    "Lakshadweep",
    "Puducherry",
    "All India",
    "Other (Specify manually)",
  ];

  final List<String> _businessTypes = [
    "Manufacturing",
    "Service & Retail",
    "Trading / Wholesale",
    "Agro & Allied Activities",
    "Handicrafts & Handlooms",
    "Food Processing & Catering",
    "Construction & Infrastructure",
    "Transportation & Logistics",
    "Renewable Energy & Waste Management",
    "Healthcare & Pharmaceuticals",
    "Education & Skill Training",
    "Information Technology & Software",
    "Textiles & Apparel",
    "Automobile & Mechanical Repair",
    "Other (Specify manually)",
  ];

  final List<String> _certificateOptions = [
    "Udyam Registration Certificate",
    "Income Certificate",
    "Community / Caste Certificate",
    "Aadhaar / Identity Proof",
    "Ration / Smart Card"
  ];

  @override
  void initState() {
    super.initState();
    _fetchExistingProfile();
  }

  void _fetchExistingProfile() async {
    final res = await ApiClient.get("/profile");
    if (res["success"] == true && res["data"] != null && mounted) {
      final data = res["data"];
      setState(() {
        if (data["company_name"] != null && (data["company_name"] as String).isNotEmpty) {
          _companyNameController.text = data["company_name"];
        }
        if (data["business_description"] != null && (data["business_description"] as String).isNotEmpty) {
          _businessDescController.text = data["business_description"];
        }
        if (data["age"] != null) {
          _ageController.text = data["age"].toString();
        }
        if (data["annual_income"] != null) {
          _annualIncomeController.text = data["annual_income"].toString();
        }
        if (data["source_of_income"] != null && _incomeSources.contains(data["source_of_income"])) {
          _selectedIncomeSource = data["source_of_income"];
        }
        if (data["category"] != null && (data["category"] as String).isNotEmpty) {
          final cat = data["category"] as String;
          if (_categories.contains(cat)) {
            _selectedCategory = cat;
          } else {
            final match = _categories.firstWhere(
              (c) => c.toLowerCase().startsWith(cat.toLowerCase()) || cat.toLowerCase().startsWith(c.split(' ').first.toLowerCase()),
              orElse: () => "Other (Specify manually)",
            );
            if (match == "Other (Specify manually)") {
              _selectedCategory = "Other (Specify manually)";
              _customCasteController.text = cat;
            } else {
              _selectedCategory = match;
            }
          }
        }
        if (data["state"] != null && (data["state"] as String).isNotEmpty) {
          final st = data["state"] as String;
          if (_states.contains(st)) {
            _selectedState = st;
          } else {
            final match = _states.firstWhere(
              (s) => s.toLowerCase() == st.toLowerCase() || s.toLowerCase().contains(st.toLowerCase()),
              orElse: () => "Other (Specify manually)",
            );
            if (match == "Other (Specify manually)") {
              _selectedState = "Other (Specify manually)";
              _customStateController.text = st;
            } else {
              _selectedState = match;
            }
          }
        }
        if (data["business_type"] != null && (data["business_type"] as String).isNotEmpty) {
          final bType = data["business_type"] as String;
          if (_businessTypes.contains(bType)) {
            _selectedBusinessType = bType;
          } else {
            final match = _businessTypes.firstWhere(
              (bt) => bt.toLowerCase().contains(bType.toLowerCase()) || bType.toLowerCase().contains(bt.split(' ').first.toLowerCase()),
              orElse: () => "Other (Specify manually)",
            );
            if (match == "Other (Specify manually)") {
              _selectedBusinessType = "Other (Specify manually)";
              _customBusinessTypeController.text = bType;
            } else {
              _selectedBusinessType = match;
            }
          }
        }
        if (data["certificate_type"] != null && _certificateOptions.contains(data["certificate_type"])) {
          _selectedCertificateType = data["certificate_type"];
        }
        if (data["certificate_number"] != null) {
          _certificateNumberController.text = data["certificate_number"].toString();
        }
      });
    }
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _businessDescController.dispose();
    _ageController.dispose();
    _annualIncomeController.dispose();
    _certificateNumberController.dispose();
    _customCasteController.dispose();
    _customBusinessTypeController.dispose();
    _customStateController.dispose();
    super.dispose();
  }

  String _getCertificateNumberLabel(String certType) {
    if (certType.contains("Udyam")) {
      return "Udyam Registration Number (URN)";
    } else if (certType.contains("Income")) {
      return "Income Certificate Number";
    } else if (certType.contains("Community")) {
      return "Community / Caste Certificate Number";
    } else if (certType.contains("Aadhaar")) {
      return "Aadhaar Number / Virtual ID";
    } else if (certType.contains("Ration")) {
      return "Ration / Smart Card Number";
    }
    return "Certificate / Registration Number";
  }

  String _getCertificatePlaceholder(String certType) {
    if (certType.contains("Udyam")) {
      return "e.g. UDYAM-TN-01-0012345";
    } else if (certType.contains("Income")) {
      return "e.g. INC/2024/09876";
    } else if (certType.contains("Community")) {
      return "e.g. COMM-OBC-2023-456";
    } else if (certType.contains("Aadhaar")) {
      return "e.g. 12-digit Aadhaar / VID";
    } else if (certType.contains("Ration")) {
      return "e.g. 33/W/0123456";
    }
    return "Enter certificate number";
  }

  void _submitProfileForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final certNum = _certificateNumberController.text.trim();
    final hasCert = certNum.isNotEmpty;
    final finalCategory = _selectedCategory == "Other (Specify manually)"
        ? (_customCasteController.text.trim().isNotEmpty ? _customCasteController.text.trim() : "Other")
        : _selectedCategory;
    final finalBusinessType = _selectedBusinessType == "Other (Specify manually)"
        ? (_customBusinessTypeController.text.trim().isNotEmpty ? _customBusinessTypeController.text.trim() : "Other")
        : _selectedBusinessType;
    final finalState = _selectedState == "Other (Specify manually)"
        ? (_customStateController.text.trim().isNotEmpty ? _customStateController.text.trim() : "Other")
        : _selectedState;

    final payload = {
      "company_name": _companyNameController.text.trim(),
      "business_description": _businessDescController.text.trim(),
      "age": int.tryParse(_ageController.text.trim()) ?? 28,
      "source_of_income": _selectedIncomeSource,
      "annual_income": double.tryParse(_annualIncomeController.text.trim()) ?? 150000.0,
      "category": finalCategory,
      "state": finalState,
      "business_type": finalBusinessType,
      "certificate_uploaded": hasCert,
      "certificate_type": hasCert ? _selectedCertificateType : null,
      "certificate_number": hasCert ? certNum : null,
      "has_udyam_registration": hasCert && _selectedCertificateType.contains("Udyam"),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Entrepreneur Business Profile"),
        elevation: 2,
        actions: [
          Consumer<LocaleProvider>(
            builder: (context, localeProv, _) {
              final currentLang = localeProv.languageCode;
              return PopupMenuButton<String>(
                icon: const Icon(Icons.language_rounded),
                tooltip: "Change Language / மொழியை மாற்றுக",
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
              );
            },
          ),
        ],
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("3. Business Type", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          value: _selectedBusinessType,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                          ),
                          items: _businessTypes
                              .map((type) => DropdownMenuItem(
                                    value: type,
                                    child: Text(type, style: const TextStyle(fontSize: 12.5), overflow: TextOverflow.ellipsis),
                                  ))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _selectedBusinessType = val);
                            }
                          },
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
                          isExpanded: true,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                          ),
                          items: _states
                              .map((st) => DropdownMenuItem(
                                    value: st,
                                    child: Text(st, style: const TextStyle(fontSize: 12.5), overflow: TextOverflow.ellipsis),
                                  ))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _selectedState = val);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (_selectedBusinessType == "Other (Specify manually)") ...[
                const SizedBox(height: 10),
                TextFormField(
                  controller: _customBusinessTypeController,
                  decoration: const InputDecoration(
                    labelText: "Enter Business Type / Domain",
                    hintText: "e.g. Drone Services, Organic Bio-Fertilizers, Eco Packaging",
                    prefixIcon: Icon(Icons.edit_note),
                    border: OutlineInputBorder(),
                    helperText: "Specify your exact business domain for industry-specific subsidies.",
                  ),
                  validator: (val) {
                    if (_selectedBusinessType == "Other (Specify manually)" && (val == null || val.trim().isEmpty)) {
                      return "Please enter your business type";
                    }
                    return null;
                  },
                ),
              ],
              if (_selectedState == "Other (Specify manually)") ...[
                const SizedBox(height: 10),
                TextFormField(
                  controller: _customStateController,
                  decoration: const InputDecoration(
                    labelText: "Enter State / Region / UT",
                    hintText: "e.g. Goa, Ladakh, Telangana, Special Economic Zone",
                    prefixIcon: Icon(Icons.location_city),
                    border: OutlineInputBorder(),
                    helperText: "Specify your state or territory for state-level subsidy schemes.",
                  ),
                  validator: (val) {
                    if (_selectedState == "Other (Specify manually)" && (val == null || val.trim().isEmpty)) {
                      return "Please enter your state / territory";
                    }
                    return null;
                  },
                ),
              ],
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

              // 6. Community / Category / Caste
              const Text("8. Community / Social Category / Caste", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.people_alt_outlined),
                  border: OutlineInputBorder(),
                ),
                items: _categories
                    .map((cat) => DropdownMenuItem(value: cat, child: Text(cat, style: const TextStyle(fontSize: 13.5))))
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedCategory = val);
                  }
                },
              ),
              if (_selectedCategory == "Other (Specify manually)") ...[
                const SizedBox(height: 10),
                TextFormField(
                  controller: _customCasteController,
                  decoration: const InputDecoration(
                    labelText: "Enter Caste / Community Name",
                    hintText: "e.g. Yadava, Thevar, Vanniyar, Vankar, Meena, etc.",
                    prefixIcon: Icon(Icons.edit_note),
                    border: OutlineInputBorder(),
                    helperText: "Specify your caste or sub-caste for targeted government schemes.",
                  ),
                  validator: (val) {
                    if (_selectedCategory == "Other (Specify manually)" && (val == null || val.trim().isEmpty)) {
                      return "Please enter your caste / community name";
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 22),

              // 7. Certificate Details / Number Section
              const Text("9. Enter Required Certificate / Registration Number (Optional)",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              const Text(
                "Enter your official certificate or registration number to verify eligibility for targeted subsidies and schemes.",
                style: TextStyle(fontSize: 13, color: Colors.black54),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _certificateNumberController.text.trim().isNotEmpty
                        ? AppTheme.successGreen
                        : Colors.grey.shade300,
                    width: _certificateNumberController.text.trim().isNotEmpty ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Select Certificate Type", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: _selectedCertificateType,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.assignment_turned_in_outlined),
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      items: _certificateOptions
                          .map((opt) => DropdownMenuItem(value: opt, child: Text(opt, style: const TextStyle(fontSize: 14))))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedCertificateType = val);
                        }
                      },
                    ),
                    const SizedBox(height: 14),
                    Text(
                      _getCertificateNumberLabel(_selectedCertificateType),
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _certificateNumberController,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: _getCertificatePlaceholder(_selectedCertificateType),
                        prefixIcon: const Icon(Icons.confirmation_number_outlined),
                        suffixIcon: _certificateNumberController.text.trim().isNotEmpty
                            ? const Icon(Icons.check_circle, color: AppTheme.successGreen)
                            : null,
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                    ),
                    if (_certificateNumberController.text.trim().isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.successGreen.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.verified, size: 16, color: AppTheme.successGreen),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "Certificate Linked: ${_certificateNumberController.text.trim()}",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.successGreen,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
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

