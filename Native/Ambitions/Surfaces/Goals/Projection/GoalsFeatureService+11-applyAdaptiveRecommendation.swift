import AmbitionsDesignSystem
import Foundation

extension RepositoryBackedGoalsService {

    func applyAdaptiveRecommendation(
        goal: Goal,
        draft: PersistedGoalDraft?,
        step: Step,
        history: [GoalFeedbackEvent],
        fallbackTitle: String,
        fallbackBody: String
    ) async throws -> GoalDetailActionResponse {
        guard let draft,
              let adjustment = adjustmentPayload(draft: draft, goal: goal, step: step, history: history) else {
            return GoalDetailActionResponse(
                message: GoalDetailInlineMessage(title: fallbackTitle, body: fallbackBody, state: .selected)
            )
        }

        let updatedGoal = updatedGoal(goal: goal, step: step, recommendation: adjustment.recommendation)
        if updatedGoal.revision != goal.revision {
            try await repositories.goals.saveGoals([updatedGoal])
        }

        return GoalDetailActionResponse(
            message: message(for: adjustment.recommendation, fallbackTitle: fallbackTitle, fallbackBody: fallbackBody)
        )
    }


    func adjustPriority(for detail: DetailContext, direction: Int) async throws -> GoalDetailActionResponse {
        let snapshot = try await loadSnapshot()
        let identifier = detail.goal?.id ?? detail.draft?.id
        guard let identifier else {
            throw GoalsFeatureError.notFound
        }

        var state = snapshot.appState
        var ordered = normalizedPriorityOrder(snapshot: snapshot)
        guard let currentIndex = ordered.firstIndex(of: identifier) else {
            throw GoalsFeatureError.notFound
        }

        let nextIndex = min(max(0, currentIndex + direction), max(ordered.count - 1, 0))
        if nextIndex != currentIndex {
            ordered.swapAt(currentIndex, nextIndex)
            state.goalPriorityOrder = ordered
            try await repositories.appState.saveState(state)
        }

        let position = (ordered.firstIndex(of: identifier) ?? currentIndex) + 1
        return GoalDetailActionResponse(
            message: GoalDetailInlineMessage(
                title: "Priority updated",
                body: "This item now sits at manual priority position \(position). Goals sort will preserve that order when you switch to the Priority lens.",
                state: .selected
            )
        )
    }


    func materializeDraft(
        from existingDraft: PersistedGoalDraft,
        answeredField: MissingFieldKey,
        answer: String,
        now: Date
    ) -> (draft: PersistedGoalDraft, goal: Goal?, message: String) {
        var clarifiedFields = existingDraft.metadata?.context.clarifiedFields ?? [:]
        clarifiedFields[answeredField.rawValue] = answer

        let previousContext = existingDraft.metadata?.context
        let result = orchestrator.compileGoal(
            existingDraft.metadata?.input.rawInput ?? existingDraft.draft.title,
            context: GoalEngineOrchestrationContext(
                goalID: previousContext?.goalID ?? existingDraft.plannedGoalID,
                actorName: previousContext?.actorName,
                preferredPlanningStrictness: previousContext?.preferredPlanningStrictness ?? .balanced,
                goalOwnerRole: previousContext?.goalOwnerRole,
                supportScope: previousContext?.supportScope,
                deadlineHints: previousContext?.deadlineHints ?? [],
                existingGoalReferences: previousContext?.existingGoalReferences ?? [],
                sourceScreen: previousContext?.sourceScreen,
                sourceFlow: previousContext?.sourceFlow,
                clarifiedFields: Dictionary(uniqueKeysWithValues: clarifiedFields.compactMap { key, value in
                    MissingFieldKey(rawValue: key).map { ($0, value) }
                }),
                referenceNow: Self.iso.string(from: now)
            )
        )

        let updatedAt = Self.iso.string(from: now)
        let draft: PersistedGoalDraft
        let goal: Goal?
        let message: String

        switch result {
        case let .clarificationRequired(required):
            draft = PersistedGoalDraft(
                id: existingDraft.id,
                createdAt: existingDraft.createdAt,
                updatedAt: updatedAt,
                draft: required.draft,
                classification: nil,
                clarification: required.clarification,
                stagedPlan: nil,
                assumptions: required.metadata.reasoning.assumptions,
                blockers: [],
                metadata: required.metadata,
                plannedGoalID: nil,
                latestResultKind: .clarificationRequired
            )
            goal = nil
            message = "The answer was saved, but the planner is still waiting on the remaining missing detail."
        case let .blocked(blocked):
            draft = PersistedGoalDraft(
                id: existingDraft.id,
                createdAt: existingDraft.createdAt,
                updatedAt: updatedAt,
                draft: blocked.draft,
                classification: nil,
                clarification: blocked.clarification,
                stagedPlan: nil,
                assumptions: blocked.metadata.reasoning.assumptions,
                blockers: blocked.blockers,
                metadata: blocked.metadata,
                plannedGoalID: nil,
                latestResultKind: .blocked
            )
            goal = nil
            message = "The answer was saved. The blocker is clearer now, but the draft still needs one real constraint resolved."
        case let .planned(planned):
            let plannedGoalID = existingDraft.plannedGoalID ?? planned.plan.goalID
            draft = PersistedGoalDraft(
                id: existingDraft.id,
                createdAt: existingDraft.createdAt,
                updatedAt: updatedAt,
                draft: planned.draft,
                classification: nil,
                clarification: planned.metadata.clarification,
                stagedPlan: planned.plan,
                assumptions: [],
                blockers: [],
                metadata: planned.metadata,
                plannedGoalID: plannedGoalID,
                latestResultKind: .planned
            )
            goal = Goal(
                schemaVersion: goalEngineSchemaVersion,
                id: plannedGoalID,
                revision: existingDraft.plannedGoalID == nil ? 1 : 2,
                createdAt: existingDraft.createdAt,
                updatedAt: updatedAt,
                state: .active,
                title: planned.draft.title,
                summary: planned.draft.summary,
                mode: planned.draft.mode,
                relationshipKind: planned.draft.relationshipKind,
                actor: planned.draft.actor,
                parentGoalID: planned.draft.parentGoalID,
                childGoalIDs: [],
                supportGoalIDs: [],
                tags: planned.draft.tags,
                timing: planned.draft.timing,
                planningStrategy: planned.draft.planningStrategy,
                progressStrategy: planned.draft.progressStrategy,
                plan: planned.plan,
                lifeGraph: planned.draft.lifeGraph
            )
            message = "The clarification unlocked a full plan. Goal Detail is now reading a real persisted path instead of a blocked draft."
        case let .starterPlanned(starter):
            let plannedGoalID = existingDraft.plannedGoalID ?? starter.plan.goalID
            draft = PersistedGoalDraft(
                id: existingDraft.id,
                createdAt: existingDraft.createdAt,
                updatedAt: updatedAt,
                draft: starter.draft,
                classification: nil,
                clarification: starter.clarification,
                stagedPlan: starter.plan,
                assumptions: starter.assumptions,
                blockers: [],
                metadata: starter.metadata,
                plannedGoalID: plannedGoalID,
                latestResultKind: .starterPlanned
            )
            goal = Goal(
                schemaVersion: goalEngineSchemaVersion,
                id: plannedGoalID,
                revision: (existingDraft.plannedGoalID == nil ? 1 : 2),
                createdAt: existingDraft.createdAt,
                updatedAt: updatedAt,
                state: .active,
                title: starter.draft.title,
                summary: starter.draft.summary,
                mode: starter.draft.mode,
                relationshipKind: starter.draft.relationshipKind,
                actor: starter.draft.actor,
                parentGoalID: starter.draft.parentGoalID,
                childGoalIDs: [],
                supportGoalIDs: [],
                tags: starter.draft.tags,
                timing: starter.draft.timing,
                planningStrategy: starter.draft.planningStrategy,
                progressStrategy: starter.draft.progressStrategy,
                plan: starter.plan,
                lifeGraph: starter.draft.lifeGraph
            )
            message = "The clarification unlocked a starter plan. The path stays provisional, but it now writes back as a real native goal."
        }

        return (draft, goal, message)
    }


    func updatedGoal(goal: Goal, step: Step, recommendation: GoalReplanRecommendation) -> Goal {
        switch recommendation {
        case let .shrinkStep(_, _, _, _, smallerVersion, fallbackMicroStep):
            return update(goal: goal, stepID: step.id) { current in
                updatedStep(current, summary: "\(smallerVersion) Start with: \(fallbackMicroStep)", timing: current.timing)
            }
        case let .suggestMicroStep(_, _, _, _, microStep):
            return update(goal: goal, stepID: step.id) { current in
                updatedStep(current, summary: microStep, timing: current.timing)
            }
        case let .reviseStep(_, _, _, _, rewriteHints, _, _):
            return update(goal: goal, stepID: step.id) { current in
                updatedStep(current, summary: rewriteHints.first ?? current.summary ?? current.actionability.fallbackMicroStep, timing: current.timing)
            }
        case let .relaxTiming(_, _, _, _, suggestedTimingType, removeDeadline):
            return update(goal: goal, stepID: step.id) { current in
                let timing = removeDeadline
                    ? GoalTiming(
                        tempo: .untimed,
                        timingType: suggestedTimingType,
                        startsOn: current.timing.startsOn,
                        dueAt: nil,
                        targetBy: nil,
                        windowStart: nil,
                        windowEnd: nil,
                        suggestedNextAt: nil,
                        repeatEveryDays: current.timing.repeatEveryDays,
                        progressReviewCadenceDays: current.timing.progressReviewCadenceDays
                    )
                    : current.timing
                return updatedStep(current, summary: current.summary ?? current.actionability.fallbackMicroStep, timing: timing)
            }
        case let .adjustPlanTone(_, _, _, _, toneGuidance):
            return update(goal: goal, stepID: step.id) { current in
                updatedStep(current, summary: toneGuidance.first ?? current.summary ?? current.actionability.fallbackMicroStep, timing: current.timing)
            }
        case let .suggestAlternatePath(_, _, _, _, alternatePath, _):
            return update(goal: goal, stepID: step.id) { current in
                updatedStep(current, summary: alternatePath, timing: current.timing)
            }
        case .requestReclarification, .noChange:
            return goal
        }
    }


    func updatedStep(_ step: Step, summary: String, timing: GoalTiming) -> Step {
        Step(
            id: step.id,
            sectionID: step.sectionID,
            title: step.title,
            summary: summary,
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


    func message(
        for recommendation: GoalReplanRecommendation,
        fallbackTitle: String,
        fallbackBody: String
    ) -> GoalDetailInlineMessage {
        switch recommendation {
        case let .shrinkStep(_, rationale, _, _, smallerVersion, fallbackMicroStep):
            return GoalDetailInlineMessage(title: fallbackTitle, body: "\(smallerVersion) Start with: \(fallbackMicroStep)\n\n\(rationale)", state: .selected)
        case let .suggestMicroStep(_, rationale, _, _, microStep):
            return GoalDetailInlineMessage(title: fallbackTitle, body: "\(microStep)\n\n\(rationale)", state: .selected)
        case let .reviseStep(_, rationale, _, _, rewriteHints, _, hook):
            return GoalDetailInlineMessage(title: fallbackTitle, body: "\(rewriteHints.first ?? fallbackBody)\n\n\(hook?.explanation ?? rationale)", state: .selected)
        case let .relaxTiming(_, rationale, _, _, _, _):
            return GoalDetailInlineMessage(title: "Timing softened", body: rationale, state: .selected)
        case let .requestReclarification(_, rationale, _, _, questions):
            return GoalDetailInlineMessage(title: "Clarification first", body: ([rationale] + questions).joined(separator: "\n"), state: .warning)
        case let .adjustPlanTone(_, rationale, _, _, toneGuidance):
            return GoalDetailInlineMessage(title: "Tone adjusted", body: ([rationale] + toneGuidance).joined(separator: "\n"), state: .selected)
        case let .suggestAlternatePath(_, rationale, _, _, alternatePath, hook):
            return GoalDetailInlineMessage(title: fallbackTitle, body: "\(alternatePath)\n\n\(hook?.explanation ?? rationale)", state: .selected)
        case .noChange:
            return GoalDetailInlineMessage(title: fallbackTitle, body: fallbackBody, state: .selected)
        }
    }


    func clarificationState(from draft: PersistedGoalDraft?) -> GoalClarificationState? {
        guard draft?.latestResultKind == .clarificationRequired, let clarification = draft?.clarification else {
            return nil
        }

        return GoalClarificationState(
            title: "Clarification needed",
            subtitle: "Ambitions is pausing decomposition until these questions are answered cleanly.",
            questions: clarification.questions.map {
                GoalClarificationQuestionState(
                    id: $0.id,
                    field: $0.field,
                    prompt: $0.prompt,
                    rationale: $0.rationale,
                    gentleDefault: $0.skipSafeDefault,
                    existingAnswer: draft?.metadata?.context.clarifiedFields[$0.field.rawValue]
                )
            }
        )
    }


    func blockedState(from draft: PersistedGoalDraft?) -> GoalBlockedState? {
        guard draft?.latestResultKind == .blocked else { return nil }

        return GoalBlockedState(
            title: "Blocked planning state",
            subtitle: "The planner kept the blocker explicit instead of generating performative steps.",
            blockers: draft?.blockers.map(\.reason) ?? ["A blocking condition is still unresolved."]
        )
    }
}
