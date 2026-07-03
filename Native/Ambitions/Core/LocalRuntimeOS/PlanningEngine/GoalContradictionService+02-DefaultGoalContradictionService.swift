import Foundation

extension DefaultGoalContradictionService {
    func bridgedInputContradictions(from clarification: GoalOrchestrationClarification) -> [GoalContradictionRecord] {
        clarification.contradictions
            .sorted { lhs, rhs in
                if lhs.code.rawValue != rhs.code.rawValue {
                    return lhs.code.rawValue < rhs.code.rawValue
                }
                return lhs.question.id < rhs.question.id
            }
            .map { contradiction in
                GoalContradictionRecord(
                    id: "contradiction-\(contradiction.code.rawValue)-\(contradiction.question.id)",
                    code: contradictionCode(for: contradiction.code),
                    category: .goalInput,
                    severity: .blocking,
                    confidence: .high,
                    summary: contradiction.reason,
                    candidateID: nil,
                    stageID: nil,
                    artifactRefs: [
                        GoalContradictionArtifactRef(
                            kind: .inputContradiction,
                            id: contradiction.code.rawValue,
                            candidateID: nil,
                            stageID: nil
                        ),
                        GoalContradictionArtifactRef(
                            kind: .clarificationQuestion,
                            id: contradiction.question.id,
                            candidateID: nil,
                            stageID: nil
                        )
                    ]
                )
            }
    }


    func requirementContradictions(
        candidate: GoalCompiledPathCandidate,
        resources: [GoalResourceEntity],
        knowledgeClaimsByID: [String: KnowledgeClaim],
        knowledgeSourcesByID: [String: KnowledgeSourceRecord],
        providerStatusesByID: [String: KnowledgeProviderStatus]
    ) -> [GoalContradictionRecord] {
        let blockingRequirements = candidate.requirementHints
            .filter(\.blocking)
            .sorted { $0.id < $1.id }

        guard blockingRequirements.isEmpty == false else {
            return []
        }

        var records: [GoalContradictionRecord] = []

        for requirement in blockingRequirements {
            let relatedResources = resources.filter { resource in
                resource.targetStageID == requirement.relatedStageID || requirement.relatedStageID == nil
            }
            guard relatedResources.isEmpty == false else { continue }

            for resource in relatedResources {
                if resource.missingResourceState != .none {
                    records.append(
                        makeRecord(
                            id: "contradiction-required-resource-missing-\(requirement.id)-\(resource.id)",
                            code: .requiredResourceMissingSupport,
                            category: .knowledgeRequirement,
                            severity: .blocking,
                            confidence: .high,
                            summary: "A blocking requirement is missing required support.",
                            candidateID: candidate.id,
                            stageID: requirement.relatedStageID,
                            artifactRefs: [
                                .init(kind: .compiledPathRequirement, id: requirement.id, candidateID: candidate.id, stageID: requirement.relatedStageID),
                                .init(kind: .resource, id: resource.id, candidateID: candidate.id, stageID: resource.targetStageID)
                            ]
                        )
                    )
                }

                if providerUnavailable(
                    resource: resource,
                    knowledgeClaimsByID: knowledgeClaimsByID,
                    knowledgeSourcesByID: knowledgeSourcesByID,
                    providerStatusesByID: providerStatusesByID
                ) {
                    records.append(
                        makeRecord(
                            id: "contradiction-required-resource-provider-\(requirement.id)-\(resource.id)",
                            code: .requiredResourceProviderUnavailable,
                            category: .knowledgeRequirement,
                            severity: .blocking,
                            confidence: .high,
                            summary: "A blocking requirement depends on provider support that is unavailable.",
                            candidateID: candidate.id,
                            stageID: requirement.relatedStageID,
                            artifactRefs: resource.providerArtifactRefs(
                                requirementID: requirement.id,
                                candidateID: candidate.id,
                                stageID: requirement.relatedStageID,
                                knowledgeClaimsByID: knowledgeClaimsByID,
                                knowledgeSourcesByID: knowledgeSourcesByID,
                                providerStatusesByID: providerStatusesByID
                            )
                        )
                    )
                }

                if staleSupportContradicts(resource: resource) {
                    records.append(
                        makeRecord(
                            id: "contradiction-required-resource-stale-\(requirement.id)-\(resource.id)",
                            code: .requiredResourceStaleSupport,
                            category: .knowledgeRequirement,
                            severity: .important,
                            confidence: .medium,
                            summary: "A blocking requirement depends on stale or expired support.",
                            candidateID: candidate.id,
                            stageID: requirement.relatedStageID,
                            artifactRefs: [
                                .init(kind: .compiledPathRequirement, id: requirement.id, candidateID: candidate.id, stageID: requirement.relatedStageID),
                                .init(kind: .resource, id: resource.id, candidateID: candidate.id, stageID: resource.targetStageID)
                            ]
                        )
                    )
                }

                if hasConflictingClaim(resource: resource, knowledgeClaimsByID: knowledgeClaimsByID) {
                    let claimRefs = resource.claimIDs.sorted().map {
                        GoalContradictionArtifactRef(kind: .knowledgeClaim, id: $0, candidateID: candidate.id, stageID: requirement.relatedStageID)
                    }
                    records.append(
                        makeRecord(
                            id: "contradiction-required-knowledge-conflict-\(requirement.id)-\(resource.id)",
                            code: .requiredKnowledgeClaimConflict,
                            category: .knowledgeRequirement,
                            severity: .important,
                            confidence: .medium,
                            summary: "A blocking requirement is supported by conflicting knowledge claims.",
                            candidateID: candidate.id,
                            stageID: requirement.relatedStageID,
                            artifactRefs: [
                                .init(kind: .compiledPathRequirement, id: requirement.id, candidateID: candidate.id, stageID: requirement.relatedStageID),
                                .init(kind: .resource, id: resource.id, candidateID: candidate.id, stageID: resource.targetStageID)
                            ] + claimRefs
                        )
                    )
                }
            }
        }

        return records
    }


    func readinessContradictions(
        candidate: GoalCompiledPathCandidate,
        resources: [GoalResourceEntity]
    ) -> [GoalContradictionRecord] {
        candidate.readinessCriteria
            .filter(\.blocking)
            .sorted { $0.id < $1.id }
            .compactMap { criterion in
                let relatedResources = resources.filter { resource in
                    resource.targetStageID == criterion.targetStageID
                }
                guard relatedResources.contains(where: { $0.missingResourceState != .none }) else {
                    return nil
                }
                return makeRecord(
                    id: "contradiction-blocking-readiness-\(criterion.id)",
                    code: .blockingReadinessMissingSupport,
                    category: .knowledgeRequirement,
                    severity: .blocking,
                    confidence: .high,
                    summary: "A blocking readiness criterion is missing required support.",
                    candidateID: candidate.id,
                    stageID: criterion.targetStageID,
                    artifactRefs: [
                        .init(kind: .compiledPathReadinessCriterion, id: criterion.id, candidateID: candidate.id, stageID: criterion.targetStageID)
                    ] + relatedResources
                        .filter { $0.missingResourceState != .none }
                        .map {
                            GoalContradictionArtifactRef(kind: .resource, id: $0.id, candidateID: candidate.id, stageID: $0.targetStageID)
                        }
                )
            }
    }


    func assumptionContradictions(
        candidate: GoalCompiledPathCandidate
    ) -> [GoalContradictionRecord] {
        let safeAssumptions = candidate.assumptions
            .filter(\.safeForCompilation)
            .sorted { $0.id < $1.id }
        let blockingRequirements = candidate.requirementHints
            .filter(\.blocking)
            .sorted { $0.id < $1.id }

        guard safeAssumptions.isEmpty == false else {
            return []
        }

        return safeAssumptions.compactMap { assumption in
            guard let requirement = blockingRequirements.first(where: { $0.relatedField == assumption.relatedField }) else {
                return nil
            }

            return makeRecord(
                id: "contradiction-assumption-requirement-\(assumption.id)-\(requirement.id)",
                code: .starterAssumptionVsBlockingRequirement,
                category: .assumptionRequirement,
                severity: .important,
                confidence: .medium,
                summary: "A starter-safe assumption conflicts with a blocking requirement on the same path.",
                candidateID: candidate.id,
                stageID: requirement.relatedStageID,
                artifactRefs: [
                    .init(kind: .compiledPathAssumption, id: assumption.id, candidateID: candidate.id, stageID: requirement.relatedStageID),
                    .init(kind: .compiledPathRequirement, id: requirement.id, candidateID: candidate.id, stageID: requirement.relatedStageID)
                ]
            )
        }
    }


    func behaviorContradictions(
        plannedStepsByID: [String: Step],
        evidenceByStepID: [String: [ProgressEvidence]],
        feedbackByStepID: [String: [GoalFeedbackEvent]]
    ) -> [GoalContradictionRecord] {
        plannedStepsByID.values
            .sorted { $0.id < $1.id }
            .flatMap { step -> [GoalContradictionRecord] in
                var records: [GoalContradictionRecord] = []
                let positiveEvidence = supportingCompletionEvidence(for: step.id, evidenceByStepID: evidenceByStepID)
                let notRelevantFeedback = notRelevantFeedback(for: step.id, feedbackByStepID: feedbackByStepID)

                if step.state == .blocked,
                   positiveEvidence.count >= 3 {
                    records.append(
                        makeRecord(
                            id: "contradiction-blocked-step-evidence-\(step.id)",
                            code: .blockedStepHasCompletionEvidence,
                            category: .observedBehavior,
                            severity: .important,
                            confidence: .high,
                            summary: "The current step is blocked even though strong completion evidence exists for that same step.",
                            candidateID: nil,
                            stageID: nil,
                            artifactRefs: [
                                .init(kind: .planStep, id: step.id, candidateID: nil, stageID: nil)
                            ] + positiveEvidence.map {
                                GoalContradictionArtifactRef(kind: .progressEvidence, id: $0.id, candidateID: nil, stageID: nil)
                            }
                        )
                    )
                }

                if step.state == .planned,
                   notRelevantFeedback.count >= 3 {
                    records.append(
                        makeRecord(
                            id: "contradiction-planned-step-not-relevant-\(step.id)",
                            code: .plannedStepMarkedNotRelevant,
                            category: .observedBehavior,
                            severity: .important,
                            confidence: .high,
                            summary: "The current planned step has repeated same-step feedback saying it is not relevant.",
                            candidateID: nil,
                            stageID: nil,
                            artifactRefs: [
                                .init(kind: .planStep, id: step.id, candidateID: nil, stageID: nil)
                            ] + notRelevantFeedback.map {
                                GoalContradictionArtifactRef(kind: .feedbackEvent, id: $0.base.id, candidateID: nil, stageID: nil)
                            }
                        )
                    )
                }

                return records
            }
    }
}
