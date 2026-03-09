import 'package:flutter/material.dart';

import '../models/stock.dart';
import 'trend_badge.dart';

class StockListItem extends StatelessWidget {
  const StockListItem({super.key, required this.stock, required this.onTap});

  final Stock stock;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        title: Text(stock.name),
        subtitle: Text('${stock.code}\n${stock.verdict}'),
        isThreeLine: true,
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${stock.totalScore}', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            TrendBadge(trend: stock.scoreTrend),
          ],
        ),
      ),
    );
  }
}

