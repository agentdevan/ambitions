import AmbitionsDesignSystem
import Foundation

// AMBITIONS-QUALITY-EXTRACTION: Cohesive owner boundary remains under the hard 600-line ceiling after adjacent declarations were extracted; split further only with behavior-level tests.
extension RepositoryBackedTodayService {
    func performFeedbackAction(_ action: TodayInlineAction, now: Date) async throws -> TodayActionResponse {
        guard let goalID = action.target.goalID, let stepID = action.target.stepID else {
            return TodayActionResponse(
                message: TodayInlineMessage(
                    title: "Action not available",
                    body: "That panel does not currently point at a persisted goal step.",
                    state: .warning
                )
            )
        }

        guard var goal = try await repositories.goals.goal(id: goalID),
              let selectedStep = goal.plan?.sections.flatMap(\.steps).first(where: { $0.id == stepID }) else {
            return TodayActionResponse(
                message: TodayInlineMessage(
                    title: "Rescheduled",
                    body: "That step is no longer available in the current native store snapshot.",
                    state: .warning
                )
            )
        }

        let feedbackHistory = try await repositories.feedback.listEvents(goalID: goalID)
        let drafts = try await repositories.drafts.listDrafts()
        let draft = drafts.first(where: { $0.plannedGoalID == goalID })
        let timestamp = Self.iso.string(from: now)
        let base = GoalFeedbackEventBase(
            id: "today-\(action.kind.rawValue)-\(UUID().uuidString)",
            stepID: stepID,
            occurredAt: timestamp,
            note: note(for: action.kind, step: selectedStep)
        )

        var events = feedbackHistory
        var message: TodayInlineMessage?

        switch action.kind {
        case .complete:
            events.append(.completed(base: base, actualDuration: 25, effortLevel: .medium, confidenceDelta: 0.08))
            try await repositories.feedback.saveEvents(events, goalID: goalID)
            try await repositories.evidence.saveEvidence([
                ProgressEvidence(
                    id: "evidence-\(UUID().uuidString)",
                    goalID: goalID,
                    stepID: stepID,
                    evidenceKind: TimeRitualGoalSemantics.isRitualLike(goal: goal, step: selectedStep) ? .habitCompletion : .stepCompleted,
                    source: .manual,
                    capturedAt: timestamp,
                    progressDelta: 0.18,
                    confidenceDelta: 0.08,
                    minutesInvested: 25,
                    note: "Completed from Today."
                )
            ])
            if TimeRitualGoalSemantics.isRitualLike(goal: goal, step: selectedStep) {
                let cadenceDays = TimeRitualGoalSemantics.cadenceDays(goal: goal, step: selectedStep)
                goal = update(goal: goal, stepID: stepID, now: now) { step in
                    Step(
                        id: step.id,
                        sectionID: step.sectionID,
                        title: step.title,
                        summary: step.summary,
                        type: step.type,
                        state: step.state,
                        owner: step.owner,
                        timing: TimeRitualGoalSemantics.advancedTiming(from: step.timing, now: now, cadenceDays: cadenceDays),
                        dependencyStepIDs: step.dependencyStepIDs,
                        isOptional: step.isOptional,
                        isRepeatable: step.isRepeatable,
                        evidenceRequired: step.evidenceRequired,
                        successSignals: step.successSignals,
                        actionability: step.actionability
                    )
                }
            } else {
                goal = update(goal: goal, stepID: stepID, now: now) { step in
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
            message = TodayInlineMessage(
                title: TimeRitualGoalSemantics.isRitualLike(goal: goal, step: selectedStep) ? "Ritual logged" : "Completion recorded",
                body: TimeRitualGoalSemantics.isRitualLike(goal: goal, step: selectedStep)
                    ? "\"\(selectedStep.title)\" was recorded for today and kept alive as an ongoing rhythm."
                    : "\"\(selectedStep.title)\" is now reflected in native evidence and feedback.",
                state: .success
            )
        case .defer:
            let decision = rescheduleDecision(for: action.kind, goal: goal, step: selectedStep, history: events, now: now)
            let adjustment = decision?.timingAdjustment ?? .laterToday
            events.append(.delayed(base: base, timingAdjustment: adjustment, date: decision?.suggestedTime))
            if let smaller = decision?.smallerStep {
                events.append(
                    .askedForSmallerVersion(
                        base: GoalFeedbackEventBase(
                            id: "today-reschedule-smaller-\(UUID().uuidString)",
                            stepID: stepID,
                            occurredAt: timestamp,
                            note: smaller.note
                        )
                    )
                )
            }
            try await repositories.feedback.saveEvents(events, goalID: goalID)
            goal = update(goal: goal, stepID: stepID, now: now) { step in
                let shifted = shiftedTiming(for: step.timing, now: now, adjustment: adjustment)
                return Step(
                    id: step.id,
                    sectionID: step.sectionID,
                    title: step.title,
                    summary: decision?.recoverySummary ?? decision?.smallerStep?.summary ?? step.summary,
                    type: step.type,
                    state: step.state,
                    owner: step.owner,
                    timing: shifted,
                    dependencyStepIDs: step.dependencyStepIDs,
                    isOptional: step.isOptional,
                    isRepeatable: step.isRepeatable,
                    evidenceRequired: step.evidenceRequired,
                    successSignals: step.successSignals,
                    actionability: step.actionability
                )
            }
            try await repositories.goals.saveGoals([goal])
            let deferLine: String = {
                guard let decision, decision.deferRecommendation.indicatesDeferral else { return "" }
                return " It was deferred with a calmer retry window."
            }()
            message = TodayInlineMessage(
                title: "Pressure softened",
                body: "The step stays in play without pretending it must happen right now.\(deferLine)",
                state: .selected
            )
        case .reschedule:
            events.append(.skipped(base: base, reasonCode: .notNow))
            let decision = rescheduleDecision(for: action.kind, goal: goal, step: selectedStep, history: events, now: now)
            if let adjustment = decision?.timingAdjustment {
                events.append(
                    .delayed(
                        base: GoalFeedbackEventBase(
                            id: "today-skip-reschedule-\(UUID().uuidString)",
                            stepID: stepID,
                            occurredAt: timestamp,
                            note: decision?.rationale
                        ),
                        timingAdjustment: adjustment,
                        date: decision?.suggestedTime
                    )
                )
            }
            if let smaller = decision?.smallerStep {
                events.append(
                    .askedForSmallerVersion(
                        base: GoalFeedbackEventBase(
                            id: "today-skip-smaller-\(UUID().uuidString)",
                            stepID: stepID,
                            occurredAt: timestamp,
                            note: smaller.note
                        )
                    )
                )
            }
            try await repositories.feedback.saveEvents(events, goalID: goalID)
            goal = update(goal: goal, stepID: stepID, now: now) { step in
                let shifted = shiftedTiming(for: step.timing, now: now, adjustment: decision?.timingAdjustment ?? .laterThisWeek)
                return Step(
                    id: step.id,
                    sectionID: step.sectionID,
                    title: step.title,
                    summary: decision?.recoverySummary ?? decision?.smallerStep?.summary ?? step.summary,
                    type: step.type,
                    state: step.state,
                    owner: step.owner,
                    timing: shifted,
                    dependencyStepIDs: step.dependencyStepIDs,
                    isOptional: step.isOptional,
                    isRepeatable: step.isRepeatable,
                    evidenceRequired: step.evidenceRequired,
                    successSignals: step.successSignals,
                    actionability: step.actionability
                )
            }
            try await repositories.goals.saveGoals([goal])
            let deferLine: String = {
                guard let decision, decision.deferRecommendation.indicatesDeferral else { return "" }
                return " The next attempt was deferred to prevent churn."
            }()
            message = TodayInlineMessage(
                title: "Rescheduled",
                body: "The step was skipped without turning it into a failure state.\(deferLine)",
                state: .warning
            )
        case .markNotRelevant:
            events.append(.notRelevant(base: base))
            try await repositories.feedback.saveEvents(events, goalID: goalID)
            goal = update(goal: goal, stepID: stepID, now: now) { step in
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
            message = TodayInlineMessage(
                title: "Relevance captured",
                body: "That step is out of the active queue until goal detail adds a fuller replanning flow.",
                state: .warning
            )
        case .quickLog:
            try await repositories.evidence.saveEvidence([
                ProgressEvidence(
                    id: "evidence-\(UUID().uuidString)",
                    goalID: goalID,
                    stepID: stepID,
                    evidenceKind: .sessionLogged,
                    source: .manual,
                    capturedAt: timestamp,
                    progressDelta: 0.08,
                    confidenceDelta: 0.04,
                    minutesInvested: 10,
                    note: "Quick log from Today."
                )
            ])
            _ = try await captureService.createCapture(
                CreateCaptureRequest(
                    rawText: "Quick log for \"\(selectedStep.title)\".",
                    sourceType: .todayQuickCapture,
                    linkedGoalID: goalID,
                    kind: .goalSupportingTask,
                    route: .captureInbox,
                    goalRelationship: CaptureGoalRelationship(goalID: goalID, relationshipKind: .nextAction)
                ),
                now: now
            )
            message = TodayInlineMessage(
                title: "Signal saved",
                body: "Today recorded a quick bit of evidence without creating fake urgency.",
                state: .success
            )
        case .createReminder:
            let selection = nextStepSchedulingSelection(goal: goal, step: selectedStep)
            let authorization = await calendarRemindersService.requestAuthorizationIfNeeded(for: .reminders)
            guard authorization.canWrite else {
                message = TodayInlineMessage(
                    title: "Reminders permission needed",
                    body: "Enable Reminders access to create next-step reminders from Ambitions.",
                    state: .warning
                )
                break
            }

            _ = try await calendarRemindersService.createReminder(for: selection, now: now)
            message = TodayInlineMessage(
                title: "Reminder created",
                body: "\"\(selectedStep.title)\" was added to Reminders.",
                state: .success
            )
        case .createCalendarEvent:
            message = TodayInlineMessage(
                title: "Use Time for Calendar access",
                body: "Today will not request Calendar permission or write calendar blocks. Open Time to make planning calendar-aware from there.",
                state: .warning
            )
        case .split:
            let decision = rescheduleDecision(for: action.kind, goal: goal, step: selectedStep, history: events, now: now)
            events.append(.askedForSmallerVersion(base: base))
            if let adjustment = decision?.timingAdjustment {
                events.append(
                    .delayed(
                        base: GoalFeedbackEventBase(
                            id: "today-smaller-reschedule-\(UUID().uuidString)",
                            stepID: stepID,
                            occurredAt: timestamp,
                            note: decision?.rationale
                        ),
                        timingAdjustment: adjustment,
                        date: decision?.suggestedTime
                    )
                )
            }
            try await repositories.feedback.saveEvents(events, goalID: goalID)
            let adjustment = adjustmentPayload(draft: draft, goal: goal, step: selectedStep, history: events)
            let replacement = adjustment.flatMap { smallerSummary(from: $0.recommendation, step: selectedStep) }
                ?? decision?.recoverySummary
                ?? decision?.smallerStep?.summary
                ?? selectedStep.actionability.fallbackMicroStep
            if replacement.isEmpty == false {
                goal = update(goal: goal, stepID: stepID, now: now) { step in
                    let timing = decision?.timingAdjustment.map { shiftedTiming(for: step.timing, now: now, adjustment: $0) } ?? step.timing
                    return Step(
                        id: step.id,
                        sectionID: step.sectionID,
                        title: step.title,
                        summary: replacement,
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
                try await repositories.goals.saveGoals([goal])
                message = TodayInlineMessage(
                    title: "Smaller version ready",
                    body: decision?.deferRecommendation.indicatesDeferral == true
                        ? "\(replacement)\n\nThe next attempt was deferred to keep the ask realistic."
                        : replacement,
                    state: .selected
                )
            } else {
                message = TodayInlineMessage(
                    title: "Smaller version ready",
                    body: selectedStep.actionability.fallbackMicroStep,
                    state: .selected
                )
            }
        case .askForHelp:
            let decision = rescheduleDecision(for: action.kind, goal: goal, step: selectedStep, history: events, now: now)
            events.append(.confused(base: base, confusionType: .unclearAction))
            if let smaller = decision?.smallerStep {
                events.append(
                    .askedForSmallerVersion(
                        base: GoalFeedbackEventBase(
                            id: "today-help-smaller-\(UUID().uuidString)",
                            stepID: stepID,
                            occurredAt: timestamp,
                            note: smaller.note
                        )
                    )
                )
            }
            if let adjustment = decision?.timingAdjustment {
                events.append(
                    .delayed(
                        base: GoalFeedbackEventBase(
                            id: "today-help-delay-\(UUID().uuidString)",
                            stepID: stepID,
                            occurredAt: timestamp,
                            note: decision?.rationale
                        ),
                        timingAdjustment: adjustment,
                        date: decision?.suggestedTime
                    )
                )
            }
            try await repositories.feedback.saveEvents(events, goalID: goalID)
            if let decision {
                goal = update(goal: goal, stepID: stepID, now: now) { step in
                    let shifted = decision.timingAdjustment.map { shiftedTiming(for: step.timing, now: now, adjustment: $0) } ?? step.timing
                    return Step(
                        id: step.id,
                        sectionID: step.sectionID,
                        title: step.title,
                        summary: decision.recoverySummary ?? decision.smallerStep?.summary ?? step.summary,
                        type: step.type,
                        state: step.state,
                        owner: step.owner,
                        timing: shifted,
                        dependencyStepIDs: step.dependencyStepIDs,
                        isOptional: step.isOptional,
                        isRepeatable: step.isRepeatable,
                        evidenceRequired: step.evidenceRequired,
                        successSignals: step.successSignals,
                        actionability: step.actionability
                    )
                }
                try await repositories.goals.saveGoals([goal])
            }
            message = TodayInlineMessage(
                title: "A calmer next step is ready",
                body: decision?.recoverySummary ?? decision?.smallerStep?.summary ?? selectedStep.actionability.fallbackMicroStep,
                state: .selected
            )
        case .askWhyThisMatters:
            events.append(.askedWhyThisMatters(base: base))
            try await repositories.feedback.saveEvents(events, goalID: goalID)
            let adjustment = adjustmentPayload(draft: draft, goal: goal, step: selectedStep, history: events)
            let intelligenceSummary = try await goalIntelligenceService?.loadContext(
                RuntimeGoalIntelligenceRequest(
                    target: GoalRouteTarget(goalID: goalID, draftID: draft?.id),
                    primaryStepID: selectedStep.id,
                    includeWhyNow: true
                ),
                now: now
            )?.explainability.whyThis.compactSummary
            let draftMetadataSummary = draft?.metadata.map { metadata in
                explainabilityProjector.makeState(
                    metadata: metadata,
                    applicableSignals: nil,
                    primaryStepID: selectedStep.id,
                    whyNow: learningService.learnedStepInsight(
                        goal: goal,
                        step: selectedStep,
                        snapshot: learningService.buildSnapshot(
                            goals: [goal],
                            evidence: [],
                            feedback: events,
                            now: now
                        ),
                        now: now
                    ).whyNow
                ).whyThis.compactSummary
            }
            let draftSummary = draft.map {
                createWhyThisMattersExplanation(draft: $0.draft, step: selectedStep).explanation
            }
            let fallbackSummary = "\(selectedStep.title) matters because it carries \(goal.title.lowercased()) forward with visible evidence."
            let explanation = intelligenceSummary
                ?? draftMetadataSummary
                ?? adjustment?.explanationHook?.explanation
                ?? draftSummary
                ?? fallbackSummary
            message = TodayInlineMessage(
                title: "Why this matters",
                body: explanation,
                state: .selected
            )
        case .startStepSession, .pauseStepSession, .stopStepSession, .closeActionClosure, .openDetail, .openTime, .protectLater, .dismissCelebration:
            break
        }

        return TodayActionResponse(message: message)
    }

}
