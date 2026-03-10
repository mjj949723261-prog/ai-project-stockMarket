import { computed, ref, watch } from "vue";
import { fetchStockAnalysis, fetchStockSearch } from "../api/stocks";
import { hotSectors } from "../mock/sectors";
import type {
  BreakingNewsItem,
  HotSector,
  InsightItem,
  NewsEntry,
  SearchStock,
  StockAnalysis,
  StockCard
} from "../types/stock";

const WATCHLIST_KEY = "stock-analysis-watchlist";
const SEARCH_HISTORY_KEY = "stock-analysis-search-history";

function readStringList(key: string, fallback: string[]) {
  if (typeof window === "undefined") return fallback;

  const raw = window.localStorage.getItem(key);
  if (!raw) return fallback;

  try {
    const parsed = JSON.parse(raw);
    return Array.isArray(parsed)
      ? parsed.filter((item): item is string => typeof item === "string")
      : fallback;
  } catch {
    return fallback;
  }
}

function persistStringList(key: string, value: string[]) {
  if (typeof window !== "undefined") {
    window.localStorage.setItem(key, JSON.stringify(value));
  }
}

function newsId(parts: string[]) {
  return parts
    .join("-")
    .toLowerCase()
    .replace(/[^a-z0-9\u4e00-\u9fa5]+/g, "-")
    .replace(/^-+|-+$/g, "");
}

function normalizeAnalysis(result: StockAnalysis): StockAnalysis {
  return {
    ...result,
    breakingNews: result.breakingNews.map((item) => ({
      ...item,
      id: newsId([result.code, item.publishedAt, item.title])
    })),
    insights: result.insights.map((item) => ({
      ...item,
      id: newsId([result.code, item.publishedAt, item.title])
    }))
  };
}

const watchlist = ref<string[]>(readStringList(WATCHLIST_KEY, ["600519"]));
const searchHistory = ref<string[]>(readStringList(SEARCH_HISTORY_KEY, ["贵州茅台", "算力"]));
const query = ref("");
const searchResults = ref<SearchStock[]>([]);
const analyses = ref<Record<string, StockAnalysis>>({});
const isSearching = ref(false);
const searchError = ref("");

watch(
  watchlist,
  (value) => {
    persistStringList(WATCHLIST_KEY, value);
  },
  { deep: true }
);

watch(
  searchHistory,
  (value) => {
    persistStringList(SEARCH_HISTORY_KEY, value);
  },
  { deep: true }
);

function rememberSearchTerm(value: string) {
  const normalized = value.trim();
  if (!normalized) return;

  searchHistory.value = [
    normalized,
    ...searchHistory.value.filter((item) => item !== normalized)
  ].slice(0, 8);
}

function enrichBreakingNews(stock: StockAnalysis, item: BreakingNewsItem): NewsEntry {
  return {
    id: newsId([stock.code, item.publishedAt, item.title]),
    title: item.title,
    summary: item.summary,
    source: item.source,
    sourceUrl: item.sourceUrl,
    publishedAt: item.publishedAt,
    region: item.region,
    impact: item.impact,
    urgency: item.level,
    sectors: item.sectors,
    scoreEffect: item.scoreEffect,
    category: "macro",
    stockCode: stock.code,
    stockName: stock.name
  };
}

function enrichInsight(stock: StockAnalysis, item: InsightItem): NewsEntry {
  return {
    id: newsId([stock.code, item.publishedAt, item.title]),
    title: item.title,
    summary: item.summary,
    source: item.source,
    sourceUrl: item.sourceUrl,
    publishedAt: item.publishedAt,
    region: item.region,
    impact: item.impact,
    urgency: item.urgency,
    sectors: item.sectors,
    scoreEffect: item.scoreEffect,
    category: item.category,
    stockCode: stock.code,
    stockName: stock.name
  };
}

async function ensureAnalysis(code: string) {
  if (analyses.value[code]) return analyses.value[code];

  const result = normalizeAnalysis(await fetchStockAnalysis(code));
  analyses.value = {
    ...analyses.value,
    [code]: result
  };
  return result;
}

async function ensureSectorCoverage() {
  const codes = hotSectors.flatMap((sector) => sector.stocks.map((item) => item.code));
  const uniqueCodes = [...new Set(codes)];
  await Promise.all(uniqueCodes.map((code) => ensureAnalysis(code).catch(() => null)));
}

async function refreshSearch() {
  isSearching.value = true;
  searchError.value = "";

  try {
    const results = await fetchStockSearch(query.value.trim());
    searchResults.value = results;
    await Promise.all(results.slice(0, 3).map((stock) => ensureAnalysis(stock.code)));
  } catch (error) {
    searchError.value = error instanceof Error ? error.message : "搜索失败";
    searchResults.value = [];
  } finally {
    isSearching.value = false;
  }
}

watch(query, () => {
  void refreshSearch();
});

void refreshSearch();
void ensureSectorCoverage();

export function useStocks() {
  const filteredStocks = computed<StockCard[]>(() =>
    searchResults.value.map((stock) => ({
      ...stock,
      ...analyses.value[stock.code]
    }))
  );

  const watchlistStocks = computed<StockCard[]>(() =>
    watchlist.value.map((code) => {
      const analysis = analyses.value[code];
      if (analysis) return analysis;

      const searchResult = searchResults.value.find((item) => item.code === code);
      if (searchResult) return searchResult;

      return {
        code,
        name: code,
        market: "A-share",
        industry: null
      };
    })
  );

  const curatedNews = computed<NewsEntry[]>(() => {
    const items = Object.values(analyses.value).flatMap((stock) => [
      ...stock.breakingNews.map((item) => enrichBreakingNews(stock, item)),
      ...stock.insights.map((item) => enrichInsight(stock, item))
    ]);

    const deduped = new Map<string, NewsEntry>();
    items.forEach((item) => {
      if (!deduped.has(item.id)) deduped.set(item.id, item);
    });
    return [...deduped.values()].slice(0, 6);
  });

  const hotSectorCards = computed<HotSector[]>(() =>
    hotSectors.map((sector) => ({
      ...sector,
      stocks: sector.stocks.map((stock) => ({
        ...stock,
        name: analyses.value[stock.code]?.name ?? stock.name
      }))
    }))
  );

  const setQuery = (value: string) => {
    query.value = value;
  };

  const applySearchHistory = (value: string) => {
    query.value = value;
    rememberSearchTerm(value);
  };

  const toggleWatchlist = (code: string) => {
    watchlist.value = watchlist.value.includes(code)
      ? watchlist.value.filter((item) => item !== code)
      : [...watchlist.value, code];

    if (watchlist.value.includes(code)) {
      void ensureAnalysis(code);
    }
  };

  const isWatched = (code: string) => watchlist.value.includes(code);

  const findStock = async (code: string) => {
    try {
      const stock = await ensureAnalysis(code);
      rememberSearchTerm(stock.name);
      return stock;
    } catch {
      return analyses.value[code] ?? null;
    }
  };

  const scoreDelta = (code: string) => {
    const stock = analyses.value[code];
    if (!stock || stock.scoreHistory.length < 2) return 0;

    const previous = stock.scoreHistory[stock.scoreHistory.length - 2];
    return stock.scoreHistory[stock.scoreHistory.length - 1] - previous;
  };

  const getNewsById = (id: string) => curatedNews.value.find((item) => item.id === id) ?? null;

  return {
    query,
    filteredStocks,
    watchlistStocks,
    curatedNews,
    hotSectorCards,
    searchHistory,
    isSearching,
    searchError,
    setQuery,
    applySearchHistory,
    rememberSearchTerm,
    toggleWatchlist,
    isWatched,
    findStock,
    scoreDelta,
    ensureAnalysis,
    getNewsById
  };
}
