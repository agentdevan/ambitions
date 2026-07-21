import Foundation

extension RepositoryBackedTimeRitualsService {
    func note(for action: TimeRitualActionKind, step: Step) -> String {
        switch action {
        case .complete: "Completed from Rituals."
        case .skip: "Skipped from Rituals without punitive language."
        case .delay: "Delayed from Rituals to soften pressure."
        case .minimumVersion: "Minimum version completed from Rituals."
        case .quickLog: "Quick log from Rituals."
        case .openDetail: step.title
        case .needsEasierVersion: "Asked for an easier version from Rituals."
        case .markNotRelevant: "Marked ritual plan as not relevant from Rituals."
        }
    }

    func advance(goal: Goal, step: Step, now: Date, cadenceDays: Int) -> Goal {
        update(goal: goal, stepID: step.id, updatedAt: Self.iso.string(from: now)) { current in
            stepCopy(from: current, timing: TimeRitualGoalSemantics.advancedTiming(from: current.timing, now: now, cadenceDays: cadenceDays))
        }
    }

    func update(goal: Goal, stepID: String, updatedAt: String, transform: (Step) -> Step) -> Goal {
        let updatedSections = goal.plan?.sections.map { section in
            PlanSection(
                id: section.id,
                goalID: section.goalID,
                title: section.title,
                summary: section.summary,
                kind: section.kind,
                orderIndex: section.orderIndex,
                steps: section.steps.map { $0.id == stepID ? transform($0) : $0 }
            )
        }

        let updatedPlan = goal.plan.map { plan in
            GoalPlan(
                id: plan.id,
                goalID: plan.goalID,
                version: plan.version,
                generatedAt: plan.generatedAt,
                summary: plan.summary,
                strategy: plan.strategy,
                sections: updatedSections ?? plan.sections,
                assumptions: plan.assumptions,
                lint: plan.lint
            )
        }

        return Goal(
            schemaVersion: goal.schemaVersion,
            id: goal.id,
            revision: goal.revision + 1,
            createdAt: goal.createdAt,
            updatedAt: updatedAt,
            state: goal.state,
            title: goal.title,
            summary: goal.summary,
            mode: goal.mode,
            relationshipKind: goal.relationshipKind,
            actor: goal.actor,
            parentGoalID: goal.parentGoalID,
            childGoalIDs: goal.childGoalIDs,
            supportGoalIDs: goal.supportGoalIDs,
            tags: goal.tags,
            timing: goal.timing,
            planningStrategy: goal.planningStrategy,
            progressStrategy: goal.progressStrategy,
            plan: updatedPlan,
            lifeGraph: goal.lifeGraph
        )
    }

    func stepCopy(from step: Step, timing: GoalTiming) -> Step {
        Step(
            id: step.id,
            sectionID: step.sectionID,
            title: step.title,
            summary: step.summary,
            type: step.type,
            state: step.state,
            owner: step.owner,
            timing: timing,
            dependencyStepIDs: step.dependencyStepIDs,
            isOptional: step.isOptional,
            isRepeatable: step.isRepeatable,
            evidenceRequired: step.evidenceRequired,
            successSignals: step.successSignals,
            actionability: step.actionability
        )
    }

    func shiftedTiming(_ timing: GoalTiming, now: Date, adjustment: GoalTimingAdjustment) -> GoalTiming {
        let shiftedDate = tickPolicy.date(byAdding: .hour, value: 4, to: now) ?? now
        let shiftedValue = adjustment == .removeDeadline ? nil : Self.iso.string(from: shiftedDate)
        return GoalTiming(
            tempo: adjustment == .removeDeadline ? .untimed : timing.tempo,
            timingType: adjustment == .removeDeadline ? .logWhenDone : .suggestedNext,
            startsOn: timing.startsOn,
            dueAt: adjustment == .removeDeadline ? nil : timing.dueAt,
            targetBy: adjustment == .removeDeadline ? nil : timing.targetBy,
            windowStart: timing.windowStart,
            windowEnd: timing.windowEnd,
            suggestedNextAt: shiftedValue,
            repeatEveryDays: timing.repeatEveryDays,
            progressReviewCadenceDays: timing.progressReviewCadenceDays
        )
    }

    func stepMinutes(for mode: GoalMode) -> Int {
        switch mode {
        case .recovery: 10
        case .delegatedSupport: 12
        default: 20
        }
    }

    func startOfDay(for value: String) -> Date? {
        guard let date = parseDate(value) else { return nil }
        return tickPolicy.startOfDay(for: date)
    }

    func isSameDay(_ value: String, as referenceDayStart: Date) -> Bool {
        guard let date = parseDate(value) else { return false }
        return tickPolicy.isSameDay(date, referenceDayStart)
    }

    func parseDate(_ value: String?) -> Date? {
        guard let value else { return nil }
        return Self.iso.date(from: value) ?? Self.isoFallback.date(from: value)
    }

    static let completeNote = "Ritual completion from Rituals."
    static let quickLogNote = "Quick log from Rituals."
    static let minimumNotePrefix = "Minimum version from Rituals: "

    static var iso: ISO8601DateFormatter {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }

    static var isoFallback: ISO8601DateFormatter {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }
}
