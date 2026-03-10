from __future__ import annotations

from typing import Dict, List


POSITIVE_KEYWORDS = (
    "修复",
    "回升",
    "增长",
    "回购",
    "合作",
    "利好",
    "improve",
    "rise",
    "gain",
)
NEGATIVE_KEYWORDS = (
    "压力",
    "下滑",
    "处罚",
    "诉讼",
    "利空",
    "cost pressure",
    "fall",
    "drop",
    "worry",
)
HIGH_URGENCY_KEYWORDS = ("突发", "处罚", "诉讼", "预警", "warning", "surge", "slump")


def _impact_for_text(text: str) -> str:
    lowered = text.lower()
    if any(keyword in lowered for keyword in NEGATIVE_KEYWORDS):
        return "negative"
    if any(keyword in lowered for keyword in POSITIVE_KEYWORDS):
        return "positive"
    return "neutral"


def _urgency_for_text(text: str) -> str:
    lowered = text.lower()
    if any(keyword in lowered for keyword in HIGH_URGENCY_KEYWORDS):
        return "high"
    if "关注" in text or "watch" in lowered or "supply" in lowered:
        return "medium"
    return "low"


def _score_effect(impact: str, urgency: str) -> str:
    if impact == "positive":
        if urgency == "high":
            return "消息面 +3，情绪面 +1"
        if urgency == "medium":
            return "消息面 +2"
        return "消息面 +1"
    if impact == "negative":
        if urgency == "high":
            return "消息面 -3，情绪面 -1"
        if urgency == "medium":
            return "消息面 -2"
        return "消息面 -1"
    return "暂不计分"


def classify_news_items(
    *,
    code: str,
    name: str,
    industry: str | None,
    raw_items: List[Dict],
) -> List[Dict]:
    del code

    normalized: List[Dict] = []
    for item in raw_items:
        title = str(item.get("title") or "")
        summary = str(item.get("summary") or "")
        text = f"{title} {summary} {name}"
        impact = _impact_for_text(text)
        urgency = _urgency_for_text(text)
        related_sectors: List[str] = list(item.get("relatedSectors") or [])
        if industry and industry not in related_sectors:
            related_sectors.append(industry)

        normalized.append(
            {
                **item,
                "impact": impact,
                "urgency": urgency,
                "relatedSectors": related_sectors,
                "scoreEffect": _score_effect(impact, urgency),
            }
        )

    return normalized
