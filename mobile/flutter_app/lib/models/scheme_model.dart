class SchemeModel {
  final String id;
  final String schemeName;
  final String ministry;
  final String? department;
  final String description;
  final String schemeType;
  final String targetBeneficiary;
  final String benefits;
  final String officialApplicationUrl;
  final String officialSourceUrl;
  final String state;
  final String lastVerified;

  SchemeModel({
    required this.id,
    required this.schemeName,
    required this.ministry,
    this.department,
    required this.description,
    required this.schemeType,
    required this.targetBeneficiary,
    required this.benefits,
    required this.officialApplicationUrl,
    required this.officialSourceUrl,
    required this.state,
    required this.lastVerified,
  });

  factory SchemeModel.fromJson(Map<String, dynamic> json) {
    return SchemeModel(
      id: json['id'] ?? '',
      schemeName: json['scheme_name'] ?? '',
      ministry: json['ministry'] ?? '',
      department: json['department'],
      description: json['description'] ?? '',
      schemeType: json['scheme_type'] ?? '',
      targetBeneficiary: json['target_beneficiary'] ?? '',
      benefits: json['benefits'] ?? '',
      officialApplicationUrl: json['official_application_url'] ?? '',
      officialSourceUrl: json['official_source_url'] ?? '',
      state: json['state'] ?? 'All India',
      lastVerified: json['last_verified'] ?? '2026-08-01',
    );
  }
}

