import CloudKit
import Foundation

@Observable
class CloudKitManager {
    static let shared = CloudKitManager()

    let container = CKContainer(identifier: "iCloud.GustafJensen.LeetCodeTrainer")
    private var publicDB: CKDatabase { container.publicCloudDatabase }

    var iCloudAvailable = false
    var userRecordName: String?
    var myFriendCode: String?
    var friends: [FriendProfile] = []
    var pendingPokes: [PokeRecord] = []
    var isLoading = false
    var errorMessage: String?

    private let pokeTimestampsKey = "pokeTimestamps"

    private init() {}

    // MARK: - Account

    func checkiCloudStatus() async {
        do {
            let status = try await container.accountStatus()
            await MainActor.run {
                iCloudAvailable = status == .available
            }
            if status == .available {
                let userID = try await container.userRecordID()
                await MainActor.run {
                    userRecordName = userID.recordName
                }
            }
        } catch {
            await MainActor.run {
                iCloudAvailable = false
            }
        }
    }

    // MARK: - User Profile

    func ensureUserProfile() async {
        guard let recordName = userRecordName else { return }

        let recordID = CKRecord.ID(recordName: "profile-\(recordName)")
        do {
            let record = try await publicDB.record(for: recordID)
            await MainActor.run {
                myFriendCode = record["friendCode"] as? String
            }
        } catch {
            // Profile doesn't exist, create it
            let record = CKRecord(recordType: "UserProfile", recordID: recordID)
            let code = await generateUniqueFriendCode()
            let xp = SkillXPManager.shared

            record["displayName"] = xp.userName.isEmpty ? "CodeCrusher" : xp.userName
            record["friendCode"] = code
            record["currentStreak"] = xp.currentStreak()
            record["solvedCount"] = xp.solvedProblems.count
            record["totalXP"] = xp.totalXP()
            record["ownerRecordName"] = recordName

            if let lastDate = xp.completedDailyDates.sorted().last {
                record["lastDailyDate"] = lastDate
            }

            do {
                try await publicDB.save(record)
                await MainActor.run {
                    myFriendCode = code
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Could not create profile"
                }
            }
        }
    }

    func syncUserProfile() async {
        guard let recordName = userRecordName else { return }

        let recordID = CKRecord.ID(recordName: "profile-\(recordName)")
        do {
            let record = try await publicDB.record(for: recordID)
            let xp = SkillXPManager.shared

            record["displayName"] = xp.userName.isEmpty ? "CodeCrusher" : xp.userName
            record["currentStreak"] = xp.currentStreak()
            record["solvedCount"] = xp.solvedProblems.count
            record["totalXP"] = xp.totalXP()

            if let lastDate = xp.completedDailyDates.sorted().last {
                record["lastDailyDate"] = lastDate
            }

            try await publicDB.save(record)
        } catch {
            // Silent fail for background sync
        }
    }

    // MARK: - Friend Code

    private func generateUniqueFriendCode() async -> String {
        let chars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
        for _ in 0..<10 {
            let code = String((0..<6).map { _ in chars.randomElement()! })
            let predicate = NSPredicate(format: "friendCode == %@", code)
            let query = CKQuery(recordType: "UserProfile", predicate: predicate)
            do {
                let (results, _) = try await publicDB.records(matching: query, resultsLimit: 1)
                if results.isEmpty {
                    return code
                }
            } catch {
                return code
            }
        }
        return String((0..<6).map { _ in chars.randomElement()! })
    }

    // MARK: - Friends

    func addFriend(byCode code: String) async throws {
        guard let myRecordName = userRecordName else {
            throw FriendsError.notSignedIn
        }

        let upperCode = code.uppercased().trimmingCharacters(in: .whitespacesAndNewlines)

        // Find user with this code
        let predicate = NSPredicate(format: "friendCode == %@", upperCode)
        let query = CKQuery(recordType: "UserProfile", predicate: predicate)
        let (results, _) = try await publicDB.records(matching: query, resultsLimit: 1)

        guard let (_, result) = results.first else {
            throw FriendsError.userNotFound
        }

        let friendProfile = try result.get()
        let friendRecordName = friendProfile["ownerRecordName"] as? String ?? friendProfile.recordID.recordName

        if friendRecordName == myRecordName {
            throw FriendsError.cannotAddSelf
        }

        // Check if already friends
        do {
            let existingPredicate = NSPredicate(
                format: "userRecordName == %@ AND friendRecordName == %@",
                myRecordName, friendRecordName
            )
            let existingQuery = CKQuery(recordType: "Friendship", predicate: existingPredicate)
            let (existing, _) = try await publicDB.records(matching: existingQuery, resultsLimit: 1)
            if !existing.isEmpty {
                throw FriendsError.alreadyFriends
            }
        } catch let error as CKError where error.code == .unknownItem {
            // Record type doesn't exist yet — no friendships, so not already friends
        }

        // Create both friendship records (bidirectional)
        let friendship1 = CKRecord(recordType: "Friendship")
        friendship1["userRecordName"] = myRecordName
        friendship1["friendRecordName"] = friendRecordName
        friendship1["createdAt"] = Date()

        let friendship2 = CKRecord(recordType: "Friendship")
        friendship2["userRecordName"] = friendRecordName
        friendship2["friendRecordName"] = myRecordName
        friendship2["createdAt"] = Date()

        try await publicDB.save(friendship1)
        try await publicDB.save(friendship2)

        // Add the friend immediately from the profile we already fetched
        let newFriend = FriendProfile(record: friendProfile)
        await MainActor.run {
            if !friends.contains(where: { $0.id == newFriend.id }) {
                friends.append(newFriend)
                friends.sort { $0.currentStreak > $1.currentStreak }
            }
        }
    }

    func loadFriends() async {
        guard let myRecordName = userRecordName else { return }

        await MainActor.run { isLoading = true }

        do {
            let predicate = NSPredicate(format: "userRecordName == %@", myRecordName)
            let query = CKQuery(recordType: "Friendship", predicate: predicate)
            let (results, _) = try await publicDB.records(matching: query, resultsLimit: 50)

            var friendProfiles: [FriendProfile] = []
            for (_, result) in results {
                guard let record = try? result.get(),
                      let friendRecordName = record["friendRecordName"] as? String else { continue }

                let profileID = CKRecord.ID(recordName: "profile-\(friendRecordName)")
                if let profile = try? await publicDB.record(for: profileID) {
                    friendProfiles.append(FriendProfile(record: profile))
                }
            }

            await MainActor.run {
                friends = friendProfiles.sorted { $0.currentStreak > $1.currentStreak }
                isLoading = false
            }
        } catch let error as CKError where error.code == .unknownItem {
            // Record type doesn't exist yet — no friends added yet
            await MainActor.run {
                friends = []
                isLoading = false
            }
        } catch {
            await MainActor.run {
                isLoading = false
                errorMessage = "Could not load friends"
            }
        }
    }

    func removeFriend(_ friendID: String) async throws {
        guard let myRecordName = userRecordName else { return }

        // Delete my -> friend record
        let pred1 = NSPredicate(
            format: "userRecordName == %@ AND friendRecordName == %@",
            myRecordName, friendID
        )
        let q1 = CKQuery(recordType: "Friendship", predicate: pred1)
        let (results1, _) = try await publicDB.records(matching: q1, resultsLimit: 1)
        for (recordID, _) in results1 {
            try await publicDB.deleteRecord(withID: recordID)
        }

        // Delete friend -> me record
        let pred2 = NSPredicate(
            format: "userRecordName == %@ AND friendRecordName == %@",
            friendID, myRecordName
        )
        let q2 = CKQuery(recordType: "Friendship", predicate: pred2)
        let (results2, _) = try await publicDB.records(matching: q2, resultsLimit: 1)
        for (recordID, _) in results2 {
            try await publicDB.deleteRecord(withID: recordID)
        }

        await loadFriends()
    }

    // MARK: - Pokes

    func pokeFriend(_ friendRecordName: String) async throws {
        guard let myRecordName = userRecordName else {
            throw FriendsError.notSignedIn
        }

        guard canPoke(friendRecordName) else {
            throw FriendsError.pokeCooldown
        }

        let poke = CKRecord(recordType: "Poke")
        poke["fromRecordName"] = myRecordName
        poke["fromDisplayName"] = SkillXPManager.shared.userName.isEmpty ? "A friend" : SkillXPManager.shared.userName
        poke["toRecordName"] = friendRecordName
        poke["timestamp"] = Date()
        poke["isRead"] = 0

        try await publicDB.save(poke)
        recordPokeTimestamp(friendRecordName)
    }

    func loadPendingPokes() async {
        guard let myRecordName = userRecordName else { return }

        do {
            let predicate = NSPredicate(format: "toRecordName == %@ AND isRead == 0", myRecordName)
            let query = CKQuery(recordType: "Poke", predicate: predicate)
            query.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
            let (results, _) = try await publicDB.records(matching: query, resultsLimit: 20)

            let dismissed = Set(UserDefaults.standard.stringArray(forKey: "dismissedPokes") ?? [])
            var pokes: [PokeRecord] = []
            for (_, result) in results {
                if let record = try? result.get() {
                    let poke = PokeRecord(record: record)
                    if !dismissed.contains(poke.id) {
                        pokes.append(poke)
                    }
                }
            }

            await MainActor.run {
                pendingPokes = pokes
            }
        } catch let error as CKError where error.code == .unknownItem {
            // Record type doesn't exist yet — no pokes sent yet
        } catch {
            // Silent fail
        }
    }

    func dismissPoke(_ poke: PokeRecord) async {
        // Remove from UI immediately
        await MainActor.run {
            pendingPokes.removeAll { $0.id == poke.id }
        }
        // Store dismissed poke IDs locally so they don't reappear
        var dismissed = UserDefaults.standard.stringArray(forKey: "dismissedPokes") ?? []
        dismissed.append(poke.id)
        UserDefaults.standard.set(dismissed, forKey: "dismissedPokes")

        // Best-effort: mark as read in CloudKit
        do {
            let record = try await publicDB.record(for: poke.recordID)
            record["isRead"] = 1
            try await publicDB.save(record)
        } catch {
            // May fail if we don't own the record — that's fine
        }
    }

    // MARK: - Push Notification Subscription

    func subscribeToPokeNotifications() async {
        guard let myRecordName = userRecordName else { return }

        let subscriptionID = "poke-notifications-\(myRecordName)"

        // Check if subscription already exists
        do {
            _ = try await publicDB.subscription(for: subscriptionID)
            return // Already subscribed
        } catch {
            // Not subscribed yet, create it
        }

        let predicate = NSPredicate(format: "toRecordName == %@", myRecordName)
        let subscription = CKQuerySubscription(
            recordType: "Poke",
            predicate: predicate,
            subscriptionID: subscriptionID,
            options: [.firesOnRecordCreation]
        )

        let info = CKSubscription.NotificationInfo()
        info.title = "Streak Reminder"
        info.alertBody = "A friend poked you! Don't break your streak!"
        info.desiredKeys = ["fromDisplayName"]
        info.soundName = "default"
        info.shouldBadge = true
        info.shouldSendContentAvailable = true

        subscription.notificationInfo = info

        do {
            try await publicDB.save(subscription)
        } catch {
            // Poke record type may not exist yet — will retry on next launch
        }
    }

    // MARK: - Poke Cooldown

    func canPoke(_ friendRecordName: String) -> Bool {
        let timestamps = UserDefaults.standard.dictionary(forKey: pokeTimestampsKey) as? [String: Double] ?? [:]
        guard let lastPoke = timestamps[friendRecordName] else { return true }
        return Date().timeIntervalSince1970 - lastPoke > 12 * 3600
    }

    private func recordPokeTimestamp(_ friendRecordName: String) {
        var timestamps = UserDefaults.standard.dictionary(forKey: pokeTimestampsKey) as? [String: Double] ?? [:]
        timestamps[friendRecordName] = Date().timeIntervalSince1970
        UserDefaults.standard.set(timestamps, forKey: pokeTimestampsKey)
    }
}

enum FriendsError: LocalizedError {
    case notSignedIn
    case userNotFound
    case cannotAddSelf
    case alreadyFriends
    case pokeCooldown

    var errorDescription: String? {
        switch self {
        case .notSignedIn: return "Sign in to iCloud to use Friends."
        case .userNotFound: return "No user found with that code."
        case .cannotAddSelf: return "That's your own code!"
        case .alreadyFriends: return "You're already friends!"
        case .pokeCooldown: return "You can only poke once every 12 hours."
        }
    }
}
