import { apiGet } from "./client";
import type { SearchStock, StockAnalysis } from "../types/stock";

export function fetchStockSearch(query: string) {
  return apiGet<SearchStock[]>(`/api/stocks/search?q=${encodeURIComponent(query)}`);
}

export function fetchStockAnalysis(code: string) {
  return apiGet<StockAnalysis>(`/api/stocks/${encodeURIComponent(code)}/analysis`);
}

