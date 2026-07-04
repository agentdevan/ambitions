import Foundation

protocol GoalEnergyFitEvaluating: Sendable {
    func evaluate(
        compiledPath: GoalCompiledPath,
        plannedSteps: [Step],
        capacityContext: EnergyCapacityContext
    ) -> GoalEnergyModel

    func planningSummary(
        for step: Step,
        goal: Goal,
        evaluation: PlanningEvaluation?,
        canonicalEnergyModel: GoalEnergyModel?
    ) -> PlanningEnergyFitSummary
}

extension GoalEnergyFitEvaluating {
    func evaluate(
        compiledPath: GoalCompiledPath,
        capacityContext: EnergyCapacityContext
    ) -> GoalEnergyModel {
        evaluate(
            compiledPath: compiledPath,
            plannedSteps: [],
            capacityContext: capacityContext
        )
    }
}

struct DefaultGoalEnergyFitService: GoalEnergyFitEvaluating {
    func evaluate(
        compiledPath: GoalCompiledPath,
        plannedSteps: [Step],
        capacityContext: EnergyCapacityContext = .assumedNeutral()
    ) -> GoalEnergyModel {
        let candidateEvaluations = compiledPath.candidates
            .sorted(by: candidateOrdering)
            .map { candidateEvaluation(for: $0, capacityContext: capacityContext) }

        let stageEvaluations = compiledPath.candidates
            .sorted(by: candidateOrdering)
            .flatMap { candidate in
                candidate.stages
                    .sorted { $0.orderIndex == $1.orderIndex ? $0.id < $1.id : $0.orderIndex < $1.orderIndex }
                    .map { stageEvaluation(for: $0, candidate: candidate, capacityContext: capacityContext) }
            }

        let stepEvaluations = plannedSteps
            .sorted { $0.id < $1.id }
            .map { stepEvaluation(for: $0, goal: nil, evaluation: nil, capacityContext: capacityContext) }

        let evaluations = (candidateEvaluations + stageEvaluations + stepEvaluations)
            .sorted { $0.id < $1.id }
        let candidateSummaries = compiledPath.candidates
            .sorted(by: candidateOrdering)
            .map { candidate in
                let related = evaluations
                    .filter { $0.candidateID == candidate.id }
                    .sorted { $0.id < $1.id }
                let score = averageScore(related)
                return GoalEnergyCandidateSummary(
                    candidateID: candidate.id,
                    fitBand: fitBand(for: score),
                    score: score,
                    evaluationIDs: related.map(\.id)
                )
            }

        return GoalEnergyModel(
            schemaVersion: goalEnergyFitSchemaVersion,
            sourceCompiledPathSchemaVersion: compiledPath.schemaVersion,
            capacityContext: capacityContext,
            overallBand: fitBand(for: averageScore(evaluations)),
            candidateSummaries: candidateSummaries,
            evaluations: evaluations,
            audit: GoalEnergyModelAuditMetadata(
                entries: evaluations.map { evaluation in
                    GoalEnergyModelAuditEntry(
                        id: "audit-\(evaluation.id)",
                        targetKind: evaluation.targetKind,
                        targetID: evaluation.targetID,
                        reasonCodes: evaluation.reasons.map(\.code).stableUniqueSorted()
                    )
                }
                .sorted { $0.id < $1.id }
            )
        )
    }

    func planningSummary(
        for step: Step,
        goal: Goal,
        evaluation: PlanningEvaluation?,
        canonicalEnergyModel: GoalEnergyModel?
    ) -> PlanningEnergyFitSummary {
        if let canonicalEvaluation = canonicalEnergyModel?.evaluations
            .sorted(by: evaluationOrdering)
            .first(where: { $0.stepID == step.id || ($0.targetKind == .planStep && $0.targetID == step.id) }) {
            return PlanningEnergyFitSummary(
                source: .canonicalMetadata,
                fitBand: canonicalEvaluation.fitBand,
                score: canonicalEvaluation.score,
                reasonCodes: canonicalEvaluation.reasons.map(\.code).stableUniqueSorted()
            )
        }

        let fallback = stepEvaluation(
            for: step,
            goal: goal,
            evaluation: evaluation,
            capacityContext: .assumedNeutral()
        )
        return PlanningEnergyFitSummary(
            source: .serviceFallback,
            fitBand: fallback.fitBand,
            score: fallback.score,
            reasonCodes: fallback.reasons.map(\.code).stableUniqueSorted()
        )
    }
}

private extension Array where Element == GoalEnergyFitReasonCode {
    func stableUniqueSorted() -> [GoalEnergyFitReasonCode] {
        Array(Set(self)).sorted { $0.rawValue < $1.rawValue }
    }
}

private extension DefaultGoalEnergyFitService {
    func candidateEvaluation(
        for candidate: GoalCompiledPathCandidate,
        capacityContext: EnergyCapacityContext
    ) -> GoalEnergyFitEvaluation {
        var score = 0.70
        var reasons = baseReasons(
            targetKind: .pathCandidate,
            targetID: candidate.id,
            relatedStageKind: nil,
            relatedStepType: nil,
            capacityContext: capacityContext
        )

        if candidate.posture == .blocked {
            score -= 0.22
            reasons.append(reason(.candidateBlocked, targetKind: .pathCandidate, targetID: candidate.id, impact: .negative))
        } else if candidate.posture == .provisional {
            score -= 0.06
            reasons.append(reason(.provisionalPath, targetKind: .pathCandidate, targetID: candidate.id, impact: .neutral))
        }

        let bounded = clamped(score)
        return GoalEnergyFitEvaluation(
            id: "energy-\(candidate.id)",
            targetKind: .pathCandidate,
            targetID: candidate.id,
            candidateID: candidate.id,
            stageID: nil,
            stepID: nil,
            workShape: .planning,
            effortDemand: .moderate,
            focusDemand: .moderate,
            recoveryCompatibility: candidate.posture == .blocked ? .strained : .neutral,
            pacingPosture: capacityContext.pacingPosture,
            fitBand: fitBand(for: bounded),
            score: bounded,
            reasons: reasons.sorted(by: reasonOrdering)
        )
    }

    func stageEvaluation(
        for stage: GoalCompiledPathStage,
        candidate: GoalCompiledPathCandidate,
        capacityContext: EnergyCapacityContext
    ) -> GoalEnergyFitEvaluation {
        let demand = stageDemand(for: stage.kind)
        var score = demand.baseScore
        var reasons = baseReasons(
            targetKind: .pathStage,
            targetID: stage.id,
            relatedStageKind: stage.kind,
            relatedStepType: nil,
            capacityContext: capacityContext
        )
        reasons.append(reason(.stageProgression, targetKind: .pathStage, targetID: stage.id, relatedStageKind: stage.kind, impact: .neutral))

        if demand.focusDemand == .high {
            score -= 0.08
            reasons.append(reason(.highFocusDemand, targetKind: .pathStage, targetID: stage.id, relatedStageKind: stage.kind, impact: .negative))
        }
        if candidate.posture == .blocked {
            score -= 0.16
            reasons.append(reason(.candidateBlocked, targetKind: .pathStage, targetID: stage.id, relatedStageKind: stage.kind, impact: .negative))
        }

        let bounded = clamped(score)
        return GoalEnergyFitEvaluation(
            id: "energy-\(candidate.id)-\(stage.id)",
            targetKind: .pathStage,
            targetID: stage.id,
            candidateID: candidate.id,
            stageID: stage.id,
            stepID: nil,
            workShape: demand.workShape,
            effortDemand: demand.effortDemand,
            focusDemand: demand.focusDemand,
            recoveryCompatibility: demand.recoveryCompatibility,
            pacingPosture: capacityContext.pacingPosture,
            fitBand: fitBand(for: bounded),
            score: bounded,
            reasons: reasons.sorted(by: reasonOrdering)
        )
    }

    func stepEvaluation(
        for step: Step,
        goal: Goal?,
        evaluation: PlanningEvaluation?,
        capacityContext: EnergyCapacityContext
    ) -> GoalEnergyFitEvaluation {
        let demand = stepDemand(for: step, goal: goal, evaluation: evaluation)
        var score = demand.baseScore
        var reasons = baseReasons(
            targetKind: .planStep,
            targetID: step.id,
            relatedStageKind: nil,
            relatedStepType: step.type,
            capacityContext: capacityContext
        )

        if goal?.mode == .recovery {
            score += 0.12
            reasons.append(reason(.recoveryCompatible, targetKind: .planStep, targetID: step.id, relatedStepType: step.type, impact: .positive))
        }
        if [.observationPrompt, .reflectionPrompt, .recurringRoutine].contains(step.type) {
            score += 0.08
            reasons.append(reason(.lowFrictionStep, targetKind: .planStep, targetID: step.id, relatedStepType: step.type, impact: .positive))
        }
        if step.state == .blocked {
            score -= 0.22
            reasons.append(reason(.blockedDependency, targetKind: .planStep, targetID: step.id, relatedStepType: step.type, impact: .negative))
        }
        if step.dependencyStepIDs.isEmpty == false || step.actionability.contextRequirements.isEmpty == false {
            score -= 0.12
            reasons.append(reason(.dependencyLoad, targetKind: .planStep, targetID: step.id, relatedStepType: step.type, impact: .negative))
        }
        if evaluation?.effortPosture == .push {
            score -= 0.10
            reasons.append(reason(.deadlinePressure, targetKind: .planStep, targetID: step.id, relatedStepType: step.type, impact: .negative))
        } else if evaluation?.effortPosture == .gentle {
            score += 0.06
            reasons.append(reason(.sustainablePacing, targetKind: .planStep, targetID: step.id, relatedStepType: step.type, impact: .positive))
        }

        let bounded = clamped(score)
        return GoalEnergyFitEvaluation(
            id: "energy-step-\(step.id)",
            targetKind: .planStep,
            targetID: step.id,
            candidateID: nil,
            stageID: nil,
            stepID: step.id,
            workShape: demand.workShape,
            effortDemand: demand.effortDemand,
            focusDemand: demand.focusDemand,
            recoveryCompatibility: demand.recoveryCompatibility,
            pacingPosture: evaluation.map { pacingPosture(for: $0.effortPosture) } ?? capacityContext.pacingPosture,
            fitBand: fitBand(for: bounded),
            score: bounded,
            reasons: reasons.sorted(by: reasonOrdering)
        )
    }

    struct DemandShape {
        let workShape: EnergyWorkShape
        let effortDemand: EnergyEffortDemand
        let focusDemand: EnergyFocusDemand
        let recoveryCompatibility: EnergyRecoveryCompatibility
        let baseScore: Double
    }

    func stageDemand(for kind: GoalCompiledPathStageKind) -> DemandShape {
        switch kind {
        case .setup:
            return DemandShape(workShape: .planning, effortDemand: .light, focusDemand: .moderate, recoveryCompatibility: .compatible, baseScore: 0.76)
        case .readiness:
            return DemandShape(workShape: .planning, effortDemand: .moderate, focusDemand: .moderate, recoveryCompatibility: .neutral, baseScore: 0.70)
        case .firstProof:
            return DemandShape(workShape: .execution, effortDemand: .moderate, focusDemand: .moderate, recoveryCompatibility: .neutral, baseScore: 0.68)
        case .advancement:
            return DemandShape(workShape: .deepWork, effortDemand: .high, focusDemand: .high, recoveryCompatibility: .strained, baseScore: 0.60)
        case .reviewFinish:
            return DemandShape(workShape: .review, effortDemand: .light, focusDemand: .light, recoveryCompatibility: .compatible, baseScore: 0.78)
        }
    }

    func stepDemand(for step: Step, goal: Goal?, evaluation: PlanningEvaluation?) -> DemandShape {
        if goal?.mode == .recovery || step.type == .observationPrompt {
            return DemandShape(workShape: .recovery, effortDemand: .light, focusDemand: .light, recoveryCompatibility: .compatible, baseScore: 0.68)
        }
        switch step.type {
        case .observationPrompt, .reflectionPrompt:
            return DemandShape(workShape: .review, effortDemand: .light, focusDemand: .light, recoveryCompatibility: .compatible, baseScore: 0.70)
        case .learningCheckpoint, .explorationExperiment:
            return DemandShape(workShape: .deepWork, effortDemand: .moderate, focusDemand: .high, recoveryCompatibility: .neutral, baseScore: 0.62)
        case .supportAction:
            return DemandShape(workShape: .support, effortDemand: .moderate, focusDemand: .moderate, recoveryCompatibility: .neutral, baseScore: 0.64)
        case .recurringRoutine:
            return DemandShape(workShape: .execution, effortDemand: .light, focusDemand: .light, recoveryCompatibility: .compatible, baseScore: 0.70)
        case .resource:
            return DemandShape(workShape: .planning, effortDemand: .light, focusDemand: .moderate, recoveryCompatibility: .compatible, baseScore: 0.68)
        case .actionUnit:
            let pushPenalty = evaluation?.effortPosture == .push ? -0.04 : 0
            return DemandShape(workShape: .execution, effortDemand: .moderate, focusDemand: .moderate, recoveryCompatibility: .neutral, baseScore: 0.68 + pushPenalty)
        }
    }

    func baseReasons(
        targetKind: GoalEnergyFitTargetKind,
        targetID: String,
        relatedStageKind: GoalCompiledPathStageKind?,
        relatedStepType: StepType?,
        capacityContext: EnergyCapacityContext
    ) -> [GoalEnergyFitReason] {
        let code: GoalEnergyFitReasonCode = capacityContext.source == .unknown ? .structuralUnknown : .assumedNeutralCapacity
        return [
            reason(
                code,
                targetKind: targetKind,
                targetID: targetID,
                relatedStageKind: relatedStageKind,
                relatedStepType: relatedStepType,
                impact: .neutral
            )
        ]
    }

    func reason(
        _ code: GoalEnergyFitReasonCode,
        targetKind: GoalEnergyFitTargetKind,
        targetID: String,
        relatedStageKind: GoalCompiledPathStageKind? = nil,
        relatedStepType: StepType? = nil,
        impact: GoalEnergyFitReasonImpact
    ) -> GoalEnergyFitReason {
        GoalEnergyFitReason(
            code: code,
            targetKind: targetKind,
            targetID: targetID,
            relatedStageKind: relatedStageKind,
            relatedStepType: relatedStepType,
            impact: impact,
            summary: summary(for: code)
        )
    }

    func summary(for code: GoalEnergyFitReasonCode) -> String {
        switch code {
        case .assumedNeutralCapacity:
            return "Energy fit uses an assumed neutral planning context."
        case .canonicalMetadata:
            return "Canonical energy metadata supplied this summary."
        case .structuralUnknown:
            return "No planning-time capacity context is available yet."
        case .candidateBlocked:
            return "Blocked path state increases execution strain."
        case .provisionalPath:
            return "Provisional path state keeps energy fit conservative."
        case .stageProgression:
            return "Compiled path stage shape drives the deterministic fit."
        case .recoveryCompatible:
            return "Recovery-oriented work is compatible with gentler energy."
        case .lowFrictionStep:
            return "The step shape is low-friction."
        case .blockedDependency:
            return "Blocked step state reduces fit."
        case .dependencyLoad:
            return "Dependencies or context requirements increase effort."
        case .deadlinePressure:
            return "Push pacing increases energy strain."
        case .sustainablePacing:
            return "Gentle pacing improves sustainability."
        case .highFocusDemand:
            return "High-focus work requires more capacity."
        }
    }

    func averageScore(_ evaluations: [GoalEnergyFitEvaluation]) -> Double {
        guard evaluations.isEmpty == false else { return 0 }
        let raw = evaluations.map(\.score).reduce(0, +) / Double(evaluations.count)
        return rounded(clamped(raw))
    }

    func clamped(_ value: Double) -> Double {
        rounded(min(max(value, 0), 1))
    }

    func rounded(_ value: Double) -> Double {
        (value * 100).rounded() / 100
    }

    func fitBand(for score: Double) -> EnergyFitBand {
        switch score {
        case ..<0.45:
            return .strained
        case ..<0.65:
            return .constrained
        case ...0.94:
            return .sustainable
        default:
            return .supportive
        }
    }

    func pacingPosture(for effortPosture: PlanningEffortPosture) -> EnergyPacingPosture {
        switch effortPosture {
        case .gentle:
            return .gentle
        case .steady:
            return .steady
        case .push:
            return .push
        }
    }

    func candidateOrdering(lhs: GoalCompiledPathCandidate, rhs: GoalCompiledPathCandidate) -> Bool {
        if lhs.isPrimary != rhs.isPrimary { return lhs.isPrimary && !rhs.isPrimary }
        return lhs.id < rhs.id
    }

    func evaluationOrdering(lhs: GoalEnergyFitEvaluation, rhs: GoalEnergyFitEvaluation) -> Bool {
        lhs.id < rhs.id
    }

    func reasonOrdering(lhs: GoalEnergyFitReason, rhs: GoalEnergyFitReason) -> Bool {
        lhs.code.rawValue < rhs.code.rawValue
    }
}
