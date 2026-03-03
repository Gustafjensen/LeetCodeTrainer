import Foundation
import UIKit

final class AnalyticsService {
    static let shared = AnalyticsService()

    private let baseURL = "https://leetcode-trainer-75896127852.europe-north1.run.app"
    private let queue = DispatchQueue(label: "analytics", qos: .utility)
    private let queueKey = "analyticsEventQueue"
    private let flushInterval: TimeInterval = 30
    private let batchThreshold = 10
    private var eventQueue: [[String: Any]] = []
    private var flushTimer: Timer?

    private let deviceInfo: [String: String] = {
        let device = UIDevice.current
        return [
            "model": device.model,
            "systemVersion": device.systemVersion,
            "appVersion": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown",
            "buildNumber": Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "unknown",
            "locale": Locale.current.identifier
        ]
    }()

    private init() {
        loadQueue()
        startFlushTimer()

        NotificationCenter.default.addObserver(
            self, selector: #selector(appWillResignActive),
            name: UIApplication.willResignActiveNotification, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(appDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification, object: nil
        )
    }

    func track(_ event: String, properties: [String: String] = [:]) {
        queue.async { [weak self] in
            guard let self else { return }
            let entry: [String: Any] = [
                "name": event,
                "timestamp": ISO8601DateFormatter().string(from: Date()),
                "properties": properties
            ]
            self.eventQueue.append(entry)
            self.persistQueue()

            if self.eventQueue.count >= self.batchThreshold {
                self.flush()
            }
        }
    }

    private func startFlushTimer() {
        DispatchQueue.main.async { [weak self] in
            self?.flushTimer = Timer.scheduledTimer(withTimeInterval: self?.flushInterval ?? 30, repeats: true) { _ in
                self?.queue.async { self?.flush() }
            }
        }
    }

    @objc private func appWillResignActive() {
        queue.async { [weak self] in
            self?.flush()
        }
    }

    @objc private func appDidBecomeActive() {
        track("app_foreground")
    }

    private func flush() {
        guard !eventQueue.isEmpty else { return }
        guard NetworkMonitor.shared.isConnected else { return }

        let eventsToSend = eventQueue
        eventQueue.removeAll()
        persistQueue()

        let body: [String: Any] = [
            "events": eventsToSend,
            "deviceInfo": deviceInfo
        ]

        guard let url = URL(string: "\(baseURL)/analytics"),
              let jsonData = try? JSONSerialization.data(withJSONObject: body) else {
            // Put events back on failure to serialize
            eventQueue.append(contentsOf: eventsToSend)
            persistQueue()
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(Secrets.apiKey, forHTTPHeaderField: "x-api-key")
        request.httpBody = jsonData
        request.timeoutInterval = 10

        URLSession.shared.dataTask(with: request) { [weak self] _, response, error in
            if let error {
                #if DEBUG
                print("Analytics flush error: \(error.localizedDescription)")
                #endif
                // Re-queue events on failure
                self?.queue.async {
                    self?.eventQueue.append(contentsOf: eventsToSend)
                    self?.persistQueue()
                }
                return
            }
            if let http = response as? HTTPURLResponse, http.statusCode == 200 {
                #if DEBUG
                print("Analytics: flushed \(eventsToSend.count) events")
                #endif
            } else {
                self?.queue.async {
                    self?.eventQueue.append(contentsOf: eventsToSend)
                    self?.persistQueue()
                }
            }
        }.resume()
    }

    private func persistQueue() {
        guard let data = try? JSONSerialization.data(withJSONObject: eventQueue) else { return }
        UserDefaults.standard.set(data, forKey: queueKey)
    }

    private func loadQueue() {
        guard let data = UserDefaults.standard.data(forKey: queueKey),
              let stored = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else { return }
        eventQueue = stored
    }
}
