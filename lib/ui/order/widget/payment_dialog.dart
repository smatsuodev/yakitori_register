import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/repository/order_history_repository.dart';
import '../../../domain/model/order_item.dart';
import '../view_model/payment_view_model.dart';

class PaymentDialog extends StatefulWidget {
  final List<OrderItem> orderItems;
  final int totalAmount;
  final OrderHistoryRepository _orderHistoryRepository;

  const PaymentDialog({
    super.key,
    required this.orderItems,
    required this.totalAmount,
    required OrderHistoryRepository orderHistoryRepository,
  }) : _orderHistoryRepository = orderHistoryRepository;

  @override
  State<PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> {
  bool _isCompleted = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: ChangeNotifierProvider(
        create: (_) => PaymentViewModel(
          orderItems: widget.orderItems,
          totalAmount: widget.totalAmount,
          orderHistoryRepository: widget._orderHistoryRepository,
        ),
        builder: (context, _) => ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            child: _isCompleted
                ? _buildCompleteScreen(context)
                : _buildPaymentScreen(context),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentScreen(BuildContext context) {
    final paymentViewModel = Provider.of<PaymentViewModel>(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildAppBar(context, 'お支払い'),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 24.0),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'お支払い金額',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                '¥${widget.totalAmount}',
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'お預かり:',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${paymentViewModel.receivedAmount}円',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'おつり:',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${paymentViewModel.changeAmount}円',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: paymentViewModel.isValidPayment
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: _buildOrderSummary(widget.orderItems),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Expanded(
                        child:
                            _buildCalculatorButtons(context, paymentViewModel),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 75,
                        child: ElevatedButton(
                          onPressed: paymentViewModel.isValidPayment
                              ? () {
                                  paymentViewModel.completeOrder();
                                  setState(() {
                                    _isCompleted = true;
                                  });
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text(
                            '会計する',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOrderSummary(List<OrderItem> orderItems) {
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
                        trailing: Text('${item.subtotal}円'),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalculatorButtons(
    BuildContext context,
    PaymentViewModel viewModel,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            _buildCalcButton(
              child: const Text('¥1,000'),
              onPressed: () {
                viewModel.updateReceivedAmount(viewModel.receivedAmount + 1000);
              },
            ),
            _buildCalcButton(
              child: const Text('¥5,000'),
              onPressed: () {
                viewModel.updateReceivedAmount(viewModel.receivedAmount + 5000);
              },
            ),
            _buildCalcButton(
              child: const Text('¥10,000'),
              onPressed: () {
                viewModel
                    .updateReceivedAmount(viewModel.receivedAmount + 10000);
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildCalcButton(
              child: const Text('7'),
              onPressed: () => _appendDigit(viewModel, 7),
            ),
            _buildCalcButton(
              child: const Text('8'),
              onPressed: () => _appendDigit(viewModel, 8),
            ),
            _buildCalcButton(
              child: const Text('9'),
              onPressed: () => _appendDigit(viewModel, 9),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildCalcButton(
              child: const Text('4'),
              onPressed: () => _appendDigit(viewModel, 4),
            ),
            _buildCalcButton(
              child: const Text('5'),
              onPressed: () => _appendDigit(viewModel, 5),
            ),
            _buildCalcButton(
              child: const Text('6'),
              onPressed: () => _appendDigit(viewModel, 6),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildCalcButton(
              child: const Text('1'),
              onPressed: () => _appendDigit(viewModel, 1),
            ),
            _buildCalcButton(
              child: const Text('2'),
              onPressed: () => _appendDigit(viewModel, 2),
            ),
            _buildCalcButton(
              child: const Text('3'),
              onPressed: () => _appendDigit(viewModel, 3),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildCalcButton(
              child: const Text('0'),
              onPressed: () => _appendDigit(viewModel, 0),
            ),
            _buildCalcButton(
              child: const Text('00'),
              onPressed: () {
                _appendDigit(viewModel, 0);
                _appendDigit(viewModel, 0);
              },
            ),
            _buildCalcButton(
              child: const Icon(Icons.backspace_outlined),
              onPressed: () {
                int currentAmount = viewModel.receivedAmount;
                if (currentAmount >= 10) {
                  viewModel.updateReceivedAmount(currentAmount ~/ 10);
                } else {
                  viewModel.updateReceivedAmount(0);
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCalcButton({
    required VoidCallback onPressed,
    required Widget child,
    Color? backgroundColor,
  }) {
    return Expanded(
      child: SizedBox(
        height: 65,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0),
            ),
            textStyle: const TextStyle(fontSize: 20),
            iconSize: 20,
          ),
          child: child,
        ),
      ),
    );
  }

  void _appendDigit(PaymentViewModel viewModel, int digit) {
    int currentAmount = viewModel.receivedAmount;
    if (currentAmount < 1000000) {
      int newAmount = currentAmount * 10 + digit;
      viewModel.updateReceivedAmount(newAmount);
    }
  }

  Widget _buildCompleteScreen(BuildContext context) {
    final paymentViewModel = Provider.of<PaymentViewModel>(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildAppBar(context, '会計完了'),
        Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    WidgetSpan(
                      alignment: PlaceholderAlignment.bottom,
                      child: const Icon(
                        Icons.check,
                        color: Colors.green,
                        size: 24,
                      ),
                    ),
                    const WidgetSpan(
                      child: SizedBox(width: 8),
                    ),
                    const TextSpan(
                      text: '会計が完了しました',
                      style: TextStyle(fontSize: 24, color: Colors.green),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'おつり',
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 8),
              Text(
                '¥${paymentViewModel.changeAmount}',
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'お預かり ¥${paymentViewModel.receivedAmount}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 12),
                  const Text('−', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 12),
                  Text(
                    '合計金額 ¥${widget.totalAmount}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: 200,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                  child: const Text('注文画面に戻る', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ],
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          if (!_isCompleted)
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            )
          else
            const SizedBox(width: 48),
          Expanded(
            child: Center(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
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
}
