import Foundation

struct LintWarning: Identifiable, Equatable {
    let id: UUID
    let line: Int
    let column: Int
    let message: String
    let suggestion: String?
    let severity: Severity
    let category: Category
    let ruleId: String

    enum Severity: Int, Comparable, CaseIterable {
        case error = 0
        case warning = 1
        case hint = 2

        static func < (lhs: Self, rhs: Self) -> Bool {
            lhs.rawValue < rhs.rawValue
        }
    }

    enum Category: String, CaseIterable {
        case methodConfusion = "Method Confusion"
        case syntaxError = "Syntax Error"
        case logicalMistake = "Logical Mistake"
        case typeConfusion = "Type/Language Confusion"
        case python2vs3 = "Python 2 vs 3"
        case crossLanguage = "Cross-Language Syntax"
    }
}
