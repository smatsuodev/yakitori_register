import 'package:flutter/material.dart';

import '../../../domain/model/order_item.dart';

class OrderSummaryWidget extends StatelessWidget {
  final List<OrderItem> orderItems;
  final int totalAmount;
  final Function(String) onRemoveItem;

  const OrderSummaryWidget({
    super.key,
    required this.orderItems,
    required this.totalAmount,
    required this.onRemoveItem,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[100],
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              '注文内容',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: orderItems.isEmpty
                ? const Center(child: Text('商品を選択してください'))
                : ListView.builder(
                    itemCount: orderItems.length,
                    itemBuilder: (context, index) {
                      final item = orderItems[index];
                      return ListTile(
                        title: Text(item.product.name),
                        subtitle: Text(
                          '${item.product.price}円 × ${item.quantity}個',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('${item.subtotal}円'),
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: () => onRemoveItem(item.product.id),
                              tooltip: '1つ削除',
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[300],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '合計',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '$totalAmount円',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
