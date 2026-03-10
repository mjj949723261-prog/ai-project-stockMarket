from app.services.news_classifier import classify_news_items
from app.providers.news.global_news_provider import GlobalNewsProvider


def test_classify_news_items_returns_normalized_fields():
    items = classify_news_items(
        code="600519",
        name="贵州茅台",
        industry="酿酒行业",
        raw_items=[
            {
                "title": "白酒板块估值修复",
                "summary": "机构认为消费龙头关注度回升",
                "source": "Reuters",
                "publishedAt": "2026-03-10 09:30",
                "region": "global",
                "category": "macro",
                "sourceUrl": "https://example.com/story",
            }
        ],
    )

    assert items[0]["impact"] in {"positive", "neutral", "negative"}
    assert items[0]["urgency"] in {"high", "medium", "low"}
    assert isinstance(items[0]["relatedSectors"], list)
    assert "scoreEffect" in items[0]


def test_global_news_provider_filters_reuters_and_bloomberg_entries():
    provider = GlobalNewsProvider()
    items = provider._normalize(
        [
            {
                "title": "Oil prices rise on supply worries",
                "summary": "Brent crude extended gains",
                "link": "https://www.reuters.com/example",
                "source": "Reuters",
                "published": "Tue, 10 Mar 2026 08:00:00 GMT",
            },
            {
                "title": "Ignored item",
                "summary": "Other feed",
                "link": "https://example.com/other",
                "source": "Other",
                "published": "Tue, 10 Mar 2026 08:00:00 GMT",
            },
        ]
    )

    assert len(items) == 1
    assert items[0]["region"] == "global"
    assert items[0]["source"] == "Reuters"


def test_classify_news_items_marks_sector_and_score_effect():
    items = classify_news_items(
        code="300750",
        name="宁德时代",
        industry="电池",
        raw_items=[
            {
                "title": "Battery supply chain faces cost pressure",
                "summary": "Raw material costs moved higher",
                "source": "Reuters",
                "sourceUrl": "https://example.com/reuters",
                "publishedAt": "2026-03-10 10:00",
                "region": "global",
                "category": "macro",
            }
        ],
    )

    assert items[0]["relatedSectors"] == ["电池"]
    assert "消息面" in items[0]["scoreEffect"]
