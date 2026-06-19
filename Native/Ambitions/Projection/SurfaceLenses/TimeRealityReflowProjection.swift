import AmbitionsDesignSystem
import Foundation

extension RepositoryBackedTimeService {
    func makeRealityReflow(
        mode: TimeSurfaceMode,
        activeGoals: [Goal],
        summaries: [RepositoryBackedTimeService.GoalWeekSummary],
        missingGoalSummaries: [RepositoryBackedTimeService.GoalWeekSummary],
        weekDays: [TimeElasticWeekDayState],
        openCaptures: [Capture],
        blockedDraftCount: Int,
        clarificationDraftCount: Int,
        evidenceByGoal: [String: [ProgressEvidence]],
        calendarAwareness: TimeCalendarAwarenessState,
        pressuredGoalSummary: RepositoryBackedTimeService.GoalWeekSummary?
    ) -> TimeRealityReflowState {
        let overloadedDays = weekDays.filter { $0.level == .overloaded }.count
        let fragileDays = weekDays.filter { $0.level == .fragile }.count
        let openDays = weekDays.filter { $0.level == .open }.count
        let blockedSummary = summaries.first { summary in
            summary.contexts.contains(where: { $0.step.state == .blocked })
        }
        let waitingCaptureExists = openCaptures.contains { $0.status == .waiting || $0.status == .delegated }
        let proofMissingSummary = summaries.first { summary in
            summary.contexts.count >= 2 && evidenceByGoal[summary.goal.id, default: []].isEmpty
        }

        let reasonKind: TimeRealityBreakReasonKind
        let reasonDetail: String
        let visualState: AmbitionVisualState

        if mode == .empty {
            reasonKind = .lowData
            reasonDetail = "There is not enough Time pressure to review a change yet."
            visualState = .default
        } else if overloadedDays > 0 {
            reasonKind = .overloadedTimeShape
            reasonDetail = "\(overloadedDays) day\(overloadedDays == 1 ? "" : "s") are carrying more than Time can calmly explain."
            visualState = .warning
        } else if fragileDays > 0 {
            reasonKind = .lowCapacityFragileDay
            reasonDetail = "\(fragileDays) day\(fragileDays == 1 ? "" : "s") need recovery room before more work is added."
            visualState = .warning
        } else if openDays == 0 && summaries.isEmpty == false {
            reasonKind = .noRecoveryMargin
            reasonDetail = "Time is using every visible day, so one pocket should stay protected."
            visualState = .warning
        } else if let blockedSummary {
            reasonKind = .blockedGoal
            reasonDetail = "\(blockedSummary.goal.title) is still active while a planned step is blocked."
            visualState = .warning
        } else if waitingCaptureExists {
            reasonKind = .waitingOnPersonOrResource
            reasonDetail = "A waiting item is still influencing the week and should not silently become more work."
            visualState = .warning
        } else if missingGoalSummaries.isEmpty == false {
            reasonKind = .noNextStep
            reasonDetail = "\(missingGoalSummaries.count) active goal\(missingGoalSummaries.count == 1 ? "" : "s") need one believable next step or an intentional park."
            visualState = .warning
        } else if calendarAwareness.status == .denied {
            reasonKind = .calendarUnavailableOrDenied
            reasonDetail = "Manual shaping still works; calendar access is not required for recovery suggestions."
            visualState = .default
        } else if activeGoals.count > 5 {
            reasonKind = .tooManyActiveGoals
            reasonDetail = "\(activeGoals.count) active goals are asking Time to defend too many directions."
            visualState = .warning
        } else if let proofMissingSummary {
            reasonKind = .proofMissing
            reasonDetail = "\(proofMissingSummary.goal.title) has Time work but no proof yet, so the next step should be receipt-ready."
            visualState = .default
        } else if openCaptures.isEmpty == false {
            reasonKind = .urgentOutsideItem
            reasonDetail = "\(openCaptures.count) capture\(openCaptures.count == 1 ? "" : "s") should be absorbed, parked, or left outside Time with confirmation."
            visualState = .warning
        } else {
            reasonKind = .stillBelievable
            reasonDetail = "No visible disruption needs a Time change right now."
            visualState = .success
        }

        let suggestions = makeReflowSuggestions(
            reasonKind: reasonKind,
            activeGoals: activeGoals,
            missingGoalSummaries: missingGoalSummaries,
            openCaptures: openCaptures,
            pressuredGoalSummary: pressuredGoalSummary,
            blockedSummary: blockedSummary,
            calendarAwareness: calendarAwareness
        )
        let recommendedAdjustment = suggestions.first?.title ?? "Keep Time unchanged"

        return TimeRealityReflowState(
            title: reasonKind == .stillBelievable ? "Time is still believable" : "Reality changed",
            detail: reasonKind == .stillBelievable
                ? "Nothing changed yet, and no recovery action is needed."
                : "Adjust one thing, not everything. These are suggestions until you confirm a change.",
            reasonKind: reasonKind,
            reasonDetail: reasonDetail,
            recommendedAdjustment: recommendedAdjustment,
            noChangeCopy: "Nothing changed yet.",
            suggestions: suggestions,
            visualState: visualState
        )
    }

    func makeReflowSuggestions(
        reasonKind: TimeRealityBreakReasonKind,
        activeGoals: [Goal],
        missingGoalSummaries: [RepositoryBackedTimeService.GoalWeekSummary],
        openCaptures: [Capture],
        pressuredGoalSummary: RepositoryBackedTimeService.GoalWeekSummary?,
        blockedSummary: RepositoryBackedTimeService.GoalWeekSummary?,
        calendarAwareness: TimeCalendarAwarenessState
    ) -> [TimeReflowSuggestionState] {
        let targetGoal = pressuredGoalSummary?.goal ?? missingGoalSummaries.first?.goal ?? blockedSummary?.goal ?? activeGoals.first
        var suggestions: [TimeReflowSuggestionState] = []

        func append(
            _ kind: TimeReflowSuggestionKind,
            detail: String,
            impact: String,
            state: AmbitionVisualState,
            target: GoalRouteTarget? = targetGoal.map { GoalRouteTarget(goalID: $0.id) },
            timeRoute: TimeRouteTarget? = nil,
            interactionIntent: TimeInteractionIntent? = nil
        ) {
            suggestions.append(TimeReflowSuggestionState(
                id: "time-change-\(kind.rawValue)-\(suggestions.count)",
                kind: kind,
                title: kind.title,
                detail: detail,
                impactLabel: impact,
                boundary: reflowBoundary(for: kind, calendarAwareness: calendarAwareness),
                visualState: state,
                target: target,
                timeRoute: timeRoute,
                interactionIntent: interactionIntent
            ))
        }

        switch reasonKind {
        case .stillBelievable:
            append(.keepTimeUnchanged, detail: "The current week still has a believable path.", impact: "No change", state: .success, target: nil)
        case .lowData:
            append(.keepTimeUnchanged, detail: "Create or choose one Time item before reviewing a change.", impact: "No Time mutation", state: .default, target: nil)
        case .blockedGoal:
            append(.markWaiting, detail: "Keep the blocked work visible as waiting instead of adding more pressure.", impact: "Waiting state only after confirmation", state: .warning)
            append(.protectOneItem, detail: "Protect the one unblocked step that still matters.", impact: "Protects one item", state: .selected)
        case .waitingOnPersonOrResource:
            append(.markWaiting, detail: "Treat the dependency as waiting and keep the rest of Time calm.", impact: "Keeps follow-up explicit", state: .warning, target: nil, interactionIntent: .openGlobalCapture)
            append(.moveLocalActionLater, detail: "Reschedule only the local follow-up later if it is not the protected item.", impact: "Local suggestion only", state: .default, target: nil, interactionIntent: .openGlobalCapture)
        case .noNextStep:
            append(.protectOneItem, detail: "Choose one must-do and leave the rest outside today.", impact: "Protects one item", state: .selected)
            append(.parkGoal, detail: "Park the goal that has no believable next step yet.", impact: "Broad change needs confirmation", state: .warning)
        case .calendarUnavailableOrDenied:
            append(.protectOneItem, detail: "Pick the one item to protect manually.", impact: "Manual availability still works", state: .selected)
            append(.moveLocalActionLater, detail: "Reschedule a local action later while Calendar stays untouched.", impact: "Calendar untouched", state: .default)
        case .tooManyActiveGoals:
            append(.protectOneItem, detail: "Protect the one goal that must stay active now.", impact: "Narrows focus", state: .selected)
            append(.parkGoal, detail: "Park one active goal until it has real room.", impact: "Broad change needs confirmation", state: .warning)
        case .proofMissing:
            append(.shrinkAction, detail: "Make the next step small enough to leave proof.", impact: "Receipt-ready adjustment", state: .default)
            append(.splitAction, detail: "Split the work so the first part can close cleanly.", impact: "Local draft suggestion", state: .default)
        case .urgentOutsideItem:
            append(.deferGoalOrItem, detail: "Defer the item that does not belong in this Time window.", impact: "Needs confirmation", state: .warning, target: nil, interactionIntent: openCaptures.isEmpty ? nil : .openGlobalCapture)
            append(.dropOptionalWork, detail: "Drop optional work only after you confirm it is not needed.", impact: "Destructive choice gated", state: .warning, target: nil, interactionIntent: openCaptures.isEmpty ? nil : .openGlobalCapture)
        case .missedDay, .overloadedTimeShape, .noRecoveryMargin, .lowCapacityFragileDay:
            append(.protectOneItem, detail: "Keep one must-do defended before changing the rest.", impact: "Smallest useful adjustment", state: .selected)
            append(.shrinkAction, detail: targetGoal.map { "Make \($0.title)'s next step smaller." } ?? "Make the next step smaller.", impact: "Local suggestion only", state: .warning)
            append(.splitAction, detail: "Split the work so today carries only the first clear part.", impact: "Local draft suggestion", state: .default)
            append(.moveLocalActionLater, detail: "Reschedule one local action later without touching Calendar.", impact: "Needs confirmation before mutation", state: .default)
            append(.deferGoalOrItem, detail: "Defer the lower-priority item that no longer fits.", impact: "Broad change needs confirmation", state: .warning)
            append(.dropOptionalWork, detail: "Drop only optional work, and only after confirmation.", impact: "Destructive choice gated", state: .warning)
            append(.recoverRest, detail: "Protect recovery or rest as part of Time.", impact: "No shame recovery", state: .success, target: nil)
        }

        if reasonKind != .stillBelievable && suggestions.contains(where: { $0.kind == .askForConfirmation }) == false {
            append(.askForConfirmation, detail: "Confirm before applying any wide Time or calendar-impacting change.", impact: "Nothing changes until confirmed", state: .warning, target: nil)
        }

        return Array(suggestions.prefix(8))
    }

    func makeRecoveryGradient(
        reflow: TimeRealityReflowState,
        calendarAwareness: TimeCalendarAwarenessState
    ) -> TimeRecoveryGradientState {
        let kinds: [TimeReflowSuggestionKind] = [
            .protectOneItem,
            .shrinkAction,
            .splitAction,
            .moveLocalActionLater,
            .deferGoalOrItem,
            .dropOptionalWork,
            .recoverRest
        ]
        let options = kinds.enumerated().map { index, kind in
            TimeRecoveryGradientOptionState(
                id: "gradient-\(kind.rawValue)",
                order: index,
                kind: kind,
                title: kind.title,
                detail: gradientDetail(for: kind),
                boundary: reflowBoundary(for: kind, calendarAwareness: calendarAwareness),
                visualState: kind == .protectOneItem ? .selected : kind == .recoverRest ? .success : .default
            )
        }

        return TimeRecoveryGradientState(
            title: "Recovery options",
            detail: reflow.reasonKind == .stillBelievable
                ? "No recovery is needed, but the order stays ready if reality changes."
                : "Start with the least disruptive option that still makes Time believable.",
            options: options
        )
    }

    func makeSaveTheDay(
        reflow: TimeRealityReflowState,
        weekDays: [TimeElasticWeekDayState],
        missingGoalSummaries: [RepositoryBackedTimeService.GoalWeekSummary],
        pressuredGoalSummary: RepositoryBackedTimeService.GoalWeekSummary?,
        openCaptures: [Capture]
    ) -> TimeSaveTheDayState {
        let protected = pressuredGoalSummary?.contexts.first?.step.title
            ?? pressuredGoalSummary?.goal.title
            ?? weekDays.flatMap(\.blocks).first(where: { $0.kind == .protected || $0.kind == .fixed })?.title
            ?? missingGoalSummaries.first?.goal.title
            ?? "One must-do"
        let adjustment = reflow.suggestions.first { suggestion in
            [.shrinkAction, .moveLocalActionLater, .dropOptionalWork, .deferGoalOrItem].contains(suggestion.kind)
        }?.title ?? "Keep Time unchanged"
        let question = openCaptures.isEmpty && missingGoalSummaries.isEmpty
            ? nil
            : "What is the one thing that still needs protection?"

        return TimeSaveTheDayState(
            title: "Save the Day in Time",
            detail: "Time handles the deeper recovery shape without changing anything for you.",
            oneQuestion: question,
            protectedItem: protected,
            adjustment: adjustment,
            recoveryExplanation: reflow.reasonKind == .stillBelievable
                ? "No rescue is needed; keep recovery room visible."
                : "Recovery works by protecting one thing, reducing one thing, and leaving the rest unchanged until you confirm.",
            boundary: "No silent rescheduling. Calendar stays untouched. Nothing changed yet.",
            visualState: reflow.visualState
        )
    }

}
