import SwiftUI

struct SearchBarView: View {
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("搜索股票代码或名称", text: $text)
                    .disableAutocorrection(true)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(Color.white.opacity(0.88), in: RoundedRectangle(cornerRadius: 16))

            HStack {
                InfoChip(title: "总分")
                InfoChip(title: "风险提示")
                InfoChip(title: "评分依据")
            }
        }
    }
}

private struct InfoChip: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.caption)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.white.opacity(0.72))
            .clipShape(Capsule())
    }
}
