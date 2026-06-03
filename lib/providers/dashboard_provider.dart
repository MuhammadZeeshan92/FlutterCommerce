import 'package:flutter/material.dart';
import '../core/services/api_service.dart';

class DashboardProvider with ChangeNotifier {
  int totalProducts = 0;
  int totalUsers = 0;
  int totalOrders = 0;

  bool isLoading = false;

  Future<void> fetchStats() async {
    try {
      isLoading = true;
      notifyListeners();

      final response =
          await ApiService.get("/dashboard/stats");

      totalProducts = response.data["totalProducts"];
      totalUsers = response.data["totalUsers"];
      totalOrders = response.data["totalOrders"];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}