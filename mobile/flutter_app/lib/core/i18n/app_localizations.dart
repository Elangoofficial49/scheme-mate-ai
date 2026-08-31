import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_languages.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  Map<String, String> _localizedStrings = {};

  Future<bool> load() async {
    Map<String, String> baseStrings = {};

    // 1. Load English default strings as base fallback
    try {
      String enJson = await rootBundle.loadString('assets/i18n/en.json');
      Map<String, dynamic> enMap = json.decode(enJson);
      baseStrings = enMap.map((key, value) => MapEntry(key, value.toString()));
    } catch (_) {}

    // 2. Load requested language JSON if available and merge
    if (locale.languageCode != 'en') {
      try {
        String langJson = await rootBundle.loadString('assets/i18n/${locale.languageCode}.json');
        Map<String, dynamic> langMap = json.decode(langJson);
        langMap.forEach((key, value) {
          if (value != null && value.toString().isNotEmpty) {
            baseStrings[key] = value.toString();
          }
        });
      } catch (_) {}
    }

    _localizedStrings = baseStrings;
    return true;
  }

  String translate(String key) {
    return _localizedStrings[key] ?? key;
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLanguages.supportedCodes.contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => true;
}

extension LocalizationExtension on BuildContext {
  String tr(String key, [Map<String, String>? args]) {
    String val = AppLocalizations.of(this)?.translate(key) ?? key;
    if (args != null) {
      args.forEach((k, v) {
        val = val.replaceAll('{$k}', v);
      });
    }
    return val;
  }
}
