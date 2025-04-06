import 'package:flutter/foundation.dart';

import '../../../data/repository/order_history_repository.dart';
import '../../../domain/model/order_item.dart';

class PaymentViewModel extends ChangeNotifier {
  final OrderHistoryRepository _orderHistoryRepository;
  final List<OrderItem> orderItems;
  final int totalAmount;
  int _receivedAmount = 0;

  PaymentViewModel({
    required this.orderItems,
    required this.totalAmount,
    required OrderHistoryRepository orderHistoryRepository,
  }) : _orderHistoryRepository = orderHistoryRepository;

  int get receivedAmount => _receivedAmount;

  int get changeAmount =>
      _receivedAmount > totalAmount ? _receivedAmount - totalAmount : 0;

  bool get isValidPayment => _receivedAmount >= totalAmount;

  void updateReceivedAmount(int amount) {
    _receivedAmount = amount;
    notifyListeners();
  }

  // 注文完了処理を追加
  void completeOrder() {
    if (!isValidPayment) return;

    // 注文履歴に追加
    _orderHistoryRepository.addOrder(orderItems, totalAmount);
  }
}
