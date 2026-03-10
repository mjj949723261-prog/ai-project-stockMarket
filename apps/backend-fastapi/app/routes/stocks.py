from __future__ import annotations

from datetime import datetime
from typing import List, Dict

from fastapi import APIRouter

from app.cache.memory_cache import MemoryCache
from app.core.settings import settings
from app.models.analysis import StockAnalysis
from app.models.stock import SearchStock
from app.providers.akshare_provider import AkshareProvider
from app.providers.fallback_data import find_stock_fixture, load_stock_fixtures
from app.providers.tushare_provider import TushareProvider
from app.scoring.engine import score_analysis

router = APIRouter(prefix="/api/stocks", tags=["stocks"])

cache = MemoryCache()
akshare_provider = AkshareProvider()
tushare_provider = TushareProvider(token=settings.tushare_token)


def _build_history_scores(price_history: List[Dict], total_score: int) -> List[int]:
    closes = [row["close"] for row in price_history[-5:]]
    if len(closes) < 5:
        return [total_score] * 5

    baseline = closes[0] or 1
    values: List[int] = []
    for close in closes:
        drift = int(((close - baseline) / baseline) * 25)
        values.append(max(0, min(100, total_score + drift)))
    return values


def _build_candles(price_history: List[Dict], latest_price: float) -> List[Dict]:
    if not price_history:
        base = latest_price or 100
        return [
            {
                "date": f"D-{offset}",
                "open": round(base * (1 - offset * 0.002), 2),
                "high": round(base * (1 + 0.01 - offset * 0.001), 2),
                "low": round(base * (1 - 0.012 - offset * 0.001), 2),
                "close": round(base * (1 - offset * 0.001), 2),
            }
            for offset in range(5, 0, -1)
        ]

    return [
        {
            "date": row["date"],
            "open": round(float(row["open"]), 2),
            "high": round(float(row["high"]), 2),
            "low": round(float(row["low"]), 2),
            "close": round(float(row["close"]), 2),
        }
        for row in price_history[-8:]
    ]


def _impact_label(change_percent: float) -> str:
    if change_percent > 0.8:
        return "positive"
    if change_percent < -0.8:
        return "negative"
    return "neutral"


def _alert_level(change_percent: float) -> str:
    if abs(change_percent) >= 3:
        return "high"
    if abs(change_percent) >= 1.5:
        return "medium"
    return "low"


def _confidence_label(confidence: str) -> str:
    mapping = {
        "high": "high",
        "medium": "medium",
        "low": "low",
    }
    return mapping.get(confidence, "medium")


def _build_breaking_news(
    *,
    industry: str | None,
    change_percent: float,
    score_effect: str,
    timestamp: str,
) -> List[Dict]:
    sector = industry or "核心资产"
    impact = _impact_label(change_percent)
    level = _alert_level(change_percent)
    direction = "利好" if impact == "positive" else "利空" if impact == "negative" else "中性"
    move_label = "放量走强" if change_percent > 0 else "波动加大" if change_percent < 0 else "震荡整理"

    return [
        {
            "title": f"{sector}链条日内{move_label}",
            "summary": f"价格波动与成交活跃度同步变化，当前被归类为{direction}事件，需要结合板块扩散判断持续性。",
            "impact": impact,
            "level": level,
            "sectors": [sector],
            "source": "AKShare 行情聚合",
            "publishedAt": timestamp,
            "scoreEffect": score_effect,
        },
        {
            "title": f"{sector}板块关注度出现再定价",
            "summary": "系统根据个股波动、行业属性和历史评分变化生成预警，提示优先检查板块联动而非单点冲高。",
            "impact": "neutral" if impact == "positive" else impact,
            "level": "medium",
            "sectors": [sector, "消费龙头" if sector != "消费龙头" else sector],
            "source": "系统事件引擎",
            "publishedAt": timestamp,
            "scoreEffect": "消息面观察项",
        },
    ]


def _build_sector_impacts(industry: str | None, change_percent: float) -> List[Dict]:
    sector = industry or "核心资产"
    impact = _impact_label(change_percent)

    impacts = [
        {
            "sector": sector,
            "impact": impact,
            "reason": "个股价格与成交活跃度共同变化，表明板块资金偏好正在重新定价。",
        },
        {
            "sector": "高股息防御",
            "impact": "negative" if change_percent > 1.5 else "neutral",
            "reason": "若成长或消费风格走强，防御板块吸引力会被阶段性分流。",
        },
    ]
    return impacts


def _build_insights(
    *,
    name: str,
    industry: str | None,
    change_percent: float,
    news_score: int,
    timestamp: str,
) -> List[Dict]:
    sector = industry or "核心资产"
    impact = _impact_label(change_percent)

    return [
        {
            "title": f"{name} 公司观察",
            "summary": "当前评分以行情和基础面聚合为主，短期没有检测到需要完全推翻判断的公司级异常信号。",
            "category": "company",
            "impact": impact,
            "sectors": [sector],
            "source": "AKShare + 系统归因",
            "publishedAt": timestamp,
            "scoreEffect": f"消息面 {news_score}/25",
        },
        {
            "title": f"{sector} 板块脉冲",
            "summary": "板块维度更适合看扩散而不是单日涨跌，当前建议同步关注龙头和跟随股的强弱分化。",
            "category": "sector",
            "impact": impact,
            "sectors": [sector],
            "source": "系统板块推演",
            "publishedAt": timestamp,
            "scoreEffect": "板块影响已纳入消息面和情绪面",
        },
        {
            "title": "国际宏观观察",
            "summary": "海外需求、汇率和全球风险偏好会影响 A 股核心资产估值弹性，当前宜把宏观扰动作为风险校正项而非单独交易信号。",
            "category": "macro",
            "impact": "neutral",
            "sectors": [sector, "国际宏观"],
            "source": "系统宏观视角",
            "publishedAt": timestamp,
            "scoreEffect": "暂作评价修正，不直接单独加分",
        },
    ]


def _analysis_from_fixture(fallback: Dict) -> StockAnalysis:
    history = fallback.get("scoreHistory", [50, 50, 50, 50, 50])
    previous = history[-2] if len(history) > 1 else history[-1]
    current = history[-1]
    change_percent = float(fallback.get("changePercent", current - previous))
    industry = fallback.get("industry")
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M")
    rating = fallback.get("rating", "A- 值得持续跟踪" if current >= 75 else "B+ 有亮点但需观察")
    confidence = fallback.get("confidence", "medium")
    summary_comment = fallback.get("summaryComment", fallback["verdict"])
    advice = fallback.get("advice", "适合继续跟踪，节奏上避免追高。")
    highlight_points = fallback.get(
        "highlightPoints",
        ["基本面维持稳定", "消息面没有显著利空", "评分延续改善趋势" if current >= previous else "评分仍需二次确认"],
    )
    risk_points = fallback.get(
        "riskPoints",
        ["短期涨跌幅放大时，节奏风险会上升", fallback["riskWarning"]],
    )
    latest_price = float(fallback.get("latestPrice", 0))
    score_effect = "消息面 +1，情绪面 +1" if change_percent >= 0 else "消息面 -1，情绪面 -1"
    return StockAnalysis(
        code=fallback["code"],
        name=fallback["name"],
        industry=industry,
        latestPrice=latest_price,
        changePercent=change_percent,
        totalScore=int(fallback["totalScore"]),
        fundamentalsScore=int(fallback["fundamentalsScore"]),
        newsScore=int(fallback["newsScore"]),
        technicalsScore=int(fallback["technicalsScore"]),
        sentimentScore=int(fallback["sentimentScore"]),
        rating=rating,
        confidence=_confidence_label(str(confidence)),
        summaryComment=summary_comment,
        advice=advice,
        highlightPoints=highlight_points,
        riskPoints=risk_points,
        verdict=fallback["verdict"],
        riskWarning=fallback["riskWarning"],
        scoreTrend=fallback["scoreTrend"],
        scoreHistory=history,
        candles=_build_candles([], latest_price),
        breakingNews=fallback.get(
            "breakingNews",
            _build_breaking_news(
                industry=industry,
                change_percent=change_percent,
                score_effect=score_effect,
                timestamp=timestamp,
            ),
        ),
        sectorImpacts=fallback.get(
            "sectorImpacts",
            _build_sector_impacts(industry, change_percent),
        ),
        insights=fallback.get(
            "insights",
            _build_insights(
                name=fallback["name"],
                industry=industry,
                change_percent=change_percent,
                news_score=int(fallback["newsScore"]),
                timestamp=timestamp,
            ),
        ),
        fundamentalsReasons=fallback["fundamentalsReasons"],
        newsReasons=fallback["newsReasons"],
        technicalsReasons=fallback["technicalsReasons"],
        sentimentReasons=fallback["sentimentReasons"],
    )


@router.get("/search", response_model=List[SearchStock])
def search_stocks(q: str = "") -> List[SearchStock]:
    cache_key = f"search:{q.strip()}"
    cached = cache.get(cache_key)
    if cached is not None:
        return cached

    try:
        raw_items = akshare_provider.search_stocks(q)
        items = [
            SearchStock(code=item["code"], name=item["name"])
            for item in raw_items
        ]
    except Exception:
        keyword = q.strip()
        items = []
        for item in load_stock_fixtures():
            if not keyword or keyword in item["code"] or keyword in item["name"]:
                items.append(SearchStock(code=item["code"], name=item["name"]))

    cache.set(cache_key, items, settings.search_cache_ttl_seconds)
    return items


@router.get("/{code}/analysis", response_model=StockAnalysis)
def get_analysis(code: str) -> StockAnalysis:
    cache_key = f"analysis:{code}"
    cached = cache.get(cache_key)
    if cached is not None:
        return cached

    try:
        profile = akshare_provider.get_stock_profile(code)
        history = akshare_provider.get_price_history(code)
    except Exception:
        fallback = find_stock_fixture(code)
        if fallback is None:
            fallback = {
                "code": code,
                "name": code,
                "industry": None,
                "latestPrice": 0,
                "changePercent": 0,
                "totalScore": 50,
                "fundamentalsScore": 15,
                "newsScore": 12,
                "technicalsScore": 12,
                "sentimentScore": 11,
                "verdict": "暂时无法获取实时数据，返回降级分析。",
                "riskWarning": "外部数据源当前不可用。",
                "scoreTrend": "flat",
                "scoreHistory": [50, 50, 50, 50, 50],
                "fundamentalsReasons": ["实时基本面数据暂不可用"],
                "newsReasons": ["实时消息数据暂不可用"],
                "technicalsReasons": ["实时技术数据暂不可用"],
                "sentimentReasons": ["实时情绪数据暂不可用"],
            }
        result = _analysis_from_fixture(fallback)
        cache.set(cache_key, result, settings.analysis_cache_ttl_seconds)
        return result

    latest = history[-1] if history else {
        "close": profile.get("latest_price", 0),
        "change_percent": 0,
        "volume": 0,
        "turnover_rate": 0,
    }

    fundamentals = tushare_provider.get_fundamentals(code)
    fundamentals = {
        "market_cap": profile.get("market_cap", 0),
        **fundamentals,
    }

    quote = {
        "change_percent": latest["change_percent"],
        "volume_ratio": 1.2 if latest["turnover_rate"] > 0.5 else 0.9,
    }
    sentiment = {
        "heat": "warm" if latest["turnover_rate"] > 0.3 else "cool",
    }
    news = [
        {
            "impact": "positive" if latest["change_percent"] >= 0 else "neutral",
            "strength": 1,
        }
    ]

    scores = score_analysis(
        fundamentals=fundamentals,
        news=news,
        quote=quote,
        sentiment=sentiment,
    )
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M")
    score_effect = "消息面 +2，情绪面 +1" if latest["change_percent"] >= 0 else "消息面 -2，情绪面 -1"

    result = StockAnalysis(
        code=profile.get("code", code),
        name=profile.get("name", code),
        industry=profile.get("industry"),
        latestPrice=round(float(latest["close"]), 2),
        changePercent=round(float(latest["change_percent"]), 2),
        totalScore=scores["total_score"],
        fundamentalsScore=scores["fundamentals_score"],
        newsScore=scores["news_score"],
        technicalsScore=scores["technicals_score"],
        sentimentScore=scores["sentiment_score"],
        rating=scores["rating"],
        confidence=_confidence_label(scores["confidence"]),
        summaryComment=scores["summary_comment"],
        advice=scores["advice"],
        highlightPoints=scores["highlight_points"],
        riskPoints=scores["risk_points"],
        verdict="近期走势和关注度改善，适合继续跟踪。" if scores["total_score"] >= 70 else "结构仍需观察，暂不宜激进判断。",
        riskWarning="当前分析主要依赖行情和基础资料，部分财务指标待补齐。",
        scoreTrend=scores["score_trend"],
        scoreHistory=_build_history_scores(history, scores["total_score"]),
        candles=_build_candles(history, profile.get("latest_price", 0)),
        breakingNews=_build_breaking_news(
            industry=profile.get("industry"),
            change_percent=float(latest["change_percent"]),
            score_effect=score_effect,
            timestamp=timestamp,
        ),
        sectorImpacts=_build_sector_impacts(profile.get("industry"), float(latest["change_percent"])),
        insights=_build_insights(
            name=profile.get("name", code),
            industry=profile.get("industry"),
            change_percent=float(latest["change_percent"]),
            news_score=scores["news_score"],
            timestamp=timestamp,
        ),
        fundamentalsReasons=scores["reasons"]["fundamentals"],
        newsReasons=scores["reasons"]["news"],
        technicalsReasons=scores["reasons"]["technicals"],
        sentimentReasons=scores["reasons"]["sentiment"],
    )
    cache.set(cache_key, result, settings.analysis_cache_ttl_seconds)
    return result
