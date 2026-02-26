import SwiftUI

struct ProblemListView: View {
    @Bindable var viewModel: ProblemListViewModel
    @State private var path = NavigationPath()
    @State private var showSearch = false
    @FocusState private var isSearchFocused: Bool
    @Environment(\.horizontalSizeClass) private var sizeClass

    private var easyCount: Int { viewModel.problems.filter { $0.difficulty == .easy }.count }
    private var mediumCount: Int { viewModel.problems.filter { $0.difficulty == .medium }.count }
    private var hardCount: Int { viewModel.problems.filter { $0.difficulty == .hard }.count }

    private var columns: [GridItem] {
        AdaptiveLayout.gridColumns(for: sizeClass, compactCount: 2, regularCount: 3)
    }

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                VStack(spacing: 14) {
                    // Search field
                    if showSearch {
                        HStack(spacing: 8) {
                            Image(systemName: "magnifyingglass")
                                .foregroundStyle(Theme.textSecondary)
                            TextField("Search problems", text: $viewModel.searchText)
                                .focused($isSearchFocused)
                                .foregroundStyle(Theme.textPrimary)
                                .autocorrectionDisabled()
                                .textInputAutocapitalization(.never)
                        }
                        .padding(10)
                        .background(Theme.card)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding(.horizontal)
                    }

                    // Tag filter chips
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(viewModel.allTags, id: \.self) { tag in
                                TagChip(
                                    tag: tag,
                                    isSelected: viewModel.selectedTags.contains(tag)
                                ) {
                                    if viewModel.selectedTags.contains(tag) {
                                        viewModel.selectedTags.remove(tag)
                                    } else {
                                        viewModel.selectedTags.insert(tag)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }

                    if viewModel.isFiltering {
                        // Filtered results grid
                        let filtered = viewModel.filteredProblems
                        if filtered.isEmpty {
                            VStack(spacing: 8) {
                                Image(systemName: "magnifyingglass")
                                    .font(.title)
                                    .foregroundStyle(Theme.textSecondary)
                                Text("No problems found")
                                    .font(.subheadline)
                                    .foregroundStyle(Theme.textSecondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 40)
                        } else {
                            LazyVGrid(columns: columns, spacing: 12) {
                                ForEach(filtered) { problem in
                                    NavigationLink(value: problem.id) {
                                        FilteredProblemCard(problem: problem)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal)
                        }
                    } else {
                        // Default difficulty cards
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
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
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
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showSearch.toggle()
                            if showSearch {
                                isSearchFocused = true
                            } else {
                                viewModel.searchText = ""
                                isSearchFocused = false
                            }
                        }
                    } label: {
                        Image(systemName: showSearch ? "xmark" : "magnifyingglass")
                            .foregroundStyle(.white)
                    }
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
                    let vm = ProblemDetailViewModel(problem: problem)
                    let _ = vm.allProblems = viewModel.problems
                    ProblemDetailView(
                        viewModel: vm,
                        popToRoot: { path = NavigationPath() }
                    )
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

struct TagChip: View {
    let tag: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(tag)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(isSelected ? Theme.accent : Theme.card)
                .foregroundStyle(isSelected ? .white : Theme.textSecondary)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

struct FilteredProblemCard: View {
    let problem: Problem

    private var isSolved: Bool {
        SkillXPManager.shared.isSolved(problem.id)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Circle()
                    .fill(isSolved ? Color.green : difficultyColor)
                    .frame(width: 8, height: 8)
                Spacer()
                DifficultyBadge(difficulty: problem.difficulty)
            }

            Text(problem.title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(Theme.textPrimary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)

            Spacer(minLength: 0)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(minHeight: 90)
        .background(Theme.card)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var difficultyColor: Color {
        switch problem.difficulty {
        case .easy: return .green.opacity(0.4)
        case .medium: return .orange.opacity(0.4)
        case .hard: return .red.opacity(0.4)
        }
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
