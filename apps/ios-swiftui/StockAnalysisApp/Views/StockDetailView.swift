import SwiftUI

struct StockDetailView: View {
    @EnvironmentObject private var store: StockStore
    let stock: Stock

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                ScoreSummaryCardView(stock: stock)

                VStack(alignment: .leading, spacing: 12) {
                    Text("四维评分")
                        .font(.headline)

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
                }
                .padding(20)
                .background(Color.white, in: RoundedRectangle(cornerRadius: 24))

                Button {
                    store.toggleWatchlist(code: stock.code)
                } label: {
                    HStack {
                        Image(systemName: store.watchlist.contains(stock.code) ? "star.slash" : "star.fill")
                        Text(store.watchlist.contains(stock.code) ? "移出自选" : "加入自选")
                    }
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(store.watchlist.contains(stock.code) ? .gray : .blue)

                VStack(alignment: .leading, spacing: 12) {
                    Text("研究依据")
                        .font(.headline)
                    ReasonListView(title: "基本面", reasons: stock.fundamentalsReasons)
                    ReasonListView(title: "消息面", reasons: stock.newsReasons)
                    ReasonListView(title: "技术面", reasons: stock.technicalsReasons)
                    ReasonListView(title: "情绪面", reasons: stock.sentimentReasons)
                }
            }
            .padding()
        }
        .background(Color(red: 0.95, green: 0.97, blue: 1.0))
        .navigationTitle(stock.name)
    }
}
