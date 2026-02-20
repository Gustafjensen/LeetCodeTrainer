import WidgetKit
import SwiftUI

// MARK: - Shared data reader

struct WidgetData {
    let currentStreak: Int
    let isDailyCompleted: Bool

    static func load() -> WidgetData {
        let defaults = UserDefaults(suiteName: "group.GustafJensen.LeetCodeTrainer") ?? .standard

        let completedDates = Set(defaults.stringArray(forKey: "completedDailyDates") ?? [])

        // Calculate current streak
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")

        let cal = Calendar.current
        var date = cal.startOfDay(for: .now)
        let todayKey = formatter.string(from: date)
        let isDailyCompleted = completedDates.contains(todayKey)

        if !isDailyCompleted {
            guard let yesterday = cal.date(byAdding: .day, value: -1, to: date) else {
                return WidgetData(currentStreak: 0, isDailyCompleted: false)
            }
            date = yesterday
        }

        var streak = 0
        while completedDates.contains(formatter.string(from: date)) {
            streak += 1
            guard let prev = cal.date(byAdding: .day, value: -1, to: date) else { break }
            date = prev
        }

        return WidgetData(currentStreak: streak, isDailyCompleted: isDailyCompleted)
    }
}

// MARK: - Timeline

struct StreakEntry: TimelineEntry {
    let date: Date
    let streak: Int
    let isDailyCompleted: Bool
}

struct StreakProvider: TimelineProvider {
    func placeholder(in context: Context) -> StreakEntry {
        StreakEntry(date: .now, streak: 3, isDailyCompleted: false)
    }

    func getSnapshot(in context: Context, completion: @escaping (StreakEntry) -> Void) {
        let data = WidgetData.load()
        completion(StreakEntry(date: .now, streak: data.currentStreak, isDailyCompleted: data.isDailyCompleted))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<StreakEntry>) -> Void) {
        let data = WidgetData.load()
        let entry = StreakEntry(date: .now, streak: data.currentStreak, isDailyCompleted: data.isDailyCompleted)

        // Refresh at the start of the next day
        let cal = Calendar.current
        let tomorrow = cal.startOfDay(for: cal.date(byAdding: .day, value: 1, to: .now)!)
        let timeline = Timeline(entries: [entry], policy: .after(tomorrow))
        completion(timeline)
    }
}

// MARK: - Widget View

struct StreakWidgetView: View {
    let entry: StreakEntry

    var body: some View {
        VStack(spacing: 8) {
            // Streak
            HStack(spacing: 6) {
                Image(systemName: "flame.fill")
                    .font(.title2)
                    .foregroundStyle(entry.streak > 0 ? .orange : .gray)

                VStack(alignment: .leading, spacing: 1) {
                    Text("\(entry.streak)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                    Text("day streak")
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.7))
                }

                Spacer()
            }

            Spacer()

            // Daily status
            HStack(spacing: 6) {
                Image(systemName: entry.isDailyCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.subheadline)
                    .foregroundStyle(entry.isDailyCompleted ? .green : .white.opacity(0.5))

                Text(entry.isDailyCompleted ? "Daily done" : "Daily pending")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(entry.isDailyCompleted ? .green : .white.opacity(0.5))

                Spacer()
            }
        }
        .padding(14)
        .containerBackground(for: .widget) {
            LinearGradient(
                colors: [
                    Color(red: 0.1, green: 0.15, blue: 0.35),
                    Color(red: 0.06, green: 0.09, blue: 0.25)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

// MARK: - Widget Configuration

@main
struct LeetCodeTrainerWidget: Widget {
    let kind = "LeetCodeTrainerWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: StreakProvider()) { entry in
            StreakWidgetView(entry: entry)
        }
        .configurationDisplayName("Streak")
        .description("Track your coding streak and daily challenge.")
        .supportedFamilies([.systemSmall])
    }
}
