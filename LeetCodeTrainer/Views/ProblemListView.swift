import SwiftUI

struct ProblemListView: View {
    var viewModel: ProblemListViewModel

    private var easyCount: Int { viewModel.problems.filter { $0.difficulty == .easy }.count }
    private var mediumCount: Int { viewModel.problems.filter { $0.difficulty == .medium }.count }
    private var hardCount: Int { viewModel.problems.filter { $0.difficulty == .hard }.count }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                    DifficultyCategoryCard(
                        title: "Easy",
                        subtitle: "\(easyCount) problems",
                        icon: "leaf.fill",
                        color: .green,
                        difficulty: .easy
                    )
                    DifficultyCategoryCard(
                        title: "Medium",
                        subtitle: "\(mediumCount) problems",
                        icon: "flame.fill",
                        color: .orange,
                        difficulty: .medium
                    )
                    DifficultyCategoryCard(
                        title: "Hard",
                        subtitle: "\(hardCount) problems",
                        icon: "bolt.fill",
                        color: .red,
                        difficulty: .hard
                    )
                }
                .padding()
            }
            .background(Theme.surface)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Theme.primary, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Problems")
                        .font(.title3.bold())
                        .foregroundStyle(.white)
                }
            }
            .navigationDestination(for: Problem.Difficulty.self) { difficulty in
                DifficultyProblemsView(
                    difficulty: difficulty,
                    problems: viewModel.problems.filter { $0.difficulty == difficulty }
                )
            }
            .navigationDestination(for: String.self) { problemId in
                if let problem = viewModel.problems.first(where: { $0.id == problemId }) {
                    ProblemDetailView(viewModel: ProblemDetailViewModel(problem: problem))
                }
            }
        }
    }
}

struct DifficultyCategoryCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let difficulty: Problem.Difficulty

    var body: some View {
        NavigationLink(value: difficulty) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(color.opacity(0.2))
                        .frame(width: 52, height: 52)
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundStyle(color)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(Theme.textPrimary)
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(Theme.textSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Theme.textSecondary)
            }
            .padding(18)
            .background(Theme.card)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }
}

struct DifficultyBadge: View {
    let difficulty: Problem.Difficulty

    private var color: Color {
        switch difficulty {
        case .easy: return .green
        case .medium: return .orange
        case .hard: return .red
        }
    }

    var body: some View {
        Text(difficulty.rawValue)
            .font(.caption)
            .fontWeight(.semibold)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.2))
            .foregroundStyle(color)
            .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}
