import SwiftUI

@main
struct StockAnalysisAppApp: App {
    @StateObject private var store = StockStore()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(store)
        }
    }
}

private struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("首页", systemImage: "house")
                }

            HotView()
                .tabItem {
                    Label("热门", systemImage: "flame")
                }

            WatchlistView()
                .tabItem {
                    Label("自选", systemImage: "star")
                }
        }
    }
}
