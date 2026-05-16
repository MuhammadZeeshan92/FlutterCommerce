import 'package:dio/dio.dart';

import 'api_service.dart';

class OrderService {
  static Future<Response> createOrder(
    List<Map<String, dynamic>> items,
  ) async {
    return await ApiService.post(
      "/orders",
      {
        "items": items,
      },
    );
  }
}