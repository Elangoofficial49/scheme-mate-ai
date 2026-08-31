class AppLanguage {
  final String code;
  final String name;
  final String nativeName;
  final String flag;

  const AppLanguage({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.flag,
  });
}

class AppLanguages {
  static const List<AppLanguage> supportedLanguages = [
    AppLanguage(code: 'en', name: 'English', nativeName: 'English', flag: '🇬🇧'),
    AppLanguage(code: 'hi', name: 'Hindi', nativeName: 'हिन्दी', flag: '🇮🇳'),
    AppLanguage(code: 'ta', name: 'Tamil', nativeName: 'தமிழ்', flag: '🇮🇳'),
    AppLanguage(code: 'te', name: 'Telugu', nativeName: 'తెలుగు', flag: '🇮🇳'),
    AppLanguage(code: 'kn', name: 'Kannada', nativeName: 'ಕನ್ನಡ', flag: '🇮🇳'),
    AppLanguage(code: 'ml', name: 'Malayalam', nativeName: 'മലയാളം', flag: '🇮🇳'),
    AppLanguage(code: 'mr', name: 'Marathi', nativeName: 'मराठी', flag: '🇮🇳'),
    AppLanguage(code: 'bn', name: 'Bengali', nativeName: 'বাংলা', flag: '🇮🇳'),
    AppLanguage(code: 'gu', name: 'Gujarati', nativeName: 'ગુજરાતી', flag: '🇮🇳'),
    AppLanguage(code: 'pa', name: 'Punjabi', nativeName: 'ਪੰਜਾਬੀ', flag: '🇮🇳'),
    AppLanguage(code: 'or', name: 'Odia', nativeName: 'ଓଡ଼ିଆ', flag: '🇮🇳'),
    AppLanguage(code: 'as', name: 'Assamese', nativeName: 'অসমীয়া', flag: '🇮🇳'),
    AppLanguage(code: 'ur', name: 'Urdu', nativeName: 'اردو', flag: '🇮🇳'),
    AppLanguage(code: 'sa', name: 'Sanskrit', nativeName: 'संस्कृतम्', flag: '🇮🇳'),
    AppLanguage(code: 'mai', name: 'Maithili', nativeName: 'मैथिली', flag: '🇮🇳'),
    AppLanguage(code: 'sat', name: 'Santali', nativeName: 'ᱥᱟᱱᱛᱟᱲᱤ', flag: '🇮🇳'),
    AppLanguage(code: 'ks', name: 'Kashmiri', nativeName: 'कॉशुर / کٲشُر', flag: '🇮🇳'),
    AppLanguage(code: 'ne', name: 'Nepali', nativeName: 'नेपाली', flag: '🇮🇳'),
    AppLanguage(code: 'kok', name: 'Konkani', nativeName: 'कोंकणी', flag: '🇮🇳'),
    AppLanguage(code: 'sd', name: 'Sindhi', nativeName: 'सिन्धी', flag: '🇮🇳'),
    AppLanguage(code: 'doi', name: 'Dogri', nativeName: 'डोगरी', flag: '🇮🇳'),
    AppLanguage(code: 'brx', name: 'Bodo', nativeName: 'बडो', flag: '🇮🇳'),
    AppLanguage(code: 'mni', name: 'Manipuri', nativeName: 'মৈতৈলোন্', flag: '🇮🇳'),
  ];

  static List<String> get supportedCodes => supportedLanguages.map((l) => l.code).toList();

  static AppLanguage getByCode(String code) {
    return supportedLanguages.firstWhere(
      (l) => l.code == code,
      orElse: () => supportedLanguages.first,
    );
  }
}
