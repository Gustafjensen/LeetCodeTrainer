import SwiftUI

struct FriendsView: View {
    private var cloudKit: CloudKitManager { .shared }
    @State private var friendCodeInput = ""
    @State private var addError: String?
    @State private var isAdding = false
    @State private var pokeSuccessName: String?
    @State private var selectedFriend: FriendProfile?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    if !cloudKit.iCloudAvailable {
                        iCloudBanner
                    } else {
                        // My friend code
                        if let code = cloudKit.myFriendCode {
                            FriendCodeCard(code: code)
                        }

                        // Pending pokes
                        if !cloudKit.pendingPokes.isEmpty {
                            VStack(spacing: 8) {
                                ForEach(cloudKit.pendingPokes) { poke in
                                    PokeNotificationCard(poke: poke) {
                                        Task { await cloudKit.dismissPoke(poke) }
                                    }
                                }
                            }
                        }

                        // Add friend
                        addFriendSection

                        // Friends list
                        if cloudKit.isLoading {
                            ProgressView()
                                .tint(Theme.accent)
                                .padding(.top, 40)
                        } else if cloudKit.friends.isEmpty {
                            VStack(spacing: 8) {
                                Image(systemName: "person.2")
                                    .font(.system(size: 40))
                                    .foregroundStyle(Theme.textSecondary.opacity(0.5))
                                Text("No friends yet")
                                    .font(.headline)
                                    .foregroundStyle(Theme.textSecondary)
                                Text("Share your code or enter a friend's code to get started")
                                    .font(.caption)
                                    .foregroundStyle(Theme.textSecondary.opacity(0.7))
                                    .multilineTextAlignment(.center)
                            }
                            .padding(.top, 40)
                        } else {
                            VStack(spacing: 10) {
                                ForEach(cloudKit.friends) { friend in
                                    FriendRow(friend: friend) {
                                        selectedFriend = friend
                                    } onPoke: {
                                        pokeFriend(friend)
                                    } onRemove: {
                                        Task { try? await cloudKit.removeFriend(friend.id) }
                                    }
                                }
                            }
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
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Friends")
                        .font(.title3.bold())
                        .foregroundStyle(.white)
                }
            }
            .onAppear {
                AnalyticsService.shared.track("friends_view")
                Task {
                    await cloudKit.loadFriends()
                    await cloudKit.loadPendingPokes()
                }
            }
            .overlay {
                if let name = pokeSuccessName {
                    pokeToast(name: name)
                }
            }
            .sheet(item: $selectedFriend) { friend in
                FriendProfileSheet(friend: friend)
            }
        }
    }

    // MARK: - iCloud Banner

    private var iCloudBanner: some View {
        HStack(spacing: 12) {
            Image(systemName: "icloud.slash")
                .font(.title2)
                .foregroundStyle(.orange)
            VStack(alignment: .leading, spacing: 2) {
                Text("iCloud Required")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Theme.textPrimary)
                Text("Sign in to iCloud in Settings to use Friends.")
                    .font(.caption)
                    .foregroundStyle(Theme.textSecondary)
            }
            Spacer()
        }
        .padding(16)
        .background(Theme.card)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Add Friend

    private var addFriendSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("ADD FRIEND")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(Theme.textSecondary)

            HStack(spacing: 0) {
                TextField("", text: $friendCodeInput, prompt: Text("Enter friend code").foregroundStyle(Theme.textSecondary))
                    .font(.system(.subheadline, design: .monospaced))
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
                    .foregroundStyle(.white)
                    .padding(10)
                    .onChange(of: friendCodeInput) { _, _ in
                        addError = nil
                    }
                    .onSubmit {
                        addFriend()
                    }
                    .disabled(isAdding)

                Button {
                    addFriend()
                } label: {
                    if isAdding {
                        ProgressView()
                            .tint(Theme.accent)
                            .frame(width: 20, height: 20)
                    } else {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title2)
                            .foregroundStyle(Theme.accent)
                    }
                }
                .disabled(friendCodeInput.trimmingCharacters(in: .whitespaces).count < 6 || isAdding)
                .opacity(friendCodeInput.trimmingCharacters(in: .whitespaces).count < 6 ? 0.3 : 1)
                .padding(.trailing, 8)
            }
            .background(Theme.card)
            .clipShape(RoundedRectangle(cornerRadius: 10))

            if let error = addError {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
    }

    // MARK: - Actions

    private func addFriend() {
        let code = friendCodeInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard code.count >= 6 else { return }
        isAdding = true
        addError = nil

        Task {
            do {
                try await cloudKit.addFriend(byCode: code)
                await MainActor.run {
                    friendCodeInput = ""
                    isAdding = false
                }
                AnalyticsService.shared.track("friends_add_attempt", properties: ["success": "true"])
            } catch {
                await MainActor.run {
                    addError = error.localizedDescription
                    isAdding = false
                }
                AnalyticsService.shared.track("friends_add_attempt", properties: ["success": "false"])
                try? await Task.sleep(for: .seconds(2))
                await MainActor.run {
                    addError = nil
                }
            }
        }
    }

    private func pokeFriend(_ friend: FriendProfile) {
        Task {
            do {
                try await cloudKit.pokeFriend(friend.id)
                await MainActor.run {
                    pokeSuccessName = friend.displayName
                }
                AnalyticsService.shared.track("friends_poke_sent")
                try? await Task.sleep(for: .seconds(2))
                await MainActor.run {
                    pokeSuccessName = nil
                }
            } catch {
                await MainActor.run {
                    addError = error.localizedDescription
                }
            }
        }
    }

    private func pokeToast(name: String) -> some View {
        VStack {
            Spacer()
            Text("Poked \(name)!")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Color.green)
                .clipShape(Capsule())
                .padding(.bottom, 20)
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .animation(.easeInOut, value: pokeSuccessName)
    }
}

// MARK: - Friend Code Card

struct FriendCodeCard: View {
    let code: String
    @State private var copied = false

    var body: some View {
        VStack(spacing: 10) {
            Text("YOUR FRIEND CODE")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(Theme.textSecondary)

            Text(code)
                .font(.system(size: 32, weight: .bold, design: .monospaced))
                .foregroundStyle(Theme.accent)
                .tracking(6)

            HStack(spacing: 12) {
                Button {
                    UIPasteboard.general.string = code
                    copied = true
                    Haptics.notification(.success)
                    AnalyticsService.shared.track("friends_code_copy")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        copied = false
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: copied ? "checkmark" : "doc.on.doc")
                            .font(.caption)
                        Text(copied ? "Copied" : "Copy")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundStyle(Theme.accent)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
                    .background(Theme.accent.opacity(0.15))
                    .clipShape(Capsule())
                }

                ShareLink(item: "Add me on CodeCrush! My friend code is: \(code)\nhttps://apps.apple.com/se/app/codecrush-pro/id6759711502") {
                    HStack(spacing: 4) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.caption)
                        Text("Share")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundStyle(Theme.accent)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
                    .background(Theme.accent.opacity(0.15))
                    .clipShape(Capsule())
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(Theme.card)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Poke Notification Card

struct PokeNotificationCard: View {
    let poke: PokeRecord
    let onDismiss: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "hand.point.right.fill")
                .font(.title3)
                .foregroundStyle(.orange)

            VStack(alignment: .leading, spacing: 2) {
                Text("\(poke.fromDisplayName) poked you!")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Theme.textPrimary)
                Text("Complete your daily challenge!")
                    .font(.caption)
                    .foregroundStyle(Theme.textSecondary)
            }

            Spacer()

            Button {
                onDismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.caption)
                    .foregroundStyle(Theme.textSecondary)
                    .padding(6)
                    .background(Theme.primaryDark.opacity(0.5))
                    .clipShape(Circle())
            }
        }
        .padding(14)
        .background(Color.orange.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(Color.orange.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Friend Row

struct FriendRow: View {
    let friend: FriendProfile
    let onTap: () -> Void
    let onPoke: () -> Void
    let onRemove: () -> Void
    private var canPoke: Bool { CloudKitManager.shared.canPoke(friend.id) }

    var body: some View {
        HStack(spacing: 14) {
            Button {
                onTap()
            } label: {
                HStack(spacing: 14) {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 38))
                        .foregroundStyle(Theme.accent.opacity(0.6))

                    VStack(alignment: .leading, spacing: 3) {
                        HStack(spacing: 6) {
                            Text(friend.displayName)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundStyle(Theme.textPrimary)
                            if friend.hasCompletedToday {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.caption2)
                                    .foregroundStyle(.green)
                            }
                        }
                        HStack(spacing: 10) {
                            HStack(spacing: 3) {
                                Image(systemName: "flame.fill")
                                    .font(.caption2)
                                    .foregroundStyle(.orange)
                                Text("\(friend.currentStreak)")
                                    .font(.caption)
                                    .foregroundStyle(Theme.textSecondary)
                            }
                            HStack(spacing: 3) {
                                Image(systemName: "checkmark.circle")
                                    .font(.caption2)
                                    .foregroundStyle(.green)
                                Text("\(friend.solvedCount)")
                                    .font(.caption)
                                    .foregroundStyle(Theme.textSecondary)
                            }
                            HStack(spacing: 3) {
                                Image(systemName: "star.fill")
                                    .font(.caption2)
                                    .foregroundStyle(Theme.accent)
                                Text("\(friend.totalXP)")
                                    .font(.caption)
                                    .foregroundStyle(Theme.textSecondary)
                            }
                        }
                    }
                }
            }
            .buttonStyle(.plain)

            Spacer()

            Button {
                onPoke()
            } label: {
                Image(systemName: "hand.tap.fill")
                    .font(.subheadline)
                    .foregroundStyle(canPoke ? Theme.accent : Theme.textSecondary.opacity(0.3))
                    .padding(8)
                    .background(Theme.accent.opacity(canPoke ? 0.15 : 0.05))
                    .clipShape(Circle())
            }
            .disabled(!canPoke)
        }
        .padding(14)
        .background(Theme.card)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                onRemove()
            } label: {
                Label("Remove", systemImage: "person.badge.minus")
            }
        }
        .contextMenu {
            Button(role: .destructive) {
                onRemove()
            } label: {
                Label("Remove Friend", systemImage: "person.badge.minus")
            }
        }
    }
}

// MARK: - Friend Profile Sheet

struct FriendProfileSheet: View {
    let friend: FriendProfile
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Avatar & name
                    VStack(spacing: 10) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 72))
                            .foregroundStyle(Theme.accent.opacity(0.6))
                        Text(friend.displayName)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(Theme.textPrimary)
                        Text("Friend Code: \(friend.friendCode)")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(Theme.textSecondary)
                    }
                    .padding(.top, 8)

                    // Stats grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        StatCard(
                            icon: "flame.fill",
                            iconColor: .orange,
                            title: "Streak",
                            value: "\(friend.currentStreak) days"
                        )
                        StatCard(
                            icon: "checkmark.circle.fill",
                            iconColor: .green,
                            title: "Solved",
                            value: "\(friend.solvedCount)"
                        )
                        StatCard(
                            icon: "star.fill",
                            iconColor: Theme.accent,
                            title: "Total XP",
                            value: "\(friend.totalXP)"
                        )
                        StatCard(
                            icon: friend.hasCompletedToday ? "checkmark.circle.fill" : "circle",
                            iconColor: friend.hasCompletedToday ? .green : Theme.textSecondary,
                            title: "Today",
                            value: friend.hasCompletedToday ? "Done" : "Not yet"
                        )
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
                    Text(friend.displayName)
                        .font(.title3.bold())
                        .foregroundStyle(.white)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(.white)
                }
            }
        }
        .presentationDetents([.medium])
        .onAppear {
            AnalyticsService.shared.track("friend_profile_view", properties: ["friend_id": friend.id])
        }
    }
}
