import Foundation

struct GoalContradictionAnalysisInput: Sendable, Equatable {
    let classification: ClassificationResult
    let clarification: GoalOrchestrationClarification
    let understanding: GoalUnderstanding
    let compiledPath: GoalCompiledPath
    let resourceGraph: GoalResourceGraph
    let energyModel: GoalEnergyModel
    let knowledgeContext: GoalUnderstandingKnowledgeContext?
    let plannedSteps: [Step]
    let evidence: [ProgressEvidence]
    let feedback: [GoalFeedbackEvent]
}

protocol GoalContradictionAnalyzing: Sendable {
    func analyze(input: GoalContradictionAnalysisInput) -> GoalContradictionReport
}

struct DefaultGoalContradictionService: GoalContradictionAnalyzing {
    func analyze(input: GoalContradictionAnalysisInput) -> GoalContradictionReport {
        let knowledgeClaimsByID = Dictionary(uniqueKeysWithValues: (input.knowledgeContext?.claims ?? []).map { ($0.id, $0) })
        let knowledgeSourcesByID = Dictionary(uniqueKeysWithValues: (input.knowledgeContext?.sources ?? []).map { ($0.id, $0) })
        let providerStatusesByID = Dictionary(uniqueKeysWithValues: (input.knowledgeContext?.providerStatuses ?? []).map { ($0.provider.id, $0) })
        let plannedStepsByID = Dictionary(uniqueKeysWithValues: input.plannedSteps.map { ($0.id, $0) })
        let feedbackByStepID = Dictionary(grouping: input.feedback, by: \.stepID)
        let evidenceByStepID = Dictionary(grouping: input.evidence) { $0.stepID ?? "" }

        var records = bridgedInputContradictions(from: input.clarification)

        for candidate in input.compiledPath.candidates.sorted(by: candidateOrdering) {
            let candidateResources = input.resourceGraph.resources
                .filter { $0.candidateID == candidate.id && $0.optionality == .required }
                .sorted(by: resourceOrdering)

            records.append(contentsOf: requirementContradictions(
                candidate: candidate,
                resources: candidateResources,
                knowledgeClaimsByID: knowledgeClaimsByID,
                knowledgeSourcesByID: knowledgeSourcesByID,
                providerStatusesByID: providerStatusesByID
            ))
            records.append(contentsOf: readinessContradictions(
                candidate: candidate,
                resources: candidateResources
            ))
            records.append(contentsOf: assumptionContradictions(
                candidate: candidate
            ))
        }

        records.append(contentsOf: behaviorContradictions(
            plannedStepsByID: plannedStepsByID,
            evidenceByStepID: evidenceByStepID,
            feedbackByStepID: feedbackByStepID
        ))
        records.append(contentsOf: energyContradictions(
            energyModel: input.energyModel,
            plannedStepsByID: plannedStepsByID,
            evidenceByStepID: evidenceByStepID,
            feedbackByStepID: feedbackByStepID
        ))

        return GoalContradictionReport(
            schemaVersion: goalContradictionSchemaVersion,
            records: deduplicated(records)
        )
    }
}

private extension DefaultGoalContradictionService {
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

    func energyContradictions(
        energyModel: GoalEnergyModel,
        plannedStepsByID: [String: Step],
        evidenceByStepID: [String: [ProgressEvidence]],
        feedbackByStepID: [String: [GoalFeedbackEvent]]
    ) -> [GoalContradictionRecord] {
        energyModel.evaluations
            .filter { $0.targetKind == .planStep }
            .sorted { $0.id < $1.id }
            .compactMap { evaluation in
                guard let stepID = evaluation.stepID ?? evaluation.targetID as String?,
                      plannedStepsByID[stepID] != nil else {
                    return nil
                }

                let positiveEvidence = supportingCompletionEvidence(for: stepID, evidenceByStepID: evidenceByStepID)
                let frictionFeedback = frictionFeedback(for: stepID, feedbackByStepID: feedbackByStepID)

                if evaluation.score >= 0.75,
                   frictionFeedback.count >= 3,
                   positiveEvidence.isEmpty {
                    return makeRecord(
                        id: "contradiction-energy-friction-\(evaluation.id)",
                        code: .energyFitVsSameGoalBehaviorFriction,
                        category: .energyBehavior,
                        severity: .important,
                        confidence: .medium,
                        summary: "Canonical energy fit is strongly positive, but same-step behavior shows repeated friction.",
                        candidateID: evaluation.candidateID,
                        stageID: evaluation.stageID,
                        artifactRefs: [
                            .init(kind: .energyEvaluation, id: evaluation.id, candidateID: evaluation.candidateID, stageID: evaluation.stageID),
                            .init(kind: .planStep, id: stepID, candidateID: evaluation.candidateID, stageID: evaluation.stageID)
                        ] + frictionFeedback.map {
                            GoalContradictionArtifactRef(kind: .feedbackEvent, id: $0.base.id, candidateID: evaluation.candidateID, stageID: evaluation.stageID)
                        }
                    )
                }

                if evaluation.score <= 0.35,
                   positiveEvidence.count >= 3,
                   frictionFeedback.isEmpty {
                    return makeRecord(
                        id: "contradiction-energy-support-\(evaluation.id)",
                        code: .energyFitVsSameGoalBehaviorSupport,
                        category: .energyBehavior,
                        severity: .important,
                        confidence: .medium,
                        summary: "Canonical energy fit is strongly negative, but same-step behavior shows repeated successful completion.",
                        candidateID: evaluation.candidateID,
                        stageID: evaluation.stageID,
                        artifactRefs: [
                            .init(kind: .energyEvaluation, id: evaluation.id, candidateID: evaluation.candidateID, stageID: evaluation.stageID),
                            .init(kind: .planStep, id: stepID, candidateID: evaluation.candidateID, stageID: evaluation.stageID)
                        ] + positiveEvidence.map {
                            GoalContradictionArtifactRef(kind: .progressEvidence, id: $0.id, candidateID: evaluation.candidateID, stageID: evaluation.stageID)
                        }
                    )
                }

                return nil
            }
    }

    func supportingCompletionEvidence(
        for stepID: String,
        evidenceByStepID: [String: [ProgressEvidence]]
    ) -> [ProgressEvidence] {
        (evidenceByStepID[stepID] ?? [])
            .filter { evidence in
                switch evidence.evidenceKind {
                case .stepCompleted, .habitCompletion, .habitMinimumVersion:
                    return true
                case .habitQuickLog, .sessionLogged, .reflectionLogged, .delegatedUpdate, .observationLogged, .milestoneReached:
                    return false
                }
            }
            .sorted { $0.id < $1.id }
    }

    func notRelevantFeedback(
        for stepID: String,
        feedbackByStepID: [String: [GoalFeedbackEvent]]
    ) -> [GoalFeedbackEvent] {
        (feedbackByStepID[stepID] ?? [])
            .filter {
                if case .notRelevant = $0 { return true }
                return false
            }
            .sorted { $0.base.id < $1.base.id }
    }

    func frictionFeedback(
        for stepID: String,
        feedbackByStepID: [String: [GoalFeedbackEvent]]
    ) -> [GoalFeedbackEvent] {
        (feedbackByStepID[stepID] ?? [])
            .filter { event in
                switch event {
                case let .skipped(_, reasonCode):
                    return [.avoidance, .tooHard, .notNow].contains(reasonCode)
                case .tooBig, .askedForSmallerVersion, .confused, .notRelevant:
                    return true
                case .completed, .delayed, .edited, .tooEasy, .askedWhyThisMatters:
                    return false
                }
            }
            .sorted { $0.base.id < $1.base.id }
    }

    func contradictionCode(for inputCode: GoalInputContradictionCode) -> GoalContradictionCode {
        switch inputCode {
        case .timingConflict:
            return .inputTimingConflict
        case .goalSubjectGap:
            return .inputGoalSubjectGap
        }
    }

    func providerUnavailable(
        resource: GoalResourceEntity,
        knowledgeClaimsByID: [String: KnowledgeClaim],
        knowledgeSourcesByID: [String: KnowledgeSourceRecord],
        providerStatusesByID: [String: KnowledgeProviderStatus]
    ) -> Bool {
        resource.providerIDs(
            for: resource,
            knowledgeClaimsByID: knowledgeClaimsByID,
            knowledgeSourcesByID: knowledgeSourcesByID
        ).contains { providerID in
            providerStatusesByID[providerID]?.availability != .available
        } || resource.uncertaintyFlags.contains(.providerUnavailable)
    }

    func staleSupportContradicts(resource: GoalResourceEntity) -> Bool {
        guard resource.optionality == .required else { return false }
        return resource.freshnessState == .stale || resource.freshnessState == .expired
    }

    func hasConflictingClaim(
        resource: GoalResourceEntity,
        knowledgeClaimsByID: [String: KnowledgeClaim]
    ) -> Bool {
        resource.claimIDs.contains { claimID in
            knowledgeClaimsByID[claimID]?.uncertaintyFlags.contains(.conflicting) == true
        }
    }

    func makeRecord(
        id: String,
        code: GoalContradictionCode,
        category: GoalContradictionCategory,
        severity: GoalContradictionSeverity,
        confidence: RecommendationConfidence,
        summary: String,
        candidateID: String?,
        stageID: String?,
        artifactRefs: [GoalContradictionArtifactRef]
    ) -> GoalContradictionRecord {
        GoalContradictionRecord(
            id: id,
            code: code,
            category: category,
            severity: severity,
            confidence: confidence,
            summary: summary,
            candidateID: candidateID,
            stageID: stageID,
            artifactRefs: artifactRefs
        )
    }

    func deduplicated(_ records: [GoalContradictionRecord]) -> [GoalContradictionRecord] {
        let sorted = records.sorted(by: recordOrdering)
        var result: [GoalContradictionRecord] = []
        var seen: Set<String> = []

        for record in sorted where seen.insert(record.deduplicationKey).inserted {
            result.append(
                GoalContradictionRecord(
                    id: record.id,
                    code: record.code,
                    category: record.category,
                    severity: record.severity,
                    confidence: record.confidence,
                    summary: record.summary,
                    candidateID: record.candidateID,
                    stageID: record.stageID,
                    artifactRefs: record.normalizedArtifactRefs
                )
            )
        }

        return result
    }

    func recordOrdering(lhs: GoalContradictionRecord, rhs: GoalContradictionRecord) -> Bool {
        if lhs.severity.sortRank != rhs.severity.sortRank {
            return lhs.severity.sortRank > rhs.severity.sortRank
        }
        if lhs.code.rawValue != rhs.code.rawValue {
            return lhs.code.rawValue < rhs.code.rawValue
        }
        if lhs.candidateID != rhs.candidateID {
            return (lhs.candidateID ?? "") < (rhs.candidateID ?? "")
        }
        if lhs.stageID != rhs.stageID {
            return (lhs.stageID ?? "") < (rhs.stageID ?? "")
        }
        if lhs.id != rhs.id {
            return lhs.id < rhs.id
        }
        return lhs.deduplicationKey < rhs.deduplicationKey
    }

    func candidateOrdering(lhs: GoalCompiledPathCandidate, rhs: GoalCompiledPathCandidate) -> Bool {
        if lhs.isPrimary != rhs.isPrimary {
            return lhs.isPrimary && !rhs.isPrimary
        }
        return lhs.id < rhs.id
    }

    func resourceOrdering(lhs: GoalResourceEntity, rhs: GoalResourceEntity) -> Bool {
        if lhs.candidateID != rhs.candidateID {
            return lhs.candidateID < rhs.candidateID
        }
        if lhs.targetStageID != rhs.targetStageID {
            return (lhs.targetStageID ?? "") < (rhs.targetStageID ?? "")
        }
        return lhs.id < rhs.id
    }
}

private extension GoalResourceEntity {
    func providerIDs(
        for resource: GoalResourceEntity? = nil,
        knowledgeClaimsByID: [String: KnowledgeClaim],
        knowledgeSourcesByID: [String: KnowledgeSourceRecord]
    ) -> [String] {
        let entity = resource ?? self
        let sourceProviders = entity.sourceRecordIDs.compactMap { knowledgeSourcesByID[$0]?.providerID }
        let claimProviders = entity.claimIDs.compactMap { knowledgeClaimsByID[$0]?.providerID }
        return Array(Set(sourceProviders + claimProviders)).sorted()
    }

    func providerArtifactRefs(
        requirementID: String,
        candidateID: String,
        stageID: String?,
        knowledgeClaimsByID: [String: KnowledgeClaim],
        knowledgeSourcesByID: [String: KnowledgeSourceRecord],
        providerStatusesByID: [String: KnowledgeProviderStatus]
    ) -> [GoalContradictionArtifactRef] {
        var refs: [GoalContradictionArtifactRef] = [
            .init(kind: .compiledPathRequirement, id: requirementID, candidateID: candidateID, stageID: stageID),
            .init(kind: .resource, id: id, candidateID: candidateID, stageID: targetStageID)
        ]

        refs.append(contentsOf: providerIDs(
            knowledgeClaimsByID: knowledgeClaimsByID,
            knowledgeSourcesByID: knowledgeSourcesByID
        ).compactMap { providerID in
            guard providerStatusesByID[providerID] != nil else { return nil }
            return GoalContradictionArtifactRef(kind: .knowledgeProvider, id: providerID, candidateID: candidateID, stageID: stageID)
        })

        return refs
    }
}
