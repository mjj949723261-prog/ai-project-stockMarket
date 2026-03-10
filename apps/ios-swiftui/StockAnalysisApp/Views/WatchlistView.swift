import SwiftUI

struct WatchlistView: View {
    @EnvironmentObject private var store: StockStore

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Watchlist")
                            .font(.caption)
                            .foregroundStyle(.purple)
                        Text("自选与对比")
                            .font(.largeTitle.bold())
                        Text("保留你持续跟踪的股票，并快速看清当前的分数差异。")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(20)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28))

                    if store.watchlistStocks.isEmpty {
                        ContentUnavailableView(
                            "还没有加入自选",
                            systemImage: "star",
                            description: Text("先从首页或热门页挑一只股票加入自选。")
                        )
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 32)
                    } else {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("自选股票")
                                    .font(.headline)
                                Spacer()
                                Text("\(store.watchlistStocks.count) 只")
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }

                            ForEach(store.watchlistStocks) { stock in
                                VStack(spacing: 12) {
                                    NavigationLink {
                                        StockDetailView(stock: stock)
                                    } label: {
                                        StockListItemView(stock: stock)
                                    }
                                    .buttonStyle(.plain)

                                    Button(role: .destructive) {
                                        store.toggleWatchlist(code: stock.code)
                                    } label: {
                                        HStack {
                                            Image(systemName: "trash")
                                            Text("移除自选")
                                        }
                                        .font(.subheadline.weight(.semibold))
                                        .frame(maxWidth: .infinity)
                                    }
                                    .buttonStyle(.bordered)
                                }
                            }
                        }
                        .padding(20)
                        .background(Color.white, in: RoundedRectangle(cornerRadius: 24))

                        VStack(alignment: .leading, spacing: 12) {
                            Text("快速对比")
                                .font(.headline)

                            ForEach(store.watchlistStocks) { stock in
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(stock.name)
                                            .font(.subheadline.weight(.semibold))
                                        Text(stock.verdict)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                            .lineLimit(2)
                                    }

                                    Spacer()

                                    VStack(alignment: .trailing, spacing: 6) {
                                        Text("\(stock.totalScore) 分")
                                            .font(.headline)
                                        TrendBadgeView(trend: stock.scoreTrend)
                                    }
                                }
                                .padding(.vertical, 6)
                            }
                        }
                        .padding(20)
                        .background(Color.white, in: RoundedRectangle(cornerRadius: 24))
                    }
                }
                .padding()
            }
            .background(Color(red: 0.95, green: 0.97, blue: 1.0))
            .navigationTitle("自选")
        }
    }
}
