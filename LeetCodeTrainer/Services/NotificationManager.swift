import Foundation
import UserNotifications

final class NotificationManager {
    static let shared = NotificationManager()

    private let notificationID = "daily-streak-reminder"

    private init() {}

    // MARK: - Permission

    func requestPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { granted, _ in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }

    // MARK: - Scheduling

    func scheduleStreakReminder() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [notificationID])

        let xpManager = SkillXPManager.shared

        guard xpManager.currentStreak() > 0,
              !xpManager.isDailyCompleted(for: .now) else {
            return
        }

        let enabled = UserDefaults.standard.bool(forKey: "streakRemindersEnabled")
        guard enabled else { return }

        let content = UNMutableNotificationContent()
        content.title = "Don't break your streak!"
        content.body = "You have a \(xpManager.currentStreak())-day streak. Complete today's challenge to keep it going!"
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = 18
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: true
        )

        let request = UNNotificationRequest(
            identifier: notificationID,
            content: content,
            trigger: trigger
        )

        center.add(request)
    }

    func cancelStreakReminder() {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [notificationID])
    }

    func refreshNotificationState() {
        let enabled = UserDefaults.standard.bool(forKey: "streakRemindersEnabled")
        if enabled {
            scheduleStreakReminder()
        } else {
            cancelStreakReminder()
        }
    }
}
