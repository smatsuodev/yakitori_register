import 'package:hive/hive.dart';

import 'product.dart';

part 'order_item.g.dart';

@HiveType(typeId: 2)
class OrderItem {
  @HiveField(0)
  final Product product;

  @HiveField(1)
  int quantity;

  @HiveField(2)
  int subtotal;

  OrderItem({
    required this.product,
    required this.quantity,
  }) : subtotal = product.price * quantity;

  void calculateSubtotal() {
    subtotal = product.price * quantity;
  }

  Map<String, dynamic> toJson() => {
        'product': product.toJson(),
        'quantity': quantity,
        'subtotal': subtotal,
      };

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
        product: Product.fromJson(json['product']),
        quantity: json['quantity'],
      );
}
