//
//  LeetCodeTrainerApp.swift
//  LeetCodeTrainer
//
//  Created by Gustaf Jensen on 2026-02-18.
//

import SwiftUI

@main
struct LeetCodeTrainerApp: App {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false

    var body: some Scene {
        WindowGroup {
            if hasSeenOnboarding {
                MainTabView()
            } else {
                OnboardingView {
                    withAnimation {
                        hasSeenOnboarding = true
                    }
                }
            }
        }
    }
}
