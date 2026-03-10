from app.scoring.engine import score_analysis


def test_score_analysis_returns_total_and_dimensions():
    result = score_analysis(
        fundamentals={"revenue_growth": 0.16, "profit_growth": 0.13},
        news=[{"impact": "positive", "strength": 2}],
        quote={"change_percent": 1.8, "volume_ratio": 1.2},
        sentiment={"heat": "warm"},
    )

    assert set(result) >= {
        "total_score",
        "fundamentals_score",
        "news_score",
        "technicals_score",
        "sentiment_score",
        "score_trend",
        "reasons",
        "rating",
        "confidence",
        "summary_comment",
        "advice",
        "highlight_points",
        "risk_points",
    }


def test_score_analysis_keeps_total_within_100():
    result = score_analysis(
        fundamentals={"revenue_growth": 1.0, "profit_growth": 1.0, "roe": 0.5},
        news=[{"impact": "positive", "strength": 3}],
        quote={"change_percent": 9.9, "volume_ratio": 3.0},
        sentiment={"heat": "hot"},
    )

    assert 0 <= result["total_score"] <= 100
