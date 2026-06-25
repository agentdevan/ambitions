import Foundation

// AMBITIONS-QUALITY-EXTRACTION: Recurring Step lifecycle behavior lives in SimpleStepLifecycleService+Recurring.swift; this file keeps one-shot placement and recovery under the hard 600-line ceiling.
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

struct ScheduledStepPlacementResult: Sendable, Equatable {
    let goalID: String
    let stepID: String
    let windowStart: String
    let windowEnd: String
    let updatedStep: Step
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

    func placeStepInTime(
        goalID: String,
        stepID: String,
        windowStart: Date,
        windowEnd: Date,
        now: Date
    ) async throws -> ScheduledStepPlacementResult {
        guard var goal = try await repositories.goals.goal(id: goalID),
              let selectedStep = goal.plan?.sections.flatMap(\.steps).first(where: { $0.id == stepID }) else {
            throw SimpleStepLifecycleServiceError.stepNotFound
        }

        let startValue = Self.iso.string(from: windowStart)
        let endValue = Self.iso.string(from: max(windowEnd, windowStart))
        goal = update(goal: goal, stepID: stepID, now: now) { step in
            Step(
                id: step.id,
                sectionID: step.sectionID,
                title: step.title,
                summary: step.summary,
                type: step.type,
                state: step.state,
                owner: step.owner,
                timing: GoalTiming(
                    tempo: .targetWindow,
                    timingType: .suggestedNext,
                    startsOn: step.timing.startsOn,
                    dueAt: nil,
                    targetBy: nil,
                    windowStart: startValue,
                    windowEnd: endValue,
                    suggestedNextAt: startValue,
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
        try await repositories.goals.saveGoals([goal])

        let updatedStep = try await repositories.goals.listSteps(goalID: goalID)
            .first(where: { $0.id == stepID }) ?? selectedStep
        try? await repositories.eventLedger.append(
            EventLedgerEntry(
                id: "ledger.time.step.placed.\(goalID).\(stepID).\(startValue)",
                kind: .itemScheduled,
                occurredAt: Self.iso.string(from: now),
                source: .time,
                goalID: goalID,
                title: "Step placed in Time",
                summary: "Local Step placement saved without calendar or network write.",
                semanticState: "local_time_window",
                tone: .neutral,
                trust: EventLedgerTrustMetadata(isUserConfirmed: true),
                evidenceReferences: [
                    EventLedgerEvidenceReference(
                        id: stepID,
                        kind: .goal,
                        occurredAt: startValue,
                        summary: updatedStep.title
                    )
                ],
                metadata: [
                    "stepID": stepID,
                    "windowStart": startValue,
                    "windowEnd": endValue
                ],
                privacy: .standard
            )
        )

        return ScheduledStepPlacementResult(
            goalID: goalID,
            stepID: stepID,
            windowStart: startValue,
            windowEnd: endValue,
            updatedStep: updatedStep
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
            note: "What changed? Recovery asked without blame."
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
            secondaryActionTitles: ["Still counts", "Blocked", "Waiting", "Not needed"],
            updatedStep: updatedStep,
            feedbackEventCount: updatedFeedback.count - existingFeedback.count
        )
    }

    func update(goal: Goal, stepID: String, now: Date, transform: (Step) -> Step) -> Goal {
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

    static var iso: ISO8601DateFormatter {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }
}
