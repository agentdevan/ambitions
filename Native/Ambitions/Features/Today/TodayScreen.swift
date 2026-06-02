import AmbitionsDesignSystem
import SwiftUI

struct TodayScreen: View {
    // Canon marker for frontend recovery gates: TodayExecutionDepthDisclosure.
    @Environment(\.appShellCapability) private var appShellCapability
    @Environment(\.appFeatureFactoryCapability) private var appFeatureFactoryCapability
    @Environment(\.appUserSystemCapability) private var appUserSystemCapability
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var viewModel: TodayViewModel
    @State private var selectedStepDetail: DayRailStepDetailState?
    @State private var selectedActionClosure: TodayActionClosureSheetState?
    @State private var selectedRejectionReasonSheet: TodayRejectionReasonSheetState?
    @State private var selectedStepReplacementSheet: TodayStepReplacementSheetState?
    @State private var approvedReplacementRail: AmbitionsDayRailViewState?

    private let autoLoad: Bool
    private let showsNavigationChrome: Bool

    @MainActor
    init(viewModel: TodayViewModel? = nil, autoLoad: Bool = true, showsNavigationChrome: Bool = true) {
        _viewModel = State(initialValue: viewModel ?? TodayViewModel())
        self.autoLoad = autoLoad
        self.showsNavigationChrome = showsNavigationChrome
    }

    var body: some View {
        ZStack(alignment: .top) {
            TodayBackgroundView()

            ScrollView {
                LazyVStack(alignment: .leading, spacing: theme.spacing.lg) {
                    switch viewModel.state {
                    case .loading:
                        TodayInlineFallbackState(
                            title: "Reading your day",
                            message: "Ambitions is preparing the current Meridian without changing anything.",
                            systemImage: "sparkle.magnifyingglass"
                        )
                    case .failed:
                        TodayInlineFallbackState(
                            title: "Today could not load",
                            message: "Retry the local Today pass. No remote intelligence is required.",
                            systemImage: "exclamationmark.triangle",
                            actionTitle: "Retry"
                        ) {
                            Task { await refresh() }
                        }
                    case let .loaded(experience):
                        let displayExecution = displayedExecution(from: experience)
                        let displayRail = displayExecution.dayRail
                        RealityMeridianView(
                            state: displayRail,
                            onAction: handleAction,
                            onOpenStepDetail: { detail in
                                selectedStepDetail = detail
                            },
                            onShowAnother: { step in
                                selectedStepReplacementSheet = TodayStepReplacementSheetState.make(
                                    from: step,
                                    privacy: displayRail.privacyProjection,
                                    contextLabel: displayRail.contextSummary
                                )
                            },
                            onNotThis: { step in
                                selectedRejectionReasonSheet = rejectionReasonSheetState(for: step)
                            }
                        )
                        .fusedCurrentTimeCursor()
                        .transition(.opacity)

                        if experience.mode == .empty {
                            TodayInlineFallbackState(
                                title: "No step is required right now",
                                message: "Capture or create a goal when you want to add direction. Today stays clear until then.",
                                systemImage: "moon.stars",
                                actionTitle: "Capture"
                            ) {
                                shell.commandRouter.presentCommandSheet(
                                    intent: .quickCapture,
                                    source: .todayQuickCapture,
                                    presentationContext: .quickCapture
                                )
                            }
                        }
                    }
                }
                .padding(.horizontal, theme.spacing.lg)
                .padding(.top, 0)
                .padding(.bottom, theme.spacing.xxxl)
            }
            .scrollIndicators(.hidden)
            .accessibilityIdentifier("today.screen")
            .refreshable {
                await refresh()
            }
        }
        .navigationTitle(showsNavigationChrome ? "Today" : "")
        .toolbar {
            if showsNavigationChrome {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        shell.commandRouter.route(to: .timeRoute(.captureInbox), source: .shellUtility)
                    } label: {
                        Label("Capture", systemImage: AppTab.capture.systemImage)
                    }
                    .accessibilityIdentifier("today.open-captures-button")
                }
            }
        }
        .animation(theme.motion.animation(reduceMotion: reduceMotion, emphasis: true), value: viewModel.stateKey)
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
                selectedActionClosure = nil
                Task {
                    await viewModel.confirmActionClosure(
                        closure,
                        outcome: outcome,
                        using: featureFactory.todayService,
                        userDisplayName: userSystem.session.userDisplayName,
                        entryContext: shell.navigation.takeTodayEntryContext()
                    )
                }
            }
            .ambitionTheme(theme)
        }
        .sheet(item: $selectedRejectionReasonSheet) { sheetState in
            TodayRejectionReasonSheet(state: sheetState) { submission in
                selectedRejectionReasonSheet = nil
                Task {
                    await submitRejection(submission, from: sheetState)
                }
            }
            .ambitionTheme(theme)
        }
        .sheet(item: $selectedStepReplacementSheet) { sheetState in
            TodayStepReplacementSheet(
                state: sheetState,
                onWhyNotThis: {
                    selectedStepReplacementSheet = nil
                    selectedRejectionReasonSheet = rejectionReasonSheetState(for: sheetState.originalHero)
                },
                onApprove: { option in
                    selectedStepReplacementSheet = nil
                    if let currentRail = currentDisplayRail() {
                        approvedReplacementRail = sheetState.approvedRail(
                            from: currentRail,
                            selectedOption: option
                        )
                    }
                    viewModel.transientMessage = sheetState.approvalReceiptMessage(for: option)
                }
            )
            .ambitionTheme(theme)
        }
        .onChange(of: shell.navigation.selectedTab) { _, selectedTab in
            guard autoLoad, selectedTab == .today else { return }
            Task { await activate() }
        }
        .onChange(of: shell.navigation.todayEntryContext) { _, entryContext in
            guard autoLoad, shell.navigation.selectedTab == .today, entryContext != .standard else { return }
            Task { await activate() }
        }
        .task {
            guard autoLoad else { return }
            await activate()
        }
    }

    private func activate() async {
        await viewModel.activate(
            using: featureFactory.todayService,
            userDisplayName: userSystem.session.userDisplayName,
            entryContext: shell.navigation.takeTodayEntryContext()
        )
    }

    private func refresh() async {
        await viewModel.refresh(
            using: featureFactory.todayService,
            userDisplayName: userSystem.session.userDisplayName,
            entryContext: shell.navigation.takeTodayEntryContext()
        )
    }

    private func handleAction(_ action: TodayInlineAction) {
        switch action.kind {
        case .startStepSession:
            shell.navigation.selectToday(entryContext: .stepSession)
        case .pauseStepSession:
            viewModel.transientMessage = TodayInlineMessage(
                title: "Session paused",
                body: "This step is still here. Nothing changes until you close the loop.",
                state: .selected
            )
        case .stopStepSession:
            shell.navigation.selectToday(entryContext: .standard)
            viewModel.transientMessage = TodayInlineMessage(
                title: "Back to Today",
                body: "Step Session ended without changing proof or plan.",
                state: .selected
            )
        case .closeActionClosure:
            selectedActionClosure = actionClosureState(for: action)
        case .openDetail, .askForHelp:
            shell.navigation.openGoalDetail(
                goalID: action.target.goalID,
                draftID: action.target.draftID,
                launchContext: action.kind == .askForHelp ? .help : .standard
            )
        case .quickLog:
            shell.commandRouter.presentCommandSheet(
                intent: .quickCapture,
                source: .todayQuickCapture,
                presentationContext: .quickCapture
            )
        case .openTime:
            shell.commandRouter.route(to: .tab(.time), source: .shellUtility)
        case .protectLater:
            shell.commandRouter.route(to: .tab(.time), source: .shellUtility)
            viewModel.transientMessage = TodayInlineMessage(
                title: "Opened Time",
                body: "Today handed this off to the canonical planning surface instead of creating a second recovery system here.",
                state: .selected
            )
        default:
            Task {
                await viewModel.handle(
                    action,
                    using: featureFactory.todayService,
                    userDisplayName: userSystem.session.userDisplayName,
                    entryContext: .standard
                )
            }
        }
    }

    private func displayedExecution(from experience: TodayExperience) -> TodayExecutionViewState {
        approvedReplacementRail.map { experience.execution.replacingDayRail($0) } ?? experience.execution
    }

    private func currentDisplayRail() -> AmbitionsDayRailViewState? {
        guard case let .loaded(experience) = viewModel.state else { return nil }
        return displayedExecution(from: experience).dayRail
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

    private func rejectionReasonSheetState(for step: DayRailHeroStepState) -> TodayRejectionReasonSheetState {
        TodayRejectionReasonSheetState(
            title: "Not this",
            subtitle: "Tell Ambitions what makes this recommendation miss so the next pass can stay local and useful.",
            contextLabel: step.becauseLine,
            candidateID: step.id,
            sourceCandidateID: step.id,
            sourceStepID: step.primaryAction.target.stepID ?? step.detailTarget.stepID ?? step.id,
            contextFingerprint: rejectionContextFingerprint(for: step),
            recordedAt: DomainTimestamp.string(from: .now)
        )
    }

    private func rejectionContextFingerprint(for step: DayRailHeroStepState) -> String {
        CandidateSource.stableIdentifier(
            prefix: "today-rejection-context",
            components: [
                step.id,
                step.title,
                step.subtitle,
                step.becauseLine,
                step.duration.label,
                step.fitLabel,
                step.sourceQualityLabel,
                step.contextEdge.title,
                step.contextEdge.summary,
                step.goalThread.title,
                step.goalThread.summary
            ]
        )
    }

    private func submitRejection(_ submission: TodayRejectionSubmission, from sheetState: TodayRejectionReasonSheetState) async {
        guard let service = featureFactory.todayService as? RepositoryBackedTodayService else {
            viewModel.transientMessage = TodayInlineMessage(
                title: "Not this saved locally",
                body: "The current Today service cannot persist the rejection sheet in this preview path.",
                state: .warning
            )
            return
        }

        do {
            let response = try await service.recordRecommendationRejection(
                TodayRecommendationRejectionInput(
                    candidateID: sheetState.candidateID,
                    sourceCandidateID: sheetState.sourceCandidateID,
                    sourceStepID: sheetState.sourceStepID,
                    contextFingerprint: sheetState.contextFingerprint,
                    reason: submission.reason,
                    skippedReason: submission.skippedReason,
                    customText: submission.customText,
                    recordedAt: sheetState.recordedAt
                )
            )
            viewModel.transientMessage = response.message
            await refresh()
        } catch {
            viewModel.transientMessage = TodayInlineMessage(
                title: "Not this could not be saved",
                body: error.localizedDescription,
                state: .warning
            )
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

    private var userSystem: AppUserSystemCapability {
        guard let appUserSystemCapability else {
            preconditionFailure("App user system capability must be injected.")
        }
        return appUserSystemCapability
    }
}

private struct TodayInlineFallbackState: View {
    @Environment(\.ambitionTheme) private var theme

    let title: String
    let message: String
    let systemImage: String
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            Image(systemName: systemImage)
                .font(.system(size: 28, weight: .semibold, design: .rounded))
                .foregroundStyle(theme.colors.accentWarm)
            Text(title)
                .font(theme.typography.title.weight(.semibold))
                .foregroundStyle(theme.colors.textPrimary)
            Text(message)
                .font(theme.typography.body)
                .foregroundStyle(theme.colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .buttonStyle(.borderedProminent)
            }
        }
        .padding(.top, theme.spacing.xxxl)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#if DEBUG
#Preview("Today MFP") {
    NavigationStack {
        TodayScreen(viewModel: TodayViewModel(state: .loaded(PreviewTodayScenarios.stable)), autoLoad: false)
    }
    .appContainer(PreviewAppContainerFactory.preview(todayExperience: PreviewTodayScenarios.stable))
    .ambitionTheme(.dark)
}

#Preview("Today MFP Dynamic Type") {
    NavigationStack {
        TodayScreen(viewModel: TodayViewModel(state: .loaded(PreviewTodayScenarios.overloaded)), autoLoad: false)
    }
    .appContainer(PreviewAppContainerFactory.preview(todayExperience: PreviewTodayScenarios.overloaded))
    .ambitionTheme(.dark)
    .environment(\.dynamicTypeSize, .accessibility3)
}
#endif
