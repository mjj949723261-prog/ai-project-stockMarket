from typing import Dict, List


def _clamp(value: int, lower: int, upper: int) -> int:
    return max(lower, min(upper, value))


def score_analysis(
    fundamentals: dict,
    news: List[Dict],
    quote: Dict,
    sentiment: Dict,
) -> Dict:
    fundamentals_score = 18
    revenue_growth = float(fundamentals.get("revenue_growth", 0) or 0)
    profit_growth = float(fundamentals.get("profit_growth", 0) or 0)
    roe = float(fundamentals.get("roe", 0) or 0)
    market_cap = float(fundamentals.get("market_cap", 0) or 0)

    if revenue_growth > 0.1:
        fundamentals_score += 6
    if profit_growth > 0.08:
        fundamentals_score += 6
    if roe > 0.12:
        fundamentals_score += 5
    if market_cap > 100_000_000_000:
        fundamentals_score += 2
    fundamentals_score = _clamp(fundamentals_score, 8, 35)

    news_score = 14
    for item in news:
        impact = item.get("impact", "neutral")
        strength = int(item.get("strength", 1))
        if impact == "positive":
            news_score += strength * 2
        elif impact == "negative":
            news_score -= strength * 2
    news_score = _clamp(news_score, 5, 25)

    technicals_score = 12
    change_percent = float(quote.get("change_percent", 0) or 0)
    volume_ratio = float(quote.get("volume_ratio", 1) or 1)
    if change_percent > 0:
        technicals_score += 5
    if change_percent > 2:
        technicals_score += 3
    if volume_ratio > 1:
        technicals_score += 4
    technicals_score = _clamp(technicals_score, 5, 25)

    sentiment_score = 8
    heat = sentiment.get("heat", "cool")
    if heat == "warm":
        sentiment_score += 4
    elif heat == "hot":
        sentiment_score += 5
    sentiment_score = _clamp(sentiment_score, 5, 15)

    total_score = _clamp(
        fundamentals_score + news_score + technicals_score + sentiment_score,
        0,
        100,
    )

    score_trend = "flat"
    if change_percent > 1:
        score_trend = "up"
    elif change_percent < -1:
        score_trend = "down"

    reasons = {
        "fundamentals": [
            "营收增长为正" if revenue_growth > 0 else "营收增长数据暂弱",
            "利润增长为正" if profit_growth > 0 else "利润增长数据暂弱",
        ],
        "news": [
            "近期未见显著利空" if news_score >= 14 else "近期外部消息偏谨慎",
        ],
        "technicals": [
            "短期价格表现转强" if change_percent > 0 else "短期价格仍偏弱",
            "成交活跃度提升" if volume_ratio > 1 else "成交活跃度一般",
        ],
        "sentiment": [
            "市场关注度温和" if heat != "cool" else "市场关注度偏低",
        ],
    }

    return {
        "total_score": total_score,
        "fundamentals_score": fundamentals_score,
        "news_score": news_score,
        "technicals_score": technicals_score,
        "sentiment_score": sentiment_score,
        "score_trend": score_trend,
        "reasons": reasons,
    }
