# Live News Integration Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add real domestic and international news inputs to the backend, map them into the unified analysis payload, and replace the synthetic macro card with real news-backed insights in the Vue3 detail page.

**Architecture:** Introduce dedicated news providers, a unified news mapping layer, and a classifier/service pipeline that converts raw stories into `breakingNews`, `insights`, sector impacts, and score adjustments. Keep the external API surface centered on `/api/stocks/:code/analysis` so the frontend continues to read a single aggregate payload.

**Tech Stack:** Python, FastAPI, pytest, Vue 3, TypeScript, lightweight RSS/XML parsing, AKShare

---

## 前提假设

- 当前 `analysis` 已经返回研究卡片所需的基础结构。
- 当前 `Vue3 H5` 已消费 `breakingNews`、`insights`、`sectorImpacts`。
- 当前后端已有基础缓存与 `AKShare` provider。
- 第一版国际资讯以摘要级聚合为主，不抓取全文。

### Task 1: 为统一新闻模型写失败测试

**Files:**
- Create: `apps/backend-fastapi/tests/test_news_classifier.py`
- Modify: `apps/backend-fastapi/app/models/analysis.py`

**Step 1: Write the failing test**

```python
from app.services.news_classifier import classify_news_items


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
```

**Step 2: Run test to verify it fails**

Run: `pytest tests/test_news_classifier.py::test_classify_news_items_returns_normalized_fields -v`
Expected: FAIL because the classifier module does not exist yet

**Step 3: Write minimal implementation**

```python
def classify_news_items(*, code, name, industry, raw_items):
    return [
        {
            **item,
            "impact": "neutral",
            "urgency": "low",
            "relatedSectors": [industry] if industry else [],
            "scoreEffect": "暂不计分",
        }
        for item in raw_items
    ]
```

**Step 4: Run test to verify it passes**

Run: `pytest tests/test_news_classifier.py::test_classify_news_items_returns_normalized_fields -v`
Expected: PASS

**Step 5: Commit**

```bash
git add apps/backend-fastapi/tests/test_news_classifier.py apps/backend-fastapi/app/services/news_classifier.py
git commit -m "feat: add normalized news classifier"
```

### Task 2: 为 AKShare 国内资讯 provider 写失败测试

**Files:**
- Create: `apps/backend-fastapi/app/providers/news/akshare_news_provider.py`
- Modify: `apps/backend-fastapi/tests/test_routes.py`

**Step 1: Write the failing test**

```python
from app.providers.news.akshare_news_provider import AkshareNewsProvider


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
```

**Step 2: Run test to verify it fails**

Run: `pytest tests/test_routes.py::test_akshare_news_provider_returns_domestic_news_shape -v`
Expected: FAIL because the provider module does not exist yet

**Step 3: Write minimal implementation**

```python
class AkshareNewsProvider:
    def _normalize(self, rows):
        return [
            {
                "title": row["新闻标题"],
                "summary": row["新闻内容"],
                "source": row["文章来源"],
                "publishedAt": row["发布时间"],
                "sourceUrl": "",
                "region": "domestic",
                "category": "company",
            }
            for row in rows
        ]
```

**Step 4: Run test to verify it passes**

Run: `pytest tests/test_routes.py::test_akshare_news_provider_returns_domestic_news_shape -v`
Expected: PASS

**Step 5: Commit**

```bash
git add apps/backend-fastapi/app/providers/news/akshare_news_provider.py apps/backend-fastapi/tests/test_routes.py
git commit -m "feat: add domestic news provider"
```

### Task 3: 为国际摘要 provider 写失败测试

**Files:**
- Create: `apps/backend-fastapi/app/providers/news/global_news_provider.py`
- Test: `apps/backend-fastapi/tests/test_news_classifier.py`

**Step 1: Write the failing test**

```python
from app.providers.news.global_news_provider import GlobalNewsProvider


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
```

**Step 2: Run test to verify it fails**

Run: `pytest tests/test_news_classifier.py::test_global_news_provider_filters_reuters_and_bloomberg_entries -v`
Expected: FAIL because the provider module does not exist yet

**Step 3: Write minimal implementation**

```python
class GlobalNewsProvider:
    def _normalize(self, entries):
        supported = {"Reuters", "Bloomberg"}
        return [
            {
                "title": item["title"],
                "summary": item["summary"],
                "source": item["source"],
                "sourceUrl": item["link"],
                "publishedAt": item["published"],
                "region": "global",
                "category": "macro",
            }
            for item in entries
            if item["source"] in supported
        ]
```

**Step 4: Run test to verify it passes**

Run: `pytest tests/test_news_classifier.py::test_global_news_provider_filters_reuters_and_bloomberg_entries -v`
Expected: PASS

**Step 5: Commit**

```bash
git add apps/backend-fastapi/app/providers/news/global_news_provider.py apps/backend-fastapi/tests/test_news_classifier.py
git commit -m "feat: add global news provider"
```

### Task 4: 为新闻分类规则写失败测试

**Files:**
- Modify: `apps/backend-fastapi/tests/test_news_classifier.py`
- Modify: `apps/backend-fastapi/app/services/news_classifier.py`

**Step 1: Write the failing test**

```python
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
```

**Step 2: Run test to verify it fails**

Run: `pytest tests/test_news_classifier.py::test_classify_news_items_marks_sector_and_score_effect -v`
Expected: FAIL because sector inference and score effect are not implemented yet

**Step 3: Write minimal implementation**

```python
if industry and industry not in normalized["relatedSectors"]:
    normalized["relatedSectors"].append(industry)
normalized["scoreEffect"] = "消息面 -1"
```

**Step 4: Run test to verify it passes**

Run: `pytest tests/test_news_classifier.py::test_classify_news_items_marks_sector_and_score_effect -v`
Expected: PASS

**Step 5: Commit**

```bash
git add apps/backend-fastapi/tests/test_news_classifier.py apps/backend-fastapi/app/services/news_classifier.py
git commit -m "feat: classify news impact and sector effects"
```

### Task 5: 为 analysis builder 写失败测试

**Files:**
- Create: `apps/backend-fastapi/app/services/analysis_builder.py`
- Modify: `apps/backend-fastapi/tests/test_routes.py`

**Step 1: Write the failing test**

```python
from app.services.analysis_builder import build_news_sections


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
```

**Step 2: Run test to verify it fails**

Run: `pytest tests/test_routes.py::test_build_news_sections_splits_breaking_news_and_insights -v`
Expected: FAIL because the builder module does not exist yet

**Step 3: Write minimal implementation**

```python
def build_news_sections(items):
    breaking_news = [item for item in items if item["urgency"] == "high"]
    return {
        "breaking_news": breaking_news,
        "insights": items,
    }
```

**Step 4: Run test to verify it passes**

Run: `pytest tests/test_routes.py::test_build_news_sections_splits_breaking_news_and_insights -v`
Expected: PASS

**Step 5: Commit**

```bash
git add apps/backend-fastapi/app/services/analysis_builder.py apps/backend-fastapi/tests/test_routes.py
git commit -m "feat: build news sections for analysis payload"
```

### Task 6: 把真实新闻接入 `/api/stocks/:code/analysis`

**Files:**
- Modify: `apps/backend-fastapi/app/routes/stocks.py`
- Modify: `apps/backend-fastapi/app/core/settings.py`
- Modify: `apps/backend-fastapi/tests/test_routes.py`

**Step 1: Write the failing test**

```python
def test_analysis_route_returns_real_news_sections():
    response = client.get("/api/stocks/600519/analysis")
    payload = response.json()

    assert payload["breakingNews"]
    assert payload["insights"]
    assert payload["insights"][0]["source"]
    assert payload["insights"][0]["sourceUrl"] is not None
```

**Step 2: Run test to verify it fails**

Run: `pytest tests/test_routes.py::test_analysis_route_returns_real_news_sections -v`
Expected: FAIL because the analysis route still uses synthetic sections only

**Step 3: Write minimal implementation**

```python
raw_domestic = akshare_news_provider.get_company_news(code)
raw_global = global_news_provider.get_market_news()
classified = classify_news_items(
    code=code,
    name=profile.get("name", code),
    industry=profile.get("industry"),
    raw_items=[*raw_domestic, *raw_global],
)
news_sections = build_news_sections(classified)
```

**Step 4: Run test to verify it passes**

Run: `pytest tests/test_routes.py::test_analysis_route_returns_real_news_sections -v`
Expected: PASS

**Step 5: Commit**

```bash
git add apps/backend-fastapi/app/routes/stocks.py apps/backend-fastapi/app/core/settings.py apps/backend-fastapi/tests/test_routes.py
git commit -m "feat: wire real news into stock analysis"
```

### Task 7: 为前端类型写失败验证

**Files:**
- Modify: `apps/web-vue3/src/types/stock.ts`
- Modify: `apps/web-vue3/src/components/InsightFeed.vue`
- Modify: `apps/web-vue3/src/components/BreakingNewsCard.vue`

**Step 1: Write the failing type expectation**

```ts
const item = {
  title: "Macro item",
  summary: "Summary",
  source: "Reuters",
  sourceUrl: "https://example.com",
  publishedAt: "2026-03-10 10:00",
  region: "global",
  category: "macro",
  impact: "neutral",
  urgency: "medium",
  relatedSectors: ["白酒"],
  scoreEffect: "消息面 +1",
};
```

**Step 2: Run build to verify it fails**

Run: `npm --prefix apps/web-vue3 run build`
Expected: FAIL if the frontend types are missing `sourceUrl`, `region`, or `urgency`

**Step 3: Write minimal implementation**

```ts
sourceUrl: string;
region: "domestic" | "global";
urgency: "high" | "medium" | "low";
relatedSectors: string[];
```

**Step 4: Run build to verify it passes**

Run: `npm --prefix apps/web-vue3 run build`
Expected: PASS

**Step 5: Commit**

```bash
git add apps/web-vue3/src/types/stock.ts apps/web-vue3/src/components/InsightFeed.vue apps/web-vue3/src/components/BreakingNewsCard.vue
git commit -m "feat: align frontend news types with real sources"
```

### Task 8: 在前端展示真实来源链接与区域

**Files:**
- Modify: `apps/web-vue3/src/components/InsightFeed.vue`
- Modify: `apps/web-vue3/src/components/BreakingNewsCard.vue`
- Modify: `apps/web-vue3/src/style.css`

**Step 1: Write the failing UI expectation**

```vue
<a :href="item.sourceUrl" target="_blank" rel="noreferrer">
  {{ item.source }}
</a>
<span>{{ item.region === "global" ? "国际" : "国内" }}</span>
```

**Step 2: Run build to verify it fails or is missing**

Run: `npm --prefix apps/web-vue3 run build`
Expected: FAIL or missing bindings before implementation

**Step 3: Write minimal implementation**

```vue
<div class="meta-row">
  <a class="source-link" :href="item.sourceUrl" target="_blank" rel="noreferrer">{{ item.source }}</a>
  <span>{{ item.region === "global" ? "国际" : "国内" }}</span>
  <span>{{ item.publishedAt }}</span>
</div>
```

**Step 4: Run build to verify it passes**

Run: `npm --prefix apps/web-vue3 run build`
Expected: PASS

**Step 5: Commit**

```bash
git add apps/web-vue3/src/components/InsightFeed.vue apps/web-vue3/src/components/BreakingNewsCard.vue apps/web-vue3/src/style.css
git commit -m "feat: show real news sources in research cards"
```

### Task 9: 完整验证并提交

**Files:**
- Verify: `apps/backend-fastapi/tests/test_routes.py`
- Verify: `apps/backend-fastapi/tests/test_scoring_engine.py`
- Verify: `apps/backend-fastapi/tests/test_news_classifier.py`
- Verify: `apps/web-vue3`

**Step 1: Run backend test suite**

Run: `. .venv/bin/activate && pytest tests/test_routes.py tests/test_scoring_engine.py tests/test_news_classifier.py -q`
Expected: PASS with zero failures

**Step 2: Run frontend build**

Run: `npm --prefix apps/web-vue3 run build`
Expected: PASS

**Step 3: Check git diff**

Run: `git status --short`
Expected: only intended files changed

**Step 4: Commit**

```bash
git add .
git commit -m "feat: integrate real domestic and global news"
```
