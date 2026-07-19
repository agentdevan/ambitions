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
