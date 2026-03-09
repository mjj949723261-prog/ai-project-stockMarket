import { computed, ref, watch } from "vue";
import { fetchStockAnalysis, fetchStockSearch } from "../api/stocks";
import type { SearchStock, StockAnalysis, StockCard } from "../types/stock";

const WATCHLIST_KEY = "stock-analysis-watchlist";
const initialWatchlist = (() => {
  if (typeof window === "undefined") return ["600519"];

  const raw = window.localStorage.getItem(WATCHLIST_KEY);
  if (!raw) return ["600519"];

  try {
    const parsed = JSON.parse(raw);
    return Array.isArray(parsed) ? parsed.filter((item): item is string => typeof item === "string") : ["600519"];
  } catch {
    return ["600519"];
  }
})();

const watchlist = ref<string[]>(initialWatchlist);
const query = ref("");
const searchResults = ref<SearchStock[]>([]);
const analyses = ref<Record<string, StockAnalysis>>({});
const isSearching = ref(false);
const searchError = ref("");

watch(
  watchlist,
  (value) => {
    if (typeof window !== "undefined") {
      window.localStorage.setItem(WATCHLIST_KEY, JSON.stringify(value));
    }
  },
  { deep: true }
);

async function ensureAnalysis(code: string) {
  if (analyses.value[code]) return analyses.value[code];

  const result = await fetchStockAnalysis(code);
  analyses.value = {
    ...analyses.value,
    [code]: result,
  };
  return result;
}

async function refreshSearch() {
  isSearching.value = true;
  searchError.value = "";

  try {
    const results = await fetchStockSearch(query.value.trim());
    searchResults.value = results;

    // 首页只预取前几个候选的分析结果，避免一次把搜索接口拖成全量分析接口。
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

export function useStocks() {
  const filteredStocks = computed<StockCard[]>(() =>
    searchResults.value.map((stock) => ({
      ...stock,
      ...analyses.value[stock.code],
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
        industry: null,
      };
    })
  );

  const setQuery = (value: string) => {
    query.value = value;
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
      return await ensureAnalysis(code);
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

  return {
    query,
    filteredStocks,
    watchlistStocks,
    isSearching,
    searchError,
    setQuery,
    toggleWatchlist,
    isWatched,
    findStock,
    scoreDelta,
    ensureAnalysis,
  };
}
