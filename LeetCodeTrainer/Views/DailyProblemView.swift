import SwiftUI

struct DailyProblemView: View {
    var viewModel: ProblemListViewModel
    @State private var displayedMonth: Date = .now
    @State private var path = NavigationPath()
    @AppStorage("dailyDifficulty") private var dailyDifficulty: String = "All"
    private var xpManager: SkillXPManager { .shared }

    private var filteredProblems: [Problem] {
        if dailyDifficulty == "All" { return viewModel.problems }
        let filtered = viewModel.problems.filter { $0.difficulty.rawValue == dailyDifficulty }
        return filtered.isEmpty ? viewModel.problems : filtered
    }

    private var dailyProblem: Problem? {
        guard !filteredProblems.isEmpty else { return nil }
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: .now) ?? 0
        let index = dayOfYear % filteredProblems.count
        return filteredProblems[index]
    }

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                VStack(spacing: 16) {
                    StreakBannerView(
                        currentStreak: xpManager.currentStreak(),
                        longestStreak: xpManager.longestStreak()
                    )

                    // Difficulty filter
                    HStack(spacing: 8) {
                        ForEach(["All", "Easy", "Medium", "Hard"], id: \.self) { option in
                            Button {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    dailyDifficulty = option
                                }
                            } label: {
                                Text(option)
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 7)
                                    .background(dailyDifficulty == option ? difficultyColor(option) : Theme.card)
                                    .foregroundStyle(dailyDifficulty == option ? .white : Theme.textSecondary)
                                    .clipShape(Capsule())
                            }
                        }
                        Spacer()
                    }

                    CalendarMonthView(
                        displayedMonth: $displayedMonth,
                        completedDates: xpManager.completedDailyDates
                    )

                    if let problem = dailyProblem {
                        DailyChallengeCard(
                            problem: problem,
                            isCompleted: xpManager.isDailyCompleted(for: .now)
                        )
                    }

                    // Subtle widget hint
                    HStack(spacing: 6) {
                        Image(systemName: "square.grid.2x2")
                            .font(.caption2)
                        Text("Add home screen widget")
                            .font(.caption)
                    }
                    .foregroundStyle(Theme.textSecondary.opacity(0.5))
                    .padding(.top, 4)
                }
                .padding()
            }
            .background(Theme.surface)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Theme.primary, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Daily Challenge")
                        .font(.title3.bold())
                        .foregroundStyle(.white)
                }
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
            .onChange(of: xpManager.solvedProblems) {
                if let problem = dailyProblem,
                   xpManager.isSolved(problem.id),
                   !xpManager.isDailyCompleted(for: .now) {
                    xpManager.markDailyCompleted()
                }
            }
        }
    }

    private func difficultyColor(_ difficulty: String) -> Color {
        switch difficulty {
        case "Easy": return .green
        case "Medium": return .orange
        case "Hard": return .red
        default: return Theme.accent
        }
    }
}

// MARK: - Calendar Month View

struct CalendarMonthView: View {
    @Binding var displayedMonth: Date
    let completedDates: Set<String>

    private let calendar = Calendar.current
    private let weekdaySymbols = ["S", "M", "T", "W", "T", "F", "S"]
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()

    private static let monthYearFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MMMM yyyy"
        return f
    }()

    private var canGoForward: Bool {
        let currentMonth = calendar.dateInterval(of: .month, for: .now)!.start
        let displayed = calendar.dateInterval(of: .month, for: displayedMonth)!.start
        return displayed < currentMonth
    }

    var body: some View {
        VStack(spacing: 12) {
            // Month navigation
            HStack {
                Button { changeMonth(by: -1) } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Theme.accent)
                        .frame(width: 36, height: 36)
                        .background(Theme.accent.opacity(0.15))
                        .clipShape(Circle())
                }

                Spacer()

                Text(Self.monthYearFormatter.string(from: displayedMonth))
                    .font(.headline)
                    .foregroundStyle(Theme.textPrimary)

                Spacer()

                Button { changeMonth(by: 1) } label: {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(canGoForward ? Theme.accent : Theme.textSecondary.opacity(0.3))
                        .frame(width: 36, height: 36)
                        .background(Theme.accent.opacity(0.15))
                        .clipShape(Circle())
                }
                .disabled(!canGoForward)
            }

            // Weekday header
            LazyVGrid(columns: columns, spacing: 0) {
                ForEach(weekdaySymbols, id: \.self) { symbol in
                    Text(symbol)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(Theme.textSecondary)
                        .frame(height: 28)
                }
            }

            // Day cells
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(daysInMonth(), id: \.self) { item in
                    if item.day == 0 {
                        Color.clear.frame(height: 40)
                    } else {
                        DayCellView(
                            day: item.day,
                            isToday: item.isToday,
                            isCompleted: item.isCompleted,
                            isFuture: item.isFuture
                        )
                    }
                }
            }
        }
        .padding(16)
        .background(Theme.card)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func changeMonth(by offset: Int) {
        if let newMonth = calendar.date(byAdding: .month, value: offset, to: displayedMonth) {
            withAnimation(.easeInOut(duration: 0.2)) {
                displayedMonth = newMonth
            }
        }
    }

    private func daysInMonth() -> [DayItem] {
        let interval = calendar.dateInterval(of: .month, for: displayedMonth)!
        let firstDay = interval.start
        let weekdayOfFirst = calendar.component(.weekday, from: firstDay)
        let daysCount = calendar.range(of: .day, in: .month, for: displayedMonth)!.count
        let today = calendar.startOfDay(for: .now)

        var items: [DayItem] = []

        for _ in 0..<(weekdayOfFirst - 1) {
            items.append(DayItem(day: 0, isToday: false, isCompleted: false, isFuture: false))
        }

        for day in 1...daysCount {
            var components = calendar.dateComponents([.year, .month], from: displayedMonth)
            components.day = day
            let date = calendar.date(from: components)!
            let dateString = Self.dateFormatter.string(from: date)
            let isToday = calendar.isDate(date, inSameDayAs: today)
            let isFuture = date > today
            let isCompleted = completedDates.contains(dateString)
            items.append(DayItem(day: day, isToday: isToday, isCompleted: isCompleted, isFuture: isFuture))
        }

        return items
    }
}

// MARK: - Day Cell

struct DayItem: Hashable {
    let day: Int
    let isToday: Bool
    let isCompleted: Bool
    let isFuture: Bool
}

struct DayCellView: View {
    let day: Int
    let isToday: Bool
    let isCompleted: Bool
    let isFuture: Bool

    var body: some View {
        Text("\(day)")
            .font(.subheadline)
            .fontWeight(isToday || isCompleted ? .bold : .regular)
            .foregroundStyle(
                isFuture ? Theme.textSecondary.opacity(0.3) :
                isCompleted ? .white :
                isToday ? Theme.accent :
                Theme.textPrimary
            )
            .frame(width: 36, height: 36)
            .background(
                Group {
                    if isCompleted {
                        Circle().fill(Color.green.opacity(0.85))
                    } else if isToday {
                        Circle().stroke(Theme.accent, lineWidth: 2)
                    }
                }
            )
            .frame(maxWidth: .infinity)
            .frame(height: 40)
    }
}

// MARK: - Daily Challenge Card

struct DailyChallengeCard: View {
    let problem: Problem
    let isCompleted: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundStyle(Theme.accent)
                        Text("Today's Challenge")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(Theme.accent)
                    }
                    Text(problem.title)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(Theme.textPrimary)
                }
                Spacer()
                DifficultyBadge(difficulty: problem.difficulty)
            }

            Text(problem.description)
                .font(.subheadline)
                .foregroundStyle(Theme.textSecondary)
                .lineLimit(3)

            Theme.divider.frame(height: 1)

            if isCompleted {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    Text("Completed")
                        .fontWeight(.semibold)
                        .foregroundStyle(.green)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.green.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
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
        }
        .padding(20)
        .background(Theme.card)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Streak Banner

struct StreakBannerView: View {
    let currentStreak: Int
    let longestStreak: Int
    @State private var shareImage: UIImage?
    @State private var showShareSheet = false

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: "flame.fill")
                .font(.system(size: 32))
                .foregroundStyle(currentStreak > 0 ? .orange : Theme.textSecondary)

            VStack(alignment: .leading, spacing: 2) {
                if currentStreak > 0 {
                    Text("\(currentStreak) day streak")
                        .font(.headline)
                        .foregroundStyle(Theme.textPrimary)
                    Text("Longest: \(longestStreak) days")
                        .font(.caption)
                        .foregroundStyle(Theme.textSecondary)
                } else {
                    Text("Start your streak today!")
                        .font(.headline)
                        .foregroundStyle(Theme.textPrimary)
                    Text("Complete the daily challenge")
                        .font(.caption)
                        .foregroundStyle(Theme.textSecondary)
                }
            }

            Spacer()

            if currentStreak > 0 {
                Button {
                    generateShareImage()
                } label: {
                    Image(systemName: "square.and.arrow.up")
                        .font(.subheadline)
                        .foregroundStyle(Theme.accent)
                        .padding(8)
                        .background(Theme.accent.opacity(0.15))
                        .clipShape(Circle())
                }
            }
        }
        .padding(16)
        .background(
            LinearGradient(
                colors: [Theme.card, Theme.cardLight],
                startPoint: .leading, endPoint: .trailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .sheet(isPresented: $showShareSheet) {
            if let image = shareImage {
                ShareSheet(items: [image])
            }
        }
    }

    private func generateShareImage() {
        let xpManager = SkillXPManager.shared
        let card = StreakShareCard(
            userName: xpManager.userName,
            currentStreak: currentStreak,
            longestStreak: longestStreak,
            totalXP: xpManager.totalXP(),
            solvedCount: xpManager.solvedProblems.count
        )
        let renderer = ImageRenderer(content: card)
        renderer.scale = UIScreen.main.scale
        if let image = renderer.uiImage {
            shareImage = image
            showShareSheet = true
        }
    }
}
