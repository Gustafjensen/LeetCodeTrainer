import SwiftUI

struct ProblemDetailView: View {
    @State var viewModel: ProblemDetailViewModel
    var popToRoot: () -> Void = {}
    @Environment(\.dismiss) private var dismiss
    @AppStorage("editorFontSize") private var editorFontSize: Double = 14
    @State private var editorContentHeight: CGFloat = 150
    @State private var revealedHints = 0
    @State private var showHistory = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack {
                    Text(viewModel.problem.title)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(Theme.textPrimary)
                    Spacer()
                    DifficultyBadge(difficulty: viewModel.problem.difficulty)
                }
                .padding(16)
                .background(Theme.card)
                .clipShape(RoundedRectangle(cornerRadius: 12))

                // Description
                Text(viewModel.problem.description)
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

                    ForEach(Array(viewModel.problem.examples.enumerated()), id: \.offset) { index, example in
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Example \(index + 1)")
                                .font(.caption2)
                                .fontWeight(.semibold)
                                .foregroundStyle(Theme.accent)
                            Group {
                                Text("Input: ") + Text(example.input)
                                Text("Output: ") + Text(example.output)
                                if let explanation = example.explanation {
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

                // Hints
                if !viewModel.problem.hints.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Image(systemName: "lightbulb.fill")
                                .foregroundStyle(.yellow)
                            Text("Hints")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundStyle(Theme.textPrimary)
                            Spacer()
                            Text("\(viewModel.problem.hints.count) available")
                                .font(.caption)
                                .foregroundStyle(Theme.textSecondary)
                        }

                        ForEach(Array(viewModel.problem.hints.enumerated()), id: \.offset) { index, hint in
                            if index < revealedHints {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Hint \(index + 1)")
                                        .font(.caption2)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(Theme.accent)
                                    Text(hint)
                                        .font(.caption)
                                        .foregroundStyle(Theme.textSecondary)
                                }
                                .padding(10)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.yellow.opacity(0.08))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .transition(.opacity.combined(with: .move(edge: .top)))
                            } else if index == revealedHints {
                                Button {
                                    withAnimation(.easeOut(duration: 0.25)) {
                                        revealedHints += 1
                                    }
                                } label: {
                                    HStack {
                                        Image(systemName: "eye.slash")
                                            .font(.caption)
                                        Text("Tap to reveal Hint \(index + 1)")
                                            .font(.caption)
                                    }
                                    .foregroundStyle(Theme.accent)
                                    .padding(10)
                                    .frame(maxWidth: .infinity)
                                    .background(Theme.primaryDark.opacity(0.5))
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                            }
                        }
                    }
                    .padding(16)
                    .background(Theme.card)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                // Code editor
                VStack(alignment: .leading, spacing: 10) {
                    Text("Solution")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(Theme.textPrimary)

                    CodeEditorView(
                        text: $viewModel.sourceCode,
                        fontSize: CGFloat(editorFontSize),
                        onContentHeightChange: { height in
                            editorContentHeight = height
                        }
                    )
                    .frame(height: min(max(editorContentHeight, 150), 500))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .padding(16)
                .background(Theme.card)
                .clipShape(RoundedRectangle(cornerRadius: 12))

                // Run button
                Button {
                    Haptics.impact(.medium)
                    Task { await viewModel.executeCode() }
                } label: {
                    HStack {
                        if viewModel.isExecuting {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Image(systemName: "play.fill")
                        }
                        Text(viewModel.isExecuting ? "Running..." : "Run Code")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        viewModel.isExecuting
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
                .disabled(viewModel.isExecuting)

                // Error
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(.callout)
                        .foregroundStyle(.red)
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.red.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }

                // Results
                if let result = viewModel.executionResult {
                    ResultsView(result: result)
                }

                // Previous Attempts
                let attempts = SkillXPManager.shared.submissions(for: viewModel.problem.id)
                if !attempts.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                showHistory.toggle()
                            }
                        } label: {
                            HStack {
                                Image(systemName: "clock.arrow.circlepath")
                                    .foregroundStyle(Theme.accent)
                                Text("Previous Attempts")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(Theme.textPrimary)
                                Spacer()
                                Text("\(attempts.count)")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(Theme.accent)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(Theme.accent.opacity(0.15))
                                    .clipShape(Capsule())
                                Image(systemName: showHistory ? "chevron.up" : "chevron.down")
                                    .font(.caption)
                                    .foregroundStyle(Theme.textSecondary)
                            }
                        }

                        if showHistory {
                            ForEach(attempts) { attempt in
                                Button {
                                    viewModel.sourceCode = attempt.sourceCode
                                } label: {
                                    HStack {
                                        Image(systemName: attempt.passed ? "checkmark.circle.fill" : "xmark.circle.fill")
                                            .foregroundStyle(attempt.passed ? .green : .red)
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(attempt.timestamp, style: .relative)
                                                .font(.caption)
                                                .foregroundStyle(Theme.textPrimary)
                                            Text("\(attempt.testsPassed)/\(attempt.testsTotal) tests passed")
                                                .font(.caption2)
                                                .foregroundStyle(Theme.textSecondary)
                                        }
                                        Spacer()
                                        Image(systemName: "arrow.up.doc")
                                            .font(.caption)
                                            .foregroundStyle(Theme.accent)
                                    }
                                    .padding(10)
                                    .background(Theme.primaryDark.opacity(0.5))
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                            }
                        }
                    }
                    .padding(16)
                    .background(Theme.card)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding()
        }
        .background(Theme.surface)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbarBackground(Theme.primary, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                BackButton { dismiss() }
            }
            ToolbarItem(placement: .principal) {
                Text(viewModel.problem.title)
                    .font(.title3.bold())
                    .foregroundStyle(.white)
                    .lineLimit(1)
            }
        }
        .onChange(of: viewModel.executionResult?.overallStatus) {
            guard let status = viewModel.executionResult?.overallStatus else { return }
            if status == .pass {
                Haptics.notification(.success)
            } else {
                Haptics.notification(.error)
            }
        }
        .fullScreenCover(isPresented: $viewModel.showXPReward) {
            if let gains = viewModel.xpGains {
                XPRewardView(
                    gains: gains,
                    sourceCode: viewModel.sourceCode,
                    solutionExplanation: viewModel.problem.solutionExplanation,
                    optimalCode: viewModel.problem.optimalCode,
                    newAchievements: viewModel.newAchievements,
                    popToRoot: popToRoot
                )
            }
        }
    }
}
