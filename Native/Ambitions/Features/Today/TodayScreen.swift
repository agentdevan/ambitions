import AmbitionsDesignSystem
import SwiftUI

struct TodayScreen: View {
    @Environment(\.appContainer) private var appContainer
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var viewModel: TodayViewModel
    @State private var selectedStepDetail: DayRailStepDetailState?
    @State private var selectedActionClosure: TodayActionClosureSheetState?

    private let autoLoad: Bool
    private let showsNavigationChrome: Bool

    @MainActor
    init(viewModel: TodayViewModel? = nil, autoLoad: Bool = true, showsNavigationChrome: Bool = true) {
        _viewModel = State(initialValue: viewModel ?? TodayViewModel())
        self.autoLoad = autoLoad
        self.showsNavigationChrome = showsNavigationChrome
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            TodayBackgroundView()

            ScrollView {
                LazyVStack(alignment: .leading, spacing: theme.spacing.lg) {
                    switch viewModel.state {
                    case .loading:
                        DegradedStateCard(state: DegradedStateOrchestrator.objectLoading(.startHere))
                            .transition(.ambitionPanel)
                    case .failed:
                        DegradedStateCard(
                            state: DegradedStateOrchestrator.objectUnavailable(.startHere),
                            primaryAccessibilityIdentifier: "today.retry-button",
                            onPrimaryAction: {
                                Task {
                                    await refresh()
                                }
                            }
                        )
                        .transition(.ambitionPanel)
                    case let .loaded(experience):
                        DayTimelineRail(
                            state: experience.execution.dayRail,
                            onAction: handleAction,
                            onOpenStepDetail: { detail in
                                selectedStepDetail = detail
                            }
                        )
                        .transition(.ambitionPanel)
                        .overlay(alignment: .topLeading) {
                            RealityMeridianCurrentTimeCursor()
                                .frame(maxWidth: .infinity, minHeight: 168, alignment: .topLeading)
                                .padding(.horizontal, theme.spacing.lg)
                                .padding(.top, theme.spacing.lg)
                                .allowsHitTesting(false)
                                .accessibilityIdentifier("TodayRealityMeridianCurrentTimeCursor")
                        }
                        .accessibilityIdentifier("TodayRealityMeridianFusedRail")

                        if experience.mode == .empty {
                            DegradedStateCard(
                                state: DegradedStateOrchestrator.todayEmpty(),
                                primaryAccessibilityIdentifier: "today.empty.create-goal",
                                secondaryAccessibilityIdentifier: "today.empty.capture-first",
                                onPrimaryAction: {
                                    container.commandRouter.presentCreateGoal(source: .shellCompose)
                                },
                                onSecondaryAction: {
                                    container.commandRouter.presentCommandSheet(
                                        intent: .quickCapture,
                                        source: .todayQuickCapture,
                                        presentationContext: .quickCapture
                                    )
                                }
                            )
                            .transition(.ambitionPanel)
                        }

                        if let transientMessage = viewModel.transientMessage {
                            TodayMessageCard(message: transientMessage)
                                .transition(.ambitionPanel)
                        }

                        TodayExecutionSupportPanels(state: experience.execution, onAction: handleAction)
                        TodayExecutionDeepDive(state: experience.execution, onAction: handleAction)
                    }
                }
                .padding(.horizontal, theme.spacing.lg)
                .padding(.top, theme.spacing.xl)
                .padding(.bottom, theme.spacing.md)
            }
            .scrollIndicators(.hidden)
            .accessibilityIdentifier("today.screen")
            .refreshable {
                await refresh()
            }

            LocalAmbitionsLockup()
                .padding(.top, theme.spacing.md)
                .padding(.trailing, theme.spacing.lg)
                .accessibilitySortPriority(2)
        }
        .navigationTitle(showsNavigationChrome ? "Today" : "")
        .toolbar {
            if showsNavigationChrome {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        container.commandRouter.route(to: .planRoute(.captureInbox), source: .shellUtility)
                    } label: {
                        Label("Capture", systemImage: AppTab.captures.systemImage)
                    }
                    .accessibilityIdentifier("today.open-captures-button")
                }
            }
        }
        .animation(theme.motion.animation(reduceMotion: reduceMotion, emphasis: true), value: viewModel.stateKey)
        .animation(theme.motion.animation(reduceMotion: reduceMotion), value: viewModel.transientMessage?.title)
        .sheet(item: $selectedStepDetail) { detail in
            TodayStepDetailSheet(detail: detail) { action in
                selectedStepDetail = nil
                Task { @MainActor in
                    handleAction(action)
                }
            }
                .ambitionTheme(theme)
        }
        .sheet(item: $selectedActionClosure) { closure in
            TodayActionClosureSheet(state: closure) { outcome in
                let peek = closure.proofReceiptPeek(for: outcome)
                selectedActionClosure = nil
                viewModel.transientMessage = TodayInlineMessage(
                    title: peek.title,
                    body: "\(peek.subtitle). \(peek.privacyLabel). \(peek.noSilentChangesLabel).",
                    state: outcome.createsProof ? .success : .selected
                )
            }
            .ambitionTheme(theme)
        }
        .onChange(of: container.navigation.selectedTab) { _, selectedTab in
            guard autoLoad, selectedTab == .today else { return }
            Task {
                await activate()
            }
        }
        .onChange(of: container.navigation.todayEntryContext) { _, entryContext in
            guard autoLoad, container.navigation.selectedTab == .today, entryContext != .standard else { return }
            Task {
                await activate()
            }
        }
        .task {
            guard autoLoad else { return }
            await activate()
        }
    }

    private func activate() async {
        await viewModel.activate(
            using: container.todayService,
            userDisplayName: container.session.userDisplayName,
            entryContext: container.navigation.takeTodayEntryContext()
        )
    }

    private func refresh() async {
        await viewModel.refresh(
            using: container.todayService,
            userDisplayName: container.session.userDisplayName,
            entryContext: container.navigation.takeTodayEntryContext()
        )
    }

    private func handleAction(_ action: TodayInlineAction) {
        switch action.kind {
        case .startStepSession:
            container.navigation.selectToday(entryContext: .stepSession)
        case .pauseStepSession:
            viewModel.transientMessage = TodayInlineMessage(
                title: "Session paused",
                body: "This step is still here. Nothing changes until you close the loop.",
                state: .selected
            )
        case .stopStepSession:
            container.navigation.selectToday(entryContext: .standard)
            viewModel.transientMessage = TodayInlineMessage(
                title: "Back to Today",
                body: "Step Session ended without changing proof or plan.",
                state: .selected
            )
        case .closeActionClosure:
            selectedActionClosure = actionClosureState(for: action)
        case .openDetail, .askForHelp:
            container.navigation.openGoalDetail(
                goalID: action.target.goalID,
                draftID: action.target.draftID,
                launchContext: action.kind == .askForHelp ? .help : .standard
            )
        case .quickLog:
            container.commandRouter.presentCommandSheet(
                intent: .quickCapture,
                source: .todayQuickCapture,
                presentationContext: .quickCapture
            )
        case .openPlan:
            container.commandRouter.route(to: .tab(.plan), source: .shellUtility)
        case .protectLater:
            container.commandRouter.route(to: .tab(.plan), source: .shellUtility)
            viewModel.transientMessage = TodayInlineMessage(
                title: "Opened Time",
                body: "Today handed this off to the canonical planning surface instead of creating a second recovery system here.",
                state: .selected
            )
        default:
            Task {
                await viewModel.handle(
                    action,
                    using: container.todayService,
                    userDisplayName: container.session.userDisplayName,
                    entryContext: .standard
                )
            }
        }
    }

    private func actionClosureState(for action: TodayInlineAction) -> TodayActionClosureSheetState {
        let fallback = TodayActionClosureSheetState.step(
            title: "Today step",
            context: "From Today",
            target: action.target
        )
        guard case let .loaded(experience) = viewModel.state else { return fallback }
        let privacy = experience.execution.dayRail.privacyProjection
        if let hero = experience.execution.dayRail.heroStep,
           hero.primaryAction.target == action.target || action.target.stepID == nil {
            return TodayActionClosureSheetState.step(
                title: privacy.detailTitle(hero.title),
                context: experience.execution.dayRail.contextSummary,
                target: action.target,
                privacyLabel: privacy.sourceLabel
            )
        }
        if let row = experience.execution.dayRail.rows.first(where: { $0.detailTarget.stepID == action.target.stepID || $0.detailTarget.goalID == action.target.goalID }) {
            return TodayActionClosureSheetState.step(
                title: privacy.detailTitle(row.title),
                context: row.slot.title,
                target: action.target,
                privacyLabel: privacy.sourceLabel
            )
        }
        return fallback
    }

    private var container: AppContainer {
        guard let appContainer else {
            preconditionFailure("App container must be injected.")
        }
        return appContainer
    }
}

#if DEBUG
#Preview("Today Stable") {
    NavigationStack {
        TodayScreen(viewModel: TodayViewModel(state: .loaded(PreviewTodayScenarios.stable)), autoLoad: false)
    }
    .appContainer(PreviewAppContainerFactory.preview(todayExperience: PreviewTodayScenarios.stable))
    .ambitionTheme(.dark)
}

#Preview("Today Tight") {
    NavigationStack {
        TodayScreen(viewModel: TodayViewModel(state: .loaded(PreviewTodayScenarios.tight)), autoLoad: false)
    }
    .appContainer(PreviewAppContainerFactory.preview(todayExperience: PreviewTodayScenarios.tight))
    .ambitionTheme(.dark)
}

#Preview("Today Recovery") {
    NavigationStack {
        TodayScreen(viewModel: TodayViewModel(state: .loaded(PreviewTodayScenarios.recovery)), autoLoad: false)
    }
    .appContainer(PreviewAppContainerFactory.preview(todayExperience: PreviewTodayScenarios.recovery))
    .ambitionTheme(.dark)
}

#Preview("Today Drifted") {
    NavigationStack {
        TodayScreen(viewModel: TodayViewModel(state: .loaded(PreviewTodayScenarios.drifted)), autoLoad: false)
    }
    .appContainer(PreviewAppContainerFactory.preview(todayExperience: PreviewTodayScenarios.drifted))
    .ambitionTheme(.dark)
}

#Preview("Today Overloaded") {
    NavigationStack {
        TodayScreen(viewModel: TodayViewModel(state: .loaded(PreviewTodayScenarios.overloaded)), autoLoad: false)
    }
    .appContainer(PreviewAppContainerFactory.preview(todayExperience: PreviewTodayScenarios.overloaded))
    .ambitionTheme(.dark)
}

#Preview("Today Low Data") {
    NavigationStack {
        TodayScreen(viewModel: TodayViewModel(state: .loaded(PreviewTodayScenarios.lowData)), autoLoad: false)
    }
    .appContainer(PreviewAppContainerFactory.preview(todayExperience: PreviewTodayScenarios.lowData))
    .ambitionTheme(.dark)
}

#Preview("Today No Plan") {
    NavigationStack {
        TodayScreen(viewModel: TodayViewModel(state: .loaded(PreviewTodayScenarios.noPlan)), autoLoad: false)
    }
    .appContainer(PreviewAppContainerFactory.preview(todayExperience: PreviewTodayScenarios.noPlan))
    .ambitionTheme(.dark)
}

#Preview("Today Reality Meridian Private") {
    NavigationStack {
        TodayScreen(viewModel: TodayViewModel(state: .loaded(PreviewTodayScenarios.privateRail)), autoLoad: false)
    }
    .appContainer(PreviewAppContainerFactory.preview(todayExperience: PreviewTodayScenarios.privateRail))
    .ambitionTheme(.dark)
}

#Preview("Today Reality Meridian Empty") {
    NavigationStack {
        TodayScreen(viewModel: TodayViewModel(state: .loaded(PreviewTodayScenarios.unavailableRail)), autoLoad: false)
    }
    .appContainer(PreviewAppContainerFactory.preview(todayExperience: PreviewTodayScenarios.unavailableRail))
    .ambitionTheme(.dark)
}

#Preview("Today SI04 Rail Dynamic Type") {
    NavigationStack {
        TodayScreen(viewModel: TodayViewModel(state: .loaded(PreviewTodayScenarios.overloaded)), autoLoad: false)
    }
    .appContainer(PreviewAppContainerFactory.preview(todayExperience: PreviewTodayScenarios.overloaded))
    .ambitionTheme(.dark)
    .environment(\.dynamicTypeSize, .accessibility3)
}

#Preview("Today SI05 Hero Loading") {
    NavigationStack {
        TodayScreen(viewModel: TodayViewModel(state: .loaded(PreviewTodayScenarios.heroLoading)), autoLoad: false)
    }
    .appContainer(PreviewAppContainerFactory.preview(todayExperience: PreviewTodayScenarios.heroLoading))
    .ambitionTheme(.dark)
}

#Preview("Today SI05 Hero Disabled Dynamic Type") {
    NavigationStack {
        TodayScreen(viewModel: TodayViewModel(state: .loaded(PreviewTodayScenarios.heroDisabled)), autoLoad: false)
    }
    .appContainer(PreviewAppContainerFactory.preview(todayExperience: PreviewTodayScenarios.heroDisabled))
    .ambitionTheme(.dark)
    .environment(\.dynamicTypeSize, .accessibility3)
}

#Preview("Today Step Detail Start Here") {
    if let detail = PreviewTodayScenarios.stepDetailStartHere {
        TodayStepDetailSheet(detail: detail)
            .ambitionTheme(.dark)
    }
}

#Preview("Today Step Detail Row") {
    if let detail = PreviewTodayScenarios.stepDetailRow {
        TodayStepDetailSheet(detail: detail)
            .ambitionTheme(.dark)
    }
}

#Preview("Today Step Detail Private") {
    if let detail = PreviewTodayScenarios.privateStepDetail {
        TodayStepDetailSheet(detail: detail)
            .ambitionTheme(.dark)
    }
}

#Preview("Today Step Detail Missing Duration") {
    TodayStepDetailSheet(detail: PreviewTodayScenarios.missingDurationStepDetail)
        .ambitionTheme(.dark)
}
#endif