import 'dart:convert';

class Product {
  final String name;
  final double price;

  const Product({required this.name, required this.price});

  Map<String, dynamic> toJson() => {
    "name": name,
    "price": price,
  };

  factory Product.fromJson(Map<String, dynamic> json) =>
      Product(name: json["name"], price: json["price"]);
}

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  Map<String, dynamic> toJson() => {
    "product": product.toJson(),
    "quantity": quantity,
  };

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
    product: Product.fromJson(json["product"]),
    quantity: json["quantity"],
  );
}

class Order {
  final List<CartItem> items;
  final double total;
  final DateTime date;

  Order({required this.items, required this.total, required this.date});

  Map<String, dynamic> toJson() => {
    "items": items.map((e) => e.toJson()).toList(),
    "total": total,
    "date": date.toIso8601String(),
  };

  factory Order.fromJson(Map<String, dynamic> json) => Order(
    items: (json["items"] as List)
        .map((e) => CartItem.fromJson(e))
        .toList(),
    total: json["total"],
    date: DateTime.parse(json["date"]),
  );
}
