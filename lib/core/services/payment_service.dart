import 'api_service.dart';

class PaymentService {
  static Future<String> initiatePayment(String orderId) async {
    final response = await ApiService.post(
      "/payment/initiate",
      {"orderId": orderId},
    );

    return response.data["paymentUrl"];
  }
}