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

function dynamicSectorId(name: string) {
  return `dynamic~${encodeURIComponent(name.trim())}`;
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
    id: newsId([item.source, item.publishedAt, item.title]),
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
    stockCode: item.region === "domestic" ? stock.code : null,
    stockName: item.region === "domestic" ? stock.name : null
  };
}

function enrichInsight(stock: StockAnalysis, item: InsightItem): NewsEntry {
  return {
    id: newsId([item.source, item.publishedAt, item.title]),
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
    stockCode: item.category === "company" ? stock.code : null,
    stockName: item.category === "company" ? stock.name : null
  };
}

function mergeNewsEntry(current: NewsEntry, incoming: NewsEntry): NewsEntry {
  const sectors = [...new Set([...current.sectors, ...incoming.sectors])];
  const stockConflict =
    current.stockCode &&
    incoming.stockCode &&
    current.stockCode !== incoming.stockCode;

  return {
    ...current,
    sectors,
    stockCode: stockConflict ? null : current.stockCode ?? incoming.stockCode,
    stockName: stockConflict ? null : current.stockName ?? incoming.stockName
  };
}

function buildCuratedNews(analysisMap: Record<string, StockAnalysis>) {
  const perStock = Object.values(analysisMap).map((stock) => [
    ...stock.breakingNews.map((item) => enrichBreakingNews(stock, item)),
    ...stock.insights.map((item) => enrichInsight(stock, item))
  ]);

  const deduped = new Map<string, NewsEntry>();
  const cursors = perStock.map(() => 0);
  const result: NewsEntry[] = [];
  let progress = true;

  while (result.length < 6 && progress) {
    progress = false;

    perStock.forEach((items, index) => {
      while (cursors[index] < items.length) {
        const item = items[cursors[index]];
        cursors[index] += 1;

        if (!deduped.has(item.id)) {
          deduped.set(item.id, item);
          result.push(item);
          progress = true;
          break;
        }

        deduped.set(item.id, mergeNewsEntry(deduped.get(item.id) as NewsEntry, item));
      }
    });
  }

  return result.map((item) => deduped.get(item.id) ?? item);
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
    return buildCuratedNews(analyses.value);
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

  const hotStocks = computed<StockCard[]>(() => {
    const codes = hotSectors.flatMap((sector) => sector.stocks.map((stock) => stock.code));
    const uniqueCodes = [...new Set(codes)];

    return uniqueCodes.map((code) => {
      const analysis = analyses.value[code];
      if (analysis) return analysis;

      const sectorStock = hotSectors.flatMap((sector) => sector.stocks).find((item) => item.code === code);
      return {
        code,
        name: sectorStock?.name ?? code,
        market: "A-share",
        industry: null
      };
    });
  });

  const getSectorById = (id: string) => {
    const staticSector = hotSectors.find((sector) => sector.id === id);
    if (staticSector) return staticSector;

    if (id.startsWith("dynamic~")) {
      const name = decodeURIComponent(id.replace("dynamic~", ""));
      return {
        id,
        name,
        heat: "diverging" as const,
        status: `${name} 当前更多受消息面驱动，适合先看关联股票再决定是否继续跟踪。`,
        summary: `这是从资讯中动态生成的板块页，优先帮你把 ${name} 对应的相关股票聚合出来。`,
        highlights: ["资讯驱动", "动态生成", "继续跟踪"],
        stocks: getSectorStocks(id).map((stock) => ({
          code: stock.code,
          name: stock.name,
          tag: stock.totalScore ? `${stock.totalScore} 分` : "观察"
        }))
      };
    }

    return null;
  };

  const findSectorIdByName = (name: string) => {
    const normalized = name.trim();
    if (!normalized) return null;

    const matched = hotSectors.find((sector) => {
      const candidates = [sector.name, ...(sector.aliases ?? [])];
      return candidates.some((candidate) => candidate === normalized || candidate.includes(normalized) || normalized.includes(candidate));
    });

    return matched?.id ?? dynamicSectorId(normalized);
  };

  const getSectorStocks = (id: string): StockCard[] => {
    const sector = hotSectors.find((item) => item.id === id);
    if (sector) {
      return sector.stocks.map((stock) => analyses.value[stock.code] ?? {
        code: stock.code,
        name: stock.name,
        market: "A-share",
        industry: null
      });
    }

    if (id.startsWith("dynamic~")) {
      const name = decodeURIComponent(id.replace("dynamic~", ""));
      return Object.values(analyses.value).filter((stock) => {
        const inIndustry = stock.industry?.includes(name);
        const inNews = [...stock.breakingNews, ...stock.insights].some((item) => item.sectors.includes(name));
        return Boolean(inIndustry || inNews);
      });
    }

    return [];
  };

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
    hotStocks,
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
    getNewsById,
    getSectorById,
    getSectorStocks,
    findSectorIdByName
  };
}
