import SwiftUI
import UIKit

struct CodeEditorView: UIViewRepresentable {
    @Binding var text: String
    var fontSize: CGFloat = 14
    var onFocusChange: (Bool) -> Void = { _ in }
    var onContentHeightChange: ((CGFloat) -> Void)?
    var onLinterWarnings: (([LintWarning]) -> Void)?

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.font = UIFont.monospacedSystemFont(ofSize: fontSize, weight: .regular)
        textView.backgroundColor = UIColor(red: 0.06, green: 0.09, blue: 0.25, alpha: 1)
        textView.textColor = UIColor.white
        textView.tintColor = UIColor.white
        textView.keyboardAppearance = .dark
        textView.autocapitalizationType = .none
        textView.autocorrectionType = .no
        textView.smartDashesType = .no
        textView.smartQuotesType = .no
        textView.smartInsertDeleteType = .no
        textView.keyboardType = .asciiCapable
        textView.layer.cornerRadius = 8
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 8, bottom: 12, right: 8)
        textView.alwaysBounceVertical = true

        // Enable horizontal scrolling (disable line wrapping)
        textView.textContainer.lineBreakMode = .byClipping
        textView.textContainer.widthTracksTextView = false
        textView.textContainer.size.width = CGFloat.greatestFiniteMagnitude

        let accessory = CodeKeyboardAccessory(coordinator: context.coordinator)
        accessory.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44)
        textView.inputAccessoryView = accessory

        context.coordinator.textView = textView
        textView.text = text
        context.coordinator.applySyntaxHighlighting()
        context.coordinator.reportContentHeight()
        return textView
    }

    func updateUIView(_ textView: UITextView, context: Context) {
        if textView.text != text {
            let selectedRange = textView.selectedRange
            textView.text = text
            context.coordinator.applySyntaxHighlighting()
            textView.selectedRange = selectedRange
            context.coordinator.reportContentHeight()
        }
    }

    class Coordinator: NSObject, UITextViewDelegate {
        var parent: CodeEditorView
        weak var textView: UITextView?

        private let keywords = [
            "def", "return", "if", "elif", "else", "for", "while",
            "in", "not", "and", "or", "True", "False", "None",
            "class", "import", "from", "as", "try", "except",
            "finally", "with", "yield", "lambda", "pass", "break",
            "continue", "raise", "global", "nonlocal", "assert", "del"
        ]

        private let builtins = [
            "print", "len", "range", "int", "str", "list", "dict",
            "set", "tuple", "bool", "float", "sorted", "enumerate",
            "zip", "map", "filter", "sum", "min", "max", "abs", "type"
        ]

        init(_ parent: CodeEditorView) {
            self.parent = parent
        }

        func textViewDidBeginEditing(_ textView: UITextView) {
            parent.onFocusChange(true)
        }

        func textViewDidEndEditing(_ textView: UITextView) {
            parent.onFocusChange(false)
        }

        private var lintTimer: Timer?

        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
            applySyntaxHighlighting()
            reportContentHeight()
            scheduleLinting()
        }

        func reportContentHeight() {
            guard let textView = textView else { return }
            let height = textView.contentSize.height
            parent.onContentHeightChange?(height)
        }

        func scheduleLinting() {
            lintTimer?.invalidate()
            lintTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] _ in
                self?.runLinter()
            }
        }

        private func runLinter() {
            guard let onWarnings = parent.onLinterWarnings else { return }
            let code = parent.text
            DispatchQueue.global(qos: .userInitiated).async {
                let warnings = PythonLinter.shared.lint(code)
                DispatchQueue.main.async {
                    onWarnings(warnings)
                }
            }
        }

        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange,
                       replacementText text: String) -> Bool {
            if text == "\n" {
                let cursorPosition = range.location
                let textBeforeCursor = (textView.text as NSString).substring(to: cursorPosition)
                let lines = textBeforeCursor.components(separatedBy: "\n")
                let currentLine = lines.last ?? ""

                let leadingSpaces = currentLine.prefix(while: { $0 == " " }).count
                var indent = String(repeating: " ", count: leadingSpaces)

                let trimmedLine = currentLine.trimmingCharacters(in: .whitespaces)
                if trimmedLine.hasSuffix(":") {
                    indent += "    "
                }

                textView.insertText("\n" + indent)
                parent.text = textView.text
                applySyntaxHighlighting()
                scheduleLinting()
                return false
            }
            return true
        }

        func applySyntaxHighlighting() {
            guard let textView = textView else { return }
            let text = textView.text ?? ""
            let attributed = NSMutableAttributedString(string: text)
            let fullRange = NSRange(location: 0, length: text.utf16.count)

            attributed.addAttribute(.font,
                value: UIFont.monospacedSystemFont(ofSize: parent.fontSize, weight: .regular), range: fullRange)
            attributed.addAttribute(.foregroundColor,
                value: UIColor.white, range: fullRange)

            for keyword in keywords {
                if let regex = try? NSRegularExpression(pattern: "\\b\(keyword)\\b") {
                    for match in regex.matches(in: text, range: fullRange) {
                        attributed.addAttribute(.foregroundColor,
                            value: UIColor.systemPurple, range: match.range)
                    }
                }
            }

            for builtin in builtins {
                if let regex = try? NSRegularExpression(pattern: "\\b\(builtin)\\b") {
                    for match in regex.matches(in: text, range: fullRange) {
                        attributed.addAttribute(.foregroundColor,
                            value: UIColor.systemTeal, range: match.range)
                    }
                }
            }

            let stringPatterns = ["\"\"\"[\\s\\S]*?\"\"\"", "'''[\\s\\S]*?'''",
                                  "\"[^\"\\n]*\"", "'[^'\\n]*'"]
            for pattern in stringPatterns {
                if let regex = try? NSRegularExpression(pattern: pattern) {
                    for match in regex.matches(in: text, range: fullRange) {
                        attributed.addAttribute(.foregroundColor,
                            value: UIColor.systemRed, range: match.range)
                    }
                }
            }

            if let regex = try? NSRegularExpression(pattern: "#.*$", options: .anchorsMatchLines) {
                for match in regex.matches(in: text, range: fullRange) {
                    attributed.addAttribute(.foregroundColor,
                        value: UIColor.systemGray, range: match.range)
                }
            }

            if let regex = try? NSRegularExpression(pattern: "\\b\\d+\\.?\\d*\\b") {
                for match in regex.matches(in: text, range: fullRange) {
                    attributed.addAttribute(.foregroundColor,
                        value: UIColor.systemBlue, range: match.range)
                }
            }

            let selectedRange = textView.selectedRange
            textView.attributedText = attributed
            textView.selectedRange = selectedRange

            // Re-apply text container settings (attributedText resets them)
            textView.textContainer.lineBreakMode = .byClipping
            textView.textContainer.widthTracksTextView = false
            textView.textContainer.size.width = CGFloat.greatestFiniteMagnitude

            textView.typingAttributes = [
                .font: UIFont.monospacedSystemFont(ofSize: parent.fontSize, weight: .regular),
                .foregroundColor: UIColor.white
            ]
        }

        @objc func insertTab() {
            textView?.insertText("    ")
        }

        @objc func dismissKeyboard() {
            textView?.resignFirstResponder()
        }

        private static let bracketPairs: [String: String] = [
            "()": ")",
            "[]": "]",
            "{}": "}",
            "\"\"": "\"",
        ]

        func insertSnippet(_ snippet: String) {
            guard let tv = textView else { return }

            // Check if this is a bracket pair snippet
            if let closing = Self.bracketPairs[snippet] {
                let cursorPos = tv.selectedRange.location
                let text = tv.text as NSString

                // If the character right after the cursor is the closing bracket, jump past it
                if cursorPos < text.length,
                   text.substring(with: NSRange(location: cursorPos, length: closing.count)) == closing {
                    tv.selectedRange = NSRange(location: cursorPos + closing.count, length: 0)
                    return
                }

                // Otherwise insert the pair and place cursor inside
                tv.insertText(snippet)
                tv.selectedRange = NSRange(location: tv.selectedRange.location - closing.count, length: 0)
            } else {
                tv.insertText(snippet)
            }

            parent.text = tv.text
            applySyntaxHighlighting()
            reportContentHeight()
            scheduleLinting()
        }

        func undo() {
            guard let tv = textView, let undoManager = tv.undoManager, undoManager.canUndo else { return }
            undoManager.undo()
            parent.text = tv.text
            applySyntaxHighlighting()
            reportContentHeight()
            scheduleLinting()
        }
    }
}

private class CodeKeyboardAccessory: UIView {
    private static let shortcuts: [(label: String, snippet: String)] = [
        ("Tab", "    "),
        ("if", "if "),
        ("elif", "elif "),
        ("else", "else:"),
        ("for", "for "),
        ("while", "while "),
        ("def", "def "),
        ("return", "return "),
        ("in", " in "),
        ("not", " not "),
        ("and", " and "),
        ("or", " or "),
        ("=", "= "),
        ("( )", "()"),
        ("[ ]", "[]"),
        ("{ }", "{}"),
        (":", ":"),
        ("\"\"", "\"\""),
        (".", "."),
        (",", ", "),
        ("#", "# "),
        ("_", "_"),
        ("+", " + "),
        ("-", " - "),
        ("*", " * "),
        ("<", " < "),
        (">", " > "),
        ("!", "!"),
    ]

    weak var coordinator: CodeEditorView.Coordinator?

    init(coordinator: CodeEditorView.Coordinator) {
        self.coordinator = coordinator
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        backgroundColor = UIColor(red: 0.12, green: 0.12, blue: 0.14, alpha: 1)

        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(scrollView)

        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 6
        stack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stack)

        for (index, shortcut) in Self.shortcuts.enumerated() {
            let button = UIButton(type: .system)
            button.setTitle(shortcut.label, for: .normal)
            button.titleLabel?.font = UIFont.monospacedSystemFont(ofSize: 15, weight: .medium)
            button.setTitleColor(.white, for: .normal)
            button.backgroundColor = UIColor(white: 0.25, alpha: 1)
            button.layer.cornerRadius = 6
            button.contentEdgeInsets = UIEdgeInsets(top: 6, left: 10, bottom: 6, right: 10)
            button.tag = index
            button.addTarget(self, action: #selector(snippetTapped(_:)), for: .touchUpInside)
            stack.addArrangedSubview(button)
        }

        // Undo button
        let undoButton = UIButton(type: .system)
        undoButton.setImage(UIImage(systemName: "arrow.uturn.backward"), for: .normal)
        undoButton.tintColor = .white
        undoButton.backgroundColor = UIColor(white: 0.25, alpha: 1)
        undoButton.layer.cornerRadius = 6
        undoButton.contentEdgeInsets = UIEdgeInsets(top: 6, left: 10, bottom: 6, right: 10)
        undoButton.addTarget(self, action: #selector(undoTapped), for: .touchUpInside)
        stack.addArrangedSubview(undoButton)

        // Done button at the end
        let doneButton = UIButton(type: .system)
        doneButton.setTitle("Done", for: .normal)
        doneButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        doneButton.setTitleColor(UIColor.systemBlue, for: .normal)
        doneButton.contentEdgeInsets = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)
        doneButton.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
        stack.addArrangedSubview(doneButton)

        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 8),
            stack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -8),
            stack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 4),
            stack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -4),
            stack.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor, constant: -8),
        ])
    }

    @objc private func snippetTapped(_ sender: UIButton) {
        let snippet = Self.shortcuts[sender.tag].snippet
        coordinator?.insertSnippet(snippet)
    }

    @objc private func undoTapped() {
        coordinator?.undo()
    }

    @objc private func doneTapped() {
        coordinator?.dismissKeyboard()
    }
}
