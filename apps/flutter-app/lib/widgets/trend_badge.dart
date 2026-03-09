import 'package:flutter/material.dart';

import '../models/stock.dart';

class TrendBadge extends StatelessWidget {
  const TrendBadge({super.key, required this.trend});

  final ScoreTrend trend;

  @override
  Widget build(BuildContext context) {
    final label = switch (trend) {
      ScoreTrend.up => '上升',
      ScoreTrend.flat => '持平',
      ScoreTrend.down => '下降',
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.teal.withOpacity(0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.teal,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

