import { computed, ref, watch } from "vue";
import { stocks } from "../mock/stocks";

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

watch(
  watchlist,
  (value) => {
    if (typeof window !== "undefined") {
      window.localStorage.setItem(WATCHLIST_KEY, JSON.stringify(value));
    }
  },
  { deep: true }
);

export function useStocks() {
  const filteredStocks = computed(() => {
    const keyword = query.value.trim();
    if (!keyword) return stocks;

    return stocks.filter((stock) => {
      return stock.code.includes(keyword) || stock.name.includes(keyword);
    });
  });

  const watchlistStocks = computed(() =>
    stocks.filter((stock) => watchlist.value.includes(stock.code))
  );

  const setQuery = (value: string) => {
    query.value = value;
  };

  const toggleWatchlist = (code: string) => {
    watchlist.value = watchlist.value.includes(code)
      ? watchlist.value.filter((item) => item !== code)
      : [...watchlist.value, code];
  };

  const isWatched = (code: string) => watchlist.value.includes(code);

  const findStock = (code: string) => stocks.find((stock) => stock.code === code);

  const scoreDelta = (code: string) => {
    const stock = findStock(code);
    if (!stock || stock.scoreHistory.length < 2) return 0;

    const previous = stock.scoreHistory[stock.scoreHistory.length - 2];
    return stock.scoreHistory[stock.scoreHistory.length - 1] - previous;
  };

  return {
    query,
    filteredStocks,
    watchlistStocks,
    setQuery,
    toggleWatchlist,
    isWatched,
    findStock,
    scoreDelta
  };
}
