import SwiftUI

struct StockListItemView: View {
    let stock: Stock

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text(stock.name)
                    .font(.headline)
                Text(stock.code)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(stock.verdict)
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
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}
