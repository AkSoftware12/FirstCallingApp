import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../CartModel/cart_model.dart';

class CartProvider with ChangeNotifier {
  List<CartItem> _items = [];

  List<CartItem> get items => _items;

  CartProvider() {
    loadCart(); // Jab provider create hoga, saved cart load hoga
  }

  // Save cart in local storage
  Future<void> saveCart() async {
    final prefs = await SharedPreferences.getInstance();
    final data = _items.map((item) => item.toMap()).toList();
    prefs.setString('cart', jsonEncode(data));
  }

  // Load cart from local storage
  Future<void> loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final savedData = prefs.getString('cart');
    if (savedData != null) {
      final List decoded = jsonDecode(savedData);
      _items = decoded.map((e) => CartItem.fromMap(e)).toList();
      notifyListeners();
    }
  }

  // Clear all items from the cart
  void clearCart() {
    _items.clear();
    saveCart();
    notifyListeners();

  }

  void addItem(CartItem item) {
    final index = _items.indexWhere((e) => e.product_name == item.product_name);
    if (index >= 0) {
      _items[index].quantity++;
    } else {
      _items.add(item);
    }
    saveCart();
    notifyListeners();
  }

  void increaseQty(CartItem item) {
    final index = _items.indexWhere((e) => e.product_name == item.product_name);
    if (index >= 0) {
      _items[index].quantity++;
      saveCart();
      notifyListeners();
    }
  }

  void decreaseQty(CartItem item) {
    final index = _items.indexWhere((e) => e.product_name == item.product_name);
    if (index >= 0) {
      if (_items[index].quantity > 1) {
        _items[index].quantity--;
      } else {
        _items.removeAt(index);
      }
      saveCart();
      notifyListeners();
    }
  }
  double get totalPrice {
    return _items.fold(
        0, (sum, item) => sum + (int.parse(item.rate.toString()) * item.quantity));
  }
  int getQuantity(String title) {
    final index = _items.indexWhere((e) => e.product_name == title);
    if (index >= 0) {
      return _items[index].quantity;
    }
    return 0;
  }
}
