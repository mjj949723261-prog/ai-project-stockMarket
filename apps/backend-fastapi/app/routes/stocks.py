from __future__ import annotations

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


def _analysis_from_fixture(fallback: Dict) -> StockAnalysis:
    history = fallback.get("scoreHistory", [50, 50, 50, 50, 50])
    previous = history[-2] if len(history) > 1 else history[-1]
    current = history[-1]
    return StockAnalysis(
        code=fallback["code"],
        name=fallback["name"],
        industry=fallback.get("industry"),
        latestPrice=float(fallback.get("latestPrice", 0)),
        changePercent=float(fallback.get("changePercent", current - previous)),
        totalScore=int(fallback["totalScore"]),
        fundamentalsScore=int(fallback["fundamentalsScore"]),
        newsScore=int(fallback["newsScore"]),
        technicalsScore=int(fallback["technicalsScore"]),
        sentimentScore=int(fallback["sentimentScore"]),
        verdict=fallback["verdict"],
        riskWarning=fallback["riskWarning"],
        scoreTrend=fallback["scoreTrend"],
        scoreHistory=history,
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
        verdict="近期走势和关注度改善，适合继续跟踪。" if scores["total_score"] >= 70 else "结构仍需观察，暂不宜激进判断。",
        riskWarning="当前分析主要依赖行情和基础资料，部分财务指标待补齐。",
        scoreTrend=scores["score_trend"],
        scoreHistory=_build_history_scores(history, scores["total_score"]),
        fundamentalsReasons=scores["reasons"]["fundamentals"],
        newsReasons=scores["reasons"]["news"],
        technicalsReasons=scores["reasons"]["technicals"],
        sentimentReasons=scores["reasons"]["sentiment"],
    )
    cache.set(cache_key, result, settings.analysis_cache_ttl_seconds)
    return result
