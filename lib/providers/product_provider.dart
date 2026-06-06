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

      // 1. Optimistic UI update (REMOVE instantly)
      _products.removeWhere((p) => p.id == productId);
      notifyListeners();

      // 2. API call
      await ApiService.delete("/products/$productId");
    } catch (e) {
      // rollback by refetch
      await fetchProducts();
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

      await ApiService.put("/products/$productId", updatedData);

      await fetchProducts();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateFromResponse(dynamic updatedProductJson) {
    final updated = Product.fromJson(updatedProductJson);

    final index = _products.indexWhere((p) => p.id == updated.id);

    if (index != -1) {
      _products[index] = updated;
      notifyListeners();
    }
  }
}
