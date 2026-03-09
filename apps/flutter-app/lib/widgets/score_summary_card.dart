import 'package:flutter/material.dart';

import '../models/stock.dart';

class ScoreSummaryCard extends StatelessWidget {
  const ScoreSummaryCard({super.key, required this.stock});

  final Stock stock;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(stock.name, style: Theme.of(context).textTheme.titleLarge),
                      Text(stock.code, style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
                Text('${stock.totalScore}', style: Theme.of(context).textTheme.displaySmall),
              ],
            ),
            const SizedBox(height: 12),
            Text(stock.verdict),
            const SizedBox(height: 8),
            Text(
              '风险提示：${stock.riskWarning}',
              style: const TextStyle(color: Colors.deepOrange),
            ),
          ],
        ),
      ),
    );
  }
}

