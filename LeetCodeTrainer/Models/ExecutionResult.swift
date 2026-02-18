import Foundation

struct ExecutionResult: Codable {
    let compilationSuccess: Bool
    let runtimeError: String?
    let testResults: [TestCaseResult]
    let overallStatus: Status
    let runtime: String
    let memory: String

    enum Status: String, Codable {
        case pass
        case fail
        case error
    }
}

struct TestCaseResult: Codable, Identifiable {
    let input: String
    let expectedOutput: String
    let actualOutput: String
    let passed: Bool

    var id: String { input }
}
