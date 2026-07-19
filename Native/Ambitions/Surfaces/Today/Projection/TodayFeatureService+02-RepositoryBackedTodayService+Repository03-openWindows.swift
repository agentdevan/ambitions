import AmbitionsDesignSystem
import Foundation

extension RepositoryBackedTodayService {
    func openWindows(
        now: Date,
        posture: TodayDayPosture,
        focus: TodayFocusState,
        dailyTargets: TodayDailyTargetsState,
        freeTime: TodayFreeTimeState
    ) -> [TodayOpenWindowState] {
        let calendar = clock.calendar
        let hour = calendar.component(.hour, from: now)
        let laneTitles: [(String, String)] = [
            ("Next 45 minutes", hour < 17 ? "A near-term block is still available if the next step stays bounded." : "A short closing block is still available if it stays gentle."),
            ("Later today", "There is still room for one follow-on step if the first block resolves cleanly."),
            ("Protect the evening", "If attention is thinning, preserve one calmer block instead of adding more switching.")
        ]

        var windows: [TodayOpenWindowState] = []
        let candidateActions = focus.primaryActionsForRecovery + freeTime.opportunities.compactMap(\.action)
        for (index, lane) in laneTitles.enumerated() {
            let action = candidateActions.dropFirst(index).first ?? candidateActions.first
            let title: String
            let subtitle: String
            if let action {
                title = lane.0
                subtitle = action.kind == .protectLater
                    ? "Use this room to preserve the next believable block."
                    : lane.1
            } else {
                title = lane.0
                subtitle = "No additional step needs to be forced into this window."
            }
            windows.append(
                TodayOpenWindowState(
                    id: "window-\(index)",
                    title: title,
                    subtitle: subtitle,
                    timingLabel: timingLabelForWindow(index: index, hour: hour),
                    state: posture == .overloaded && index == 0 ? .warning : .default,
                    action: action
                )
            )
        }

        if dailyTargets.items.isEmpty && freeTime.opportunities.isEmpty {
            return []
        }
        return Array(windows.prefix(posture == .stable ? 2 : 3))
    }

    func timingLabelForWindow(index: Int, hour: Int) -> String {
        switch index {
        case 0:
            return hour < 12 ? "Morning room" : hour < 17 ? "Afternoon room" : "Closing room"
        case 1:
            return "Later today"
        default:
            return "Adjust plan"
        }
    }

    func makeRecoveryBloom(
        posture: TodayDayPosture,
        focus: TodayFocusState,
        freeTime: TodayFreeTimeState
    ) -> TodayRecoveryBloomState? {
        guard posture == .drifted || posture == .recovering || posture == .overloaded || posture == .tight else {
            return nil
        }

        let options = recoveryOptions(for: posture, focus: focus, freeTime: freeTime)
        guard options.isEmpty == false else { return nil }

        let title: String
        let subtitle: String
        let explanation: String
        let pressureField: String
        let recoveryLoop: String
        let smallerStepAnchor: String
        let receiptPreview: String
        switch posture {
        case .tight:
            title = "Keep the day believable"
            subtitle = "One light adjustment now is calmer than a mess later."
            explanation = "Recovery here is small on purpose. The app is reducing pressure before the day turns into catch-up theater."
            pressureField = "Pressure field: the day is tight, so extra switching should stay visible."
            recoveryLoop = "Recovery loop: lighten one ask, keep Still counts available, and review before changing the day."
            smallerStepAnchor = "Smaller step anchor: choose the lightest useful version before adding effort."
            receiptPreview = "Recovery review preview: records the lighter path and what stayed unchanged."
        case .drifted:
            title = "Recovery Bloom"
            subtitle = "The day can still recover through one believable step."
            explanation = "The safer path is shown first, and the prior plan stays visible only as background context."
            pressureField = "Pressure field: the first plan drifted, so recovery starts with one believable lane."
            recoveryLoop = "Recovery loop: orient, shrink the next step, and preview the receipt before anything changes."
            smallerStepAnchor = "Smaller step anchor: return through one safe action, not the whole original plan."
            receiptPreview = "Recovery review preview: records what changed and what still counts."
        case .overloaded:
            title = "Lighten today"
            subtitle = "The day needs fewer simultaneous asks before effort goes up."
            explanation = "This is not a failure state. The system is narrowing the day so the next step feels real again."
            pressureField = "Pressure field: too many asks are touching today at once."
            recoveryLoop = "Recovery loop: reduce the load, offer the smaller safe next step, and keep review in front."
            smallerStepAnchor = "Smaller step anchor: make the next step small enough to start without sacrificing protected time."
            receiptPreview = "Recovery review preview: records the lighter next step, protected time, and Still counts boundary."
        case .recovering:
            title = "Stay in the recovery lane"
            subtitle = "Use one gentle step to stabilize the rest of the day."
            explanation = "The bloom keeps the next step singular so recovery feels relieving instead of corrective."
            pressureField = "Pressure field: recovery is already active, so the day stays narrowed."
            recoveryLoop = "Recovery loop: continue the lighter path and keep the receipt visible."
            smallerStepAnchor = "Smaller step anchor: stay with the smallest stabilizing block."
            receiptPreview = "Recovery review preview: records that recovery continued without turning into catch-up."
        case .stable, .lowData, .noPlan:
            return nil
        }

        return TodayRecoveryBloomState(
            title: title,
            subtitle: subtitle,
            explanation: explanation,
            pressureFieldLabel: pressureField,
            recoveryLoopLabel: recoveryLoop,
            smallerStepAnchorLabel: smallerStepAnchor,
            recoveryReceiptPreviewLabel: receiptPreview,
            options: options
        )
    }

    func recoveryOptions(
        for posture: TodayDayPosture,
        focus: TodayFocusState,
        freeTime: TodayFreeTimeState
    ) -> [TodayRecoveryOptionState] {
        let actions = focus.primaryActionsForRecovery + freeTime.opportunities.compactMap(\.action)
        var options: [TodayRecoveryOptionState] = []

        func append(_ action: TodayInlineAction?, title: String? = nil, detail: String, state: AmbitionVisualState? = nil) {
            guard let action else { return }
            let resolvedTitle = title ?? action.title
            guard options.contains(where: { $0.action.id == action.id || $0.title == resolvedTitle }) == false else { return }
            options.append(
                TodayRecoveryOptionState(
                    id: "\(action.kind.rawValue)-\(resolvedTitle)",
                    title: resolvedTitle,
                    detail: detail,
                    state: state ?? action.state,
                    action: action
                )
            )
        }

        append(actions.first(where: { $0.kind == .split }), title: "Smaller version", detail: "Shrink the next step until it feels safe to start.", state: .selected)
        append(actions.first(where: { $0.kind == .complete || $0.kind == .startStepSession }), title: "Safest step", detail: "If the current step is still doable, stay with the calmest useful action.", state: .success)
        append(actions.first(where: { $0.kind == .reschedule || $0.kind == .defer }), title: "Reschedule gently", detail: "Reschedule the work without turning the day into a failure narrative.", state: .default)
        append(actions.first(where: { $0.kind == .protectLater }), title: "Adjust time", detail: "Put one cleaner block in Time instead of squeezing it here.", state: .default)
        append(
            TodayInlineAction(
                kind: .openTime,
                title: "Accept today's shape",
                systemImage: "calendar",
                state: .default,
                target: actions.first?.target ?? TodayActionTarget()
            ),
            detail: "Let the rest of the day stay lighter and carry the shaping into Goals."
        )

        return Array(options.prefix(4))
    }

    func makeStepSession(
        entryContext: TodayEntryContext,
        focus: TodayFocusState,
        posture: TodayDayPosture,
        shellSummary: GoalShellSummaryState?
    ) -> TodayStepSessionState? {
        guard entryContext.normalized == .stepSession else { return nil }
        let fallbackAction = TodayInlineAction(
            kind: .openTime,
            title: "Open Time",
            systemImage: "calendar",
            state: .selected,
            target: TodayActionTarget()
        )
        let primary = focus.primaryActionsForRecovery.first(where: { $0.kind != .startStepSession }) ?? fallbackAction

        let title: String
        let subtitle: String
        switch focus {
        case let .planned(state):
            title = state.title
            subtitle = state.reason
        case let .starter(state):
            title = state.title
            subtitle = state.reassurance
        case let .clarification(state):
            title = state.title
            subtitle = state.subtitle
        case let .blocked(state):
            title = state.title
            subtitle = state.nextBestAction
        case let .empty(state):
            title = state.title
            subtitle = state.message
        }

        let detail = posture == .stable
            ? "Step session is narrowed to one step so the rest of Today can stay quiet."
            : "Step session is a calmer lane back into the day."

        let closeAction = TodayInlineAction(
            kind: .closeActionClosure,
            title: "Close the loop",
            systemImage: "checkmark.bubble",
            state: .selected,
            target: primary.target
        )
        let pauseAction = TodayInlineAction(
            kind: .pauseStepSession,
            title: "Pause",
            systemImage: "pause.circle",
            state: .default,
            target: primary.target
        )
        let stopAction = TodayInlineAction(
            kind: .stopStepSession,
            title: "Stop session",
            systemImage: "xmark.circle",
            state: .default,
            target: primary.target
        )
        let supportingActions = focus.primaryActionsForRecovery.filter {
            $0.id != primary.id
                && $0.kind != .startStepSession
                && $0.kind != .complete
                && $0.kind != .pauseStepSession
                && $0.kind != .stopStepSession
        }
        let contextReminder = posture == .stable
            ? "One step is in focus. The rest of Today stays available behind it."
            : "One step is in focus. Recovery stays available without changing proof."
        let goalConnection = primary.target.goalID == nil
            ? "Goal context is not attached yet."
            : "Goal context stays attached while this step is in session."

        return TodayStepSessionState(
            title: title,
            subtitle: subtitle,
            detail: detail,
            primaryAction: primary,
            secondaryActions: Array(supportingActions.prefix(2)),
            trustWhisper: shellSummary.map {
                TodayTrustWhisperState(
                    title: "Based on",
                    detail: $0.explanationSummary,
                    state: .selected
                )
            },
            contextReminderLabel: contextReminder,
            goalConnectionLabel: goalConnection,
            timerLabel: "Timer optional",
            sessionControlActions: [pauseAction, stopAction, closeAction],
            receiptGenerationLabel: "Closing the loop opens the review preview before proof changes.",
            exitBoundaryLabel: "Stopping the session returns to Today without changing proof or plan."
        )
    }

    func deduplicated(_ actions: [TodayInlineAction]) -> [TodayInlineAction] {
        var seen = Set<String>()
        return actions.filter {
            let key = "\($0.kind.rawValue)-\($0.target.goalID ?? "none")-\($0.target.stepID ?? "none")"
            return seen.insert(key).inserted
        }
    }

    func makeRitual(snapshot: Snapshot, activeGoals: [Goal], learningSnapshot: LearningAnticipationSnapshot, sharedLifeSnapshot: SharedLifeCoordinationSnapshot, now: Date) -> TodayRitualLoopState {
        let plan = ritualService.makePlan(
            input: RitualOrchestrationInput(
                goals: activeGoals,
                captures: snapshot.captures,
                evidence: snapshot.evidence,
                feedback: snapshot.feedback,
                learningSnapshot: learningSnapshot,
                sharedLifeSnapshot: sharedLifeSnapshot,
                now: now
            )
        )
        let recommendation = plan.activeRecommendation
        return TodayRitualLoopState(
            kind: recommendation.kind,
            title: recommendation.title,
            subtitle: recommendation.body,
            thesis: recommendation.kind == .weeklyReset ? plan.weekThesis : plan.dayThesis,
            stateLabel: recommendation.stateLabel,
            signalLabels: ritualSignalLabels(from: plan.signalSummary),
            action: recommendation.primaryAction.map(todayAction(from:))
        )
    }

    func todayAction(from action: RitualActionReference) -> TodayInlineAction {
        let kind: TodayActionKind
        let title: String
        let systemImage: String
        let state: AmbitionVisualState
        switch action.kind {
        case .complete:
            kind = .complete
            title = "Still counts"
            systemImage = "checkmark"
            state = .success
        case .delay:
            kind = .defer
            title = "Move it"
            systemImage = "clock.arrow.circlepath"
            state = .default
        case .askForSmallerStep:
            kind = .split
            title = "Split"
            systemImage = "scissors"
            state = .selected
        case .quickLog:
            kind = .quickLog
            title = "Quick log"
            systemImage = "square.and.pencil"
            state = .default
        case .openDetail:
            kind = .openDetail
            title = "Open detail"
            systemImage = "arrow.right.circle"
            state = .default
        }
        return TodayInlineAction(
            kind: kind,
            title: title,
            systemImage: systemImage,
            state: state,
            target: TodayActionTarget(goalID: action.goalID, stepID: action.stepID, draftID: action.draftID)
        )
    }

    func ritualSignalLabels(from summary: RitualSignalSummary) -> [String] {
        var labels = [
            "\(summary.activeGoalCount) active goal\(summary.activeGoalCount == 1 ? "" : "s")",
            "\(summary.completedTodayCount) done today"
        ]
        if summary.frictionTodayCount > 0 {
            labels.append("\(summary.frictionTodayCount) friction signal\(summary.frictionTodayCount == 1 ? "" : "s")")
        }
        if summary.openCaptureCount > 0 {
            labels.append("\(summary.openCaptureCount) open capture\(summary.openCaptureCount == 1 ? "" : "s")")
        }
        labels.append("\(summary.pressureLevel.rawValue) pressure")
        return labels
    }

}
