import 'package:flutter/material.dart';
import '../core/network/api_client.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoggedIn = false;
  String? _userId;
  String? _email;
  String? _phone;
  String? _fullName;
  List<String> _roles = [];

  bool get isLoggedIn => _isLoggedIn;
  String? get userId => _userId;
  String? get email => _email;
  String? get phone => _phone;
  String? get fullName => _fullName;
  bool get isAdmin => _roles.contains("ADMIN");

  Future<bool> login(String emailOrIdentifier, String password) async {
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
      ApiClient.authToken = res["data"]["access_token"];
      notifyListeners();
      return true;
    }
    return false;
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

  void logout() {
    _isLoggedIn = false;
    _userId = null;
    _email = null;
    _phone = null;
    _fullName = null;
    _roles = [];
    ApiClient.authToken = null;
    notifyListeners();
  }
}

