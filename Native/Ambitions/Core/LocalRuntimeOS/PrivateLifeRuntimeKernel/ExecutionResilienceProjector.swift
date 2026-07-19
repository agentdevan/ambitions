import Foundation

protocol ExecutionResilienceAssessing: Sendable {
    func assess(_ input: ExecutionResilienceProjectionInput) -> ExecutionResilienceAssessment
    func makeExplanation(
        for assessment: ExecutionResilienceAssessment,
        option: ExecutionRecoveryOption?,
        type: RecommendationExplanationType
    ) -> RecommendationExplanation
}

struct ExecutionResilienceProjector: ExecutionResilienceAssessing {
    func assess(_ input: ExecutionResilienceProjectionInput) -> ExecutionResilienceAssessment {
        let generatedAt = DomainTimestamp.string(from: input.generatedAt)
        let assessments = normalizedAssessments(input)
        let explanations = input.recommendationExplanations
        let disruptions = makeDisruptions(input: input, assessments: assessments)
        let protected = protectedWork(from: assessments)
        let displaced = displacedWork(from: assessments, protected: protected)
        let passive = passiveWork(from: assessments)
        let waiting = waitingOrBlockedWork(from: assessments, captures: input.captures, nowState: input.nowState)
        let options = makeOptions(
            input: input,
            assessments: assessments,
            disruptions: disruptions,
            protected: protected,
            displaced: displaced,
            passive: passive,
            waiting: waiting,
            explanations: explanations,
            generatedAt: generatedAt
        )
        let status = status(disruptions: disruptions, nowState: input.nowState)
        let recommended = recommendedOption(from: options, status: status)
        let relatedGoalIDs = assessments.compactMap(\.goalID) + protected.compactMap(\.relatedGoalID) + displaced.compactMap(\.relatedGoalID)
        let relatedCaptureIDs = assessments.compactMap(\.captureID) + input.captures.map(\.id)
        let relatedTimeIDs = assessments.compactMap(\.planID) + [input.timeID].compactMap { $0 }
        let eventIDs = normalized(
            input.eventLedgerEntries.map(\.id) +
            assessments.flatMap(\.eventLedgerEntryIDs) +
            (input.realitySnapshot?.eventLedgerEntryIDs ?? []) +
            (input.nowState?.eventLedgerEntryIDs ?? [])
        )
        let explanationIDs = normalized(
            explanations.map(\.id) +
            assessments.flatMap(\.recommendationExplanationIDs) +
            options.flatMap(\.recommendationExplanationIDs) +
            (input.realitySnapshot?.recommendationExplanationIDs ?? []) +
            (input.nowState?.recommendationExplanationIDs ?? [])
        )
        let assumptions = assumptions(input: input, assessments: assessments)
        let corrections = correctionSuggestions(disruptions: disruptions, assessments: assessments)

        return ExecutionResilienceAssessment(
            id: "resilience.\(generatedAt)",
            generatedAt: generatedAt,
            relatedGoalIDs: relatedGoalIDs,
            relatedCaptureIDs: relatedCaptureIDs,
            relatedTimeIDs: relatedTimeIDs,
            relatedReviewIDs: [input.reviewID].compactMap { $0 },
            relatedBelievabilityAssessmentIDs: assessments.map(\.id),
            relatedRealitySnapshotID: input.realitySnapshot?.id ?? input.believabilitySnapshot?.relatedRealitySnapshotID,
            relatedNowStateID: input.nowState?.id,
            status: status,
            disruptions: disruptions,
            recoveryOptions: options,
            recommendedRecoveryOptionID: recommended?.id,
            smallestUsefulNextStep: smallestUsefulNextStep(from: recommended, assessments: assessments, input: input),
            protectedHighPriorityWork: protected,
            displacedLowerPriorityWork: displaced,
            passiveWorkDeferredCalmly: passive,
            waitingOrBlockedRemovedFromPressure: waiting,
            reasons: reasons(disruptions: disruptions, options: options, input: input),
            assumptions: assumptions,
            correctionSuggestions: corrections,
            eventLedgerEntryIDs: eventIDs,
            recommendationExplanationIDs: explanationIDs,
            privacy: privacy(input: input, assessments: assessments)
        )
    }

    func makeExplanation(
        for assessment: ExecutionResilienceAssessment,
        option: ExecutionRecoveryOption?,
        type: RecommendationExplanationType
    ) -> RecommendationExplanation {
        let selected = option ?? assessment.recommendedRecoveryOption
        let evidence = explanationEvidence(for: assessment, option: selected)
        let correctionActions = assessment.correctionSuggestions.map { kind in
            RecommendationExplanationCorrectionAction(
                id: "resilience.correction.\(kind.rawValue)",
                kind: kind,
                title: correctionTitle(for: kind),
                targetFieldKey: correctionField(for: kind)
            )
        }
        return RecommendationExplanation(
            id: "explanation.resilience.\(assessment.id).\(type.rawValue)",
            type: type,
            title: explanationTitle(for: type),
            summary: selected?.summary ?? "No recovery is needed right now.",
            recommendationTitle: selected?.title ?? "Keep current plan",
            recommendationSummary: selected?.expectedEffect,
            confidence: assessment.status == .stable ? .high : .medium,
            evidence: evidence,
            assumptions: assessment.assumptions,
            userCorrectableFields: correctionActions.compactMap(\.targetFieldKey),
            correctionActions: correctionActions,
            lastUpdatedAt: assessment.generatedAt,
            source: .recovery,
            relations: RecommendationExplanationRelations(
                goalIDs: assessment.relatedGoalIDs,
                captureIDs: assessment.relatedCaptureIDs,
                planIDs: assessment.relatedTimeIDs,
                reviewIDs: assessment.relatedReviewIDs,
                eventLedgerEntryIDs: assessment.eventLedgerEntryIDs
            ),
            privacy: assessment.privacy,
            localOnly: true,
            metadata: [
                "resilienceAssessmentID": assessment.id,
                "status": assessment.status.rawValue,
                "schema": assessment.schemaVersion,
                "optionID": selected?.id ?? ""
            ].filter { $0.value.isEmpty == false }
        )
    }
}
