import SwiftUI

struct XPRewardView: View {
    let gains: [SkillXPGain]
    let onContinue: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var showContent = false
    @State private var animateProgress = false
    @State private var showButton = false

    var body: some View {
        ZStack {
            Theme.surface.ignoresSafeArea()

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
                                .offset(y: showContent ? 0 : 20)
                                .animation(
                                    .spring(duration: 0.5).delay(Double(index) * 0.15 + 0.2),
                                    value: showContent
                                )
                        }
                    }

                    // Continue button
                    if showButton {
                        Button {
                            dismiss()
                            onContinue()
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
        .navigationBarBackButtonHidden(true)
        .toolbarBackground(Theme.primary, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Rewards")
                    .font(.title3.bold())
                    .foregroundStyle(.white)
            }
        }
        .onAppear {
            withAnimation(.spring(duration: 0.6)) {
                showContent = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.easeOut(duration: 0.8)) {
                    animateProgress = true
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
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
            // Set initial state
            displayLevel = gain.previousLevel
            barProgress = gain.previousProgress
            let prevInLevel = SkillXPManager.xpInCurrentLevel(forXP: gain.previousXP)
            let prevNeeded = SkillXPManager.xpNeededForNextLevel(atLevel: gain.previousLevel)
            displayXPText = "\(prevInLevel)/\(prevNeeded) XP"
        }
        .onChange(of: animate) {
            guard animate, !hasStarted else { return }
            hasStarted = true

            if gain.didLevelUp {
                // Phase 1: fill bar to 100%
                withAnimation(.easeOut(duration: 0.6)) {
                    barProgress = 1.0
                }

                // Phase 2: jump to new level, animate to new progress
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                    barProgress = 0
                    displayLevel = gain.newLevel
                    let newInLevel = SkillXPManager.xpInCurrentLevel(forXP: gain.newXP)
                    let newNeeded = SkillXPManager.xpNeededForNextLevel(atLevel: gain.newLevel)
                    displayXPText = "\(newInLevel)/\(newNeeded) XP"

                    withAnimation(.easeOut(duration: 0.6)) {
                        barProgress = gain.newProgress
                    }
                }
            } else {
                // No level up: simple animation
                let newInLevel = SkillXPManager.xpInCurrentLevel(forXP: gain.newXP)
                let newNeeded = SkillXPManager.xpNeededForNextLevel(atLevel: gain.newLevel)
                withAnimation(.easeOut(duration: 0.8)) {
                    barProgress = gain.newProgress
                }
                displayXPText = "\(newInLevel)/\(newNeeded) XP"
            }
        }
    }
}
