import Foundation

final class PythonLinter {
    static let shared = PythonLinter()

    private let rules: [LintRule]

    private init() {
        rules = Self.buildRules()
    }

    // MARK: - Public API

    func lint(_ code: String) -> [LintWarning] {
        guard !code.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return [] }

        let excludedRanges = computeExcludedRanges(in: code)
        var warnings: [LintWarning] = []

        for rule in rules {
            if rule.lineOnly {
                warnings.append(contentsOf: lintPerLine(code, rule: rule, excludedRanges: excludedRanges))
            } else {
                warnings.append(contentsOf: lintFullText(code, rule: rule, excludedRanges: excludedRanges))
            }
        }

        warnings.sort { ($0.line, $0.severity) < ($1.line, $1.severity) }
        return deduplicate(warnings)
    }

    // MARK: - String/Comment Exclusion

    private func computeExcludedRanges(in code: String) -> [NSRange] {
        let fullRange = NSRange(location: 0, length: (code as NSString).length)
        var ranges: [NSRange] = []

        // Triple-quoted strings first (greedy match)
        for pattern in ["\"\"\"[\\s\\S]*?\"\"\"", "'''[\\s\\S]*?'''"] {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .dotMatchesLineSeparators) {
                for match in regex.matches(in: code, range: fullRange) {
                    if !overlaps(match.range, with: ranges) {
                        ranges.append(match.range)
                    }
                }
            }
        }

        // Single-line strings
        for pattern in ["\"[^\"\\n]*\"", "'[^'\\n]*'"] {
            if let regex = try? NSRegularExpression(pattern: pattern) {
                for match in regex.matches(in: code, range: fullRange) {
                    if !overlaps(match.range, with: ranges) {
                        ranges.append(match.range)
                    }
                }
            }
        }

        // Comments: # to end of line
        if let regex = try? NSRegularExpression(pattern: "#.*$", options: .anchorsMatchLines) {
            for match in regex.matches(in: code, range: fullRange) {
                if !overlaps(match.range, with: ranges) {
                    ranges.append(match.range)
                }
            }
        }

        return ranges
    }

    private func overlaps(_ range: NSRange, with existing: [NSRange]) -> Bool {
        existing.contains { NSIntersectionRange(range, $0).length > 0 }
    }

    private func isExcluded(_ range: NSRange, in excludedRanges: [NSRange]) -> Bool {
        excludedRanges.contains { excluded in
            excluded.location <= range.location &&
            excluded.location + excluded.length >= range.location + range.length
        }
    }

    // MARK: - Lint Execution

    private func lintPerLine(_ code: String, rule: LintRule, excludedRanges: [NSRange]) -> [LintWarning] {
        let lines = code.components(separatedBy: "\n")
        var warnings: [LintWarning] = []
        var offset = 0

        for (index, line) in lines.enumerated() {
            let lineLen = (line as NSString).length
            let lineRange = NSRange(location: 0, length: lineLen)

            for match in rule.pattern.matches(in: line, range: lineRange) {
                let absoluteRange = NSRange(location: offset + match.range.location, length: match.range.length)
                if !isExcluded(absoluteRange, in: excludedRanges) {
                    warnings.append(LintWarning(
                        id: UUID(),
                        line: index + 1,
                        column: match.range.location + 1,
                        message: rule.message,
                        suggestion: rule.suggestion,
                        severity: rule.severity,
                        category: rule.category,
                        ruleId: rule.id
                    ))
                }
            }

            offset += lineLen + 1 // +1 for \n
        }

        return warnings
    }

    private func lintFullText(_ code: String, rule: LintRule, excludedRanges: [NSRange]) -> [LintWarning] {
        let nsCode = code as NSString
        let fullRange = NSRange(location: 0, length: nsCode.length)
        var warnings: [LintWarning] = []

        for match in rule.pattern.matches(in: code, range: fullRange) {
            if !isExcluded(match.range, in: excludedRanges) {
                let (line, column) = lineAndColumn(for: match.range.location, in: nsCode)
                warnings.append(LintWarning(
                    id: UUID(),
                    line: line,
                    column: column,
                    message: rule.message,
                    suggestion: rule.suggestion,
                    severity: rule.severity,
                    category: rule.category,
                    ruleId: rule.id
                ))
            }
        }

        return warnings
    }

    private func lineAndColumn(for offset: Int, in nsCode: NSString) -> (Int, Int) {
        let prefix = nsCode.substring(to: offset)
        let lines = prefix.components(separatedBy: "\n")
        return (lines.count, (lines.last?.utf16.count ?? 0) + 1)
    }

    private func deduplicate(_ warnings: [LintWarning]) -> [LintWarning] {
        var seen = Set<String>()
        return warnings.filter { w in
            let key = "\(w.line):\(w.ruleId)"
            if seen.contains(key) { return false }
            seen.insert(key)
            return true
        }
    }

    // MARK: - Regex Helper

    private static func re(_ pattern: String, options: NSRegularExpression.Options = []) -> NSRegularExpression {
        try! NSRegularExpression(pattern: pattern, options: options)
    }

    // MARK: - Rule Definitions

    private static func buildRules() -> [LintRule] {
        var rules: [LintRule] = []

        // ============================================================
        // CATEGORY 1: Method Confusion (17 rules)
        // ============================================================

        rules.append(LintRule(
            id: "method-length", pattern: re("\\.length\\b"),
            message: "Python uses len(x), not .length",
            suggestion: "Use len(x) instead",
            severity: .error, category: .methodConfusion, lineOnly: false
        ))

        rules.append(LintRule(
            id: "method-size", pattern: re("\\.size\\(\\)"),
            message: "Python uses len(x), not .size()",
            suggestion: "Use len(x) instead",
            severity: .error, category: .methodConfusion, lineOnly: false
        ))

        rules.append(LintRule(
            id: "method-push", pattern: re("\\.push\\("),
            message: "Python lists use .append(), not .push()",
            suggestion: "Use .append() instead",
            severity: .error, category: .methodConfusion, lineOnly: false
        ))

        rules.append(LintRule(
            id: "method-uppercase", pattern: re("\\.uppercase\\("),
            message: "Python uses .upper(), not .uppercase()",
            suggestion: "Use .upper() instead",
            severity: .error, category: .methodConfusion, lineOnly: false
        ))

        rules.append(LintRule(
            id: "method-lowercase", pattern: re("\\.lowercase\\("),
            message: "Python uses .lower(), not .lowercase()",
            suggestion: "Use .lower() instead",
            severity: .error, category: .methodConfusion, lineOnly: false
        ))

        rules.append(LintRule(
            id: "method-contains", pattern: re("\\.contains\\("),
            message: "Python uses 'x in y', not .contains()",
            suggestion: "Use the 'in' operator",
            severity: .warning, category: .methodConfusion, lineOnly: false
        ))

        rules.append(LintRule(
            id: "method-indexof", pattern: re("\\.indexOf\\("),
            message: "Python uses .index(), not .indexOf()",
            suggestion: "Use .index() instead",
            severity: .error, category: .methodConfusion, lineOnly: false
        ))

        rules.append(LintRule(
            id: "method-tostring", pattern: re("\\.toString\\("),
            message: "Python uses str(x), not .toString()",
            suggestion: "Use str(x) instead",
            severity: .error, category: .methodConfusion, lineOnly: false
        ))

        rules.append(LintRule(
            id: "method-toint", pattern: re("\\.toInt\\(|\\bparseInt\\("),
            message: "Python uses int(x), not .toInt() or parseInt()",
            suggestion: "Use int(x) instead",
            severity: .error, category: .methodConfusion, lineOnly: false
        ))

        rules.append(LintRule(
            id: "method-charat", pattern: re("\\.charAt\\("),
            message: "Python uses x[i] indexing, not .charAt()",
            suggestion: "Use x[i] instead",
            severity: .error, category: .methodConfusion, lineOnly: false
        ))

        rules.append(LintRule(
            id: "method-substring", pattern: re("\\.substring\\("),
            message: "Python uses slicing x[a:b], not .substring()",
            suggestion: "Use x[a:b] slicing",
            severity: .error, category: .methodConfusion, lineOnly: false
        ))

        rules.append(LintRule(
            id: "method-haskey", pattern: re("\\.has_key\\("),
            message: ".has_key() was removed in Python 3",
            suggestion: "Use 'key in dict' instead",
            severity: .error, category: .methodConfusion, lineOnly: false
        ))

        rules.append(LintRule(
            id: "method-sort-assign", pattern: re("\\w+\\s*=\\s*\\w[\\w.]*\\.sort\\("),
            message: ".sort() returns None — it sorts in-place",
            suggestion: "Use sorted(x) to get a new sorted list",
            severity: .warning, category: .methodConfusion, lineOnly: true
        ))

        rules.append(LintRule(
            id: "method-append-assign", pattern: re("\\w+\\s*=\\s*\\w[\\w.]*\\.append\\("),
            message: ".append() returns None — it modifies in-place",
            suggestion: "Call .append() as a statement, don't assign it",
            severity: .warning, category: .methodConfusion, lineOnly: true
        ))

        rules.append(LintRule(
            id: "method-reverse-assign", pattern: re("\\w+\\s*=\\s*\\w[\\w.]*\\.reverse\\("),
            message: ".reverse() returns None — it reverses in-place",
            suggestion: "Use list(reversed(x)) or x[::-1]",
            severity: .warning, category: .methodConfusion, lineOnly: true
        ))

        rules.append(LintRule(
            id: "method-extend-assign", pattern: re("\\w+\\s*=\\s*\\w[\\w.]*\\.extend\\("),
            message: ".extend() returns None — it modifies in-place",
            suggestion: "Call .extend() as a statement or use +",
            severity: .warning, category: .methodConfusion, lineOnly: true
        ))

        rules.append(LintRule(
            id: "method-math-js", pattern: re("\\bMath\\.[a-zA-Z]+\\("),
            message: "Python uses lowercase 'math' module, not 'Math'",
            suggestion: "import math; use math.xxx()",
            severity: .error, category: .methodConfusion, lineOnly: false
        ))

        // ============================================================
        // CATEGORY 2: Syntax Errors (18 rules)
        // ============================================================

        // Missing colon rules (per-line)
        rules.append(LintRule(
            id: "syntax-if-colon", pattern: re("^\\s*if\\s+.+[^:\\s]\\s*$"),
            message: "Missing ':' at end of 'if' statement",
            suggestion: "Add ':' at end of line",
            severity: .error, category: .syntaxError, lineOnly: true
        ))

        rules.append(LintRule(
            id: "syntax-elif-colon", pattern: re("^\\s*elif\\s+.+[^:\\s]\\s*$"),
            message: "Missing ':' at end of 'elif' statement",
            suggestion: "Add ':' at end of line",
            severity: .error, category: .syntaxError, lineOnly: true
        ))

        rules.append(LintRule(
            id: "syntax-else-colon", pattern: re("^\\s*else\\s*$"),
            message: "Missing ':' after 'else'",
            suggestion: "Use 'else:'",
            severity: .error, category: .syntaxError, lineOnly: true
        ))

        rules.append(LintRule(
            id: "syntax-for-colon", pattern: re("^\\s*for\\s+.+[^:\\s]\\s*$"),
            message: "Missing ':' at end of 'for' statement",
            suggestion: "Add ':' at end of line",
            severity: .error, category: .syntaxError, lineOnly: true
        ))

        rules.append(LintRule(
            id: "syntax-while-colon", pattern: re("^\\s*while\\s+.+[^:\\s]\\s*$"),
            message: "Missing ':' at end of 'while' statement",
            suggestion: "Add ':' at end of line",
            severity: .error, category: .syntaxError, lineOnly: true
        ))

        rules.append(LintRule(
            id: "syntax-def-colon", pattern: re("^\\s*def\\s+\\w+\\s*\\([^)]*\\)\\s*(?:->\\s*[^:]+)?\\s*$"),
            message: "Missing ':' at end of function definition",
            suggestion: "Add ':' after the closing parenthesis",
            severity: .error, category: .syntaxError, lineOnly: true
        ))

        rules.append(LintRule(
            id: "syntax-class-colon", pattern: re("^\\s*class\\s+\\w+[^:]*$"),
            message: "Missing ':' at end of class definition",
            suggestion: "Add ':' at end of line",
            severity: .error, category: .syntaxError, lineOnly: true
        ))

        rules.append(LintRule(
            id: "syntax-try-colon", pattern: re("^\\s*try\\s*$"),
            message: "Missing ':' after 'try'",
            suggestion: "Use 'try:'",
            severity: .error, category: .syntaxError, lineOnly: true
        ))

        rules.append(LintRule(
            id: "syntax-except-colon", pattern: re("^\\s*except(\\s+\\w[\\w.]*)?\\s*$"),
            message: "Missing ':' at end of 'except' statement",
            suggestion: "Add ':' at end of line",
            severity: .error, category: .syntaxError, lineOnly: true
        ))

        rules.append(LintRule(
            id: "syntax-finally-colon", pattern: re("^\\s*finally\\s*$"),
            message: "Missing ':' after 'finally'",
            suggestion: "Use 'finally:'",
            severity: .error, category: .syntaxError, lineOnly: true
        ))

        // Operator confusion
        rules.append(LintRule(
            id: "syntax-and-operator", pattern: re("&&"),
            message: "Python uses 'and', not '&&'",
            suggestion: "Replace '&&' with 'and'",
            severity: .error, category: .syntaxError, lineOnly: false
        ))

        rules.append(LintRule(
            id: "syntax-or-operator", pattern: re("\\|\\|"),
            message: "Python uses 'or', not '||'",
            suggestion: "Replace '||' with 'or'",
            severity: .error, category: .syntaxError, lineOnly: false
        ))

        rules.append(LintRule(
            id: "syntax-not-operator", pattern: re("(?<!=)!(?!=)\\s*[a-zA-Z(]"),
            message: "Python uses 'not', not '!'",
            suggestion: "Replace '!' with 'not '",
            severity: .warning, category: .syntaxError, lineOnly: false
        ))

        rules.append(LintRule(
            id: "syntax-increment", pattern: re("\\w\\+\\+|\\+\\+\\w"),
            message: "Python has no ++ operator",
            suggestion: "Use x += 1 instead",
            severity: .error, category: .syntaxError, lineOnly: false
        ))

        rules.append(LintRule(
            id: "syntax-decrement", pattern: re("\\w--|--\\w"),
            message: "Python has no -- operator",
            suggestion: "Use x -= 1 instead",
            severity: .error, category: .syntaxError, lineOnly: false
        ))

        rules.append(LintRule(
            id: "syntax-braces", pattern: re("(?:if|else|for|while|def|class)\\s*.*\\{\\s*$"),
            message: "Python uses indentation for blocks, not curly braces",
            suggestion: "Remove '{' and use indentation",
            severity: .error, category: .syntaxError, lineOnly: true
        ))

        rules.append(LintRule(
            id: "syntax-semicolon", pattern: re(";\\s*$"),
            message: "Semicolons are not needed in Python",
            suggestion: "Remove the semicolon",
            severity: .hint, category: .syntaxError, lineOnly: true
        ))

        rules.append(LintRule(
            id: "syntax-double-slash-comment", pattern: re("^\\s*//"),
            message: "Python uses # for comments, not //",
            suggestion: "Replace // with #",
            severity: .error, category: .syntaxError, lineOnly: true
        ))

        rules.append(LintRule(
            id: "syntax-block-comment", pattern: re("/\\*"),
            message: "Python doesn't use /* */ comments",
            suggestion: "Use # for comments",
            severity: .error, category: .syntaxError, lineOnly: false
        ))

        // ============================================================
        // CATEGORY 3: Logical Mistakes (12 rules)
        // ============================================================

        rules.append(LintRule(
            id: "logic-xor-power", pattern: re("\\b\\d+\\s*\\^\\s*\\d+"),
            message: "'^' is bitwise XOR in Python, not exponentiation",
            suggestion: "Use ** for power (e.g., 2**3)",
            severity: .warning, category: .logicalMistake, lineOnly: false
        ))

        rules.append(LintRule(
            id: "logic-or-comparison", pattern: re("==\\s*\\w+\\s+or\\s+\\w+\\s*:"),
            message: "This may not work as expected — the right side is always truthy",
            suggestion: "Use 'x == a or x == b' or 'x in (a, b)'",
            severity: .warning, category: .logicalMistake, lineOnly: true
        ))

        rules.append(LintRule(
            id: "logic-mutable-default-list", pattern: re("def\\s+\\w+\\s*\\([^)]*=\\s*\\[\\s*\\]"),
            message: "Mutable default argument [] — shared across calls",
            suggestion: "Use None as default, create list inside function",
            severity: .warning, category: .logicalMistake, lineOnly: true
        ))

        rules.append(LintRule(
            id: "logic-mutable-default-dict", pattern: re("def\\s+\\w+\\s*\\([^)]*=\\s*\\{\\s*\\}"),
            message: "Mutable default argument {} — shared across calls",
            suggestion: "Use None as default, create dict inside function",
            severity: .warning, category: .logicalMistake, lineOnly: true
        ))

        rules.append(LintRule(
            id: "logic-is-literal", pattern: re("\\bis\\s+\\d|\\bis\\s+['\"]"),
            message: "'is' checks identity, not equality",
            suggestion: "Use == for value comparison",
            severity: .warning, category: .logicalMistake, lineOnly: false
        ))

        rules.append(LintRule(
            id: "logic-eq-none", pattern: re("==\\s*None\\b"),
            message: "Use 'is None' instead of '== None'",
            suggestion: "Replace '== None' with 'is None'",
            severity: .hint, category: .logicalMistake, lineOnly: false
        ))

        rules.append(LintRule(
            id: "logic-neq-none", pattern: re("!=\\s*None\\b"),
            message: "Use 'is not None' instead of '!= None'",
            suggestion: "Replace '!= None' with 'is not None'",
            severity: .hint, category: .logicalMistake, lineOnly: false
        ))

        rules.append(LintRule(
            id: "logic-eq-bool", pattern: re("==\\s*True\\b|==\\s*False\\b"),
            message: "Don't compare to True/False explicitly",
            suggestion: "Use 'if x:' or 'if not x:' directly",
            severity: .hint, category: .logicalMistake, lineOnly: false
        ))

        rules.append(LintRule(
            id: "logic-assign-in-condition", pattern: re("(?:if|while)\\s+\\w+\\s*=[^=]"),
            message: "Single '=' is assignment — did you mean '=='?",
            suggestion: "Use == for comparison",
            severity: .warning, category: .logicalMistake, lineOnly: true
        ))

        rules.append(LintRule(
            id: "logic-nested-list-multiply", pattern: re("\\[\\s*\\[.*\\]\\s*\\]\\s*\\*\\s*\\w+"),
            message: "Multiplying nested lists creates shared references",
            suggestion: "Use [row[:] for _ in range(n)] or list comprehension",
            severity: .warning, category: .logicalMistake, lineOnly: false
        ))

        rules.append(LintRule(
            id: "logic-len-zero", pattern: re("\\blen\\(\\w+\\)\\s*==\\s*0"),
            message: "Prefer 'not x' over 'len(x) == 0'",
            suggestion: "Use 'if not x:' instead",
            severity: .hint, category: .logicalMistake, lineOnly: false
        ))

        rules.append(LintRule(
            id: "logic-len-positive", pattern: re("\\blen\\(\\w+\\)\\s*>\\s*0"),
            message: "Prefer 'if x:' over 'len(x) > 0'",
            suggestion: "Use 'if x:' instead",
            severity: .hint, category: .logicalMistake, lineOnly: false
        ))

        rules.append(LintRule(
            id: "logic-bare-except", pattern: re("^\\s*except\\s*:"),
            message: "Bare 'except:' catches all exceptions including KeyboardInterrupt",
            suggestion: "Use 'except Exception:' instead",
            severity: .warning, category: .logicalMistake, lineOnly: true
        ))

        // ============================================================
        // CATEGORY 4: Type/Language Confusion (8 rules)
        // ============================================================

        rules.append(LintRule(
            id: "type-true-lowercase", pattern: re("\\btrue\\b"),
            message: "Python uses 'True' (capitalized), not 'true'",
            suggestion: "Capitalize to 'True'",
            severity: .error, category: .typeConfusion, lineOnly: false
        ))

        rules.append(LintRule(
            id: "type-false-lowercase", pattern: re("\\bfalse\\b"),
            message: "Python uses 'False' (capitalized), not 'false'",
            suggestion: "Capitalize to 'False'",
            severity: .error, category: .typeConfusion, lineOnly: false
        ))

        rules.append(LintRule(
            id: "type-null", pattern: re("\\bnull\\b"),
            message: "Python uses 'None', not 'null'",
            suggestion: "Replace 'null' with 'None'",
            severity: .error, category: .typeConfusion, lineOnly: false
        ))

        rules.append(LintRule(
            id: "type-undefined", pattern: re("\\bundefined\\b"),
            message: "'undefined' does not exist in Python",
            suggestion: "Use 'None' instead",
            severity: .error, category: .typeConfusion, lineOnly: false
        ))

        rules.append(LintRule(
            id: "type-new-keyword", pattern: re("\\bnew\\s+[A-Z]\\w*\\("),
            message: "Python doesn't use 'new' — call the class directly",
            suggestion: "Remove 'new'",
            severity: .error, category: .typeConfusion, lineOnly: false
        ))

        rules.append(LintRule(
            id: "type-this-keyword", pattern: re("\\bthis\\."),
            message: "Python uses 'self', not 'this'",
            suggestion: "Replace 'this.' with 'self.'",
            severity: .error, category: .typeConfusion, lineOnly: false
        ))

        rules.append(LintRule(
            id: "type-sysout", pattern: re("\\bSystem\\.out\\.println\\("),
            message: "Python uses print(), not System.out.println()",
            suggestion: "Use print() instead",
            severity: .error, category: .typeConfusion, lineOnly: false
        ))

        rules.append(LintRule(
            id: "type-console-log", pattern: re("\\bconsole\\.log\\("),
            message: "Python uses print(), not console.log()",
            suggestion: "Use print() instead",
            severity: .error, category: .typeConfusion, lineOnly: false
        ))

        // ============================================================
        // CATEGORY 5: Python 2 vs 3 (4 rules)
        // ============================================================

        rules.append(LintRule(
            id: "py2-print-statement", pattern: re("^\\s*print\\s+[^(\\s]"),
            message: "In Python 3, print is a function",
            suggestion: "Use print(...) with parentheses",
            severity: .error, category: .python2vs3, lineOnly: true
        ))

        rules.append(LintRule(
            id: "py2-xrange", pattern: re("\\bxrange\\("),
            message: "xrange() doesn't exist in Python 3",
            suggestion: "Use range() instead",
            severity: .error, category: .python2vs3, lineOnly: false
        ))

        rules.append(LintRule(
            id: "py2-raw-input", pattern: re("\\braw_input\\("),
            message: "raw_input() doesn't exist in Python 3",
            suggestion: "Use input() instead",
            severity: .error, category: .python2vs3, lineOnly: false
        ))

        rules.append(LintRule(
            id: "py2-diamond-operator", pattern: re("<>"),
            message: "<> was removed in Python 3",
            suggestion: "Use != instead",
            severity: .error, category: .python2vs3, lineOnly: false
        ))

        // ============================================================
        // CATEGORY 6: Cross-Language Syntax (9 rules)
        // ============================================================

        rules.append(LintRule(
            id: "cross-switch", pattern: re("^\\s*switch\\s*\\("),
            message: "Python doesn't have switch — use if/elif or match/case",
            suggestion: "Use if/elif/else chain",
            severity: .error, category: .crossLanguage, lineOnly: true
        ))

        rules.append(LintRule(
            id: "cross-function", pattern: re("^\\s*function\\s+\\w+"),
            message: "Python uses 'def', not 'function'",
            suggestion: "Replace 'function' with 'def'",
            severity: .error, category: .crossLanguage, lineOnly: true
        ))

        rules.append(LintRule(
            id: "cross-var-let-const", pattern: re("^\\s*(?:var|let|const)\\s+\\w+"),
            message: "Python doesn't use var/let/const — assign directly",
            suggestion: "Remove the var/let/const keyword",
            severity: .error, category: .crossLanguage, lineOnly: true
        ))

        rules.append(LintRule(
            id: "cross-void", pattern: re("^\\s*void\\s+\\w+"),
            message: "Python doesn't use 'void' — functions return None by default",
            suggestion: "Use 'def' instead",
            severity: .error, category: .crossLanguage, lineOnly: true
        ))

        rules.append(LintRule(
            id: "cross-type-prefix", pattern: re("^\\s*(?:int|string|float|double|char|boolean)\\s+\\w+\\s*="),
            message: "Python doesn't use C-style type declarations",
            suggestion: "Just assign directly: x = value",
            severity: .warning, category: .crossLanguage, lineOnly: true
        ))

        rules.append(LintRule(
            id: "cross-foreach", pattern: re("\\bforeach\\b"),
            message: "Python uses 'for', not 'foreach'",
            suggestion: "Replace 'foreach' with 'for'",
            severity: .error, category: .crossLanguage, lineOnly: false
        ))

        rules.append(LintRule(
            id: "cross-else-if", pattern: re("^\\s*else\\s+if\\b"),
            message: "Python uses 'elif', not 'else if'",
            suggestion: "Replace 'else if' with 'elif'",
            severity: .error, category: .crossLanguage, lineOnly: true
        ))

        rules.append(LintRule(
            id: "cross-catch", pattern: re("^\\s*catch\\s*[\\(:]"),
            message: "Python uses 'except', not 'catch'",
            suggestion: "Replace 'catch' with 'except'",
            severity: .error, category: .crossLanguage, lineOnly: true
        ))

        rules.append(LintRule(
            id: "cross-throw", pattern: re("^\\s*throw\\s+"),
            message: "Python uses 'raise', not 'throw'",
            suggestion: "Replace 'throw' with 'raise'",
            severity: .error, category: .crossLanguage, lineOnly: true
        ))

        // ============================================================
        // CATEGORY 7: Common Algorithm Mistakes (8 rules)
        // ============================================================

        rules.append(LintRule(
            id: "algo-off-by-one", pattern: re("\\[\\s*len\\(\\w+\\)\\s*\\]"),
            message: "Index len(x) is out of bounds — last valid index is len(x)-1",
            suggestion: "Use [-1] for the last element",
            severity: .error, category: .logicalMistake, lineOnly: false
        ))

        rules.append(LintRule(
            id: "algo-string-concat-loop", pattern: re("(?:for|while)\\s.*:.*\\n\\s+\\w+\\s*\\+=\\s*['\"]"),
            message: "String concatenation in a loop is slow",
            suggestion: "Collect in a list and use ''.join()",
            severity: .hint, category: .logicalMistake, lineOnly: false
        ))

        rules.append(LintRule(
            id: "algo-except-pass", pattern: re("except.*:\\s*\\n\\s+pass\\s*$"),
            message: "Silently catching exceptions hides bugs",
            suggestion: "Log the error or handle it explicitly",
            severity: .warning, category: .logicalMistake, lineOnly: false
        ))

        rules.append(LintRule(
            id: "algo-dict-keys-in", pattern: re("\\bin\\s+\\w+\\.keys\\(\\)"),
            message: "'key in dict' already checks keys — .keys() is redundant",
            suggestion: "Use 'if key in dict:' directly",
            severity: .hint, category: .logicalMistake, lineOnly: false
        ))

        rules.append(LintRule(
            id: "algo-list-remove-iterate", pattern: re("for\\s+\\w+\\s+in\\s+(\\w+)\\s*:.*\\n\\s+\\1\\.remove\\("),
            message: "Modifying a list while iterating over it causes skipped elements",
            suggestion: "Iterate over a copy: for x in list[:]",
            severity: .error, category: .logicalMistake, lineOnly: false
        ))

        rules.append(LintRule(
            id: "algo-global-statement", pattern: re("^\\s*global\\s+\\w+"),
            message: "Avoid using global variables — pass values as parameters instead",
            suggestion: nil,
            severity: .hint, category: .logicalMistake, lineOnly: true
        ))

        rules.append(LintRule(
            id: "algo-not-equal-precedence", pattern: re("\\bif\\s+not\\s+\\w+\\s*=="),
            message: "'not' binds tighter than '==' — this may not do what you expect",
            suggestion: "Use 'if x != y:' or 'if not (x == y):'",
            severity: .warning, category: .logicalMistake, lineOnly: true
        ))

        rules.append(LintRule(
            id: "algo-return-in-finally", pattern: re("^\\s*finally\\s*:.*\\n(?:\\s+.*\\n)*?\\s+return\\b"),
            message: "Return in finally block silently overwrites other return values",
            suggestion: "Avoid return statements inside finally blocks",
            severity: .warning, category: .logicalMistake, lineOnly: false
        ))

        // ============================================================
        // CATEGORY 8: String/Format Mistakes (5 rules)
        // ============================================================

        rules.append(LintRule(
            id: "string-percent-format", pattern: re("['\"].*%[dsfr].*['\"]\\s*%\\s*"),
            message: "%-formatting is outdated",
            suggestion: "Use f-strings: f\"value is {x}\"",
            severity: .hint, category: .logicalMistake, lineOnly: true
        ))

        rules.append(LintRule(
            id: "string-concat-type", pattern: re("['\"].*['\"]\\s*\\+\\s*\\w+(?!\\s*['\"])"),
            message: "Concatenating string with non-string may cause TypeError",
            suggestion: "Use f-string or str() to convert",
            severity: .hint, category: .logicalMistake, lineOnly: true
        ))

        rules.append(LintRule(
            id: "string-split-empty", pattern: re("\\.split\\(\\s*['\"]['\"]\\s*\\)"),
            message: ".split('') doesn't work in Python — it raises ValueError",
            suggestion: "Use list(string) to split into characters",
            severity: .error, category: .methodConfusion, lineOnly: false
        ))

        rules.append(LintRule(
            id: "string-replace-no-assign", pattern: re("^\\s*\\w+\\.replace\\([^)]+\\)\\s*$"),
            message: "Strings are immutable — .replace() returns a new string",
            suggestion: "Assign the result: x = x.replace(...)",
            severity: .warning, category: .methodConfusion, lineOnly: true
        ))

        rules.append(LintRule(
            id: "string-strip-no-assign", pattern: re("^\\s*\\w+\\.strip\\(\\)\\s*$"),
            message: "Strings are immutable — .strip() returns a new string",
            suggestion: "Assign the result: x = x.strip()",
            severity: .warning, category: .methodConfusion, lineOnly: true
        ))

        // ============================================================
        // CATEGORY 9: Collection Mistakes (5 rules)
        // ============================================================

        rules.append(LintRule(
            id: "collection-sorted-assign", pattern: re("=\\s*\\w+\\.sorted\\("),
            message: "Lists don't have .sorted() — it's a built-in function",
            suggestion: "Use sorted(list) or list.sort()",
            severity: .error, category: .methodConfusion, lineOnly: true
        ))

        rules.append(LintRule(
            id: "collection-add-list", pattern: re("\\.add\\(.*\\)"),
            message: ".add() is for sets — use .append() for lists",
            suggestion: "Use .append() for lists or .add() for sets",
            severity: .hint, category: .methodConfusion, lineOnly: false
        ))

        rules.append(LintRule(
            id: "collection-extend-element", pattern: re("\\.extend\\(\\s*[^\\[\\(]\\w+\\s*\\)"),
            message: ".extend() with a string will add each character individually",
            suggestion: "Use .append() for a single element",
            severity: .hint, category: .methodConfusion, lineOnly: false
        ))

        rules.append(LintRule(
            id: "collection-pop-no-args", pattern: re("\\.pop\\(0\\)"),
            message: ".pop(0) is O(n) — consider using collections.deque for frequent left pops",
            suggestion: "Use deque.popleft() for O(1) performance",
            severity: .hint, category: .logicalMistake, lineOnly: false
        ))

        rules.append(LintRule(
            id: "collection-insert-append", pattern: re("\\.insert\\(\\s*len\\(\\w+\\)"),
            message: ".insert(len(x), val) is the same as .append(val)",
            suggestion: "Use .append() instead",
            severity: .hint, category: .logicalMistake, lineOnly: false
        ))

        // ============================================================
        // CATEGORY 10: Additional Cross-Language (4 rules)
        // ============================================================

        rules.append(LintRule(
            id: "cross-array-new", pattern: re("\\bArray\\("),
            message: "Python uses list(), not Array()",
            suggestion: "Use list() or [] literal",
            severity: .error, category: .crossLanguage, lineOnly: false
        ))

        rules.append(LintRule(
            id: "cross-string-equals", pattern: re("\\.equals\\("),
            message: "Python uses == for comparison, not .equals()",
            suggestion: "Use == operator",
            severity: .error, category: .crossLanguage, lineOnly: false
        ))

        rules.append(LintRule(
            id: "cross-println", pattern: re("\\bprintln\\("),
            message: "Python uses print(), not println()",
            suggestion: "Use print() instead",
            severity: .error, category: .crossLanguage, lineOnly: false
        ))

        rules.append(LintRule(
            id: "cross-elif-spelling", pattern: re("^\\s*elseif\\s+"),
            message: "Python uses 'elif', not 'elseif'",
            suggestion: "Replace 'elseif' with 'elif'",
            severity: .error, category: .crossLanguage, lineOnly: true
        ))

        return rules
    }
}

// MARK: - Lint Rule

private struct LintRule {
    let id: String
    let pattern: NSRegularExpression
    let message: String
    let suggestion: String?
    let severity: LintWarning.Severity
    let category: LintWarning.Category
    let lineOnly: Bool
}
