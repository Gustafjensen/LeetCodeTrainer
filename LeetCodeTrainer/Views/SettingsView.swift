import SwiftUI

struct SettingsView: View {
    var isEmbedded = false
    private var xpManager: SkillXPManager { .shared }
    @State private var editingName = false
    @State private var nameText = ""
    @AppStorage("editorFontSize") private var editorFontSize: Double = 14
    @AppStorage("linterEnabled") private var linterEnabled = true
    @State private var showResetAlert = false
    @State private var showWidgetHint = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        settingsContent
    }

    @ViewBuilder
    private var settingsContent: some View {
        if isEmbedded {
            settingsBody
                .navigationBarBackButtonHidden(true)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        BackButton { dismiss() }
                    }
                    ToolbarItem(placement: .principal) {
                        Text("Settings")
                            .font(.title3.bold())
                            .foregroundStyle(.white)
                    }
                }
        } else {
            NavigationStack {
                settingsBody
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

    private var settingsBody: some View {
        ScrollView {
                VStack(spacing: 12) {
                    SettingsSection(title: "Profile") {
                        if editingName {
                            HStack {
                                Image(systemName: "person")
                                    .font(.subheadline)
                                    .foregroundStyle(Theme.accent)
                                    .frame(width: 24)
                                TextField("", text: $nameText, prompt: Text("Your name").foregroundStyle(Theme.textSecondary))
                                    .font(.subheadline)
                                    .foregroundStyle(.white)
                                    .tint(.white)
                                    .onSubmit {
                                        saveName()
                                    }
                                Button("Save") {
                                    saveName()
                                }
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundStyle(Theme.accent)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                        } else {
                            Button {
                                nameText = xpManager.userName
                                editingName = true
                            } label: {
                                HStack {
                                    Image(systemName: "person")
                                        .font(.subheadline)
                                        .foregroundStyle(Theme.accent)
                                        .frame(width: 24)
                                    Text("Name")
                                        .font(.subheadline)
                                        .foregroundStyle(Theme.textPrimary)
                                    Spacer()
                                    Text(xpManager.userName.isEmpty ? "Not set" : xpManager.userName)
                                        .font(.subheadline)
                                        .foregroundStyle(Theme.textSecondary)
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundStyle(Theme.textSecondary)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                            }
                        }
                    }

                    SettingsSection(title: "Editor") {
                        HStack {
                            Image(systemName: "textformat.size")
                                .font(.subheadline)
                                .foregroundStyle(Theme.accent)
                                .frame(width: 24)
                            Text("Font Size")
                                .font(.subheadline)
                                .foregroundStyle(Theme.textPrimary)
                            Spacer()
                            Text("\(Int(editorFontSize))pt")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(Theme.textSecondary)
                                .frame(width: 36)
                            Stepper("", value: $editorFontSize, in: 6...32, step: 1)
                                .labelsHidden()
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)

                        SettingsRow(icon: "globe", label: "Language", value: "Python")

                        HStack {
                            Image(systemName: "checkmark.shield")
                                .font(.subheadline)
                                .foregroundStyle(Theme.accent)
                                .frame(width: 24)
                            Text("Python Linter")
                                .font(.subheadline)
                                .foregroundStyle(Theme.textPrimary)
                            Spacer()
                            Toggle("", isOn: $linterEnabled)
                                .labelsHidden()
                                .tint(Theme.accent)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                    }

                    SettingsSection(title: "About") {
                        SettingsRow(icon: "info.circle", label: "Version", value: "1.2.1")
                    }

                    SettingsSection(title: "Widgets") {
                        Button {
                            showWidgetHint = true
                        } label: {
                            HStack {
                                Image(systemName: "square.grid.2x2")
                                    .font(.subheadline)
                                    .foregroundStyle(Theme.accent)
                                    .frame(width: 24)
                                Text("Add Home Screen Widget")
                                    .font(.subheadline)
                                    .foregroundStyle(Theme.textPrimary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(Theme.textSecondary)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                        }
                    }

                    SettingsSection(title: "Data") {
                        Button {
                            showResetAlert = true
                        } label: {
                            HStack {
                                Image(systemName: "arrow.counterclockwise")
                                    .font(.subheadline)
                                    .foregroundStyle(.red)
                                    .frame(width: 24)
                                Text("Reset All Progress")
                                    .font(.subheadline)
                                    .foregroundStyle(.red)
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                        }
                    }
                }
                .padding()
            }
            .scrollDismissesKeyboard(.interactively)
            .background(Theme.surface)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Theme.primary, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .onAppear {
                AnalyticsService.shared.track("settings_view")
            }
            .onChange(of: editorFontSize) { _, newSize in
                AnalyticsService.shared.track("settings_font_size", properties: ["size": "\(Int(newSize))"])
            }
            .onChange(of: linterEnabled) { _, enabled in
                AnalyticsService.shared.track("settings_linter_toggle", properties: ["enabled": "\(enabled)"])
            }
            .alert("Reset Progress", isPresented: $showResetAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Reset", role: .destructive) {
                    resetProgress()
                }
            } message: {
                Text("This will delete all your XP, solved problems, achievements, and streaks. This cannot be undone.")
            }
            .alert("Home Screen Widget", isPresented: $showWidgetHint) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Long-press your home screen, tap the + button in the top corner, then search for CodeCrush to add the widget.")
            }
    }

    private func saveName() {
        let trimmed = nameText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty {
            xpManager.saveUserName(trimmed)
            AnalyticsService.shared.track("settings_name_change")
        }
        editingName = false
    }

    private func resetProgress() {
        AnalyticsService.shared.track("settings_reset_progress")
        SkillXPManager.shared.resetProgress()
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
