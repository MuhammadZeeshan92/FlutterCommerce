import 'package:dio/dio.dart';

import 'api_service.dart';

class OrderService {
  static Future<Response> createOrder(
    Map<String, dynamic> data,
  ) async {
    return await ApiService.post(
      "/orders",
      data,
    );
  }
}