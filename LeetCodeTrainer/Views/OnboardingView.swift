import SwiftUI

struct OnboardingView: View {
    var onComplete: () -> Void
    @State private var currentPage = 0

    private let pages: [(icon: String, title: String, subtitle: String)] = [
        ("chevron.left.forwardslash.chevron.right", "LeetCode Trainer", "Practice coding on the go"),
        ("keyboard.fill", "Write & Run Code", "Solve problems in Python with instant feedback"),
        ("chart.bar.fill", "Track Your Progress", "Earn XP, level up skills, and complete daily challenges")
    ]

    var body: some View {
        ZStack {
            Theme.surface.ignoresSafeArea()

            VStack(spacing: 0) {
                TabView(selection: $currentPage) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                        VStack(spacing: 24) {
                            Spacer()

                            ZStack {
                                Circle()
                                    .fill(Theme.accent.opacity(0.15))
                                    .frame(width: 120, height: 120)
                                Image(systemName: page.icon)
                                    .font(.system(size: 48))
                                    .foregroundStyle(Theme.accent)
                            }

                            Text(page.title)
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundStyle(Theme.textPrimary)

                            Text(page.subtitle)
                                .font(.body)
                                .foregroundStyle(Theme.textSecondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)

                            Spacer()
                            Spacer()
                        }
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                // Page dots
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentPage ? Theme.accent : Theme.textSecondary.opacity(0.3))
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.bottom, 32)

                // Button
                Button {
                    if currentPage < pages.count - 1 {
                        withAnimation {
                            currentPage += 1
                        }
                    } else {
                        onComplete()
                    }
                } label: {
                    Text(currentPage < pages.count - 1 ? "Next" : "Get Started")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [Theme.accent, Theme.primaryLight],
                                startPoint: .leading, endPoint: .trailing
                            )
                        )
                        .foregroundStyle(.white)
                        .fontWeight(.semibold)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .padding(.horizontal, 24)

                if currentPage < pages.count - 1 {
                    Button("Skip") {
                        onComplete()
                    }
                    .foregroundStyle(Theme.textSecondary)
                    .padding(.top, 12)
                }

                Spacer().frame(height: 32)
            }
        }
    }
}
