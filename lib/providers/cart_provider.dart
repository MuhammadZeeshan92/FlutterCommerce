import 'package:flutter/material.dart';

import '../models/cart_item_model.dart';
import '../models/product_model.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  // ADD TO CART
  void addToCart(Product product) {
    final existingIndex = _items.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (existingIndex != -1) {
      _items[existingIndex].quantity++;
    } else {
      _items.add(
        CartItem(
          product: product,
          quantity: 1,
        ),
      );
    }

    notifyListeners();
  }

  // REMOVE ITEM
  void removeItem(String productId) {
    _items.removeWhere(
      (item) => item.product.id == productId,
    );

    notifyListeners();
  }

  // INCREASE
  void increaseQuantity(String productId) {
    final item = _items.firstWhere(
      (item) => item.product.id == productId,
    );

    item.quantity++;

    notifyListeners();
  }

  // DECREASE
  void decreaseQuantity(String productId) {
    final item = _items.firstWhere(
      (item) => item.product.id == productId,
    );

    if (item.quantity > 1) {
      item.quantity--;
    } else {
      removeItem(productId);
    }

    notifyListeners();
  }

  // TOTAL PRICE
  double get totalPrice {
    double total = 0;

    for (var item in _items) {
      total += item.product.price * item.quantity;
    }

    return total;
  }

  // TOTAL ITEMS
  int get totalItems {
    int total = 0;

    for (var item in _items) {
      total += item.quantity;
    }

    return total;
  }

  // CLEAR CART
  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}