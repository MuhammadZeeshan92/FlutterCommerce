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
        final List<dynamic> data = response.data["products"];

        _products = data.map((e) => Product.fromJson(e)).toList();
      }
    } catch (e) {
      print("Error fetching products: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      _isLoading = true;
      notifyListeners();

      // await ApiService.delete("/products/$productId");

      await fetchProducts();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProduct(
    String productId,
    Map<String, dynamic> updatedData,
  ) async {
    try {
      _isLoading = true;
      notifyListeners();

      // await ApiService.put("/products/$productId", updatedData);

      await fetchProducts();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
