import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:yakitori_register/data/service/notification_service.dart';

import 'data/repository/order_history_repository.dart';
import 'data/repository/product_repository.dart';
import 'domain/model/order_history_item.dart';
import 'domain/model/order_item.dart';
import 'domain/model/product.dart';
import 'ui/debug/debug_screen.dart';
import 'ui/order/widget/order_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 通知の初期化
  await NotificationService().initialize();

  // Hiveの初期化
  await Hive.initFlutter();

  // アダプターの登録
  Hive.registerAdapter(ProductAdapter());
  Hive.registerAdapter(OrderItemAdapter());
  Hive.registerAdapter(OrderHistoryItemAdapter());

  // リポジトリの初期化
  final orderHistoryRepository = OrderHistoryRepository();
  await orderHistoryRepository.initialize();

  // デバッグ通知の表示
  await NotificationService().showDebugNotification();

  runApp(MyApp(orderHistoryRepository: orderHistoryRepository));
}

class MyApp extends StatelessWidget {
  final OrderHistoryRepository orderHistoryRepository;

  const MyApp({super.key, required this.orderHistoryRepository});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '焼き鳥レジアプリ',
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          primary: Colors.blue,
          secondary: Colors.lightBlue,
          surface: Colors.white,
          onPrimary: Colors.white,
        ),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => OrderScreen(
              productRepository: ProductRepository(),
              orderHistoryRepository: orderHistoryRepository,
            ),
        '/debug': (context) => DebugScreen(
              orderHistoryRepository: orderHistoryRepository,
            ),
      },
      // デバッグ通知タップ時の処理
      navigatorKey: NotificationService().navigatorKey,
      onGenerateRoute: (settings) {
        if (settings.name == '/notification') {
          final payload = settings.arguments as String?;
          if (payload == 'debug') {
            return MaterialPageRoute(
              builder: (context) => DebugScreen(
                orderHistoryRepository: orderHistoryRepository,
              ),
            );
          }
        }
        return null;
      },
    );
  }
}
