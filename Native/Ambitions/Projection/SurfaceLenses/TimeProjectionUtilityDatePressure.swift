import AmbitionsDesignSystem
import Foundation

extension RepositoryBackedTimeService {
    func futureTimingLabel(for goal: Goal, now: Date) -> String {
        if hasFutureStart(goal.timing, now: now), let startsOn = goal.timing.startsOn {
            return "Starts \(shortDate(startsOn))"
        }
        if let targetBy = goal.timing.targetBy {
            return "Later \(shortDate(targetBy))"
        }
        if let dueAt = goal.timing.dueAt {
            return "Due later \(shortDate(dueAt))"
        }
        return "Future"
    }

    func postureState(
        evaluations: [PlanningEvaluation],
        blockedCount: Int,
        clarificationCount: Int,
        openCaptureCount: Int,
        weekDays: [TimeElasticWeekDayState],
        mode: TimeSurfaceMode
    ) -> TimeBelievabilityState {
        guard mode == .active else {
            return TimeBelievabilityState(
                title: "The week is open",
                detail: "No active goals or captures are pressing for structure yet.",
                label: "Open",
                supportLabel: "This is a real state, not missing data.",
                visualState: .default
            )
        }

        if blockedCount + clarificationCount > 0 {
            return TimeBelievabilityState(
                title: "The week is waiting on reality",
                detail: "Open questions or blockers make the current shape less believable than it looks.",
                label: "Needs clarity",
                supportLabel: "Clarify before adding more commitment.",
                visualState: .warning
            )
        }

        if weekDays.contains(where: { $0.level == .overloaded }) {
            return TimeBelievabilityState(
                title: "The week is overloaded",
                detail: "At least one day is carrying more than the current structure can explain calmly.",
                label: "Overloaded",
                supportLabel: "Lighten the loudest lane first.",
                visualState: .warning
            )
        }

        if evaluations.contains(where: { $0.feasibilityLevel == .notBelievable || $0.feasibilityLevel == .fragile }) {
            return TimeBelievabilityState(
                title: "The week is fragile",
                detail: "Existing fit evaluations are warning that current commitments need gentler scope.",
                label: "Fragile",
                supportLabel: "Protect what is believable and soften the rest.",
                visualState: .warning
            )
        }

        if evaluations.contains(where: { $0.feasibilityLevel == .tight }) || openCaptureCount > 0 || weekDays.contains(where: { $0.level == .tight }) {
            return TimeBelievabilityState(
                title: "The week is believable but tight",
                detail: "The structure can hold, but room is already limited and pressure is visible.",
                label: "Tight",
                supportLabel: "Patch with restraint instead of adding density.",
                visualState: .selected
            )
        }

        return TimeBelievabilityState(
            title: "The week looks believable",
            detail: "Visible work, protected time, and open room are currently in balance.",
            label: "Believable",
            supportLabel: "You can shape calmly because the week already has a coherent backbone.",
            visualState: .success
        )
    }

    func timeframeLabel(now: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.setLocalizedDateFormatFromTemplate("MMM d")
        let start = calendar.startOfDay(for: now)
        let end = calendar.date(byAdding: .day, value: 6, to: start) ?? start
        return "\(formatter.string(from: start))-\(formatter.string(from: end))"
    }

    func timingLabel(for timing: GoalTiming) -> String {
        if let dueAt = timing.dueAt {
            return "Due \(shortDate(dueAt))"
        }
        if let targetBy = timing.targetBy {
            return "Protect \(shortDate(targetBy))"
        }
        if let suggestedNextAt = timing.suggestedNextAt {
            return "Flex \(shortDate(suggestedNextAt))"
        }
        if let repeatEveryDays = timing.repeatEveryDays {
            return "Every \(repeatEveryDays)d"
        }
        return "Flexible"
    }

    func plannedDate(for timing: GoalTiming) -> Date? {
        parseDate(timing.dueAt ?? timing.targetBy ?? timing.suggestedNextAt ?? timing.startsOn)
    }

    func blockKind(for timing: GoalTiming) -> TimeWeekBlockKind {
        if timing.dueAt != nil {
            return .fixed
        }
        if timing.targetBy != nil {
            return .protected
        }
        return .flexible
    }

    func blockVisualState(step: Step, evaluation: PlanningEvaluation?, frictionCount: Int) -> AmbitionVisualState {
        if step.state == .blocked || frictionCount > 0 {
            return .warning
        }
        if evaluation?.feasibilityLevel == .fragile || evaluation?.feasibilityLevel == .notBelievable {
            return .warning
        }
        if evaluation?.feasibilityLevel == .tight {
            return .selected
        }
        return .default
    }

    func loadWeight(for kind: TimeWeekBlockKind, visualState: AmbitionVisualState) -> Double {
        let base: Double = switch kind {
        case .fixed: 1.35
        case .protected: 1.0
        case .flexible: 0.72
        }
        if visualState == .warning {
            return base + 0.25
        }
        if visualState == .selected {
            return base + 0.1
        }
        return base
    }

    func dayIntensity(for level: TimeWeekPressureLevel, blockCount: Int) -> Double {
        let base: Double = switch level {
        case .open: 0.48
        case .steady: 0.66
        case .tight: 0.84
        case .fragile: 0.92
        case .overloaded: 1.0
        }
        return min(base + (Double(blockCount) * 0.04), 1.0)
    }

    func roomLabel(for level: TimeWeekPressureLevel, remainingCapacity: Double, contextCount: Int) -> String {
        switch level {
        case .open:
            return contextCount == 0 ? "Open day" : "Wide room"
        case .steady:
            return remainingCapacity > 1.0 ? "Room remains" : "Steady load"
        case .tight:
            return "Little room left"
        case .fragile:
            return "Fragile room"
        case .overloaded:
            return "Needs relief"
        }
    }

    func dayHighlight(
        level: TimeWeekPressureLevel,
        contexts: [RepositoryBackedTimeService.StepContext],
        suggestedSummary: RepositoryBackedTimeService.GoalWeekSummary?
    ) -> String {
        if level == .overloaded {
            return "Pressure is stacking here."
        }
        if level == .fragile {
            return "This day needs recovery room."
        }
        if level == .tight {
            return "This day needs protected edges."
        }
        if let first = contexts.first {
            return "\(first.goal.title) is anchoring this day."
        }
        if let suggestedSummary {
            return "\(suggestedSummary.goal.title) could fit here."
        }
        return "Keep the room visible."
    }

    func pressureRank(for level: TimeWeekPressureLevel) -> Int {
        switch level {
        case .open: 0
        case .steady: 1
        case .tight: 2
        case .fragile: 3
        case .overloaded: 4
        }
    }

    func pressureScore(for summary: RepositoryBackedTimeService.GoalWeekSummary) -> Double {
        var score = Double(summary.frictionCount * 3)
        if summary.contexts.isEmpty {
            score += 5
        }
        switch summary.evaluation?.feasibilityLevel {
        case .notBelievable:
            score += 5
        case .fragile:
            score += 4
        case .tight:
            score += 2
        default:
            break
        }
        score += Double(summary.contexts.count)
        return score
    }

    func shortDate(_ value: String) -> String {
        guard let date = parseDate(value) else { return value }
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.setLocalizedDateFormatFromTemplate("MMM d")
        return formatter.string(from: date)
    }

    func parseDate(_ value: String?) -> Date? {
        guard let value else { return nil }
        if let date = ISO8601DateFormatter().date(from: value) {
            return date
        }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: value)
    }

    func isFriction(_ event: GoalFeedbackEvent) -> Bool {
        switch event {
        case .skipped, .confused, .tooBig, .notRelevant, .askedForSmallerVersion:
            return true
        default:
            return false
        }
    }

    func shapingRank(for state: AmbitionVisualState) -> Int {
        switch state {
        case .warning:
            return 0
        case .selected:
            return 1
        case .pressed, .loading:
            return 2
        case .default:
            return 3
        case .disabled:
            return 4
        case .success:
            return 5
        case .celebration:
            return 6
        }
    }

}
