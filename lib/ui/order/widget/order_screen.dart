import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yakitori_register/data/repository/order_history_repository.dart';

import '../../../data/repository/product_repository.dart';
import '../view_model/order_view_model.dart';
import 'order_management_dialog.dart';
import 'order_summary_widget.dart';
import 'payment_dialog.dart';
import 'product_selection_widget.dart';

class OrderScreen extends StatelessWidget {
  final ProductRepository _productRepository;
  final OrderHistoryRepository _orderHistoryRepository;

  const OrderScreen({
    super.key,
    required ProductRepository productRepository,
    required OrderHistoryRepository orderHistoryRepository,
  })  : _productRepository = productRepository,
        _orderHistoryRepository = orderHistoryRepository;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OrderViewModel(),
      child: Builder(
        builder: (context) {
          final orderViewModel = Provider.of<OrderViewModel>(context);
          final products = _productRepository.getProducts();

          return Scaffold(
            appBar: AppBar(
              title: const Text('注文入力'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.receipt_long),
                  tooltip: '注文管理',
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => OrderManagementDialog(
                        orderHistoryRepository: _orderHistoryRepository,
                      ),
                    );
                  },
                ),
              ],
            ),
            body: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: OrderSummaryWidget(
                    orderItems: orderViewModel.orderItems,
                    totalAmount: orderViewModel.totalAmount,
                    onRemoveItem: orderViewModel.removeProduct,
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: ProductSelectionWidget(
                    products: products,
                    onProductSelected: orderViewModel.addProduct,
                  ),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () async {
                if (!orderViewModel.hasItems) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('商品を選択してください'),
                    showCloseIcon: true,
                  ));
                  return;
                }

                final result = await showDialog<bool>(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => PaymentDialog(
                    orderItems: orderViewModel.orderItems,
                    totalAmount: orderViewModel.totalAmount,
                    orderHistoryRepository: _orderHistoryRepository,
                  ),
                );

                if (result == true) {
                  orderViewModel.clearCart();
                }
              },
              label: const Text('支払いへ進む'),
              icon: const Icon(Icons.payment),
            ),
          );
        },
      ),
    );
  }
}
