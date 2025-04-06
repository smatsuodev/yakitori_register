import 'package:flutter/material.dart';

import '../../data/repository/order_history_repository.dart';

class DebugScreen extends StatefulWidget {
  final OrderHistoryRepository orderHistoryRepository;

  const DebugScreen({super.key, required this.orderHistoryRepository});

  @override
  State<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('デバッグ画面'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ストレージ操作',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildStorageCard(),
            const SizedBox(height: 16),
            const Text(
              '注文履歴情報',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildOrderInfoCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildStorageCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('注文履歴データの管理'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _clearOrderHistory,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('注文履歴をすべて削除'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderInfoCard() {
    final orders = widget.orderHistoryRepository.getOrders();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('保存されている注文数: ${orders.length}'),
            if (orders.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('最新の注文日時: ${orders.first.timestamp.toString()}'),
              const SizedBox(height: 8),
              Text('最古の注文日時: ${orders.last.timestamp.toString()}'),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _clearOrderHistory() async {
    // 確認ダイアログを表示
    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('確認'),
        content: const Text('すべての注文履歴を削除しますか？この操作は元に戻せません。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('削除する'),
          ),
        ],
      ),
    );

    if (shouldClear != true) return;

    setState(() => _isLoading = true);

    try {
      await widget.orderHistoryRepository.clearAllOrders();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('注文履歴をすべて削除しました')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('エラーが発生しました: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
