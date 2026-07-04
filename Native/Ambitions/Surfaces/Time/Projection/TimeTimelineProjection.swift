import AmbitionsDesignSystem
import Foundation

extension RepositoryBackedTimeService {
    func makeTimelineStrip(
        goals: [Goal],
        weekContexts: [RepositoryBackedTimeService.StepContext],
        evidenceByGoal: [String: [ProgressEvidence]],
        now: Date
    ) -> TimeTimelineStripState {
        let activeItems = weekContexts.prefix(5).map { context in
            TimeTimelineItemState(
                id: "timeline-\(context.goal.id)-\(context.step.id)",
                title: context.goal.title,
                detail: context.step.title,
                timingLabel: context.timingLabel,
                sourceLabel: "Based on Time",
                kind: .active,
                visualState: context.visualState,
                target: GoalRouteTarget(goalID: context.goal.id)
            )
        }
        let previousItems = goals
            .filter { goalLifecycleState(goal: $0, evidence: evidenceByGoal[$0.id] ?? [], now: now) == .previous || $0.state == .completed }
            .prefix(2)
            .map { goal in
                TimeTimelineItemState(
                    id: "timeline-previous-\(goal.id)",
                    title: goal.title,
                    detail: "Kept outside current pressure.",
                    timingLabel: "Previous",
                    sourceLabel: "Created in Ambitions",
                    kind: .previous,
                    visualState: goal.state == .completed ? .success : .default,
                    target: GoalRouteTarget(goalID: goal.id)
                )
            }
        let futureItems = goals
            .filter { goalLifecycleState(goal: $0, evidence: evidenceByGoal[$0.id] ?? [], now: now) == .future }
            .prefix(2)
            .map { goal in
                TimeTimelineItemState(
                    id: "timeline-future-\(goal.id)",
                    title: goal.title,
                    detail: "Planned later, not part of this week's load.",
                    timingLabel: futureTimingLabel(for: goal, now: now),
                    sourceLabel: "Based on Time",
                    kind: .future,
                    visualState: .default,
                    target: GoalRouteTarget(goalID: goal.id)
                )
            }
        let outsideItems = goals
            .filter { [.paused, .archived].contains($0.state) }
            .prefix(2)
            .map { goal in
                TimeTimelineItemState(
                    id: "timeline-outside-\(goal.id)",
                    title: goal.title,
                    detail: goal.state == .paused ? "Parked outside current pressure." : "Closed or dropped outside Time.",
                    timingLabel: goal.state == .paused ? "Parked" : "Outside",
                    sourceLabel: "Created in Ambitions",
                    kind: .outside,
                    visualState: .default,
                    target: GoalRouteTarget(goalID: goal.id)
                )
            }
        let items = Array((previousItems + activeItems + futureItems + outsideItems).prefix(8))

        return TimeTimelineStripState(
            title: "Rich Timeline",
            subtitle: items.isEmpty
                ? "No goal step change is visible yet."
                : "A compact strip of previous, active, future, and outside pressure with local source labels.",
            items: items
        )
    }

    func makeOpportunityWindows(
        weekDays: [TimeElasticWeekDayState],
        missingGoalSummaries: [RepositoryBackedTimeService.GoalWeekSummary]
    ) -> TimeOpportunityWindowsState {
        let windows = weekDays.compactMap { day -> TimeOpportunityWindowItem? in
            guard let window = day.openWindow else { return nil }
            let modeLabel: String
            let title: String
            switch day.level {
            case .open:
                modeLabel = window.target == nil ? "Recovery" : "Focus"
                title = window.target == nil ? "Recovery window" : "Good window for one focused step"
            case .steady:
                modeLabel = "Follow-up"
                title = "Good for follow-up"
            case .tight:
                modeLabel = "Follow-up"
                title = "Better for light follow-up"
            case .fragile, .overloaded:
                return nil
            }
            return TimeOpportunityWindowItem(
                id: "window-\(day.id)",
                title: title,
                detail: window.detail,
                modeLabel: modeLabel,
                timingLabel: "\(day.weekdayLabel) \(day.dateLabel)",
                visualState: window.visualState,
                target: window.target
            )
        }

        let fallback: [TimeOpportunityWindowItem] = windows.isEmpty ? [
            TimeOpportunityWindowItem(
                id: "window-manual",
                title: missingGoalSummaries.isEmpty ? "Keep this light" : "Manual window needed",
                detail: missingGoalSummaries.isEmpty ? "No believable window is asking to be filled." : "Choose one small pocket manually before adding this goal to the week.",
                modeLabel: missingGoalSummaries.isEmpty ? "Recovery" : "Focus",
                timingLabel: "Manual",
                visualState: missingGoalSummaries.isEmpty ? .default : .warning,
                target: missingGoalSummaries.first.map { GoalRouteTarget(goalID: $0.goal.id) }
            )
        ] : []

        return TimeOpportunityWindowsState(
            title: "Opportunity windows",
            subtitle: "Windows are work modes, not a calendar grid.",
            windows: Array((windows + fallback).prefix(4))
        )
    }

}
