import Foundation

@Observable
class ProblemListViewModel {
    var problems: [Problem] = []
    var errorMessage: String?

    init() {
        loadProblems()
    }

    private func loadProblems() {
        guard let url = Bundle.main.url(forResource: "problems", withExtension: "json") else {
            errorMessage = "Could not find problems.json"
            return
        }
        do {
            let data = try Data(contentsOf: url)
            problems = try JSONDecoder().decode([Problem].self, from: data)
        } catch {
            errorMessage = "Failed to load problems: \(error.localizedDescription)"
        }
    }
}
