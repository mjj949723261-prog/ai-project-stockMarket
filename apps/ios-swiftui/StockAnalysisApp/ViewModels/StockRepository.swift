import Foundation

struct StockRepository {
    func loadStocks() -> [Stock] {
        MockStocks.all
    }

    func loadSectors() -> [HotSector] {
        MockStocks.sectors
    }

    func loadNews() -> [NewsEntry] {
        MockStocks.news
    }
}
