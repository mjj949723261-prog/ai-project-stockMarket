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
            "ROE 保持在健康区间" if roe > 0.12 else "ROE 仍需继续改善",
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

    if total_score >= 85:
        rating = "A 关注优先级高"
        advice = "适合继续跟踪，并等待更强确认。"
    elif total_score >= 75:
        rating = "A- 值得持续跟踪"
        advice = "适合继续跟踪，节奏上避免追高。"
    elif total_score >= 65:
        rating = "B+ 有亮点但需观察"
        advice = "适合观察催化是否持续，不宜单靠情绪判断。"
    elif total_score >= 55:
        rating = "B 结构一般"
        advice = "等待更多确认信号，再决定是否纳入重点观察。"
    else:
        rating = "C 风险偏高"
        advice = "当前不宜激进，优先规避不确定性。"

    confidence = "medium"
    if revenue_growth and profit_growth and market_cap:
        confidence = "high"
    elif not revenue_growth and not profit_growth:
        confidence = "low"

    summary_parts = [
        "基本面稳" if fundamentals_score >= 28 else "基本面仍需观察",
        "消息面偏多" if news_score >= 17 else "消息面中性偏谨慎",
        "走势改善" if technicals_score >= 18 else "走势弹性一般",
        "情绪温和" if sentiment_score >= 11 else "情绪支撑有限",
    ]
    summary_comment = "，".join(summary_parts) + "。"

    highlight_points = [
        "总分达到跟踪区间" if total_score >= 70 else "仍处观察区间",
        "消息面未见显著利空" if news_score >= 14 else "外部消息扰动偏多",
        "量价结构改善" if technicals_score >= 17 else "量价结构尚未完全转强",
    ]
    risk_points = [
        "短期波动可能放大" if abs(change_percent) > 2 else "短期趋势确认度一般",
        "财务维度仍需更多结构化数据" if confidence != "high" else "高分仍需结合估值位置",
    ]

    return {
        "total_score": total_score,
        "fundamentals_score": fundamentals_score,
        "news_score": news_score,
        "technicals_score": technicals_score,
        "sentiment_score": sentiment_score,
        "score_trend": score_trend,
        "reasons": reasons,
        "rating": rating,
        "confidence": confidence,
        "summary_comment": summary_comment,
        "advice": advice,
        "highlight_points": highlight_points,
        "risk_points": risk_points,
    }
