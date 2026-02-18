import SwiftUI

struct DailyProblemView: View {
    var viewModel: ProblemListViewModel

    private var dailyProblem: Problem? {
        guard !viewModel.problems.isEmpty else { return nil }
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: .now) ?? 0
        let index = dayOfYear % viewModel.problems.count
        return viewModel.problems[index]
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    if let problem = dailyProblem {
                        // Date banner
                        VStack(spacing: 6) {
                            Image(systemName: "star.fill")
                                .font(.title)
                                .foregroundStyle(Theme.accent)
                            Text("Daily Challenge")
                                .font(.headline)
                                .foregroundStyle(Theme.textPrimary)
                            Text(formattedDate)
                                .font(.caption)
                                .foregroundStyle(Theme.textSecondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 28)
                        .background(
                            LinearGradient(
                                colors: [Theme.card, Theme.cardLight],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16))

                        // Problem card
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text(problem.title)
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundStyle(Theme.textPrimary)
                                Spacer()
                                DifficultyBadge(difficulty: problem.difficulty)
                            }

                            Text(problem.description)
                                .font(.subheadline)
                                .foregroundStyle(Theme.textSecondary)
                                .lineLimit(4)

                            Theme.divider
                                .frame(height: 1)

                            NavigationLink(value: problem.id) {
                                HStack {
                                    Image(systemName: "play.fill")
                                    Text("Start Solving")
                                }
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
                        }
                        .padding(20)
                        .background(Theme.card)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    } else {
                        ProgressView()
                            .tint(Theme.accent)
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
                    Text("Daily Problem")
                        .font(.title3.bold())
                        .foregroundStyle(.white)
                }
            }
            .navigationDestination(for: String.self) { problemId in
                if let problem = viewModel.problems.first(where: { $0.id == problemId }) {
                    ProblemDetailView(viewModel: ProblemDetailViewModel(problem: problem))
                }
            }
        }
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: .now)
    }
}
