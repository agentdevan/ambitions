import AmbitionsDesignSystem
import Foundation

extension TimeLifeSuiteProjector {
    func dayShape(
        weekDays: [TimeElasticWeekDayState],
        calendarAwareness: TimeCalendarAwarenessState
    ) -> TimeLifeSuiteShapeState {
        let today = weekDays.first
        let protectedTime = today?.blocks.filter { $0.kind == .protected || $0.kind == .fixed }.count ?? 0
        let capacityLabel = today.map { $0.capacityLabel } ?? "Manual shaping available"
        return TimeLifeSuiteShapeState(
            kind: .day,
            title: "Day Shape",
            question: "What can this day honestly hold?",
            summary: today.map { "\($0.weekdayLabel) has \($0.roomLabel.lowercased()) and \($0.blocks.count) fixed point\($0.blocks.count == 1 ? "" : "s")." }
                ?? "No day shape is loaded yet.",
            facts: dayShapeFacts(today),
            sourceLabel: "Based on Time",
            boundaryLabel: "No silent Time change",
            schedulePressureLabel: today.map { "Schedule pressure: \($0.roomLabel.lowercased())." } ?? "Schedule pressure: no day is loaded yet.",
            protectedTimeLabel: protectedTime == 0
                ? "Protected time: none marked in the current day."
                : "Protected time: \(protectedTime) fixed or protected item\(protectedTime == 1 ? "" : "s") stay visible.",
            capacityLabel: "Capacity: \(capacityLabel).",
            proofOpportunityLabel: today == nil
                ? "Proof opportunity: no day is loaded yet."
                : "Proof opportunity: one clear receipt can explain the day without changing it.",
            provenanceLabel: "Provenance: based on Time and today's visible blocks.",
            privacyLabel: calendarAwareness.canRequestCalendarRead
                ? "Privacy: calendar access stays optional and local."
                : "Privacy: this view stays local-only.",
            visualState: today?.level.visualState ?? .default
        )
    }

    func weekShape(
        weekDays: [TimeElasticWeekDayState],
        openCaptureCount: Int,
        activeGoalCount: Int,
        calendarAwareness: TimeCalendarAwarenessState,
        mode: TimeSurfaceMode
    ) -> TimeLifeSuiteShapeState {
        let pressuredDays = weekDays.filter { [.tight, .fragile, .overloaded].contains($0.level) }.count
        let openDays = weekDays.filter { $0.level == .open }.count
        let protectedDays = weekDays.flatMap(\.blocks).filter { $0.kind == .protected || $0.kind == .fixed }.count
        let summary: String
        if mode == .empty {
            summary = "The week has room until goals, captures, or routines create real constraints."
        } else if pressuredDays > 0 {
            summary = "\(pressuredDays) day\((pressuredDays == 1) ? "" : "s") may need shaping before the week feels believable."
        } else {
            summary = "The week has visible room and no overloaded day in the current shape."
        }

        return TimeLifeSuiteShapeState(
            kind: .week,
            title: "Week Shape",
            question: "Does the week still fit?",
            summary: openCaptureCount > 0
                ? "\(summary) \(openCaptureCount) capture\((openCaptureCount == 1) ? "" : "s") still need a place."
                : summary,
            facts: weekShapeFacts(
                weekDays: weekDays,
                pressuredDays: pressuredDays,
                openCaptureCount: openCaptureCount,
                openDays: openDays
            ),
            sourceLabel: "Based on goals and captures",
            boundaryLabel: "Suggestions require confirmation",
            schedulePressureLabel: pressuredDays == 0
                ? "Schedule pressure: the week is readable."
                : "Schedule pressure: \(pressuredDays) pressured day\((pressuredDays == 1) ? "" : "s") need review.",
            protectedTimeLabel: protectedDays == 0
                ? "Protected time: nothing is defending the week yet."
                : "Protected time: \(protectedDays) fixed or protected block\((protectedDays == 1) ? "" : "s") stay visible.",
            capacityLabel: openCaptureCount > 0
                ? "Capacity: \(openCaptureCount) capture\((openCaptureCount == 1) ? "" : "s") still need placement."
                : "Capacity: the current week has visible room.",
            proofOpportunityLabel: activeGoalCount == 0
                ? "Proof opportunity: no active goal is asking for a receipt yet."
                : "Proof opportunity: active goals can become inspectable receipts when one small step is confirmed.",
            provenanceLabel: "Provenance: based on goals, captures, and local week pressure.",
            privacyLabel: calendarAwareness.canRequestCalendarRead
                ? "Privacy: derived busy time stays locally inspectable and never writes silently."
                : "Privacy: local goals and captures are enough for this view, with user choice available.",
            visualState: pressuredDays > 0 ? .warning : .selected
        )
    }

    func lifeShape(
        activeGoalCount: Int,
        calendarAwareness: TimeCalendarAwarenessState
    ) -> TimeLifeSuiteShapeState {
        TimeLifeSuiteShapeState(
            kind: .life,
            title: "Life Shape",
            question: "Is Time still pointed at the life you are building?",
            summary: activeGoalCount == 0
                ? "Life Shape is quiet until active goals give Time something to shape."
                : "\(activeGoalCount) active goal\((activeGoalCount == 1) ? "" : "s") shape the current LifeShape Field.",
            facts: [
                activeGoalCount == 0 ? "No active goals shaping life view yet." : "\(activeGoalCount) active goal\((activeGoalCount == 1) ? "" : "s") included.",
                "Life Shape stays inside Time.",
                "User choice stays available."
            ],
            sourceLabel: "Based on active goals",
            boundaryLabel: "Life view, broader than time slots",
            schedulePressureLabel: activeGoalCount == 0
                ? "Schedule pressure: no active goal is loading the longer arc yet."
                : "Schedule pressure: active goals are shaping the longer arc.",
            protectedTimeLabel: "Protected time: the longer arc stays wider than any one day.",
            capacityLabel: activeGoalCount == 0
                ? "Capacity: the life view is quiet until goals give it shape."
                : "Capacity: \(activeGoalCount) active goal\((activeGoalCount == 1) ? "" : "s") keep the life view meaningful.",
            proofOpportunityLabel: activeGoalCount == 0
                ? "Proof opportunity: no long-range proof is expected yet."
                : "Proof opportunity: active goals can show durable proof when receipts are recorded locally.",
            provenanceLabel: "Provenance: based on active goals and LifeShape state.",
            privacyLabel: calendarAwareness.canRequestCalendarRead
                ? "Privacy: calendar access is optional, local, and never silent."
                : "Privacy: this life view remains local-only and never writes silently.",
            visualState: activeGoalCount == 0 ? .default : .selected
        )
    }

}
