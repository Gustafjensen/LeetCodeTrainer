import Foundation

@Observable
class ProblemDetailViewModel {
    let problem: Problem
    var sourceCode: String
    var executionResult: ExecutionResult?
    var isExecuting: Bool = false
    var errorMessage: String?
    var errorIcon: String?
    var xpGains: [SkillXPGain]?
    var newAchievements: [Achievement] = []
    var showXPReward: Bool = false

    private let executionService: ExecutionService
    private let xpManager: SkillXPManager
    var allProblems: [Problem] = []

    init(problem: Problem, executionService: ExecutionService = ExecutionService(), xpManager: SkillXPManager = .shared) {
        self.problem = problem
        self.sourceCode = problem.starterCode
        self.executionService = executionService
        self.xpManager = xpManager
    }

    func executeCode() async {
        isExecuting = true
        errorMessage = nil
        errorIcon = nil
        executionResult = nil
        xpGains = nil
        newAchievements = []
        showXPReward = false

        do {
            let result = try await executionService.execute(
                problemId: problem.id,
                language: "python",
                sourceCode: sourceCode
            )
            executionResult = result

            let testsPassed = result.testResults.filter { $0.passed }.count
            let submission = CodeSubmission(
                id: UUID().uuidString,
                problemId: problem.id,
                timestamp: Date(),
                sourceCode: sourceCode,
                passed: result.overallStatus == .pass,
                testsPassed: testsPassed,
                testsTotal: result.testResults.count
            )
            xpManager.recordSubmission(submission)

            AnalyticsService.shared.track("code_run_result", properties: [
                "problem_id": problem.id,
                "passed": "\(result.overallStatus == .pass)",
                "tests_passed": "\(testsPassed)",
                "tests_total": "\(result.testResults.count)"
            ])

            if result.overallStatus == .pass {
                let gains = xpManager.awardXP(for: problem)
                xpGains = gains
                newAchievements = xpManager.checkAchievements(problems: allProblems)
                let totalXP = gains.reduce(0) { $0 + $1.gained }
                AnalyticsService.shared.track("problem_solved", properties: [
                    "problem_id": problem.id,
                    "difficulty": problem.difficulty.rawValue,
                    "xp_gained": "\(totalXP)"
                ])
                showXPReward = true
            }
        } catch let error as ExecutionService.ExecutionError {
            errorMessage = error.userMessage
            errorIcon = error.systemImage
            AnalyticsService.shared.track("code_run_error", properties: [
                "problem_id": problem.id,
                "error_type": "\(error)"
            ])
        } catch {
            errorMessage = "Something went wrong. Please try again."
            errorIcon = "exclamationmark.triangle"
            AnalyticsService.shared.track("code_run_error", properties: [
                "problem_id": problem.id,
                "error_type": "unknown"
            ])
        }

        isExecuting = false
    }
}
