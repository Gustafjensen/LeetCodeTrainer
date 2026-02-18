import Foundation

@Observable
class SkillXPManager {
    static let shared = SkillXPManager()

    var skillXP: [String: Int] = [:]

    private let storageKey = "skillXP"
    private let xpPerProblem = 25

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
        xp(for: skill) / 100
    }

    func progress(for skill: String) -> Double {
        Double(xp(for: skill) % 100) / 100.0
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

    var previousLevel: Int { previousXP / 100 }
    var newLevel: Int { newXP / 100 }
    var didLevelUp: Bool { newLevel > previousLevel }
    var previousProgress: Double { Double(previousXP % 100) / 100.0 }
    var newProgress: Double { Double(newXP % 100) / 100.0 }
}
