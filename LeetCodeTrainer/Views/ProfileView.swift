import SwiftUI

struct ProfileView: View {
    private var xpManager: SkillXPManager { .shared }

    private var sortedSkills: [(skill: String, xp: Int)] {
        xpManager.skillXP
            .sorted { $0.value > $1.value }
            .map { (skill: $0.key, xp: $0.value) }
    }

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

                        Text("\(xpManager.totalXP()) Total XP")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(Theme.accent)
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

                    // Skills
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Skills")
                            .font(.headline)
                            .foregroundStyle(Theme.textPrimary)

                        if sortedSkills.isEmpty {
                            Text("Solve problems to earn XP!")
                                .font(.subheadline)
                                .foregroundStyle(Theme.textSecondary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 20)
                        } else {
                            ForEach(sortedSkills, id: \.skill) { item in
                                SkillRow(
                                    skill: item.skill,
                                    xp: item.xp,
                                    level: item.xp / 100,
                                    progress: Double(item.xp % 100) / 100.0
                                )
                            }
                        }
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

struct SkillRow: View {
    let skill: String
    let xp: Int
    let level: Int
    let progress: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(skill)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(Theme.textPrimary)
                Spacer()
                Text("Lvl \(level)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(Theme.accent)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Theme.accent.opacity(0.15))
                    .clipShape(Capsule())
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Theme.primaryDark)
                        .frame(height: 6)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [Theme.accent, .green],
                                startPoint: .leading, endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * progress, height: 6)
                }
            }
            .frame(height: 6)

            Text("\(xp % 100)/100 XP to next level")
                .font(.caption2)
                .foregroundStyle(Theme.textSecondary)
        }
        .padding(.vertical, 4)
    }
}
