class CartItem {
  final String product_name;
  final String rate;
  final String imageUrl;
  int quantity;
  String? product_id;
  double? product_gst;
  String? measurement;




  CartItem({
    required this.product_name,
    required this.rate,
    required this.imageUrl,
    this.quantity = 1,
    this.product_id,
    this.product_gst,
    this.measurement,

  });

  // Convert to Map for saving
  Map<String, dynamic> toMap() {
    return {
      'product_name': product_name,
      'rate': rate,
      'imageUrl': imageUrl,
      'quantity': quantity,
      'product_id': product_id,
      'product_gst': product_gst,
      'measurement': measurement,

    };
  }

  // Convert from Map when loading
  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      product_name: map['product_name'],
      rate: map['rate'],
      imageUrl: map['imageUrl'],
      quantity: map['quantity'],
      product_id: map['product_id'],
      product_gst: map['product_gst'],
      measurement: map['measurement'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['quantity'] = quantity;
    data['rate'] = rate;
    data['product_name'] = product_name;
    data['imageUrl'] = imageUrl;
    data['product_id'] = product_id;
    data['product_gst'] = product_gst;
    data['measurement'] = measurement;
    return data;
  }
}
