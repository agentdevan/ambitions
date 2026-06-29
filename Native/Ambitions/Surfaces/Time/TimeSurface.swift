import AmbitionsDesignSystem
import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct TimeSurface: View {
    @Environment(\.appShellCapability) private var appShellCapability
    @Environment(\.appFeatureFactoryCapability) private var appFeatureFactoryCapability
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @State private var viewModel: TimeViewModel
    private let showsNavigationChrome: Bool

    @MainActor
    init(viewModel: TimeViewModel? = nil, showsNavigationChrome: Bool = true) {
        _viewModel = State(initialValue: viewModel ?? TimeViewModel())
        self.showsNavigationChrome = showsNavigationChrome
    }

    var body: some View {
        ZStack {
            LivingSurfaceBackground(context: .time, state: timeLivingState, intensity: 0.64)
                .stageOwnedIgnoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: theme.spacing.lg) {
                    switch viewModel.state {
                    case .loading:
                        DegradedStateSurface(state: DegradedStateOrchestrator.objectLoading(.lifeShapeContourMap))
                            .transition(.ambitionPanel)
                    case .failed:
                        DegradedStateSurface(
                            state: DegradedStateOrchestrator.objectUnavailable(.lifeShapeContourMap),
                            primaryAccessibilityIdentifier: "time.retry-button",
                            onPrimaryAction: {
                                Task { await refresh() }
                            }
                        )
                        .transition(.ambitionPanel)
                    case let .loaded(timeState):
                        TimeObjectView(
                            timeState: timeState,
                            clock: clock,
                            onReflowDecision: handleReflowDecision,
                            onSearch: presentTimeSearch,
                            onCapture: presentTimeCapture,
                            visibleMutation: viewModel.visibleTimeMutation,
                            onMutationAction: performLifeShapeMutation,
                            onUndoMutation: undoLifeShapeMutation
                        )
                        protectedPlacementReviewSection

                    }
                }
                .padding(.horizontal, theme.spacing.lg)
                .padding(.vertical, theme.spacing.md)
            }
            .accessibilityIdentifier("time.content-scroll")
            .scrollIndicators(.hidden)
            .stageOwnedSafeAreaInset(edge: .bottom, spacing: 0) {
                Color.clear
                    .frame(height: dynamicTypeSize.isAccessibilitySize ? 172 : theme.spacing.xxxl)
                    .allowsHitTesting(false)
                    .accessibilityHidden(true)
            }
        }
        .navigationTitle(showsNavigationChrome ? "Time" : "")
        .toolbar {
            if showsNavigationChrome {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        shell.navigation.openRituals()
                    } label: {
                        Label("Rituals", systemImage: "repeat")
                    }
                    .accessibilityIdentifier("time.open-time-rituals-button")
                }
            }
        }
        .refreshable {
            await refresh()
        }
        .accessibilityIdentifier("time.screen")
        .animation(theme.motion.animation(reduceMotion: reduceMotion, emphasis: true), value: viewModel.stateKey)
        .onChange(of: viewModel.visibleTimeMutation?.stageMutation.accessibilityAnnouncement.message) { _, message in
            announceMutation(message)
        }
        .onChange(of: viewModel.protectedPlacementReviewOutcome?.rawValue) { _, message in
            announceMutation(message)
        }
        .task {
            await viewModel.load(using: featureFactory.timeService, now: clock.now, calendar: clock.calendar, timeZone: clock.timeZone)
        }
        .task {
            guard clock.advancesAutomatically else { return }
            await observeClockBoundary()
        }
    }

    private var shell: AppShellCapability {
        guard let appShellCapability else {
            preconditionFailure("App shell capability must be injected.")
        }
        return appShellCapability
    }

    private var featureFactory: AppFeatureFactoryCapability {
        guard let appFeatureFactoryCapability else {
            preconditionFailure("App feature factory capability must be injected.")
        }
        return appFeatureFactoryCapability
    }

    private var clock: any AmbitionsClock {
        featureFactory.clock
    }

    private var timeLivingState: LivingVisualState {
        guard case let .loaded(timeState) = viewModel.state else {
            return .calm
        }

        let label = timeState.capacityEnvelope.label.lowercased()
        if label.contains("overloaded") || label.contains("tight") {
            return .pressured
        }
        if timeState.calendarAwareness.status == .denied {
            return .recovery
        }
        return .active
    }

    private func handleReflowDecision(
        _ option: TimeReflowDecisionOptionState,
        action: TimeReflowDecisionActionKind
    ) {
        guard action != .decline else { return }
        if let target = option.target {
            openGoal(target)
            return
        }
        if let route = option.timeRoute {
            shell.navigation.openTimeRoute(route)
            return
        }
        if let interactionIntent = option.interactionIntent {
            handleInteractionIntent(interactionIntent)
        }
    }

    private func handleInteractionIntent(_ intent: TimeInteractionIntent) {
        switch intent {
        case .openGlobalCapture:
            presentTimeCapture()
        case .chooseDay, .chooseWeek, .chooseMonth, .chooseYear, .reviewPressure, .protectWindow:
            break
        }
    }

    private func performLifeShapeMutation(_ action: TimeFieldMutationAction, selectedMark: LifeShapeSemanticMark?) {
        viewModel.performLifeShapeMutation(action, selectedMark: selectedMark, now: clock.now)
    }

    private func undoLifeShapeMutation() {
        viewModel.undoLastLifeShapeMutation(now: clock.now)
    }

    @ViewBuilder
    private var protectedPlacementReviewSection: some View {
        if let review = viewModel.protectedPlacementReview {
            ProtectedPlacementReviewCard(
                review: review,
                onPriorityChange: updateProtectedPlacementPriority,
                onApprove: approveProtectedPlacementReview,
                onKeep: keepProtectedPlacementReview
            )
        } else if let outcome = viewModel.protectedPlacementReviewOutcome {
            Text(outcome.rawValue)
                .font(theme.typography.bodyEmphasized)
                .foregroundStyle(theme.colors.textPrimary)
                .padding(theme.spacing.sm)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background {
                    RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                        .fill(theme.colors.surfaceOverlay.opacity(0.72))
                }
                .accessibilityIdentifier("protected-placement-review.outcome")
        }
    }

    private func approveProtectedPlacementReview() {
        viewModel.approveProtectedPlacementReview(now: clock.now)
    }

    private func updateProtectedPlacementPriority(_ priority: PlacementPriority) {
        viewModel.updateProtectedPlacementPriority(priority)
    }

    private func keepProtectedPlacementReview() {
        viewModel.keepProtectedPlacementReview()
    }

    private func announceMutation(_ message: String?) {
        guard let message, message.isEmpty == false else { return }
        #if canImport(UIKit)
        UIAccessibility.post(notification: .announcement, argument: message)
        #endif
    }

    private func openGoal(_ target: GoalRouteTarget) {
        shell.navigation.openGoalDetail(target)
    }

    private func refresh() async {
        await viewModel.refresh(using: featureFactory.timeService, now: clock.now, calendar: clock.calendar, timeZone: clock.timeZone)
    }

    private func observeClockBoundary() async {
        while Task.isCancelled == false {
            do {
                try await Task.sleep(for: .seconds(60))
            } catch {
                return
            }
            await refreshIfClockChanged()
        }
    }

    private func refreshIfClockChanged() async {
        let now = clock.now
        guard viewModel.shouldRefreshForClockChange(now: now, calendar: clock.calendar, timeZone: clock.timeZone) else { return }
        await refresh()
    }

    private func presentTimeCapture() {
        shell.commandRouter.presentCommandSheet(
            intent: .quickCapture,
            source: .timeQuickCapture,
            presentationContext: .quickCapture
        )
    }

    private func presentTimeSearch() {
        shell.commandRouter.presentMemoryLens(
            intent: .memoryLens,
            source: .shellUtility,
            presentationContext: .recall,
            query: "",
            goalID: nil,
            captureID: nil
        )
    }
}

#if DEBUG
#Preview("Time Seeded") {
    NavigationStack {
        TimeSurface(viewModel: TimeViewModel(state: .loaded(PreviewTimeScenarios.seeded)))
    }
    .appContainer(PreviewAppContainerFactory.preview)
    .ambitionTheme(.dark)
}

#Preview("Time Empty") {
    NavigationStack {
        TimeSurface(viewModel: TimeViewModel(state: .loaded(PreviewTimeScenarios.empty)))
    }
    .appContainer(PreviewAppContainerFactory.preview)
    .ambitionTheme(.dark)
}
#endif
