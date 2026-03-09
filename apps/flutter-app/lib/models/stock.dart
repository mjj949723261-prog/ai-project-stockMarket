enum ScoreTrend { up, flat, down }

class Stock {
  const Stock({
    required this.code,
    required this.name,
    required this.totalScore,
    required this.fundamentalsScore,
    required this.newsScore,
    required this.technicalsScore,
    required this.sentimentScore,
    required this.verdict,
    required this.riskWarning,
    required this.scoreTrend,
    required this.fundamentalsReasons,
    required this.newsReasons,
    required this.technicalsReasons,
    required this.sentimentReasons,
  });

  final String code;
  final String name;
  final int totalScore;
  final int fundamentalsScore;
  final int newsScore;
  final int technicalsScore;
  final int sentimentScore;
  final String verdict;
  final String riskWarning;
  final ScoreTrend scoreTrend;
  final List<String> fundamentalsReasons;
  final List<String> newsReasons;
  final List<String> technicalsReasons;
  final List<String> sentimentReasons;
}

