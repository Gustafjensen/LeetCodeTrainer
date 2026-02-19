import SwiftUI

struct ProfileView: View {
    var problems: [Problem] = []
    private var xpManager: SkillXPManager { .shared }

    private var sortedSkills: [(skill: String, xp: Int)] {
        xpManager.skillXP
            .sorted { $0.value > $1.value }
            .map { (skill: $0.key, xp: $0.value) }
    }

    private var solvedCount: Int { xpManager.solvedProblems.count }
    private var totalCount: Int { problems.count }

    private var easySolved: Int {
        problems.filter { $0.difficulty == .easy && xpManager.isSolved($0.id) }.count
    }
    private var easyTotal: Int {
        problems.filter { $0.difficulty == .easy }.count
    }
    private var mediumSolved: Int {
        problems.filter { $0.difficulty == .medium && xpManager.isSolved($0.id) }.count
    }
    private var mediumTotal: Int {
        problems.filter { $0.difficulty == .medium }.count
    }
    private var hardSolved: Int {
        problems.filter { $0.difficulty == .hard && xpManager.isSolved($0.id) }.count
    }
    private var hardTotal: Int {
        problems.filter { $0.difficulty == .hard }.count
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

                    // Stats cards
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                        StatCard(
                            icon: "checkmark.circle.fill",
                            iconColor: .green,
                            title: "Solved",
                            value: "\(solvedCount)/\(totalCount)"
                        )
                        StatCard(
                            icon: "flame.fill",
                            iconColor: .orange,
                            title: "Streak",
                            value: "\(xpManager.currentStreak()) days"
                        )
                        StatCard(
                            icon: "star.fill",
                            iconColor: Theme.accent,
                            title: "Total XP",
                            value: "\(xpManager.totalXP())"
                        )
                        StatCard(
                            icon: "trophy.fill",
                            iconColor: .yellow,
                            title: "Best Streak",
                            value: "\(xpManager.longestStreak()) days"
                        )
                    }

                    // Achievements
                    AchievementsSection(problems: problems)

                    // Difficulty breakdown
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Progress")
                            .font(.headline)
                            .foregroundStyle(Theme.textPrimary)

                        // Stacked bar
                        GeometryReader { geo in
                            let total = max(totalCount, 1)
                            let easyWidth = geo.size.width * Double(easySolved) / Double(total)
                            let mediumWidth = geo.size.width * Double(mediumSolved) / Double(total)
                            let hardWidth = geo.size.width * Double(hardSolved) / Double(total)

                            HStack(spacing: 2) {
                                if easySolved > 0 {
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color.green)
                                        .frame(width: easyWidth, height: 12)
                                }
                                if mediumSolved > 0 {
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color.orange)
                                        .frame(width: mediumWidth, height: 12)
                                }
                                if hardSolved > 0 {
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color.red)
                                        .frame(width: hardWidth, height: 12)
                                }
                                Spacer(minLength: 0)
                            }
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Theme.primaryDark)
                                    .frame(height: 12)
                            )
                        }
                        .frame(height: 12)

                        HStack(spacing: 16) {
                            DifficultyStatLabel(color: .green, label: "Easy", count: easySolved, total: easyTotal)
                            DifficultyStatLabel(color: .orange, label: "Medium", count: mediumSolved, total: mediumTotal)
                            DifficultyStatLabel(color: .red, label: "Hard", count: hardSolved, total: hardTotal)
                            Spacer()
                        }
                    }
                    .padding(20)
                    .background(Theme.card)
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
                                    level: SkillXPManager.level(forXP: item.xp),
                                    progress: SkillXPManager.progress(forXP: item.xp)
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

struct StatCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(iconColor)
            Text(value)
                .font(.headline)
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

struct DifficultyStatLabel: View {
    let color: Color
    let label: String
    let count: Int
    let total: Int

    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text("\(count)/\(total) \(label)")
                .font(.caption)
                .foregroundStyle(Theme.textSecondary)
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

            Text("\(SkillXPManager.xpInCurrentLevel(forXP: xp))/\(SkillXPManager.xpNeededForNextLevel(atLevel: level)) XP to next level")
                .font(.caption2)
                .foregroundStyle(Theme.textSecondary)
        }
        .padding(.vertical, 4)
    }
}

struct AchievementsSection: View {
    let problems: [Problem]
    private var xpManager: SkillXPManager { .shared }
    private let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    private var unlockedCount: Int {
        Achievement.all.filter { $0.isUnlocked(manager: xpManager, problems: problems) }.count
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Achievements")
                    .font(.headline)
                    .foregroundStyle(Theme.textPrimary)
                Spacer()
                Text("\(unlockedCount)/\(Achievement.all.count)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(Theme.accent)
            }

            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(Achievement.all) { achievement in
                    AchievementCard(
                        achievement: achievement,
                        isUnlocked: achievement.isUnlocked(manager: xpManager, problems: problems)
                    )
                }
            }
        }
        .padding(20)
        .background(Theme.card)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct AchievementCard: View {
    let achievement: Achievement
    let isUnlocked: Bool

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: achievement.icon)
                .font(.title2)
                .foregroundStyle(isUnlocked ? achievement.color : Theme.textSecondary.opacity(0.3))

            Text(achievement.title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(isUnlocked ? Theme.textPrimary : Theme.textSecondary.opacity(0.4))

            Text(achievement.description)
                .font(.caption2)
                .foregroundStyle(isUnlocked ? Theme.textSecondary : Theme.textSecondary.opacity(0.3))
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .padding(.horizontal, 6)
        .background(isUnlocked ? Theme.cardLight : Theme.primaryDark.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
