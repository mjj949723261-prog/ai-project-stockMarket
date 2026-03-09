import Foundation

enum ScoreTrend: String, CaseIterable, Codable {
    case up
    case flat
    case down
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

