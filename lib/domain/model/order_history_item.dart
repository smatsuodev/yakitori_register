import 'order_item.dart';

class OrderHistoryItem {
  final String id;
  final DateTime timestamp;
  final List<OrderItem> items;
  final int totalAmount;
  final Map<String, bool> deliveredItems;

  OrderHistoryItem({
    required this.id,
    required this.timestamp,
    required this.items,
    required this.totalAmount,
    Map<String, bool>? deliveredItems,
  }) : deliveredItems = deliveredItems ?? {};

  bool isCompletelyDelivered() {
    if (deliveredItems.isEmpty) return false;
    return !deliveredItems.values.contains(false);
  }
}
