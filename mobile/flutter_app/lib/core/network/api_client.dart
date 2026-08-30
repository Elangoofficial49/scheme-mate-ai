import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  // Configured default local server URL
  static String get baseUrl => kIsWeb ? "http://localhost:8000/api/v1" : "http://10.0.2.2:8000/api/v1";
  static String? authToken;

  static Map<String, String> _headers() {
    Map<String, String> headers = {
      "Content-Type": "application/json",
      "Accept": "application/json"
    };
    if (authToken != null) {
      headers["Authorization"] = "Bearer $authToken";
    }
    return headers;
  }

  static Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl$endpoint"),
        headers: _headers(),
      ).timeout(const Duration(seconds: 35));
      return _processResponse(response);
    } catch (e) {
      return {"success": false, "error": {"message": "Network error or server offline: $e"}};
    }
  }

  static Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> body) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl$endpoint"),
        headers: _headers(),
        body: json.encode(body),
      ).timeout(const Duration(seconds: 35));
      return _processResponse(response);
    } catch (e) {
      return {"success": false, "error": {"message": "Network error or server offline: $e"}};
    }
  }

  static Future<Map<String, dynamic>> put(String endpoint, Map<String, dynamic> body) async {
    try {
      final response = await http.put(
        Uri.parse("$baseUrl$endpoint"),
        headers: _headers(),
        body: json.encode(body),
      ).timeout(const Duration(seconds: 35));
      return _processResponse(response);
    } catch (e) {
      return {"success": false, "error": {"message": "Network error or server offline: $e"}};
    }
  }

  static Map<String, dynamic> _processResponse(http.Response response) {
    try {
      final data = json.decode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return data;
      }
      return data is Map<String, dynamic> ? data : {"success": false, "error": {"message": "Error ${response.statusCode}"}};
    } catch (_) {
      return {"success": false, "error": {"message": "Server returned status ${response.statusCode}"}};
    }
  }
}

