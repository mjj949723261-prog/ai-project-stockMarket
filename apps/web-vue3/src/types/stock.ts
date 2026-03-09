export type ScoreTrend = "up" | "flat" | "down";

export type StockAnalysis = {
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
  fundamentalsReasons: string[];
  newsReasons: string[];
  technicalsReasons: string[];
  sentimentReasons: string[];
};

export type DimensionKey =
  | "fundamentalsScore"
  | "newsScore"
  | "technicalsScore"
  | "sentimentScore";

