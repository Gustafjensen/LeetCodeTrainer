import SwiftUI

struct DifficultyProblemsView: View {
    let difficulty: Problem.Difficulty
    let problems: [Problem]
    @State private var selectedProblem: Problem?
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var sizeClass

    private var difficultyColor: Color {
        switch difficulty {
        case .easy: return .green
        case .medium: return .orange
        case .hard: return .red
        }
    }

    var body: some View {
        ScrollView {
            LazyVGrid(columns: AdaptiveLayout.gridColumns(for: sizeClass, compactCount: 2, regularCount: 4), spacing: 12) {
                ForEach(problems) { problem in
                    ProblemCard(
                        problem: problem,
                        color: difficultyColor,
                        onInfoTap: { selectedProblem = problem }
                    )
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
                Text(difficulty.rawValue)
                    .font(.title3.bold())
                    .foregroundStyle(.white)
            }
        }
        .sheet(item: $selectedProblem) { problem in
            ProblemInfoSheet(problem: problem, color: difficultyColor)
        }
    }
}

struct ProblemCard: View {
    let problem: Problem
    let color: Color
    let onInfoTap: () -> Void
    private var isSolved: Bool { SkillXPManager.shared.isSolved(problem.id) }

    var body: some View {
        NavigationLink(value: problem.id) {
            VStack(alignment: .leading, spacing: 0) {
                // Top bar with info button
                HStack {
                    Circle()
                        .fill(isSolved ? Color.green : color.opacity(0.3))
                        .frame(width: 8, height: 8)
                    Spacer()
                    Button {
                        onInfoTap()
                    } label: {
                        Image(systemName: "info.circle.fill")
                            .font(.subheadline)
                            .foregroundStyle(Theme.textSecondary)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.bottom, 10)

                // Title
                Text(problem.title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(Theme.textPrimary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                Spacer(minLength: 8)

                // Tags
                FlowLayout(spacing: 4) {
                    ForEach(problem.tags, id: \.self) { tag in
                        Text(tag)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(Theme.accent)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(Theme.accent.opacity(0.15))
                            .clipShape(Capsule())
                    }
                }
                    .lineLimit(1)
            }
            .padding(14)
            .frame(maxWidth: .infinity, minHeight: 120, alignment: .topLeading)
            .background(Theme.card)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(color.opacity(0.15), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

struct ProblemInfoSheet: View {
    let problem: Problem
    let color: Color
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Header
                    HStack {
                        Text(problem.title)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundStyle(Theme.textPrimary)
                        Spacer()
                        DifficultyBadge(difficulty: problem.difficulty)
                    }

                    // Description
                    Text(problem.description)
                        .font(.subheadline)
                        .foregroundStyle(Theme.textSecondary)

                    Theme.divider.frame(height: 1)

                    // Function signature
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Function Signature")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(Theme.accent)
                        Text(problem.functionSignature)
                            .font(.system(.caption, design: .monospaced))
                            .foregroundStyle(Theme.textPrimary)
                            .padding(10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Theme.primaryDark.opacity(0.5))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }

                    // Examples
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Examples")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(Theme.accent)

                        ForEach(Array(problem.examples.enumerated()), id: \.offset) { index, example in
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Example \(index + 1)")
                                    .font(.caption2)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(color)
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
                }
                .padding()
            }
            .background(Theme.card)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Theme.primary, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Problem Info")
                        .font(.headline)
                        .foregroundStyle(.white)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(Theme.accent)
                }
            }
        }
    }
}
