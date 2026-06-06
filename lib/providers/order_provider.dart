import 'package:flutter/material.dart';
import '../core/services/payment_service.dart';

class OrderProvider with ChangeNotifier {
  bool isLoading = false;
  String? paymentUrl;
  String? error;

  Future<void> initiatePayment(String orderId) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      paymentUrl = await PaymentService.initiatePayment(orderId);
    } catch (e) {
      error = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }
}