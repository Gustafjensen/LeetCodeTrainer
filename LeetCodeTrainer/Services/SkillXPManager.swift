import Foundation
import SwiftUI

@Observable
class SkillXPManager {
    static let shared = SkillXPManager()

    var skillXP: [String: Int] = [:]
    var solvedProblems: Set<String> = []
    var completedDailyDates: Set<String> = []

    /// Cumulative XP thresholds to reach each level.
    static let levelThresholds = [0, 10, 50, 100, 150, 200]

    private let storageKey = "skillXP"
    private let solvedKey = "solvedProblems"
    private let dailyCompletionsKey = "completedDailyDates"

    private static let dailyDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()

    static func xpPerProblem(difficulty: Problem.Difficulty, isSolved: Bool) -> Int {
        if isSolved { return 10 }
        switch difficulty {
        case .easy: return 25
        case .medium: return 40
        case .hard: return 60
        }
    }

    private init() {
        load()
    }

    // MARK: - Static level helpers

    static func level(forXP xp: Int) -> Int {
        for i in stride(from: levelThresholds.count - 1, through: 0, by: -1) {
            if xp >= levelThresholds[i] {
                return i
            }
        }
        return 0
    }

    static func xpForLevel(_ level: Int) -> Int {
        if level < levelThresholds.count {
            return levelThresholds[level]
        }
        let lastDefined = levelThresholds.last!
        return lastDefined + (level - levelThresholds.count + 1) * 200
    }

    static func xpNeededForNextLevel(atLevel level: Int) -> Int {
        xpForLevel(level + 1) - xpForLevel(level)
    }

    static func progress(forXP xp: Int) -> Double {
        let lvl = level(forXP: xp)
        let currentThreshold = xpForLevel(lvl)
        let needed = xpNeededForNextLevel(atLevel: lvl)
        return Double(xp - currentThreshold) / Double(needed)
    }

    static func xpInCurrentLevel(forXP xp: Int) -> Int {
        let lvl = level(forXP: xp)
        return xp - xpForLevel(lvl)
    }

    // MARK: - Instance methods

    func awardXP(for problem: Problem) -> [SkillXPGain] {
        let alreadySolved = solvedProblems.contains(problem.id)
        let xp = Self.xpPerProblem(difficulty: problem.difficulty, isSolved: alreadySolved)

        var gains: [SkillXPGain] = []
        for tag in problem.tags {
            let before = skillXP[tag] ?? 0
            let after = before + xp
            skillXP[tag] = after
            gains.append(SkillXPGain(
                skill: tag,
                previousXP: before,
                newXP: after,
                gained: xp
            ))
        }

        solvedProblems.insert(problem.id)
        save()
        return gains
    }

    func isSolved(_ problemId: String) -> Bool {
        solvedProblems.contains(problemId)
    }

    func markDailyCompleted(for date: Date = .now) {
        let key = Self.dailyDateFormatter.string(from: date)
        completedDailyDates.insert(key)
        save()
    }

    func isDailyCompleted(for date: Date) -> Bool {
        let key = Self.dailyDateFormatter.string(from: date)
        return completedDailyDates.contains(key)
    }

    func currentStreak() -> Int {
        let cal = Calendar.current
        var date = cal.startOfDay(for: .now)

        // If today isn't completed yet, start checking from yesterday
        if !completedDailyDates.contains(Self.dailyDateFormatter.string(from: date)) {
            guard let yesterday = cal.date(byAdding: .day, value: -1, to: date) else { return 0 }
            date = yesterday
        }

        var streak = 0
        while completedDailyDates.contains(Self.dailyDateFormatter.string(from: date)) {
            streak += 1
            guard let prev = cal.date(byAdding: .day, value: -1, to: date) else { break }
            date = prev
        }
        return streak
    }

    func longestStreak() -> Int {
        guard !completedDailyDates.isEmpty else { return 0 }
        let sorted = completedDailyDates.sorted()
        let cal = Calendar.current
        var longest = 1
        var current = 1

        for i in 1..<sorted.count {
            if let prev = Self.dailyDateFormatter.date(from: sorted[i - 1]),
               let curr = Self.dailyDateFormatter.date(from: sorted[i]),
               let next = cal.date(byAdding: .day, value: 1, to: prev),
               cal.isDate(curr, inSameDayAs: next) {
                current += 1
                longest = max(longest, current)
            } else {
                current = 1
            }
        }
        return longest
    }

    func xp(for skill: String) -> Int {
        skillXP[skill] ?? 0
    }

    func totalXP() -> Int {
        skillXP.values.reduce(0, +)
    }

    func level(for skill: String) -> Int {
        Self.level(forXP: xp(for: skill))
    }

    func progress(for skill: String) -> Double {
        Self.progress(forXP: xp(for: skill))
    }

    private func save() {
        UserDefaults.standard.set(skillXP, forKey: storageKey)
        UserDefaults.standard.set(Array(solvedProblems), forKey: solvedKey)
        UserDefaults.standard.set(Array(completedDailyDates), forKey: dailyCompletionsKey)
    }

    private func load() {
        if let stored = UserDefaults.standard.dictionary(forKey: storageKey) as? [String: Int] {
            skillXP = stored
        }
        if let stored = UserDefaults.standard.stringArray(forKey: solvedKey) {
            solvedProblems = Set(stored)
        }
        if let stored = UserDefaults.standard.stringArray(forKey: dailyCompletionsKey) {
            completedDailyDates = Set(stored)
        }
    }
}

struct SkillXPGain: Identifiable {
    let skill: String
    let previousXP: Int
    let newXP: Int
    let gained: Int

    var id: String { skill }

    var previousLevel: Int { SkillXPManager.level(forXP: previousXP) }
    var newLevel: Int { SkillXPManager.level(forXP: newXP) }
    var didLevelUp: Bool { newLevel > previousLevel }
    var previousProgress: Double { SkillXPManager.progress(forXP: previousXP) }
    var newProgress: Double { SkillXPManager.progress(forXP: newXP) }
}

struct Achievement: Identifiable {
    let id: String
    let title: String
    let description: String
    let icon: String
    let color: Color

    func isUnlocked(manager: SkillXPManager, problems: [Problem]) -> Bool {
        switch id {
        case "first-solve": return manager.solvedProblems.count >= 1
        case "five-solved": return manager.solvedProblems.count >= 5
        case "twenty-solved": return manager.solvedProblems.count >= 20
        case "streak-3": return manager.longestStreak() >= 3
        case "streak-7": return manager.longestStreak() >= 7
        case "streak-30": return manager.longestStreak() >= 30
        case "first-medium":
            return problems.contains { $0.difficulty == .medium && manager.isSolved($0.id) }
        case "first-hard":
            return problems.contains { $0.difficulty == .hard && manager.isSolved($0.id) }
        case "xp-100": return manager.totalXP() >= 100
        case "xp-500": return manager.totalXP() >= 500
        default: return false
        }
    }

    static let all: [Achievement] = [
        Achievement(id: "first-solve", title: "First Steps", description: "Solve your first problem", icon: "star.fill", color: .yellow),
        Achievement(id: "five-solved", title: "Problem Solver", description: "Solve 5 problems", icon: "checkmark.circle.fill", color: .green),
        Achievement(id: "twenty-solved", title: "Veteran", description: "Solve 20 problems", icon: "trophy.fill", color: .purple),
        Achievement(id: "streak-3", title: "On Fire", description: "Reach a 3-day streak", icon: "flame.fill", color: .orange),
        Achievement(id: "streak-7", title: "Week Warrior", description: "Reach a 7-day streak", icon: "flame.fill", color: .orange),
        Achievement(id: "streak-30", title: "Unstoppable", description: "Reach a 30-day streak", icon: "flame.fill", color: .red),
        Achievement(id: "first-medium", title: "Stepping Up", description: "Solve a medium problem", icon: "arrow.up.circle.fill", color: .orange),
        Achievement(id: "first-hard", title: "Fearless", description: "Solve a hard problem", icon: "bolt.fill", color: .red),
        Achievement(id: "xp-100", title: "XP Hunter", description: "Earn 100 total XP", icon: "star.circle.fill", color: .blue),
        Achievement(id: "xp-500", title: "XP Master", description: "Earn 500 total XP", icon: "star.circle.fill", color: .purple),
    ]
}
