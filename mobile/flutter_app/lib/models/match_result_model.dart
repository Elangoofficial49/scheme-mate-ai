class MatchResultModel {
  final String schemeId;
  final String schemeName;
  final String ministry;
  final double matchScore;
  final String matchLabel;
  final String eligibilityStatus;
  final List<String> whyMatches;
  final List<String> whyNot;
  final List<String> missingInformation;
  final List<dynamic> requiredDocuments;
  final String officialApplicationUrl;
  final String officialSourceUrl;
  final String lastVerified;

  MatchResultModel({
    required this.schemeId,
    required this.schemeName,
    required this.ministry,
    required this.matchScore,
    required this.matchLabel,
    required this.eligibilityStatus,
    required this.whyMatches,
    required this.whyNot,
    required this.missingInformation,
    required this.requiredDocuments,
    required this.officialApplicationUrl,
    required this.officialSourceUrl,
    required this.lastVerified,
  });

  factory MatchResultModel.fromJson(Map<String, dynamic> json) {
    return MatchResultModel(
      schemeId: json['scheme_id'] ?? '',
      schemeName: json['scheme_name'] ?? '',
      ministry: json['ministry'] ?? '',
      matchScore: (json['match_score'] ?? 0.0).toDouble(),
      matchLabel: json['match_label'] ?? '',
      eligibilityStatus: json['eligibility_status'] ?? 'Potentially Eligible',
      whyMatches: List<String>.from(json['why_matches'] ?? []),
      whyNot: List<String>.from(json['why_not'] ?? []),
      missingInformation: List<String>.from(json['missing_information'] ?? []),
      requiredDocuments: json['required_documents'] ?? [],
      officialApplicationUrl: json['official_application_url'] ?? '',
      officialSourceUrl: json['official_source_url'] ?? '',
      lastVerified: json['last_verified'] ?? '',
    );
  }
}

