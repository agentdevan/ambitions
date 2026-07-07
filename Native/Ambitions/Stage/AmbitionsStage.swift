import AmbitionsDesignSystem
import SwiftUI

struct AmbitionsStage: View {
    @Environment(\.colorScheme) private var systemColorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    private let container: AppContainer
    private let appFeatureFlags: AppFeatureFlags
    @State private var navigation: StageStore
    @State private var stageOwner = StageOwner()
    @State private var creationMessage: GoalDetailInlineMessage?
    @State private var goalsRefreshID = 0
    @State private var isOnboardingPresented: Bool
    @State private var onboardingError: String?
    @State private var motionCurrentActionObserver: NSObjectProtocol?

    init(container: AppContainer, appFeatureFlags: AppFeatureFlags = .current) {
        self.container = container
        self.appFeatureFlags = appFeatureFlags
        _navigation = State(initialValue: container.navigation)
        _isOnboardingPresented = State(initialValue: container.session.shouldShowOnboarding)
    }

    var body: some View {
        let resolvedTheme = container.appearancePreference.resolveTheme(
            systemColorScheme: systemColorScheme,
            accentFamily: container.accentFamily
        )
        let stageModel = navigation.stageModel(
            dynamicTypeIsAccessibilitySize: dynamicTypeSize.isAccessibilitySize
        )
        let chromePolicy = stageModel.chromePolicy

        ZStack(alignment: .bottom) {
            stageSurfaceHost
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            if chromePolicy.showsRootDock {
                shellRootDockLayer(theme: resolvedTheme, policy: chromePolicy)
            }
            shellSearchSeam(theme: resolvedTheme)
            shellActivatedCaptureComposerSeam(theme: resolvedTheme, policy: chromePolicy)
            shellContinuityReceipt(theme: resolvedTheme, policy: chromePolicy)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(resolvedTheme.shell.canvasGradient.ignoresSafeArea())
        .onAppear {
            validateExternalNavigationGraph()
            configureStageMotionBehavior()
            registerMotionCurrentActionObserver()
        }
        .onDisappear {
            unregisterMotionCurrentActionObserver()
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
    private var stageSurfaceHost: some View {
        AmbitionsRootStageSurfaceHost(
            navigation: $navigation,
            creationMessage: creationMessage,
            goalsRefreshID: goalsRefreshID,
            onCreateGoal: { source, seedText, captureID in
                presentCreateGoal(from: source, seedText: seedText, captureID: captureID)
            },
            onToolbarAction: { action, tab in
                handleContextualToolbarAction(action, for: tab)
            }
        )
    }

    private var activeSheetOverlayBinding: Binding<ShellOverlayState?> {
        Binding(
            get: {
                guard navigation.activeOverlay?.isActivatedCaptureComposer != true,
                      navigation.activeOverlay?.kind != .memoryLens else {
                    return nil
                }
                return navigation.activeOverlay
            },
            set: { newValue in
                if newValue == nil,
                   navigation.activeOverlay?.isActivatedCaptureComposer == true
                    || navigation.activeOverlay?.kind == .memoryLens {
                    return
                }
                navigation.activeOverlay = newValue
            }
        )
    }

    @ViewBuilder
    private func shellSearchSeam(theme: AmbitionTheme) -> some View {
        if let overlay = navigation.activeOverlay, overlay.kind == .memoryLens {
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
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(theme.colors.canvas.ignoresSafeArea())
            .transition(.opacity)
            .zIndex(3)
        }
    }

    private func handleContextualToolbarAction(_ action: AppShellContextualToolbarAction, for tab: AmbitionsSurface) {
        switch action.id {
        case "today-start-here":
            navigation.selectToday(entryContext: .standard)
        case "goals-create-goal":
            navigation.presentTypedCaptureComposer(kind: .goalSeed, source: .goalsCreate)
        case "time-weekly-review":
            navigation.openWeeklyReview()
        case "you-history", "motion-memory-lens":
            navigation.presentMemoryLens(source: .shellUtility)
        default:
            presentSurfaceCapture(for: tab)
        }
    }

    @ViewBuilder
    private func shellActivatedCaptureComposerSeam(theme: AmbitionTheme, policy: StageChromePolicy) -> some View {
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
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .transition(.opacity)
            .zIndex(2)
        }
    }

    private func shellVisibleDock(theme: AmbitionTheme) -> some View {
        StageDockRail(
            theme: theme,
            selectedTab: navigation.selectedTab
        ) { tab in
            navigation.selectRootSurfaceFromDock(tab)
        }
        .padding(.horizontal, dynamicTypeSize.isAccessibilitySize ? theme.spacing.xxs : theme.spacing.md)
        .padding(.bottom, dynamicTypeSize.isAccessibilitySize ? theme.spacing.lg : theme.spacing.xxl)
    }

    private func shellRootDockLayer(theme: AmbitionTheme, policy: StageChromePolicy) -> some View {
        shellVisibleDock(theme: theme)
            .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private func shellContinuityReceipt(theme: AmbitionTheme, policy: StageChromePolicy) -> some View {
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
            .padding(.bottom, policy.continuityReceiptBottomClearance + theme.spacing.lg)
            .accessibilityIdentifier("shell.continuity-receipt")
            .zIndex(4)
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

    private func presentCommandSheet(from source: ShellCommandEntrySource) {
        container.commandRouter.presentCommandSheet(
            intent: nil,
            source: source,
            presentationContext: .neutral
        )
    }

    private func presentSurfaceCapture(for tab: AmbitionsSurface) {
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
        assert(appFeatureFlags.validationIssues.isEmpty, "App feature flags violate final-canon architecture.")
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
            Task { @MainActor in
                routeStageMotionAction(action, source: source)
            }
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

}
