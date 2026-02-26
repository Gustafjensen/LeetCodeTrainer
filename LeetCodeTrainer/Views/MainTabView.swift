import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @State private var viewModel = ProblemListViewModel()

    init() {
        // Tab bar
        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithOpaqueBackground()
        tabAppearance.backgroundColor = UIColor(Theme.primaryDark)

        let normalAttrs: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white.withAlphaComponent(0.4)
        ]
        let selectedAttrs: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor(Theme.accent)
        ]

        tabAppearance.stackedLayoutAppearance.normal.iconColor = .white.withAlphaComponent(0.4)
        tabAppearance.stackedLayoutAppearance.normal.titleTextAttributes = normalAttrs
        tabAppearance.stackedLayoutAppearance.selected.iconColor = UIColor(Theme.accent)
        tabAppearance.stackedLayoutAppearance.selected.titleTextAttributes = selectedAttrs

        // Add spacing above icons
        tabAppearance.stackedLayoutAppearance.normal.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -2)
        tabAppearance.stackedLayoutAppearance.selected.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -2)

        UITabBar.appearance().standardAppearance = tabAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabAppearance

        // Push content down from the top edge of the tab bar
        UITabBar.appearance().layoutMargins = UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0)

        // Navigation bar
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithOpaqueBackground()
        navAppearance.backgroundColor = UIColor(Theme.primary)
        navAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]

        let backImage = UIImage(systemName: "chevron.left")?
            .withTintColor(.white, renderingMode: .alwaysOriginal)
        navAppearance.setBackIndicatorImage(backImage, transitionMaskImage: backImage)

        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().compactAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
        UINavigationBar.appearance().tintColor = .white
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            DailyProblemView(viewModel: viewModel)
                .tabItem {
                    Label("Daily", systemImage: "calendar")
                }
                .tag(0)
            ProblemListView(viewModel: viewModel)
                .tabItem {
                    Label("Problems", systemImage: "list.bullet.rectangle.fill")
                }
                .tag(1)
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(2)
            ProfileView(problems: viewModel.problems)
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(3)
        }
        .tint(Theme.accent)
    }
}
