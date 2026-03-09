import 'package:flutter/material.dart';

import '../view_models/stock_repository.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/stock_list_item.dart';
import 'stock_detail_screen.dart';
import 'watchlist_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final controller = TextEditingController();
  final repository = const StockRepository();
  String query = '';

  @override
  Widget build(BuildContext context) {
    final stocks = repository
        .loadStocks()
        .where((stock) => stock.code.contains(query) || stock.name.contains(query))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('首页'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const WatchlistScreen()),
              );
            },
            child: const Text('自选'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SearchBarWidget(
            controller: controller,
            onChanged: (value) {
              setState(() {
                query = value;
              });
            },
          ),
          const SizedBox(height: 16),
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

