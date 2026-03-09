import SwiftUI

struct HomeView: View {
    @StateObject private var store = StockStore()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    SearchBarView(text: $store.query)

                    ForEach(store.filteredStocks) { stock in
                        NavigationLink {
                            StockDetailView(stock: stock)
                                .environmentObject(store)
                        } label: {
                            StockListItemView(stock: stock)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
            .background(Color(red: 0.95, green: 0.96, blue: 0.97))
            .navigationTitle("首页")
            .toolbar {
                NavigationLink("自选") {
                    WatchlistView()
                        .environmentObject(store)
                }
            }
        }
    }
}
