import 'package:flutter/material.dart';
import '../core/network/api_client.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoggedIn = false;
  String? _userId;
  String? _email;
  String? _phone;
  String? _fullName;
  List<String> _roles = [];

  String? _lastError;
  String? get lastError => _lastError;

  bool get isLoggedIn => _isLoggedIn;
  String? get userId => _userId;
  String? get email => _email;
  String? get phone => _phone;
  String? get fullName => _fullName;
  bool get isAdmin => _roles.contains("ADMIN");

  Future<bool> login(String emailOrIdentifier, String password) async {
    _lastError = null;
    final res = await ApiClient.post("/auth/login", {
      "email": emailOrIdentifier.trim(),
      "phone": emailOrIdentifier.trim(),
      "password": password
    });

    if (res["success"] == true && res["data"] != null) {
      _isLoggedIn = true;
      _userId = res["data"]["user_id"];
      _email = res["data"]["email"];
      _phone = res["data"]["phone"];
      _fullName = res["data"]["full_name"];
      _roles = List<String>.from(res["data"]["roles"] ?? ["USER"]);
      try {
        await ApiClient.saveTokens(
          res["data"]["access_token"],
          res["data"]["refresh_token"],
        );
      } catch (_) {}
      _lastError = null;
      notifyListeners();
      return true;
    }

    if (res["error"] != null && res["error"] is Map) {
      _lastError = res["error"]["message"]?.toString();
    } else if (res["message"] != null) {
      _lastError = res["message"].toString();
    }
    _lastError ??= "Invalid email address or password.";
    notifyListeners();
    return false;
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    return await ApiClient.post("/auth/forgot-password", {
      "email": email.trim(),
    });
  }

  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String newPassword,
    String? otp,
  }) async {
    return await ApiClient.post("/auth/reset-password", {
      "email": email.trim(),
      "new_password": newPassword.trim(),
      "otp": otp?.trim(),
    });
  }

  Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    required String aadhaarNumber,
    required String phone,
    required String password,
  }) async {
    final res = await ApiClient.post("/auth/register", {
      "full_name": fullName,
      "email": email,
      "aadhaar_number": aadhaarNumber,
      "phone": phone,
      "password": password,
      "role": "USER"
    });
    return res;
  }

  Future<bool> verifyOtp(String phone, String otp) async {
    final res = await ApiClient.post("/auth/verify-otp", {
      "phone": phone,
      "otp": otp,
    });
    return res["success"] == true;
  }

  Future<Map<String, dynamic>> resendOtp(String phone, {String? email}) async {
    final res = await ApiClient.post("/auth/resend-otp", {
      "phone": phone,
      "email": email,
    });
    return res;
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    _userId = null;
    _email = null;
    _phone = null;
    _fullName = null;
    _roles = [];
    await ApiClient.clearSession();
    notifyListeners();
  }
}
