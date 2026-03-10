from __future__ import annotations

from typing import Dict, List


def _insight_item(item: Dict) -> Dict:
    return {
        "title": item.get("title", ""),
        "summary": item.get("summary", ""),
        "category": item.get("category", "macro"),
        "sourceUrl": item.get("sourceUrl", ""),
        "region": item.get("region", "domestic"),
        "urgency": item.get("urgency", "low"),
        "impact": item.get("impact", "neutral"),
        "sectors": item.get("relatedSectors", []),
        "source": item.get("source", ""),
        "publishedAt": item.get("publishedAt", ""),
        "scoreEffect": item.get("scoreEffect", "暂不计分"),
    }


def _breaking_news_item(item: Dict) -> Dict:
    return {
        "title": item.get("title", ""),
        "summary": item.get("summary", ""),
        "sourceUrl": item.get("sourceUrl", ""),
        "region": item.get("region", "domestic"),
        "impact": item.get("impact", "neutral"),
        "level": item.get("urgency", "low"),
        "sectors": item.get("relatedSectors", []),
        "source": item.get("source", ""),
        "publishedAt": item.get("publishedAt", ""),
        "scoreEffect": item.get("scoreEffect", "暂不计分"),
    }


def build_news_sections(items: List[Dict]) -> Dict[str, List[Dict]]:
    breaking_news = [_breaking_news_item(item) for item in items if item.get("urgency") == "high"]
    insights = [_insight_item(item) for item in items[:8]]
    return {
        "breaking_news": breaking_news,
        "insights": insights,
    }
