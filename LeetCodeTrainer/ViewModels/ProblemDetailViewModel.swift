import Foundation

@Observable
class ProblemDetailViewModel {
    let problem: Problem
    var sourceCode: String
    var executionResult: ExecutionResult?
    var isExecuting: Bool = false
    var errorMessage: String?

    private let executionService: ExecutionService

    init(problem: Problem, executionService: ExecutionService = ExecutionService()) {
        self.problem = problem
        self.sourceCode = problem.starterCode
        self.executionService = executionService
    }

    func executeCode() async {
        isExecuting = true
        errorMessage = nil
        executionResult = nil

        do {
            let result = try await executionService.execute(
                problemId: problem.id,
                language: "python",
                sourceCode: sourceCode
            )
            executionResult = result
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
