import SwiftUI

struct SettingsView: View {
    private var xpManager: SkillXPManager { .shared }
    @State private var editingName = false
    @State private var nameText = ""
    @AppStorage("editorFontSize") private var editorFontSize: Double = 14
    @AppStorage("linterEnabled") private var linterEnabled = true
    @AppStorage("streakRemindersEnabled") private var streakRemindersEnabled = false
    @State private var showResetAlert = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    SettingsSection(title: "Profile") {
                        if editingName {
                            HStack {
                                Image(systemName: "person")
                                    .font(.subheadline)
                                    .foregroundStyle(Theme.accent)
                                    .frame(width: 24)
                                TextField("Your name", text: $nameText)
                                    .font(.subheadline)
                                    .foregroundStyle(Theme.textPrimary)
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

                    SettingsSection(title: "Notifications") {
                        HStack {
                            Image(systemName: "bell.badge")
                                .font(.subheadline)
                                .foregroundStyle(Theme.accent)
                                .frame(width: 24)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Streak Reminders")
                                    .font(.subheadline)
                                    .foregroundStyle(Theme.textPrimary)
                                Text("Daily at 6:00 PM")
                                    .font(.caption2)
                                    .foregroundStyle(Theme.textSecondary)
                            }
                            Spacer()
                            Toggle("", isOn: $streakRemindersEnabled)
                                .labelsHidden()
                                .tint(Theme.accent)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                    }

                    SettingsSection(title: "About") {
                        #if DEBUG
                        SettingsRow(icon: "info.circle", label: "Version", value: "1.0.0")
                            .onTapGesture(count: 3) {
                                xpManager.seedScreenshotData()
                                Haptics.notification(.success)
                            }
                        #else
                        SettingsRow(icon: "info.circle", label: "Version", value: "1.0.0")
                        #endif

                        Button {
                            AnalyticsService.shared.track("settings_privacy_policy")
                            if let url = URL(string: "https://axellangenskiold.github.io/") {
                                UIApplication.shared.open(url)
                            }
                        } label: {
                            HStack {
                                Image(systemName: "hand.raised")
                                    .font(.subheadline)
                                    .foregroundStyle(Theme.accent)
                                    .frame(width: 24)
                                Text("Privacy Policy")
                                    .font(.subheadline)
                                    .foregroundStyle(Theme.textPrimary)
                                Spacer()
                                Image(systemName: "arrow.up.right")
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
            .onAppear {
                AnalyticsService.shared.track("settings_view")
            }
            .onChange(of: editorFontSize) { _, newSize in
                AnalyticsService.shared.track("settings_font_size", properties: ["size": "\(Int(newSize))"])
            }
            .onChange(of: linterEnabled) { _, enabled in
                AnalyticsService.shared.track("settings_linter_toggle", properties: ["enabled": "\(enabled)"])
            }
            .onChange(of: streakRemindersEnabled) { _, enabled in
                AnalyticsService.shared.track("settings_streak_reminders_toggle", properties: ["enabled": "\(enabled)"])
                if enabled {
                    NotificationManager.shared.scheduleStreakReminder()
                } else {
                    NotificationManager.shared.cancelStreakReminder()
                }
            }
            .alert("Reset Progress", isPresented: $showResetAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Reset", role: .destructive) {
                    resetProgress()
                }
            } message: {
                Text("This will delete all your XP, solved problems, achievements, and streaks. This cannot be undone.")
            }
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
