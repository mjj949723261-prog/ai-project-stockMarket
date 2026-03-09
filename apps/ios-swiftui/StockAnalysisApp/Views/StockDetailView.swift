import SwiftUI

struct StockDetailView: View {
    @EnvironmentObject private var store: StockStore
    let stock: Stock

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ScoreSummaryCardView(stock: stock)

                DimensionScoreCardView(
                    title: "基本面",
                    score: stock.fundamentalsScore,
                    reasons: stock.fundamentalsReasons,
                    trend: stock.scoreTrend
                )
                DimensionScoreCardView(
                    title: "消息面",
                    score: stock.newsScore,
                    reasons: stock.newsReasons,
                    trend: stock.scoreTrend
                )
                DimensionScoreCardView(
                    title: "技术面",
                    score: stock.technicalsScore,
                    reasons: stock.technicalsReasons,
                    trend: stock.scoreTrend
                )
                DimensionScoreCardView(
                    title: "情绪面",
                    score: stock.sentimentScore,
                    reasons: stock.sentimentReasons,
                    trend: stock.scoreTrend
                )

                Button(store.watchlist.contains(stock.code) ? "移出自选" : "加入自选") {
                    store.toggleWatchlist(code: stock.code)
                }
                .buttonStyle(.borderedProminent)

                ReasonListView(title: "详细依据：基本面", reasons: stock.fundamentalsReasons)
                ReasonListView(title: "详细依据：消息面", reasons: stock.newsReasons)
                ReasonListView(title: "详细依据：技术面", reasons: stock.technicalsReasons)
                ReasonListView(title: "详细依据：情绪面", reasons: stock.sentimentReasons)
            }
            .padding()
        }
        .background(Color(red: 0.95, green: 0.96, blue: 0.97))
        .navigationTitle(stock.name)
    }
}
