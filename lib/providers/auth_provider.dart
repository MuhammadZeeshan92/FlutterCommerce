import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  String? token;
  String? role;

  bool get isLoggedIn => token != null;

  Future<void> saveToken(String newToken, {String? userRole}) async {
    token = newToken;
    role = userRole;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("token", newToken);

    if (userRole != null) {
      await prefs.setString("role", userRole);
    }

    notifyListeners();
  }

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();

    token = prefs.getString("token");
    role = prefs.getString("role");

    notifyListeners();
  }

  Future<void> logout() async {
    token = null;
    role = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    notifyListeners();
  }
}