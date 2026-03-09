import SwiftUI

struct DimensionScoreCardView: View {
    let title: String
    let score: Int
    let reasons: [String]
    let trend: ScoreTrend

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(title)
                    .font(.headline)
                Spacer()
                Text("\(score)")
                    .font(.headline)
                TrendBadgeView(trend: trend)
            }

            ForEach(reasons, id: \.self) { reason in
                Text("• \(reason)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}
