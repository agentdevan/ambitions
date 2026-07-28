import Foundation

struct TimeRitualActionPlan: Sendable, Codable, Equatable {
    let actionKind: TimeRitualActionKind
    let goalID: String
    let stepID: String
    let expectedGoalRevision: Int
    let updatedGoal: Goal
    let writesGoal: Bool
    let feedbackEvents: [StoredGoalFeedbackEvent]
    let evidence: [ProgressEvidence]

    static func decode(command: AmbitionsCommand) -> Self? {
        guard case let .schedule(value) = command.canonicalPayload,
              case let .ritual(plan) = value.action else { return nil }
        return plan
    }

    static func operation(for action: TimeRitualActionKind) -> RuntimeCommandOperation {
        switch action {
        case .complete, .minimumVersion: .completeAction
        case .quickLog: .quickCapture
        case .delay, .skip: .delayAction
        case .needsEasierVersion: .recoverAction
        case .markNotRelevant: .updateGoal
        case .openDetail: .openDestination
        }
    }
}

struct PreparedTimeRitualAction: Sendable {
    let command: AmbitionsCommand
    let context: CommandExecutionContext
    let response: TimeRitualActionResponse
}

enum TimeRitualDurableActionError: Error, LocalizedError, Equatable {
    case unavailable
    case needsRecovery
    case staleGoalRevision(expected: Int, actual: Int)
    case materializerUnavailable

    var errorDescription: String? {
        switch self {
        case .unavailable: "That ritual is no longer available."
        case .needsRecovery: "The ritual action was recorded but still needs local recovery."
        case .staleGoalRevision: "The ritual changed before this action could be committed."
        case .materializerUnavailable: "The ritual action cannot be saved on this device."
        }
    }
}

struct TimeRitualActionPlanner: Sendable {
    private struct EvidenceValues {
        let progress: Double
        let confidence: Double
        let minutes: Int
        let note: String
    }

    let repositories: AppRepositories

    func prepare(_ request: TimeRitualActionRequest, now: Date) async throws -> PreparedTimeRitualAction {
        guard request.kind != .openDetail,
              var goal = try await repositories.goals.goal(id: request.target.goalID),
              let step = goal.plan?.sections.flatMap(\.steps).first(where: { $0.id == request.target.stepID }) else {
            throw TimeRitualDurableActionError.unavailable
        }
        let expectedRevision = goal.revision
        let baseCommandID = [
            "command.time.ritual", request.kind.rawValue, goal.id, step.id,
            "revision-\(expectedRevision)"
        ].joined(separator: ".")
        let commandID = request.kind == .quickLog
            ? "\(baseCommandID).operation-\(request.operationID)"
            : baseCommandID
        let timestamp = DomainTimestamp.string(from: now)
        let base = GoalFeedbackEventBase(
            id: "\(commandID).feedback",
            stepID: step.id,
            occurredAt: timestamp,
            note: feedbackNote(for: request.kind, step: step)
        )
        let cadenceDays = TimeRitualGoalSemantics.cadenceDays(goal: goal, step: step)
        var feedback: [GoalFeedbackEvent] = []
        var evidence: [ProgressEvidence] = []
        var writesGoal = false
        let response: TimeRitualActionResponse

        switch request.kind {
        case .complete:
            let minutes = stepMinutes(for: goal.mode)
            feedback = [.completed(base: base, actualDuration: minutes, effortLevel: .low, confidenceDelta: 0.06)]
            evidence = [makeEvidence(
                id: "\(commandID).evidence", kind: .ritualCompletion, goal: goal, step: step,
                capturedAt: timestamp
            )]
            goal = replacingStep(in: goal, stepID: step.id, now: now) {
                copy($0, timing: TimeRitualGoalSemantics.advancedTiming(
                    from: $0.timing, now: now, cadenceDays: cadenceDays
                ))
            }
            writesGoal = true
            response = .init(
                message: .init(
                    title: "Ritual logged",
                    body: "Today's full version is recorded. The rhythm stays active without pretending the loop is finished forever.",
                    state: .success
                ),
                proofArtifactID: evidence[0].id
            )
        case .minimumVersion:
            evidence = [makeEvidence(
                id: "\(commandID).evidence", kind: .ritualMinimumVersion, goal: goal, step: step,
                capturedAt: timestamp
            )]
            goal = replacingStep(in: goal, stepID: step.id, now: now) {
                copy($0, timing: TimeRitualGoalSemantics.advancedTiming(
                    from: $0.timing, now: now, cadenceDays: cadenceDays
                ))
            }
            writesGoal = true
            response = .init(
                message: .init(title: "Minimum version counts", body: step.actionability.fallbackMicroStep, state: .success),
                proofArtifactID: evidence[0].id
            )
        case .quickLog:
            evidence = [makeEvidence(
                id: "\(commandID).evidence", kind: .ritualQuickLog, goal: goal, step: step,
                capturedAt: timestamp
            )]
            response = .init(
                message: .init(
                    title: "Signal captured",
                    body: "Progress was logged without forcing a full completion label.",
                    state: .selected
                ),
                proofArtifactID: evidence[0].id
            )
        case .delay:
            feedback = [.delayed(base: base, timingAdjustment: .laterToday, date: nil)]
            goal = replacingStep(in: goal, stepID: step.id, now: now) {
                copy($0, timing: delayedTiming($0.timing, now: now))
            }
            writesGoal = true
            response = .init(
                message: .init(
                    title: "Delayed without drama",
                    body: "The routine stays live, but the system is no longer treating it like it had to happen right now.",
                    state: .selected
                ),
                proofArtifactID: base.id
            )
        case .skip:
            feedback = [.skipped(base: base, reasonCode: .notNow)]
            goal = replacingStep(in: goal, stepID: step.id, now: now) {
                copy($0, timing: TimeRitualGoalSemantics.advancedTiming(
                    from: $0.timing, now: now, cadenceDays: cadenceDays
                ))
            }
            writesGoal = true
            response = .init(
                message: .init(
                    title: "Skipped, still okay",
                    body: "Today's window was intentionally let go. The next cadence point is already in place.",
                    state: .warning
                ),
                proofArtifactID: base.id
            )
        case .needsEasierVersion:
            feedback = [.askedForSmallerVersion(base: base)]
            response = .init(
                message: .init(
                    title: "Easier version noted",
                    body: "Use this minimum version next: \(step.actionability.fallbackMicroStep)",
                    state: .selected
                ),
                proofArtifactID: base.id
            )
        case .markNotRelevant:
            feedback = [.notRelevant(base: base)]
            goal = copy(goal, state: .paused, updatedAt: timestamp)
            writesGoal = true
            response = .init(
                message: .init(
                    title: "Routine flagged for review",
                    body: "This routine has been softened out of the active loop until the ritual plan is corrected.",
                    state: .warning
                ),
                proofArtifactID: base.id
            )
        case .openDetail:
            throw TimeRitualDurableActionError.unavailable
        }

        let plan = TimeRitualActionPlan(
            actionKind: request.kind,
            goalID: goal.id,
            stepID: step.id,
            expectedGoalRevision: expectedRevision,
            updatedGoal: goal,
            writesGoal: writesGoal,
            feedbackEvents: feedback.map(StoredGoalFeedbackEvent.init(event:)),
            evidence: evidence
        )
        let target = AmbitionsCommandTarget(goalID: goal.id, stepID: step.id, destination: .time)
        let content = AmbitionsCommandPayload(
            rawText: request.kind == .quickLog ? "Quick log for \"\(step.title)\"." : nil,
            title: request.kind.rawValue
        )
        let command = AmbitionsCommand(
            id: commandID,
            source: .time,
            typedPayload: .schedule(ScheduleCommand(
                action: .ritual(plan),
                target: target,
                content: RuntimeCommandContent(content)
            )),
            createdAt: timestamp,
            actor: .user,
            sourceSurface: "Time",
            privacy: .privateUserText
        )
        return PreparedTimeRitualAction(
            command: command,
            context: CommandExecutionContext(now: now, actor: .user, sourceSurface: "Time"),
            response: response
        )
    }

    private func feedbackNote(for kind: TimeRitualActionKind, step: Step) -> String {
        switch kind {
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

    private func makeEvidence(
        id: String,
        kind: ProgressEvidenceKind,
        goal: Goal,
        step: Step,
        capturedAt: String
    ) -> ProgressEvidence {
        let values: EvidenceValues
        switch kind {
        case .ritualCompletion:
            values = EvidenceValues(
                progress: 0.16,
                confidence: 0.06,
                minutes: stepMinutes(for: goal.mode),
                note: "Ritual completion from Rituals."
            )
        case .ritualMinimumVersion:
            values = EvidenceValues(
                progress: 0.08,
                confidence: 0.03,
                minutes: 5,
                note: "Minimum version from Rituals: \(step.actionability.fallbackMicroStep)"
            )
        default:
            values = EvidenceValues(
                progress: 0.05,
                confidence: 0.02,
                minutes: 10,
                note: "Quick log from Rituals."
            )
        }
        return ProgressEvidence(
            id: id, goalID: goal.id, stepID: step.id, evidenceKind: kind, source: .manual,
            capturedAt: capturedAt, progressDelta: values.progress, confidenceDelta: values.confidence,
            minutesInvested: values.minutes, note: values.note
        )
    }

    private func replacingStep(in goal: Goal, stepID: String, now: Date, transform: (Step) -> Step) -> Goal {
        let sections = goal.plan?.sections.map { section in
            PlanSection(
                id: section.id, goalID: section.goalID, title: section.title, summary: section.summary,
                kind: section.kind, orderIndex: section.orderIndex,
                steps: section.steps.map { $0.id == stepID ? transform($0) : $0 }
            )
        }
        let plan = goal.plan.map {
            GoalPlan(
                id: $0.id, goalID: $0.goalID, version: $0.version, generatedAt: $0.generatedAt,
                summary: $0.summary, strategy: $0.strategy, sections: sections ?? $0.sections,
                assumptions: $0.assumptions, lint: $0.lint
            )
        }
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

    private func copy(_ step: Step, timing: GoalTiming) -> Step {
        Step(
            id: step.id, sectionID: step.sectionID, title: step.title, summary: step.summary,
            type: step.type, state: step.state, owner: step.owner, timing: timing,
            dependencyStepIDs: step.dependencyStepIDs, isOptional: step.isOptional,
            isRepeatable: step.isRepeatable, evidenceRequired: step.evidenceRequired,
            successSignals: step.successSignals, actionability: step.actionability
        )
    }

    private func copy(_ goal: Goal, state: GoalLifecycleState, updatedAt: String) -> Goal {
        Goal(
            schemaVersion: goal.schemaVersion, id: goal.id, revision: goal.revision + 1,
            createdAt: goal.createdAt, updatedAt: updatedAt, state: state, title: goal.title,
            summary: goal.summary, mode: goal.mode, relationshipKind: goal.relationshipKind,
            actor: goal.actor, parentGoalID: goal.parentGoalID, childGoalIDs: goal.childGoalIDs,
            supportGoalIDs: goal.supportGoalIDs, tags: goal.tags, timing: goal.timing,
            planningStrategy: goal.planningStrategy, progressStrategy: goal.progressStrategy,
            plan: goal.plan, lifeGraph: goal.lifeGraph
        )
    }

    private func delayedTiming(_ timing: GoalTiming, now: Date) -> GoalTiming {
        let shifted = Calendar(identifier: .gregorian).date(byAdding: .hour, value: 4, to: now) ?? now
        return GoalTiming(
            tempo: timing.tempo, timingType: timing.timingType, startsOn: timing.startsOn,
            dueAt: timing.dueAt, targetBy: timing.targetBy, windowStart: timing.windowStart,
            windowEnd: timing.windowEnd, suggestedNextAt: DomainTimestamp.string(from: shifted),
            repeatEveryDays: timing.repeatEveryDays,
            progressReviewCadenceDays: timing.progressReviewCadenceDays
        )
    }

    private func stepMinutes(for mode: GoalMode) -> Int {
        switch mode {
        case .recovery: 10
        case .delegatedSupport: 12
        default: 20
        }
    }
}

protocol TimeRitualActionMaterializing: Sendable {
    func validate(_ plan: TimeRitualActionPlan) async throws
    func materialize(_ plan: TimeRitualActionPlan) async throws
}

struct RepositoryTimeRitualActionMaterializer: TimeRitualActionMaterializing {
    let repositories: AppRepositories

    func validate(_ plan: TimeRitualActionPlan) async throws {
        guard let current = try await repositories.goals.goal(id: plan.goalID) else {
            throw TimeRitualDurableActionError.unavailable
        }
        guard current.plan?.sections.flatMap(\.steps).contains(where: { $0.id == plan.stepID }) == true else {
            throw TimeRitualDurableActionError.unavailable
        }
        guard current.revision == plan.expectedGoalRevision || current == plan.updatedGoal else {
            throw TimeRitualDurableActionError.staleGoalRevision(
                expected: plan.expectedGoalRevision,
                actual: current.revision
            )
        }
    }

    func materialize(_ plan: TimeRitualActionPlan) async throws {
        _ = plan
        throw TimeRitualDurableActionError.materializerUnavailable
    }
}

extension AmbitionsCommand {
    var isTimeRitualActionMutation: Bool {
        TimeRitualActionPlan.decode(command: self) != nil
    }
}

extension AmbitionsCommandExecutor {
    func executeTimeRitualAction(_ command: AmbitionsCommand) async -> AmbitionsCommandExecutionResult {
        guard let plan = TimeRitualActionPlan.decode(command: command),
              plan.goalID == command.target.goalID,
              plan.stepID == command.target.stepID else {
            return AmbitionsCommandExecutionResult(
                status: .blocked,
                summary: "Time ritual action plan is missing or does not match its target.",
                route: .time,
                target: command.target,
                metadata: ["blockedBy": "time_ritual_action_plan_invalid"]
            )
        }
        do {
            guard let timeRitualActionMaterializer else {
                throw TimeRitualDurableActionError.materializerUnavailable
            }
            try await timeRitualActionMaterializer.validate(plan)
        } catch TimeRitualDurableActionError.materializerUnavailable {
            return AmbitionsCommandExecutionResult(
                status: .blocked,
                summary: "Time ritual action could not be committed because its local materializer is unavailable.",
                route: .time,
                target: command.target,
                metadata: ["blockedBy": "time_ritual_action_materializer_unavailable"]
            )
        } catch {
            return AmbitionsCommandExecutionResult(
                status: .blocked,
                summary: "Time ritual action could not be committed because the ritual changed.",
                route: .time,
                target: command.target,
                metadata: ["blockedBy": "time_ritual_action_stale_revision"]
            )
        }
        return AmbitionsCommandExecutionResult(
            status: .succeeded,
            summary: "Time ritual action committed.",
            route: .time,
            target: command.target,
            metadata: [
                "timeRitualActionKind": plan.actionKind.rawValue,
                "timeRitualActionMaterialization": "pending_authority_commit",
                "projectionReloadRequired": "true"
            ]
        )
    }

    func materializeTimeRitualAction(
        _ command: AmbitionsCommand,
        committedResult: AmbitionsCommandExecutionResult
    ) async -> AmbitionsCommandExecutionResult {
        guard let timeRitualActionMaterializer else {
            return committedResult.mergingMetadata([
                "timeRitualActionMaterialization": "needs_recovery",
                "timeRitualActionMaterializationError": "materializer_unavailable"
            ])
        }
        do {
            let envelopes = try await runtimeEvents?.fetchEvents(matching: .commandID(command.id), limit: nil) ?? []
            guard let plan = try envelopes.compactMap({ envelope -> TimeRitualActionPlan? in
                guard case let .domainMutation(record) = envelope.event.payload,
                      case let .timeRitualActionApplied(value) = try record.decodedEvent() else { return nil }
                return value
            }).first else {
                return committedResult.mergingMetadata([
                    "timeRitualActionMaterialization": "needs_recovery",
                    "timeRitualActionMaterializationError": "semantic_time_ritual_action_missing"
                ])
            }
            try await timeRitualActionMaterializer.materialize(plan)
            return committedResult.mergingMetadata([
                "timeRitualActionMaterialization": "saved_post_authority"
            ])
        } catch {
            return committedResult.mergingMetadata([
                "timeRitualActionMaterialization": "needs_recovery",
                "timeRitualActionMaterializationError": String(describing: error)
            ])
        }
    }
}
