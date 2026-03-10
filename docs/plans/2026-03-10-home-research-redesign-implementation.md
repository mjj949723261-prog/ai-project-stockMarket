# Home Research Redesign Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Redesign the H5 home experience around search history, hot sector concepts, and in-app news detail pages while upgrading the visual language to a more modern financial product style.

**Architecture:** Replace the home page's candidate-stock block with a search-first research entry flow composed of search history, sector concept cards, and curated news cards. Add a dedicated news-detail route backed by structured news items so evidence cards can open inside the app before linking out to the original source.

**Tech Stack:** Vue 3, TypeScript, Vue Router, FastAPI payload reuse, local state persistence, CSS redesign

---

## 前提假设

- 当前后端 `analysis` 已返回 `breakingNews` 与 `insights`
- 当前 `Vue3 H5` 已有首页、个股详情页、自选页
- 当前页面视觉需要整体升级，而不是仅调整颜色
- 第一版板块概念可以先由本地 mock + 后端分析数据混合驱动

### Task 1: 为搜索记录写失败验证

**Files:**
- Modify: `apps/web-vue3/src/composables/useStocks.ts`
- Modify: `apps/web-vue3/src/views/HomeView.vue`

**Step 1: Write the failing expectation**

```ts
const SEARCH_HISTORY_KEY = "stock-analysis-search-history";
```

首页应能展示最近搜索词，并点击复用。

**Step 2: Run build to verify current behavior has no support**

Run: `npm --prefix apps/web-vue3 run build`
Expected: PASS but no search history implementation exists yet

**Step 3: Write minimal implementation**

```ts
const searchHistory = ref<string[]>([]);
function pushSearchHistory(value: string) {}
```

**Step 4: Run build to verify it passes**

Run: `npm --prefix apps/web-vue3 run build`
Expected: PASS

**Step 5: Commit**

```bash
git add apps/web-vue3/src/composables/useStocks.ts apps/web-vue3/src/views/HomeView.vue
git commit -m "feat: add search history to home page"
```

### Task 2: 为热门板块概念定义类型和 mock 数据

**Files:**
- Modify: `apps/web-vue3/src/types/stock.ts`
- Create: `apps/web-vue3/src/mock/sectors.ts`

**Step 1: Write the failing type expectation**

```ts
export type HotSector = {
  id: string;
  name: string;
  heat: "high" | "warming" | "diverging";
  status: string;
  stocks: Array<{ code: string; name: string; tag: string }>;
};
```

**Step 2: Run build to verify it fails if components reference missing type**

Run: `npm --prefix apps/web-vue3 run build`
Expected: FAIL after adding references without the type

**Step 3: Write minimal implementation**

```ts
export type HotSector = { ... };
```

**Step 4: Run build to verify it passes**

Run: `npm --prefix apps/web-vue3 run build`
Expected: PASS

**Step 5: Commit**

```bash
git add apps/web-vue3/src/types/stock.ts apps/web-vue3/src/mock/sectors.ts
git commit -m "feat: define hot sector concept data"
```

### Task 3: 新增热门板块概念卡组件

**Files:**
- Create: `apps/web-vue3/src/components/HotSectorCard.vue`
- Modify: `apps/web-vue3/src/style.css`

**Step 1: Write the failing UI expectation**

```vue
<HotSectorCard :sector="sector" />
```

组件需展示：

- 板块名
- 热度标签
- 一句状态
- 3 到 5 只代表股票

**Step 2: Run build to verify it fails**

Run: `npm --prefix apps/web-vue3 run build`
Expected: FAIL because component does not exist

**Step 3: Write minimal implementation**

```vue
<article class="sector-card">
  <h3>{{ sector.name }}</h3>
</article>
```

**Step 4: Run build to verify it passes**

Run: `npm --prefix apps/web-vue3 run build`
Expected: PASS

**Step 5: Commit**

```bash
git add apps/web-vue3/src/components/HotSectorCard.vue apps/web-vue3/src/style.css
git commit -m "feat: add hot sector concept cards"
```

### Task 4: 重构首页信息架构

**Files:**
- Modify: `apps/web-vue3/src/views/HomeView.vue`
- Modify: `apps/web-vue3/src/composables/useStocks.ts`

**Step 1: Write the failing UI expectation**

首页要包含：

- 搜索框
- 搜索记录
- 热门板块概念
- 热门资讯入口

并且不再显示“候选股票”标题。

**Step 2: Run build to verify current page does not match**

Run: `grep -n "候选股票" apps/web-vue3/src/views/HomeView.vue`
Expected: still present before implementation

**Step 3: Write minimal implementation**

```vue
<section class="home-layout">
  <SearchBar ... />
  <div class="history-row">...</div>
  <div class="sector-list">...</div>
  <div class="news-entry-list">...</div>
</section>
```

**Step 4: Run build to verify it passes**

Run: `npm --prefix apps/web-vue3 run build`
Expected: PASS

**Step 5: Commit**

```bash
git add apps/web-vue3/src/views/HomeView.vue apps/web-vue3/src/composables/useStocks.ts
git commit -m "feat: redesign home information architecture"
```

### Task 5: 新增资讯详情页路由和页面

**Files:**
- Create: `apps/web-vue3/src/views/NewsDetailView.vue`
- Modify: `apps/web-vue3/src/router/index.ts`
- Modify: `apps/web-vue3/src/types/stock.ts`

**Step 1: Write the failing UI expectation**

```ts
{
  path: "/news/:id",
  name: "news-detail",
  component: NewsDetailView
}
```

**Step 2: Run build to verify it fails**

Run: `npm --prefix apps/web-vue3 run build`
Expected: FAIL because the route/component does not exist

**Step 3: Write minimal implementation**

```vue
<template>
  <section class="panel">
    <h2>资讯详情</h2>
  </section>
</template>
```

**Step 4: Run build to verify it passes**

Run: `npm --prefix apps/web-vue3 run build`
Expected: PASS

**Step 5: Commit**

```bash
git add apps/web-vue3/src/views/NewsDetailView.vue apps/web-vue3/src/router/index.ts apps/web-vue3/src/types/stock.ts
git commit -m "feat: add in-app news detail route"
```

### Task 6: 让资讯证据卡点击进入站内详情

**Files:**
- Modify: `apps/web-vue3/src/components/InsightFeed.vue`
- Modify: `apps/web-vue3/src/components/BreakingNewsCard.vue`
- Modify: `apps/web-vue3/src/views/StockDetailView.vue`

**Step 1: Write the failing UI expectation**

资讯卡点击后应进入：

- `/news/:id`

而不是只显示原文链接。

**Step 2: Run build to verify current behavior lacks routing**

Run: `rg -n "sourceUrl|RouterLink|news-detail" apps/web-vue3/src/components apps/web-vue3/src/views`
Expected: no in-app news-detail navigation yet

**Step 3: Write minimal implementation**

```vue
<RouterLink :to="`/news/${item.id}`">...</RouterLink>
```

**Step 4: Run build to verify it passes**

Run: `npm --prefix apps/web-vue3 run build`
Expected: PASS

**Step 5: Commit**

```bash
git add apps/web-vue3/src/components/InsightFeed.vue apps/web-vue3/src/components/BreakingNewsCard.vue apps/web-vue3/src/views/StockDetailView.vue
git commit -m "feat: route evidence cards to news detail view"
```

### Task 7: 实现资讯详情页内容结构

**Files:**
- Modify: `apps/web-vue3/src/views/NewsDetailView.vue`
- Modify: `apps/web-vue3/src/composables/useStocks.ts`
- Modify: `apps/web-vue3/src/style.css`

**Step 1: Write the failing UI expectation**

资讯详情页要包含：

- 标题与来源
- 时间与区域
- 利好利空与影响等级
- 核心摘要
- 影响板块
- 关联股票
- 评分影响说明
- 原文入口

**Step 2: Run build to verify placeholder page lacks those sections**

Run: `grep -n "资讯详情\\|影响板块\\|查看原文" apps/web-vue3/src/views/NewsDetailView.vue`
Expected: missing most sections before implementation

**Step 3: Write minimal implementation**

```vue
<section class="news-detail">
  <header>...</header>
  <div class="impact-board">...</div>
</section>
```

**Step 4: Run build to verify it passes**

Run: `npm --prefix apps/web-vue3 run build`
Expected: PASS

**Step 5: Commit**

```bash
git add apps/web-vue3/src/views/NewsDetailView.vue apps/web-vue3/src/composables/useStocks.ts apps/web-vue3/src/style.css
git commit -m "feat: implement in-app news detail page"
```

### Task 8: 进行视觉重设计

**Files:**
- Modify: `apps/web-vue3/src/style.css`
- Modify: `apps/web-vue3/src/App.vue`
- Modify: `apps/web-vue3/src/views/HomeView.vue`
- Modify: `apps/web-vue3/src/views/NewsDetailView.vue`

**Step 1: Write the failing visual checklist**

视觉目标：

- 不再使用旧式暖棕金融感作为主基调
- 首页第一屏节奏更强
- 卡片更现代、更清晰
- 资讯详情页与首页视觉统一

**Step 2: Run build and capture current baseline**

Run: `npm --prefix apps/web-vue3 run build`
Expected: PASS; current styles still reflect old theme

**Step 3: Write minimal implementation**

```css
:root {
  --bg: ...;
  --surface: ...;
  --accent: ...;
}
```

逐步重写首页与资讯详情页核心样式。

**Step 4: Run build to verify it passes**

Run: `npm --prefix apps/web-vue3 run build`
Expected: PASS

**Step 5: Commit**

```bash
git add apps/web-vue3/src/style.css apps/web-vue3/src/App.vue apps/web-vue3/src/views/HomeView.vue apps/web-vue3/src/views/NewsDetailView.vue
git commit -m "feat: redesign home and news visuals"
```

### Task 9: 完整验证并提交

**Files:**
- Verify: `apps/web-vue3`

**Step 1: Run frontend build**

Run: `npm --prefix apps/web-vue3 run build`
Expected: PASS

**Step 2: Run backend tests if shared news types changed**

Run: `. .venv/bin/activate && pytest tests/test_routes.py tests/test_scoring_engine.py tests/test_news_classifier.py -q`
Expected: PASS

**Step 3: Check git status**

Run: `git status --short`
Expected: only intended files changed

**Step 4: Commit**

```bash
git add .
git commit -m "feat: redesign home and add news detail flow"
```
