import SwiftUI

struct ProfileView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Avatar card
                    VStack(spacing: 12) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 64))
                            .foregroundStyle(Theme.accent)
                        Text("Guest User")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundStyle(Theme.textPrimary)
                        Text("LeetCode Trainer")
                            .font(.caption)
                            .foregroundStyle(Theme.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 28)
                    .background(
                        LinearGradient(
                            colors: [Theme.card, Theme.cardLight],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                    // Stats
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 12) {
                        StatCard(title: "Solved", value: "0", icon: "checkmark.circle.fill", color: .green)
                        StatCard(title: "Attempted", value: "0", icon: "play.circle.fill", color: Theme.accent)
                        StatCard(title: "Streak", value: "0", icon: "flame.fill", color: .orange)
                    }

                    // Progress
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Progress")
                            .font(.headline)
                            .foregroundStyle(Theme.textPrimary)
                        HStack(spacing: 16) {
                            ProgressRing(label: "Easy", solved: 0, total: 5, color: .green)
                            ProgressRing(label: "Medium", solved: 0, total: 3, color: .orange)
                            ProgressRing(label: "Hard", solved: 0, total: 0, color: .red)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding(20)
                    .background(Theme.card)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding()
            }
            .background(Theme.surface)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Theme.primary, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Profile")
                        .font(.title3.bold())
                        .foregroundStyle(.white)
                }
            }
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(Theme.textPrimary)
            Text(title)
                .font(.caption)
                .foregroundStyle(Theme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Theme.card)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct ProgressRing: View {
    let label: String
    let solved: Int
    let total: Int
    let color: Color

    private var progress: Double {
        total > 0 ? Double(solved) / Double(total) : 0
    }

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .stroke(color.opacity(0.15), lineWidth: 6)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(color, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                Text("\(solved)/\(total)")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundStyle(Theme.textPrimary)
            }
            .frame(width: 56, height: 56)
            Text(label)
                .font(.caption)
                .foregroundStyle(Theme.textSecondary)
        }
    }
}
