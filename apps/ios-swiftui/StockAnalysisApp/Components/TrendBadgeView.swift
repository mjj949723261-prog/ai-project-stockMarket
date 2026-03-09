import SwiftUI

struct TrendBadgeView: View {
    let trend: ScoreTrend

    private var title: String {
        switch trend {
        case .up: return "上升"
        case .flat: return "持平"
        case .down: return "下降"
        }
    }

    var body: some View {
        Text(title)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.green.opacity(0.12))
            .foregroundStyle(Color.green)
            .clipShape(Capsule())
    }
}

