import AmbitionsDesignSystem
import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct AmbitionsRootView: View {
    @Environment(\.colorScheme) private var systemColorScheme
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    private let container: AppContainer
    @State private var navigation: AppNavigationModel
    @State private var creationMessage: GoalDetailInlineMessage?
    @State private var goalsRefreshID = 0
    @State private var isOnboardingPresented: Bool
    @State private var onboardingError: String?

    init(container: AppContainer) {
        self.container = container
        _navigation = State(initialValue: container.navigation)
        _isOnboardingPresented = State(initialValue: container.session.shouldShowOnboarding)
    }

    var body: some View {
        let resolvedTheme = container.appearancePreference.resolveTheme(
            systemColorScheme: systemColorScheme,
            accentFamily: container.accentFamily
        )

        ZStack(alignment: .bottomTrailing) {
            TabView(selection: $navigation.selectedTab) {
                todayNavigation()
                goalsNavigation()
                captureNavigation()
                planNavigation()
                profileNavigation()
            }
            .tint(resolvedTheme.shell.activeTabForeground)
            .toolbarBackground(resolvedTheme.shell.bottomBarMaterial, for: .tabBar)
            .toolbarBackground(.visible, for: .tabBar)
            .toolbarColorScheme(resolvedTheme.mode == .dark ? .dark : .light, for: .tabBar)
            #if canImport(UIKit)
            .background(
                ShellTabReselectionObserver { _ in
                    navigation.handleCurrentTabReselection()
                }
                .frame(width: 0, height: 0)
                .accessibilityHidden(true)
            )
            #endif

            shellContinuityReceipt(theme: resolvedTheme)
        }
        .overlay(alignment: .bottom) {
            shellFloatingControlLane(theme: resolvedTheme)
                .padding(.bottom, resolvedTheme.spacing.xxxl + resolvedTheme.spacing.xl)
        }
        .background(resolvedTheme.shell.canvasGradient.ignoresSafeArea())
        .onAppear {
            configureTabBarAppearance(with: resolvedTheme)
        }
        .onChange(of: systemColorScheme) { _, _ in
            configureTabBarAppearance(with: resolvedTheme)
        }
        .onChange(of: container.accentFamily) { _, _ in
            configureTabBarAppearance(with: resolvedTheme)
        }
        .onChange(of: container.appearancePreference) { _, _ in
            configureTabBarAppearance(with: resolvedTheme)
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
        .fullScreenCover(isPresented: $isOnboardingPresented) {
            ProgressiveIntelligenceOnboardingView { choice in
                Task {
                    await completeOnboarding(choice: choice)
                }
            }
            .interactiveDismissDisabled()
            .appContainer(container)
            .preferredColorScheme(container.appearancePreference.preferredColorScheme)
            .ambitionTheme(
                container.appearancePreference.resolveTheme(
                    systemColorScheme: systemColorScheme,
                    accentFamily: container.accentFamily
                )
            )
        }
        .appContainer(container)
        .preferredColorScheme(container.appearancePreference.preferredColorScheme)
        .ambitionTheme(resolvedTheme)
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
                trailingButtons: shellUtilityButtons(for: .plan)
            ) {
                PlanScreen(showsNavigationChrome: false)
            }
            .navigationDestination(for: PlanRouteTarget.self) { target in
                switch target {
                case .capturesInbox:
                    AppShellScaffold(
                        title: "Capture",
                        subtitle: "Plan support route",
                        posture: .shaping,
                        backButtonAccessibilityIdentifier: "shell.plan.back-button",
                        onBack: { navigation.resetPlanPath() },
                        trailingButtons: shellUtilityButtons(for: .plan)
                    ) {
                        CapturesScreen()
                    }
                case .habits:
                    AppShellScaffold(
                        title: "Rituals",
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

    private func captureNavigation() -> some View {
        NavigationStack {
            AppShellScaffold(
                title: "Capture",
                subtitle: "Intake",
                posture: .shaping,
                trailingButtons: shellUtilityButtons(for: .captures)
            ) {
                CapturesScreen(shellMode: .topLevelCapture)
            }
        }
        .tag(AppTab.captures)
        .tabItem {
            Label(AppTab.captures.title, systemImage: AppTab.captures.systemImage)
        }
    }

    private func profileNavigation() -> some View {
        NavigationStack(path: $navigation.insightsPath) {
            AppShellScaffold(
                title: "You",
                subtitle: "Control",
                posture: .utility,
                trailingButtons: shellUtilityButtons(for: .profile)
            ) {
                ProfileScreen(showsNavigationChrome: false)
            }
            .navigationDestination(for: InsightsRouteTarget.self) { target in
                switch target {
                case .monthlyReview:
                    AppShellScaffold(
                        title: "Monthly Review",
                        subtitle: "Reflection",
                        posture: .reflection,
                        backButtonAccessibilityIdentifier: "shell.you.back-button",
                        onBack: { navigation.resetInsightsPath() },
                        trailingButtons: shellUtilityButtons(for: .profile)
                    ) {
                        InsightsMonthlyReviewScreen()
                    }
                case .history:
                    AppShellScaffold(
                        title: "History",
                        subtitle: "Reflection",
                        posture: .reflection,
                        backButtonAccessibilityIdentifier: "shell.you.back-button",
                        onBack: { navigation.resetInsightsPath() },
                        trailingButtons: shellUtilityButtons(for: .profile)
                    ) {
                        InsightsHistoryScreen()
                    }
                }
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
                title: "What Ambitions knows",
                systemImage: "magnifyingglass",
                accessibilityIdentifier: "shell.\(tab.rawValue).memory-lens-button"
            ) {
                presentMemoryLens(from: .shellUtility)
            }
        ]
    }

    private func shellGlobalEntryButton(theme: AmbitionTheme) -> some View {
        Button {
            presentCommandSheet(from: .shellCompose)
        } label: {
            Label("Add something", systemImage: "plus")
                .labelStyle(.iconOnly)
                .frame(width: 52, height: 52)
        }
        .buttonStyle(AmbitionPressableButtonStyle(state: .selected))
        .accessibilityElement()
        .accessibilityLabel("Add something")
        .accessibilityHint("Opens the global quick action surface.")
        .accessibilityIdentifier("shell.global-entry-button")
        .keyboardShortcut("k", modifiers: [.command])
    }

    @ViewBuilder
    private func shellFloatingControlLane(theme: AmbitionTheme) -> some View {
        HStack {
            Spacer()
            shellGlobalEntryButton(theme: theme)
        }
        .padding(.horizontal, theme.spacing.md)
        .padding(.top, theme.spacing.xs)
        .padding(.bottom, theme.spacing.sm)
        .background(
            LinearGradient(
                colors: [
                    theme.colors.canvas.opacity(0.0),
                    theme.colors.canvasElevated.opacity(theme.mode == .dark ? 0.94 : 0.98)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .allowsHitTesting(false)
        )
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Global action lane")
        .accessibilityIdentifier("shell.floating-control-lane")
    }

    @ViewBuilder
    private func shellContinuityReceipt(theme: AmbitionTheme) -> some View {
        if let receipt = navigation.continuityReceipt {
            AmbitionActionClosureTray(
                title: receipt.title,
                message: receipt.body,
                status: .steady
            ) {
                navigation.continuityReceipt = nil
            }
            .frame(maxWidth: dynamicTypeSize.isAccessibilitySize ? 360 : 310, alignment: .leading)
            .padding(.trailing, 20)
            .padding(.bottom, theme.spacing.xxxl + theme.spacing.xxl)
            .accessibilityIdentifier("shell.continuity-receipt")
        }
    }

    private func handleCreatedGoal(_ response: CreateGoalResponse, from overlay: ShellOverlayState) async {
        var body: String = {
            switch response.resultKind {
            case .planned:
                return "\(response.blueprint.title) is now in Goals with a plan."
            case .starterPlanned:
                return "\(response.blueprint.title) is now in Goals with a starter plan."
            case .clarificationRequired:
                return "\(response.blueprint.title) needs one clarification before it becomes a live goal."
            case .blocked:
                return "\(response.blueprint.title) was saved as a blocked draft with the missing piece visible."
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

    private func completeOnboarding(choice: OnboardingEntryChoice) async {
        do {
            let decision = try await container.onboardingService.complete(choice: choice, now: .now)
            onboardingError = nil
            isOnboardingPresented = false
            navigation.selectTab(decision.selectedTab)
            switch decision.choice {
            case .createFirstGoal:
                presentCreateGoal(from: decision.overlaySource ?? .shellCompose)
            case .captureFirst:
                container.commandRouter.presentCommandSheet(
                    intent: decision.overlayIntent,
                    source: decision.overlaySource ?? .shellCompose,
                    presentationContext: decision.presentationContext
                )
            case .enterToday:
                navigation.selectToday(entryContext: .standard)
            }
        } catch {
            onboardingError = "Unable to finish onboarding: \(error.localizedDescription)"
        }
    }

    private func configureTabBarAppearance(with theme: AmbitionTheme) {
        #if canImport(UIKit)
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(theme.colors.canvasElevated)
        appearance.shadowColor = UIColor(theme.shell.divider)

        let selectedColor = UIColor(theme.shell.activeTabForeground)
        let inactiveColor = UIColor(theme.shell.inactiveTabForeground)

        [appearance.stackedLayoutAppearance, appearance.inlineLayoutAppearance, appearance.compactInlineLayoutAppearance].forEach { itemAppearance in
            itemAppearance.selected.iconColor = selectedColor
            itemAppearance.selected.titleTextAttributes = [.foregroundColor: selectedColor]
            itemAppearance.normal.iconColor = inactiveColor
            itemAppearance.normal.titleTextAttributes = [.foregroundColor: inactiveColor]
        }

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        UITabBar.appearance().tintColor = selectedColor
        UITabBar.appearance().unselectedItemTintColor = inactiveColor
        #endif
    }
}
