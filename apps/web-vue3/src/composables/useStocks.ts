import { computed, ref } from "vue";
import { stocks } from "../mock/stocks";

const watchlist = ref<string[]>(["600519"]);
const query = ref("");

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

  return {
    query,
    filteredStocks,
    watchlistStocks,
    setQuery,
    toggleWatchlist,
    isWatched,
    findStock
  };
}

