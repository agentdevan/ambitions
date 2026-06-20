import Foundation

extension GoalDraft {
    func makeGoalIntent(
        id: String,
        rawStatement: String? = nil,
        createdAt: String,
        sourceSurface: GoalIntentSourceSurface = .goals,
        userKnownContext: [GoalContextSignal] = [],
        privacyClass: GoalPrivacyClass = .localOnly,
        sourceState: GoalSourceState = .draft
    ) -> GoalIntent {
        GoalIntent(
            id: id,
            rawStatement: rawStatement ?? title,
            createdAt: createdAt,
            sourceSurface: sourceSurface,
            userKnownContext: userKnownContext,
            privacyClass: privacyClass,
            sourceState: sourceState
        )
    }
}

extension GoalCompiledPath {
    func makeGoalIntentDayCompilerInput(
        intent: GoalIntent,
        capacityEnvelope: GoalIntentCapacityEnvelope? = nil,
        localOnly: Bool = true
    ) -> GoalIntentDayCompilerInput {
        let candidate = candidates.first
        let status = compiledStatus
        let assumptions = candidate?.assumptions.map {
            GoalIntentAssumption(
                id: $0.id,
                summary: $0.summary,
                rationale: $0.rationale,
                confidence: $0.confidence,
                source: $0.source,
                relatedField: $0.relatedField,
                safeForCompilation: $0.safeForCompilation
            )
        } ?? []
        let blockedReasons = compiledBlockedReasons
        let clarification = GoalIntentClarification(
            status: status,
            readiness: compiledReadiness(for: status),
            questions: compiledQuestions(for: status),
            missingFields: compiledMissingFields(for: status)
        )

        return GoalIntentDayCompilerInput(
            intent: intent,
            status: status,
            assumptions: assumptions,
            clarification: clarification,
            blockedReasons: blockedReasons,
            capacityEnvelope: capacityEnvelope,
            localOnly: localOnly
        )
    }

    func makeCompiledSteps(intentID: String) -> [CompiledStep] {
        guard statusForGoalIntentCompiler != .blocked, let candidate = candidates.first else {
            return []
        }

        return candidate.stages.map { stage in
            CompiledStep(
                id: "compiled-step-\(stage.id)",
                intentID: intentID,
                sourceCandidateID: candidate.id,
                sourceStageID: stage.id,
                title: stage.title,
                summary: stage.summary,
                orderIndex: stage.orderIndex,
                stepType: stepType(for: stage.kind),
                pace: pace(for: stage.kind, posture: candidate.posture),
                evidenceHint: stage.readinessHints.first ?? stage.prerequisiteHints.first,
                contextRequirements: stage.prerequisiteHints,
                isOptional: candidate.safeForStarterPlanning == false,
                isRepeatable: stage.kind == .reviewFinish,
                isExecutable: candidate.posture != .blocked,
                blockingReasonIDs: candidate.blockingReasons.map(\.id),
                assumptionIDs: candidate.assumptions.map(\.id),
                clarificationQuestionIDs: compiledQuestions(for: compiledStatus).map(\.id)
            )
        }
    }

    var compiledStatus: GoalIntentDayCompilerStatus {
        statusForGoalIntentCompiler
    }

    var statusForGoalIntentCompiler: GoalIntentDayCompilerStatus {
        guard safeForStarterPlanning else {
            return .blocked
        }
        if overallPosture == .blocked {
            return .blocked
        }
        if overallPosture == .provisional || uncertainty.ambiguityActive {
            return .ambiguous
        }
        return .clear
    }

    var compiledBlockedReasons: [GoalIntentBlockedReason] {
        let candidate = candidates.first
        let reasons = candidate?.blockingReasons ?? []
        if reasons.isEmpty, statusForGoalIntentCompiler == .blocked {
            return [
                GoalIntentBlockedReason(
                    id: "blocked-\(sourceUnderstandingSchemaVersion)",
                    kind: .blockedPath,
                    summary: "The compiled path is blocked until more source truth is available.",
                    severity: .blocking
                )
            ]
        }

        return reasons.map {
            GoalIntentBlockedReason(
                id: $0.id,
                kind: $0.field == nil ? .other : .missingContext,
                summary: $0.summary,
                field: $0.field,
                severity: .blocking
            )
        }
    }

    func compiledQuestions(for status: GoalIntentDayCompilerStatus) -> [GoalIntentClarificationQuestion] {
        let missingFields = uncertainty.missingContextFields
        if missingFields.isEmpty == false {
            return missingFields.enumerated().map { index, field in
                GoalIntentClarificationQuestion(
                    id: "question-\(field.rawValue)-\(index)",
                    prompt: "Clarify \(field.displayName).",
                    rationale: "The compiled path still carries this missing field.",
                    targetField: field,
                    severity: status == .blocked ? .blocking : .important,
                    blocking: status == .blocked,
                    skipSafeDefault: "Keep the conservative interpretation."
                )
            }
        }

        guard status == .ambiguous || uncertainty.alternateInterpretationsActive else {
            return []
        }

        return [
            GoalIntentClarificationQuestion(
                id: "question-ambiguity-\(sourceUnderstandingSchemaVersion)",
                prompt: "Clarify which interpretation should drive today.",
                rationale: "The compiled path still has active ambiguity.",
                severity: .important,
                blocking: false,
                skipSafeDefault: "Use the conservative primary interpretation."
            )
        ]
    }

    func compiledMissingFields(for status: GoalIntentDayCompilerStatus) -> [GoalIntentMissingField] {
        let missingFields = uncertainty.missingContextFields
        guard missingFields.isEmpty == false else {
            return status == .blocked ? [
                GoalIntentMissingField(
                    id: "missing-\(sourceUnderstandingSchemaVersion)",
                    reason: "Compilation is blocked until more source truth is available.",
                    blocksCompilation: true
                )
            ] : []
        }

        return missingFields.map { field in
            GoalIntentMissingField(
                id: "missing-\(field.rawValue)",
                field: field,
                reason: "The compiled path still needs \(field.displayName).",
                blocksCompilation: status == .blocked
            )
        }
    }

    func compiledReadiness(for status: GoalIntentDayCompilerStatus) -> PlanningReadiness {
        switch status {
        case .clear:
            return .readyForPlanning
        case .ambiguous:
            return .canPlanWithDefaults
        case .blocked:
            return .needsClarification
        }
    }

    func stepType(for stageKind: GoalCompiledPathStageKind) -> StepType {
        switch stageKind {
        case .setup, .readiness, .firstProof, .advancement:
            return .actionUnit
        case .reviewFinish:
            return .reflectionPrompt
        }
    }

    func pace(
        for stageKind: GoalCompiledPathStageKind,
        posture: GoalPathCompilePosture
    ) -> PlanningPace {
        switch stageKind {
        case .setup, .readiness, .advancement:
            return .untimed
        case .firstProof:
            return posture == .stronger ? .targeted : .untimed
        case .reviewFinish:
            return .ongoing
        }
    }
}

extension PlanStep {
    var compiledStep: CompiledStep {
        CompiledStep(
            id: id,
            intentID: "plan-step-\(id)",
            title: title,
            summary: summary,
            orderIndex: 0,
            stepType: type,
            pace: pace,
            targetDate: targetDate,
            repeatEveryDays: repeatEveryDays,
            evidenceHint: evidenceHint,
            contextRequirements: contextRequirements,
            isOptional: isOptional,
            isRepeatable: isRepeatable,
            isExecutable: true
        )
    }
}

extension Step {
    var compiledStep: CompiledStep {
        CompiledStep(
            id: id,
            intentID: "step-\(id)",
            sourceStageID: sectionID,
            title: title,
            summary: summary,
            orderIndex: 0,
            stepType: type,
            pace: PlanningPace(goalTempo: timing.tempo),
            targetDate: timing.dueAt ?? timing.targetBy ?? timing.suggestedNextAt,
            repeatEveryDays: timing.repeatEveryDays,
            evidenceHint: actionability.completionDefinition,
            contextRequirements: actionability.contextRequirements,
            isOptional: isOptional,
            isRepeatable: isRepeatable,
            isExecutable: state != .blocked && state != .cancelled
        )
    }
}
