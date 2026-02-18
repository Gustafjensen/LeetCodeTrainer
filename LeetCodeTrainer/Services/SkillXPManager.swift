import Foundation

@Observable
class SkillXPManager {
    static let shared = SkillXPManager()

    var skillXP: [String: Int] = [:]
    var solvedProblems: Set<String> = []

    /// Cumulative XP thresholds to reach each level.
    static let levelThresholds = [0, 10, 50, 100, 150, 200]

    private let storageKey = "skillXP"
    private let solvedKey = "solvedProblems"

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
    }

    private func load() {
        if let stored = UserDefaults.standard.dictionary(forKey: storageKey) as? [String: Int] {
            skillXP = stored
        }
        if let stored = UserDefaults.standard.stringArray(forKey: solvedKey) {
            solvedProblems = Set(stored)
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
