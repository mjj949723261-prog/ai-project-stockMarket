import Foundation
import SwiftUI

@MainActor
final class StockStore: ObservableObject {
    @Published var query = ""
    @Published var watchlist: Set<String> = ["600519"]

    private let repository = StockRepository()

    var stocks: [Stock] {
        repository.loadStocks()
    }

    var filteredStocks: [Stock] {
        let keyword = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !keyword.isEmpty else { return stocks }

        return stocks.filter { stock in
            stock.code.contains(keyword) || stock.name.contains(keyword)
        }
    }

    var watchlistStocks: [Stock] {
        stocks.filter { watchlist.contains($0.code) }
    }

    func toggleWatchlist(code: String) {
        if watchlist.contains(code) {
            watchlist.remove(code)
        } else {
            watchlist.insert(code)
        }
    }
}

