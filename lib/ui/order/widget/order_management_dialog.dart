import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/repository/order_history_repository.dart';
import '../../../domain/model/order_history_item.dart';
import '../view_model/order_management_view_model.dart';

class OrderManagementDialog extends StatelessWidget {
  final OrderHistoryRepository _orderHistoryRepository;

  const OrderManagementDialog({
    super.key,
    required OrderHistoryRepository orderHistoryRepository,
  }) : _orderHistoryRepository = orderHistoryRepository;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      insetPadding: const EdgeInsets.all(12),
      child: ChangeNotifierProvider(
        create: (_) => OrderManagementViewModel(
            orderHistoryRepository: _orderHistoryRepository),
        builder: (context, _) {
          return DefaultTabController(
            length: 2,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.5,
              height: MediaQuery.of(context).size.height * 0.85,
              padding: const EdgeInsets.all(0),
              child: Column(
                children: [
                  _buildAppBar(context, '注文管理'),
                  const TabBar(
                    tabs: [
                      Tab(text: '未提供の注文'),
                      Tab(text: 'すべての注文'),
                    ],
                    labelColor: Colors.black87,
                    unselectedLabelColor: Colors.grey,
                    indicatorSize: TabBarIndicatorSize.label,
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildOrderList(context, false),
                        _buildOrderList(context, true),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, String title) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          Expanded(
            child: Center(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildOrderList(BuildContext context, bool showAll) {
    return Consumer<OrderManagementViewModel>(
      builder: (context, viewModel, _) {
        final orders =
            showAll ? viewModel.orders : viewModel.getUndeliveredOrders();

        if (orders.isEmpty) {
          return const Center(
            child: Text('表示する注文がありません', style: TextStyle(fontSize: 18)),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            return _buildOrderCard(context, order, viewModel);
          },
        );
      },
    );
  }

  Widget _buildOrderCard(BuildContext context, OrderHistoryItem order,
      OrderManagementViewModel viewModel) {
    final isCompleted = order.isCompletelyDelivered();
    final statusColor = viewModel.getStatusColor(isCompleted);

    Widget headerContent = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCompleted ? Icons.check_circle : Icons.pending_outlined,
                color: statusColor,
                size: 16,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '注文 #${order.id.substring(0, 4)}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            order.items
                .map((item) => '${item.product.name}×${item.quantity}')
                .join('、'),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade800,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.access_time_filled,
                size: 12,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 4),
              Text(
                viewModel.formatOrderDate(order.timestamp),
                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? Colors.green.shade50
                      : Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isCompleted
                        ? Colors.green.shade200
                        : Colors.orange.shade200,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isCompleted ? Icons.inventory_2 : Icons.inventory,
                      color: statusColor,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${viewModel.getTotalItemQuantity(order)}個',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isCompleted
                            ? Colors.green.shade800
                            : Colors.orange.shade800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );

    Widget itemsListWidget = Container(
      color: Colors.grey.shade50,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isCompleted)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: OutlinedButton.icon(
                onPressed: () =>
                    viewModel.updateAllDeliveryStatus(order.id, true),
                icon: const Icon(Icons.done_all, size: 16),
                label: const Text('すべて提供完了', style: TextStyle(fontSize: 13)),
                style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  side: BorderSide(color: Colors.green.shade400, width: 1.5),
                  foregroundColor: Colors.green.shade700,
                  backgroundColor: Colors.green.shade50,
                ),
              ),
            ),
          ...order.items.map((item) {
            final itemId = '${order.id}_${item.product.id}';
            final isDelivered = order.deliveredItems[itemId] ?? false;

            return InkWell(
              key: ValueKey(itemId),
              onTap: () {
                final newValue = !(order.deliveredItems[itemId] ?? false);
                viewModel.updateDeliveryStatus(order.id, itemId, newValue);
              },
              borderRadius: BorderRadius.circular(6),
              child: Container(
                margin: const EdgeInsets.only(bottom: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 1,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Transform.scale(
                      scale: 0.9,
                      child: Checkbox(
                        value: isDelivered,
                        activeColor: Colors.green.shade600,
                        checkColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(3),
                        ),
                        side: BorderSide(
                          color: isDelivered
                              ? Colors.green.shade300
                              : Colors.orange.shade400,
                          width: isDelivered ? 1.0 : 1.5,
                        ),
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        onChanged: (value) {
                          if (value != null) {
                            viewModel.updateDeliveryStatus(
                                order.id, itemId, value);
                          }
                        },
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          item.product.name,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: isDelivered
                                ? Colors.grey.shade500
                                : Colors.grey.shade900,
                            decoration:
                                isDelivered ? TextDecoration.lineThrough : null,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 3),
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: isDelivered
                            ? Colors.grey.shade100
                            : Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: isDelivered
                              ? Colors.grey.shade300
                              : Colors.blue.shade100,
                        ),
                      ),
                      child: Text(
                        '${item.quantity}個',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isDelivered
                              ? Colors.grey.shade600
                              : Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );

    return Container(
      key: ValueKey('order-${order.id}'),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(
            color: statusColor,
            width: 4,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: EdgeInsets.zero,
        collapsedBackgroundColor: Colors.white,
        backgroundColor: Colors.white,
        initiallyExpanded: false,
        title: headerContent,
        iconColor: Colors.grey.shade700,
        collapsedIconColor: Colors.grey.shade700,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        children: [itemsListWidget],
      ),
    );
  }
}
