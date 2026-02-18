import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 1
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

        UITabBar.appearance().standardAppearance = tabAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabAppearance

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
            Tab("Daily", systemImage: "calendar", value: 0) {
                DailyProblemView(viewModel: viewModel)
            }
            Tab("Problems", systemImage: "list.bullet.rectangle.fill", value: 1) {
                ProblemListView(viewModel: viewModel)
            }
            Tab("Settings", systemImage: "gearshape.fill", value: 2) {
                SettingsView()
            }
            Tab("Profile", systemImage: "person.fill", value: 3) {
                ProfileView()
            }
        }
        .tint(Theme.accent)
    }
}
