import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    SettingsSection(title: "General") {
                        SettingsRow(icon: "globe", label: "Language", value: "Python")
                        SettingsRow(icon: "textformat.size", label: "Editor Font Size", value: "14pt")
                    }

                    SettingsSection(title: "Execution") {
                        SettingsRow(icon: "server.rack", label: "Server", value: "localhost")
                        SettingsRow(icon: "clock", label: "Timeout", value: "5 seconds")
                    }

                    SettingsSection(title: "About") {
                        SettingsRow(icon: "info.circle", label: "Version", value: "1.0.0")
                    }
                }
                .padding()
            }
            .background(Theme.surface)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Theme.primary, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Settings")
                        .font(.title3.bold())
                        .foregroundStyle(.white)
                }
            }
        }
    }
}

struct SettingsSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title.uppercased())
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(Theme.textSecondary)
                .padding(.horizontal, 16)
                .padding(.bottom, 8)

            VStack(spacing: 0) {
                content
            }
            .background(Theme.card)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

struct SettingsRow: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundStyle(Theme.accent)
                .frame(width: 24)
            Text(label)
                .font(.subheadline)
                .foregroundStyle(Theme.textPrimary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .foregroundStyle(Theme.textSecondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}
