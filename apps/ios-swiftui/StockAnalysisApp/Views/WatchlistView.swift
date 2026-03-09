import SwiftUI

struct WatchlistView: View {
    @EnvironmentObject private var store: StockStore

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if store.watchlistStocks.isEmpty {
                    Text("还没有加入自选")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(store.watchlistStocks) { stock in
                        NavigationLink {
                            StockDetailView(stock: stock)
                                .environmentObject(store)
                        } label: {
                            StockListItemView(stock: stock)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding()
        }
        .background(Color(red: 0.95, green: 0.96, blue: 0.97))
        .navigationTitle("自选")
    }
}
