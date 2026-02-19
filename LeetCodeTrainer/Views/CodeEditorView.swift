import SwiftUI
import UIKit

struct CodeEditorView: UIViewRepresentable {
    @Binding var text: String
    var onFocusChange: (Bool) -> Void = { _ in }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.font = UIFont.monospacedSystemFont(ofSize: 12, weight: .regular)
        textView.backgroundColor = UIColor(red: 0.06, green: 0.09, blue: 0.25, alpha: 1)
        textView.textColor = UIColor.white
        textView.autocapitalizationType = .none
        textView.autocorrectionType = .no
        textView.smartDashesType = .no
        textView.smartQuotesType = .no
        textView.smartInsertDeleteType = .no
        textView.keyboardType = .asciiCapable
        textView.layer.cornerRadius = 8
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 8, bottom: 12, right: 8)
        textView.alwaysBounceVertical = true

        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let tabButton = UIBarButtonItem(
            title: "Tab", style: .plain,
            target: context.coordinator, action: #selector(Coordinator.insertTab))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: context.coordinator, action: #selector(Coordinator.dismissKeyboard))
        toolbar.items = [tabButton, flexSpace, doneButton]
        textView.inputAccessoryView = toolbar

        context.coordinator.textView = textView
        textView.text = text
        context.coordinator.applySyntaxHighlighting()
        return textView
    }

    func updateUIView(_ textView: UITextView, context: Context) {
        if textView.text != text {
            let selectedRange = textView.selectedRange
            textView.text = text
            context.coordinator.applySyntaxHighlighting()
            textView.selectedRange = selectedRange
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

        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
            applySyntaxHighlighting()
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
                value: UIFont.monospacedSystemFont(ofSize: 12, weight: .regular), range: fullRange)
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
        }

        @objc func insertTab() {
            textView?.insertText("    ")
        }

        @objc func dismissKeyboard() {
            textView?.resignFirstResponder()
        }
    }
}
