import 'package:flutter/material.dart';

import '../models/stock.dart';
import 'trend_badge.dart';

class DimensionScoreCard extends StatelessWidget {
  const DimensionScoreCard({
    super.key,
    required this.title,
    required this.score,
    required this.reasons,
    required this.trend,
  });

  final String title;
  final int score;
  final List<String> reasons;
  final ScoreTrend trend;

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
                Expanded(child: Text(title, style: Theme.of(context).textTheme.titleMedium)),
                Text('$score'),
                const SizedBox(width: 10),
                TrendBadge(trend: trend),
              ],
            ),
            const SizedBox(height: 12),
            for (final reason in reasons) Text('• $reason'),
          ],
        ),
      ),
    );
  }
}

