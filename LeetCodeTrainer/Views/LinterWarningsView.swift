import SwiftUI

struct LinterWarningsView: View {
    let warnings: [LintWarning]
    @State private var isExpanded = true

    private var errorCount: Int { warnings.filter { $0.severity == .error }.count }
    private var warningCount: Int { warnings.filter { $0.severity == .warning }.count }
    private var hintCount: Int { warnings.filter { $0.severity == .hint }.count }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header — tap to expand/collapse
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.yellow)
                        .font(.caption)

                    Text("\(warnings.count) issue\(warnings.count == 1 ? "" : "s")")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(Theme.textPrimary)

                    if errorCount > 0 {
                        SeverityBadge(count: errorCount, color: .red, icon: "xmark.circle.fill")
                    }
                    if warningCount > 0 {
                        SeverityBadge(count: warningCount, color: .orange, icon: "exclamationmark.triangle.fill")
                    }
                    if hintCount > 0 {
                        SeverityBadge(count: hintCount, color: .blue, icon: "info.circle.fill")
                    }

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption2)
                        .foregroundStyle(Theme.textSecondary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
            }

            if isExpanded {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(Array(warnings.enumerated()), id: \.element.id) { index, warning in
                        WarningRow(warning: warning)

                        if index < warnings.count - 1 {
                            Theme.divider
                                .frame(height: 1)
                                .padding(.leading, 32)
                        }
                    }
                }
            }
        }
        .background(Theme.card)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Severity Badge

private struct SeverityBadge: View {
    let count: Int
    let color: Color
    let icon: String

    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: icon)
                .font(.system(size: 8))
            Text("\(count)")
                .font(.caption2)
                .fontWeight(.semibold)
        }
        .foregroundStyle(color)
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(color.opacity(0.15))
        .clipShape(Capsule())
    }
}

// MARK: - Warning Row

private struct WarningRow: View {
    let warning: LintWarning

    private var severityColor: Color {
        switch warning.severity {
        case .error: return .red
        case .warning: return .orange
        case .hint: return .blue
        }
    }

    private var severityIcon: String {
        switch warning.severity {
        case .error: return "xmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .hint: return "info.circle.fill"
        }
    }

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: severityIcon)
                .foregroundStyle(severityColor)
                .font(.caption)
                .frame(width: 16)

            VStack(alignment: .leading, spacing: 3) {
                Text(warning.message)
                    .font(.caption)
                    .foregroundStyle(Theme.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 8) {
                    Text("Line \(warning.line)")
                        .font(.caption2)
                        .foregroundStyle(Theme.textSecondary)

                    if let suggestion = warning.suggestion {
                        Text(suggestion)
                            .font(.caption2)
                            .foregroundStyle(Theme.accent)
                    }
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }
}
