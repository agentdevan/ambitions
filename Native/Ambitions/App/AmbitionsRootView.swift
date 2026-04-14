import AmbitionsDesignSystem
import SwiftUI

struct AmbitionsRootView: View {
    private let container: AppContainer
    @State private var selectedTab: AppTab

    init(container: AppContainer) {
        self.container = container
        _selectedTab = State(initialValue: container.session.initialTab)
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            tabNavigation(tab: .today) { TodayScreen() }
            tabNavigation(tab: .goals) { GoalsScreen() }
            tabNavigation(tab: .habits) { HabitsScreen() }
            tabNavigation(tab: .insights) { InsightsScreen() }
            tabNavigation(tab: .profile) { ProfileScreen() }
        }
        .appContainer(container)
        .ambitionTheme(container.theme)
    }

    private func tabNavigation<Content: View>(tab: AppTab, @ViewBuilder content: () -> Content) -> some View {
        NavigationStack {
            content()
        }
        .tag(tab)
        .tabItem {
            Label(tab.title, systemImage: tab.systemImage)
        }
    }
}
