class CartItem {
  final String title;
  final String price;
  final String imageUrl;
  int quantity;

  CartItem({
    required this.title,
    required this.price,
    required this.imageUrl,
    this.quantity = 1,
  });

  // Convert to Map for saving
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'price': price,
      'imageUrl': imageUrl,
      'quantity': quantity,
    };
  }

  // Convert from Map when loading
  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      title: map['title'],
      price: map['price'],
      imageUrl: map['imageUrl'],
      quantity: map['quantity'],
    );
  }
}
