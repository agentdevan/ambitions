import Foundation

struct TodayGoalStepActionPlan: Sendable, Codable, Equatable {
    static let metadataKey = "todayGoalStepActionPlan"
    static let mutationMarkerKey = "todayGoalStepActionMutation"

    let actionKind: String
    let goalID: String
    let stepID: String
    let expectedGoalRevision: Int
    let updatedGoal: Goal
    let writesGoal: Bool?
    let feedbackEvents: [StoredGoalFeedbackEvent]
    let evidence: [ProgressEvidence]
    let capture: Capture?

    var shouldWriteGoal: Bool { writesGoal ?? true }

    func encoded() throws -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        return try encoder.encode(self).base64EncodedString()
    }

    static func decode(command: AmbitionsCommand) -> TodayGoalStepActionPlan? {
        guard command.payload.metadata[mutationMarkerKey] == "true",
              let value = command.payload.metadata[metadataKey],
              let data = Data(base64Encoded: value) else { return nil }
        return try? JSONDecoder().decode(Self.self, from: data)
    }
}

struct PreparedTodayGoalStepAction: Sendable {
    let command: AmbitionsCommand
    let context: CommandExecutionContext
}

struct TodayGoalStepActionRequest: Sendable {
    let kind: String
    let title: String
    let goalID: String
    let stepID: String
    let operationID: String
    let context: TodayGoalStepActionContext?
}

struct TodayGoalStepActionContext: Sendable, Codable, Equatable {
    let timingAdjustment: GoalTimingAdjustment?
    let suggestedTime: String?
    let recoverySummary: String?
    let smallerStepSummary: String?
    let rationale: String?
    let indicatesDeferral: Bool
}

struct TodayGoalStepActionPlanner: Sendable {
    let repositories: AppRepositories

    func prepare(_ request: TodayGoalStepActionRequest, now: Date) async throws -> PreparedTodayGoalStepAction {
        guard var goal = try await repositories.goals.goal(id: request.goalID),
              let selectedStep = goal.plan?.sections.flatMap(\.steps).first(where: { $0.id == request.stepID }) else {
            throw TodayDurableActionError.unavailable
        }
        let expectedRevision = goal.revision
        let baseCommandID = "command.today.goal-step.\(request.kind).\(request.goalID).\(request.stepID).revision-\(expectedRevision)"
        let commandID = request.kind == "quickLog"
            ? "\(baseCommandID).operation-\(request.operationID)"
            : baseCommandID
        let timestamp = DomainTimestamp.string(from: now)
        let base = GoalFeedbackEventBase(
            id: "\(commandID).feedback",
            stepID: request.stepID,
            occurredAt: timestamp,
            note: feedbackNote(kind: request.kind, step: selectedStep)
        )
        var feedback: [GoalFeedbackEvent] = []
        var evidence: [ProgressEvidence] = []
        var capture: Capture?
        let context = request.context

        switch request.kind {
        case "complete":
            feedback = [.completed(base: base, actualDuration: 25, effortLevel: .medium, confidenceDelta: 0.08)]
            let ritual = TimeRitualGoalSemantics.isRitualLike(goal: goal, step: selectedStep)
            evidence = [ProgressEvidence(
                id: "\(commandID).evidence", goalID: request.goalID, stepID: request.stepID,
                evidenceKind: ritual ? .ritualCompletion : .stepCompleted, source: .manual,
                capturedAt: timestamp, progressDelta: ritual ? 0.1 : 0.18, confidenceDelta: 0.08,
                minutesInvested: 25,
                note: ritual ? "Completed one recurring Step occurrence from Today." : "Completed from Today."
            )]
            if ritual {
                let cadence = TimeRitualGoalSemantics.cadenceDays(goal: goal, step: selectedStep)
                goal = replacingStep(in: goal, stepID: request.stepID, now: now) { step in
                    copied(step, state: .planned, timing: TimeRitualGoalSemantics.advancedTiming(from: step.timing, now: now, cadenceDays: cadence), isRepeatable: true)
                }
            } else {
                goal = replacingStep(in: goal, stepID: request.stepID, now: now) { copied($0, state: .completed) }
            }
        case "defer":
            guard let context, let adjustment = context.timingAdjustment else { throw TodayDurableActionError.unavailable }
            feedback = [.delayed(base: base, timingAdjustment: adjustment, date: context.suggestedTime)]
            goal = replacingStep(in: goal, stepID: request.stepID, now: now) {
                copied($0, timing: shiftedTiming(for: $0.timing, now: now, adjustment: adjustment, suggestedTime: context.suggestedTime), summary: context.recoverySummary ?? context.smallerStepSummary)
            }
        case "reschedule":
            guard let context else { throw TodayDurableActionError.unavailable }
            feedback = [.skipped(base: base, reasonCode: .notNow)]
            if let adjustment = context.timingAdjustment {
                feedback.append(.delayed(base: GoalFeedbackEventBase(id: "\(commandID).delay", stepID: request.stepID, occurredAt: timestamp, note: context.rationale), timingAdjustment: adjustment, date: context.suggestedTime))
            }
            goal = replacingStep(in: goal, stepID: request.stepID, now: now) { step in
                let timing = context.timingAdjustment.map {
                    shiftedTiming(for: step.timing, now: now, adjustment: $0, suggestedTime: context.suggestedTime)
                } ?? step.timing
                return copied(step, timing: timing, summary: context.recoverySummary ?? context.smallerStepSummary)
            }
        case "markNotRelevant":
            feedback = [.notRelevant(base: base)]
            goal = replacingStep(in: goal, stepID: request.stepID, now: now) { copied($0, state: .cancelled) }
        case "split":
            guard let context else { throw TodayDurableActionError.unavailable }
            feedback = [.askedForSmallerVersion(base: base)]
            if let adjustment = context.timingAdjustment {
                feedback.append(.delayed(base: GoalFeedbackEventBase(id: "\(commandID).delay", stepID: request.stepID, occurredAt: timestamp, note: context.rationale), timingAdjustment: adjustment, date: context.suggestedTime))
            }
            goal = replacingStep(in: goal, stepID: request.stepID, now: now) { step in
                let timing = context.timingAdjustment.map {
                    shiftedTiming(for: step.timing, now: now, adjustment: $0, suggestedTime: context.suggestedTime)
                } ?? step.timing
                return copied(step, timing: timing, summary: context.smallerStepSummary ?? context.recoverySummary)
            }
        case "askForHelp":
            guard let context else { throw TodayDurableActionError.unavailable }
            feedback = [.confused(base: base, confusionType: .unclearAction)]
            if let smaller = context.smallerStepSummary {
                feedback.append(.askedForSmallerVersion(base: GoalFeedbackEventBase(id: "\(commandID).smaller", stepID: request.stepID, occurredAt: timestamp, note: smaller)))
            }
            if let adjustment = context.timingAdjustment {
                feedback.append(.delayed(base: GoalFeedbackEventBase(id: "\(commandID).delay", stepID: request.stepID, occurredAt: timestamp, note: context.rationale), timingAdjustment: adjustment, date: context.suggestedTime))
            }
            goal = replacingStep(in: goal, stepID: request.stepID, now: now) { step in
                let timing = context.timingAdjustment.map {
                    shiftedTiming(for: step.timing, now: now, adjustment: $0, suggestedTime: context.suggestedTime)
                } ?? step.timing
                return copied(step, timing: timing, summary: context.recoverySummary ?? context.smallerStepSummary)
            }
        case "quickLog":
            let rawText = "Quick log for \"\(selectedStep.title)\"."
            let classification = CaptureClassifier.classify(
                text: rawText,
                requestedKind: .goalSupportingTask,
                requestedRoute: .captureInbox,
                deadlineText: nil,
                contextLensHint: nil,
                priorityHints: CapturePriorityHints()
            )
            evidence = [ProgressEvidence(
                id: "\(commandID).evidence", goalID: request.goalID, stepID: request.stepID,
                evidenceKind: .sessionLogged, source: .manual, capturedAt: timestamp,
                progressDelta: 0.08, confidenceDelta: 0.04, minutesInvested: 10,
                note: "Quick log from Today."
            )]
            capture = Capture(
                id: "capture.\(commandID)", createdAt: timestamp, updatedAt: timestamp,
                rawText: rawText, sourceType: .todayQuickCapture,
                status: .actionable, linkedGoalID: request.goalID,
                triage: CaptureTriageMetadata(
                    destination: classification.route.triageDestination,
                    hint: classification.assumptionSummary
                ),
                kind: classification.kind, route: classification.route,
                triageStatus: classification.triageStatus,
                commitmentKind: classification.commitmentKind,
                deadlineText: classification.deadlineText,
                deadlineKind: classification.deadlineKind,
                contextLensHint: classification.contextLensHint,
                priorityHints: classification.priorityHints,
                goalRelationship: CaptureGoalRelationship(
                    goalID: request.goalID,
                    relationshipKind: .nextAction
                ),
                assumptionSummary: classification.assumptionSummary
            )
        default:
            throw TodayDurableActionError.unavailable
        }

        let plan = TodayGoalStepActionPlan(
            actionKind: request.kind, goalID: request.goalID, stepID: request.stepID,
            expectedGoalRevision: expectedRevision, updatedGoal: goal,
            writesGoal: request.kind != "quickLog",
            feedbackEvents: feedback.map(StoredGoalFeedbackEvent.init(event:)), evidence: evidence,
            capture: capture
        )
        let command = AmbitionsCommand(
            id: commandID, kind: commandKind(for: request.kind), source: .today,
            target: AmbitionsCommandTarget(
                goalID: request.goalID,
                captureID: capture?.id,
                stepID: request.stepID,
                destination: .today
            ),
            payload: AmbitionsCommandPayload(rawText: capture?.rawText, title: request.title, metadata: [
                TodayGoalStepActionPlan.mutationMarkerKey: "true",
                TodayGoalStepActionPlan.metadataKey: try plan.encoded(),
                "todayActionKind": request.kind
            ]),
            createdAt: timestamp, actor: .user, sourceSurface: "Today", privacy: .privateUserText
        )
        return PreparedTodayGoalStepAction(command: command, context: CommandExecutionContext(now: now, actor: .user, sourceSurface: "Today"))
    }

    private func commandKind(for kind: String) -> AmbitionsCommandKind {
        switch kind {
        case "complete": .completeAction
        case "defer", "reschedule": .delayAction
        case "markNotRelevant": .updateGoal
        case "split": .splitAction
        case "askForHelp": .recoverAction
        case "quickLog": .quickCapture
        default: .recoverAction
        }
    }

    private func feedbackNote(kind: String, step: Step) -> String {
        switch kind {
        case "complete": "Completed \(step.title) from Today."
        case "defer": "Deferred \(step.title) from Today."
        case "reschedule": "Rescheduled \(step.title) from Today."
        case "markNotRelevant": "Marked \(step.title) as not needed from Today."
        case "split": "Requested a smaller version of \(step.title) from Today."
        default: "Asked for help with \(step.title) from Today."
        }
    }

    private func copied(_ step: Step, state: StepLifecycleState? = nil, timing: GoalTiming? = nil, summary: String? = nil, isRepeatable: Bool? = nil) -> Step {
        Step(
            id: step.id, sectionID: step.sectionID, title: step.title, summary: summary ?? step.summary,
            type: step.type, state: state ?? step.state, owner: step.owner, timing: timing ?? step.timing,
            dependencyStepIDs: step.dependencyStepIDs, isOptional: step.isOptional,
            isRepeatable: isRepeatable ?? step.isRepeatable, evidenceRequired: step.evidenceRequired,
            successSignals: step.successSignals, actionability: step.actionability
        )
    }

    private func replacingStep(in goal: Goal, stepID: String, now: Date, transform: (Step) -> Step) -> Goal {
        let sections = goal.plan?.sections.map { section in
            PlanSection(id: section.id, goalID: section.goalID, title: section.title, summary: section.summary, kind: section.kind, orderIndex: section.orderIndex, steps: section.steps.map { $0.id == stepID ? transform($0) : $0 })
        }
        let plan = goal.plan.map { GoalPlan(id: $0.id, goalID: $0.goalID, version: $0.version, generatedAt: $0.generatedAt, summary: $0.summary, strategy: $0.strategy, sections: sections ?? $0.sections, assumptions: $0.assumptions, lint: $0.lint) }
        return Goal(
            schemaVersion: goal.schemaVersion, id: goal.id, revision: goal.revision + 1,
            createdAt: goal.createdAt, updatedAt: DomainTimestamp.string(from: now), state: goal.state,
            title: goal.title, summary: goal.summary, mode: goal.mode, relationshipKind: goal.relationshipKind,
            actor: goal.actor, parentGoalID: goal.parentGoalID, childGoalIDs: goal.childGoalIDs,
            supportGoalIDs: goal.supportGoalIDs, tags: goal.tags, timing: goal.timing,
            planningStrategy: goal.planningStrategy, progressStrategy: goal.progressStrategy,
            plan: plan, lifeGraph: goal.lifeGraph
        )
    }

    private func shiftedTiming(for timing: GoalTiming, now: Date, adjustment: GoalTimingAdjustment, suggestedTime: String?) -> GoalTiming {
        if let suggestedTime {
            return GoalTiming(
                tempo: adjustment == .removeDeadline ? .untimed : timing.tempo,
                timingType: adjustment == .removeDeadline ? .logWhenDone : .suggestedNext,
                startsOn: timing.startsOn, dueAt: adjustment == .removeDeadline ? nil : timing.dueAt,
                targetBy: adjustment == .removeDeadline ? nil : timing.targetBy,
                windowStart: timing.windowStart, windowEnd: timing.windowEnd,
                suggestedNextAt: adjustment == .removeDeadline ? nil : suggestedTime,
                repeatEveryDays: timing.repeatEveryDays, progressReviewCadenceDays: timing.progressReviewCadenceDays
            )
        }
        let days = adjustment == .laterThisWeek ? 2 : 0
        let hours = adjustment == .laterToday ? 3 : 0
        let shifted = Calendar(identifier: .gregorian).date(byAdding: days > 0 ? .day : .hour, value: days > 0 ? days : hours, to: now) ?? now
        return GoalTiming(
            tempo: timing.tempo, timingType: timing.timingType, startsOn: timing.startsOn,
            dueAt: timing.dueAt, targetBy: timing.targetBy, windowStart: timing.windowStart,
            windowEnd: timing.windowEnd, suggestedNextAt: DomainTimestamp.string(from: shifted),
            repeatEveryDays: timing.repeatEveryDays, progressReviewCadenceDays: timing.progressReviewCadenceDays
        )
    }
}

protocol TodayGoalStepActionMaterializing: Sendable {
    func validate(_ plan: TodayGoalStepActionPlan) async throws
    func materialize(_ plan: TodayGoalStepActionPlan) async throws
}

extension TodayGoalStepActionMaterializing {
    func validate(_ plan: TodayGoalStepActionPlan) async throws { _ = plan }
}

struct RepositoryTodayGoalStepActionMaterializer: TodayGoalStepActionMaterializing {
    let repositories: AppRepositories

    func validate(_ plan: TodayGoalStepActionPlan) async throws {
        guard plan.shouldWriteGoal else { return }
        guard let current = try await repositories.goals.goal(id: plan.goalID) else { return }
        guard current.revision == plan.expectedGoalRevision || current == plan.updatedGoal else {
            throw TodayDurableActionMaterializationError.staleGoalRevision(
                expected: plan.expectedGoalRevision,
                actual: current.revision
            )
        }
    }

    func materialize(_ plan: TodayGoalStepActionPlan) async throws {
        var goalNeedsSave = plan.shouldWriteGoal
        if plan.shouldWriteGoal,
           let currentGoal = try await repositories.goals.goal(id: plan.goalID) {
            if currentGoal == plan.updatedGoal {
                goalNeedsSave = false
            } else if currentGoal.revision != plan.expectedGoalRevision {
                throw TodayDurableActionMaterializationError.staleGoalRevision(
                    expected: plan.expectedGoalRevision,
                    actual: currentGoal.revision
                )
            }
        }
        let existingFeedback = try await repositories.feedback.listEvents(goalID: plan.goalID)
        var mergedFeedback = existingFeedback
        for stored in plan.feedbackEvents {
            if let index = mergedFeedback.firstIndex(where: { $0.base.id == stored.event.base.id }) {
                mergedFeedback[index] = stored.event
            } else {
                mergedFeedback.append(stored.event)
            }
        }
        try await repositories.feedback.saveEvents(mergedFeedback, goalID: plan.goalID)
        if plan.evidence.isEmpty == false {
            try await repositories.evidence.saveEvidence(plan.evidence)
        }
        if let capture = plan.capture {
            try await repositories.captures.saveCaptures([capture])
        }
        if goalNeedsSave {
            try await repositories.goals.saveGoals([plan.updatedGoal])
        }
    }
}

enum TodayDurableActionMaterializationError: Error, Equatable {
    case staleGoalRevision(expected: Int, actual: Int)
    case materializerUnavailable
}

extension AmbitionsCommand {
    var isTodayGoalStepActionMutation: Bool {
        payload.metadata[TodayGoalStepActionPlan.mutationMarkerKey] == "true"
    }
}

extension AmbitionsCommandExecutor {
    func executeTodayGoalStepAction(_ command: AmbitionsCommand) async -> AmbitionsCommandExecutionResult {
        guard let plan = TodayGoalStepActionPlan.decode(command: command),
              plan.goalID == command.target.goalID,
              plan.stepID == command.target.stepID else {
            return AmbitionsCommandExecutionResult(
                status: .blocked,
                summary: "Today action plan is missing or does not match its target.",
                route: .today,
                target: command.target,
                metadata: ["blockedBy": "today_action_plan_invalid"]
            )
        }
        do {
            guard let todayActionMaterializer else {
                throw TodayDurableActionMaterializationError.materializerUnavailable
            }
            try await todayActionMaterializer.validate(plan)
        } catch TodayDurableActionMaterializationError.materializerUnavailable {
            return AmbitionsCommandExecutionResult(
                status: .blocked,
                summary: "Today action could not be committed because its local materializer is unavailable.",
                route: .today,
                target: command.target,
                metadata: ["blockedBy": "today_action_materializer_unavailable"]
            )
        } catch {
            return AmbitionsCommandExecutionResult(
                status: .blocked,
                summary: "Today action could not be committed because the Step changed.",
                route: .today,
                target: command.target,
                metadata: ["blockedBy": "today_action_stale_revision"]
            )
        }
        return AmbitionsCommandExecutionResult(
            status: .succeeded,
            summary: "Today goal-step action committed.",
            route: .today,
            target: command.target,
            metadata: [
                "todayActionKind": plan.actionKind,
                "todayActionMaterialization": "pending_authority_commit",
                "projectionReloadRequired": "true"
            ]
        )
    }

    func materializeTodayGoalStepAction(
        _ command: AmbitionsCommand,
        committedResult: AmbitionsCommandExecutionResult
    ) async -> AmbitionsCommandExecutionResult {
        guard let todayActionMaterializer else {
            return committedResult.mergingMetadata([
                "todayActionMaterialization": "needs_recovery",
                "todayActionMaterializationError": "materializer_unavailable"
            ])
        }
        do {
            let envelopes = try await runtimeEvents?.fetchEvents(matching: .commandID(command.id), limit: nil) ?? []
            guard let plan = try envelopes.compactMap({ envelope -> TodayGoalStepActionPlan? in
                guard case let .domainMutation(record) = envelope.event.payload,
                      case let .todayGoalStepActionApplied(value) = try record.decodedEvent() else { return nil }
                return value
            }).first else {
                return committedResult.mergingMetadata([
                    "todayActionMaterialization": "needs_recovery",
                    "todayActionMaterializationError": "semantic_today_action_missing"
                ])
            }
            try await todayActionMaterializer.materialize(plan)
            return committedResult.mergingMetadata(["todayActionMaterialization": "saved_post_authority"])
        } catch {
            return committedResult.mergingMetadata([
                "todayActionMaterialization": "needs_recovery",
                "todayActionMaterializationError": String(describing: error)
            ])
        }
    }
}
