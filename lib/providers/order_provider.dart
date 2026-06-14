import 'package:flutter/material.dart';
import '../core/services/payment_service.dart';
import '../core/services/api_service.dart';

class OrderProvider with ChangeNotifier {
  bool isLoading = false;
  String? paymentUrl;
  String? error;

  Future<void> initiatePayment(String orderId, String method) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final endpoint = _getEndpoint(method);

      print("ORDER ID => $orderId");
      print("METHOD => $method");
      print("ENDPOINT => $endpoint");

      final res = await ApiService.post(endpoint, {"orderId": orderId});

      print("PAYMENT RESPONSE => ${res.data}");

      paymentUrl = res.data["paymentUrl"];
    } catch (e) {
      print("PAYMENT ERROR => $e");

      error = e.toString();
      rethrow;
    }

    isLoading = false;
    notifyListeners();
  }

  String _getEndpoint(String method) {
    switch (method.toLowerCase()) {
      case "jazzcash":
        return "/payment/jazzcash/initiate";
      case "easypaisa":
        return "/payment/easypaisa/initiate";
      default:
        return "/payment/cod";
    }
  }

  Future<Map<String, dynamic>> getOrder(String orderId) async {
    final res = await ApiService.get("/orders/$orderId");
    return res.data;
  }
}
