import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../domain/model/order_history_item.dart';
import '../../domain/model/order_item.dart';

class OrderHistoryRepository {
  static const String _boxName = 'orders_box';
  final _uuid = const Uuid();
  late Box<OrderHistoryItem> _ordersBox;
  List<OrderHistoryItem> _orders = [];

  // 初期化メソッド
  Future<void> initialize() async {
    _ordersBox = await Hive.openBox<OrderHistoryItem>(_boxName);
    _loadOrders();
  }

  // メモリにデータをロード
  void _loadOrders() {
    _orders = _ordersBox.values.toList();
    // 日付順に並べ替え
    _orders.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

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
    _ordersBox.put(orderId, order);
    return orderId;
  }

  void updateDeliveryStatus(String orderId, String itemId, bool isDelivered) {
    final orderIndex = _orders.indexWhere((order) => order.id == orderId);
    if (orderIndex >= 0) {
      final order = _orders[orderIndex];
      order.deliveredItems[itemId] = isDelivered;
      _ordersBox.put(orderId, order);
    }
  }

  // 注文の削除機能（必要に応じて）
  Future<void> deleteOrder(String orderId) async {
    _orders.removeWhere((order) => order.id == orderId);
    await _ordersBox.delete(orderId);
  }

  // データのクリア（テスト用）
  Future<void> clearAllOrders() async {
    _orders.clear();
    await _ordersBox.clear();
  }
}
