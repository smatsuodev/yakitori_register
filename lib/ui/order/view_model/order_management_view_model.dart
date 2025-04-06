import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../data/repository/order_history_repository.dart';
import '../../../domain/model/order_history_item.dart';

class OrderManagementViewModel extends ChangeNotifier {
  late final OrderHistoryRepository _orderHistoryRepository;
  final DateFormat _dateFormat = DateFormat('MM/dd HH:mm');

  OrderManagementViewModel({
    required OrderHistoryRepository orderHistoryRepository,
  }) : _orderHistoryRepository = orderHistoryRepository;

  List<OrderHistoryItem> get orders => _orderHistoryRepository.getOrders();

  void updateDeliveryStatus(String orderId, String itemId, bool isDelivered) {
    _orderHistoryRepository.updateDeliveryStatus(orderId, itemId, isDelivered);
    notifyListeners();
  }

  void updateAllDeliveryStatus(String orderId, bool status) {
    final orderIndex = _orderHistoryRepository
        .getOrders()
        .indexWhere((order) => order.id == orderId);
    if (orderIndex >= 0) {
      final order = _orderHistoryRepository.getOrders()[orderIndex];
      for (final item in order.items) {
        final itemId = '${orderId}_${item.product.id}';
        _orderHistoryRepository.updateDeliveryStatus(orderId, itemId, status);
      }
      notifyListeners();
    }
  }

  List<OrderHistoryItem> getUndeliveredOrders() {
    return orders.where((order) => !order.isCompletelyDelivered()).toList();
  }

  String formatOrderDate(DateTime timestamp) {
    return _dateFormat.format(timestamp);
  }

  Color getStatusColor(bool isCompleted) {
    return isCompleted ? Colors.green : Colors.orange;
  }

  int getTotalItemQuantity(OrderHistoryItem order) {
    return order.items.fold(0, (sum, item) => sum + item.quantity);
  }
}
