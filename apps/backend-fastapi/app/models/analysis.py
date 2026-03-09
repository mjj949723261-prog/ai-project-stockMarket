from typing import List, Optional

from pydantic import BaseModel


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
    verdict: str
    riskWarning: str
    scoreTrend: str
    scoreHistory: List[int]
    fundamentalsReasons: List[str]
    newsReasons: List[str]
    technicalsReasons: List[str]
    sentimentReasons: List[str]
