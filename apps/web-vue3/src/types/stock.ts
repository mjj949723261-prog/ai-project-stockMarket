export type ScoreTrend = "up" | "flat" | "down";

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
  verdict: string;
  riskWarning: string;
  scoreTrend: ScoreTrend;
  scoreHistory: number[];
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
