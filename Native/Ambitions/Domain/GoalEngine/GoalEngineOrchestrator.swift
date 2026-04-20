import Foundation

struct GoalEngineOrchestrator: GoalOrchestrating {
    private let intake: GoalEngineIntakeService
    private let planner: any GoalPlanning
    private let clarificationService: any GoalClarificationAnalyzing
    private let understandingService: any GoalUnderstandingBuilding

    init(
        intake: GoalEngineIntakeService = GoalEngineIntakeService(),
        planner: any GoalPlanning = GoalPlanner(),
        clarificationService: any GoalClarificationAnalyzing = DefaultGoalClarificationService(),
        understandingService: any GoalUnderstandingBuilding = DefaultGoalUnderstandingService()
    ) {
        self.intake = intake
        self.planner = planner
        self.clarificationService = clarificationService
        self.understandingService = understandingService
    }

    func compileGoal(_ rawInput: String, context: GoalEngineOrchestrationContext = .init()) -> GoalOrchestrationResult {
        let normalizedContext = normalize(context)
        let draftBuild = intake.buildGoalDraft(from: rawInput, referenceNow: normalizedContext.referenceNow)
        let analysis = clarificationService.analyze(
            classification: draftBuild.classification,
            context: normalizedContext
        )
        let prepared = buildPreparedInput(
            classification: draftBuild.classification,
            analysis: analysis,
            context: normalizedContext
        )
        let understanding = understandingService.build(
            classification: prepared.classification,
            clarification: prepared.clarification.analysis,
            context: normalizedContext,
            contradictions: prepared.clarification.contradictions
        )

        if prepared.clarification.analysis.decision == .mustClarifyBeforeCompile {
            let metadata = buildMetadata(classification: prepared.classification, clarification: prepared.clarification, context: normalizedContext, plannerResult: nil, understanding: understanding)
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
                clarification: prepared.clarification.analysis.compatibilityClarificationSet,
                clarificationAnalysis: prepared.clarification.analysis,
                understanding: understanding
            ),
            options: GoalPlannerOptions(goalID: normalizedContext.goalID, now: normalizedContext.referenceNow)
        )
        let metadata = buildMetadata(classification: prepared.classification, clarification: prepared.clarification, context: normalizedContext, plannerResult: plannerResult, understanding: understanding)

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
            referenceNow: trimmed(context.referenceNow),
            knowledgeContext: context.knowledgeContext
        )
    }

    private func trimmed(_ value: String?) -> String? {
        guard let value else { return nil }
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    private func buildPreparedInput(
        classification: ClassificationResult,
        analysis: GoalClarificationAnalysis,
        context: GoalEngineOrchestrationContextSnapshot
    ) -> (classification: ClassificationResult, clarification: GoalOrchestrationClarification) {
        let resolvedFields = Set(context.clarifiedFields.keys.compactMap(MissingFieldKey.init(rawValue:)))
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
        let preparedAnalysis = adjustedAnalysis(
            analysis: analysis,
            contradictions: contradictions,
            resolvedFields: resolvedFields,
            supportScopeProvided: context.supportScope != nil,
            strictPlanning: context.preferredPlanningStrictness == .strict
        )

        let orchestrationClarification = GoalOrchestrationClarification(
            readiness: preparedAnalysis.compatibilityReadiness,
            questions: preparedAnalysis.compatibilityQuestions,
            missingFields: preparedAnalysis.compatibilityMissingFields,
            contradictions: contradictions,
            analysis: preparedAnalysis
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
            clarificationNeeded: preparedAnalysis.decision.clarificationNeeded,
            starterPlanSafe: preparedAnalysis.decision.starterPlanSafe,
            missingFields: orchestrationClarification.missingFields,
            tags: classification.tags,
            draft: updatedDraft
        )

        return (adjustedClassification, orchestrationClarification)
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

    private func buildMetadata(
        classification: ClassificationResult,
        clarification: GoalOrchestrationClarification,
        context: GoalEngineOrchestrationContextSnapshot,
        plannerResult: GoalPlannerResult?,
        understanding: GoalUnderstanding
    ) -> GoalOrchestrationMetadata {
        let assumptions: [PlanAssumption]
        switch plannerResult {
        case let .starterPlan(_, _, _, starterAssumptions):
            assumptions = starterAssumptions
        default:
            assumptions = clarification.analysis.compatibilityPlanAssumptions
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
            ),
            understanding: understanding
        )
    }

    private func adjustedAnalysis(
        analysis: GoalClarificationAnalysis,
        contradictions: [GoalInputContradiction],
        resolvedFields: Set<MissingFieldKey>,
        supportScopeProvided: Bool,
        strictPlanning: Bool
    ) -> GoalClarificationAnalysis {
        var missingContext = analysis.missingContext.filter { item in
            guard let field = item.field else { return true }
            if resolvedFields.contains(field) {
                return false
            }
            if supportScopeProvided && field == .supportScope {
                return false
            }
            return true
        }

        var ambiguities = analysis.ambiguities.filter { signal in
            guard let field = signal.relatedField else { return true }
            if resolvedFields.contains(field) {
                return false
            }
            if supportScopeProvided && field == .supportScope {
                return false
            }
            return true
        }

        var questions = analysis.questions.filter { question in
            guard let field = question.targetField else { return true }
            if resolvedFields.contains(field) {
                return false
            }
            if supportScopeProvided && field == .supportScope {
                return false
            }
            return true
        }

        let contradictionFields = Set(contradictions.map(\.question.field))
        let contradictionMissingContext = contradictions
            .filter { contradiction in
                missingContext.contains(where: { $0.field == contradiction.question.field }) == false
            }
            .map { contradiction in
                GoalMissingContextItem(
                    id: "contradiction-\(contradiction.code.rawValue)",
                    field: contradiction.question.field,
                    label: contradiction.question.field.rawValue,
                    reason: contradiction.reason,
                    severity: .blocking,
                    blocksCompilation: true
                )
            }
        missingContext.append(contentsOf: contradictionMissingContext)

        ambiguities.append(
            contentsOf: contradictions.map { contradiction in
                GoalAmbiguitySignal(
                    id: "contradiction-signal-\(contradiction.code.rawValue)",
                    type: contradiction.code == .timingConflict ? .timeline : .readiness,
                    summary: contradiction.reason,
                    detail: contradiction.question.rationale,
                    severity: .blocking,
                    relatedField: contradiction.question.field,
                    candidateIDs: []
                )
            }
        )

        questions.append(
            contentsOf: contradictions.map { contradiction in
                GoalClarificationQuestionContract(
                    id: contradiction.question.id,
                    prompt: contradiction.question.prompt,
                    rationale: contradiction.question.rationale,
                    targetField: contradiction.question.field,
                    addressesAmbiguityTypes: contradiction.code == .timingConflict ? [.timeline] : [.readiness],
                    severity: .blocking,
                    blocking: true,
                    skipSafeDefault: contradiction.question.skipSafeDefault
                )
            }
        )

        let decision: GoalClarificationDecision
        if contradictions.isEmpty == false {
            decision = .mustClarifyBeforeCompile
        } else if strictPlanning && (missingContext.isEmpty == false || ambiguities.contains(where: { $0.severity == .important })) {
            decision = .mustClarifyBeforeCompile
        } else if missingContext.contains(where: \.blocksCompilation) || ambiguities.contains(where: { $0.severity.blocksCompilation }) {
            decision = .mustClarifyBeforeCompile
        } else {
            decision = .safeToProceedWithAssumptions
        }

        return GoalClarificationAnalysis(
            candidateInterpretations: analysis.candidateInterpretations,
            ambiguities: stableUniqueAmbiguities(ambiguities),
            missingContext: stableUniqueMissingContext(missingContext),
            assumptions: analysis.assumptions.filter { assumption in
                guard let field = assumption.relatedField else { return true }
                if resolvedFields.contains(field) {
                    return false
                }
                if supportScopeProvided && field == .supportScope {
                    return false
                }
                return true
            },
            questions: stableUniqueQuestions(questions).filter { question in
                if let field = question.targetField {
                    return contradictionFields.contains(field) == false || question.blocking
                }
                return true
            },
            decision: decision,
            reasoning: GoalClarificationReasoningMetadata(
                signalNotes: analysis.reasoning.signalNotes + contradictionNotes(from: contradictions, strictPlanning: strictPlanning),
                inference: analysis.reasoning.inference,
                auditTags: stableStrings(analysis.reasoning.auditTags + contradictions.map { "contradiction:\($0.code.rawValue)" } + (strictPlanning ? ["strict_planning"] : []))
            )
        )
    }

    private func stableUniqueMissingContext(_ items: [GoalMissingContextItem]) -> [GoalMissingContextItem] {
        var seen: Set<String> = []
        var result: [GoalMissingContextItem] = []
        for item in items where seen.insert(item.id).inserted {
            result.append(item)
        }
        return result
    }

    private func stableUniqueAmbiguities(_ items: [GoalAmbiguitySignal]) -> [GoalAmbiguitySignal] {
        var seen: Set<String> = []
        var result: [GoalAmbiguitySignal] = []
        for item in items where seen.insert(item.id).inserted {
            result.append(item)
        }
        return result
    }

    private func stableUniqueQuestions(_ items: [GoalClarificationQuestionContract]) -> [GoalClarificationQuestionContract] {
        var seen: Set<String> = []
        var result: [GoalClarificationQuestionContract] = []
        for item in items where seen.insert(item.id).inserted {
            result.append(item)
        }
        return result
    }

    private func stableStrings(_ items: [String]) -> [String] {
        var seen: Set<String> = []
        var result: [String] = []
        for item in items where seen.insert(item).inserted {
            result.append(item)
        }
        return result
    }

    private func contradictionNotes(from contradictions: [GoalInputContradiction], strictPlanning: Bool) -> [String] {
        var notes = contradictions.map { "Contradiction preserved: \($0.code.rawValue)." }
        if strictPlanning {
            notes.append("Strict planning mode promoted unresolved ambiguity into a clarify-first decision.")
        }
        return notes
    }
}

func compileGoal(_ rawInput: String, context: GoalEngineOrchestrationContext = .init()) -> GoalOrchestrationResult {
    GoalEngineOrchestrator().compileGoal(rawInput, context: context)
}
