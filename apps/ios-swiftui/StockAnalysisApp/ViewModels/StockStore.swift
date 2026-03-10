import Foundation
import SwiftUI

@MainActor
final class StockStore: ObservableObject {
    @Published var query = ""
    @Published var watchlist: Set<String> = ["600519", "300308"]
    @Published var searchHistory: [String] = ["贵州茅台", "算力", "房地产开发"]

    private let repository = StockRepository()

    var stocks: [Stock] {
        repository.loadStocks()
    }

    var sectors: [HotSector] {
        repository.loadSectors()
    }

    var newsEntries: [NewsEntry] {
        repository.loadNews()
    }

    var filteredStocks: [Stock] {
        let keyword = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !keyword.isEmpty else { return [] }

        return stocks.filter { stock in
            stock.code.contains(keyword) || stock.name.contains(keyword)
        }
    }

    var watchlistStocks: [Stock] {
        stocks.filter { watchlist.contains($0.code) }
    }

    var hotStocks: [Stock] {
        let codes = sectors.flatMap(\.stocks).map(\.code)
        let uniqueCodes = Array(Set(codes))
        return stocks.filter { uniqueCodes.contains($0.code) }
            .sorted { $0.totalScore > $1.totalScore }
    }

    func toggleWatchlist(code: String) {
        if watchlist.contains(code) {
            watchlist.remove(code)
        } else {
            watchlist.insert(code)
        }
    }

    func applySearchHistory(_ value: String) {
        query = value
        rememberSearch(value)
    }

    func rememberSearch(_ value: String) {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        searchHistory = [trimmed] + searchHistory.filter { $0 != trimmed }
        searchHistory = Array(searchHistory.prefix(8))
    }

    func stock(code: String) -> Stock? {
        stocks.first { $0.code == code }
    }

    func sector(id: String) -> HotSector? {
        if let staticSector = sectors.first(where: { $0.id == id }) {
            return staticSector
        }

        guard id.hasPrefix("dynamic~") else { return nil }
        let name = String(id.dropFirst("dynamic~".count)).removingPercentEncoding ?? id
        let relatedStocks = sectorStocks(id: id)
        return HotSector(
            id: id,
            name: name,
            aliases: [name],
            heat: .diverging,
            status: "\(name) 当前更多受资讯驱动，适合先看相关股票再判断持续性。",
            summary: "这是根据资讯动态生成的板块页，方便你直接从方向继续往个股研究。",
            highlights: ["资讯驱动", "动态映射", "继续跟踪"],
            stocks: relatedStocks.map { SectorStock(code: $0.code, name: $0.name, tag: "\($0.totalScore) 分") }
        )
    }

    func sectorStocks(id: String) -> [Stock] {
        if let sector = sectors.first(where: { $0.id == id }) {
            let codes = sector.stocks.map(\.code)
            return stocks.filter { codes.contains($0.code) }
        }

        guard id.hasPrefix("dynamic~") else { return [] }
        let name = String(id.dropFirst("dynamic~".count)).removingPercentEncoding ?? id
        return stocks.filter { stock in
            newsEntries.contains { entry in
                entry.stockCode == stock.code || entry.sectors.contains(name)
            }
        }
    }

    func sectorNews(id: String) -> [NewsEntry] {
        guard let sector = sector(id: id) else { return [] }
        let candidates = [sector.name] + sector.aliases
        return newsEntries.filter { entry in
            entry.sectors.contains { sectorName in
                candidates.contains(where: { candidate in
                    candidate == sectorName || candidate.contains(sectorName) || sectorName.contains(candidate)
                })
            }
        }
    }

    func news(id: String) -> NewsEntry? {
        newsEntries.first { $0.id == id }
    }

    func sectorID(for name: String) -> String {
        let normalized = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if let sector = sectors.first(where: { sector in
            ([sector.name] + sector.aliases).contains(where: {
                $0 == normalized || $0.contains(normalized) || normalized.contains($0)
            })
        }) {
            return sector.id
        }
        return "dynamic~\(normalized.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? normalized)"
    }
}
