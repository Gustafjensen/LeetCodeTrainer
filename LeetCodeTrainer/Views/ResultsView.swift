import SwiftUI

struct ResultsView: View {
    let result: ExecutionResult

    private var statusColor: Color {
        switch result.overallStatus {
        case .pass: return .green
        case .fail, .error: return .red
        }
    }

    private var statusText: String {
        switch result.overallStatus {
        case .pass: return "All Tests Passed"
        case .fail: return "Some Tests Failed"
        case .error: return "Execution Error"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: result.overallStatus == .pass
                      ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundStyle(statusColor)
                Text(statusText)
                    .font(.headline)
                    .foregroundStyle(statusColor)
                Spacer()
                Text(result.runtime)
                    .font(.caption)
                    .foregroundStyle(Theme.textSecondary)
            }

            if let runtimeError = result.runtimeError {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Error")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.red)
                    Text(runtimeError)
                        .font(.system(.caption, design: .monospaced))
                        .foregroundStyle(Theme.textSecondary)
                        .padding(8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.red.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
            }

            ForEach(Array(result.testResults.enumerated()), id: \.offset) { index, testCase in
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: testCase.passed
                              ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundStyle(testCase.passed ? .green : .red)
                            .font(.caption)
                        Text("Input: \(testCase.input)")
                            .font(.system(.caption, design: .monospaced))
                            .foregroundStyle(Theme.textPrimary)
                            .lineLimit(2)
                    }
                    HStack(spacing: 16) {
                        VStack(alignment: .leading) {
                            Text("Expected")
                                .font(.caption2)
                                .foregroundStyle(Theme.textSecondary)
                            Text(testCase.expectedOutput)
                                .font(.system(.caption, design: .monospaced))
                                .foregroundStyle(Theme.textPrimary)
                        }
                        VStack(alignment: .leading) {
                            Text("Got")
                                .font(.caption2)
                                .foregroundStyle(Theme.textSecondary)
                            Text(testCase.actualOutput)
                                .font(.system(.caption, design: .monospaced))
                                .foregroundColor(testCase.passed ? .green : .red)
                        }
                    }
                    .padding(.leading, 20)
                }
                .padding(.vertical, 4)

                if index < result.testResults.count - 1 {
                    Theme.divider
                        .frame(height: 1)
                }
            }
        }
        .padding()
        .background(Theme.card)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
