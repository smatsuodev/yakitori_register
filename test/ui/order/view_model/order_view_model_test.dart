import 'package:flutter_test/flutter_test.dart';
import 'package:yakitori_register/domain/model/product.dart';
import 'package:yakitori_register/ui/order/view_model/order_view_model.dart';

void main() {
  late OrderViewModel orderViewModel;

  setUp(() {
    orderViewModel = OrderViewModel();
  });

  group('OrderViewModel初期状態のテスト', () {
    test('初期状態では注文リストが空であること', () {
      expect(orderViewModel.orderItems, isEmpty);
    });

    test('初期状態では合計金額が0であること', () {
      expect(orderViewModel.totalAmount, 0);
    });

    test('初期状態ではhasItemsがfalseであること', () {
      expect(orderViewModel.hasItems, false);
    });
  });

  group('商品追加のテスト', () {
    final product1 = Product(id: '1', name: 'もも 甘口', price: 100);
    final product2 = Product(id: '2', name: 'もも 中辛', price: 120);

    test('商品を追加すると注文リストに追加されること', () {
      orderViewModel.addProduct(product1);

      expect(orderViewModel.orderItems.length, 1);
      expect(orderViewModel.orderItems[0].product.id, '1');
      expect(orderViewModel.orderItems[0].quantity, 1);
    });

    test('同じ商品を追加すると数量が増えること', () {
      orderViewModel.addProduct(product1);
      orderViewModel.addProduct(product1);

      expect(orderViewModel.orderItems.length, 1);
      expect(orderViewModel.orderItems[0].quantity, 2);
      expect(orderViewModel.orderItems[0].subtotal, 200);
    });

    test('異なる商品を追加すると別の注文項目になること', () {
      orderViewModel.addProduct(product1);
      orderViewModel.addProduct(product2);

      expect(orderViewModel.orderItems.length, 2);
      expect(orderViewModel.orderItems[0].product.id, '1');
      expect(orderViewModel.orderItems[1].product.id, '2');
    });

    test('商品追加後はhasItemsがtrueになること', () {
      expect(orderViewModel.hasItems, false);

      orderViewModel.addProduct(product1);

      expect(orderViewModel.hasItems, true);
    });

    test('合計金額が正しく計算されること', () {
      orderViewModel.addProduct(product1); // 100円
      expect(orderViewModel.totalAmount, 100);

      orderViewModel.addProduct(product1); // さらに100円
      expect(orderViewModel.totalAmount, 200);

      orderViewModel.addProduct(product2); // さらに120円
      expect(orderViewModel.totalAmount, 320);
    });
  });

  group('商品削除のテスト', () {
    final product = Product(id: '1', name: 'もも 甘口', price: 100);

    test('商品を削除すると注文リストから削除されること', () {
      orderViewModel.addProduct(product);
      expect(orderViewModel.orderItems.length, 1);

      orderViewModel.removeProduct(product.id);
      expect(orderViewModel.orderItems, isEmpty);
    });

    test('数量が2以上の場合は1つだけ削除されること', () {
      orderViewModel.addProduct(product);
      orderViewModel.addProduct(product); // 合計2個

      orderViewModel.removeProduct(product.id);

      expect(orderViewModel.orderItems.length, 1);
      expect(orderViewModel.orderItems[0].quantity, 1);
    });

    test('存在しないIDの商品を削除しようとしても何も起きないこと', () {
      orderViewModel.addProduct(product);

      orderViewModel.removeProduct('存在しないID');

      expect(orderViewModel.orderItems.length, 1);
    });

    test('全ての商品を削除するとhasItemsがfalseになること', () {
      orderViewModel.addProduct(product);
      expect(orderViewModel.hasItems, true);

      orderViewModel.removeProduct(product.id);
      expect(orderViewModel.hasItems, false);
    });
  });

  group('カートクリアのテスト', () {
    final product1 = Product(id: '1', name: 'もも 甘口', price: 100);
    final product2 = Product(id: '2', name: 'もも 中辛', price: 120);

    test('clearCartを呼び出すと注文リストが空になること', () {
      // 商品をカートに追加
      orderViewModel.addProduct(product1);
      orderViewModel.addProduct(product2);
      expect(orderViewModel.orderItems.length, 2);

      // カートをクリア
      orderViewModel.clearCart();

      // 検証
      expect(orderViewModel.orderItems, isEmpty);
    });

    test('clearCart後は合計金額が0になること', () {
      // 商品をカートに追加
      orderViewModel.addProduct(product1);
      orderViewModel.addProduct(product2);
      expect(orderViewModel.totalAmount, 220);

      // カートをクリア
      orderViewModel.clearCart();

      // 検証
      expect(orderViewModel.totalAmount, 0);
    });

    test('clearCart後はhasItemsがfalseになること', () {
      // 商品をカートに追加
      orderViewModel.addProduct(product1);
      expect(orderViewModel.hasItems, true);

      // カートをクリア
      orderViewModel.clearCart();

      // 検証
      expect(orderViewModel.hasItems, false);
    });
  });
}
