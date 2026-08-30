import 'package:flutter/material.dart';
import '../core/network/api_client.dart';
import '../core/offline_db/offline_cache.dart';
import '../models/match_result_model.dart';
import '../models/scheme_model.dart';

class SchemeProvider with ChangeNotifier {
  bool _isLoading = false;
  List<MatchResultModel> _recommendations = [];
  List<SchemeModel> _allSchemes = [];
  bool _isOffline = false;

  // Gemini AI state
  bool _isLoadingGemini = false;
  String? _geminiSummary;
  String? _geminiProvider;
  List<Map<String, dynamic>> _geminiSuggestions = [];

  bool get isLoading => _isLoading;
  List<MatchResultModel> get recommendations => _recommendations;
  List<SchemeModel> get allSchemes => _allSchemes;
  bool get isOffline => _isOffline;

  bool get isLoadingGemini => _isLoadingGemini;
  String? get geminiSummary => _geminiSummary;
  String? get geminiProvider => _geminiProvider;
  List<Map<String, dynamic>> get geminiSuggestions => _geminiSuggestions;

  Future<void> fetchRecommendations() async {
    _isLoading = true;
    notifyListeners();

    final res = await ApiClient.post("/matching/analyze", {});

    if (res["success"] == true && res["data"] != null) {
      _isOffline = false;
      List<dynamic> list = res["data"];
      _recommendations = list.map((item) => MatchResultModel.fromJson(item)).toList();
      await OfflineCache.cacheSchemes(list);
    } else {
      // Fallback to local offline cache
      _isOffline = true;
      List<dynamic> cached = await OfflineCache.getCachedSchemes();
      if (cached.isNotEmpty) {
        _recommendations = cached.map((item) => MatchResultModel.fromJson(item)).toList();
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchGeminiSuggestions({String? query, Map<String, dynamic>? customProfile}) async {
    _isLoadingGemini = true;
    notifyListeners();

    final res = await ApiClient.post("/matching/gemini-suggestions", {
      if (query != null && query.isNotEmpty) "query": query,
      if (customProfile != null) "custom_profile": customProfile,
    });

    if (res["success"] == true && res["data"] != null) {
      List<dynamic> rawList = res["data"];
      _geminiSuggestions = rawList.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      _geminiSummary = res["ai_analysis_summary"]?.toString();
      _geminiProvider = res["provider"]?.toString();
    }

    _isLoadingGemini = false;
    notifyListeners();
  }

  Future<void> fetchAllSchemes() async {
    final res = await ApiClient.get("/schemes");
    if (res["success"] == true && res["data"] != null) {
      List<dynamic> list = res["data"];
      _allSchemes = list.map((item) => SchemeModel.fromJson(item)).toList();
      notifyListeners();
    }
  }
}

