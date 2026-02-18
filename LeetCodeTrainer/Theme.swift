import SwiftUI

enum Theme {
    static let primary = Color(red: 0.1, green: 0.15, blue: 0.35)
    static let primaryLight = Color(red: 0.15, green: 0.22, blue: 0.5)
    static let primaryDark = Color(red: 0.06, green: 0.09, blue: 0.25)
    static let accent = Color(red: 0.3, green: 0.5, blue: 1.0)
    static let surface = Color(red: 0.08, green: 0.12, blue: 0.28)
    static let card = Color(red: 0.12, green: 0.17, blue: 0.38)
    static let cardLight = Color(red: 0.15, green: 0.2, blue: 0.42)
    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.6)
    static let divider = Color.white.opacity(0.1)
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 4

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth && x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
        return CGSize(width: maxWidth, height: y + rowHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX && x > bounds.minX {
                x = bounds.minX
                y += rowHeight + spacing
                rowHeight = 0
            }
            subview.place(at: CGPoint(x: x, y: y), proposal: .unspecified)
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}

struct BackButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "chevron.left")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 32, height: 32)
                .background(Theme.accent.opacity(0.3))
                .clipShape(Circle())
        }
    }
}
