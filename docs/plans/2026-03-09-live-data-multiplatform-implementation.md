# 股市资讯 App 真实数据接入实现计划

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 为三端股市资讯 App 建立统一的真实数据后端，接入 `AKShare` 和 `Tushare`，输出内部统一 API，并逐步替换 `Vue3 H5`、`SwiftUI`、`Flutter` 的 mock 数据来源。

**Architecture:** 新增一个 `Python + FastAPI` 后端作为聚合与评分服务，封装 `AKShare` 和 `Tushare`，通过缓存保护免费数据源，并对外提供统一的 `search / quote / fundamentals / analysis` 接口。三端优先改造为调用 `search` 和 `analysis`，其余接口逐步接入。

**Tech Stack:** Python、FastAPI、Uvicorn、AKShare、Tushare、Pydantic、pytest、Vue 3、SwiftUI、Flutter

---

## 前提假设

- 当前三端都还在使用本地 mock 数据。
- 真实数据改造必须保证三端继续共享同一份产品协议。
- 第一阶段先把 `Vue3 H5` 接到真实后端，`SwiftUI` 和 `Flutter` 先改造数据层接口。
- 当前机器未安装 Flutter SDK，因此 Flutter 运行验证只能后置。

### Task 1: 初始化后端目录

**Files:**
- Create: `apps/backend-fastapi/pyproject.toml`
- Create: `apps/backend-fastapi/app/main.py`
- Create: `apps/backend-fastapi/app/__init__.py`
- Create: `apps/backend-fastapi/README.md`

**Step 1: Write the failing test**

```text
验证后端目录存在可启动的 FastAPI 入口文件。
```

**Step 2: Run test to verify it fails**

Run: `find apps/backend-fastapi -maxdepth 2 -type f`
Expected: FAIL because the backend app does not exist yet

**Step 3: Write minimal implementation**

```python
from fastapi import FastAPI

app = FastAPI(title="Stock Analysis Backend")

@app.get("/health")
def health():
    return {"ok": True}
```

**Step 4: Run test to verify it passes**

Run: `uvicorn app.main:app --reload`
Expected: server starts and `/health` returns `{"ok": true}`

**Step 5: Commit**

```bash
git add apps/backend-fastapi
git commit -m "chore: scaffold fastapi backend"
```

### Task 2: 定义后端统一模型

**Files:**
- Create: `apps/backend-fastapi/app/models/stock.py`
- Create: `apps/backend-fastapi/app/models/analysis.py`
- Test: `apps/backend-fastapi/tests/test_models.py`

**Step 1: Write the failing test**

```python
from app.models.analysis import StockAnalysis

def test_stock_analysis_model_accepts_core_fields():
    model = StockAnalysis(
        code="600519",
        name="贵州茅台",
        total_score=82,
        verdict="继续跟踪"
    )
    assert model.code == "600519"
```

**Step 2: Run test to verify it fails**

Run: `pytest apps/backend-fastapi/tests/test_models.py -v`
Expected: FAIL because model files do not exist

**Step 3: Write minimal implementation**

```python
from pydantic import BaseModel

class StockAnalysis(BaseModel):
    code: str
    name: str
    total_score: int
    verdict: str
```

**Step 4: Run test to verify it passes**

Run: `pytest apps/backend-fastapi/tests/test_models.py -v`
Expected: PASS

**Step 5: Commit**

```bash
git add apps/backend-fastapi/app/models apps/backend-fastapi/tests/test_models.py
git commit -m "feat: add backend domain models"
```

### Task 3: 接入 AKShare Provider

**Files:**
- Create: `apps/backend-fastapi/app/providers/akshare_provider.py`
- Test: `apps/backend-fastapi/tests/test_akshare_provider.py`

**Step 1: Write the failing test**

```python
from app.providers.akshare_provider import AkshareProvider

def test_provider_exposes_search_method():
    provider = AkshareProvider()
    assert hasattr(provider, "search_stocks")
```

**Step 2: Run test to verify it fails**

Run: `pytest apps/backend-fastapi/tests/test_akshare_provider.py -v`
Expected: FAIL because provider module does not exist

**Step 3: Write minimal implementation**

```python
class AkshareProvider:
    def search_stocks(self, query: str):
        return []
```

**Step 4: Run test to verify it passes**

Run: `pytest apps/backend-fastapi/tests/test_akshare_provider.py -v`
Expected: PASS

**Step 5: Commit**

```bash
git add apps/backend-fastapi/app/providers apps/backend-fastapi/tests/test_akshare_provider.py
git commit -m "feat: add akshare provider skeleton"
```

### Task 4: 接入 Tushare Provider

**Files:**
- Create: `apps/backend-fastapi/app/providers/tushare_provider.py`
- Create: `apps/backend-fastapi/app/core/settings.py`
- Test: `apps/backend-fastapi/tests/test_tushare_provider.py`

**Step 1: Write the failing test**

```python
from app.providers.tushare_provider import TushareProvider

def test_provider_exposes_fundamentals_method():
    provider = TushareProvider(token="demo")
    assert hasattr(provider, "get_fundamentals")
```

**Step 2: Run test to verify it fails**

Run: `pytest apps/backend-fastapi/tests/test_tushare_provider.py -v`
Expected: FAIL because provider module does not exist

**Step 3: Write minimal implementation**

```python
class TushareProvider:
    def __init__(self, token: str):
        self.token = token

    def get_fundamentals(self, code: str):
        return {}
```

**Step 4: Run test to verify it passes**

Run: `pytest apps/backend-fastapi/tests/test_tushare_provider.py -v`
Expected: PASS

**Step 5: Commit**

```bash
git add apps/backend-fastapi/app/providers/tushare_provider.py apps/backend-fastapi/app/core/settings.py apps/backend-fastapi/tests/test_tushare_provider.py
git commit -m "feat: add tushare provider skeleton"
```

### Task 5: 建立统一映射层

**Files:**
- Create: `apps/backend-fastapi/app/mappers/stock_mapper.py`
- Create: `apps/backend-fastapi/app/mappers/analysis_mapper.py`
- Test: `apps/backend-fastapi/tests/test_mappers.py`

**Step 1: Write the failing test**

```python
from app.mappers.stock_mapper import map_search_result

def test_map_search_result_normalizes_fields():
    raw = {"symbol": "600519", "name": "贵州茅台"}
    result = map_search_result(raw)
    assert result["code"] == "600519"
```

**Step 2: Run test to verify it fails**

Run: `pytest apps/backend-fastapi/tests/test_mappers.py -v`
Expected: FAIL because mapper module does not exist

**Step 3: Write minimal implementation**

```python
def map_search_result(raw: dict) -> dict:
    return {
        "code": raw.get("symbol", ""),
        "name": raw.get("name", ""),
    }
```

**Step 4: Run test to verify it passes**

Run: `pytest apps/backend-fastapi/tests/test_mappers.py -v`
Expected: PASS

**Step 5: Commit**

```bash
git add apps/backend-fastapi/app/mappers apps/backend-fastapi/tests/test_mappers.py
git commit -m "feat: add backend mapper layer"
```

### Task 6: 实现评分引擎

**Files:**
- Create: `apps/backend-fastapi/app/scoring/rules.py`
- Create: `apps/backend-fastapi/app/scoring/engine.py`
- Test: `apps/backend-fastapi/tests/test_scoring_engine.py`

**Step 1: Write the failing test**

```python
from app.scoring.engine import score_analysis

def test_score_analysis_returns_total_and_dimensions():
    result = score_analysis(
        fundamentals={"revenue_growth": 0.15, "profit_growth": 0.13},
        news=[],
        quote={},
        sentiment={}
    )
    assert "total_score" in result
    assert "fundamentals_score" in result
```

**Step 2: Run test to verify it fails**

Run: `pytest apps/backend-fastapi/tests/test_scoring_engine.py -v`
Expected: FAIL because scoring module does not exist

**Step 3: Write minimal implementation**

```python
def score_analysis(fundamentals: dict, news: list, quote: dict, sentiment: dict):
    return {
        "total_score": 75,
        "fundamentals_score": 28,
        "news_score": 18,
        "technicals_score": 16,
        "sentiment_score": 13,
    }
```

**Step 4: Run test to verify it passes**

Run: `pytest apps/backend-fastapi/tests/test_scoring_engine.py -v`
Expected: PASS

**Step 5: Commit**

```bash
git add apps/backend-fastapi/app/scoring apps/backend-fastapi/tests/test_scoring_engine.py
git commit -m "feat: add backend scoring engine"
```

### Task 7: 实现缓存层

**Files:**
- Create: `apps/backend-fastapi/app/cache/memory_cache.py`
- Test: `apps/backend-fastapi/tests/test_memory_cache.py`

**Step 1: Write the failing test**

```python
from app.cache.memory_cache import MemoryCache

def test_cache_round_trip():
    cache = MemoryCache()
    cache.set("k", {"value": 1}, ttl_seconds=60)
    assert cache.get("k") == {"value": 1}
```

**Step 2: Run test to verify it fails**

Run: `pytest apps/backend-fastapi/tests/test_memory_cache.py -v`
Expected: FAIL because cache module does not exist

**Step 3: Write minimal implementation**

```python
import time

class MemoryCache:
    def __init__(self):
        self._values = {}

    def set(self, key, value, ttl_seconds):
        self._values[key] = (value, time.time() + ttl_seconds)

    def get(self, key):
        item = self._values.get(key)
        if not item:
            return None
        value, expires_at = item
        if time.time() > expires_at:
            return None
        return value
```

**Step 4: Run test to verify it passes**

Run: `pytest apps/backend-fastapi/tests/test_memory_cache.py -v`
Expected: PASS

**Step 5: Commit**

```bash
git add apps/backend-fastapi/app/cache apps/backend-fastapi/tests/test_memory_cache.py
git commit -m "feat: add backend cache layer"
```

### Task 8: 实现 `search` 与 `analysis` 路由

**Files:**
- Create: `apps/backend-fastapi/app/routes/stocks.py`
- Modify: `apps/backend-fastapi/app/main.py`
- Test: `apps/backend-fastapi/tests/test_routes.py`

**Step 1: Write the failing test**

```python
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_search_route_exists():
    response = client.get("/api/stocks/search?q=茅台")
    assert response.status_code == 200
```

**Step 2: Run test to verify it fails**

Run: `pytest apps/backend-fastapi/tests/test_routes.py -v`
Expected: FAIL because routes do not exist

**Step 3: Write minimal implementation**

```python
from fastapi import APIRouter

router = APIRouter(prefix="/api/stocks")

@router.get("/search")
def search_stocks(q: str):
    return []

@router.get("/{code}/analysis")
def get_analysis(code: str):
    return {"code": code}
```

**Step 4: Run test to verify it passes**

Run: `pytest apps/backend-fastapi/tests/test_routes.py -v`
Expected: PASS

**Step 5: Commit**

```bash
git add apps/backend-fastapi/app/routes apps/backend-fastapi/app/main.py apps/backend-fastapi/tests/test_routes.py
git commit -m "feat: add backend search and analysis routes"
```

### Task 9: 把 Vue3 H5 切到真实接口

**Files:**
- Create: `apps/web-vue3/src/api/client.ts`
- Create: `apps/web-vue3/src/api/stocks.ts`
- Modify: `apps/web-vue3/src/composables/useStocks.ts`
- Modify: `apps/web-vue3/src/views/HomeView.vue`
- Modify: `apps/web-vue3/src/views/StockDetailView.vue`

**Step 1: Write the failing test**

```text
验证 `Vue3` 数据来源不再直接依赖 `src/mock/stocks.ts`。
```

**Step 2: Run test to verify it fails**

Run: `grep -R \"src/mock/stocks\\|../mock/stocks\" apps/web-vue3/src`
Expected: FAIL because the Vue app still reads local mock data

**Step 3: Write minimal implementation**

```ts
export async function fetchStockSearch(query: string) {
  const response = await fetch(`/api/stocks/search?q=${encodeURIComponent(query)}`);
  return response.json();
}
```

**Step 4: Run test to verify it passes**

Run: `npm --prefix apps/web-vue3 run build`
Expected: PASS with the Vue app using backend API calls

**Step 5: Commit**

```bash
git add apps/web-vue3/src/api apps/web-vue3/src/composables/useStocks.ts apps/web-vue3/src/views
git commit -m "feat: connect vue3 app to live backend api"
```

### Task 10: 为 SwiftUI 和 Flutter 改造数据层接口

**Files:**
- Modify: `apps/ios-swiftui/StockAnalysisApp/ViewModels/StockRepository.swift`
- Modify: `apps/flutter-app/lib/view_models/stock_repository.dart`
- Modify: `apps/ios-swiftui/README.md`
- Modify: `README.md`

**Step 1: Write the failing test**

```text
验证 `SwiftUI` 和 `Flutter` 的 repository 不再只描述本地 mock 仓储。
```

**Step 2: Run test to verify it fails**

Run: `grep -R \"MockStocks\\|mock_stocks\" apps/ios-swiftui apps/flutter-app`
Expected: FAIL because the native clients still point only to local mocks

**Step 3: Write minimal implementation**

```swift
struct StockRepository {
    let baseURL: URL
}
```

```dart
class StockRepository {
  const StockRepository({required this.baseUrl});
  final String baseUrl;
}
```

**Step 4: Run test to verify it passes**

Run: `swiftc -typecheck ...`
Expected: PASS for Swift after repository signature changes

**Step 5: Commit**

```bash
git add apps/ios-swiftui/StockAnalysisApp/ViewModels/StockRepository.swift apps/flutter-app/lib/view_models/stock_repository.dart apps/ios-swiftui/README.md README.md
git commit -m "refactor: prepare native clients for backend api"
```

### Task 11: 最终验证

**Files:**
- Modify: `README.md`

**Step 1: 补充真实数据启动说明**

```md
## 真实数据开发

- 启动后端：`uvicorn app.main:app --reload`
- 启动 H5：`npm --prefix apps/web-vue3 run dev`
- iOS/Flutter 使用统一后端地址
```

**Step 2: Run full verification**

Run: `pytest apps/backend-fastapi/tests -v`
Expected: PASS

Run: `npm --prefix apps/web-vue3 run build`
Expected: PASS

Run: `xcodebuild -project apps/ios-swiftui/StockAnalysisApp.xcodeproj -scheme StockAnalysisApp -destination 'generic/platform=iOS Simulator' -derivedDataPath .derivedData CODE_SIGNING_ALLOWED=NO build`
Expected: PASS

**Step 3: Commit**

```bash
git add README.md
git commit -m "docs: add live data workflow guidance"
```
