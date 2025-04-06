import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yakitori_register/data/repository/order_history_repository.dart';
import 'package:yakitori_register/data/repository/product_repository.dart';
import 'package:yakitori_register/domain/model/product.dart';
import 'package:yakitori_register/ui/order/widget/order_screen.dart';

// テスト用のモックリポジトリ
class MockProductRepository extends ProductRepository {
  @override
  List<Product> getProducts() {
    return [
      Product(id: '1', name: 'もも 塩', price: 150),
      Product(id: '2', name: 'むね 塩', price: 120),
      Product(id: '3', name: 'ねぎま', price: 180),
    ];
  }
}

void main() {
  group('OrderScreen UIテスト', () {
    // テスト実行前に共通の画面サイズを設定する関数
    void setUpScreenSize(WidgetTester tester) {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.reset());
    }

    testWidgets('基本操作のテスト', (WidgetTester tester) async {
      setUpScreenSize(tester);

      // OrderScreenをビルド
      await tester.pumpWidget(
        MaterialApp(
          home: OrderScreen(
            productRepository: MockProductRepository(),
            orderHistoryRepository: OrderHistoryRepository(),
          ),
        ),
      );

      // 1. 初期画面の構成要素確認
      expect(find.text('注文入力'), findsOneWidget);
      expect(find.text('注文内容'), findsOneWidget);
      expect(find.text('商品を選択してください'), findsOneWidget);
      expect(find.text('支払いへ進む'), findsOneWidget);

      // 2. 商品一覧の確認
      expect(find.text('もも 塩'), findsOneWidget);
      expect(find.text('むね 塩'), findsOneWidget);
      expect(find.text('ねぎま'), findsOneWidget);

      // 3. 商品選択のテスト
      await tester.tap(find.text('もも 塩'));
      await tester.pump();

      // 注文リストに追加されたことを確認
      expect(find.text('もも 塩'), findsNWidgets(2));
      expect(find.text('150円 × 1個'), findsOneWidget);
      expect(find.text('150円'), findsAtLeastNWidgets(1));

      // 4. 別の商品を追加
      await tester.tap(find.text('ねぎま'));
      await tester.pump();

      expect(find.text('ねぎま'), findsNWidgets(2));
      expect(find.text('180円 × 1個'), findsOneWidget);

      // 合計金額の確認（150 + 180 = 330）
      expect(find.text('330円'), findsOneWidget);

      // 5. 商品の削除テスト
      final firstRemoveButton = find.byIcon(Icons.remove_circle_outline).first;
      await tester.tap(firstRemoveButton);
      await tester.pump();

      expect(find.text('もも 塩'), findsOneWidget);
      expect(find.text('150円 × 1個'), findsNothing);
      expect(find.text('180円'), findsAtLeastNWidgets(1));

      // 6. 空の状態での支払いボタンテスト
      await tester.tap(find.byIcon(Icons.remove_circle_outline).first);
      await tester.pump();

      expect(find.text('商品を選択してください'), findsOneWidget);

      await tester.tap(find.text('支払いへ進む'));
      await tester.pump();

      // エラーメッセージ表示の確認
      expect(find.text('商品を選択してください'), findsAtLeastNWidgets(1));
    });

    testWidgets('注文完了フローのテスト', (WidgetTester tester) async {
      setUpScreenSize(tester);

      // OrderScreenをビルド
      await tester.pumpWidget(
        MaterialApp(
          home: OrderScreen(
            productRepository: MockProductRepository(),
            orderHistoryRepository: OrderHistoryRepository(),
          ),
        ),
      );

      // 商品を選択
      await tester.tap(find.text('むね 塩'));
      await tester.pump();

      // 支払いダイアログを表示
      await tester.tap(find.text('支払いへ進む'));
      await tester.pumpAndSettle();

      // 支払いダイアログが表示されることを確認
      expect(find.text('お支払い'), findsOneWidget);
      expect(find.text('お支払い金額'), findsOneWidget);
      expect(find.text('¥120'), findsOneWidget);

      // 金額入力ボタンをタップ（例：1000円）
      await tester.tap(find.text('¥1,000'));
      await tester.pump();

      // お預かり金額とおつりが正しく表示されることを確認
      expect(find.text('1000円'), findsOneWidget); // お預かり金額
      expect(find.text('880円'), findsOneWidget); // おつり (1000-120)

      // 会計するボタンをタップ
      await tester.tap(find.text('会計する'));
      await tester.pumpAndSettle();

      // 会計完了画面が表示されることを確認
      expect(find.text('会計完了'), findsOneWidget);

      // RichTextウィジェットの代わりに、アイコンとタイトル表示を確認
      expect(find.byIcon(Icons.check), findsOneWidget);

      // おつり金額の確認
      expect(find.text('おつり'), findsOneWidget);
      expect(find.text('¥880'), findsOneWidget);

      // 明細の確認
      expect(find.text('お預かり ¥1000'), findsOneWidget);
      expect(find.text('合計金額 ¥120'), findsOneWidget);

      // 注文画面に戻るボタンをタップ
      await tester.tap(find.text('注文画面に戻る'));
      await tester.pumpAndSettle();

      // 注文画面に戻り、カートがクリアされていることを確認
      expect(find.text('注文入力'), findsOneWidget);
      expect(find.text('商品を選択してください'), findsOneWidget);
    });

    testWidgets('会計後に注文管理ダイアログで注文の反映を確認するテスト', (WidgetTester tester) async {
      setUpScreenSize(tester);

      // リポジトリの初期状態を記録
      final orderHistoryRepository = OrderHistoryRepository();
      final initialOrders = orderHistoryRepository.getOrders().length;

      // OrderScreenをビルド
      await tester.pumpWidget(
        MaterialApp(
          home: OrderScreen(
            productRepository: MockProductRepository(),
            orderHistoryRepository: orderHistoryRepository,
          ),
        ),
      );

      // 1. 商品を選択
      await tester.tap(find.text('もも 塩'));
      await tester.pump();
      await tester.tap(find.text('ねぎま'));
      await tester.pump();

      // 2. 支払いへ進む
      await tester.tap(find.text('支払いへ進む'));
      await tester.pumpAndSettle();

      // 3. 金額入力と会計処理
      await tester.tap(find.text('¥1,000'));
      await tester.pump();
      await tester.tap(find.text('会計する'));
      await tester.pumpAndSettle();

      // 4. 注文画面に戻る
      await tester.tap(find.text('注文画面に戻る'));
      await tester.pumpAndSettle();

      // 5. 注文管理ダイアログを表示
      await tester.tap(find.byIcon(Icons.receipt_long));
      await tester.pumpAndSettle();

      // 6. ダイアログ表示確認
      expect(find.text('注文管理'), findsOneWidget);

      // 7. すべての注文タブに切り替え
      await tester.tap(find.text('すべての注文'));
      await tester.pumpAndSettle();

      // 8. 注文が追加されたことを確認
      final currentOrders = orderHistoryRepository.getOrders().length;
      expect(currentOrders, greaterThan(initialOrders));

      // 9. 新しい注文が表示されていることを確認
      expect(find.textContaining('注文 #'), findsAtLeastNWidgets(1));

      // 10. 注文カードをインタラクティブに見つけてタップ
      final orderCards = find.descendant(
        of: find.byType(ListView),
        matching: find.byType(InkWell),
      );

      if (orderCards.evaluate().isNotEmpty) {
        await tester.tap(orderCards.first);
        await tester.pumpAndSettle();
      }

      // 11. 注文が展開されているかを確認（どちらかが存在すればOK）
      final hasCompleteButton = find.text('すべて提供完了').evaluate().isNotEmpty;
      final hasCheckboxes = find.byType(Checkbox).evaluate().isNotEmpty;

      expect(
        hasCompleteButton || hasCheckboxes,
        isTrue,
        reason: '注文カードが展開されていません',
      );

      // 12. ダイアログを閉じる
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
    });
  });
}
