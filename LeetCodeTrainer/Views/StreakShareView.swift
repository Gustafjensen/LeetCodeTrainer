import SwiftUI

struct StreakShareCard: View {
    let userName: String
    let currentStreak: Int
    let longestStreak: Int
    let totalXP: Int
    let solvedCount: Int

    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 8) {
                Text("< / >")
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                    .foregroundStyle(Color(red: 0.3, green: 0.5, blue: 1.0))
                Text("CodeCrush")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
            }

            HStack(spacing: 12) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(.orange)
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(currentStreak)")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(.white)
                    Text("Day Streak")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.7))
                }
                Spacer()
            }

            HStack(spacing: 0) {
                ShareStatBubble(label: "Best", value: "\(longestStreak)")
                ShareStatBubble(label: "XP", value: "\(totalXP)")
                ShareStatBubble(label: "Solved", value: "\(solvedCount)")
            }

            if !userName.isEmpty {
                Text("— \(userName)")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.4))
            }
        }
        .padding(24)
        .frame(width: 320)
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.1, green: 0.15, blue: 0.35),
                    Color(red: 0.06, green: 0.09, blue: 0.25)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

private struct ShareStatBubble: View {
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(.white)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
