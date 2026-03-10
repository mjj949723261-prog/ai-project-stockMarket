import Foundation

enum ScoreTrend: String, CaseIterable, Codable {
    case up
    case flat
    case down
}

enum SectorHeat: String, CaseIterable, Codable {
    case high
    case warming
    case diverging
}

enum NewsImpact: String, CaseIterable, Codable {
    case positive
    case neutral
    case negative
}

enum NewsUrgency: String, CaseIterable, Codable {
    case high
    case medium
    case low
}

enum NewsRegion: String, CaseIterable, Codable {
    case domestic
    case global
}

struct Stock: Identifiable, Codable, Hashable {
    var id: String { code }

    let code: String
    let name: String
    let totalScore: Int
    let fundamentalsScore: Int
    let newsScore: Int
    let technicalsScore: Int
    let sentimentScore: Int
    let verdict: String
    let riskWarning: String
    let scoreTrend: ScoreTrend
    let fundamentalsReasons: [String]
    let newsReasons: [String]
    let technicalsReasons: [String]
    let sentimentReasons: [String]
}

struct SectorStock: Identifiable, Hashable {
    var id: String { code }

    let code: String
    let name: String
    let tag: String
}

struct HotSector: Identifiable, Hashable {
    let id: String
    let name: String
    let aliases: [String]
    let heat: SectorHeat
    let status: String
    let summary: String
    let highlights: [String]
    let stocks: [SectorStock]
}

struct NewsEntry: Identifiable, Hashable {
    let id: String
    let title: String
    let summary: String
    let source: String
    let sourceURL: String
    let publishedAt: String
    let region: NewsRegion
    let impact: NewsImpact
    let urgency: NewsUrgency
    let sectors: [String]
    let scoreEffect: String
    let stockCode: String?
    let stockName: String?
}
