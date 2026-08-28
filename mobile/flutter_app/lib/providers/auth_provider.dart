import 'package:flutter/material.dart';
import '../core/network/api_client.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoggedIn = false;
  String? _userId;
  String? _phone;
  String? _fullName;
  List<String> _roles = [];

  bool get isLoggedIn => _isLoggedIn;
  String? get userId => _userId;
  String? get phone => _phone;
  String? get fullName => _fullName;
  bool get isAdmin => _roles.contains("ADMIN");

  Future<bool> login(String phone, String password) async {
    final res = await ApiClient.post("/auth/login", {
      "phone": phone,
      "password": password
    });

    if (res["success"] == true && res["data"] != null) {
      _isLoggedIn = true;
      _userId = res["data"]["user_id"];
      _phone = res["data"]["phone"];
      _fullName = res["data"]["full_name"];
      _roles = List<String>.from(res["data"]["roles"] ?? ["USER"]);
      ApiClient.authToken = res["data"]["access_token"];
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> register(String phone, String password, String name) async {
    final res = await ApiClient.post("/auth/register", {
      "phone": phone,
      "password": password,
      "full_name": name,
      "role": "USER"
    });

    if (res["success"] == true && res["data"] != null) {
      _isLoggedIn = true;
      _userId = res["data"]["user_id"];
      _phone = res["data"]["phone"];
      _fullName = name;
      _roles = List<String>.from(res["data"]["roles"] ?? ["USER"]);
      ApiClient.authToken = res["data"]["access_token"];
      notifyListeners();
      return true;
    }
    return false;
  }

  void logout() {
    _isLoggedIn = false;
    _userId = null;
    _phone = null;
    _fullName = null;
    _roles = [];
    ApiClient.authToken = null;
    notifyListeners();
  }
}

