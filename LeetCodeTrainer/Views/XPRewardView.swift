import SwiftUI

struct XPRewardView: View {
    let gains: [SkillXPGain]
    let onContinue: () -> Void

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
                        Button(action: onContinue) {
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
                                width: geo.size.width * (animate ? gain.newProgress : gain.previousProgress),
                                height: 8
                            )
                            .animation(.easeOut(duration: 0.8), value: animate)
                    }
                }
                .frame(height: 8)

                HStack {
                    Text("Lvl \(gain.newLevel)")
                        .font(.caption2)
                        .foregroundStyle(Theme.textSecondary)
                    Spacer()
                    Text("\(gain.newXP % 100)/100 XP")
                        .font(.caption2)
                        .foregroundStyle(Theme.textSecondary)
                }
            }
        }
        .padding(14)
        .background(Theme.card)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
