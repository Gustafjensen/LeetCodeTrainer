import Foundation

struct CodeSubmission: Codable, Identifiable {
    let id: String
    let problemId: String
    let timestamp: Date
    let sourceCode: String
    let passed: Bool
    let testsPassed: Int
    let testsTotal: Int
}
