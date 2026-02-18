import Foundation

struct Problem: Codable, Identifiable {
    let id: String
    let title: String
    let difficulty: Difficulty
    let description: String
    let examples: [Example]
    let functionSignature: String
    let starterCode: String
    let tags: [String]

    enum Difficulty: String, Codable {
        case easy = "Easy"
        case medium = "Medium"
        case hard = "Hard"
    }

    struct Example: Codable {
        let input: String
        let output: String
        let explanation: String?
    }
}
