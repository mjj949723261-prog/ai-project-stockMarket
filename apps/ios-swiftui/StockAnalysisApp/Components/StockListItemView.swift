import SwiftUI

struct StockListItemView: View {
    let stock: Stock

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(stock.name)
                        .font(.headline)
                    Text(stock.code)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 8) {
                    Text("\(stock.totalScore)")
                        .font(.title3.weight(.bold))
                    TrendBadgeView(trend: stock.scoreTrend)
                }
            }

            Text(stock.verdict)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
        .padding()
        .background(Color.white.opacity(0.78))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}
