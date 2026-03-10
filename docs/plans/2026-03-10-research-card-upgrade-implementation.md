# Research Card Upgrade Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Upgrade the stock detail experience into a polished research-card product with richer evaluation output, K-line visualization, highlighted breaking news, sector impact labels, and improved visual hierarchy.

**Architecture:** Extend the backend analysis payload to include rating, confidence, breaking-news items, sector impacts, and richer commentary. Refactor the Vue3 detail page first into a multi-layer research-card layout, then propagate the same data contract to SwiftUI and Flutter.

**Tech Stack:** Python, FastAPI, Vue 3, TypeScript, SwiftUI, Flutter, lightweight charting, icon assets

---

## 前提假设

- 当前 `Vue3 H5` 已经能连接真实后端基础接口。
- 当前后端已具备 `analysis` 和 `search` 的最小可用实现。
- 当前 `SwiftUI` 与 `Flutter` 还没有切到真实接口。
- 本次升级优先落地 `Vue3 H5` 详情页。

### Task 1: 扩展后端分析模型

**Files:**
- Modify: `apps/backend-fastapi/app/models/analysis.py`
- Test: `apps/backend-fastapi/tests/test_routes.py`

**Step 1: Write the failing test**

```python
def test_analysis_route_returns_rating_fields():
    response = client.get("/api/stocks/600519/analysis")
    payload = response.json()
    assert "rating" in payload
    assert "confidence" in payload
    assert "summaryComment" in payload
```

**Step 2: Run test to verify it fails**

Run: `pytest tests/test_routes.py::test_analysis_route_returns_rating_fields -v`
Expected: FAIL because the analysis response does not yet include the new fields

**Step 3: Write minimal implementation**

```python
class StockAnalysis(BaseModel):
    rating: str
    confidence: str
    summaryComment: str
```

**Step 4: Run test to verify it passes**

Run: `pytest tests/test_routes.py::test_analysis_route_returns_rating_fields -v`
Expected: PASS

**Step 5: Commit**

```bash
git add apps/backend-fastapi/app/models/analysis.py apps/backend-fastapi/tests/test_routes.py
git commit -m "feat: add research-card analysis fields"
```

### Task 2: 为后端增加突发消息和板块影响字段

**Files:**
- Modify: `apps/backend-fastapi/app/models/analysis.py`
- Modify: `apps/backend-fastapi/app/routes/stocks.py`
- Test: `apps/backend-fastapi/tests/test_routes.py`

**Step 1: Write the failing test**

```python
def test_analysis_route_returns_breaking_news_and_sector_impacts():
    response = client.get("/api/stocks/600519/analysis")
    payload = response.json()
    assert "breakingNews" in payload
    assert "sectorImpacts" in payload
```

**Step 2: Run test to verify it fails**

Run: `pytest tests/test_routes.py::test_analysis_route_returns_breaking_news_and_sector_impacts -v`
Expected: FAIL because those fields are not present

**Step 3: Write minimal implementation**

```python
"breakingNews": [],
"sectorImpacts": [],
```

**Step 4: Run test to verify it passes**

Run: `pytest tests/test_routes.py::test_analysis_route_returns_breaking_news_and_sector_impacts -v`
Expected: PASS

**Step 5: Commit**

```bash
git add apps/backend-fastapi/app/models/analysis.py apps/backend-fastapi/app/routes/stocks.py apps/backend-fastapi/tests/test_routes.py
git commit -m "feat: add breaking news and sector impact fields"
```

### Task 3: 生成评分评价与建议

**Files:**
- Modify: `apps/backend-fastapi/app/scoring/engine.py`
- Modify: `apps/backend-fastapi/app/routes/stocks.py`
- Test: `apps/backend-fastapi/tests/test_scoring_engine.py`

**Step 1: Write the failing test**

```python
def test_score_analysis_returns_rating_and_advice():
    result = score_analysis(
        fundamentals={"revenue_growth": 0.16, "profit_growth": 0.13},
        news=[{"impact": "positive", "strength": 2}],
        quote={"change_percent": 1.8, "volume_ratio": 1.2},
        sentiment={"heat": "warm"},
    )
    assert "rating" in result
    assert "advice" in result
```

**Step 2: Run test to verify it fails**

Run: `pytest tests/test_scoring_engine.py::test_score_analysis_returns_rating_and_advice -v`
Expected: FAIL because the scoring engine does not return those fields

**Step 3: Write minimal implementation**

```python
"rating": "A- 值得持续跟踪",
"confidence": "中",
"advice": "适合继续跟踪",
```

**Step 4: Run test to verify it passes**

Run: `pytest tests/test_scoring_engine.py::test_score_analysis_returns_rating_and_advice -v`
Expected: PASS

**Step 5: Commit**

```bash
git add apps/backend-fastapi/app/scoring/engine.py apps/backend-fastapi/app/routes/stocks.py apps/backend-fastapi/tests/test_scoring_engine.py
git commit -m "feat: generate richer evaluation commentary"
```

### Task 4: 为 Vue3 定义升级后的详情页类型

**Files:**
- Modify: `apps/web-vue3/src/types/stock.ts`
- Test: `apps/web-vue3/src/types/stock-upgrade.test.ts`

**Step 1: Write the failing test**

```ts
import type { StockAnalysis } from "./stock";

const sample: StockAnalysis = {
  code: "600519",
  name: "贵州茅台",
  market: "A-share",
  industry: "白酒",
  latestPrice: 1397,
  changePercent: 1.2,
  totalScore: 82,
  rating: "A- 值得持续跟踪",
  confidence: "中",
  summaryComment: "基本面稳健",
  breakingNews: [],
  sectorImpacts: [],
  fundamentalsScore: 31,
  newsScore: 20,
  technicalsScore: 18,
  sentimentScore: 13,
  verdict: "继续跟踪",
  riskWarning: "短期涨幅较大",
  scoreTrend: "up",
  scoreHistory: [73, 75, 77, 79, 82],
  fundamentalsReasons: [],
  newsReasons: [],
  technicalsReasons: [],
  sentimentReasons: [],
};
```

**Step 2: Run test to verify it fails**

Run: `npm --prefix apps/web-vue3 run build`
Expected: FAIL because the frontend type is missing the new fields

**Step 3: Write minimal implementation**

```ts
rating: string;
confidence: string;
summaryComment: string;
breakingNews: BreakingNewsItem[];
sectorImpacts: SectorImpactItem[];
```

**Step 4: Run test to verify it passes**

Run: `npm --prefix apps/web-vue3 run build`
Expected: PASS

**Step 5: Commit**

```bash
git add apps/web-vue3/src/types/stock.ts
git commit -m "feat: extend frontend stock analysis types"
```

### Task 5: 新增详情页研究卡片组件

**Files:**
- Create: `apps/web-vue3/src/components/RatingBadge.vue`
- Create: `apps/web-vue3/src/components/BreakingNewsCard.vue`
- Create: `apps/web-vue3/src/components/SectorImpactCard.vue`
- Create: `apps/web-vue3/src/components/KLinePanel.vue`
- Test: `apps/web-vue3/src/components/BreakingNewsCard.test.ts`

**Step 1: Write the failing test**

```ts
import { mount } from "@vue/test-utils";
import { describe, expect, it } from "vitest";
import BreakingNewsCard from "./BreakingNewsCard.vue";

describe("BreakingNewsCard", () => {
  it("renders impact labels", () => {
    const wrapper = mount(BreakingNewsCard, {
      props: {
        item: {
          title: "白酒消费政策调整",
          sentiment: "利好",
          sector: "白酒",
          level: "高",
          source: "彭博社",
          time: "10:30",
          summary: "政策边际改善",
        },
      },
    });
    expect(wrapper.text()).toContain("利好");
    expect(wrapper.text()).toContain("白酒");
  });
});
```

**Step 2: Run test to verify it fails**

Run: `npm --prefix apps/web-vue3 run test -- src/components/BreakingNewsCard.test.ts`
Expected: FAIL because the research-card components do not exist yet

**Step 3: Write minimal implementation**

```vue
<template>
  <section>
    <strong>{{ item.title }}</strong>
    <p>{{ item.sentiment }}</p>
    <p>{{ item.sector }}</p>
  </section>
</template>
```

**Step 4: Run test to verify it passes**

Run: `npm --prefix apps/web-vue3 run test -- src/components/BreakingNewsCard.test.ts`
Expected: PASS

**Step 5: Commit**

```bash
git add apps/web-vue3/src/components
git commit -m "feat: add research-card detail components"
```

### Task 6: 重构 Vue3 详情页布局

**Files:**
- Modify: `apps/web-vue3/src/views/StockDetailView.vue`
- Modify: `apps/web-vue3/src/style.css`

**Step 1: Write the failing test**

```text
验证详情页不再只是评分卡片和依据列表，而包含：
- 评级
- K线区域
- 突发消息
- 板块影响
```

**Step 2: Run test to verify it fails**

Run: `grep -n "评级\\|K线\\|突发消息\\|板块影响" apps/web-vue3/src/views/StockDetailView.vue`
Expected: FAIL because the upgraded sections are not yet present

**Step 3: Write minimal implementation**

```vue
<section>
  <h2>评级</h2>
  <KLinePanel />
  <BreakingNewsCard />
  <SectorImpactCard />
</section>
```

**Step 4: Run test to verify it passes**

Run: `npm --prefix apps/web-vue3 run build`
Expected: PASS with the new detail layout in place

**Step 5: Commit**

```bash
git add apps/web-vue3/src/views/StockDetailView.vue apps/web-vue3/src/style.css
git commit -m "feat: upgrade vue3 detail page to research-card layout"
```

### Task 7: 增强首页与自选页入口信息

**Files:**
- Modify: `apps/web-vue3/src/views/HomeView.vue`
- Modify: `apps/web-vue3/src/views/WatchlistView.vue`
- Modify: `apps/web-vue3/src/components/StockListItem.vue`

**Step 1: Write the failing test**

```text
验证首页和自选页列表项可展示：
- 评级
- 突发消息数量
- 风险级别入口
```

**Step 2: Run test to verify it fails**

Run: `grep -R "评级\\|突发\\|风险" apps/web-vue3/src/views/HomeView.vue apps/web-vue3/src/views/WatchlistView.vue apps/web-vue3/src/components/StockListItem.vue`
Expected: FAIL because list summary has not been upgraded yet

**Step 3: Write minimal implementation**

```vue
<span>{{ stock.rating }}</span>
<span>突发 1</span>
<span>风险 中</span>
```

**Step 4: Run test to verify it passes**

Run: `npm --prefix apps/web-vue3 run build`
Expected: PASS

**Step 5: Commit**

```bash
git add apps/web-vue3/src/views/HomeView.vue apps/web-vue3/src/views/WatchlistView.vue apps/web-vue3/src/components/StockListItem.vue
git commit -m "feat: upgrade list summaries with evaluation cues"
```

### Task 8: 同步原生端数据契约

**Files:**
- Modify: `apps/ios-swiftui/StockAnalysisApp/Models/Stock.swift`
- Modify: `apps/flutter-app/lib/models/stock.dart`
- Modify: `shared/product-spec/stock-schema.json`

**Step 1: Write the failing test**

```text
验证共享 schema、SwiftUI 模型和 Flutter 模型都包含：
- rating
- confidence
- breakingNews
- sectorImpacts
```

**Step 2: Run test to verify it fails**

Run: `grep -R "rating\\|confidence\\|breakingNews\\|sectorImpacts" shared/product-spec apps/ios-swiftui apps/flutter-app`
Expected: FAIL because the native contracts are not updated yet

**Step 3: Write minimal implementation**

```swift
let rating: String
let confidence: String
```

```dart
final String rating;
final String confidence;
```

**Step 4: Run test to verify it passes**

Run: `swiftc -typecheck ...`
Expected: PASS for Swift after contract changes

**Step 5: Commit**

```bash
git add shared/product-spec/stock-schema.json apps/ios-swiftui/StockAnalysisApp/Models/Stock.swift apps/flutter-app/lib/models/stock.dart
git commit -m "feat: align native models with research-card contract"
```

### Task 9: 最终验证

**Files:**
- Modify: `README.md`

**Step 1: 补充升级说明**

```md
## Research Card Upgrade

- 评级与评价
- K线面板
- 突发消息高亮
- 板块影响标签
```

**Step 2: Run full verification**

Run: `pytest apps/backend-fastapi/tests -q`
Expected: PASS

Run: `npm --prefix apps/web-vue3 run build`
Expected: PASS

Run: `xcodebuild -project apps/ios-swiftui/StockAnalysisApp.xcodeproj -scheme StockAnalysisApp -destination 'generic/platform=iOS Simulator' -derivedDataPath .derivedData CODE_SIGNING_ALLOWED=NO build`
Expected: PASS

**Step 3: Commit**

```bash
git add README.md
git commit -m "docs: document research-card upgrade"
```
