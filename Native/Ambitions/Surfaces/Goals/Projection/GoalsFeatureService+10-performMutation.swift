import AmbitionsDesignSystem
import Foundation

extension RepositoryBackedGoalsService {

    func performMutation(
        request: GoalDetailActionRequest,
        detail: DetailContext,
        now: Date
    ) async throws -> GoalDetailActionResponse {
        if request.kind == .raisePriority || request.kind == .lowerPriority {
            return try await adjustPriority(for: detail, direction: request.kind == .raisePriority ? -1 : 1)
        }

        guard var goal = detail.goal else {
            throw GoalsFeatureError.notActionable
        }

        guard let stepID = request.stepID ?? detail.primaryStep?.id,
              let selectedStep = goal.plan?.sections.flatMap(\.steps).first(where: { $0.id == stepID }) else {
            if request.kind == .switchToUntimed {
                let updatedGoal = updateGoalTiming(goal: goal) { timing in
                    GoalTiming(
                        tempo: .untimed,
                        timingType: .logWhenDone,
                        startsOn: timing.startsOn,
                        dueAt: nil,
                        targetBy: nil,
                        windowStart: nil,
                        windowEnd: nil,
                        suggestedNextAt: nil,
                        repeatEveryDays: timing.repeatEveryDays,
                        progressReviewCadenceDays: timing.progressReviewCadenceDays
                    )
                }
                try await repositories.goals.saveGoals([updatedGoal])
                return GoalDetailActionResponse(
                    message: GoalDetailInlineMessage(
                        title: "Timing softened",
                        body: "This goal now treats progress as log-when-done work instead of carrying fake deadline pressure.",
                        state: .selected
                    )
                )
            }
            throw GoalsFeatureError.missingStep
        }

        let timestamp = Self.iso.string(from: now)
        var history = try await repositories.feedback.listEvents(goalID: goal.id)
        let base = GoalFeedbackEventBase(
            id: "goal-detail-\(request.kind.rawValue)-\(UUID().uuidString)",
            stepID: selectedStep.id,
            occurredAt: timestamp,
            note: note(for: request.kind, step: selectedStep)
        )

        switch request.kind {
        case .complete:
            history.append(.completed(base: base, actualDuration: 25, effortLevel: .medium, confidenceDelta: 0.08))
            try await repositories.feedback.saveEvents(history, goalID: goal.id)
            try await repositories.evidence.saveEvidence([
                ProgressEvidence(
                    id: "evidence-\(UUID().uuidString)",
                    goalID: goal.id,
                    stepID: selectedStep.id,
                    evidenceKind: TimeRitualGoalSemantics.isRitualLike(goal: goal, step: selectedStep) ? .ritualCompletion : .stepCompleted,
                    source: .manual,
                    capturedAt: timestamp,
                    progressDelta: 0.18,
                    confidenceDelta: 0.08,
                    minutesInvested: 25,
                    note: "Completed from Goal Detail."
                )
            ])
            if TimeRitualGoalSemantics.isRitualLike(goal: goal, step: selectedStep) {
                let cadenceDays = TimeRitualGoalSemantics.cadenceDays(goal: goal, step: selectedStep)
                goal = update(goal: goal, stepID: selectedStep.id) { step in
                    updatedStep(
                        step,
                        summary: step.summary ?? step.actionability.fallbackMicroStep,
                        timing: TimeRitualGoalSemantics.advancedTiming(from: step.timing, now: now, cadenceDays: cadenceDays)
                    )
                }
            } else {
                goal = update(goal: goal, stepID: selectedStep.id) { step in
                    Step(
                        id: step.id,
                        sectionID: step.sectionID,
                        title: step.title,
                        summary: step.summary,
                        type: step.type,
                        state: .completed,
                        owner: step.owner,
                        timing: step.timing,
                        dependencyStepIDs: step.dependencyStepIDs,
                        isOptional: step.isOptional,
                        isRepeatable: step.isRepeatable,
                        evidenceRequired: step.evidenceRequired,
                        successSignals: step.successSignals,
                        actionability: step.actionability
                    )
                }
            }
            try await repositories.goals.saveGoals([goal])
            return GoalDetailActionResponse(
                message: GoalDetailInlineMessage(
                    title: TimeRitualGoalSemantics.isRitualLike(goal: goal, step: selectedStep) ? "Ritual logged" : "Completion recorded",
                    body: TimeRitualGoalSemantics.isRitualLike(goal: goal, step: selectedStep)
                        ? "\"\(selectedStep.title)\" now lands in native evidence while staying active as a recurring rhythm."
                        : "\"\(selectedStep.title)\" now lands in native evidence and plan history.",
                    state: .success
                )
            )
        case .delay:
            let decision = rescheduleDecision(for: request.kind, goal: goal, step: selectedStep, history: history, now: now)
            let adjustment = decision?.timingAdjustment ?? .laterToday
            history.append(.delayed(base: base, timingAdjustment: adjustment, date: decision?.suggestedTime))
            if let smaller = decision?.smallerStep {
                history.append(
                    .askedForSmallerVersion(
                        base: GoalFeedbackEventBase(
                            id: "goal-detail-delay-smaller-\(UUID().uuidString)",
                            stepID: selectedStep.id,
                            occurredAt: timestamp,
                            note: smaller.note
                        )
                    )
                )
            }
            try await repositories.feedback.saveEvents(history, goalID: goal.id)
            goal = update(goal: goal, stepID: selectedStep.id) { step in
                updatedStep(
                    step,
                    summary: decision?.recoverySummary ?? decision?.smallerStep?.summary ?? step.summary ?? step.actionability.fallbackMicroStep,
                    timing: shiftedTiming(for: step.timing, now: now, adjustment: adjustment)
                )
            }
            try await repositories.goals.saveGoals([goal])
            let deferLine: String = {
                guard let decision, decision.deferRecommendation.indicatesDeferral else { return "" }
                return " The next attempt was deferred to keep pressure realistic."
            }()
            return GoalDetailActionResponse(
                message: GoalDetailInlineMessage(
                    title: "Pressure reduced",
                    body: "The step remains visible, but the timing is gentler now.\(deferLine)",
                    state: .selected
                )
            )
        case .skip:
            history.append(.skipped(base: base, reasonCode: .notNow))
            let decision = rescheduleDecision(for: request.kind, goal: goal, step: selectedStep, history: history, now: now)
            if let adjustment = decision?.timingAdjustment {
                history.append(
                    .delayed(
                        base: GoalFeedbackEventBase(
                            id: "goal-detail-skip-delay-\(UUID().uuidString)",
                            stepID: selectedStep.id,
                            occurredAt: timestamp,
                            note: decision?.rationale
                        ),
                        timingAdjustment: adjustment,
                        date: decision?.suggestedTime
                    )
                )
            }
            if let smaller = decision?.smallerStep {
                history.append(
                    .askedForSmallerVersion(
                        base: GoalFeedbackEventBase(
                            id: "goal-detail-skip-smaller-\(UUID().uuidString)",
                            stepID: selectedStep.id,
                            occurredAt: timestamp,
                            note: smaller.note
                        )
                    )
                )
            }
            try await repositories.feedback.saveEvents(history, goalID: goal.id)
            goal = update(goal: goal, stepID: selectedStep.id) { step in
                updatedStep(
                    step,
                    summary: decision?.recoverySummary ?? decision?.smallerStep?.summary ?? step.summary ?? step.actionability.fallbackMicroStep,
                    timing: shiftedTiming(for: step.timing, now: now, adjustment: decision?.timingAdjustment ?? .laterThisWeek)
                )
            }
            try await repositories.goals.saveGoals([goal])
            let deferLine: String = {
                guard let decision, decision.deferRecommendation.indicatesDeferral else { return "" }
                return " The next attempt is intentionally deferred to avoid churn."
            }()
            return GoalDetailActionResponse(
                message: GoalDetailInlineMessage(
                    title: "Rescheduled",
                    body: "The path stays intact without treating one skipped step like failure.\(deferLine)",
                    state: .warning
                )
            )
        case .createReminder:
            let selection = nextStepSchedulingSelection(goal: goal, step: selectedStep)
            let authorization = await calendarRemindersService.requestAuthorizationIfNeeded(for: .reminders)
            guard authorization.canWrite else {
                return GoalDetailActionResponse(
                    message: GoalDetailInlineMessage(
                        title: "Reminders permission needed",
                        body: "Enable Reminders access to create next-step reminders from Ambitions.",
                        state: .warning
                    )
                )
            }

            let localCommit = try await externalEffectCommitEvidence(
                operationID: request.operationID,
                kind: .reminder,
                goal: goal,
                step: selectedStep,
                now: now
            )
            _ = try await calendarRemindersService.createReminder(
                for: selection,
                now: now,
                operationID: request.operationID,
                localCommit: localCommit
            )
            return GoalDetailActionResponse(
                message: GoalDetailInlineMessage(
                    title: "Reminder created",
                    body: "\"\(selectedStep.title)\" was added to Reminders.",
                    state: .success
                )
            )
        case .createCalendarEvent:
            let selection = nextStepSchedulingSelection(goal: goal, step: selectedStep)
            let authorization = await calendarRemindersService.authorizationState(for: .calendarEvents)
            guard authorization.canWrite else {
                return GoalDetailActionResponse(
                    message: GoalDetailInlineMessage(
                        title: "Use Time for Calendar access",
                        body: "Time works without Calendar. To add calendar-aware blocks, open Time and choose Make Time calendar-aware first.",
                        state: .warning
                    )
                )
            }

            let conflictReport = await calendarRemindersService.detectConflicts(for: selection, durationMinutes: 45, now: now)
            let localCommit = try await externalEffectCommitEvidence(
                operationID: request.operationID,
                kind: .calendarEvent,
                goal: goal,
                step: selectedStep,
                now: now
            )
            let event = try await calendarRemindersService.createCalendarEvent(
                for: selection,
                durationMinutes: 45,
                now: now,
                operationID: request.operationID,
                localCommit: localCommit
            )
            return GoalDetailActionResponse(
                message: GoalDetailInlineMessage(
                    title: "Calendar event created",
                    body: calendarEventMessageBody(for: event.title, report: conflictReport),
                    state: .success
                )
            )
        case .markNotRelevant:
            history.append(.notRelevant(base: base))
            try await repositories.feedback.saveEvents(history, goalID: goal.id)
            goal = update(goal: goal, stepID: selectedStep.id) { step in
                Step(
                    id: step.id,
                    sectionID: step.sectionID,
                    title: step.title,
                    summary: step.summary,
                    type: step.type,
                    state: .cancelled,
                    owner: step.owner,
                    timing: step.timing,
                    dependencyStepIDs: step.dependencyStepIDs,
                    isOptional: step.isOptional,
                    isRepeatable: step.isRepeatable,
                    evidenceRequired: step.evidenceRequired,
                    successSignals: step.successSignals,
                    actionability: step.actionability
                )
            }
            try await repositories.goals.saveGoals([goal])
            return GoalDetailActionResponse(
                message: GoalDetailInlineMessage(
                    title: "Relevance updated",
                    body: "That step is no longer pushing the plan forward until a better version replaces it.",
                    state: .warning
                )
            )
        case .askWhyThisMatters:
            history.append(.askedWhyThisMatters(base: base))
            try await repositories.feedback.saveEvents(history, goalID: goal.id)
            let projectedExplanation = try await goalIntelligenceContext(
                for: detail,
                primaryStepID: selectedStep.id,
                includeWhyNow: true,
                now: now
            )?.explainability.whyThis.compactSummary ?? detail.draft?.metadata.map { metadata in
                explainabilityProjector.makeState(
                    metadata: metadata,
                    applicableSignals: nil,
                    primaryStepID: selectedStep.id,
                    whyNow: learningService.learnedStepInsight(
                        goal: goal,
                        step: selectedStep,
                        snapshot: learningService.buildSnapshot(
                            goals: [goal],
                            evidence: detail.evidence,
                            feedback: history,
                            now: now
                        ),
                        now: now
                    ).whyNow
                ).whyThis.compactSummary
            }
            let explanation = projectedExplanation
                ?? detail.draft.flatMap { draft in
                    adjustmentPayload(draft: draft, goal: goal, step: selectedStep, history: history)?.explanationHook?.explanation
                        ?? createWhyThisMattersExplanation(draft: draft.draft, step: selectedStep).explanation
                } ?? "\(selectedStep.title) matters because it advances \(goal.title.lowercased()) through something observable and finishable."
            return GoalDetailActionResponse(
                message: GoalDetailInlineMessage(
                    title: "Why this matters",
                    body: explanation,
                    state: .selected
                )
            )
        case .askForSmallerStep:
            let decision = rescheduleDecision(for: request.kind, goal: goal, step: selectedStep, history: history, now: now)
            history.append(.askedForSmallerVersion(base: base))
            if let adjustment = decision?.timingAdjustment {
                history.append(
                    .delayed(
                        base: GoalFeedbackEventBase(
                            id: "goal-detail-smaller-delay-\(UUID().uuidString)",
                            stepID: selectedStep.id,
                            occurredAt: timestamp,
                            note: decision?.rationale
                        ),
                        timingAdjustment: adjustment,
                        date: decision?.suggestedTime
                    )
                )
            }
            try await repositories.feedback.saveEvents(history, goalID: goal.id)
            goal = update(goal: goal, stepID: selectedStep.id) { step in
                let timing = decision?.timingAdjustment.map { shiftedTiming(for: step.timing, now: now, adjustment: $0) } ?? step.timing
                return updatedStep(
                    step,
                    summary: decision?.recoverySummary ?? decision?.smallerStep?.summary ?? step.actionability.fallbackMicroStep,
                    timing: timing
                )
            }
            try await repositories.goals.saveGoals([goal])
            return GoalDetailActionResponse(
                message: GoalDetailInlineMessage(
                    title: "Smaller version ready",
                    body: decision?.recoverySummary ?? decision?.smallerStep?.summary ?? selectedStep.actionability.fallbackMicroStep,
                    state: .selected
                )
            )
        case .breakThisDownSmaller:
            let decision = rescheduleDecision(for: request.kind, goal: goal, step: selectedStep, history: history, now: now)
            history.append(.tooBig(base: base))
            history.append(.askedForSmallerVersion(base: GoalFeedbackEventBase(id: "smaller-\(UUID().uuidString)", stepID: selectedStep.id, occurredAt: timestamp, note: "Break this down smaller.")))
            if let adjustment = decision?.timingAdjustment {
                history.append(
                    .delayed(
                        base: GoalFeedbackEventBase(
                            id: "goal-detail-break-delay-\(UUID().uuidString)",
                            stepID: selectedStep.id,
                            occurredAt: timestamp,
                            note: decision?.rationale
                        ),
                        timingAdjustment: adjustment,
                        date: decision?.suggestedTime
                    )
                )
            }
            try await repositories.feedback.saveEvents(history, goalID: goal.id)
            goal = update(goal: goal, stepID: selectedStep.id) { step in
                let timing = decision?.timingAdjustment.map { shiftedTiming(for: step.timing, now: now, adjustment: $0) } ?? step.timing
                return updatedStep(
                    step,
                    summary: decision?.recoverySummary ?? decision?.smallerStep?.summary ?? step.actionability.fallbackMicroStep,
                    timing: timing
                )
            }
            try await repositories.goals.saveGoals([goal])
            return GoalDetailActionResponse(
                message: GoalDetailInlineMessage(
                    title: "Broken down smaller",
                    body: decision?.recoverySummary ?? decision?.smallerStep?.summary ?? selectedStep.actionability.fallbackMicroStep,
                    state: .selected
                )
            )
        case .imStuck:
            let decision = rescheduleDecision(for: request.kind, goal: goal, step: selectedStep, history: history, now: now)
            history.append(.confused(base: base, confusionType: .unclearAction))
            if let smaller = decision?.smallerStep {
                history.append(
                    .askedForSmallerVersion(
                        base: GoalFeedbackEventBase(
                            id: "goal-detail-stuck-smaller-\(UUID().uuidString)",
                            stepID: selectedStep.id,
                            occurredAt: timestamp,
                            note: smaller.note
                        )
                    )
                )
            }
            if let adjustment = decision?.timingAdjustment {
                history.append(
                    .delayed(
                        base: GoalFeedbackEventBase(
                            id: "goal-detail-stuck-delay-\(UUID().uuidString)",
                            stepID: selectedStep.id,
                            occurredAt: timestamp,
                            note: decision?.rationale
                        ),
                        timingAdjustment: adjustment,
                        date: decision?.suggestedTime
                    )
                )
            }
            try await repositories.feedback.saveEvents(history, goalID: goal.id)
            goal = update(goal: goal, stepID: selectedStep.id) { step in
                let timing = decision?.timingAdjustment.map { shiftedTiming(for: step.timing, now: now, adjustment: $0) } ?? step.timing
                return updatedStep(
                    step,
                    summary: decision?.recoverySummary ?? decision?.smallerStep?.summary ?? step.actionability.fallbackMicroStep,
                    timing: timing
                )
            }
            try await repositories.goals.saveGoals([goal])
            return GoalDetailActionResponse(
                message: GoalDetailInlineMessage(
                    title: "A calmer next step is ready",
                    body: decision?.recoverySummary ?? decision?.smallerStep?.summary ?? selectedStep.actionability.fallbackMicroStep,
                    state: .selected
                )
            )
        case .switchToUntimed:
            history.append(.delayed(base: base, timingAdjustment: .removeDeadline, date: nil))
            try await repositories.feedback.saveEvents(history, goalID: goal.id)
            let updatedGoal = updateGoalTiming(goal: goal) { timing in
                GoalTiming(
                    tempo: .untimed,
                    timingType: .logWhenDone,
                    startsOn: timing.startsOn,
                    dueAt: nil,
                    targetBy: nil,
                    windowStart: nil,
                    windowEnd: nil,
                    suggestedNextAt: nil,
                    repeatEveryDays: timing.repeatEveryDays,
                    progressReviewCadenceDays: timing.progressReviewCadenceDays
                )
            }
            try await repositories.goals.saveGoals([updatedGoal])
            return GoalDetailActionResponse(
                message: GoalDetailInlineMessage(
                    title: "Untimed mode enabled",
                    body: "This goal now tracks progress without deadline pressure. Existing work stays visible, but the urgency language is removed.",
                    state: .selected
                )
            )
        case .showPath, .showSupportMode, .raisePriority, .lowerPriority:
            return GoalDetailActionResponse(message: nil)
        }
    }

    private func externalEffectCommitEvidence(
        operationID: String,
        kind: RuntimeExternalEffectKind,
        goal: Goal,
        step: Step,
        now: Date
    ) async throws -> SideEffectLocalCommitEvidence {
        return try await externalEffectAuthorizer.authorize(
            RuntimeExternalEffectRequest(
                operationID: operationID,
                kind: kind,
                source: .goalDetail,
                goalID: goal.id,
                stepID: step.id,
                title: step.title,
                requestedAt: now
            )
        )
    }
}
