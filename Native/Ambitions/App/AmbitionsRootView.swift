import AmbitionsDesignSystem
import SwiftUI

struct AmbitionsRootView: View {
    @Environment(\.colorScheme) private var systemColorScheme
    private let container: AppContainer
    @State private var navigation: AppNavigationModel

    init(container: AppContainer) {
        self.container = container
        _navigation = State(initialValue: container.navigation)
    }

    var body: some View {
        TabView(selection: $navigation.selectedTab) {
            todayNavigation()
            goalsNavigation()
            planNavigation()
            tabNavigation(tab: .insights) { InsightsScreen() }
            tabNavigation(tab: .profile) { ProfileScreen() }
        }
        .appContainer(container)
        .preferredColorScheme(container.appearancePreference.preferredColorScheme)
        .ambitionTheme(container.appearancePreference.resolveTheme(systemColorScheme: systemColorScheme))
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

    private func todayNavigation() -> some View {
        NavigationStack(path: $navigation.todayPath) {
            TodayScreen()
                .navigationDestination(for: TodayRouteTarget.self) { target in
                    switch target {
                    case .capturesInbox:
                        CapturesScreen()
                    }
                }
        }
        .tag(AppTab.today)
        .tabItem {
            Label(AppTab.today.title, systemImage: AppTab.today.systemImage)
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

    private func planNavigation() -> some View {
        NavigationStack(path: $navigation.planPath) {
            PlanScreen()
                .navigationDestination(for: PlanRouteTarget.self) { target in
                    switch target {
                    case .habits:
                        HabitsScreen()
                    }
                }
                .navigationDestination(for: GoalRouteTarget.self) { target in
                    GoalDetailScreen(target: target)
                }
        }
        .tag(AppTab.plan)
        .tabItem {
            Label(AppTab.plan.title, systemImage: AppTab.plan.systemImage)
        }
    }
}
