import AmbitionsDesignSystem
import Foundation

extension RepositoryBackedGoalsService {

    func adaptiveResult(from draft: PersistedGoalDraft, goal: Goal) -> GoalAdaptivePlanResult? {
        guard let plan = goal.plan ?? draft.stagedPlan else { return nil }

        switch draft.latestResultKind {
        case .planned:
            guard let metadata = draft.metadata else { return nil }
            return .planned(
                GoalPlannedResult(draft: draft.draft, plan: plan, lint: plan.lint, metadata: metadata)
            )
        case .starterPlanned:
            guard let clarification = draft.clarification, let metadata = draft.metadata else { return nil }
            return .starterPlanned(
                GoalStarterPlannedResult(
                    draft: draft.draft,
                    plan: plan,
                    lint: plan.lint,
                    assumptions: draft.assumptions,
                    clarification: clarification,
                    metadata: metadata
                )
            )
        case .clarificationRequired, .blocked, .none:
            return nil
        }
    }


    func incompleteDependencyCount(in goal: Goal, for step: Step) -> Int {
        let completedStepIDs = Set(goal.plan?.sections.flatMap(\.steps).filter { $0.state == .completed }.map(\.id) ?? [])
        return step.dependencyStepIDs.filter { completedStepIDs.contains($0) == false }.count
    }


    func canSwitchToUntimed(mode: GoalMode, timing: GoalTiming) -> Bool {
        guard timing.tempo != .untimed else { return false }
        switch mode {
        case .achievement:
            return false
        case .project, .habit, .learning, .exploration, .maintenance, .recovery, .delegatedSupport:
            return true
        }
    }


    func urgencyScore(for timing: GoalTiming, mode: GoalMode) -> Double {
        if mode == .delegatedSupport {
            return timing.suggestedNextAt == nil ? 0.32 : 0.58
        }
        if timing.tempo == .untimed {
            return 0.22
        }

        guard let reference = parseDate(timing.dueAt ?? timing.targetBy ?? timing.windowEnd ?? timing.suggestedNextAt) else {
            return 0.42
        }
        let days = max(0, reference.timeIntervalSinceNow / 86_400)
        if days <= 2 { return 0.96 }
        if days <= 7 { return 0.82 }
        if days <= 21 { return 0.58 }
        return 0.34
    }


    func timingLabel(for timing: GoalTiming, goalMode: GoalMode) -> String {
        switch goalMode {
        case .delegatedSupport:
            return timing.suggestedNextAt == nil ? "Support when helpful" : "Support window open"
        default:
            switch timing.tempo {
            case .untimed:
                return "Untimed"
            case .ongoing:
                return timing.repeatEveryDays.map { "Every \($0) day\($0 == 1 ? "" : "s")" } ?? "Ongoing cadence"
            case .targetWindow:
                return timing.targetBy.map { "Target by \($0)" } ?? "Flexible window"
            case .deadlineBased:
                return timing.dueAt.map { "Due \($0)" } ?? "Deadline-based"
            }
        }
    }


    func shiftedTiming(for timing: GoalTiming, now: Date, adjustment: GoalTimingAdjustment) -> GoalTiming {
        let shiftedDate: Date
        switch adjustment {
        case .laterToday:
            shiftedDate = Calendar.current.date(byAdding: .hour, value: 3, to: now) ?? now
        case .laterThisWeek:
            shiftedDate = Calendar.current.date(byAdding: .day, value: 2, to: now) ?? now
        case .someday, .removeDeadline:
            shiftedDate = Calendar.current.date(byAdding: .day, value: 14, to: now) ?? now
        }

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


    func stepVisualState(_ state: StepLifecycleState) -> AmbitionVisualState {
        switch state {
        case .completed: .success
        case .blocked: .warning
        case .active: .selected
        case .cancelled: .default
        case .planned: .default
        }
    }


    func update(goal: Goal, stepID: String, transform: (Step) -> Step) -> Goal {
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
            updatedAt: Self.iso.string(from: .now),
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


    func updateGoalTiming(goal: Goal, transform: (GoalTiming) -> GoalTiming) -> Goal {
        let newGoalTiming = transform(goal.timing)
        let updatedSections = goal.plan?.sections.map { section in
            PlanSection(
                id: section.id,
                goalID: section.goalID,
                title: section.title,
                summary: section.summary,
                kind: section.kind,
                orderIndex: section.orderIndex,
                steps: section.steps.map { step in
                    guard step.state != .completed && step.state != .cancelled else { return step }
                    return Step(
                        id: step.id,
                        sectionID: step.sectionID,
                        title: step.title,
                        summary: step.summary,
                        type: step.type,
                        state: step.state,
                        owner: step.owner,
                        timing: GoalTiming(
                            tempo: newGoalTiming.tempo,
                            timingType: newGoalTiming.timingType,
                            startsOn: step.timing.startsOn,
                            dueAt: nil,
                            targetBy: nil,
                            windowStart: nil,
                            windowEnd: nil,
                            suggestedNextAt: newGoalTiming.suggestedNextAt,
                            repeatEveryDays: step.timing.repeatEveryDays,
                            progressReviewCadenceDays: step.timing.progressReviewCadenceDays
                        ),
                        dependencyStepIDs: step.dependencyStepIDs,
                        isOptional: step.isOptional,
                        isRepeatable: step.isRepeatable,
                        evidenceRequired: step.evidenceRequired,
                        successSignals: step.successSignals,
                        actionability: step.actionability
                    )
                }
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
            updatedAt: Self.iso.string(from: .now),
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
            timing: newGoalTiming,
            planningStrategy: goal.planningStrategy,
            progressStrategy: goal.progressStrategy,
            plan: updatedPlan,
            lifeGraph: goal.lifeGraph
        )
    }


    func nextStepSchedulingSelection(goal: Goal, step: Step) -> NextStepSchedulingSelection {
        NextStepSchedulingSelection(
            goalID: goal.id,
            goalTitle: goal.title,
            stepID: step.id,
            stepTitle: step.title,
            stepSummary: step.summary ?? step.actionability.fallbackMicroStep,
            suggestedDate: parseDate(step.timing.suggestedNextAt ?? step.timing.targetBy ?? step.timing.dueAt)
        )
    }


    func parseDate(_ value: String?) -> Date? {
        guard let value else { return nil }
        return Self.iso.date(from: value) ?? Self.isoFallback.date(from: value) ?? Self.dateOnly.date(from: value)
    }


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


    static var dateOnly: DateFormatter {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }


    static var shortTime: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter
    }


    func calendarEventMessageBody(for title: String, report: CalendarConflictReport?) -> String {
        guard let report else {
            return "\"\(title)\" was added to Calendar."
        }
        if report.hasConflicts {
            let count = report.conflicts.count
            if let nearby = report.nearbyAvailableWindow {
                return "\"\(title)\" was added to Calendar. It overlaps \(count) event\(count == 1 ? "" : "s"). A clearer opening starts around \(Self.shortTime.string(from: nearby.start))."
            }
            return "\"\(title)\" was added to Calendar. It overlaps \(count) event\(count == 1 ? "" : "s")."
        }
        if report.pressure == .high {
            return "\"\(title)\" was added to Calendar. The day looks tight around that block."
        }
        return "\"\(title)\" was added to Calendar."
    }
}
