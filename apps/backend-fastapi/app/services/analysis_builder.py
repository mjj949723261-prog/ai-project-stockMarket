from __future__ import annotations

from typing import Dict, List


def build_news_sections(items: List[Dict]) -> Dict[str, List[Dict]]:
    breaking_news = [item for item in items if item.get("urgency") == "high"]
    insights = items[:8]
    return {
        "breaking_news": breaking_news,
        "insights": insights,
    }
