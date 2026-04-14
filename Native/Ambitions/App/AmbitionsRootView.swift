import AmbitionsDesignSystem
import SwiftUI

struct AmbitionsRootView: View {
    private let container: AppContainer
    @State private var navigation: AppNavigationModel

    init(container: AppContainer) {
        self.container = container
        _navigation = State(initialValue: container.navigation)
    }

    var body: some View {
        TabView(selection: $navigation.selectedTab) {
            tabNavigation(tab: .today) { TodayScreen() }
            goalsNavigation()
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

    private func goalsNavigation() -> some View {
        NavigationStack(path: $navigation.goalsPath) {
            GoalsScreen()
                .navigationDestination(for: GoalRouteTarget.self) { target in
                    GoalDetailScreen(target: target)
                }
        }
        .tag(AppTab.goals)
        .tabItem {
            Label(AppTab.goals.title, systemImage: AppTab.goals.systemImage)
        }
    }
}
