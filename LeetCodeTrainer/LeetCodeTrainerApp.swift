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
        }
    }
}
