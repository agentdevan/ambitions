import Foundation

enum TimeRitualGoalSemantics {
    static func isRitualLike(goal: Goal, step: Step? = nil) -> Bool {
        if [.habit, .maintenance, .recovery].contains(goal.mode) {
            return true
        }
        if goal.timing.tempo == .ongoing {
            return true
        }
        guard let step else { return false }
        return step.isRepeatable || step.type == .recurringRoutine
    }

    static func preferredStep(in goal: Goal) -> Step? {
        let steps = goal.plan?.sections
            .flatMap(\.steps)
            .filter { $0.state != .cancelled } ?? []

        return steps.first(where: { $0.isRepeatable || $0.type == .recurringRoutine })
            ?? steps.first(where: { $0.state != .completed })
            ?? steps.first
    }

    static func cadenceDays(goal: Goal, step: Step?) -> Int {
        max(1, step?.timing.repeatEveryDays ?? goal.timing.repeatEveryDays ?? 1)
    }

    static func cadenceLabel(goal: Goal, step: Step?) -> String {
        let cadence = cadenceDays(goal: goal, step: step)
        if goal.mode == .delegatedSupport {
            return cadence == 1 ? "Support whenever it helps today" : "Support rhythm every \(cadence) days"
        }
        switch goal.timing.tempo {
        case .ongoing:
            return cadence == 1 ? "Daily rhythm" : "Every \(cadence) days"
        case .untimed:
            return "Untimed consistency"
        case .targetWindow:
            return goal.timing.targetBy.map { "Flexible until \($0)" } ?? "Flexible rhythm"
        case .deadlineBased:
            return goal.timing.dueAt.map { "Soft edge \($0)" } ?? "Time-aware rhythm"
        }
    }

    static func advancedTiming(from timing: GoalTiming, now: Date, cadenceDays: Int) -> GoalTiming {
        let nextDate = Calendar.current.date(byAdding: .day, value: cadenceDays, to: now) ?? now
        let nextValue = iso.string(from: nextDate)

        return GoalTiming(
            tempo: timing.tempo == .untimed ? .untimed : .ongoing,
            timingType: timing.tempo == .untimed ? .logWhenDone : .repeatWithinWindow,
            startsOn: timing.startsOn,
            dueAt: nil,
            targetBy: nil,
            windowStart: timing.windowStart,
            windowEnd: timing.windowEnd,
            suggestedNextAt: nextValue,
            repeatEveryDays: cadenceDays,
            progressReviewCadenceDays: timing.progressReviewCadenceDays
        )
    }

    static func minimumVersionText(for step: Step) -> String {
        step.actionability.fallbackMicroStep
    }

    private static var iso: ISO8601DateFormatter {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }
}
