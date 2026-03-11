//
//  LeetCodeTrainerApp.swift
//  LeetCodeTrainer
//
//  Created by Gustaf Jensen on 2026-02-18.
//

import SwiftUI
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        application.registerForRemoteNotifications()
        return true
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) async -> UIBackgroundFetchResult {
        // Refresh pokes when a push arrives
        await CloudKitManager.shared.loadPendingPokes()
        return .newData
    }
}

@main
struct LeetCodeTrainerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var showSplash = true

    var body: some Scene {
        WindowGroup {
            ZStack {
                if hasSeenOnboarding {
                    MainTabView()
                } else {
                    OnboardingView {
                        withAnimation {
                            hasSeenOnboarding = true
                        }
                        AnalyticsService.shared.track("onboarding_complete")
                    }
                }

                if showSplash {
                    SplashScreenView {
                        withAnimation(.easeOut(duration: 0.4)) {
                            showSplash = false
                        }
                    }
                    .transition(.opacity)
                    .zIndex(1)
                }
            }
            .onAppear {
                AnalyticsService.shared.track("app_launch")
                NotificationManager.shared.requestPermission { granted in
                    if granted {
                        NotificationManager.shared.scheduleStreakReminder()
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                }
                Task {
                    let ck = CloudKitManager.shared
                    await ck.checkiCloudStatus()
                    if ck.iCloudAvailable {
                        await ck.ensureUserProfile()
                        await ck.syncUserProfile()
                        await ck.loadPendingPokes()
                        await ck.subscribeToPokeNotifications()
                    }
                }
            }
        }
    }
}
