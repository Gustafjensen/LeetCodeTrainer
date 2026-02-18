import Foundation

@Observable
class ProblemDetailViewModel {
    let problem: Problem
    var sourceCode: String
    var executionResult: ExecutionResult?
    var isExecuting: Bool = false
    var errorMessage: String?
    var xpGains: [SkillXPGain]?
    var showXPReward: Bool = false

    private let executionService: ExecutionService
    private let xpManager: SkillXPManager

    init(problem: Problem, executionService: ExecutionService = ExecutionService(), xpManager: SkillXPManager = .shared) {
        self.problem = problem
        self.sourceCode = problem.starterCode
        self.executionService = executionService
        self.xpManager = xpManager
    }

    func executeCode() async {
        isExecuting = true
        errorMessage = nil
        executionResult = nil
        xpGains = nil
        showXPReward = false

        do {
            let result = try await executionService.execute(
                problemId: problem.id,
                language: "python",
                sourceCode: sourceCode
            )
            executionResult = result

            if result.overallStatus == .pass {
                let gains = xpManager.awardXP(for: problem.tags)
                xpGains = gains
                showXPReward = true
            }
        } catch let error as ExecutionService.ExecutionError {
            switch error {
            case .networkError(let message):
                errorMessage = "Network error: \(message)"
            case .serverError(let message):
                errorMessage = "Server error: \(message)"
            case .timeout:
                errorMessage = "Execution timed out. Check for infinite loops."
            case .decodingError:
                errorMessage = "Failed to parse server response."
            }
        } catch {
            errorMessage = "Unexpected error: \(error.localizedDescription)"
        }

        isExecuting = false
    }
}
