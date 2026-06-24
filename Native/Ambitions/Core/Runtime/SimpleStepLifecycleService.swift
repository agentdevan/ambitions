import Foundation

enum SimpleStepLifecycleServiceError: Error, Equatable {
    case emptyTitle
    case stepNotFound
}

struct SimpleStepLifecycleResult: Sendable, Equatable {
    let goalID: String
    let stepID: String
    let goal: Goal
    let step: Step
}

struct CaptureStepRoutingResult: Sendable, Equatable {
    let captureID: String
    let goalID: String
    let stepID: String
    let stepTitle: String
}

struct MissedStepRecoveryResult: Sendable, Equatable {
    let goalID: String
    let stepID: String
    let promptTitle: String
    let promptBody: String
    let primaryActionTitle: String
    let secondaryActionTitles: [String]
    let updatedStep: Step
    let feedbackEventCount: Int

    var asksWhatChanged: Bool {
        promptTitle == "What changed?"
    }
}

struct RecurringStepOccurrence: Sendable, Equatable, Identifiable {
    let id: String
    let goalID: String
    let stepID: String
    let scheduledAt: String
    let title: String
    let isPaused: Bool
}

struct RecurringStepLifecycleResult: Sendable, Equatable {
    let goalID: String
    let stepID: String
    let goal: Goal
    let step: Step
    let nextOccurrence: RecurringStepOccurrence
}

struct RecurringStepCompletionResult: Sendable, Equatable {
    let goalID: String
    let stepID: String
    let completedOccurrenceID: String
    let updatedStep: Step
    let nextOccurrence: RecurringStepOccurrence?
    let feedbackEventCount: Int
    let evidenceCount: Int

    var preservesRecurrence: Bool {
        updatedStep.state != .completed && updatedStep.isRepeatable && updatedStep.timing.repeatEveryDays != nil
    }
}

struct RecurringStepPauseResult: Sendable, Equatable {
    let goalID: String
    let stepID: String
    let isPaused: Bool
    let generatedOccurrences: [RecurringStepOccurrence]
}

struct SimpleStepLifecycleService: Sendable {
    let repositories: AppRepositories
    let idProvider: @Sendable () -> String

    init(
        repositories: AppRepositories,
        idProvider: @escaping @Sendable () -> String = { UUID().uuidString }
    ) {
        self.repositories = repositories
        self.idProvider = idProvider
    }

    func createSimpleStep(
        title rawTitle: String,
        summary: String? = nil,
        now: Date
    ) async throws -> SimpleStepLifecycleResult {
        let title = rawTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard title.isEmpty == false else {
            throw SimpleStepLifecycleServiceError.emptyTitle
        }

        let idRoot = idProvider()
        let timestamp = Self.iso.string(from: now)
        let goalID = "simple-step-goal-\(idRoot)"
        let planID = "simple-step-plan-\(idRoot)"
        let sectionID = "simple-step-section-\(idRoot)"
        let stepID = "simple-step-\(idRoot)"
        let fallback = "Do the smallest useful part of: \(title)"
        let actor = GoalActor(
            actorID: "self",
            displayName: "You",
            ownership: .self,
            roleLabel: nil,
            isPrimary: true
        )
        let timing = GoalTiming(
            tempo: .untimed,
            timingType: .suggestedNext,
            startsOn: timestamp,
            dueAt: nil,
            targetBy: nil,
            windowStart: nil,
            windowEnd: nil,
            suggestedNextAt: timestamp,
            repeatEveryDays: nil,
            progressReviewCadenceDays: nil
        )
        let step = Step(
            id: stepID,
            sectionID: sectionID,
            title: title,
            summary: summary,
            type: .actionUnit,
            state: .planned,
            owner: actor,
            timing: timing,
            dependencyStepIDs: [],
            isOptional: false,
            isRepeatable: false,
            evidenceRequired: false,
            successSignals: ["Step exists locally", "Step can be closed with a receipt"],
            actionability: StepActionability(
                action: title,
                completionDefinition: "The Step has been honestly completed or closed.",
                evidenceOfCompletion: ["Local closure receipt", "Local feedback event"],
                fallbackMicroStep: fallback,
                contextRequirements: []
            )
        )
        let section = PlanSection(
            id: sectionID,
            goalID: goalID,
            title: "Simple Step",
            summary: "One local Step created without account or network requirements.",
            kind: .activeSteps,
            orderIndex: 0,
            steps: [step]
        )
        let plan = GoalPlan(
            id: planID,
            goalID: goalID,
            version: goalEnginePlanVersion,
            generatedAt: timestamp,
            summary: "One local Step.",
            strategy: PlanningStrategy(
                strategyKind: .sequential,
                allowParallelSteps: false,
                maxActiveSteps: 1,
                preferredSectionOrder: [.activeSteps],
                defaultStepType: .actionUnit,
                autoGenerateReviewSection: false,
                preferShortSteps: true,
                revisitCadenceDays: 7
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
            mode: .project,
            relationshipKind: .independent,
            actor: actor,
            parentGoalID: nil,
            childGoalIDs: [],
            supportGoalIDs: [],
            tags: ["simple-step"],
            timing: timing,
            planningStrategy: plan.strategy,
            progressStrategy: ProgressStrategy(
                metricKind: .stepCompletion,
                rollupMethod: .ratio,
                targetStepCount: 1,
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
        return SimpleStepLifecycleResult(goalID: goalID, stepID: stepID, goal: goal, step: step)
    }

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

    func markMissedStepForRecovery(
        goalID: String,
        stepID: String,
        now: Date
    ) async throws -> MissedStepRecoveryResult {
        guard var goal = try await repositories.goals.goal(id: goalID),
              let selectedStep = goal.plan?.sections.flatMap(\.steps).first(where: { $0.id == stepID }) else {
            throw SimpleStepLifecycleServiceError.stepNotFound
        }

        let existingFeedback = try await repositories.feedback.listEvents(goalID: goalID)
        let decision = RescheduleEngine().decide(
            RescheduleEngineInput(
                stepID: stepID,
                timing: selectedStep.timing,
                feedbackHistory: existingFeedback,
                trigger: .skip,
                fallbackMicroStep: selectedStep.actionability.fallbackMicroStep,
                now: now,
                stepState: selectedStep.state
            )
        )
        let timestamp = Self.iso.string(from: now)
        let timingAdjustment = decision.timingAdjustment ?? .laterThisWeek
        let missedBase = GoalFeedbackEventBase(
            id: "simple-step-missed-\(idProvider())",
            stepID: stepID,
            occurredAt: timestamp,
            note: "What changed? Recovery asked without shame."
        )
        var updatedFeedback = existingFeedback
        updatedFeedback.append(.skipped(base: missedBase, reasonCode: .notNow))
        updatedFeedback.append(
            .delayed(
                base: GoalFeedbackEventBase(
                    id: "simple-step-move-\(idProvider())",
                    stepID: stepID,
                    occurredAt: timestamp,
                    note: decision.rationale
                ),
                timingAdjustment: timingAdjustment,
                date: decision.suggestedTime
            )
        )
        try await repositories.feedback.saveEvents(updatedFeedback, goalID: goalID)

        goal = update(goal: goal, stepID: stepID, now: now) { step in
            Step(
                id: step.id,
                sectionID: step.sectionID,
                title: step.title,
                summary: decision.recoverySummary ?? decision.smallerStep?.summary ?? step.summary,
                type: step.type,
                state: step.state,
                owner: step.owner,
                timing: shiftedTiming(for: step.timing, now: now, adjustment: timingAdjustment),
                dependencyStepIDs: step.dependencyStepIDs,
                isOptional: step.isOptional,
                isRepeatable: step.isRepeatable,
                evidenceRequired: step.evidenceRequired,
                successSignals: step.successSignals,
                actionability: step.actionability
            )
        }
        try await repositories.goals.saveGoals([goal])

        for event in updatedFeedback.suffix(2) {
            try? await repositories.eventLedger.append(EventLedgerEntry.fromFeedbackEvent(event, goalID: goalID, source: .today))
        }

        let updatedSteps = try await repositories.goals.listSteps(goalID: goalID)
        let updatedStep = updatedSteps.first(where: { $0.id == stepID }) ?? selectedStep
        return MissedStepRecoveryResult(
            goalID: goalID,
            stepID: stepID,
            promptTitle: "What changed?",
            promptBody: "Move it without blame. \(decision.recoverySummary ?? "Choose the next believable time before trying again.")",
            primaryActionTitle: "Move it",
            secondaryActionTitles: ["Still counts", "Blocked", "Not needed"],
            updatedStep: updatedStep,
            feedbackEventCount: updatedFeedback.count - existingFeedback.count
        )
    }

    private func update(goal: Goal, stepID: String, now: Date, transform: (Step) -> Step) -> Goal {
        let sections = goal.plan?.sections.map { section in
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
        let plan = goal.plan.map {
            GoalPlan(
                id: $0.id,
                goalID: $0.goalID,
                version: $0.version,
                generatedAt: $0.generatedAt,
                summary: $0.summary,
                strategy: $0.strategy,
                sections: sections ?? $0.sections,
                assumptions: $0.assumptions,
                lint: $0.lint
            )
        }
        return Goal(
            schemaVersion: goal.schemaVersion,
            id: goal.id,
            revision: goal.revision + 1,
            createdAt: goal.createdAt,
            updatedAt: Self.iso.string(from: now),
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
            plan: plan,
            lifeGraph: goal.lifeGraph
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
              var cursor = date(from: firstScheduledAt) else {
            return []
        }

        let cadenceDays = TimeRitualGoalSemantics.cadenceDays(goal: goal, step: step)
        while cursor < start {
            cursor = calendar.date(byAdding: .day, value: cadenceDays, to: cursor) ?? start
        }

        var occurrences: [RecurringStepOccurrence] = []
        while occurrences.count < limit {
            let scheduledAt = iso.string(from: cursor)
            occurrences.append(
                RecurringStepOccurrence(
                    id: occurrenceID(stepID: step.id, scheduledAt: scheduledAt),
                    goalID: goal.id,
                    stepID: step.id,
                    scheduledAt: scheduledAt,
                    title: step.title,
                    isPaused: false
                )
            )
            cursor = calendar.date(byAdding: .day, value: cadenceDays, to: cursor) ?? cursor
        }
        return occurrences
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

    private static var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .current
        return calendar
    }

    private func shiftedTiming(for timing: GoalTiming, now: Date, adjustment: GoalTimingAdjustment) -> GoalTiming {
        let shiftedDate: Date
        switch adjustment {
        case .laterToday:
            shiftedDate = Calendar(identifier: .gregorian).date(byAdding: .hour, value: 3, to: now) ?? now
        case .laterThisWeek:
            shiftedDate = Calendar(identifier: .gregorian).date(byAdding: .day, value: 2, to: now) ?? now
        case .someday:
            shiftedDate = Calendar(identifier: .gregorian).date(byAdding: .day, value: 14, to: now) ?? now
        case .removeDeadline:
            shiftedDate = now
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

    private static var iso: ISO8601DateFormatter {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }
}
