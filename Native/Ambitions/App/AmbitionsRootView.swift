import AmbitionsDesignSystem
import SwiftUI

struct AmbitionsRootView: View {
    @Environment(\.colorScheme) private var systemColorScheme
    private let container: AppContainer
    @State private var navigation: AppNavigationModel
    @State private var creationMessage: GoalDetailInlineMessage?
    @State private var goalsRefreshID = 0

    init(container: AppContainer) {
        self.container = container
        _navigation = State(initialValue: container.navigation)
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            TabView(selection: $navigation.selectedTab) {
                todayNavigation()
                goalsNavigation()
                planNavigation()
                insightsNavigation()
                profileNavigation()
            }

            shellGlobalEntryButton
        }
        .sheet(item: $navigation.activeOverlay, onDismiss: {
            guard let entryContext = navigation.takePendingTodayEntryContext() else { return }
            navigation.selectToday(entryContext: entryContext)
        }) { overlay in
            AppShellOverlayView(
                overlay: overlay,
                onDismiss: {
                    navigation.dismissOverlay()
                },
                onGoalCreated: { overlayState, response in
                    Task {
                        await handleCreatedGoal(response, from: overlayState)
                    }
                }
            )
        }
        .appContainer(container)
        .preferredColorScheme(container.appearancePreference.preferredColorScheme)
        .ambitionTheme(
            container.appearancePreference.resolveTheme(
                systemColorScheme: systemColorScheme,
                accentFamily: container.accentFamily
            )
        )
    }

    private func todayNavigation() -> some View {
        NavigationStack {
            AppShellScaffold(
                title: "Today",
                subtitle: "Execution",
                posture: .execution,
                trailingButtons: shellUtilityButtons(for: .today)
            ) {
                TodayScreen(showsNavigationChrome: false)
            }
        }
        .tag(AppTab.today)
        .tabItem {
            Label(AppTab.today.title, systemImage: AppTab.today.systemImage)
        }
    }

    private func goalsNavigation() -> some View {
        NavigationStack(path: $navigation.goalsPath) {
            AppShellScaffold(
                title: "Goals",
                subtitle: "Direction",
                posture: .direction,
                trailingButtons: shellUtilityButtons(for: .goals) + [
                    AppShellHeaderButton(
                        title: "Create Goal",
                        systemImage: "plus",
                        accessibilityIdentifier: "shell.goals.create-button"
                    ) {
                        presentCreateGoal(from: .goalsCreate)
                    }
                ]
            ) {
                GoalsScreen(
                    externalCreationMessage: creationMessage,
                    externalRefreshID: goalsRefreshID,
                    showsNavigationChrome: false,
                    onCreateGoal: {
                        presentCreateGoal(from: .goalsCreate)
                    }
                )
            }
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
            AppShellScaffold(
                title: "Plan",
                subtitle: "Shaping",
                posture: .shaping,
                trailingButtons: [
                    AppShellHeaderButton(
                        title: "Captures",
                        systemImage: AppTab.captures.systemImage,
                        accessibilityIdentifier: "shell.plan.open-captures-button"
                    ) {
                        container.commandRouter.route(to: .planRoute(.capturesInbox), source: .shellUtility)
                    }
                ] + shellUtilityButtons(for: .plan)
            ) {
                PlanScreen(showsNavigationChrome: false)
            }
            .navigationDestination(for: PlanRouteTarget.self) { target in
                switch target {
                case .capturesInbox:
                    AppShellScaffold(
                        title: "Captures",
                        subtitle: "Plan-owned inbox",
                        posture: .shaping,
                        backButtonAccessibilityIdentifier: "shell.plan.back-button",
                        onBack: { navigation.resetPlanPath() },
                        trailingButtons: shellUtilityButtons(for: .plan)
                    ) {
                        CapturesScreen()
                    }
                case .habits:
                    AppShellScaffold(
                        title: "Habits",
                        subtitle: "Plan-owned loop view",
                        posture: .shaping,
                        backButtonAccessibilityIdentifier: "shell.plan.back-button",
                        onBack: { navigation.resetPlanPath() },
                        trailingButtons: shellUtilityButtons(for: .plan)
                    ) {
                        HabitsScreen()
                    }
                case .weeklyReview:
                    AppShellScaffold(
                        title: "Weekly Review",
                        subtitle: "Plan shaping continuation",
                        posture: .shaping,
                        backButtonAccessibilityIdentifier: "shell.plan.back-button",
                        onBack: { navigation.resetPlanPath() },
                        trailingButtons: shellUtilityButtons(for: .plan)
                    ) {
                        WeeklyReviewScreen()
                    }
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

    private func insightsNavigation() -> some View {
        NavigationStack(path: $navigation.insightsPath) {
            AppShellScaffold(
                title: "Insights",
                subtitle: "Reflection",
                posture: .reflection,
                trailingButtons: shellUtilityButtons(for: .insights)
            ) {
                InsightsScreen(showsNavigationChrome: false)
            }
            .navigationDestination(for: InsightsRouteTarget.self) { target in
                switch target {
                case .monthlyReview:
                    AppShellScaffold(
                        title: "Monthly Review",
                        subtitle: "Insights-owned review route",
                        posture: .reflection,
                        backButtonAccessibilityIdentifier: "shell.insights.back-button",
                        onBack: { navigation.resetInsightsPath() },
                        trailingButtons: shellUtilityButtons(for: .insights)
                    ) {
                        AppShellPlaceholderRouteView(
                            title: "Monthly Review",
                            subtitle: "Batch 40 establishes ownership without starting the later reflection rebuild.",
                            message: "Monthly Review now belongs to Insights at the shell layer. The full surface stays deferred to the later reflection work."
                        )
                    }
                case .history:
                    AppShellScaffold(
                        title: "History",
                        subtitle: "Insights-owned history route",
                        posture: .reflection,
                        backButtonAccessibilityIdentifier: "shell.insights.back-button",
                        onBack: { navigation.resetInsightsPath() },
                        trailingButtons: shellUtilityButtons(for: .insights)
                    ) {
                        AppShellPlaceholderRouteView(
                            title: "History",
                            subtitle: "Batch 40 establishes ownership without activating the later history redesign.",
                            message: "History now belongs to Insights at the shell layer. Deeper recall and reflection remain deferred to later batches."
                        )
                    }
                }
            }
        }
        .tag(AppTab.insights)
        .tabItem {
            Label(AppTab.insights.title, systemImage: AppTab.insights.systemImage)
        }
    }

    private func profileNavigation() -> some View {
        NavigationStack {
            AppShellScaffold(
                title: "Profile",
                subtitle: "Utility",
                posture: .utility,
                trailingButtons: shellUtilityButtons(for: .profile)
            ) {
                ProfileScreen(showsNavigationChrome: false)
            }
        }
        .tag(AppTab.profile)
        .tabItem {
            Label(AppTab.profile.title, systemImage: AppTab.profile.systemImage)
        }
    }

    private func shellUtilityButtons(for tab: AppTab) -> [AppShellHeaderButton] {
        [
            AppShellHeaderButton(
                title: "Memory Lens",
                systemImage: "magnifyingglass",
                accessibilityIdentifier: "shell.\(tab.rawValue).memory-lens-button"
            ) {
                presentMemoryLens(from: .shellUtility)
            }
        ]
    }

    private var shellGlobalEntryButton: some View {
        Button {
            presentCommandSheet(from: .shellCompose)
        } label: {
            Label("Command", systemImage: "plus")
                .labelStyle(.iconOnly)
                .frame(width: 52, height: 52)
        }
        .buttonStyle(AmbitionPressableButtonStyle(state: .selected))
        .padding(.trailing, 20)
        .padding(.bottom, 88)
        .accessibilityElement()
        .accessibilityLabel("Command")
        .accessibilityHint("Opens the shell-owned command surface.")
        .accessibilityIdentifier("shell.global-entry-button")
        .keyboardShortcut("k", modifiers: [.command])
    }

    private func handleCreatedGoal(_ response: CreateGoalResponse, from overlay: ShellOverlayState) async {
        var body: String = {
            switch response.resultKind {
            case .planned:
                return "\(response.blueprint.title) is now in the portfolio with a canonical plan."
            case .starterPlanned:
                return "\(response.blueprint.title) is now in the portfolio with a starter plan."
            case .clarificationRequired:
                return "\(response.blueprint.title) needs one clarification before Ambitions treats it as a live goal."
            case .blocked:
                return "\(response.blueprint.title) was saved as a blocked draft with the missing constraint visible."
            }
        }()

        if let captureID = overlay.captureID, let goalID = response.target.goalID {
            do {
                let binding = try await attachCaptureToCreatedGoal(captureID: captureID, goalID: goalID)
                if binding != nil {
                    body += " The capture stayed connected to this goal."
                }
            } catch {
                body += " The goal was created, but the capture could not be attached yet."
            }
        }

        creationMessage = GoalDetailInlineMessage(
            title: "Goal created",
            body: body,
            state: .success
        )
        goalsRefreshID += 1
        navigation.dismissOverlay()
        switch response.resultKind {
        case .planned, .starterPlanned:
            navigation.selectTab(.goals)
        case .clarificationRequired, .blocked:
            navigation.openGoalDetail(response.target)
        }
    }

    private func presentCreateGoal(
        from source: ShellCommandEntrySource,
        seedText: String = "",
        captureID: String? = nil
    ) {
        creationMessage = nil
        container.commandRouter.presentCreateGoal(source: source, seedText: seedText, captureID: captureID)
    }

    private func attachCaptureToCreatedGoal(captureID: String, goalID: String) async throws -> CaptureGoalBinding? {
        do {
            return try await container.captureService.attachCaptureToGoal(
                AttachCaptureToGoalRequest(captureID: captureID, goalID: goalID),
                now: .now
            )
        } catch let error as CaptureServiceError {
            guard case let .invalidTransition(from, to) = error,
                  from == .seed,
                  to == .goalBound else {
                throw error
            }

            _ = try await container.captureService.updateCaptureState(
                CaptureStateUpdateRequest(id: captureID, status: .actionable),
                now: .now
            )
            return try await container.captureService.attachCaptureToGoal(
                AttachCaptureToGoalRequest(captureID: captureID, goalID: goalID),
                now: .now
            )
        }
    }

    private func presentMemoryLens(from source: ShellCommandEntrySource) {
        container.commandRouter.presentMemoryLens(
            intent: .memoryLens,
            source: source,
            presentationContext: .recall,
            query: "",
            goalID: nil,
            captureID: nil
        )
    }

    private func presentCommandSheet(from source: ShellCommandEntrySource) {
        container.commandRouter.presentCommandSheet(
            intent: nil,
            source: source,
            presentationContext: .neutral
        )
    }
}
