import 'package:uuid/uuid.dart';

import '../../domain/model/order_history_item.dart';
import '../../domain/model/order_item.dart';

class OrderHistoryRepository {
  final List<OrderHistoryItem> _orders = [];
  final _uuid = const Uuid();

  List<OrderHistoryItem> getOrders() => List.unmodifiable(_orders);

  String addOrder(List<OrderItem> items, int totalAmount) {
    final orderId = _uuid.v4();
    final deliveredItems = <String, bool>{};

    for (final item in items) {
      final itemId = '${orderId}_${item.product.id}';
      deliveredItems[itemId] = false;
    }

    final order = OrderHistoryItem(
      id: orderId,
      timestamp: DateTime.now(),
      items: List.of(items),
      totalAmount: totalAmount,
      deliveredItems: deliveredItems,
    );

    _orders.add(order);
    return orderId;
  }

  void updateDeliveryStatus(String orderId, String itemId, bool isDelivered) {
    final orderIndex = _orders.indexWhere((order) => order.id == orderId);
    if (orderIndex >= 0) {
      final order = _orders[orderIndex];
      order.deliveredItems[itemId] = isDelivered;
    }
  }
}
