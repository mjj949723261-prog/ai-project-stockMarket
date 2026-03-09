import Foundation

struct StockRepository {
    func loadStocks() -> [Stock] {
        MockStocks.all
    }

    func findStock(code: String) -> Stock? {
        MockStocks.all.first { $0.code == code }
    }
}

