import 'package:flutter/foundation.dart';

import '../../../domain/model/order_item.dart';
import '../../../domain/model/product.dart';

class OrderViewModel extends ChangeNotifier {
  final List<OrderItem> _orderItems = [];
  int _totalAmount = 0;

  List<OrderItem> get orderItems => _orderItems;

  int get totalAmount => _totalAmount;

  bool get hasItems => _orderItems.isNotEmpty;

  void addProduct(Product product) {
    // 既存の商品かチェック
    final existingItemIndex = _orderItems.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (existingItemIndex >= 0) {
      // 既存商品の場合は個数を増やす
      _orderItems[existingItemIndex].quantity++;
      _orderItems[existingItemIndex].calculateSubtotal();
    } else {
      // 新規商品の場合はリストに追加
      _orderItems.add(OrderItem(product: product, quantity: 1));
    }

    // 合計金額再計算
    _calculateTotal();
    notifyListeners();
  }

  void removeProduct(String productId) {
    // 該当商品のインデックスを取得
    final existingItemIndex = _orderItems.indexWhere(
      (item) => item.product.id == productId,
    );

    // 商品が見つからない場合は何もしない
    if (existingItemIndex < 0) return;

    // 数量が1より多い場合は数量を減らす
    if (_orderItems[existingItemIndex].quantity > 1) {
      _orderItems[existingItemIndex].quantity--;
      _orderItems[existingItemIndex].calculateSubtotal();
    } else {
      // 数量が1の場合はリストから削除
      _orderItems.removeAt(existingItemIndex);
    }

    // 合計金額再計算
    _calculateTotal();
    notifyListeners();
  }

  void _calculateTotal() {
    _totalAmount = _orderItems.fold(0, (sum, item) => sum + item.subtotal);
  }
}
