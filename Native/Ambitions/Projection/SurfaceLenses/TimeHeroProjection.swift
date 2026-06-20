import AmbitionsDesignSystem
import Foundation

extension RepositoryBackedTimeService {
    func makeHero(
        posture: TimeBelievabilityState,
        timeframeLabel: String,
        representedGoalCount: Int,
        activeGoalCount: Int,
        weekDays: [TimeElasticWeekDayState],
        missingGoalCount: Int,
        openCaptureCount: Int,
        mode: TimeSurfaceMode
    ) -> TimeRealityHeroState {
        let overloadedDays = weekDays.filter { $0.level == .overloaded }.count
        let openDays = weekDays.filter { $0.level == .open }.count
        let tightDays = weekDays.filter { $0.level == .tight }.count
        let dominantTruth: String = {
            guard mode == .active else { return "The week is mostly empty, which is useful information." }
            if overloadedDays > 0 {
                return "Pressure is clustering into \(overloadedDays) overloaded day\(overloadedDays == 1 ? "" : "s")."
            }
            if missingGoalCount > 0 {
                return "\(missingGoalCount) active goal\(missingGoalCount == 1 ? "" : "s") still need believable room in the week."
            }
            if tightDays > 0 {
                return "The week basically holds, but pressure is already visible on \(tightDays) day\(tightDays == 1 ? "" : "s")."
            }
            return "The current week is holding together without calendar-noise density."
        }()

        let roomSummary: String = {
            if openDays == 0 { return "Room is scarce, so every new ask needs a tradeoff." }
            if openDays <= 2 { return "Only a little open room remains; protect it deliberately." }
            return "\(openDays) day\(openDays == 1 ? "" : "s") still carry visible room for a believable step."
        }()

        let pressureSummary: String = {
            if openCaptureCount > 0 {
                return "Outside pressure is mostly coming from captures that have not yet been attached or discarded."
            }
            return posture.supportLabel
        }()

        return TimeRealityHeroState(
            eyebrow: "Time",
            title: "Shape Time",
            subtitle: "Time reads the week as open room, goal time, pressure, and protected structure.",
            dominantTruth: dominantTruth,
            roomSummary: roomSummary,
            pressureSummary: pressureSummary,
            contextPills: [
                TimeHeroPillState(title: timeframeLabel, icon: "calendar", state: .default),
                TimeHeroPillState(title: posture.label, icon: AmbitionsSurface.time.systemImage, state: posture.visualState),
                TimeHeroPillState(title: "\(representedGoalCount)/\(max(activeGoalCount, 1)) goals visible", icon: "target", state: representedGoalCount == activeGoalCount && activeGoalCount > 0 ? .success : .selected)
            ],
            trustWhisper: posture.supportLabel
        )
    }

    func makePrimaryAction(
        mode: TimeSurfaceMode,
        posture: TimeBelievabilityState,
        missingGoalSummary: RepositoryBackedTimeService.GoalWeekSummary?,
        pressuredGoalSummary: RepositoryBackedTimeService.GoalWeekSummary?,
        openCaptureCount: Int,
        weekDays: [TimeElasticWeekDayState]
    ) -> TimeWeekPrimaryAction {
        if mode == .empty {
            return TimeWeekPrimaryAction(
                kind: .useRoom,
                title: "Use this room",
                subtitle: "The week is open. Keep it open until a real goal or capture needs shape.",
                systemImage: "sparkles",
                state: .success,
                goalTarget: nil,
                timeRoute: nil
            )
        }

        if weekDays.contains(where: { $0.level == .overloaded }) {
            return TimeWeekPrimaryAction(
                kind: .lightenWeek,
                title: "Lighten week",
                subtitle: openCaptureCount > 0
                    ? "Reduce outside pressure first so the week stops carrying speculative load."
                    : "One day is carrying too much. Lighten the loudest lane before adding more.",
                systemImage: "sun.max",
                state: .warning,
                goalTarget: openCaptureCount > 0 ? nil : pressuredGoalSummary.map { GoalRouteTarget(goalID: $0.goal.id) },
                timeRoute: nil,
                interactionIntent: openCaptureCount > 0 ? .openGlobalCapture : nil
            )
        }

        if let missingGoalSummary, weekDays.contains(where: { $0.level == .open }) {
            return TimeWeekPrimaryAction(
                kind: .useRoom,
                title: "Use this room",
                subtitle: "There is believable room for one calmer step on \(missingGoalSummary.goal.title).",
                systemImage: "arrow.down.left.and.arrow.up.right",
                state: .success,
                goalTarget: GoalRouteTarget(goalID: missingGoalSummary.goal.id),
                timeRoute: nil
            )
        }

        if let missingGoalSummary {
            return TimeWeekPrimaryAction(
                kind: .resolveCarryover,
                title: "Resolve carryover",
                subtitle: "\(missingGoalSummary.goal.title) is active but still not represented in the week.",
                systemImage: "arrow.triangle.branch",
                state: .selected,
                goalTarget: GoalRouteTarget(goalID: missingGoalSummary.goal.id),
                timeRoute: nil
            )
        }

        return TimeWeekPrimaryAction(
            kind: .shapeWeek,
            title: "Shape this week",
            subtitle: posture.supportLabel,
            systemImage: "wand.and.stars",
            state: posture.visualState == .warning ? .selected : posture.visualState,
            goalTarget: pressuredGoalSummary.map { GoalRouteTarget(goalID: $0.goal.id) } ?? weekDays.flatMap(\.blocks).first?.target,
            timeRoute: nil
        )
    }

}
