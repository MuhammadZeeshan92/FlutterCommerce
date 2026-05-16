import 'package:dio/dio.dart';

import 'api_service.dart';

class AuthService {
  static Future<Response> register({
    required String name,
    required String email,
    required String password,
  }) async {
    return await ApiService.post(
      "/auth/register",
      {
        "name": name,
        "email": email,
        "password": password,
      },
    );
  }

  static Future<Response> login({
    required String email,
    required String password,
  }) async {
    return await ApiService.post(
      "/auth/login",
      {
        "email": email,
        "password": password,
      },
    );
  }
}