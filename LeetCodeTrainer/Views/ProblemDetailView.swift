import SwiftUI

struct ProblemDetailView: View {
    @State var viewModel: ProblemDetailViewModel
    var popToRoot: () -> Void = {}
    @Environment(\.dismiss) private var dismiss
    @State private var isEditorFocused = false

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

                // Code editor
                VStack(alignment: .leading, spacing: 10) {
                    Text("Solution")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(Theme.textPrimary)

                    CodeEditorView(text: $viewModel.sourceCode) { focused in
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isEditorFocused = focused
                        }
                    }
                    .frame(minHeight: isEditorFocused ? 350 : 150,
                           maxHeight: isEditorFocused ? 500 : 200)
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
                    newAchievements: viewModel.newAchievements,
                    popToRoot: popToRoot
                )
            }
        }
    }
}
