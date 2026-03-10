from fastapi.testclient import TestClient

from app.main import app


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
