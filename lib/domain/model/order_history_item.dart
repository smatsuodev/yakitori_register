import 'package:hive/hive.dart';

import 'order_item.dart';

part 'order_history_item.g.dart';

@HiveType(typeId: 3)
class OrderHistoryItem {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime timestamp;

  @HiveField(2)
  final List<OrderItem> items;

  @HiveField(3)
  final int totalAmount;

  @HiveField(4)
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

  Map<String, dynamic> toJson() => {
        'id': id,
        'timestamp': timestamp.toIso8601String(),
        'items': items.map((item) => item.toJson()).toList(),
        'totalAmount': totalAmount,
        'deliveredItems': deliveredItems,
      };

  factory OrderHistoryItem.fromJson(Map<String, dynamic> json) =>
      OrderHistoryItem(
        id: json['id'],
        timestamp: DateTime.parse(json['timestamp']),
        items: (json['items'] as List)
            .map((item) => OrderItem.fromJson(item))
            .toList(),
        totalAmount: json['totalAmount'],
        deliveredItems: Map<String, bool>.from(json['deliveredItems']),
      );
}
