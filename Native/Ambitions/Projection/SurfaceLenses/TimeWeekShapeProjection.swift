import AmbitionsDesignSystem
import Foundation

extension RepositoryBackedTimeService {
    func makeGoalSummaries(goals: [Goal], feedback: [GoalFeedbackEvent], now: Date) -> [RepositoryBackedTimeService.GoalWeekSummary] {
        goals.map { goal in
            let sections = goal.plan?.sections ?? []
            let steps = sections.flatMap(\.steps)
            let goalFeedback = feedback.filter { event in
                steps.contains(where: { $0.id == event.stepID })
            }
            let frictionCount = goalFeedback.filter(isFriction).count
            let contexts = weekStepContexts(goal: goal, frictionCount: frictionCount, now: now)
            return RepositoryBackedTimeService.GoalWeekSummary(
                goal: goal,
                contexts: contexts,
                frictionCount: frictionCount,
                evaluation: goal.plan?.evaluation
            )
        }
    }

    func weekStepContexts(goal: Goal, frictionCount: Int, now: Date) -> [RepositoryBackedTimeService.StepContext] {
        let start = calendar.startOfDay(for: now)
        let end = calendar.date(byAdding: .day, value: 7, to: start) ?? now
        let evaluation = goal.plan?.evaluation

        return (goal.plan?.sections ?? [])
            .flatMap(\.steps)
            .compactMap { step -> RepositoryBackedTimeService.StepContext? in
                guard step.state != .completed, step.state != .cancelled else { return nil }
                guard let date = plannedDate(for: step.timing) else { return nil }
                guard date >= start, date < end else { return nil }
                let dayIndex = calendar.dateComponents([.day], from: start, to: calendar.startOfDay(for: date)).day ?? 0
                guard (0..<7).contains(dayIndex) else { return nil }
                return RepositoryBackedTimeService.StepContext(
                    goal: goal,
                    step: step,
                    date: date,
                    dayIndex: dayIndex,
                    timingLabel: timingLabel(for: step.timing),
                    blockKind: blockKind(for: step.timing),
                    visualState: blockVisualState(step: step, evaluation: evaluation, frictionCount: frictionCount),
                    frictionCount: frictionCount,
                    evaluation: evaluation
                )
            }
            .sorted { lhs, rhs in
                if lhs.dayIndex == rhs.dayIndex {
                    return lhs.date < rhs.date
                }
                return lhs.dayIndex < rhs.dayIndex
            }
    }

    func makeWeekDays(
        summaries: [RepositoryBackedTimeService.GoalWeekSummary],
        missingGoalSummaries: [RepositoryBackedTimeService.GoalWeekSummary],
        now: Date
    ) -> [TimeElasticWeekDayState] {
        let start = calendar.startOfDay(for: now)
        let dayFormatter = DateFormatter()
        dayFormatter.locale = .current
        dayFormatter.setLocalizedDateFormatFromTemplate("EEE")
        let dateFormatter = DateFormatter()
        dateFormatter.locale = .current
        dateFormatter.setLocalizedDateFormatFromTemplate("d")

        let contextsByDay = Dictionary(grouping: summaries.flatMap(\.contexts), by: \.dayIndex)

        return (0..<7).map { dayIndex in
            let date = calendar.date(byAdding: .day, value: dayIndex, to: start) ?? start
            let contexts = (contextsByDay[dayIndex] ?? []).sorted { lhs, rhs in
                if lhs.visualState == rhs.visualState {
                    return lhs.date < rhs.date
                }
                return shapingRank(for: lhs.visualState) < shapingRank(for: rhs.visualState)
            }
            let load = contexts.reduce(0.0) { partial, context in
                partial + loadWeight(for: context.blockKind, visualState: context.visualState)
            }
            let remainingCapacity = 3.0 - load
            let level: TimeWeekPressureLevel = {
                if remainingCapacity < -0.3 || contexts.count >= 4 { return .overloaded }
                if remainingCapacity < 0.7 || contexts.count >= 3 { return .tight }
                if contexts.isEmpty || remainingCapacity > 1.7 { return .open }
                return .steady
            }()
            let suggestedSummary = missingGoalSummaries.first ?? summaries.first(where: {
                $0.contexts.contains(where: { $0.dayIndex == dayIndex }) == false && ($0.evaluation?.feasibilityLevel == .tight || $0.evaluation?.feasibilityLevel == .fragile)
            })
            let roomLabel = roomLabel(for: level, remainingCapacity: remainingCapacity, contextCount: contexts.count)
            let openWindow = makeOpenWindow(
                level: level,
                remainingCapacity: remainingCapacity,
                suggestedSummary: suggestedSummary,
                contextCount: contexts.count
            )
            let visibleBlocks = Array(contexts.prefix(level == .overloaded ? 4 : 3)).map { context in
                TimeWeekBlockState(
                    id: "\(context.goal.id)-\(context.step.id)",
                    target: GoalRouteTarget(goalID: context.goal.id),
                    title: context.step.title,
                    detail: context.step.summary ?? context.step.actionability.fallbackMicroStep,
                    goalLabel: context.goal.title,
                    timingLabel: context.timingLabel,
                    kind: context.blockKind,
                    visualState: context.visualState
                )
            }
            let highlight = dayHighlight(
                level: level,
                contexts: contexts,
                suggestedSummary: suggestedSummary
            )

            return TimeElasticWeekDayState(
                id: "day-\(dayIndex)",
                weekdayLabel: dayFormatter.string(from: date),
                dateLabel: dateFormatter.string(from: date),
                level: level,
                intensity: dayIntensity(for: level, blockCount: contexts.count),
                roomLabel: roomLabel,
                capacityLabel: contexts.isEmpty ? "No blocks yet" : "\(contexts.count) block\(contexts.count == 1 ? "" : "s")",
                highlight: highlight,
                blocks: visibleBlocks,
                overflowCount: max(contexts.count - visibleBlocks.count, 0),
                openWindow: openWindow
            )
        }
    }

    func makeOpenWindow(
        level: TimeWeekPressureLevel,
        remainingCapacity: Double,
        suggestedSummary: RepositoryBackedTimeService.GoalWeekSummary?,
        contextCount: Int
    ) -> TimeOpenWindowState? {
        guard level != .overloaded || remainingCapacity > -0.1 else {
            return nil
        }

        if let suggestedSummary {
            return TimeOpenWindowState(
                title: level == .open ? "Open window" : "Usable room",
                detail: contextCount == 0
                    ? "This day can carry one believable step without turning calendar-dense."
                    : "There is still enough room to protect or patch one calmer step.",
                suggestionLabel: suggestedSummary.goal.title,
                target: GoalRouteTarget(goalID: suggestedSummary.goal.id),
                visualState: level == .open ? .success : .selected
            )
        }

        return TimeOpenWindowState(
            title: level == .open ? "Leave this open" : "Keep breathing room",
            detail: "Not every open pocket needs to be filled. Open room keeps the week doable.",
            suggestionLabel: nil,
            target: nil,
            visualState: .default
        )
    }

    func makePressureScrubber(days: [TimeElasticWeekDayState]) -> TimePressureScrubberState {
        let defaultDayID = days.max { lhs, rhs in
            if lhs.level == rhs.level {
                return lhs.intensity < rhs.intensity
            }
            return pressureRank(for: lhs.level) < pressureRank(for: rhs.level)
        }?.id ?? days.first?.id ?? "day-0"

        return TimePressureScrubberState(
            title: "Pressure scrubber",
            subtitle: "Scrub the week to inspect where pressure gathers, where room remains, and which day can take another believable step.",
            defaultDayID: defaultDayID,
            points: days.map { day in
                TimePressureScrubberPoint(
                    id: day.id,
                    weekdayLabel: day.weekdayLabel,
                    dateLabel: day.dateLabel,
                    level: day.level,
                    pressureValue: day.intensity,
                    roomLabel: day.roomLabel,
                    summary: day.highlight
                )
            }
        )
    }

}
