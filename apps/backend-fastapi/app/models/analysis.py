from typing import List, Literal, Optional

from pydantic import BaseModel


ImpactValue = Literal["positive", "neutral", "negative"]
AlertLevel = Literal["high", "medium", "low"]
ConfidenceLevel = Literal["high", "medium", "low"]
InsightCategory = Literal["company", "sector", "macro"]


class CandlePoint(BaseModel):
    date: str
    open: float
    high: float
    low: float
    close: float


class BreakingNewsItem(BaseModel):
    title: str
    summary: str
    impact: ImpactValue
    level: AlertLevel
    sectors: List[str]
    source: str
    publishedAt: str
    scoreEffect: str


class SectorImpactItem(BaseModel):
    sector: str
    impact: ImpactValue
    reason: str


class InsightItem(BaseModel):
    title: str
    summary: str
    category: InsightCategory
    impact: ImpactValue
    sectors: List[str]
    source: str
    publishedAt: str
    scoreEffect: str


class StockAnalysis(BaseModel):
    code: str
    name: str
    market: str = "A-share"
    industry: Optional[str] = None
    latestPrice: float
    changePercent: float
    totalScore: int
    fundamentalsScore: int
    newsScore: int
    technicalsScore: int
    sentimentScore: int
    rating: str
    confidence: ConfidenceLevel
    summaryComment: str
    advice: str
    highlightPoints: List[str]
    riskPoints: List[str]
    verdict: str
    riskWarning: str
    scoreTrend: str
    scoreHistory: List[int]
    candles: List[CandlePoint]
    breakingNews: List[BreakingNewsItem]
    sectorImpacts: List[SectorImpactItem]
    insights: List[InsightItem]
    fundamentalsReasons: List[str]
    newsReasons: List[str]
    technicalsReasons: List[str]
    sentimentReasons: List[str]
