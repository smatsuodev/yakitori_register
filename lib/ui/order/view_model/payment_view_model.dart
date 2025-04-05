import 'package:flutter/foundation.dart';

import '../../../domain/model/order_item.dart';

class PaymentViewModel extends ChangeNotifier {
  final List<OrderItem> orderItems;
  final int totalAmount;
  int _receivedAmount = 0;

  PaymentViewModel({
    required this.orderItems,
    required this.totalAmount,
  });

  int get receivedAmount => _receivedAmount;

  int get changeAmount =>
      _receivedAmount > totalAmount ? _receivedAmount - totalAmount : 0;

  bool get isValidPayment => _receivedAmount >= totalAmount;

  void updateReceivedAmount(int amount) {
    _receivedAmount = amount;
    notifyListeners();
  }
}
