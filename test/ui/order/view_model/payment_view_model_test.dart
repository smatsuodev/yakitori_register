import 'package:flutter_test/flutter_test.dart';
import 'package:yakitori_register/data/repository/order_history_repository.dart';
import 'package:yakitori_register/domain/model/order_item.dart';
import 'package:yakitori_register/domain/model/product.dart';
import 'package:yakitori_register/ui/order/view_model/payment_view_model.dart';

void main() {
  late PaymentViewModel paymentViewModel;
  late List<OrderItem> testOrderItems;
  final testTotalAmount = 500;

  setUp(() {
    final product1 = Product(id: '1', name: 'もも 甘口', price: 300);
    final product2 = Product(id: '2', name: 'むね 中辛', price: 200);

    testOrderItems = [
      OrderItem(product: product1, quantity: 1),
      OrderItem(product: product2, quantity: 1),
    ];

    paymentViewModel = PaymentViewModel(
      orderItems: testOrderItems,
      totalAmount: testTotalAmount,
      orderHistoryRepository: OrderHistoryRepository(),
    );
  });

  group('PaymentViewModel初期状態のテスト', () {
    test('初期状態では受け取り金額が0であること', () {
      expect(paymentViewModel.receivedAmount, 0);
    });

    test('初期状態ではお釣りが0であること', () {
      expect(paymentViewModel.changeAmount, 0);
    });

    test('初期状態では支払いが無効であること', () {
      expect(paymentViewModel.isValidPayment, false);
    });
  });

  group('金額更新のテスト', () {
    test('合計金額未満の金額を設定すると支払いが無効になること', () {
      paymentViewModel.updateReceivedAmount(400);

      expect(paymentViewModel.receivedAmount, 400);
      expect(paymentViewModel.changeAmount, 0);
      expect(paymentViewModel.isValidPayment, false);
    });

    test('合計金額ちょうどを設定すると支払いが有効になること', () {
      paymentViewModel.updateReceivedAmount(500);

      expect(paymentViewModel.receivedAmount, 500);
      expect(paymentViewModel.changeAmount, 0);
      expect(paymentViewModel.isValidPayment, true);
    });

    test('合計金額を超える金額を設定するとお釣りが計算されること', () {
      paymentViewModel.updateReceivedAmount(1000);

      expect(paymentViewModel.receivedAmount, 1000);
      expect(paymentViewModel.changeAmount, 500);
      expect(paymentViewModel.isValidPayment, true);
    });

    test('0円を設定すると支払いが無効になること', () {
      // 一度有効な金額を設定
      paymentViewModel.updateReceivedAmount(1000);
      expect(paymentViewModel.isValidPayment, true);

      // 0円に変更
      paymentViewModel.updateReceivedAmount(0);
      expect(paymentViewModel.receivedAmount, 0);
      expect(paymentViewModel.changeAmount, 0);
      expect(paymentViewModel.isValidPayment, false);
    });
  });
}
