from fastapi.testclient import TestClient

from app.main import app
from app.providers.news.akshare_news_provider import AkshareNewsProvider
from app.services.analysis_builder import build_news_sections


client = TestClient(app)


def test_health_route_exists():
    response = client.get("/health")

    assert response.status_code == 200
    assert response.json() == {"ok": True}


def test_search_route_exists():
    response = client.get("/api/stocks/search", params={"q": "茅台"})

    assert response.status_code == 200
    assert isinstance(response.json(), list)


def test_analysis_route_exists():
    response = client.get("/api/stocks/600519/analysis")

    assert response.status_code == 200
    payload = response.json()
    assert payload["code"] == "600519"
    assert "totalScore" in payload
    assert "rating" in payload
    assert "confidence" in payload
    assert "summaryComment" in payload
    assert "breakingNews" in payload
    assert "sectorImpacts" in payload
    assert "insights" in payload
    assert "candles" in payload


def test_akshare_news_provider_returns_domestic_news_shape():
    provider = AkshareNewsProvider()
    items = provider._normalize(
        [
            {
                "新闻标题": "贵州茅台回购计划引发关注",
                "新闻内容": "公司公告摘要",
                "发布时间": "2026-03-10 10:00:00",
                "文章来源": "东方财富",
            }
        ]
    )

    assert items[0]["region"] == "domestic"
    assert items[0]["source"] == "东方财富"


def test_build_news_sections_splits_breaking_news_and_insights():
    items = [
        {
            "title": "突发事件",
            "summary": "高优先级",
            "source": "Reuters",
            "sourceUrl": "https://example.com/reuters",
            "publishedAt": "2026-03-10 10:00",
            "region": "global",
            "category": "macro",
            "impact": "negative",
            "urgency": "high",
            "relatedSectors": ["白酒"],
            "scoreEffect": "消息面 -2，情绪面 -1",
        }
    ]

    sections = build_news_sections(items)
    assert len(sections["breaking_news"]) == 1
    assert len(sections["insights"]) == 1
    assert sections["breaking_news"][0]["level"] == "high"
    assert sections["breaking_news"][0]["sectors"] == ["白酒"]
    assert sections["insights"][0]["urgency"] == "high"
    assert sections["insights"][0]["sectors"] == ["白酒"]


def test_analysis_route_returns_real_news_sections():
    response = client.get("/api/stocks/600519/analysis")
    payload = response.json()

    assert payload["breakingNews"]
    assert payload["insights"]
    assert payload["insights"][0]["source"]
    assert payload["insights"][0]["sourceUrl"] != ""
