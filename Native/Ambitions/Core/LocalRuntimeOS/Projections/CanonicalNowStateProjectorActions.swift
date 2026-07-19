import Foundation

extension CanonicalNowStateProjector {
    struct DatedStep {
        let goal: Goal
        let step: Step
        let date: Date
        let pressure: NowPressureLevel
    }


    func bestAction(
        from selection: PlanningNextStepSelection?,
        explanations: [RecommendationExplanation]
    ) -> NowAction? {
        guard let selection else { return nil }
        let explanation = explanation(forGoalID: selection.goal.id, stepID: selection.step.id, explanations: explanations)
        return action(
            goal: selection.goal,
            step: selection.step,
            kind: selection.step.state == .blocked ? .wait : .focus,
            state: selection.step.state == .blocked ? .blocked : .ready,
            explanationID: explanation?.id
        )
    }


    func action(
        goal: Goal,
        step: Step,
        kind: NowActionKind,
        state: NowActionState,
        explanationID: String?
    ) -> NowAction {
        NowAction(
            id: "now.action.\(goal.id).\(step.id)",
            kind: kind,
            state: state,
            title: step.title,
            subtitle: goal.title,
            contextLens: lens(for: goal),
            commitmentKind: commitmentKind(goal: goal, step: step),
            reference: NowActionReference(goalID: goal.id, stepID: step.id),
            explanationID: explanationID
        )
    }


    func upcomingDatedSteps(goals: [Goal], now: Date) -> [DatedStep] {
        let horizon = now.addingTimeInterval(7 * 24 * 60 * 60)
        return goals.flatMap { goal in
            (goal.plan?.sections.flatMap(\.steps) ?? []).compactMap { step -> DatedStep? in
                guard step.state != .completed && step.state != .cancelled,
                      let date = date(from: step.timing.dueAt ?? step.timing.targetBy ?? step.timing.windowEnd ?? step.timing.suggestedNextAt),
                      date <= horizon else {
                    return nil
                }
                return DatedStep(goal: goal, step: step, date: date, pressure: pressure(for: date, now: now))
            }
        }.sorted {
            if $0.date != $1.date { return $0.date < $1.date }
            if $0.goal.id != $1.goal.id { return $0.goal.id < $1.goal.id }
            return $0.step.id < $1.step.id
        }
    }


    func schedulePressure(from datedSteps: [DatedStep]) -> NowPressureSummary {
        let count = datedSteps.count
        let level: NowPressureLevel
        switch count {
        case 0:
            level = .none
        case 1...2:
            level = .low
        case 3...4:
            level = .moderate
        case 5...6:
            level = .elevated
        default:
            level = .high
        }
        return NowPressureSummary(
            level: level,
            itemCount: count,
            summary: count == 0
                ? "No local schedule pressure is visible."
                : "\(count) local dated item\(count == 1 ? "" : "s") can shape the next seven days."
        )
    }


    func deadlinePressure(from urgentSteps: [DatedStep]) -> NowPressureSummary {
        let strongest = urgentSteps.map(\.pressure).max(by: pressureSort) ?? .none
        return NowPressureSummary(
            level: strongest,
            itemCount: urgentSteps.count,
            summary: urgentSteps.isEmpty
                ? "No urgent deadline pressure is visible."
                : "\(urgentSteps.count) deadline-bound item\(urgentSteps.count == 1 ? "" : "s") need attention soon."
        )
    }


    func captureUrgency(openCaptures: [Capture]) -> NowPressureSummary {
        let count = openCaptures.count
        let level: NowPressureLevel
        switch count {
        case 0:
            level = .none
        case 1...2:
            level = .low
        case 3...4:
            level = .moderate
        default:
            level = .elevated
        }
        return NowPressureSummary(
            level: level,
            itemCount: count,
            summary: count == 0
                ? "No open captures are asking for attention."
                : "\(count) capture\(count == 1 ? "" : "s") still need a destination."
        )
    }


    func blockersWaitingSummary(
        blockedSteps: [(Goal, Step)],
        waitingCaptures: [Capture]
    ) -> NowBlockersWaitingSummary {
        let references = blockedSteps.map { goal, step in
            NowActionReference(goalID: goal.id, stepID: step.id)
        } + waitingCaptures.map { capture in
            NowActionReference(captureID: capture.id)
        }
        let blockedCount = blockedSteps.count
        let waitingCount = waitingCaptures.count
        let summary: String
        if blockedCount == 0 && waitingCount == 0 {
            summary = "No blockers or waiting items are visible."
        } else {
            summary = "\(blockedCount) blocked and \(waitingCount) waiting item\(blockedCount + waitingCount == 1 ? "" : "s") are visible."
        }
        return NowBlockersWaitingSummary(
            blockedCount: blockedCount,
            waitingCount: waitingCount,
            summary: summary,
            references: references
        )
    }


    func goalPressureSummaries(
        goals: [Goal],
        selections: [PlanningNextStepSelection],
        kind: NowGoalPressureKind,
        now: Date,
        explanations: [RecommendationExplanation]
    ) -> [NowGoalPressureSummary] {
        goals.map { goal in
            let selection = selections.first { $0.goal.id == goal.id }
            let duePressure = pressure(for: date(from: goal.timing.dueAt ?? goal.timing.targetBy ?? goal.timing.windowEnd), now: now)
            let blockedCount = goal.plan?.sections.flatMap(\.steps).filter { $0.state == .blocked }.count ?? 0
            let level = maxPressure([duePressure, blockedCount > 0 ? .elevated : .none, kind == .activeGoal ? .moderate : .low])
            let explanation = explanation(forGoalID: goal.id, stepID: selection?.step.id, explanations: explanations)
            let nextAction = selection.map {
                action(goal: $0.goal, step: $0.step, kind: .focus, state: .ready, explanationID: explanation?.id)
            }
            return NowGoalPressureSummary(
                id: "now.goal-pressure.\(kind.rawValue).\(goal.id)",
                kind: kind,
                level: level,
                goalID: goal.id,
                title: goal.title,
                summary: summary(goal: goal, kind: kind, duePressure: duePressure, blockedCount: blockedCount),
                nextAction: nextAction,
                explanationID: explanation?.id,
                eventLedgerEntryIDs: explanations.flatMap(\.relations.eventLedgerEntryIDs)
            )
        }
    }


    func priorityReality(
        schedulePressure: NowPressureSummary,
        deadlinePressure: NowPressureSummary,
        activeGoalPressure: [NowGoalPressureSummary],
        passiveGoalPressure: [NowGoalPressureSummary],
        recovery: NowRecoveryState
    ) -> NowPriorityRealitySummary {
        let activeLevel = maxPressure(activeGoalPressure.map(\.level))
        let passiveLevel = maxPressure(passiveGoalPressure.map(\.level))
        let capacity = schedulePressure.level == .high ? NowPressureLevel.elevated : schedulePressure.level
        let recoveryPressure: NowPressureLevel = {
            switch recovery {
            case .stable:
                return .none
            case .watch:
                return .moderate
            case .needsRecovery, .recovering:
                return .elevated
            case .blocked:
                return .high
            }
        }()
        let overall = maxPressure([deadlinePressure.level, activeLevel, capacity, recoveryPressure])
        return NowPriorityRealitySummary(
            overallPressure: overall,
            importance: activeLevel,
            urgency: maxPressure([deadlinePressure.level, schedulePressure.level]),
            deadline: deadlinePressure.level,
            consequence: deadlinePressure.level == .critical || deadlinePressure.level == .high ? .high : .low,
            effort: schedulePressure.level,
            contextFit: passiveLevel == .low && rank(activeLevel) > rank(passiveLevel) ? .moderate : .low,
            goalRelationship: maxPressure([activeLevel, passiveLevel]),
            userPreference: .none,
            capacity: capacity,
            recoveryState: recovery,
            summary: overall == .none
                ? "No priority pressure is visible yet."
                : "Priority pressure reflects active goals, dated work, capacity pressure, and recovery state."
        )
    }


    func outsideLensSummary(
        activeLens: NowContextLens,
        selections: [PlanningNextStepSelection],
        now: Date
    ) -> NowUrgentOutsideLensSummary {
        guard activeLens != .all else {
            return NowUrgentOutsideLensSummary(level: .none, summary: "All lenses are visible.")
        }
        let items = selections.compactMap { selection -> NowOutsideLensItem? in
            let lens = lens(for: selection.goal)
            guard lens != activeLens && lens != .all else { return nil }
            let pressure = pressure(for: date(from: selection.step.timing.dueAt ?? selection.step.timing.targetBy ?? selection.step.timing.windowEnd), now: now)
            guard pressure == .critical || pressure == .high || pressure == .elevated else { return nil }
            return NowOutsideLensItem(
                id: "now.outside-lens.\(selection.goal.id).\(selection.step.id)",
                title: selection.step.title,
                lens: lens,
                pressure: pressure,
                reference: NowActionReference(goalID: selection.goal.id, stepID: selection.step.id)
            )
        }
        return NowUrgentOutsideLensSummary(
            level: maxPressure(items.map(\.pressure)),
            summary: items.isEmpty
                ? "No urgent outside-lens items are visible."
                : "\(items.count) urgent item\(items.count == 1 ? "" : "s") outside this lens should stay visible.",
            items: items
        )
    }


    func todayPosture(
        activeGoals: Int,
        blockedCount: Int,
        openCaptureCount: Int,
        schedulePressure: NowPressureLevel,
        recovery: NowRecoveryState,
        bestAction: NowAction?
    ) -> NowPosture {
        if activeGoals == 0 && openCaptureCount == 0 { return .lowData }
        if recovery == .needsRecovery || recovery == .recovering { return .recovering }
        if blockedCount > 0 && bestAction == nil { return .waiting }
        if schedulePressure == .high || schedulePressure == .critical { return .overloaded }
        if schedulePressure == .elevated || openCaptureCount >= 5 { return .tight }
        if bestAction == nil { return .lowData }
        return .steady
    }


    func recoveryState(blockedCount: Int, feedback: [GoalFeedbackEvent]) -> NowRecoveryState {
        if blockedCount >= 3 { return .blocked }
        if blockedCount > 0 { return .needsRecovery }
        let recentFriction = feedback.filter { event in
            switch event {
            case .skipped, .delayed, .tooBig, .askedForSmallerVersion:
                return true
            default:
                return false
            }
        }.count
        if recentFriction >= 3 { return .watch }
        return .stable
    }
}
