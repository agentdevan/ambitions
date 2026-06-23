import SwiftUI

struct AmbitionsRootStageSurfaceHost: View {
    @Binding var navigation: StageStore

    let creationMessage: GoalDetailInlineMessage?
    let goalsRefreshID: Int
    let onCreateGoal: (ShellCommandEntrySource, String, String?) -> Void
    let onToolbarAction: (AppShellContextualToolbarAction, AmbitionsSurface) -> Void

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
                TodaySurface(showsNavigationChrome: false)
            }
        }
    }

    private var goalsNavigation: some View {
        NavigationStack(path: $navigation.goalsPath) {
            AppShellScaffold(
                title: "Goals",
                subtitle: nil,
                posture: .direction,
                trailingButtons: shellUtilityButtons(for: .goals)
            ) {
                GoalsSurface(
                    externalCreationMessage: creationMessage,
                    externalRefreshID: goalsRefreshID,
                    showsNavigationChrome: false
                )
            }
            .navigationDestination(for: GoalRouteTarget.self) { target in
                if target.isLifeAreaRoute, let lifeAreaID = target.lifeAreaID {
                    AppShellScaffold(
                        title: GoalsLifeAreaTitle.title(for: lifeAreaID),
                        subtitle: nil,
                        posture: .direction,
                        backButtonAccessibilityIdentifier: "shell.goals.back-button",
                        onBack: { navigation.resetGoalsPath() },
                        trailingButtons: []
                    ) {
                        AreaDetailScreen(lifeAreaID: lifeAreaID)
                    }
                } else {
                    GoalDetailScreen(target: target)
                }
            }
        }
    }

    private var timeNavigation: some View {
        NavigationStack(path: $navigation.timePath) {
            AppShellScaffold(
                title: "Time",
                subtitle: nil,
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
                subtitle: nil,
                posture: .utility,
                trailingButtons: shellUtilityButtons(for: .you)
            ) {
                YouSurface(showsNavigationChrome: false)
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
                case .personalSystem,
                     .privacyAutomation,
                     .receiptsHistory,
                     .lifeAreas,
                     .scheduleAvailability,
                     .planningDefaults,
                     .vacationAwayTime,
                     .localContextControls,
                     .notifications,
                     .capturePreferences,
                     .sessionDefaults,
                     .appearance,
                     .privacy,
                     .sourceSettings,
                     .localDataControls,
                     .accessibility,
                     .exportImport,
                     .help,
                     .about:
                    AppShellScaffold(
                        title: target.title,
                        subtitle: nil,
                        posture: .utility,
                        backButtonAccessibilityIdentifier: "shell.you.back-button",
                        onBack: { navigation.resetYouPath() },
                        trailingButtons: []
                    ) {
                        YouRootDetailRouteSurface(detail: rootDetail(for: target))
                    }
                }
            }
        }
    }

    private func rootDetail(for target: YouRouteTarget) -> YouRootDetail {
        switch target {
        case .monthlyReview:
            .reviews
        case .history:
            .proof
        case .personalSystem:
            .personalRuntime
        case .privacyAutomation:
            .automationTrust
        case .receiptsHistory:
            .receiptsHistory
        case .lifeAreas:
            .lifeAreas
        case .scheduleAvailability:
            .scheduleAvailability
        case .planningDefaults:
            .planBehavior
        case .vacationAwayTime:
            .vacationAwayTime
        case .localContextControls:
            .whatAmbitionsKnows
        case .notifications:
            .notifications
        case .capturePreferences:
            .capturePreferences
        case .sessionDefaults:
            .sessionDefaults
        case .appearance:
            .appearance
        case .privacy:
            .trustCenter
        case .sourceSettings:
            .sourceSettings
        case .localDataControls:
            .localDataControls
        case .accessibility:
            .accessibility
        case .exportImport:
            .exportImport
        case .help:
            .support
        case .about:
            .about
        }
    }

    private func shellUtilityButtons(for tab: AmbitionsSurface) -> [AppShellHeaderButton] {
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
