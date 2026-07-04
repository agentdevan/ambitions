import AmbitionsDesignSystem
import Foundation

extension RepositoryBackedTimeService {
    func makeDecisionDebt(
        activeGoals: [Goal],
        summaries: [RepositoryBackedTimeService.GoalWeekSummary],
        missingGoalSummaries: [RepositoryBackedTimeService.GoalWeekSummary],
        weekDays: [TimeElasticWeekDayState],
        openCaptures: [Capture],
        blockedDraftCount: Int,
        clarificationDraftCount: Int,
        evidenceByGoal: [String: [ProgressEvidence]],
        calendarAwareness: TimeCalendarAwarenessState
    ) -> TimeDecisionDebtState {
        var items: [TimeDecisionItemState] = []

        items += missingGoalSummaries.prefix(2).map { summary in
            TimeDecisionItemState(
                id: "decision-next-step-\(summary.goal.id)",
                title: "Needs a decision",
                detail: "\(summary.goal.title) is active but not represented in this Time window.",
                suggestion: "Give it one next step, park it, or leave it intentionally outside today.",
                visualState: .warning,
                target: GoalRouteTarget(goalID: summary.goal.id),
                timeRoute: nil
            )
        }

        if activeGoals.count > 5 {
            items.append(TimeDecisionItemState(
                id: "decision-active-goals",
                title: "Too many active goals",
                detail: "\(activeGoals.count) active goals are competing for the same Time window.",
                suggestion: "Protect the few that matter now and park the rest.",
                visualState: .warning,
                target: nil,
                timeRoute: nil
            ))
        }

        if openCaptures.contains(where: { $0.status == .waiting || $0.status == .delegated }) {
            items.append(TimeDecisionItemState(
                id: "decision-waiting-captures",
                title: "Waiting item needs follow-up",
                detail: "A waiting or delegated capture is still influencing the week.",
                suggestion: "Follow up, attach it, or keep it outside Time.",
                visualState: .warning,
                target: nil,
                timeRoute: nil,
                interactionIntent: .openGlobalCapture
            ))
        }

        if blockedDraftCount + clarificationDraftCount > 0 {
            items.append(TimeDecisionItemState(
                id: "decision-clarify-drafts",
                title: "Clarify before shaping more",
                detail: "\(blockedDraftCount + clarificationDraftCount) draft\(blockedDraftCount + clarificationDraftCount == 1 ? "" : "s") need an answer before they become real Time pressure.",
                suggestion: "Resolve the smallest missing answer first.",
                visualState: .warning,
                target: nil,
                timeRoute: nil,
                interactionIntent: .openGlobalCapture
            ))
        }

        if let noProof = summaries.first(where: { evidenceByGoal[$0.goal.id, default: []].isEmpty && $0.contexts.isEmpty == false }) {
            items.append(TimeDecisionItemState(
                id: "decision-proof-\(noProof.goal.id)",
                title: "Proof is thin",
                detail: "\(noProof.goal.title) has work in Time but no proof recorded yet.",
                suggestion: "Keep the next step small enough to leave evidence.",
                visualState: .default,
                target: GoalRouteTarget(goalID: noProof.goal.id),
                timeRoute: nil
            ))
        }

        if calendarAwareness.canRequestCalendarRead && calendarAwareness.status != .calendarAware {
            items.append(TimeDecisionItemState(
                id: "decision-calendar-boundary",
                title: "Calendar boundary is optional",
                detail: "Manual availability still works; calendar-derived windows require your action.",
                suggestion: "Use manual availability or let Time find local open windows.",
                visualState: .default,
                target: nil,
                timeRoute: nil
            ))
        }

        if weekDays.contains(where: { $0.level == .overloaded }) {
            items.append(TimeDecisionItemState(
                id: "decision-overloaded-week",
                title: "Clarify overloaded week",
                detail: "At least one day is carrying too much to stay believable.",
                suggestion: "Adjust one thing, not everything.",
                visualState: .warning,
                target: nil,
                timeRoute: nil
            ))
        }

        return TimeDecisionDebtState(
            title: "Needs a decision",
            subtitle: items.isEmpty ? "No unresolved Time decision is loud right now." : "Small decisions prevent Time from becoming a dense task manager.",
            items: Array(items.prefix(5))
        )
    }

    func makeConflictCourt(
        activeGoals: [Goal],
        summaries: [RepositoryBackedTimeService.GoalWeekSummary],
        weekDays: [TimeElasticWeekDayState],
        openCaptures: [Capture],
        evidenceByGoal: [String: [ProgressEvidence]]
    ) -> TimeConflictCourtState {
        var conflicts: [TimeDecisionItemState] = []
        let protectedSummaries = summaries.filter { summary in
            summary.contexts.contains(where: { $0.blockKind == .protected || $0.blockKind == .fixed })
        }

        if protectedSummaries.count >= 2,
           let first = protectedSummaries.first {
            conflicts.append(TimeDecisionItemState(
                id: "conflict-protected-goals",
                title: "Important goals are competing",
                detail: "\(protectedSummaries.count) important goals are asking the same week to hold them.",
                suggestion: "Choose the one that must stay protected and let the other flex.",
                visualState: .warning,
                target: GoalRouteTarget(goalID: first.goal.id),
                timeRoute: nil
            ))
        }

        if let blocked = summaries.first(where: { $0.contexts.contains(where: { $0.step.state == .blocked }) }) {
            conflicts.append(TimeDecisionItemState(
                id: "conflict-blocked-\(blocked.goal.id)",
                title: "Blocked goal is still active",
                detail: "\(blocked.goal.title) has blocked work inside the current Time shape.",
                suggestion: "Treat this as waiting or unblock it before protecting more time.",
                visualState: .warning,
                target: GoalRouteTarget(goalID: blocked.goal.id),
                timeRoute: nil
            ))
        }

        if activeGoals.count > 5 {
            conflicts.append(TimeDecisionItemState(
                id: "conflict-active-count",
                title: "Active goals are crowded",
                detail: "\(activeGoals.count) active goals make the week negotiate too many directions.",
                suggestion: "Protect fewer goals so Time remains believable.",
                visualState: .warning,
                target: nil,
                timeRoute: nil
            ))
        }

        if openCaptures.contains(where: { $0.status == .waiting || $0.status == .delegated }) && summaries.isEmpty == false {
            conflicts.append(TimeDecisionItemState(
                id: "conflict-commitment-goal",
                title: "Follow-up is competing with goal work",
                detail: "A waiting commitment and current goal work both want attention.",
                suggestion: "Follow up first if it unlocks the step; otherwise keep it outside today.",
                visualState: .warning,
                target: nil,
                timeRoute: nil,
                interactionIntent: .openGlobalCapture
            ))
        }

        if let thinProof = summaries.first(where: { evidenceByGoal[$0.goal.id, default: []].isEmpty && $0.contexts.count >= 2 }) {
            conflicts.append(TimeDecisionItemState(
                id: "conflict-proof-\(thinProof.goal.id)",
                title: "Work is moving without proof",
                detail: "\(thinProof.goal.title) has multiple Time blocks but no proof yet.",
                suggestion: "Make the next step receipt-friendly.",
                visualState: .default,
                target: GoalRouteTarget(goalID: thinProof.goal.id),
                timeRoute: nil
            ))
        }

        if weekDays.filter({ $0.level == .open }).isEmpty && summaries.isEmpty == false {
            conflicts.append(TimeDecisionItemState(
                id: "conflict-recovery-margin",
                title: "No recovery margin",
                detail: "Time is using every visible day.",
                suggestion: "Protect one pocket as recovery room.",
                visualState: .warning,
                target: nil,
                timeRoute: nil
            ))
        }

        return TimeConflictCourtState(
            title: "Conflicts to negotiate",
            subtitle: conflicts.isEmpty ? "No visible conflict needs court right now." : "These are negotiation items, not alarms.",
            conflicts: Array(conflicts.prefix(4))
        )
    }

}
