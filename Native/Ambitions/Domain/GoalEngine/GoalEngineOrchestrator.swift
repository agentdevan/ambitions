import Foundation

struct GoalEngineOrchestrator: GoalOrchestrating {
    private let intake: GoalEngineIntakeService
    private let planner: any GoalPlanning

    init(
        intake: GoalEngineIntakeService = GoalEngineIntakeService(),
        planner: any GoalPlanning = GoalPlanner()
    ) {
        self.intake = intake
        self.planner = planner
    }

    func compileGoal(_ rawInput: String, context: GoalEngineOrchestrationContext = .init()) -> GoalOrchestrationResult {
        let normalizedContext = normalize(context)
        let draftBuild = intake.buildGoalDraft(from: rawInput, referenceNow: normalizedContext.referenceNow)
        let prepared = buildPreparedInput(classification: draftBuild.classification, clarification: draftBuild.clarification, context: normalizedContext)

        let requiresClarification =
            !prepared.clarification.contradictions.isEmpty ||
            prepared.classification.readiness == .needsClarification ||
            (prepared.classification.readiness == .canPlanWithDefaults && normalizedContext.preferredPlanningStrictness == .strict)

        if requiresClarification {
            let metadata = buildMetadata(classification: prepared.classification, clarification: prepared.clarification, context: normalizedContext, plannerResult: nil)
            return .clarificationRequired(
                GoalClarificationRequiredResult(
                    draft: prepared.classification.draft,
                    clarification: prepared.clarification,
                    metadata: metadata
                )
            )
        }

        let plannerResult = planner.plan(
            input: GoalPlannerInput(
                draft: prepared.classification.draft,
                classification: prepared.classification,
                clarification: ClarificationSet(
                    readiness: prepared.clarification.readiness,
                    questions: prepared.clarification.questions,
                    missingFields: prepared.clarification.missingFields
                )
            ),
            options: GoalPlannerOptions(goalID: normalizedContext.goalID, now: normalizedContext.referenceNow)
        )
        let metadata = buildMetadata(classification: prepared.classification, clarification: prepared.clarification, context: normalizedContext, plannerResult: plannerResult)

        switch plannerResult {
        case let .plan(draft, plan, lint):
            return .planned(GoalPlannedResult(draft: draft, plan: plan, lint: lint, metadata: metadata))
        case let .starterPlan(draft, plan, lint, assumptions):
            return .starterPlanned(GoalStarterPlannedResult(draft: draft, plan: plan, lint: lint, assumptions: assumptions, clarification: prepared.clarification, metadata: metadata))
        case let .blocked(draft, blockers, _):
            return .blocked(GoalBlockedResult(draft: draft, blockers: blockers, clarification: prepared.clarification, metadata: metadata))
        }
    }

    private func normalize(_ context: GoalEngineOrchestrationContext) -> GoalEngineOrchestrationContextSnapshot {
        let clarified = Dictionary(uniqueKeysWithValues: context.clarifiedFields.compactMap { key, value in
            let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
            return trimmed.isEmpty ? nil : (key.rawValue, trimmed)
        })
        return GoalEngineOrchestrationContextSnapshot(
            goalID: trimmed(context.goalID),
            actorName: trimmed(context.actorName),
            preferredPlanningStrictness: context.preferredPlanningStrictness,
            goalOwnerRole: trimmed(context.goalOwnerRole),
            supportScope: context.supportScope,
            deadlineHints: context.deadlineHints.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty },
            existingGoalReferences: context.existingGoalReferences.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty },
            sourceScreen: trimmed(context.sourceScreen),
            sourceFlow: trimmed(context.sourceFlow),
            clarifiedFields: clarified,
            referenceNow: trimmed(context.referenceNow)
        )
    }

    private func trimmed(_ value: String?) -> String? {
        guard let value else { return nil }
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    private func buildPreparedInput(classification: ClassificationResult, clarification: ClarificationSet, context: GoalEngineOrchestrationContextSnapshot) -> (classification: ClassificationResult, clarification: GoalOrchestrationClarification) {
        let resolvedFields = Set(context.clarifiedFields.keys.compactMap(MissingFieldKey.init(rawValue:)))
        var missingFields = classification.missingFields.filter { !resolvedFields.contains($0.field) }
        if context.supportScope != nil {
            missingFields.removeAll { $0.field == .supportScope }
        }

        let updatedDraft = GoalDraft(
            schemaVersion: classification.draft.schemaVersion,
            source: classification.draft.source,
            title: classification.draft.title,
            summary: classification.draft.summary,
            mode: classification.draft.mode,
            relationshipKind: classification.draft.relationshipKind,
            actor: GoalActor(
                actorID: classification.draft.actor.actorID,
                displayName: context.actorName ?? classification.draft.actor.displayName,
                ownership: classification.draft.actor.ownership,
                roleLabel: context.goalOwnerRole ?? classification.draft.actor.roleLabel,
                isPrimary: classification.draft.actor.isPrimary
            ),
            parentGoalID: classification.draft.parentGoalID,
            tags: classification.draft.tags,
            timing: classification.draft.timing,
            planningStrategy: classification.draft.planningStrategy,
            progressStrategy: classification.draft.progressStrategy,
            lifeGraph: classification.draft.lifeGraph
        )

        let contradictions = detectContradictions(classification: classification, context: context)
        let contradictionFields = Set(contradictions.map { $0.question.field })
        let contradictionMissingFields = contradictions
            .filter { contradiction in !missingFields.contains(where: { $0.field == contradiction.question.field }) }
            .map { contradiction in
                MissingField(field: contradiction.question.field, reason: contradiction.reason, blocksPlanning: true)
            }

        let readiness = contradictions.isEmpty ? recomputeReadiness(from: missingFields) : .needsClarification
        let questions = Array(
            (clarification.questions.filter { !resolvedFields.contains($0.field) && !contradictionFields.contains($0.field) } + contradictions.map(\.question))
                .prefix(3)
        )
        let orchestrationClarification = GoalOrchestrationClarification(
            readiness: readiness,
            questions: questions,
            missingFields: missingFields + contradictionMissingFields,
            contradictions: contradictions
        )

        let adjustedClassification = ClassificationResult(
            rawInput: classification.rawInput,
            normalizedInput: classification.normalizedInput,
            title: classification.title,
            summary: classification.summary,
            mode: classification.mode,
            tempo: classification.tempo,
            relationshipKind: classification.relationshipKind,
            executionOwnership: classification.executionOwnership,
            userRole: classification.userRole,
            strictDeadlinesAppropriate: classification.strictDeadlinesAppropriate,
            planningStrategyID: classification.planningStrategyID,
            progressStrategyID: classification.progressStrategyID,
            readiness: orchestrationClarification.readiness,
            clarificationNeeded: orchestrationClarification.readiness != .readyForPlanning,
            starterPlanSafe: orchestrationClarification.readiness != .needsClarification,
            missingFields: orchestrationClarification.missingFields,
            tags: classification.tags,
            draft: updatedDraft
        )

        return (adjustedClassification, orchestrationClarification)
    }

    private func recomputeReadiness(from missingFields: [MissingField]) -> PlanningReadiness {
        if missingFields.contains(where: \.blocksPlanning) {
            return .needsClarification
        }
        return missingFields.isEmpty ? .readyForPlanning : .canPlanWithDefaults
    }

    private func detectContradictions(classification: ClassificationResult, context: GoalEngineOrchestrationContextSnapshot) -> [GoalInputContradiction] {
        let lower = classification.normalizedInput.lowercased()
        let mentionsNoDeadlines = lower.range(of: #"\b(no deadlines|don't want deadlines|dont want deadlines|without deadlines)\b"#, options: .regularExpression) != nil
        let mentionsSpecificTiming = lower.range(of: #"\b(deadline|due|must|no later than|this week|this month|this quarter|this year|before|by [a-z]+|by \d{4}-\d{2}-\d{2}|next month|this summer|this fall)\b"#, options: .regularExpression) != nil || !context.deadlineHints.isEmpty

        var contradictions: [GoalInputContradiction] = []

        if mentionsNoDeadlines && mentionsSpecificTiming {
            contradictions.append(
                GoalInputContradiction(
                    code: .timingConflict,
                    reason: "The input asks to avoid deadline pressure while also pointing at a concrete date or timing anchor.",
                    question: ClarificationQuestion(
                        id: "timing-conflict",
                        field: .timeHorizon,
                        prompt: "You mentioned both avoiding deadlines and wanting a specific date. Should this stay flexible, or should the date drive planning?",
                        rationale: "The orchestrator should not pretend it knows whether the date is a soft hint or a real constraint.",
                        skipSafeDefault: "No full plan is produced until the timing preference is clarified."
                    )
                )
            )
        }

        if lower.range(of: #"\b(i don't know where to start|dont know where to start|where to start)\b"#, options: .regularExpression) != nil {
            contradictions.append(
                GoalInputContradiction(
                    code: .goalSubjectGap,
                    reason: "The input signals uncertainty about where to begin, but it does not supply a concrete goal subject the planner can safely decompose.",
                    question: ClarificationQuestion(
                        id: "goal-subject-gap",
                        field: .goalSubject,
                        prompt: "What is the actual goal you want help starting?",
                        rationale: "Starter planning still needs a concrete subject. Uncertainty about the first step is not the same as having a defined goal.",
                        skipSafeDefault: "No starter plan is produced until the goal subject is explicit."
                    )
                )
            )
        }

        return contradictions
    }

    private func buildMetadata(classification: ClassificationResult, clarification: GoalOrchestrationClarification, context: GoalEngineOrchestrationContextSnapshot, plannerResult: GoalPlannerResult?) -> GoalOrchestrationMetadata {
        let assumptions: [PlanAssumption]
        switch plannerResult {
        case let .starterPlan(_, _, _, starterAssumptions):
            assumptions = starterAssumptions
        default:
            assumptions = []
        }

        let plannerMetadata: GoalOrchestrationPlannerMetadata
        switch plannerResult {
        case let .plan(_, plan, lint):
            plannerMetadata = GoalOrchestrationPlannerMetadata(attempted: true, resultKind: .plan, blockers: [], lint: lint, evaluation: plan.evaluation)
        case let .starterPlan(_, plan, lint, _):
            plannerMetadata = GoalOrchestrationPlannerMetadata(attempted: true, resultKind: .starterPlan, blockers: [], lint: lint, evaluation: plan.evaluation)
        case let .blocked(_, blockers, _):
            plannerMetadata = GoalOrchestrationPlannerMetadata(attempted: true, resultKind: .blocked, blockers: blockers, lint: nil)
        case .none:
            plannerMetadata = GoalOrchestrationPlannerMetadata(attempted: false, resultKind: nil, blockers: [], lint: nil)
        }

        return GoalOrchestrationMetadata(
            input: GoalEngineOrchestrationInputSnapshot(rawInput: classification.rawInput, normalizedInput: classification.normalizedInput),
            context: context,
            inference: GoalOrchestrationInferenceSnapshot(
                mode: classification.mode,
                tempo: classification.tempo,
                relationshipKind: classification.relationshipKind,
                executionOwnership: classification.executionOwnership,
                userRole: classification.userRole,
                strictDeadlinesAppropriate: classification.strictDeadlinesAppropriate,
                planningStrategyID: classification.planningStrategyID,
                progressStrategyID: classification.progressStrategyID,
                actorDisplayName: classification.draft.actor.displayName,
                actorRoleLabel: classification.draft.actor.roleLabel,
                timing: classification.draft.timing
            ),
            clarification: clarification,
            planner: plannerMetadata,
            reasoning: GoalOrchestrationReasoningMetadata(
                readiness: classification.readiness,
                clarificationNeeded: classification.clarificationNeeded,
                starterPlanSafe: classification.starterPlanSafe,
                missingFields: classification.missingFields,
                contradictions: clarification.contradictions,
                assumptions: assumptions,
                inference: [
                    "mode": classification.mode.metadata,
                    "tempo": classification.tempo.metadata,
                    "relationshipKind": classification.relationshipKind.metadata,
                    "executionOwnership": classification.executionOwnership.metadata,
                    "userRole": classification.userRole.metadata,
                    "strictDeadlinesAppropriate": classification.strictDeadlinesAppropriate.metadata,
                    "planningStrategyID": classification.planningStrategyID.metadata,
                    "progressStrategyID": classification.progressStrategyID.metadata,
                ]
            )
        )
    }
}

func compileGoal(_ rawInput: String, context: GoalEngineOrchestrationContext = .init()) -> GoalOrchestrationResult {
    GoalEngineOrchestrator().compileGoal(rawInput, context: context)
}
