import 'package:flutter/material.dart';

import '../core/services/api_service.dart';
import '../models/product_model.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _products = [];
  bool _isLoading = false;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;

  Future<void> fetchProducts() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.get('/products');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        _products = data.map((item) => Product.fromJson(item)).toList();
      }
    } catch (e) {
      // Handle error
      print('Error fetching products: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}