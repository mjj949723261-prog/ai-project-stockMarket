import SwiftUI

struct ScoreSummaryCardView: View {
    let stock: Stock

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(stock.name)
                        .font(.title2.bold())
                    Text(stock.code)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text("\(stock.totalScore)")
                    .font(.system(size: 42, weight: .bold, design: .rounded))
            }

            Text(stock.verdict)
            Text("风险提示：\(stock.riskWarning)")
                .foregroundStyle(.orange)
        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
}
