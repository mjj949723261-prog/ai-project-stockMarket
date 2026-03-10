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
            .background(color.opacity(0.12))
            .foregroundStyle(color)
            .clipShape(Capsule())
    }

    private var color: Color {
        switch trend {
        case .up: return .green
        case .flat: return .orange
        case .down: return .red
        }
    }
}
