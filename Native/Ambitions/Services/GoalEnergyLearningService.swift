import Foundation

protocol GoalEnergyLearning: Sendable {
    func planningSummary(
        for step: Step,
        goal: Goal,
        evidence: [ProgressEvidence],
        feedback: [GoalFeedbackEvent],
        canonicalEnergyModel: GoalEnergyModel?,
        energyFit: PlanningEnergyFitSummary?,
        now: Date
    ) -> PlanningEnergyLearningSummary
}

struct DefaultGoalEnergyLearningService: GoalEnergyLearning {
    func planningSummary(
        for step: Step,
        goal: Goal,
        evidence: [ProgressEvidence],
        feedback: [GoalFeedbackEvent],
        canonicalEnergyModel: GoalEnergyModel?,
        energyFit: PlanningEnergyFitSummary?,
        now: Date
    ) -> PlanningEnergyLearningSummary {
        _ = now
        guard let canonicalEnergyModel,
              canonicalEvaluation(for: step, canonicalEnergyModel: canonicalEnergyModel) != nil,
              energyFit?.source == .canonicalMetadata else {
            return neutralSummary(
                reason: .missingCanonicalEnergyModel,
                evidenceCount: 0,
                frictionCount: 0,
                summary: "Canonical energy metadata is unavailable, so learning stays neutral."
            )
        }

        let exactSignals = signals(
            for: step.id,
            goalID: goal.id,
            evidence: evidence,
            feedback: feedback
        )
        if exactSignals.explicitSignalCount >= 3 {
            return summary(
                from: exactSignals,
                baseReason: exactSignals.frictionCount == 0 ? .sameStepPositiveHistory : .sameStepFrictionHistory
            )
        }

        let safeFallbackStepIDs = safeFallbackStepIDs(for: step, goal: goal)
        guard safeFallbackStepIDs.isEmpty == false else {
            return neutralSummary(
                reason: exactSignals.explicitSignalCount > 0 ? .insufficientSignals : .noSafeSameGoalMatch,
                evidenceCount: exactSignals.evidenceCount,
                frictionCount: exactSignals.frictionCount,
                summary: "Observed history is too thin to claim a same-goal energy tendency yet."
            )
        }

        let fallbackSignals = signals(
            forAnyOf: safeFallbackStepIDs,
            goalID: goal.id,
            evidence: evidence,
            feedback: feedback
        )
        guard fallbackSignals.explicitSignalCount >= 3 else {
            return neutralSummary(
                reason: .insufficientSignals,
                evidenceCount: exactSignals.evidenceCount + fallbackSignals.evidenceCount,
                frictionCount: exactSignals.frictionCount + fallbackSignals.frictionCount,
                summary: "Observed history is still limited, so energy learning stays neutral."
            )
        }

        return summary(from: fallbackSignals, baseReason: .sameGoalSameTypeFallback)
    }
}

private extension DefaultGoalEnergyLearningService {
    struct SignalBundle {
        let positiveReferences: [GoalEnergyLearningEvidenceReference]
        let frictionReferences: [GoalEnergyLearningEvidenceReference]
        let minimumVersionCount: Int
        let lowEffortCompletionCount: Int
        let highEffortCompletionCount: Int
        let oversizedFrictionCount: Int

        var evidenceCount: Int { positiveReferences.count }
        var frictionCount: Int { frictionReferences.count }
        var explicitSignalCount: Int { evidenceCount + frictionCount }
    }

    func summary(from signals: SignalBundle, baseReason: GoalEnergyLearningReasonCode) -> PlanningEnergyLearningSummary {
        if signals.evidenceCount > 0 && signals.frictionCount > 0 {
            return neutralSummary(
                reason: .conflictingHistory,
                evidenceCount: signals.evidenceCount,
                frictionCount: signals.frictionCount,
                summary: "Observed energy history is mixed, so learning stays neutral."
            )
        }

        if signals.evidenceCount >= 3 {
            var reasonCodes: [GoalEnergyLearningReasonCode] = [baseReason]
            var adjustment = 0.04
            if signals.minimumVersionCount > 0 || signals.lowEffortCompletionCount > 0 {
                adjustment += 0.02
                reasonCodes.append(.lowEffortSupport)
            }
            return PlanningEnergyLearningSummary(
                schemaVersion: goalEnergyLearningSchemaVersion,
                rankingAdjustment: rounded(min(adjustment, 0.08)),
                confidence: .high,
                tendencyCodes: [.supportsLightExecution],
                reasonCodes: reasonCodes.sorted(by: codeOrdering),
                evidenceCount: signals.evidenceCount,
                frictionCount: signals.frictionCount,
                summary: "Observed same-goal execution history supports a lighter sustainable move."
            )
        }

        if signals.frictionCount >= 3 {
            var reasonCodes: [GoalEnergyLearningReasonCode] = [baseReason]
            var adjustment = -0.04
            if signals.oversizedFrictionCount > 0 || signals.highEffortCompletionCount > 0 {
                adjustment -= 0.02
                reasonCodes.append(.oversizedOrHighEffortStrain)
            }
            return PlanningEnergyLearningSummary(
                schemaVersion: goalEnergyLearningSchemaVersion,
                rankingAdjustment: rounded(max(adjustment, -0.08)),
                confidence: .high,
                tendencyCodes: [.strainsHighEffort],
                reasonCodes: reasonCodes.sorted(by: codeOrdering),
                evidenceCount: signals.evidenceCount,
                frictionCount: signals.frictionCount,
                summary: "Observed same-goal friction suggests this move strains execution more than it supports it."
            )
        }

        return neutralSummary(
            reason: .conflictingHistory,
            evidenceCount: signals.evidenceCount,
            frictionCount: signals.frictionCount,
            summary: "Observed history is ambiguous, so energy learning stays neutral."
        )
    }

    func neutralSummary(
        reason: GoalEnergyLearningReasonCode,
        evidenceCount: Int,
        frictionCount: Int,
        summary: String
    ) -> PlanningEnergyLearningSummary {
        PlanningEnergyLearningSummary(
            schemaVersion: goalEnergyLearningSchemaVersion,
            rankingAdjustment: 0,
            confidence: .low,
            tendencyCodes: [.mixedOrInsufficientHistory],
            reasonCodes: [reason],
            evidenceCount: evidenceCount,
            frictionCount: frictionCount,
            summary: summary
        )
    }

    func signals(
        for stepID: String,
        goalID: String,
        evidence: [ProgressEvidence],
        feedback: [GoalFeedbackEvent]
    ) -> SignalBundle {
        signals(
            forAnyOf: [stepID],
            goalID: goalID,
            evidence: evidence,
            feedback: feedback
        )
    }

    func signals(
        forAnyOf stepIDs: Set<String>,
        goalID: String,
        evidence: [ProgressEvidence],
        feedback: [GoalFeedbackEvent]
    ) -> SignalBundle {
        let positiveEvidence = evidence
            .filter { $0.goalID == goalID && ($0.stepID.map(stepIDs.contains) ?? false) }
            .compactMap { item -> GoalEnergyLearningEvidenceReference? in
                switch item.evidenceKind {
                case .stepCompleted:
                    return GoalEnergyLearningEvidenceReference(id: item.id, goalID: item.goalID, stepID: item.stepID, occurredAt: item.capturedAt, kind: .positiveCompletion)
                case .ritualCompletion:
                    return GoalEnergyLearningEvidenceReference(id: item.id, goalID: item.goalID, stepID: item.stepID, occurredAt: item.capturedAt, kind: .positiveCompletion)
                case .ritualMinimumVersion:
                    return GoalEnergyLearningEvidenceReference(id: item.id, goalID: item.goalID, stepID: item.stepID, occurredAt: item.capturedAt, kind: .minimumVersionCompletion)
                case .ritualQuickLog, .sessionLogged, .reflectionLogged, .delegatedUpdate, .observationLogged, .milestoneReached:
                    return nil
                }
            }
            .sorted(by: referenceOrdering)

        let relatedFeedback = feedback
            .filter { stepIDs.contains($0.stepID) }
            .sorted { $0.base.id < $1.base.id }

        let lowEffortCompletionCount = relatedFeedback.reduce(into: 0) { count, event in
            if case let .completed(_, _, effortLevel, _) = event, effortLevel == .low {
                count += 1
            }
        }
        let highEffortCompletionCount = relatedFeedback.reduce(into: 0) { count, event in
            if case let .completed(_, _, effortLevel, _) = event, effortLevel == .high {
                count += 1
            }
        }

        let frictionReferences = relatedFeedback.compactMap { event -> GoalEnergyLearningEvidenceReference? in
            switch event {
            case let .skipped(base, _):
                return GoalEnergyLearningEvidenceReference(id: base.id, goalID: goalID, stepID: base.stepID, occurredAt: base.occurredAt, kind: .skipFriction)
            case let .delayed(base, _, _):
                return GoalEnergyLearningEvidenceReference(id: base.id, goalID: goalID, stepID: base.stepID, occurredAt: base.occurredAt, kind: .delayFriction)
            case let .confused(base, _):
                return GoalEnergyLearningEvidenceReference(id: base.id, goalID: goalID, stepID: base.stepID, occurredAt: base.occurredAt, kind: .confusionFriction)
            case let .tooBig(base), let .askedForSmallerVersion(base):
                return GoalEnergyLearningEvidenceReference(id: base.id, goalID: goalID, stepID: base.stepID, occurredAt: base.occurredAt, kind: .oversizedFriction)
            case let .notRelevant(base):
                return GoalEnergyLearningEvidenceReference(id: base.id, goalID: goalID, stepID: base.stepID, occurredAt: base.occurredAt, kind: .notRelevantFriction)
            case .completed, .edited, .tooEasy, .askedWhyThisMatters:
                return nil
            }
        }
        .sorted(by: referenceOrdering)

        return SignalBundle(
            positiveReferences: positiveEvidence,
            frictionReferences: frictionReferences,
            minimumVersionCount: positiveEvidence.filter { $0.kind == .minimumVersionCompletion }.count,
            lowEffortCompletionCount: lowEffortCompletionCount,
            highEffortCompletionCount: highEffortCompletionCount,
            oversizedFrictionCount: frictionReferences.filter { $0.kind == .oversizedFriction }.count
        )
    }

    func safeFallbackStepIDs(for step: Step, goal: Goal) -> Set<String> {
        let matching = goal.plan?.sections
            .flatMap(\.steps)
            .filter { $0.id != step.id && $0.type == step.type }
            .map(\.id) ?? []
        return Set(matching)
    }

    func canonicalEvaluation(for step: Step, canonicalEnergyModel: GoalEnergyModel) -> GoalEnergyFitEvaluation? {
        canonicalEnergyModel.evaluations.first { $0.stepID == step.id || ($0.targetKind == .planStep && $0.targetID == step.id) }
    }

    func rounded(_ value: Double) -> Double {
        (value * 100).rounded() / 100
    }

    func codeOrdering(lhs: GoalEnergyLearningReasonCode, rhs: GoalEnergyLearningReasonCode) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    func referenceOrdering(lhs: GoalEnergyLearningEvidenceReference, rhs: GoalEnergyLearningEvidenceReference) -> Bool {
        if lhs.occurredAt == rhs.occurredAt { return lhs.id < rhs.id }
        return lhs.occurredAt < rhs.occurredAt
    }
}
