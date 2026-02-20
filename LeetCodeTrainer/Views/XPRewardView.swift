import SwiftUI

struct XPRewardView: View {
    let gains: [SkillXPGain]
    let sourceCode: String
    var solutionExplanation: String?
    var newAchievements: [Achievement] = []
    var popToRoot: () -> Void = {}

    @Environment(\.dismiss) private var dismiss
    @State private var showContent = false
    @State private var animateProgress = false
    @State private var showAchievements = false
    @State private var showButton = false
    @State private var showConfetti = false

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.surface.ignoresSafeArea()

                ConfettiView(isActive: $showConfetti)
                    .ignoresSafeArea()
                    .zIndex(10)

                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 10) {
                            ZStack {
                                Circle()
                                    .fill(Color.green.opacity(0.15))
                                    .frame(width: 80, height: 80)
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 44))
                                    .foregroundStyle(.green)
                                    .symbolEffect(.bounce, value: showContent)
                            }

                            Text("Problem Solved!")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundStyle(Theme.textPrimary)

                            Text("+\(gains.reduce(0) { $0 + $1.gained }) XP earned")
                                .font(.subheadline)
                                .foregroundStyle(Theme.accent)
                        }
                        .padding(.top, 20)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)

                        // Skill XP cards
                        VStack(spacing: 12) {
                            ForEach(Array(gains.enumerated()), id: \.element.id) { index, gain in
                                SkillXPCard(gain: gain, animate: animateProgress)
                                    .opacity(showContent ? 1 : 0)
                                    .animation(
                                        .easeOut(duration: 0.4).delay(Double(index) * 0.1 + 0.2),
                                        value: showContent
                                    )
                            }
                        }

                        // New achievements
                        if !newAchievements.isEmpty && showAchievements {
                            VStack(spacing: 12) {
                                Text("Achievement Unlocked!")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.yellow)

                                ForEach(newAchievements) { achievement in
                                    HStack(spacing: 14) {
                                        Image(systemName: achievement.icon)
                                            .font(.title2)
                                            .foregroundStyle(achievement.color)
                                            .frame(width: 40)

                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(achievement.title)
                                                .font(.subheadline)
                                                .fontWeight(.bold)
                                                .foregroundStyle(Theme.textPrimary)
                                            Text(achievement.description)
                                                .font(.caption)
                                                .foregroundStyle(Theme.textSecondary)
                                        }

                                        Spacer()

                                        Image(systemName: "checkmark.seal.fill")
                                            .foregroundStyle(.yellow)
                                    }
                                    .padding(14)
                                    .background(Theme.cardLight)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Theme.card)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
                                    )
                            )
                            .transition(.scale.combined(with: .opacity))
                        }

                        // Your Solution
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Your Solution")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundStyle(Theme.textPrimary)

                            ScrollView(.horizontal, showsIndicators: false) {
                                Text(sourceCode)
                                    .font(.system(size: 12, design: .monospaced))
                                    .foregroundStyle(Theme.textSecondary)
                            }
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Theme.primaryDark)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        .padding(16)
                        .background(Theme.card)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .opacity(showContent ? 1 : 0)

                        // Optimal approach
                        if let explanation = solutionExplanation {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack(spacing: 6) {
                                    Image(systemName: "lightbulb.fill")
                                        .foregroundStyle(.yellow)
                                    Text("Optimal Approach")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(Theme.textPrimary)
                                }

                                Text(explanation)
                                    .font(.subheadline)
                                    .foregroundStyle(Theme.textSecondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Theme.card)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.yellow.opacity(0.2), lineWidth: 1)
                                    )
                            )
                            .opacity(showContent ? 1 : 0)
                        }

                        // Continue button
                        if showButton {
                            Button {
                                dismiss()
                                popToRoot()
                            } label: {
                                Text("Continue")
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(
                                        LinearGradient(
                                            colors: [Theme.accent, Theme.primaryLight],
                                            startPoint: .leading, endPoint: .trailing
                                        )
                                    )
                                    .foregroundStyle(.white)
                                    .fontWeight(.semibold)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                        }
                    }
                    .padding(20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Theme.primary, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Rewards")
                        .font(.title3.bold())
                        .foregroundStyle(.white)
                }
            }
        }
        .onAppear {
            withAnimation(.spring(duration: 0.6)) {
                showContent = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                showConfetti = true
                Haptics.notification(.success)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.easeOut(duration: 0.8)) {
                    animateProgress = true
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation(.spring(duration: 0.5, bounce: 0.3)) {
                    showAchievements = true
                }
                if !newAchievements.isEmpty {
                    Haptics.impact(.heavy)
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + (newAchievements.isEmpty ? 1.2 : 1.8)) {
                withAnimation(.spring(duration: 0.4)) {
                    showButton = true
                }
            }
        }
    }
}

struct SkillXPCard: View {
    let gain: SkillXPGain
    let animate: Bool

    @State private var barProgress: Double = 0
    @State private var displayLevel: Int = 0
    @State private var displayXPText: String = ""
    @State private var hasStarted = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(gain.skill)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Theme.textPrimary)
                Spacer()
                Text("+\(gain.gained) XP")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.green)

                if gain.didLevelUp {
                    Text("LEVEL UP!")
                        .font(.caption2)
                        .fontWeight(.heavy)
                        .foregroundStyle(Theme.accent)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Theme.accent.opacity(0.2))
                        .clipShape(Capsule())
                }
            }

            // XP bar
            VStack(alignment: .leading, spacing: 4) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Theme.primaryDark)
                            .frame(height: 8)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                LinearGradient(
                                    colors: [Theme.accent, .green],
                                    startPoint: .leading, endPoint: .trailing
                                )
                            )
                            .frame(
                                width: geo.size.width * barProgress,
                                height: 8
                            )
                    }
                }
                .frame(height: 8)

                HStack {
                    Text("Lvl \(displayLevel)")
                        .font(.caption2)
                        .foregroundStyle(Theme.textSecondary)
                    Spacer()
                    Text(displayXPText)
                        .font(.caption2)
                        .foregroundStyle(Theme.textSecondary)
                }
            }
        }
        .padding(14)
        .background(Theme.card)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .onAppear {
            displayLevel = gain.newLevel
            let newInLevel = SkillXPManager.xpInCurrentLevel(forXP: gain.newXP)
            let newNeeded = SkillXPManager.xpNeededForNextLevel(atLevel: gain.newLevel)
            displayXPText = "\(newInLevel)/\(newNeeded) XP"
            barProgress = 0
        }
        .onChange(of: animate) {
            guard animate, !hasStarted else { return }
            hasStarted = true

            withAnimation(.easeOut(duration: 0.8)) {
                barProgress = gain.newProgress
            }
        }
    }
}
