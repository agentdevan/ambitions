import AmbitionsDesignSystem
import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct AmbitionsRootView: View {
    @Environment(\.colorScheme) private var systemColorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    private let container: AppContainer
    private let shellPresentationMode: AppShellPresentationMode
    @State private var navigation: AppNavigationModel
    @State private var stageOwner = StageOwner()
    @State private var creationMessage: GoalDetailInlineMessage?
    @State private var goalsRefreshID = 0
    @State private var isOnboardingPresented: Bool
    @State private var onboardingError: String?
    @State private var motionCurrentActionObserver: NSObjectProtocol?

    init(
        container: AppContainer,
        shellPresentationMode: AppShellPresentationMode = .resolved()
    ) {
        self.container = container
        self.shellPresentationMode = shellPresentationMode
        _navigation = State(initialValue: container.navigation)
        _isOnboardingPresented = State(initialValue: container.session.shouldShowOnboarding)
    }

    var body: some View {
        let resolvedTheme = container.appearancePreference.resolveTheme(
            systemColorScheme: systemColorScheme,
            accentFamily: container.accentFamily
        )

        ZStack(alignment: .bottom) {
            shellTabView(theme: resolvedTheme)
            if navigation.hasRootNavigationChrome {
                shellDockBackdrop(theme: resolvedTheme)
                    .zIndex(2)
                shellVisibleDock(theme: resolvedTheme)
                    .zIndex(3)
            }
            shellActivatedCaptureComposerSeam(theme: resolvedTheme)
            shellContinuityReceipt(theme: resolvedTheme)
        }
        .background(resolvedTheme.shell.canvasGradient.ignoresSafeArea())
        .onAppear {
            configureTabBarAppearance(with: resolvedTheme)
            validateExternalNavigationGraph()
            configureStageMotionBehavior()
            registerMotionCurrentActionObserver()
        }
        .onDisappear {
            unregisterMotionCurrentActionObserver()
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
        .onChange(of: reduceMotion) { _, isReduced in
            stageOwner.setReduceMotionEnabled(isReduced)
        }
        .sheet(item: activeSheetOverlayBinding, onDismiss: {
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

    @ViewBuilder
    private func shellTabView(theme: AmbitionTheme) -> some View {
        TabView(selection: $navigation.selectedTab) {
            Tab(AppTab.today.title, systemImage: AppTab.today.systemImage, value: AppTab.today) {
                todayNavigation()
            }

            Tab(AppTab.goals.title, systemImage: AppTab.goals.systemImage, value: AppTab.goals) {
                goalsNavigation()
            }

            Tab(AppTab.time.title, systemImage: AppTab.time.systemImage, value: AppTab.time) {
                timeNavigation()
            }

            Tab(AppTab.you.title, systemImage: AppTab.you.systemImage, value: AppTab.you) {
                youNavigation()
            }
        }
        .tint(theme.shell.activeTabForeground)
        .toolbar(.hidden, for: .tabBar)
        #if canImport(UIKit)
        .background(
            ShellTabReselectionObserver { _ in
                navigation.handleCurrentTabReselection()
            }
            .frame(width: 0, height: 0)
            .accessibilityHidden(true)
        )
        #endif
    }

    private var activeSheetOverlayBinding: Binding<ShellOverlayState?> {
        Binding(
            get: {
                guard navigation.activeOverlay?.isActivatedCaptureComposer != true else {
                    return nil
                }
                return navigation.activeOverlay
            },
            set: { newValue in
                navigation.activeOverlay = newValue
            }
        )
    }

    private func todayNavigation() -> some View {
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

    private func goalsNavigation() -> some View {
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
                        presentCreateGoal(from: .goalsCreate)
                    }
                )
            }
            .navigationDestination(for: GoalRouteTarget.self) { target in
                GoalDetailScreen(target: target)
            }
        }
    }

    private func timeNavigation() -> some View {
        NavigationStack(path: $navigation.timePath) {
            AppShellScaffold(
                title: "Time",
                subtitle: "LifeShape Field",
                posture: .shaping,
                trailingButtons: shellUtilityButtons(for: .time)
            ) {
                TimeScreen(showsNavigationChrome: false)
            }
            .navigationDestination(for: TimeRouteTarget.self) { target in
                switch target {
                case .captureInbox:
                    AppShellScaffold(
                        title: "Capture",
                        subtitle: "Composer",
                        posture: .shaping,
                        backButtonAccessibilityIdentifier: "shell.time.back-button",
                        onBack: { navigation.resetTimePath() },
                        trailingButtons: []
                    ) {
                        CaptureScreen()
                    }
                case .habits:
                    AppShellScaffold(
                        title: "Rituals",
                        subtitle: "LifeShape Field",
                        posture: .shaping,
                        backButtonAccessibilityIdentifier: "shell.time.back-button",
                        onBack: { navigation.resetTimePath() },
                        trailingButtons: []
                    ) {
                        HabitsScreen()
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

    private func youNavigation() -> some View {
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
                        InsightsMonthlyReviewScreen()
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
                        InsightsHistoryScreen()
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
                handleContextualToolbarAction(action, for: tab)
            }
        }
    }

    private func handleContextualToolbarAction(_ action: AppShellContextualToolbarAction, for tab: AppTab) {
        switch action.id {
        case "today-start-here":
            navigation.selectToday(entryContext: .standard)
        case "goals-create-goal":
            presentCreateGoal(from: .goalsCreate)
        case "time-weekly-review":
            navigation.openWeeklyReview()
        case "you-history", "motion-memory-lens":
            navigation.presentMemoryLens(source: .shellUtility)
        default:
            presentSurfaceCapture(for: tab)
        }
    }

    @ViewBuilder
    private func shellActivatedCaptureComposerSeam(theme: AmbitionTheme) -> some View {
        if let overlay = navigation.activeOverlay, overlay.isActivatedCaptureComposer {
            AppShellActivatedCaptureSeam(
                overlay: overlay,
                onDismiss: {
                    navigation.dismissOverlay()
                },
                onCreateGoal: { seedText, captureID in
                    presentCreateGoal(from: overlay.entrySource, seedText: seedText, captureID: captureID)
                }
            )
            .padding(.horizontal, dynamicTypeSize.isAccessibilitySize ? theme.spacing.sm : theme.spacing.lg)
            .offset(y: -shellCaptureComposerClearance(theme: theme))
            .transition(.opacity)
            .zIndex(2)
        }
    }

    private func shellVisibleDock(theme: AmbitionTheme) -> some View {
        AppMeridianDestinationRail(
            theme: theme,
            selectedTab: navigation.selectedTab
        ) { tab in
            navigation.selectTab(tab)
        }
        .padding(.horizontal, dynamicTypeSize.isAccessibilitySize ? theme.spacing.xxs : theme.spacing.md)
        .padding(.bottom, dynamicTypeSize.isAccessibilitySize ? theme.spacing.xxs : theme.spacing.sm)
    }

    private func shellDockBackdrop(theme: AmbitionTheme) -> some View {
        LinearGradient(
            colors: [
                theme.colors.canvas.opacity(0.0),
                theme.colors.canvas.opacity(theme.mode == .dark ? 0.24 : 0.18),
                theme.colors.canvas.opacity(theme.mode == .dark ? 0.44 : 0.36)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .frame(height: shellDockClearance(theme: theme) + (dynamicTypeSize.isAccessibilitySize ? 48 : 72))
        .frame(maxWidth: .infinity)
        .ignoresSafeArea(edges: .bottom)
        .accessibilityHidden(true)
    }

    @ViewBuilder
    private func shellContinuityReceipt(theme: AmbitionTheme) -> some View {
        // Display-only shell receipt chrome; SourceRecord and ReplayTrace wiring stay in runtime/proof owners.
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
            .padding(.bottom, shellDockClearance(theme: theme) + theme.spacing.lg)
            .accessibilityIdentifier("shell.continuity-receipt")
            .zIndex(4)
        }
    }

    private func shellDockClearance(theme: AmbitionTheme) -> CGFloat {
        dynamicTypeSize.isAccessibilitySize ? 184 : 164
    }

    private func shellCaptureComposerClearance(theme: AmbitionTheme) -> CGFloat {
        navigation.hasRootNavigationChrome ? shellDockClearance(theme: theme) : (dynamicTypeSize.isAccessibilitySize ? 36 : 18)
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

    private func presentCommandSheet(from source: ShellCommandEntrySource) {
        container.commandRouter.presentCommandSheet(
            intent: nil,
            source: source,
            presentationContext: .neutral
        )
    }

    private func presentSurfaceCapture(for tab: AppTab) {
        container.commandRouter.presentCommandSheet(
            intent: .quickCapture,
            source: AppShellCaptureAccessModel.source(for: tab),
            presentationContext: .quickCapture
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

    private func validateExternalNavigationGraph() {
        assert(AppDeepLinkRegistry.validationIssues().isEmpty, "Deep-link registry contains unsupported routes.")
        assert(AppNavigationGraph.nodes.allSatisfy(\.canOpenFromExternalSurface), "Navigation graph contains a dead-end external route.")
    }

    private func configureStageMotionBehavior() {
        stageOwner.setReduceMotionEnabled(reduceMotion)
    }

    private func registerMotionCurrentActionObserver() {
        motionCurrentActionObserver = NotificationCenter.default.addObserver(
            forName: MotionCurrentAction.notificationName,
            object: nil,
            queue: .main
        ) { notification in
            guard let action = notification.ambitionsMotionCurrentAction else { return }
            let source = notification.userInfo?[MotionCurrentAction.notificationSourceKey] as? String ?? "motion.current"
            routeStageMotionAction(action, source: source)
        }
    }

    private func unregisterMotionCurrentActionObserver() {
        guard let motionCurrentActionObserver else { return }
        NotificationCenter.default.removeObserver(motionCurrentActionObserver)
        self.motionCurrentActionObserver = nil
    }

    private func routeStageMotionAction(_ action: MotionCurrentAction, source: String) {
        let route = stageOwner.route(for: action, source: source)
        switch route {
        case let .returnToToday(entryContext):
            navigation.selectToday(entryContext: entryContext)
        case .openGoals:
            navigation.selectTab(.goals)
        case .openTime:
            navigation.selectTab(.time)
        case .openTrust:
            navigation.openHistory()
        case let .presentOverlay(overlay):
            if overlay.kind == .memoryLens {
                navigation.presentMemoryLens(
                    intent: overlay.intent,
                    source: overlay.entrySource,
                    presentationContext: overlay.presentationContext,
                    query: overlay.query,
                    goalID: overlay.goalID,
                    captureID: overlay.captureID
                )
            } else {
                navigation.activeOverlay = overlay
            }
        case .none:
            break
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
