import AmbitionsDesignSystem
import Foundation
import SwiftUI

struct TodayScreen: View {
    // Canon marker for frontend recovery gates: TodayExecutionDepthDisclosure.
    @Environment(\.appShellCapability) private var appShellCapability
    @Environment(\.appFeatureFactoryCapability) private var appFeatureFactoryCapability
    @Environment(\.appUserSystemCapability) private var appUserSystemCapability
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @State private var viewModel: TodayViewModel
    @State private var selectedStepDetail: DayRailStepDetailState?
    @State private var selectedActionClosure: TodayActionClosureSheetState?
    @State private var selectedRejectionReasonSheet: TodayRejectionReasonSheetState?
    @State private var selectedStepReplacementSheet: TodayStepReplacementSheetState?
    @State private var approvedReplacementRail: AmbitionsDayRailViewState?
    #if DEBUG
    @State private var debugScreenshotSheetApplied = false
    #endif

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

            todayContent
                .padding(.horizontal, theme.spacing.lg)
                .padding(.bottom, bottomChromeClearance)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .accessibilityIdentifier("today.screen")
            .refreshable {
                await refresh()
            }
        }
        .navigationTitle(showsNavigationChrome ? "Today" : "")
        .navigationBarTitleDisplayMode(dynamicTypeSize.isAccessibilitySize ? .inline : .large)
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
        #if DEBUG
        .task(id: viewModel.stateKey) {
            applyDebugScreenshotSheetIfNeeded()
        }
        #endif
    }

    private var bottomChromeClearance: CGFloat {
        if showsNavigationChrome {
            return theme.spacing.xxxl
        }
        return dynamicTypeSize.isAccessibilitySize ? 340 : 300
    }

    @ViewBuilder
    private var todayContent: some View {
        switch viewModel.state {
        case .loading:
            TodayInlineFallbackState(
                title: "Reading your day",
                message: "Ambitions is preparing the current Meridian without changing anything.",
                systemImage: "sparkle.magnifyingglass"
            )
            .padding(.top, theme.spacing.lg)
        case let .loaded(experience):
            let displayExecution = displayedExecution(from: experience)
            let displayRail = displayExecution.dayRail
            TodayRealityMeridianFlagshipAdapter(
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
            .transition(.opacity)

            if let message = viewModel.transientMessage {
                TodayInlineFallbackState(
                    title: message.title,
                    message: message.body,
                    systemImage: "checkmark.circle.fill"
                )
                .padding(.top, theme.spacing.md)
                .accessibilityIdentifier("today.post-closure-feedback")
            }

        default:
            TodayInlineFallbackState(
                title: "Today could not load",
                message: "Retry the local Today pass. No remote intelligence is required.",
                systemImage: "exclamationmark.triangle",
                actionTitle: "Retry"
            ) {
                Task { await refresh() }
            }
            .padding(.top, theme.spacing.lg)
        }
    }

    private func activate() async {
        #if DEBUG
        let entryContext = debugScreenshotEntryContext ?? shell.navigation.takeTodayEntryContext()
        #else
        let entryContext = shell.navigation.takeTodayEntryContext()
        #endif
        await viewModel.activate(
            using: featureFactory.todayService,
            userDisplayName: userSystem.session.userDisplayName,
            entryContext: entryContext
        )
    }

    private func refresh() async {
        #if DEBUG
        let entryContext = debugScreenshotEntryContext ?? shell.navigation.takeTodayEntryContext()
        #else
        let entryContext = shell.navigation.takeTodayEntryContext()
        #endif
        await viewModel.refresh(
            using: featureFactory.todayService,
            userDisplayName: userSystem.session.userDisplayName,
            entryContext: entryContext
        )
    }

    private func handleAction(_ action: TodayInlineAction) {
        switch action.kind {
        case .startStepSession:
            shell.navigation.selectToday(entryContext: .stepSession)
        case .pauseStepSession:
            viewModel.transientMessage = TodayInlineMessage(
                title: "Session paused",
                body: "This step stays here until you choose an outcome.",
                state: .selected
            )
        case .stopStepSession:
            shell.navigation.selectToday(entryContext: .standard)
            viewModel.transientMessage = TodayInlineMessage(
                title: "Back to Today",
                body: "Step session ended. Today is ready for the next step.",
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
                startHereReceiptLabel: hero.receiptLabel,
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

    #if DEBUG
    @MainActor
    private func applyDebugScreenshotSheetIfNeeded() {
        guard debugScreenshotSheetApplied == false else { return }
        guard case .loaded = viewModel.state else { return }
        guard let sheet = debugScreenshotSheet else { return }
        guard let rail = currentDisplayRail(), let heroStep = rail.heroStep else { return }

        switch sheet {
        case "trust":
            selectedStepDetail = heroStep.stepDetail(
                privacy: rail.privacyProjection,
                contextLabel: rail.contextSummary
            )
        case "receipt":
            selectedActionClosure = actionClosureState(for: heroStep.primaryAction)
        default:
            return
        }

        debugScreenshotSheetApplied = true
    }

    private var debugScreenshotEntryContext: TodayEntryContext? {
        debugLaunchArgumentValue(for: "AmbitionsTodayEntryContext")
            .flatMap(TodayEntryContext.init(rawValue:))
    }

    private var debugScreenshotSheet: String? {
        debugLaunchArgumentValue(for: "AmbitionsTodaySheet")?.lowercased()
    }

    private func debugLaunchArgumentValue(for key: String) -> String? {
        let arguments = ProcessInfo.processInfo.arguments
        guard let index = arguments.firstIndex(of: "-\(key)"),
              arguments.indices.contains(index + 1) else {
            return nil
        }
        let value = arguments[index + 1].trimmingCharacters(in: .whitespacesAndNewlines)
        return value.isEmpty ? nil : value
    }
    #endif

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
