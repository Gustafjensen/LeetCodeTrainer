import Foundation

@Observable
class SkillXPManager {
    static let shared = SkillXPManager()

    var skillXP: [String: Int] = [:]

    static let xpPerLevel = 10

    private let storageKey = "skillXP"
    private let xpPerProblem = 5

    private init() {
        load()
    }

    func awardXP(for tags: [String]) -> [SkillXPGain] {
        var gains: [SkillXPGain] = []
        for tag in tags {
            let before = skillXP[tag] ?? 0
            let after = before + xpPerProblem
            skillXP[tag] = after
            gains.append(SkillXPGain(
                skill: tag,
                previousXP: before,
                newXP: after,
                gained: xpPerProblem
            ))
        }
        save()
        return gains
    }

    func xp(for skill: String) -> Int {
        skillXP[skill] ?? 0
    }

    func totalXP() -> Int {
        skillXP.values.reduce(0, +)
    }

    func level(for skill: String) -> Int {
        xp(for: skill) / Self.xpPerLevel
    }

    func progress(for skill: String) -> Double {
        Double(xp(for: skill) % Self.xpPerLevel) / Double(Self.xpPerLevel)
    }

    private func save() {
        UserDefaults.standard.set(skillXP, forKey: storageKey)
    }

    private func load() {
        if let stored = UserDefaults.standard.dictionary(forKey: storageKey) as? [String: Int] {
            skillXP = stored
        }
    }
}

struct SkillXPGain: Identifiable {
    let skill: String
    let previousXP: Int
    let newXP: Int
    let gained: Int

    var id: String { skill }

    var previousLevel: Int { previousXP / SkillXPManager.xpPerLevel }
    var newLevel: Int { newXP / SkillXPManager.xpPerLevel }
    var didLevelUp: Bool { newLevel > previousLevel }
    var previousProgress: Double { Double(previousXP % SkillXPManager.xpPerLevel) / Double(SkillXPManager.xpPerLevel) }
    var newProgress: Double { Double(newXP % SkillXPManager.xpPerLevel) / Double(SkillXPManager.xpPerLevel) }
}
