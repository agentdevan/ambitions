import AmbitionsDesignSystem
import Foundation

extension TodayExecutionProjector {
    func deeperSections(_ input: TodayExecutionProjectionInput) -> [TodayExecutionDeepDiveState] {
        let pressureRows = [
            priorityPanel(input),
            waitingPanel(input),
        ]
        let recoveryRows = recoveryDetailPanels(input)
        return [
            TodayExecutionDeepDiveState(id: "today2.deep.priority", title: "Priority reality", rows: pressureRows),
            TodayExecutionDeepDiveState(id: "today2.deep.recovery", title: "Recovery details", rows: recoveryRows),
        ].filter { $0.rows.isEmpty == false }
    }

    func capturePanel(_ input: TodayExecutionProjectionInput) -> TodayExecutionPanelState {
        let level = input.nowState.captureUrgency.level
        return TodayExecutionPanelState(
            id: "today2.capture",
            kind: .capture,
            title: input.nowState.captureUrgency.level == .none ? "Capture is clear" : "Capture pressure",
            subtitle: input.nowState.captureUrgency.summary.todayShortSentence,
            value: pressureLabel(level),
            semanticState: level == .none ? .trust : .capture,
            action: input.legacySupport.quickCaptureAction ?? TodayInlineAction(kind: .quickLog, title: "Open Capture", systemImage: "tray.and.arrow.down", state: .selected, target: TodayActionTarget()),
            explanation: nil
        )
    }

    func timePanel(_ input: TodayExecutionProjectionInput) -> TodayExecutionPanelState {
        let summary = input.realitySnapshot?.availability.summary ?? input.nowState.schedulePressure.summary
        let calendarLine = input.realitySnapshot?.calendarContext?.hasCalendarReadAccess == true
            ? "Calendar-aware and local."
            : "Time works without calendar access."
        return TodayExecutionPanelState(
            id: "today2.time",
            kind: .time,
            title: timeTitle(input.nowState.schedulePressure.level),
            subtitle: "\(summary.todayShortSentence) \(calendarLine)",
            value: pressureLabel(input.nowState.schedulePressure.level),
            semanticState: .calendarDerived,
            action: openTimeAction(),
            explanation: nil
        )
    }

    func calendarSourceLabel(_ input: TodayExecutionProjectionInput) -> String {
        if input.realitySnapshot?.calendarContext?.hasCalendarReadAccess == true {
            return "From your calendar"
        }
        if input.realitySnapshot?.scheduledBlocks.isEmpty == false {
            return "Created in Ambitions"
        }
        return "Based on your Time"
    }

    func oneStepGoalSubtitle(_ summary: OneStepGoalSummary) -> String {
        [
            summary.timingLabel,
            summary.linkedActiveGoalCount > 0 ? "\(summary.linkedActiveGoalCount) linked goal\(summary.linkedActiveGoalCount == 1 ? "" : "s")" : nil,
            summary.suggestedNextAction
        ].compactMap { $0 }.joined(separator: " · ").todayShortSentence
    }

    func oneStepGoalSemanticState(_ status: OneStepGoalStatus) -> AmbitionSemanticState {
        switch status {
        case .today, .ready:
            return .focus
        case .scheduled:
            return .calendarDerived
        case .waiting:
            return .waiting
        case .reviewLater, .parked:
            return .trust
        case .completed:
            return .success
        case .archived:
            return .review
        }
    }

    func priorityPanel(_ input: TodayExecutionProjectionInput) -> TodayExecutionPanelState {
        let active = input.nowState.activeGoalPressure.count
        let passive = input.nowState.passiveGoalPressure.count
        return TodayExecutionPanelState(
            id: "today2.priority",
            kind: .priority,
            title: "Active balance",
            subtitle: "Active work stays ahead.",
            value: "\(active) active / \(passive) passive",
            semanticState: input.nowState.priorityPressure.overallPressure == .none ? .trust : .protected,
            action: nil,
            explanation: TodayExplanationAffordanceState(id: "today2.priority.why", title: "Why?", summary: input.nowState.priorityPressure.summary.todayShortSentence, explanationID: input.nowState.nextActionExplanationID, state: .selected)
        )
    }

    func waitingPanel(_ input: TodayExecutionProjectionInput) -> TodayExecutionPanelState {
        TodayExecutionPanelState(
            id: "today2.waiting",
            kind: .waiting,
            title: "Waiting and blocked",
            subtitle: input.nowState.blockersWaiting.summary.todayShortSentence,
            value: "\(input.nowState.blockersWaiting.waitingCount) waiting / \(input.nowState.blockersWaiting.blockedCount) blocked",
            semanticState: .waiting,
            action: nil,
            explanation: nil
        )
    }

    func recoveryDetailPanels(_ input: TodayExecutionProjectionInput) -> [TodayExecutionPanelState] {
        var protected = input.resilienceAssessment.protectedHighPriorityWork.prefix(1).map {
            TodayExecutionPanelState(id: "today2.protected.\($0.id)", kind: .recovery, title: "Kept in view", subtitle: $0.summary.todayShortSentence, value: $0.title.shortened(maxLength: 24), semanticState: .protected, action: openTimeAction(), explanation: nil)
        }
        if protected.isEmpty, input.nowState.deadlinePressure.level != .none {
            protected = [
                TodayExecutionPanelState(
                    id: "today2.protected.deadline",
                    kind: .recovery,
                    title: "Kept in view",
                    subtitle: input.nowState.deadlinePressure.summary.todayShortSentence,
                    value: pressureLabel(input.nowState.deadlinePressure.level),
                    semanticState: .protected,
                    action: openTimeAction(),
                    explanation: nil
                ),
            ]
        }
        let passive = input.resilienceAssessment.passiveWorkDeferredCalmly.prefix(1).map {
            TodayExecutionPanelState(id: "today2.passive.\($0.id)", kind: .priority, title: "Can wait", subtitle: $0.summary.todayShortSentence, value: $0.title.shortened(maxLength: 24), semanticState: .trust, action: nil, explanation: nil)
        }
        let waiting = input.resilienceAssessment.waitingOrBlockedRemovedFromPressure.prefix(1).map {
            TodayExecutionPanelState(id: "today2.waiting.\($0.id)", kind: .waiting, title: "Waiting", subtitle: $0.summary.todayShortSentence, value: $0.title.shortened(maxLength: 24), semanticState: .waiting, action: nil, explanation: nil)
        }
        return protected + passive + waiting
    }

    func emptyGuidance(_ input: TodayExecutionProjectionInput) -> TodayExecutionPanelState {
        TodayExecutionPanelState(
            id: "today2.empty.guidance",
            kind: .capture,
            title: "Start by capturing",
            subtitle: "Today will not pretend certainty.",
            value: "No false certainty",
            semanticState: .capture,
            action: input.legacySupport.quickCaptureAction,
            explanation: nil
        )
    }
}
