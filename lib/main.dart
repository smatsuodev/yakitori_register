import 'package:flutter/material.dart';

import 'data/repository/order_history_repository.dart';
import 'data/repository/product_repository.dart';
import 'ui/order/widget/order_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        cardTheme: CardTheme(
          color: Colors.white,
          shadowColor: Colors.blue[100],
        ),
        useMaterial3: true,
      ),
      home: OrderScreen(
        productRepository: ProductRepository(),
        orderHistoryRepository: OrderHistoryRepository(),
      ),
    );
  }
}
