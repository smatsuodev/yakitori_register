import 'product.dart';

class OrderItem {
  final Product product;
  int quantity;
  int subtotal;

  OrderItem({
    required this.product,
    required this.quantity,
  }) : subtotal = product.price * quantity;

  void calculateSubtotal() {
    subtotal = product.price * quantity;
  }
}
