import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Model/model.dart';

class CartProvider extends ChangeNotifier {
  List<CartItem> cart = [];
  List<Order> orders = [];

  CartProvider() {
    loadData();
  }

  Future<void> addToCart(Product product) async {
    final index =
    cart.indexWhere((item) => item.product.name == product.name);
    if (index >= 0) {
      cart[index].quantity++;
    } else {
      cart.add(CartItem(product: product));
    }
    await saveData();
    notifyListeners();
  }

  Future<void> removeFromCart(CartItem item) async {
    cart.remove(item);
    await saveData();
    notifyListeners();
  }

  Future<void> increaseQty(CartItem item) async {
    item.quantity++;
    await saveData();
    notifyListeners();
  }

  Future<void> decreaseQty(CartItem item) async {
    if (item.quantity > 1) {
      item.quantity--;
    } else {
      cart.remove(item);
    }
    await saveData();
    notifyListeners();
  }

  Future<void> clearCart() async {
    cart.clear();
    await saveData();
    notifyListeners();
  }

  double get total =>
      cart.fold(0, (sum, item) => sum + (item.product.price * item.quantity));

  /// ✅ Place Order
  Future<void> placeOrder() async {
    if (cart.isEmpty) return;

    orders.add(Order(items: List.from(cart), total: total, date: DateTime.now()));
    cart.clear();

    await saveData();
    notifyListeners();
  }

  /// ✅ Clear all Orders
  Future<void> clearOrders() async {
    orders.clear();
    await saveData();
    notifyListeners();
  }

  /// ✅ Save to SharedPreferences
  Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();

    // cart
    List<String> cartJson =
    cart.map((item) => jsonEncode(item.toJson())).toList();
    await prefs.setStringList("cart", cartJson);

    // orders
    List<String> ordersJson =
    orders.map((order) => jsonEncode(order.toJson())).toList();
    await prefs.setStringList("orders", ordersJson);
  }

  /// ✅ Load from SharedPreferences
  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();

    // cart
    List<String>? cartJson = prefs.getStringList("cart");
    if (cartJson != null) {
      cart = cartJson
          .map((item) => CartItem.fromJson(jsonDecode(item)))
          .toList();
    }

    // orders
    List<String>? ordersJson = prefs.getStringList("orders");
    if (ordersJson != null) {
      orders = ordersJson
          .map((item) => Order.fromJson(jsonDecode(item)))
          .toList();
    }

    notifyListeners();
  }
}
