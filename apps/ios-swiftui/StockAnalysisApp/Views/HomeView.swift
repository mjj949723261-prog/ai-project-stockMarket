import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var store: StockStore

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Search")
                            .font(.caption)
                            .foregroundStyle(.blue)
                        Text("搜索 + 热门资讯")
                            .font(.largeTitle.bold())
                        Text("先搜股票，再直接进入今天最值得看的资讯和证据。")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        SearchBarView(text: $store.query)
                    }
                    .padding(20)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28))

                    if !store.searchHistory.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HeaderRow(title: "搜索记录", trailing: "\(store.searchHistory.count) 条")

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    ForEach(store.searchHistory, id: \.self) { item in
                                        Button(item) {
                                            store.applySearchHistory(item)
                                        }
                                        .buttonStyle(.bordered)
                                        .buttonBorderShape(.capsule)
                                    }
                                }
                            }
                        }
                        .padding(20)
                        .background(Color.white, in: RoundedRectangle(cornerRadius: 24))
                    }

                    if !store.query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HeaderRow(title: "搜索结果", trailing: "\(store.filteredStocks.count) 只")

                            ForEach(store.filteredStocks) { stock in
                                NavigationLink {
                                    StockDetailView(stock: stock)
                                } label: {
                                    StockListItemView(stock: stock)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(20)
                        .background(Color.white, in: RoundedRectangle(cornerRadius: 24))
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            HeaderRow(title: "热门资讯", trailing: nil)
                            Spacer()
                            NavigationLink("查看热门页") {
                                HotView()
                            }
                            .font(.footnote.weight(.semibold))
                        }

                        ForEach(store.newsEntries.prefix(4)) { item in
                            NavigationLink {
                                NewsDetailView(news: item)
                            } label: {
                                NewsEntryCardView(news: item)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(20)
                    .background(Color.white, in: RoundedRectangle(cornerRadius: 24))
                }
                .padding()
            }
            .background(Color(red: 0.95, green: 0.97, blue: 1.0))
            .navigationTitle("首页")
        }
    }
}

struct HotView: View {
    @EnvironmentObject private var store: StockStore

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Hot List")
                            .font(.caption)
                            .foregroundStyle(.orange)
                        Text("热门方向与热门股票")
                            .font(.largeTitle.bold())
                        Text("先看方向，再点进最值得研究的股票。")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(20)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28))

                    VStack(alignment: .leading, spacing: 12) {
                        HeaderRow(title: "热门板块", trailing: "\(store.sectors.count) 个方向")

                        ForEach(store.sectors) { sector in
                            NavigationLink {
                                SectorDetailView(sectorID: sector.id)
                            } label: {
                                HotSectorCardView(sector: sector)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(20)
                    .background(Color.white, in: RoundedRectangle(cornerRadius: 24))

                    VStack(alignment: .leading, spacing: 12) {
                        HeaderRow(title: "热门股票", trailing: "当前关注度")
                        ForEach(store.hotStocks) { stock in
                            NavigationLink {
                                StockDetailView(stock: stock)
                            } label: {
                                StockListItemView(stock: stock)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(20)
                    .background(Color.white, in: RoundedRectangle(cornerRadius: 24))
                }
                .padding()
            }
            .background(Color(red: 0.95, green: 0.97, blue: 1.0))
            .navigationTitle("热门")
        }
    }
}

struct SectorDetailView: View {
    @EnvironmentObject private var store: StockStore
    let sectorID: String

    var body: some View {
        Group {
            if let sector = store.sector(id: sectorID) {
                ScrollView {
                    VStack(spacing: 18) {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(alignment: .top) {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Sector Focus")
                                        .font(.caption)
                                        .foregroundStyle(.blue)
                                    Text(sector.name)
                                        .font(.largeTitle.bold())
                                }
                                Spacer()
                                HeatPill(heat: sector.heat)
                            }

                            Text(sector.status)
                                .font(.headline)

                            Text(sector.summary)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    ForEach(sector.highlights, id: \.self) { item in
                                        Text(item)
                                            .font(.caption)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                            .background(Color(.secondarySystemFill))
                                            .clipShape(Capsule())
                                    }
                                }
                            }
                        }
                        .padding(20)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28))

                        VStack(alignment: .leading, spacing: 12) {
                            HeaderRow(title: "相关股票", trailing: "\(store.sectorStocks(id: sectorID).count) 只")

                            ForEach(store.sectorStocks(id: sectorID)) { stock in
                                NavigationLink {
                                    StockDetailView(stock: stock)
                                } label: {
                                    StockListItemView(stock: stock)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(20)
                        .background(Color.white, in: RoundedRectangle(cornerRadius: 24))

                        VStack(alignment: .leading, spacing: 12) {
                            HeaderRow(title: "板块相关资讯", trailing: nil)

                            ForEach(store.sectorNews(id: sectorID).prefix(6)) { item in
                                NavigationLink {
                                    NewsDetailView(news: item)
                                } label: {
                                    NewsEntryCardView(news: item)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(20)
                        .background(Color.white, in: RoundedRectangle(cornerRadius: 24))
                    }
                    .padding()
                }
                .background(Color(red: 0.95, green: 0.97, blue: 1.0))
                .navigationTitle(sector.name)
            } else {
                ContentUnavailableView("未找到板块", systemImage: "square.grid.2x2", description: Text("请返回热门页重新选择板块。"))
            }
        }
    }
}

struct NewsDetailView: View {
    @EnvironmentObject private var store: StockStore
    let news: NewsEntry

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 10) {
                        RegionPill(region: news.region)
                        ImpactPill(impact: news.impact)
                        Text(urgencyText)
                            .font(.caption.weight(.semibold))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color(.secondarySystemFill))
                            .clipShape(Capsule())
                    }

                    Text(news.title)
                        .font(.largeTitle.bold())
                    Text(news.summary)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    HStack {
                        Text(news.source)
                        Spacer()
                        Text(news.publishedAt)
                    }
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                }
                .padding(20)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28))

                DetailCard(title: "核心摘要", content: "这条资讯当前被系统归类为\(impactText)，主要影响\(news.sectors.joined(separator: "、"))。它会先修正消息面判断，再决定是否改变短期跟踪节奏。")

                VStack(alignment: .leading, spacing: 12) {
                    HeaderRow(title: "影响板块", trailing: nil)
                    FlowStack(spacing: 10) {
                        ForEach(news.sectors, id: \.self) { sector in
                            NavigationLink {
                                SectorDetailView(sectorID: store.sectorID(for: sector))
                            } label: {
                                Text(sector)
                                    .font(.caption)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(Color(.secondarySystemFill))
                                    .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(20)
                .background(Color.white, in: RoundedRectangle(cornerRadius: 24))

                if let stockCode = news.stockCode, let stock = store.stock(code: stockCode) {
                    VStack(alignment: .leading, spacing: 12) {
                        HeaderRow(title: "关联股票", trailing: nil)
                        NavigationLink {
                            StockDetailView(stock: stock)
                        } label: {
                            StockListItemView(stock: stock)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(20)
                    .background(Color.white, in: RoundedRectangle(cornerRadius: 24))
                } else {
                    DetailCard(title: "关联股票", content: "当前没有明确关联股票，建议优先从影响板块继续展开。")
                }

                DetailCard(title: "评分影响", content: news.scoreEffect)

                Link("查看原文", destination: URL(string: news.sourceURL) ?? URL(string: "https://example.com")!)
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.blue)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            }
            .padding()
        }
        .background(Color(red: 0.95, green: 0.97, blue: 1.0))
        .navigationTitle("资讯详情")
    }

    private var impactText: String {
        switch news.impact {
        case .positive: return "利好"
        case .negative: return "利空"
        case .neutral: return "中性"
        }
    }

    private var urgencyText: String {
        switch news.urgency {
        case .high: return "高优先级"
        case .medium: return "重点跟踪"
        case .low: return "观察信息"
        }
    }
}

private struct HeaderRow: View {
    let title: String
    let trailing: String?

    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
            Spacer()
            if let trailing {
                Text(trailing)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

private struct HeatPill: View {
    let heat: SectorHeat

    var body: some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(background, in: Capsule())
            .foregroundStyle(foreground)
    }

    private var text: String {
        switch heat {
        case .high: return "高关注"
        case .warming: return "升温中"
        case .diverging: return "分化中"
        }
    }

    private var background: Color {
        switch heat {
        case .high: return Color.blue.opacity(0.12)
        case .warming: return Color.orange.opacity(0.14)
        case .diverging: return Color.gray.opacity(0.16)
        }
    }

    private var foreground: Color {
        switch heat {
        case .high: return .blue
        case .warming: return .orange
        case .diverging: return .secondary
        }
    }
}

private struct RegionPill: View {
    let region: NewsRegion

    var body: some View {
        Text(region == .global ? "国际资讯" : "国内资讯")
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(.secondarySystemFill), in: Capsule())
    }
}

private struct ImpactPill: View {
    let impact: NewsImpact

    var body: some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(background, in: Capsule())
            .foregroundStyle(foreground)
    }

    private var text: String {
        switch impact {
        case .positive: return "利好"
        case .negative: return "利空"
        case .neutral: return "中性"
        }
    }

    private var background: Color {
        switch impact {
        case .positive: return Color.green.opacity(0.12)
        case .negative: return Color.red.opacity(0.12)
        case .neutral: return Color.gray.opacity(0.14)
        }
    }

    private var foreground: Color {
        switch impact {
        case .positive: return .green
        case .negative: return .red
        case .neutral: return .secondary
        }
    }
}

private struct DetailCard: View {
    let title: String
    let content: String

    var bodyView: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
            Text(content)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(20)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 24))
    }

    var body: some View { bodyView }
}

private struct FlowStack<Content: View>: View {
    let spacing: CGFloat
    @ViewBuilder let content: Content

    init(spacing: CGFloat = 8, @ViewBuilder content: () -> Content) {
        self.spacing = spacing
        self.content = content()
    }

    var body: some View {
        HStack(spacing: spacing) {
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct NewsEntryCardView: View {
    let news: NewsEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                RegionPill(region: news.region)
                Spacer()
                ImpactPill(impact: news.impact)
            }

            Text(news.title)
                .font(.headline)
                .multilineTextAlignment(.leading)
            Text(news.summary)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack {
                Text(news.source)
                Spacer()
                Text(news.stockName ?? news.sectors.joined(separator: "、"))
            }
            .font(.footnote)
            .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color.white.opacity(0.7), in: RoundedRectangle(cornerRadius: 20))
    }
}

private struct HotSectorCardView: View {
    let sector: HotSector

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("热门板块")
                        .font(.caption)
                        .foregroundStyle(.blue)
                    Text(sector.name)
                        .font(.title3.bold())
                }
                Spacer()
                HeatPill(heat: sector.heat)
            }

            Text(sector.status)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            VStack(spacing: 10) {
                ForEach(sector.stocks) { stock in
                    HStack {
                        Text(stock.name)
                            .font(.subheadline.weight(.semibold))
                        Spacer()
                        Text(stock.tag)
                            .font(.caption)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color(.secondarySystemFill))
                            .clipShape(Capsule())
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color.white.opacity(0.72), in: RoundedRectangle(cornerRadius: 16))
                }
            }
        }
        .padding()
        .background(Color.white, in: RoundedRectangle(cornerRadius: 24))
    }
}
