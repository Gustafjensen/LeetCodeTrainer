import Foundation
import CloudKit

struct FriendProfile: Identifiable {
    let id: String
    let displayName: String
    let friendCode: String
    let currentStreak: Int
    let solvedCount: Int
    let totalXP: Int
    let lastDailyDate: String?

    var hasCompletedToday: Bool {
        guard let lastDate = lastDailyDate else { return false }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return lastDate == formatter.string(from: .now)
    }

    init(record: CKRecord) {
        id = record["ownerRecordName"] as? String ?? record.recordID.recordName
        displayName = record["displayName"] as? String ?? "Unknown"
        friendCode = record["friendCode"] as? String ?? ""
        currentStreak = record["currentStreak"] as? Int ?? 0
        solvedCount = record["solvedCount"] as? Int ?? 0
        totalXP = record["totalXP"] as? Int ?? 0
        lastDailyDate = record["lastDailyDate"] as? String
    }
}

struct PokeRecord: Identifiable {
    let id: String
    let fromDisplayName: String
    let fromRecordName: String
    let timestamp: Date
    let recordID: CKRecord.ID

    init(record: CKRecord) {
        id = record.recordID.recordName
        fromDisplayName = record["fromDisplayName"] as? String ?? "Someone"
        fromRecordName = record["fromRecordName"] as? String ?? ""
        timestamp = record["timestamp"] as? Date ?? .now
        recordID = record.recordID
    }
}
