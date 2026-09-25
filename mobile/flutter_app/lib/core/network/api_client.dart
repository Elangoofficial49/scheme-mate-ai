import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  static const _storage = FlutterSecureStorage();
  static const _configuredBaseUrl = String.fromEnvironment('API_BASE_URL');
  static String get baseUrl => _configuredBaseUrl.isNotEmpty
      ? _configuredBaseUrl
      : (kIsWeb
          ? "http://localhost:8000/api/v1"
          : "http://10.0.2.2:8000/api/v1");
  static String? authToken;
  static String? refreshToken;

  static Future<void> restoreSession() async {
    try {
      authToken = await _storage.read(key: 'access_token');
      refreshToken = await _storage.read(key: 'refresh_token');
    } catch (_) {}
  }

  static Future<void> _saveTokens(String access, String refresh) async {
    authToken = access;
    refreshToken = refresh;
    try {
      await _storage.write(key: 'access_token', value: access);
      await _storage.write(key: 'refresh_token', value: refresh);
    } catch (_) {}
  }

  static Future<void> saveTokens(String access, String refresh) async {
    await _saveTokens(access, refresh);
  }

  static Future<void> clearSession() async {
    authToken = null;
    refreshToken = null;
    try {
      await _storage.delete(key: 'access_token');
      await _storage.delete(key: 'refresh_token');
    } catch (_) {}
  }

  static Future<bool> refreshSession() async {
    if (refreshToken == null) return false;
    try {
      final response = await http
          .post(
            Uri.parse("$baseUrl/auth/refresh"),
            headers: {
              "Content-Type": "application/json",
              "Accept": "application/json"
            },
            body: json.encode({"refresh_token": refreshToken}),
          )
          .timeout(const Duration(seconds: 15));
      final data = _processResponse(response);
      if (data["success"] == true && data["data"] != null) {
        await _saveTokens(
            data["data"]["access_token"], data["data"]["refresh_token"]);
        return true;
      }
    } catch (_) {
      return false;
    }
    return false;
  }

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
      final response = await http
          .get(
            Uri.parse("$baseUrl$endpoint"),
            headers: _headers(),
          )
          .timeout(const Duration(seconds: 35));
      return _processResponse(response);
    } catch (e) {
      if (kIsWeb && baseUrl.contains("localhost")) {
        try {
          final fallbackUrl = baseUrl.replaceAll("localhost", "127.0.0.1");
          final response = await http
              .get(
                Uri.parse("$fallbackUrl$endpoint"),
                headers: _headers(),
              )
              .timeout(const Duration(seconds: 35));
          return _processResponse(response);
        } catch (_) {}
      }
      return {
        "success": false,
        "error": {"message": "Network error or server offline: $e"}
      };
    }
  }

  static Future<Map<String, dynamic>> post(
      String endpoint, Map<String, dynamic> body) async {
    try {
      final response = await http
          .post(
            Uri.parse("$baseUrl$endpoint"),
            headers: _headers(),
            body: json.encode(body),
          )
          .timeout(const Duration(seconds: 35));
      return _processResponse(response);
    } catch (e) {
      if (kIsWeb && baseUrl.contains("localhost")) {
        try {
          final fallbackUrl = baseUrl.replaceAll("localhost", "127.0.0.1");
          final response = await http
              .post(
                Uri.parse("$fallbackUrl$endpoint"),
                headers: _headers(),
                body: json.encode(body),
              )
              .timeout(const Duration(seconds: 35));
          return _processResponse(response);
        } catch (_) {}
      }
      return {
        "success": false,
        "error": {"message": "Network error or server offline: $e"}
      };
    }
  }

  static Future<Map<String, dynamic>> put(
      String endpoint, Map<String, dynamic> body) async {
    try {
      final response = await http
          .put(
            Uri.parse("$baseUrl$endpoint"),
            headers: _headers(),
            body: json.encode(body),
          )
          .timeout(const Duration(seconds: 35));
      return _processResponse(response);
    } catch (e) {
      if (kIsWeb && baseUrl.contains("localhost")) {
        try {
          final fallbackUrl = baseUrl.replaceAll("localhost", "127.0.0.1");
          final response = await http
              .put(
                Uri.parse("$fallbackUrl$endpoint"),
                headers: _headers(),
                body: json.encode(body),
              )
              .timeout(const Duration(seconds: 35));
          return _processResponse(response);
        } catch (_) {}
      }
      return {
        "success": false,
        "error": {"message": "Network error or server offline: $e"}
      };
    }
  }

  static Future<Map<String, dynamic>> uploadDocument(
      List<int> bytes, String fileName, String documentType) async {
    try {
      final uri = Uri.parse("$baseUrl/documents/upload");
      var request = http.MultipartRequest('POST', uri);

      if (authToken != null) {
        request.headers['Authorization'] = 'Bearer $authToken';
      }

      request.fields['document_type'] = documentType;
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: fileName,
        ),
      );

      var streamedResponse =
          await request.send().timeout(const Duration(seconds: 45));
      var response = await http.Response.fromStream(streamedResponse);
      return _processResponse(response);
    } catch (e) {
      return {
        "success": false,
        "error": {"message": "Upload error: $e"}
      };
    }
  }

  static Map<String, dynamic> _processResponse(http.Response response) {
    try {
      final decoded = json.decode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
        return {"success": true, "data": decoded};
      }

      String? extractedMsg;
      if (decoded is Map<String, dynamic>) {
        if (decoded["detail"] is Map) {
          extractedMsg = decoded["detail"]["message"]?.toString() ?? decoded["detail"]["code"]?.toString();
        } else if (decoded["detail"] != null) {
          extractedMsg = decoded["detail"].toString();
        } else if (decoded["error"] is Map) {
          extractedMsg = decoded["error"]["message"]?.toString();
        } else if (decoded["message"] != null) {
          extractedMsg = decoded["message"].toString();
        }
        return {
          "success": false,
          "error": {"message": extractedMsg ?? "Error ${response.statusCode}"},
          ...decoded,
        };
      }
      return {
        "success": false,
        "error": {"message": "Error ${response.statusCode}"}
      };
    } catch (_) {
      return {
        "success": false,
        "error": {"message": "Server returned status ${response.statusCode}"}
      };
    }
  }
}
