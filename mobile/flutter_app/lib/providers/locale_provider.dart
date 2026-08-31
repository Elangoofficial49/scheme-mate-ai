import 'package:flutter/material.dart';
import '../core/i18n/app_languages.dart';
import '../core/offline_db/offline_cache.dart';

class LocaleProvider with ChangeNotifier {
  Locale _currentLocale = const Locale('en', '');

  Locale get currentLocale => _currentLocale;
  String get languageCode => _currentLocale.languageCode;

  LocaleProvider() {
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    final savedCode = await OfflineCache.getLanguage();
    if (AppLanguages.supportedCodes.contains(savedCode)) {
      _currentLocale = Locale(savedCode, '');
      notifyListeners();
    }
  }

  Future<void> setLocale(String languageCode) async {
    if (!AppLanguages.supportedCodes.contains(languageCode)) return;
    if (_currentLocale.languageCode == languageCode) return;

    _currentLocale = Locale(languageCode, '');
    notifyListeners();
    await OfflineCache.saveLanguage(languageCode);
  }
}
