import Foundation

extension SimpleStepLifecycleService {
    func createRecurringStep(
        title rawTitle: String,
        summary: String? = nil,
        repeatEveryDays rawRepeatEveryDays: Int = 7,
        now: Date
    ) async throws -> RecurringStepLifecycleResult {
        let title = rawTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard title.isEmpty == false else {
            throw SimpleStepLifecycleServiceError.emptyTitle
        }

        let repeatEveryDays = max(1, rawRepeatEveryDays)
        let idRoot = idProvider()
        let timestamp = Self.iso.string(from: now)
        let goalID = "recurring-step-goal-\(idRoot)"
        let planID = "recurring-step-plan-\(idRoot)"
        let sectionID = "recurring-step-section-\(idRoot)"
        let stepID = "recurring-step-\(idRoot)"
        let fallback = "Do the smallest useful version of: \(title)"
        let actor = GoalActor.localOwner
        let timing = GoalTiming(
            tempo: .ongoing,
            timingType: .repeatWithinWindow,
            startsOn: timestamp,
            dueAt: nil,
            targetBy: nil,
            windowStart: nil,
            windowEnd: nil,
            suggestedNextAt: timestamp,
            repeatEveryDays: repeatEveryDays,
            progressReviewCadenceDays: repeatEveryDays
        )
        let step = Step(
            id: stepID,
            sectionID: sectionID,
            title: title,
            summary: summary,
            type: .recurringRoutine,
            state: .planned,
            owner: actor,
            timing: timing,
            dependencyStepIDs: [],
            isOptional: false,
            isRepeatable: true,
            evidenceRequired: false,
            successSignals: ["Recurring Step exists locally", "Each occurrence can be closed without ending the recurrence"],
            actionability: StepActionability(
                action: title,
                completionDefinition: "This occurrence has been honestly completed or closed.",
                evidenceOfCompletion: ["Local recurring Step occurrence receipt", "Local feedback event"],
                fallbackMicroStep: fallback,
                contextRequirements: ["recurrence", "offline local store"]
            )
        )
        let section = PlanSection(
            id: sectionID,
            goalID: goalID,
            title: "Recurring Step",
            summary: "One local repeating Step created without account or network requirements.",
            kind: .activeSteps,
            orderIndex: 0,
            steps: [step]
        )
        let plan = GoalPlan(
            id: planID,
            goalID: goalID,
            version: goalEnginePlanVersion,
            generatedAt: timestamp,
            summary: "One local recurring Step.",
            strategy: PlanningStrategy(
                strategyKind: .cadence,
                allowParallelSteps: false,
                maxActiveSteps: 1,
                preferredSectionOrder: [.activeSteps],
                defaultStepType: .recurringRoutine,
                autoGenerateReviewSection: false,
                preferShortSteps: true,
                revisitCadenceDays: repeatEveryDays
            ),
            sections: [section],
            assumptions: [],
            lint: PlanLintResult(goalID: goalID, planVersion: goalEnginePlanVersion, isValid: true, issueCount: 0, issues: [])
        )
        let goal = Goal(
            schemaVersion: goalEngineSchemaVersion,
            id: goalID,
            revision: 1,
            createdAt: timestamp,
            updatedAt: timestamp,
            state: .active,
            title: title,
            summary: summary,
            mode: .maintenance,
            relationshipKind: .independent,
            actor: actor,
            parentGoalID: nil,
            childGoalIDs: [],
            supportGoalIDs: [],
            tags: ["recurring-step", "local-only"],
            timing: timing,
            planningStrategy: plan.strategy,
            progressStrategy: ProgressStrategy(
                metricKind: .stepCompletion,
                rollupMethod: .ratio,
                targetStepCount: nil,
                targetEvidenceCount: nil,
                targetMinutes: nil,
                supportsUntimedProgress: true,
                countsChildGoals: false,
                countsSupportGoals: false
            ),
            plan: plan,
            lifeGraph: nil
        )

        try await repositories.goals.saveGoals([goal])
        let occurrence = RecurringStepOccurrence(
            id: Self.occurrenceID(stepID: stepID, scheduledAt: timestamp),
            goalID: goalID,
            stepID: stepID,
            scheduledAt: timestamp,
            title: title,
            isPaused: false
        )
        return RecurringStepLifecycleResult(goalID: goalID, stepID: stepID, goal: goal, step: step, nextOccurrence: occurrence)
    }

    func scheduledOccurrences(
        goalID: String,
        stepID: String,
        from start: Date,
        limit rawLimit: Int = 3
    ) async throws -> [RecurringStepOccurrence] {
        guard let goal = try await repositories.goals.goal(id: goalID),
              let step = goal.plan?.sections.flatMap(\.steps).first(where: { $0.id == stepID }) else {
            throw SimpleStepLifecycleServiceError.stepNotFound
        }
        return Self.scheduledOccurrences(goal: goal, step: step, from: start, limit: rawLimit)
    }

    func completeRecurringOccurrence(
        goalID: String,
        stepID: String,
        occurrenceID: String,
        now: Date
    ) async throws -> RecurringStepCompletionResult {
        guard var goal = try await repositories.goals.goal(id: goalID),
              let selectedStep = goal.plan?.sections.flatMap(\.steps).first(where: { $0.id == stepID }) else {
            throw SimpleStepLifecycleServiceError.stepNotFound
        }

        let occurrenceAnchor = Self.date(
            from: selectedStep.timing.startsOn
                ?? goal.timing.startsOn
                ?? goal.createdAt
        ) ?? now
        let occurrences = Self.scheduledOccurrences(goal: goal, step: selectedStep, from: occurrenceAnchor, limit: 64)
        guard occurrences.contains(where: { $0.id == occurrenceID }) else {
            throw SimpleStepLifecycleServiceError.stepNotFound
        }

        let existingFeedback = try await repositories.feedback.listEvents(goalID: goalID)
        let existingEvidence = try await repositories.evidence.listEvidence(goalID: goalID)
        let timestamp = Self.iso.string(from: now)
        let completedBase = GoalFeedbackEventBase(
            id: "recurring-step-completed-\(idProvider())",
            stepID: stepID,
            occurredAt: timestamp,
            note: "Recurring Step occurrence completed locally."
        )
        var updatedFeedback = existingFeedback
        updatedFeedback.append(.completed(base: completedBase, actualDuration: nil, effortLevel: .medium, confidenceDelta: 0.04))
        try await repositories.feedback.saveEvents(updatedFeedback, goalID: goalID)

        var updatedEvidence = existingEvidence
        updatedEvidence.append(
            ProgressEvidence(
                id: "recurring-step-evidence-\(idProvider())",
                goalID: goalID,
                stepID: stepID,
                evidenceKind: .ritualCompletion,
                source: .manual,
                capturedAt: timestamp,
                progressDelta: 0.1,
                confidenceDelta: 0.04,
                minutesInvested: nil,
                note: "Completed one recurring Step occurrence without ending the recurrence."
            )
        )
        try await repositories.evidence.saveEvidence(updatedEvidence)

        let cadenceDays = TimeRitualGoalSemantics.cadenceDays(goal: goal, step: selectedStep)
        goal = update(goal: goal, stepID: stepID, now: now) { step in
            Step(
                id: step.id,
                sectionID: step.sectionID,
                title: step.title,
                summary: step.summary,
                type: step.type,
                state: .planned,
                owner: step.owner,
                timing: TimeRitualGoalSemantics.advancedTiming(from: step.timing, now: now, cadenceDays: cadenceDays),
                dependencyStepIDs: step.dependencyStepIDs,
                isOptional: step.isOptional,
                isRepeatable: true,
                evidenceRequired: step.evidenceRequired,
                successSignals: step.successSignals,
                actionability: step.actionability
            )
        }
        try await repositories.goals.saveGoals([goal])

        let updatedStep = try await repositories.goals.listSteps(goalID: goalID)
            .first(where: { $0.id == stepID }) ?? selectedStep
        let nextOccurrence = Self.scheduledOccurrences(goal: goal, step: updatedStep, from: now, limit: 1).first
        return RecurringStepCompletionResult(
            goalID: goalID,
            stepID: stepID,
            completedOccurrenceID: occurrenceID,
            updatedStep: updatedStep,
            nextOccurrence: nextOccurrence,
            feedbackEventCount: updatedFeedback.count - existingFeedback.count,
            evidenceCount: updatedEvidence.count - existingEvidence.count
        )
    }

    func pauseRecurrence(goalID: String, stepID: String, now: Date) async throws -> RecurringStepPauseResult {
        let goal = try await recurringGoal(goalID: goalID, stepID: stepID)
        let paused = remake(goal: goal, state: .paused, now: now)
        try await repositories.goals.saveGoals([paused])
        return RecurringStepPauseResult(goalID: goalID, stepID: stepID, isPaused: true, generatedOccurrences: [])
    }

    func resumeRecurrence(goalID: String, stepID: String, now: Date) async throws -> RecurringStepPauseResult {
        let goal = try await recurringGoal(goalID: goalID, stepID: stepID)
        let resumed = remake(goal: goal, state: .active, now: now)
        try await repositories.goals.saveGoals([resumed])
        let step = resumed.plan?.sections.flatMap(\.steps).first(where: { $0.id == stepID })
        return RecurringStepPauseResult(
            goalID: goalID,
            stepID: stepID,
            isPaused: false,
            generatedOccurrences: step.map { Self.scheduledOccurrences(goal: resumed, step: $0, from: now, limit: 1) } ?? []
        )
    }

    private func recurringGoal(goalID: String, stepID: String) async throws -> Goal {
        guard let goal = try await repositories.goals.goal(id: goalID),
              goal.plan?.sections.flatMap(\.steps).contains(where: { $0.id == stepID }) == true else {
            throw SimpleStepLifecycleServiceError.stepNotFound
        }
        return goal
    }

    private func remake(goal: Goal, state: GoalLifecycleState, now: Date) -> Goal {
        Goal(
            schemaVersion: goal.schemaVersion,
            id: goal.id,
            revision: goal.revision + 1,
            createdAt: goal.createdAt,
            updatedAt: Self.iso.string(from: now),
            state: state,
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
            plan: goal.plan,
            lifeGraph: goal.lifeGraph
        )
    }

    private static func scheduledOccurrences(
        goal: Goal,
        step: Step,
        from start: Date,
        limit rawLimit: Int
    ) -> [RecurringStepOccurrence] {
        let limit = max(0, rawLimit)
        let firstScheduledAt = step.timing.suggestedNextAt
            ?? step.timing.startsOn
            ?? goal.timing.suggestedNextAt
            ?? goal.timing.startsOn
            ?? goal.createdAt
        guard limit > 0,
              goal.state != .paused,
              step.state != .cancelled,
              step.isRepeatable || step.type == .recurringRoutine,
              let cursor = date(from: firstScheduledAt) else {
            return []
        }

        let seed = TimeRecurrenceSeed(
            id: step.id,
            title: step.title,
            startsAt: cursor,
            rule: TimeRecurrenceRule(cadenceDays: TimeRitualGoalSemantics.cadenceDays(goal: goal, step: step)),
            isPaused: false,
            localOnly: true
        )
        return RecurrenceEngine().occurrences(seed: seed, from: start, limit: limit).map { occurrence in
            let scheduledAt = iso.string(from: occurrence.scheduledAt)
            return RecurringStepOccurrence(
                id: occurrenceID(stepID: step.id, scheduledAt: scheduledAt),
                goalID: goal.id,
                stepID: step.id,
                scheduledAt: scheduledAt,
                title: step.title,
                isPaused: false
            )
        }
    }

    private static func occurrenceID(stepID: String, scheduledAt: String) -> String {
        let normalizedSchedule = scheduledAt
            .replacingOccurrences(of: ":", with: "")
            .replacingOccurrences(of: ".", with: "")
        return "\(stepID)-occurrence-\(normalizedSchedule)"
    }

    private static func date(from value: String) -> Date? {
        iso.date(from: value) ?? ISO8601DateFormatter().date(from: value)
    }
}
