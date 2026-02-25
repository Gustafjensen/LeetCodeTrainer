import SwiftUI

struct OnboardingView: View {
    var onComplete: () -> Void
    @State private var currentPage = 0
    @State private var userName = ""
    @State private var showTutorial = false

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
                        saveUserName()
                        showTutorial = true
                    } else {
                        withAnimation { currentPage += 1 }
                    }
                } label: {
                    Text(isLastPage ? "Try Your First Problem" : "Next")
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
                        saveUserName()
                        onComplete()
                    }
                    .foregroundStyle(Theme.textSecondary)
                    .padding(.top, 12)
                }

                Spacer().frame(height: 32)
            }
        }
        .fullScreenCover(isPresented: $showTutorial) {
            OnboardingTutorialView(onComplete: onComplete)
        }
    }

    private func saveUserName() {
        let trimmed = userName.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty {
            SkillXPManager.shared.saveUserName(trimmed)
        }
    }
}

// MARK: - Tutorial Problem View (looks like ProblemDetailView)

private struct OnboardingTutorialView: View {
    var onComplete: () -> Void

    @State private var sourceCode = "def addTwo(a: int, b: int) -> int:\n    # Write your solution here\n    pass"
    @State private var isExecuting = false
    @State private var errorMessage: String?
    @State private var executionResult: ExecutionResult?
    @State private var editorContentHeight: CGFloat = 150
    @State private var showXPReward = false
    @State private var xpGains: [SkillXPGain]?
    @AppStorage("editorFontSize") private var editorFontSize: Double = 14
    @State private var linterWarnings: [LintWarning] = []
    @AppStorage("linterEnabled") private var linterEnabled = true

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    // Header
                    HStack {
                        Text("Add Two Numbers")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundStyle(Theme.textPrimary)
                        Spacer()
                        DifficultyBadge(difficulty: .easy)
                    }
                    .padding(16)
                    .background(Theme.card)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    // Description
                    Text("Given two integers a and b, return their sum.")
                        .font(.subheadline)
                        .foregroundStyle(Theme.textSecondary)
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Theme.card)
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                    // Examples
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Examples")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(Theme.textPrimary)

                        ForEach(
                            [("a = 1, b = 2", "3", "1 + 2 = 3"),
                             ("a = -5, b = 10", "5", nil as String?)],
                            id: \.0
                        ) { input, output, explanation in
                            VStack(alignment: .leading, spacing: 4) {
                                Group {
                                    Text("Input: ") + Text(input)
                                    Text("Output: ") + Text(output)
                                    if let explanation {
                                        Text("Explanation: ") + Text(explanation)
                                    }
                                }
                                .font(.system(.caption, design: .monospaced))
                                .foregroundStyle(Theme.textSecondary)
                            }
                            .padding(10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Theme.primaryDark.opacity(0.5))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                    .padding(16)
                    .background(Theme.card)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    // Code editor
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Solution")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(Theme.textPrimary)

                        CodeEditorView(
                            text: $sourceCode,
                            fontSize: CGFloat(editorFontSize),
                            onContentHeightChange: { height in
                                editorContentHeight = height
                            },
                            onLinterWarnings: linterEnabled ? { warnings in
                                linterWarnings = warnings
                            } : nil
                        )
                        .frame(height: min(max(editorContentHeight, 150), 500))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .padding(16)
                    .background(Theme.card)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    // Linter warnings
                    if linterEnabled && !linterWarnings.isEmpty {
                        LinterWarningsView(warnings: linterWarnings)
                    }

                    // Run button
                    Button {
                        Haptics.impact(.medium)
                        Task { await runCode() }
                    } label: {
                        HStack {
                            if isExecuting {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Image(systemName: "play.fill")
                            }
                            Text(isExecuting ? "Running..." : "Run Code")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            isExecuting
                            ? AnyShapeStyle(Theme.cardLight)
                            : AnyShapeStyle(LinearGradient(
                                colors: [Theme.accent, Theme.primaryLight],
                                startPoint: .leading, endPoint: .trailing
                            ))
                        )
                        .foregroundStyle(.white)
                        .fontWeight(.semibold)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .disabled(isExecuting)

                    // Error
                    if let errorMessage {
                        Text(errorMessage)
                            .font(.callout)
                            .foregroundStyle(.red)
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.red.opacity(0.15))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }

                    // Results
                    if let result = executionResult {
                        ResultsView(result: result)
                    }
                }
                .padding()
            }
            .background(Theme.surface)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Theme.primary, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Your First Problem")
                        .font(.title3.bold())
                        .foregroundStyle(.white)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Skip") {
                        onComplete()
                    }
                    .foregroundStyle(.white.opacity(0.7))
                    .font(.subheadline)
                }
            }
        }
        .fullScreenCover(isPresented: $showXPReward) {
            if let gains = xpGains {
                XPRewardView(
                    gains: gains,
                    sourceCode: sourceCode,
                    solutionExplanation: "Simply return a + b. Time: O(1), Space: O(1).",
                    optimalCode: "def addTwo(a: int, b: int) -> int:\n    return a + b",
                    popToRoot: onComplete
                )
            }
        }
    }

    private func runCode() async {
        isExecuting = true
        errorMessage = nil
        executionResult = nil

        do {
            let result = try await ExecutionService().execute(
                problemId: "tutorial-add-two",
                language: "python",
                sourceCode: sourceCode
            )
            executionResult = result

            if result.overallStatus == .pass {
                Haptics.notification(.success)

                // Award a small 5 XP on "Math"
                let skill = "Math"
                let before = SkillXPManager.shared.xp(for: skill)
                SkillXPManager.shared.skillXP[skill] = before + 5
                xpGains = [SkillXPGain(
                    skill: skill,
                    previousXP: before,
                    newXP: before + 5,
                    gained: 5
                )]
                showXPReward = true
            } else {
                Haptics.notification(.error)
            }
        } catch {
            errorMessage = "Could not connect. Check your internet and try again."
        }

        isExecuting = false
    }

}
