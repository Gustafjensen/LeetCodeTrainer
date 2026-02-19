import Foundation

@Observable
class ProblemListViewModel {
    var problems: [Problem] = []
    var errorMessage: String?
    var searchText: String = ""
    var selectedTags: Set<String> = []

    var allTags: [String] {
        let tags = Set(problems.flatMap { $0.tags })
        return tags.sorted()
    }

    var isFiltering: Bool {
        !searchText.isEmpty || !selectedTags.isEmpty
    }

    var filteredProblems: [Problem] {
        problems.filter { problem in
            let matchesSearch = searchText.isEmpty ||
                problem.title.localizedCaseInsensitiveContains(searchText)
            let matchesTags = selectedTags.isEmpty ||
                selectedTags.isSubset(of: Set(problem.tags))
            return matchesSearch && matchesTags
        }
    }

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
