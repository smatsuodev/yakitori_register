import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/repository/product_repository.dart';
import '../view_model/order_view_model.dart';
import 'order_summary_widget.dart';
import 'product_selection_widget.dart';

class OrderScreen extends StatelessWidget {
  final ProductRepository productRepository;

  OrderScreen({super.key, ProductRepository? productRepository})
      : productRepository = productRepository ?? ProductRepository();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OrderViewModel(),
      child: Builder(
        builder: (context) {
          final orderViewModel = Provider.of<OrderViewModel>(context);
          final products = productRepository.getProducts();

          return Scaffold(
            appBar: AppBar(title: const Text('注文入力')),
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
              onPressed: () {
                if (!orderViewModel.hasItems) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(
                    content: Text('商品を選択してください'),
                    showCloseIcon: true,
                  ));
                  return;
                }
                // TODO: 支払い画面へ遷移
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(
                  content: Text('支払い画面へ遷移します'),
                  showCloseIcon: true,
                ));
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
