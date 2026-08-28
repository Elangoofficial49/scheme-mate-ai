import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class OfflineCache {
  static const String _schemesKey = "cached_schemes_data";
  static const String _profileKey = "cached_user_profile";
  static const String _languageKey = "user_preferred_language";

  static Future<void> saveLanguage(String langCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, langCode);
  }

  static Future<String> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageKey) ?? 'en';
  }

  static Future<void> cacheSchemes(List<dynamic> schemes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_schemesKey, json.encode(schemes));
  }

  static Future<List<dynamic>> getCachedSchemes() async {
    final prefs = await SharedPreferences.getInstance();
    String? raw = prefs.getString(_schemesKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        return json.decode(raw);
      } catch (_) {}
    }
    return [];
  }

  static Future<void> cacheProfile(Map<String, dynamic> profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileKey, json.encode(profile));
  }

  static Future<Map<String, dynamic>?> getCachedProfile() async {
    final prefs = await SharedPreferences.getInstance();
    String? raw = prefs.getString(_profileKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        return json.decode(raw);
      } catch (_) {}
    }
    return null;
  }
}

