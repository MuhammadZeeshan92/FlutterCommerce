import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/api_constants.dart';

class ApiService {
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,

      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),

      headers: {"Content-Type": "application/json"},
    ),
  );

  // INITIALIZE INTERCEPTOR
  static void setupInterceptor() {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();

          final token = prefs.getString("token");

          if (token != null) {
            options.headers["Authorization"] = "Bearer $token";
          }

          handler.next(options);
        },
      ),
    );
  }

  static Future<Response> get(String endpoint) async {
    return await dio.get(endpoint);
  }

  static Future<Response> post(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    return await dio.post(endpoint, data: data);
  }

  static Future<Response> put(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    return await dio.put(endpoint, data: data);
  }

  static Future<Response> delete(String endpoint) async {
    return await dio.delete(endpoint);
  }
}
