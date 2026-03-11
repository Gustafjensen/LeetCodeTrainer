import Foundation

struct CodeSubmission: Codable, Identifiable {
    let id: String
    let problemId: String
    let timestamp: Date
    let sourceCode: String
    let passed: Bool
    let testsPassed: Int
    let testsTotal: Int
    let duration: TimeInterval?

    init(id: String, problemId: String, timestamp: Date, sourceCode: String, passed: Bool, testsPassed: Int, testsTotal: Int, duration: TimeInterval? = nil) {
        self.id = id
        self.problemId = problemId
        self.timestamp = timestamp
        self.sourceCode = sourceCode
        self.passed = passed
        self.testsPassed = testsPassed
        self.testsTotal = testsTotal
        self.duration = duration
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        problemId = try container.decode(String.self, forKey: .problemId)
        timestamp = try container.decode(Date.self, forKey: .timestamp)
        sourceCode = try container.decode(String.self, forKey: .sourceCode)
        passed = try container.decode(Bool.self, forKey: .passed)
        testsPassed = try container.decode(Int.self, forKey: .testsPassed)
        testsTotal = try container.decode(Int.self, forKey: .testsTotal)
        duration = try container.decodeIfPresent(TimeInterval.self, forKey: .duration)
    }
}
