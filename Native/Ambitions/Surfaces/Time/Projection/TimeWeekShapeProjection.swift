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
        timeBlocks: [TimeBlock] = [],
        now: Date
    ) -> [TimeElasticWeekDayState] {
        let ticks = RuntimeTickPolicy(calendar: calendar)
        let start = ticks.startOfDay(for: now)

        let scheduledStepIDs = Set(timeBlocks.compactMap(\.stepID))
        let contextsByDay = Dictionary(
            grouping: summaries.flatMap(\.contexts).filter { scheduledStepIDs.contains($0.step.id) == false },
            by: \.dayIndex
        )
        let blocksByDay = Dictionary(grouping: timeBlocks.filter { $0.end > start }) { block in
            calendar.dateComponents([.day], from: start, to: calendar.startOfDay(for: block.start)).day ?? -1
        }

        return (0..<7).map { dayIndex in
            let date = ticks.date(byAdding: .day, value: dayIndex, to: start) ?? start
            let contexts = (contextsByDay[dayIndex] ?? []).sorted { lhs, rhs in
                if lhs.visualState == rhs.visualState {
                    return lhs.date < rhs.date
                }
                return shapingRank(for: lhs.visualState) < shapingRank(for: rhs.visualState)
            }
            let durableBlocks = (blocksByDay[dayIndex] ?? []).sorted { $0.start < $1.start }
            let capacityBlockCount = durableBlocks.filter(\.kind.consumesCapacity).count
            let load = contexts.reduce(Double(capacityBlockCount)) { partial, context in
                partial + loadWeight(for: context.blockKind, visualState: context.visualState)
            }
            let remainingCapacity = 3.0 - load
            let level: TimeWeekPressureLevel = {
                let count = contexts.count + capacityBlockCount
                if remainingCapacity < -0.3 || count >= 4 { return .overloaded }
                if remainingCapacity < 0.7 || count >= 3 { return .tight }
                if count == 0 || remainingCapacity > 1.7 { return .open }
                return .steady
            }()
            let suggestedSummary = missingGoalSummaries.first ?? summaries.first(where: {
                $0.contexts.contains(where: { $0.dayIndex == dayIndex }) == false && ($0.evaluation?.feasibilityLevel == .tight || $0.evaluation?.feasibilityLevel == .fragile)
            })
            let blockCount = contexts.count + capacityBlockCount
            let roomLabel = roomLabel(for: level, remainingCapacity: remainingCapacity, contextCount: blockCount)
            let openWindow = makeOpenWindow(
                level: level,
                remainingCapacity: remainingCapacity,
                suggestedSummary: suggestedSummary,
                contextCount: blockCount
            )
            let contextBlocks = contexts.map { context in
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
            let persistedBlocks = durableBlocks.map { block in
                TimeWeekBlockState(
                    id: block.id,
                    target: block.goalID.map { GoalRouteTarget(goalID: $0) },
                    title: block.title,
                    detail: "Saved locally in Life Calendar",
                    goalLabel: block.goalID ?? "Time",
                    timingLabel: Self.timingLabel(for: block, calendar: calendar),
                    kind: Self.weekBlockKind(block.kind),
                    visualState: block.kind.protectsBoundary ? .selected : .default
                )
            }
            let allBlocks = (persistedBlocks + contextBlocks)
            let visibleBlocks = Array(allBlocks.prefix(level == .overloaded ? 4 : 3))
            let highlight = dayHighlight(
                level: level,
                contexts: contexts,
                suggestedSummary: suggestedSummary
            )

            return TimeElasticWeekDayState(
                id: "day-\(dayIndex)",
                weekdayLabel: ticks.shortWeekdayLabel(for: date),
                dateLabel: ticks.dayOfMonthLabel(for: date),
                level: level,
                intensity: dayIntensity(for: level, blockCount: blockCount),
                roomLabel: roomLabel,
                capacityLabel: allBlocks.isEmpty ? "No blocks yet" : "\(allBlocks.count) block\(allBlocks.count == 1 ? "" : "s")",
                highlight: highlight,
                blocks: visibleBlocks,
                overflowCount: max(allBlocks.count - visibleBlocks.count, 0),
                openWindow: openWindow
            )
        }
    }

    private static func weekBlockKind(_ kind: TimeBlockKind) -> TimeWeekBlockKind {
        switch kind {
        case .protected: .protected
        case .fixed, .externalBusy: .fixed
        case .flexible, .scheduledStep, .recovery, .buffer, .needsMoreTime, .lighterPressure: .flexible
        case .unavailable, .keepClear: .protected
        }
    }

    private static func timingLabel(for block: TimeBlock, calendar: Calendar) -> String {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.timeZone = calendar.timeZone
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        let time = formatter.string(from: block.start)
        return block.kind == .scheduledStep ? "Scheduled, \(time)" : time
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
