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
    let hints: [String]
    let solutionExplanation: String?

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        difficulty = try container.decode(Difficulty.self, forKey: .difficulty)
        description = try container.decode(String.self, forKey: .description)
        examples = try container.decode([Example].self, forKey: .examples)
        functionSignature = try container.decode(String.self, forKey: .functionSignature)
        starterCode = try container.decode(String.self, forKey: .starterCode)
        tags = try container.decode([String].self, forKey: .tags)
        hints = (try? container.decode([String].self, forKey: .hints)) ?? []
        solutionExplanation = try container.decodeIfPresent(String.self, forKey: .solutionExplanation)
    }

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
