import AmbitionsDesignSystem
import Foundation
import SwiftUI

extension TodaySurface {
    var bottomChromeClearance: CGFloat {
        TodayViewportSafety.layout(
            dynamicTypeSize: dynamicTypeSize,
            showsNavigationChrome: showsNavigationChrome
        ).rootBottomChromeClearance
    }


    @ViewBuilder
    var todayContent: some View {
        switch viewModel.state {
        case .loading:
            TodayInlineFallbackState(
                title: "Reading your day",
                message: "Ambitions is preparing the current Meridian without changing anything.",
                systemImage: "sparkle.magnifyingglass"
            )
            .padding(.top, theme.spacing.lg)
        case let .loaded(experience):
            TodayObjectView(
                experience: experience,
                approvedReplacementRail: approvedReplacementRail,
                onAction: handleAction,
                onOpenStepDetail: { detail in
                    selectedStepDetail = detail
                },
                onShowAnother: { step, displayRail in
                    selectedStepReplacementSheet = TodayStepReplacementSheetState.make(
                        from: step,
                        privacy: displayRail.privacyProjection,
                        contextLabel: displayRail.contextSummary,
                        recordedAt: DomainTimestamp.string(from: clock.now)
                    )
                },
                onNotThis: { step in
                    selectedRejectionReasonSheet = rejectionReasonSheetState(for: step)
                },
                clock: clock
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


    func activate() async {
        #if DEBUG
        let entryContext = debugScreenshotEntryContext ?? shell.navigation.takeTodayEntryContext()
        #else
        let entryContext = shell.navigation.takeTodayEntryContext()
        #endif
        await viewModel.activate(
            using: featureFactory.todayService,
            userDisplayName: userSystem.session.userDisplayName,
            now: clock.now,
            calendar: clock.calendar,
            entryContext: entryContext,
            timeZone: clock.timeZone
        )
    }


    func refresh() async {
        #if DEBUG
        let entryContext = debugScreenshotEntryContext ?? shell.navigation.takeTodayEntryContext()
        #else
        let entryContext = shell.navigation.takeTodayEntryContext()
        #endif
        await viewModel.refresh(
            using: featureFactory.todayService,
            userDisplayName: userSystem.session.userDisplayName,
            now: clock.now,
            calendar: clock.calendar,
            entryContext: entryContext,
            timeZone: clock.timeZone
        )
    }


    func observeDayBoundary() async {
        while Task.isCancelled == false {
            do {
                try await Task.sleep(for: .seconds(60))
            } catch {
                return
            }
            await refreshIfDayBoundaryChanged()
        }
    }


    func refreshIfDayBoundaryChanged() async {
        let now = clock.now
        guard viewModel.shouldRefreshForClockChange(now: now, calendar: clock.calendar, timeZone: clock.timeZone) else { return }
        await refresh()
    }


    func handleAction(_ action: TodayInlineAction) {
        let intent = TodayInteractions.intent(for: action)
        _ = TodayInteractions.accessibilityAnnouncement(for: intent)
        switch intent {
        case .startStep:
            shell.navigation.selectToday(entryContext: .stepSession)
        case .pauseStep:
            viewModel.transientMessage = TodayInlineMessage(
                title: "Session paused",
                body: "This step stays here until you choose an outcome.",
                state: .selected
            )
        case .stopStep:
            shell.navigation.selectToday(entryContext: .standard)
            viewModel.transientMessage = TodayInlineMessage(
                title: "Back to Today",
                body: "Step session ended. Today is ready for the next step.",
                state: .selected
            )
        case .closeStep:
            selectedActionClosure = actionClosureState(for: action)
        case .openDetail:
            shell.navigation.openGoalDetail(
                goalID: action.target.goalID,
                draftID: action.target.draftID,
                launchContext: action.kind == .askForHelp ? .help : .standard
            )
        case .openCapture:
            shell.commandRouter.presentCommandSheet(
                intent: .quickCapture,
                source: .todayQuickCapture,
                presentationContext: .quickCapture
            )
        case .shapeTime:
            selectedTimeShape = timeShapeFlowState(for: action)
        case .protectWindow:
            selectedWindowProtection = windowProtectionFlowState(for: action)
        case .runtimeMutation:
            Task {
                await viewModel.handle(
                    action,
                    using: featureFactory.todayService,
                    userDisplayName: userSystem.session.userDisplayName,
                    now: clock.now,
                    calendar: clock.calendar,
                    entryContext: .standard,
                    timeZone: clock.timeZone
                )
            }
        }
    }


    func displayedExecution(from experience: TodayExperience) -> TodayExecutionViewState {
        approvedReplacementRail.map { experience.execution.replacingDayRail($0) } ?? experience.execution
    }


    func currentDisplayRail() -> AmbitionsDayRailViewState? {
        guard case let .loaded(experience) = viewModel.state else { return nil }
        return displayedExecution(from: experience).dayRail
    }


    func actionClosureState(for action: TodayInlineAction) -> TodayActionClosureSheetState {
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


    func windowProtectionFlowState(for action: TodayInlineAction) -> TodayWindowProtectionFlowState {
        guard let rail = currentDisplayRail(), let hero = rail.heroStep else {
            return TodayWindowProtectionFlowState.unavailable(
                title: "No window to protect",
                message: "Today does not have a current step and plausible window to protect right now.",
                target: action.target
            )
        }
        return TodayWindowProtectionFlowState.available(
            stepTitle: rail.privacyProjection.detailTitle(hero.title),
            windowSummary: rail.contextSummary,
            target: action.target
        )
    }


    func timeShapeFlowState(for action: TodayInlineAction) -> TodayTimeShapeFlowState {
        guard let rail = currentDisplayRail(), let hero = rail.heroStep else {
            return TodayTimeShapeFlowState.unavailable(
                title: "Nothing to shape",
                message: "Today has no current step to place or reshape right now.",
                target: action.target
            )
        }
        return TodayTimeShapeFlowState.contextual(
            stepTitle: rail.privacyProjection.detailTitle(hero.title),
            windowSummary: rail.contextSummary,
            target: action.target
        )
    }


    func rejectionReasonSheetState(for step: DayRailHeroStepState) -> TodayRejectionReasonSheetState {
        TodayRejectionReasonSheetState(
            title: "Not this",
            subtitle: "Tell Ambitions what makes this recommendation miss so the next pass can stay local and useful.",
            contextLabel: step.becauseLine,
            candidateID: step.id,
            sourceCandidateID: step.id,
            sourceStepID: step.primaryAction.target.stepID ?? step.detailTarget.stepID ?? step.id,
            contextFingerprint: rejectionContextFingerprint(for: step),
            recordedAt: DomainTimestamp.string(from: clock.now)
        )
    }


    func rejectionContextFingerprint(for step: DayRailHeroStepState) -> String {
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


    func submitRejection(_ submission: TodayRejectionSubmission, from sheetState: TodayRejectionReasonSheetState) async {
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
}
