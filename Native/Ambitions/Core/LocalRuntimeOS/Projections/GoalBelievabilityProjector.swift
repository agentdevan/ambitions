import Foundation

protocol GoalBelievabilityAssessing: Sendable {
    func assess(_ input: BelievabilityProjectionInput) -> GoalBelievabilityAssessment
    func makeExplanation(
        for assessment: GoalBelievabilityAssessment,
        type: RecommendationExplanationType
    ) -> RecommendationExplanation
}

struct GoalBelievabilityProjector: GoalBelievabilityAssessing {
    func assess(_ input: BelievabilityProjectionInput) -> GoalBelievabilityAssessment {
        let generatedAt = DomainTimestamp.string(from: input.generatedAt)
        let goalID = input.goal?.id ?? input.capture?.goalRelationship?.goalID ?? input.capture?.linkedGoalID
        let captureID = input.capture?.id
        let stepID = input.step?.id
        let planID = input.planID ?? input.goal?.plan?.id
        let posture = posture(for: input)
        let contextLens = contextLens(for: input)
        let effortMinutes = input.effortMinutes ?? inferredEffortMinutes(for: input)
        let effortLevel = effortLevel(minutes: effortMinutes, input: input)
        let deadline = deadlineRisk(for: input)
        let consequence = input.consequence ?? consequenceLevel(for: input, deadline: deadline)
        let importance = input.importance ?? importanceLevel(for: input, consequence: consequence)
        let contextFit = contextFit(for: input, contextLens: contextLens)
        let capacity = capacityFit(for: input, effortMinutes: effortMinutes, deadline: deadline)
        let urgency = maxPressure([deadline.level, captureHint(input.capture?.priorityHints.urgency)])
        let goalRelationship = goalRelationshipPressure(for: input)
        let userPreference = input.userPreference ?? .none
        let priority = priorityReality(
            importance: importance,
            urgency: urgency,
            deadline: deadline.level,
            consequence: consequence,
            effort: effortLevel,
            contextFit: contextFit,
            goalRelationship: goalRelationship,
            userPreference: userPreference,
            capacity: capacity.level,
            recoveryState: input.recoveryState
        )
        let signals = healthSignals(
            input: input,
            posture: posture,
            priority: priority,
            deadline: deadline,
            capacity: capacity,
            consequence: consequence,
            effort: effortLevel,
            contextFit: contextFit
        )
        let status = status(
            posture: posture,
            signals: signals,
            priority: priority,
            deadline: deadline,
            capacity: capacity
        )
        let confidence = confidence(
            status: status,
            input: input,
            deadline: deadline,
            capacity: capacity,
            signals: signals
        )
        let reasons = reasons(
            status: status,
            input: input,
            deadline: deadline,
            capacity: capacity,
            priority: priority,
            posture: posture,
            contextLens: contextLens
        )
        let assumptions = assumptions(input: input, posture: posture, effortMinutes: effortMinutes)
        let recommendations = recommendations(
            status: status,
            signals: signals,
            posture: posture
        )
        let correctionSuggestions = correctionSuggestions(signals: signals, posture: posture)
        let eventIDs = normalized(
            input.eventLedgerEntries.map(\.id) +
            (input.realitySnapshot?.eventLedgerEntryIDs ?? []) +
            input.recommendationExplanations.flatMap(\.relations.eventLedgerEntryIDs)
        )
        let explanationIDs = normalized(
            input.recommendationExplanations.map(\.id) +
            (input.realitySnapshot?.recommendationExplanationIDs ?? []) +
            (input.capture?.recommendationExplanationIDs ?? [])
        )
        let calendarDerived = input.realitySnapshot?.privacy == .calendarDerived ||
            input.realitySnapshot?.calendarContext != nil ||
            input.realitySnapshot?.windows.contains(where: \.isCalendarDerived) == true ||
            input.recommendationExplanations.contains(where: \.containsCalendarDerivedEvidence)
        let privacy: EventLedgerPrivacyClassification = calendarDerived ? .calendarDerived : (input.capture?.privacy ?? .standard)

        return GoalBelievabilityAssessment(
            id: assessmentID(generatedAt: generatedAt, goalID: goalID, captureID: captureID, stepID: stepID, subjectKind: input.subjectKind),
            goalID: goalID,
            captureID: captureID,
            planID: planID,
            stepID: stepID,
            subjectKind: input.subjectKind,
            generatedAt: generatedAt,
            status: status,
            confidence: confidence,
            posture: posture,
            priorityReality: priority,
            deadlineRisk: deadline,
            consequenceLevel: consequence,
            effortLevel: effortLevel,
            effortMinutes: effortMinutes,
            contextLens: contextLens,
            contextFit: contextFit,
            capacityFit: capacity,
            signals: signals,
            reasons: reasons,
            recommendations: recommendations,
            assumptions: assumptions,
            correctionSuggestions: correctionSuggestions,
            hasCalendarDerivedEvidence: calendarDerived,
            privacy: privacy,
            relatedRealitySnapshotID: input.realitySnapshot?.id,
            eventLedgerEntryIDs: eventIDs,
            recommendationExplanationIDs: explanationIDs
        )
    }

    func makeExplanation(
        for assessment: GoalBelievabilityAssessment,
        type: RecommendationExplanationType
    ) -> RecommendationExplanation {
        let evidence = explanationEvidence(for: assessment)
        let assumptionEvidence = assessment.assumptions.map {
            RecommendationExplanationAssumption(
                id: "explanation.\($0.id)",
                summary: $0.summary,
                fieldKey: $0.fieldKey,
                confidence: $0.confidence,
                isUserCorrectable: $0.isUserCorrectable
            )
        }
        let correctionActions = assessment.correctionSuggestions.map { action in
            RecommendationExplanationCorrectionAction(
                id: "believability.correction.\(action.rawValue)",
                kind: action,
                title: correctionTitle(for: action),
                targetFieldKey: correctionField(for: action)
            )
        }
        return RecommendationExplanation(
            id: "explanation.believability.\(assessment.id).\(type.rawValue)",
            type: type,
            title: title(for: type, status: assessment.status),
            summary: assessment.summary.headline,
            recommendationTitle: assessment.recommendations.first?.title ?? assessment.summary.headline,
            recommendationSummary: assessment.reasons.map(\.summary).joined(separator: " "),
            confidence: assessment.confidence,
            evidence: evidence,
            assumptions: assumptionEvidence,
            userCorrectableFields: correctionActions.compactMap(\.targetFieldKey),
            correctionActions: correctionActions,
            lastUpdatedAt: assessment.generatedAt,
            source: .recommendation,
            relations: RecommendationExplanationRelations(
                goalIDs: [assessment.goalID].compactMap { $0 },
                captureIDs: [assessment.captureID].compactMap { $0 },
                planIDs: [assessment.planID].compactMap { $0 },
                eventLedgerEntryIDs: assessment.eventLedgerEntryIDs
            ),
            privacy: assessment.privacy,
            localOnly: true,
            metadata: [
                "assessmentID": assessment.id,
                "status": assessment.status.rawValue,
                "posture": assessment.posture.rawValue,
                "schema": assessment.schemaVersion
            ]
        )
    }
}

extension GoalBelievabilityProjector {
    func nowGoalPressureSummary(from assessment: GoalBelievabilityAssessment) -> NowGoalPressureSummary? {
        guard let goalID = assessment.goalID else { return nil }
        let kind: NowGoalPressureKind = assessment.posture == .passive ? .passiveGoal : .activeGoal
        return NowGoalPressureSummary(
            id: "now.believability.\(assessment.id)",
            kind: kind,
            level: assessment.priorityReality.overallPressure,
            goalID: goalID,
            title: assessment.summary.headline,
            summary: assessment.reasons.first?.summary ?? assessment.priorityReality.summary,
            explanationID: assessment.recommendationExplanationIDs.first,
            eventLedgerEntryIDs: assessment.eventLedgerEntryIDs
        )
    }

    func commandNeedsConfirmationMetadata(from assessment: GoalBelievabilityAssessment) -> [String: String] {
        guard assessment.status == .atRisk || assessment.status == .unrealistic || assessment.status == .blocked else {
            return [:]
        }
        return [
            "believabilityAssessmentID": assessment.id,
            "believabilityStatus": assessment.status.rawValue,
            "believabilitySummary": assessment.summary.headline,
            "needsConfirmation": "true"
        ]
    }
}
