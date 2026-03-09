import 'package:flutter/material.dart';

import '../view_models/stock_repository.dart';
import '../widgets/stock_list_item.dart';
import 'stock_detail_screen.dart';

class WatchlistScreen extends StatelessWidget {
  const WatchlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final stocks = const StockRepository().loadStocks().take(1).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('自选')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final stock in stocks)
            StockListItem(
              stock: stock,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => StockDetailScreen(stock: stock),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

