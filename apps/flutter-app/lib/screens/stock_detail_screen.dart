import 'package:flutter/material.dart';

import '../models/stock.dart';
import '../widgets/dimension_score_card.dart';
import '../widgets/reason_list.dart';
import '../widgets/score_summary_card.dart';

class StockDetailScreen extends StatelessWidget {
  const StockDetailScreen({super.key, required this.stock});

  final Stock stock;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(stock.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ScoreSummaryCard(stock: stock),
          DimensionScoreCard(
            title: '基本面',
            score: stock.fundamentalsScore,
            reasons: stock.fundamentalsReasons,
            trend: stock.scoreTrend,
          ),
          DimensionScoreCard(
            title: '消息面',
            score: stock.newsScore,
            reasons: stock.newsReasons,
            trend: stock.scoreTrend,
          ),
          DimensionScoreCard(
            title: '技术面',
            score: stock.technicalsScore,
            reasons: stock.technicalsReasons,
            trend: stock.scoreTrend,
          ),
          DimensionScoreCard(
            title: '情绪面',
            score: stock.sentimentScore,
            reasons: stock.sentimentReasons,
            trend: stock.scoreTrend,
          ),
          ReasonList(title: '详细依据：基本面', reasons: stock.fundamentalsReasons),
          ReasonList(title: '详细依据：消息面', reasons: stock.newsReasons),
          ReasonList(title: '详细依据：技术面', reasons: stock.technicalsReasons),
          ReasonList(title: '详细依据：情绪面', reasons: stock.sentimentReasons),
        ],
      ),
    );
  }
}

