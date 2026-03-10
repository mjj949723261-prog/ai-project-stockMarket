export type ScoreTrend = "up" | "flat" | "down";
export type ImpactValue = "positive" | "neutral" | "negative";
export type AlertLevel = "high" | "medium" | "low";
export type ConfidenceLevel = "high" | "medium" | "low";
export type InsightCategory = "company" | "sector" | "macro";

export type CandlePoint = {
  date: string;
  open: number;
  high: number;
  low: number;
  close: number;
};

export type BreakingNewsItem = {
  title: string;
  summary: string;
  sourceUrl: string;
  region: "domestic" | "global";
  impact: ImpactValue;
  level: AlertLevel;
  sectors: string[];
  source: string;
  publishedAt: string;
  scoreEffect: string;
};

export type SectorImpactItem = {
  sector: string;
  impact: ImpactValue;
  reason: string;
};

export type InsightItem = {
  title: string;
  summary: string;
  category: InsightCategory;
  sourceUrl: string;
  region: "domestic" | "global";
  urgency: AlertLevel;
  impact: ImpactValue;
  sectors: string[];
  source: string;
  publishedAt: string;
  scoreEffect: string;
};

export type SearchStock = {
  code: string;
  name: string;
  market: string;
  industry: string | null;
};

export type StockAnalysis = SearchStock & {
  latestPrice: number;
  changePercent: number;
  code: string;
  name: string;
  totalScore: number;
  fundamentalsScore: number;
  newsScore: number;
  technicalsScore: number;
  sentimentScore: number;
  rating: string;
  confidence: ConfidenceLevel;
  summaryComment: string;
  advice: string;
  highlightPoints: string[];
  riskPoints: string[];
  verdict: string;
  riskWarning: string;
  scoreTrend: ScoreTrend;
  scoreHistory: number[];
  candles: CandlePoint[];
  breakingNews: BreakingNewsItem[];
  sectorImpacts: SectorImpactItem[];
  insights: InsightItem[];
  fundamentalsReasons: string[];
  newsReasons: string[];
  technicalsReasons: string[];
  sentimentReasons: string[];
};

export type StockCard = SearchStock & Partial<StockAnalysis>;

export type DimensionKey =
  | "fundamentalsScore"
  | "newsScore"
  | "technicalsScore"
  | "sentimentScore";
