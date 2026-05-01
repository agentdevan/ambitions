import AmbitionsDesignSystem
import Foundation

enum PlanLifeSuiteShapeKind: String, Sendable, CaseIterable {
    case day = "day_shape"
    case week = "week_shape"
    case life = "life_shape"
}

struct PlanLifeSuiteShapeState: Identifiable, Sendable {
    let kind: PlanLifeSuiteShapeKind
    let title: String
    let question: String
    let summary: String
    let facts: [String]
    let sourceLabel: String
    let boundaryLabel: String
    let visualState: AmbitionVisualState

    var id: String { kind.rawValue }
}

struct PlanLifeSuiteState: Sendable {
    let title: String
    let subtitle: String
    let shapes: [PlanLifeSuiteShapeState]
    let calendarBoundaryLabel: String
    let manualFallbackLabel: String
    let trustLabel: String
}

struct PlanLifeSuiteProjector: Sendable {
    func project(
        weekDays: [PlanElasticWeekDayState],
        calendarAwareness: PlanCalendarAwarenessState,
        openCaptureCount: Int,
        activeGoalCount: Int,
        mode: PlanDashboardMode
    ) -> PlanLifeSuiteState {
        PlanLifeSuiteState(
            title: "Plan Life Suite",
            subtitle: "Does this hold together?",
            shapes: [
                dayShape(weekDays: weekDays),
                weekShape(weekDays: weekDays, openCaptureCount: openCaptureCount, mode: mode),
                lifeShape(activeGoalCount: activeGoalCount)
            ],
            calendarBoundaryLabel: calendarAwareness.canRequestCalendarRead ? "Calendar stays optional" : "Manual planning still works",
            manualFallbackLabel: "Manual fallback available",
            trustLabel: "No silent calendar changes"
        )
    }

    private func dayShape(weekDays: [PlanElasticWeekDayState]) -> PlanLifeSuiteShapeState {
        let today = weekDays.first
        return PlanLifeSuiteShapeState(
            kind: .day,
            title: "Day Shape",
            question: "What can this day honestly hold?",
            summary: today.map { "\($0.weekdayLabel) has \($0.roomLabel.lowercased()) and \($0.blocks.count) planned block\($0.blocks.count == 1 ? "" : "s")." }
                ?? "No day shape is loaded yet.",
            facts: dayShapeFacts(today),
            sourceLabel: "Based on your plan",
            boundaryLabel: "No silent replanning",
            visualState: today?.level.visualState ?? .default
        )
    }

    private func weekShape(weekDays: [PlanElasticWeekDayState], openCaptureCount: Int, mode: PlanDashboardMode) -> PlanLifeSuiteShapeState {
        let pressuredDays = weekDays.filter { [.tight, .fragile, .overloaded].contains($0.level) }.count
        let summary: String
        if mode == .empty {
            summary = "The week has room until goals, captures, or routines create real constraints."
        } else if pressuredDays > 0 {
            summary = "\(pressuredDays) day\((pressuredDays == 1) ? "" : "s") may need shaping before the week feels believable."
        } else {
            summary = "The week has visible room and no overloaded day in the current plan."
        }

        return PlanLifeSuiteShapeState(
            kind: .week,
            title: "Week Shape",
            question: "Does the week still fit?",
            summary: openCaptureCount > 0
                ? "\(summary) \(openCaptureCount) capture\((openCaptureCount == 1) ? "" : "s") still need a place."
                : summary,
            facts: weekShapeFacts(
                weekDays: weekDays,
                pressuredDays: pressuredDays,
                openCaptureCount: openCaptureCount
            ),
            sourceLabel: "Based on goals and captures",
            boundaryLabel: "Suggestions require confirmation",
            visualState: pressuredDays > 0 ? .warning : .selected
        )
    }

    private func lifeShape(activeGoalCount: Int) -> PlanLifeSuiteShapeState {
        PlanLifeSuiteShapeState(
            kind: .life,
            title: "Life Shape",
            question: "Is the plan still pointed at the life you are building?",
            summary: activeGoalCount == 0
                ? "Life Shape is quiet until active goals give Plan something to coordinate."
                : "\(activeGoalCount) active goal\((activeGoalCount == 1) ? "" : "s") shape the current life plan.",
            facts: [
                activeGoalCount == 0 ? "No active goals shaping life view yet." : "\(activeGoalCount) active goal\((activeGoalCount == 1) ? "" : "s") included.",
                "Life Shape stays inside Plan."
            ],
            sourceLabel: "Based on active goals",
            boundaryLabel: "Life view, broader than time slots",
            visualState: activeGoalCount == 0 ? .default : .selected
        )
    }

    private func dayShapeFacts(_ today: PlanElasticWeekDayState?) -> [String] {
        guard let today else {
            return ["Manual shaping is available.", "Nothing moves without review."]
        }
        return [
            today.capacityLabel,
            today.openWindow?.title ?? "No open window is suggested yet.",
            today.blocks.isEmpty ? "No planned blocks attached." : "\(today.blocks.count) planned block\((today.blocks.count == 1) ? "" : "s") attached."
        ]
    }

    private func weekShapeFacts(
        weekDays: [PlanElasticWeekDayState],
        pressuredDays: Int,
        openCaptureCount: Int
    ) -> [String] {
        [
            "\(pressuredDays) pressured day\((pressuredDays == 1) ? "" : "s") visible.",
            openCaptureCount == 1 ? "1 capture needs a place." : "\(openCaptureCount) captures need a place.",
            "\(weekDays.count) day\((weekDays.count == 1) ? "" : "s") included in this week."
        ]
    }
}
