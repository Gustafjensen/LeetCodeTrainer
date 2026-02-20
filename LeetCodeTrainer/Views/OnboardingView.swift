import SwiftUI

struct OnboardingView: View {
    var onComplete: () -> Void
    @State private var currentPage = 0
    @State private var userName = ""

    private let totalPages = 4

    private let pages: [(icon: String, title: String, subtitle: String)] = [
        ("chevron.left.forwardslash.chevron.right", "Code Trainer", "Practice coding on the go"),
        ("keyboard.fill", "Write & Run Code", "Solve problems in Python with instant feedback"),
        ("chart.bar.fill", "Track Your Progress", "Earn XP, level up skills, and complete daily challenges")
    ]

    private var isLastPage: Bool { currentPage == totalPages - 1 }

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

                    // Name entry page
                    VStack(spacing: 24) {
                        Spacer()

                        ZStack {
                            Circle()
                                .fill(Theme.accent.opacity(0.15))
                                .frame(width: 120, height: 120)
                            Image(systemName: "person.fill")
                                .font(.system(size: 48))
                                .foregroundStyle(Theme.accent)
                        }

                        Text("What's your name?")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundStyle(Theme.textPrimary)

                        TextField("Enter your name", text: $userName)
                            .textFieldStyle(.plain)
                            .font(.title3)
                            .multilineTextAlignment(.center)
                            .padding(.vertical, 14)
                            .padding(.horizontal, 20)
                            .background(Theme.card)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .padding(.horizontal, 40)

                        Spacer()
                        Spacer()
                    }
                    .tag(pages.count)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                // Page dots
                HStack(spacing: 8) {
                    ForEach(0..<totalPages, id: \.self) { index in
                        Circle()
                            .fill(index == currentPage ? Theme.accent : Theme.textSecondary.opacity(0.3))
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.bottom, 32)

                // Button
                Button {
                    if isLastPage {
                        let trimmed = userName.trimmingCharacters(in: .whitespacesAndNewlines)
                        if !trimmed.isEmpty {
                            SkillXPManager.shared.saveUserName(trimmed)
                        }
                        onComplete()
                    } else {
                        withAnimation {
                            currentPage += 1
                        }
                    }
                } label: {
                    Text(isLastPage ? "Get Started" : "Next")
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

                if !isLastPage {
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
