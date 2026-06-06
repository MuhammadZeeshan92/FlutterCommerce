import 'package:flutter/material.dart';
import 'product_provider.dart';

class AppDataProvider with ChangeNotifier {
  final ProductProvider productProvider;

  AppDataProvider(this.productProvider);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> initAppData() async {
    _isLoading = true;
    notifyListeners();

    await productProvider.fetchProducts();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refreshProducts() async {
    await productProvider.fetchProducts();
    notifyListeners();
  }
}