import AmbitionsDesignSystem
import Foundation

extension RepositoryBackedTimeService {
    func makeTreaty(
        posture: TimeBelievabilityState,
        capacityEnvelope: TimeCapacityEnvelopeState,
        calendarBoundary: TimeCalendarBoundaryContractState,
        weekContexts: [RepositoryBackedTimeService.StepContext],
        missingGoalCount: Int,
        openCaptureCount: Int,
        weekDays: [TimeElasticWeekDayState],
        primaryAction: TimeWeekPrimaryAction
    ) -> TimeTreatyState {
        let protectedCount = weekContexts.filter { $0.blockKind == .protected || $0.blockKind == .fixed }.count
        let flexibleCount = weekContexts.filter { $0.blockKind == .flexible }.count
        let openDays = weekDays.filter { $0.level == .open }.count
        let overloadedDays = weekDays.filter { $0.level == .overloaded || $0.level == .fragile }.count

        return TimeTreatyState(
            title: "This week's agreement",
            summary: posture.visualState == .warning
                ? "This week can still be kind, but it needs one honest adjustment before more work is added."
                : "This week is a calm agreement between protected work, flexible work, and room you are allowed to keep.",
            protectedWork: protectedCount == 0
                ? "Nothing is marked as protected yet."
                : "\(protectedCount) protected or fixed item\(protectedCount == 1 ? "" : "s") should stay defended.",
            flexibleWork: flexibleCount == 0
                ? "No flexible work is asking for placement right now."
                : "\(flexibleCount) flexible item\(flexibleCount == 1 ? "" : "s") can bend around real life.",
            notTodayWork: missingGoalCount + openCaptureCount == 0
                ? "Nothing obvious needs to be kept outside today."
                : "\(missingGoalCount + openCaptureCount) item\(missingGoalCount + openCaptureCount == 1 ? "" : "s") should wait, clarify, or stay outside today's pressure.",
            recoveryAllowance: overloadedDays == 0 && openDays > 0
                ? "\(openDays) open day\(openDays == 1 ? "" : "s") keep recovery room visible."
                : "Recovery room is thin; adjust one thing, not everything.",
            calendarBoundary: calendarBoundary.manualFallback,
            primaryActionTitle: primaryAction.title,
            primaryActionSubtitle: primaryAction.subtitle,
            visualState: capacityEnvelope.visualState
        )
    }

    func makeCapacityEnvelope(
        posture: TimeBelievabilityState,
        weekDays: [TimeElasticWeekDayState],
        visibleBlockCount: Int,
        protectedCount: Int,
        missingGoalCount: Int,
        openCaptureCount: Int,
        calendarAwareness: TimeCalendarAwarenessState
    ) -> TimeCapacityEnvelopeState {
        let overloadedDays = weekDays.filter { $0.level == .overloaded }.count
        let tightDays = weekDays.filter { $0.level == .tight }.count
        let openDays = weekDays.filter { $0.level == .open }.count
        let fragile = posture.label == "Fragile" || missingGoalCount >= 2
        let level: (String, AmbitionVisualState)

        if overloadedDays > 0 || visibleBlockCount >= 12 {
            level = ("Overloaded", .warning)
        } else if fragile {
            level = ("Fragile", .warning)
        } else if tightDays >= 2 || openCaptureCount >= 3 {
            level = ("Tight", .warning)
        } else if visibleBlockCount >= 4 || protectedCount > 0 {
            level = ("Steady", .selected)
        } else {
            level = ("Light", .success)
        }

        let calendarCopy = calendarAwareness.status == .calendarAware
            ? "Calendar-derived busy time is informing open windows locally."
            : "Manual availability is enough to keep shaping Time."

        return TimeCapacityEnvelopeState(
            title: "Capacity envelope",
            detail: "\(calendarCopy) The envelope stays qualitative so it does not pretend to know more than the data shows.",
            label: level.0,
            availableCapacity: openDays == 0 ? "No obvious open day" : "\(openDays) open day\(openDays == 1 ? "" : "s")",
            pressure: overloadedDays > 0 ? "Pressure is stacked" : tightDays > 0 ? "Pressure is visible" : "Pressure is readable",
            protectedFocus: protectedCount == 0 ? "Focus time is not explicit yet" : "\(protectedCount) important item\(protectedCount == 1 ? "" : "s")",
            recoveryMargin: openDays >= 2 ? "Recovery room exists" : openDays == 1 ? "Recovery room is narrow" : "Recovery room needs protection",
            visualState: level.1
        )
    }

    func makeGoalLifecycleRail(
        goals: [Goal],
        summaries: [RepositoryBackedTimeService.GoalWeekSummary],
        evidenceByGoal: [String: [ProgressEvidence]],
        now: Date
    ) -> TimeGoalLifecycleRailState {
        let states = goals.map { goalLifecycleState(goal: $0, evidence: evidenceByGoal[$0.id] ?? [], now: now) }
        let representedGoalIDs = Set(summaries.filter { $0.contexts.isEmpty == false }.map(\.goal.id))
        let sequence: [GoalPortfolioLifecycleState] = [.previous, .active, .future, .waiting, .blocked, .parked, .protected, .completed, .cancelledDropped]
        let segments = sequence.map { state in
            let count: Int
            if state == .active {
                count = states.filter { $0 == .active }.count + representedGoalIDs.count
            } else {
                count = states.filter { $0 == state }.count
            }
            return TimeGoalLifecycleRailSegment(
                lifecycleState: state,
                count: count,
                subtitle: lifecycleSubtitle(for: state, count: count)
            )
        }

        return TimeGoalLifecycleRailState(
            title: "What Time is carrying",
            subtitle: "Goals stay visible by lifecycle, including work that belongs outside this week's pressure.",
            segments: segments
        )
    }

}
