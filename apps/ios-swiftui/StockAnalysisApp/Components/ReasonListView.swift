import SwiftUI

struct ReasonListView: View {
    let title: String
    let reasons: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)

            ForEach(reasons, id: \.self) { reason in
                Text("• \(reason)")
                    .font(.body)
            }
        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}
