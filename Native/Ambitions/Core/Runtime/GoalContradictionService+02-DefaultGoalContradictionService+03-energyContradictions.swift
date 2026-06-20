import Foundation

extension DefaultGoalContradictionService {

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
                case .stepCompleted, .ritualCompletion, .ritualMinimumVersion:
                    return true
                case .ritualQuickLog, .sessionLogged, .reflectionLogged, .delegatedUpdate, .observationLogged, .milestoneReached:
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
