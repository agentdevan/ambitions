import SwiftUI

struct AmbitionsRootStageSurfaceHost: View {
    @Binding var navigation: AppNavigationModel

    let creationMessage: GoalDetailInlineMessage?
    let goalsRefreshID: Int
    let onCreateGoal: (ShellCommandEntrySource, String, String?) -> Void
    let onToolbarAction: (AppShellContextualToolbarAction, AppTab) -> Void

    var body: some View {
        Group {
            switch navigation.selectedTab {
            case .today:
                todayNavigation
            case .goals:
                goalsNavigation
            case .time:
                timeNavigation
            case .you:
                youNavigation
            }
        }
        .accessibilityIdentifier("shell.stage.host")
    }

    private var todayNavigation: some View {
        NavigationStack {
            AppShellScaffold(
                title: "Today",
                subtitle: "Start here",
                posture: .execution,
                trailingButtons: shellUtilityButtons(for: .today),
                reservesPrimaryObjectTopClearance: true
            ) {
                TodayScreen(showsNavigationChrome: false)
            }
        }
    }

    private var goalsNavigation: some View {
        NavigationStack(path: $navigation.goalsPath) {
            AppShellScaffold(
                title: "Goals",
                subtitle: "Constellation Atlas",
                posture: .direction,
                trailingButtons: shellUtilityButtons(for: .goals)
            ) {
                GoalsScreen(
                    externalCreationMessage: creationMessage,
                    externalRefreshID: goalsRefreshID,
                    showsNavigationChrome: false,
                    onCreateGoal: {
                        onCreateGoal(.goalsCreate, "", nil)
                    }
                )
            }
            .navigationDestination(for: GoalRouteTarget.self) { target in
                GoalDetailScreen(target: target)
            }
        }
    }

    private var timeNavigation: some View {
        NavigationStack(path: $navigation.timePath) {
            AppShellScaffold(
                title: "Time",
                subtitle: "LifeShape Field",
                posture: .shaping,
                trailingButtons: shellUtilityButtons(for: .time)
            ) {
                TimeSurface(showsNavigationChrome: false)
            }
            .navigationDestination(for: TimeRouteTarget.self) { target in
                switch target {
                case .rituals:
                    AppShellScaffold(
                        title: "Rituals",
                        subtitle: "LifeShape Field",
                        posture: .shaping,
                        backButtonAccessibilityIdentifier: "shell.time.back-button",
                        onBack: { navigation.resetTimePath() },
                        trailingButtons: []
                    ) {
                        TimeRitualsSurface()
                    }
                case .weeklyReview:
                    AppShellScaffold(
                        title: "Weekly Review",
                        subtitle: "LifeShape Field",
                        posture: .shaping,
                        backButtonAccessibilityIdentifier: "shell.time.back-button",
                        onBack: { navigation.resetTimePath() },
                        trailingButtons: []
                    ) {
                        WeeklyReviewScreen()
                    }
                }
            }
            .navigationDestination(for: GoalRouteTarget.self) { target in
                GoalDetailScreen(target: target)
            }
        }
    }

    private var youNavigation: some View {
        NavigationStack(path: $navigation.youPath) {
            AppShellScaffold(
                title: "You",
                subtitle: "Profile and settings",
                posture: .utility,
                trailingButtons: shellUtilityButtons(for: .you)
            ) {
                YouScreen(showsNavigationChrome: false)
            }
            .navigationDestination(for: YouRouteTarget.self) { target in
                switch target {
                case .monthlyReview:
                    AppShellScaffold(
                        title: "Monthly Review",
                        subtitle: "Reflection",
                        posture: .reflection,
                        backButtonAccessibilityIdentifier: "shell.you.back-button",
                        onBack: { navigation.resetYouPath() },
                        trailingButtons: []
                    ) {
                        YouMonthlyReviewSurface()
                    }
                case .history:
                    AppShellScaffold(
                        title: "History",
                        subtitle: "Reflection",
                        posture: .reflection,
                        backButtonAccessibilityIdentifier: "shell.you.back-button",
                        onBack: { navigation.resetYouPath() },
                        trailingButtons: []
                    ) {
                        HistoryInspectionView()
                    }
                }
            }
        }
    }

    private func shellUtilityButtons(for tab: AppTab) -> [AppShellHeaderButton] {
        AppShellContextualToolbarCatalog.actions(for: tab).map { action in
            AppShellHeaderButton(
                kind: action.kind,
                title: action.title,
                systemImage: action.systemImage,
                accessibilityIdentifier: action.accessibilityIdentifier,
                accessibilityLabel: action.accessibilityLabel,
                accessibilityHint: action.accessibilityHint,
                keyboardShortcut: action.kind == .captureFallback ? AppShellHeaderKeyboardShortcut(key: "k", modifiers: [.command]) : nil
            ) {
                onToolbarAction(action, tab)
            }
        }
    }
}
