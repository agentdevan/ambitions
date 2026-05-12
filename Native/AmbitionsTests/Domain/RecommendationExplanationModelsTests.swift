import XCTest
@testable import Ambitions

final class RecommendationExplanationModelsTests: XCTestCase {
    func testExplanationTypeTaxonomyCoversBatch66Reasons() {
        XCTAssertEqual(
            Set(RecommendationExplanationType.allCases),
            [
                .whyThis,
                .whyNow,
                .whyChanged,
                .whyScheduled,
                .whyDeferred,
                .whyRecovered,
                .whyPrioritized,
                .whyDisplaced,
                .whyRouted,
                .whyGoalChanged,
                .whyPlanChanged,
                .whyContextLens,
                .whyCalendarAware,
                .whyBelievable,
                .whyNotBelievable
            ]
        )
    }

    func testEvidenceCategoryTaxonomyCoversDecisionInputs() {
        XCTAssertEqual(
            Set(RecommendationExplanationEvidenceCategory.allCases),
            [
                .userInput,
                .memoryEvent,
                .goalState,
                .captureState,
                .planState,
                .calendarDerived,
                .deadline,
                .priority,
                .urgency,
                .consequence,
                .effort,
                .contextLens,
                .capacity,
                .recovery,
                .path,
                .deliverable,
                .scopeChange,
                .assumption,
                .userCorrection,
                .systemDefault
            ]
        )
    }

    func testConfidenceAndUncertaintyDefaultsAreConservative() {
        let explanation = RecommendationExplanation(
            id: "explanation-defaults",
            type: .whyRouted,
            title: "Why routed",
            summary: "I routed this to Plan because it looks like a one-time commitment.",
            recommendationTitle: "Create spreadsheet and send it to Kaylee",
            lastUpdatedAt: "2026-04-24T12:00:00Z",
            source: .capture
        )
        let uncertainty = RecommendationExplanationUncertainty(
            id: "uncertain-eod",
            summary: "I am not certain whether EOD means 5 PM for you."
        )

        XCTAssertEqual(explanation.confidence, .medium)
        XCTAssertTrue(explanation.localOnly)
        XCTAssertEqual(explanation.privacy, .standard)
        XCTAssertEqual(uncertainty.severity, .medium)
        XCTAssertTrue(uncertainty.canBeReducedByUser)
    }

    func testAssumptionsAreReadableAndCorrectable() {
        let assumption = RecommendationExplanationAssumption(
            id: "assumption-work-task",
            summary: "I assumed this is a work task.",
            fieldKey: "domain_context"
        )

        XCTAssertEqual(assumption.summary, "I assumed this is a work task.")
        XCTAssertEqual(assumption.confidence, .medium)
        XCTAssertTrue(assumption.isUserCorrectable)
    }

    func testCorrectionActionsRepresentUserTuningWithoutUI() {
        XCTAssertEqual(
            Set(RecommendationExplanationCorrectionActionKind.allCases),
            [
                .changeDomainContext,
                .changeDeadline,
                .changeImportance,
                .changeUrgency,
                .changeConsequence,
                .changeRoute,
                .markGoalSupporting,
                .markOneTimeTask,
                .markOptionalSomeday,
                .dismissRecommendation,
                .explainMore
            ]
        )

        let action = RecommendationExplanationCorrectionAction(
            id: "correct-route",
            kind: .changeRoute,
            title: "Move this to Waiting",
            targetFieldKey: "route"
        )

        XCTAssertEqual(action.kind, .changeRoute)
        XCTAssertEqual(action.targetFieldKey, "route")
    }

    func testPriorityContextDeadlineAndConsequenceEvidenceCanBeRepresented() {
        let explanation = RecommendationExplanation(
            id: "explanation-priority-reality",
            type: .whyPrioritized,
            title: "Why this is higher priority",
            summary: "This has a hard deadline and real consequence, so it outranks passive flexible work.",
            recommendationTitle: "Build the crib",
            evidence: [
                RecommendationExplanationEvidence(id: "deadline", category: .deadline, title: "Hard deadline", summary: "Before the baby arrives."),
                RecommendationExplanationEvidence(id: "priority", category: .priority, title: "High priority"),
                RecommendationExplanationEvidence(id: "urgency", category: .urgency, title: "Urgent"),
                RecommendationExplanationEvidence(id: "consequence", category: .consequence, title: "Real-world consequence"),
                RecommendationExplanationEvidence(id: "effort", category: .effort, title: "Requires a work block"),
                RecommendationExplanationEvidence(id: "context", category: .contextLens, title: "Home context fit")
            ],
            lastUpdatedAt: "2026-04-24T12:00:00Z",
            source: .recommendation
        )

        XCTAssertTrue(explanation.containsDeadlineEvidence)
        XCTAssertTrue(explanation.containsPriorityRealityEvidence)
        XCTAssertTrue(explanation.containsContextLensEvidence)
        XCTAssertTrue(explanation.evidenceCategories.isSuperset(of: [.deadline, .priority, .urgency, .consequence, .effort, .contextLens]))
    }

    func testGoalScopeDeliverableAndRouteEvidenceCanBeRepresented() {
        let explanation = RecommendationExplanation(
            id: "explanation-goal-path-change",
            type: .whyGoalChanged,
            title: "Why the path changed",
            summary: "Adding a deliverable changed the remaining roadmap.",
            recommendationTitle: "Update album path",
            evidence: [
                RecommendationExplanationEvidence(id: "song-added", category: .deliverable, title: "Song added"),
                RecommendationExplanationEvidence(id: "scope", category: .scopeChange, title: "Scope changed"),
                RecommendationExplanationEvidence(id: "route", category: .planState, title: "Scheduled before release")
            ],
            lastUpdatedAt: "2026-04-24T12:00:00Z",
            source: .goalDetail
        )

        XCTAssertTrue(explanation.containsGoalScopeOrDeliverableEvidence)
        XCTAssertTrue(explanation.evidenceCategories.contains(.planState))
    }

    func testExplanationsCanReferenceEventLedgerIdsAndPreservePrivacyMarkers() {
        let entry = EventLedgerEntry(
            id: "ledger-calendar-1",
            kind: .calendarContextObserved,
            occurredAt: "2026-04-24T12:00:00Z",
            source: .calendar,
            title: "Calendar context observed",
            summary: "Busy until 3 PM.",
            trust: EventLedgerTrustMetadata(confidence: 0.8),
            privacy: .calendarDerived
        )
        let evidence = RecommendationExplanationEvidence.fromEventLedgerEntry(entry)
        let explanation = RecommendationExplanation(
            id: "explanation-calendar-aware",
            type: .whyCalendarAware,
            title: "Why calendar-aware",
            summary: "The suggestion uses local calendar-derived pressure.",
            recommendationTitle: "Defer deep work",
            evidence: [evidence],
            lastUpdatedAt: "2026-04-24T12:00:00Z",
            source: .plan,
            relations: RecommendationExplanationRelations(eventLedgerEntryIDs: [entry.id]),
            privacy: .calendarDerived
        )

        XCTAssertEqual(evidence.category, .calendarDerived)
        XCTAssertEqual(evidence.eventLedgerEntryID, entry.id)
        XCTAssertEqual(evidence.confidence, .high)
        XCTAssertTrue(explanation.referencesEventLedger)
        XCTAssertTrue(explanation.containsCalendarDerivedEvidence)
        XCTAssertEqual(explanation.privacy, .calendarDerived)
        XCTAssertTrue(explanation.localOnly)
    }

    func testEvidenceBoundarySummaryNamesLocalEvidenceAndCorrectionAvailability() {
        let explanation = RecommendationExplanation(
            id: "explanation-boundary-evidence",
            type: .whyChanged,
            title: "Why changed",
            summary: "A correction changed the recommendation.",
            recommendationTitle: "Use the lighter version",
            evidence: [
                RecommendationExplanationEvidence(
                    id: "correction",
                    category: .userCorrection,
                    title: "Correction",
                    sourceID: "correction-1"
                )
            ],
            assumptions: [
                RecommendationExplanationAssumption(
                    id: "assumption-energy",
                    summary: "I assumed this needs a lighter version.",
                    fieldKey: "energy_fit"
                )
            ],
            userCorrectableFields: ["energy_fit"],
            correctionActions: [
                RecommendationExplanationCorrectionAction(
                    id: "correct-energy",
                    kind: .changeImportance,
                    title: "Use a different fit",
                    targetFieldKey: "energy_fit"
                )
            ],
            lastUpdatedAt: "2026-05-03T23:50:00Z",
            source: .recommendation
        )

        let boundary = explanation.evidenceBoundarySummary

        XCTAssertEqual(boundary.evidenceLabel, "Uses local explanation evidence")
        XCTAssertEqual(boundary.inferenceBoundaryLabel, "Inference stated and correctable")
        XCTAssertEqual(boundary.userControlLabel, "Correction available")
        XCTAssertEqual(boundary.privacyLabel, "Local-only")
        XCTAssertEqual(boundary.citedSourceIDs, ["correction-1"])
        XCTAssertFalse(boundary.isEvidenceLight)
        XCTAssertTrue(boundary.hasCorrectableInference)
        XCTAssertFalse(boundary.requiresSensitiveReview)
    }

    func testEvidenceBoundarySummaryKeepsEvidenceLightRecommendationsHonest() {
        let explanation = RecommendationExplanation(
            id: "explanation-boundary-light",
            type: .whyThis,
            title: "Why this",
            summary: "This is a default suggestion.",
            recommendationTitle: "Start small",
            lastUpdatedAt: "2026-05-03T23:55:00Z",
            source: .system
        )

        let boundary = explanation.evidenceBoundarySummary

        XCTAssertEqual(boundary.evidenceLabel, "Evidence-light")
        XCTAssertEqual(boundary.inferenceBoundaryLabel, "No stated inference")
        XCTAssertEqual(boundary.userControlLabel, "Review only")
        XCTAssertTrue(boundary.isEvidenceLight)
        XCTAssertFalse(boundary.hasCorrectableInference)
    }

    func testEvidenceBoundarySummaryFlagsCalendarDerivedPrivacyBoundary() {
        let entry = EventLedgerEntry(
            id: "ledger-calendar-boundary",
            kind: .calendarContextObserved,
            occurredAt: "2026-05-03T23:58:00Z",
            source: .calendar,
            title: "Calendar context observed",
            privacy: .calendarDerived
        )
        let explanation = RecommendationExplanation(
            id: "explanation-boundary-calendar",
            type: .whyCalendarAware,
            title: "Why calendar-aware",
            summary: "The suggestion uses calendar-derived pressure.",
            recommendationTitle: "Move deep work",
            evidence: [RecommendationExplanationEvidence.fromEventLedgerEntry(entry)],
            lastUpdatedAt: "2026-05-03T23:59:00Z",
            source: .plan,
            relations: RecommendationExplanationRelations(eventLedgerEntryIDs: [entry.id]),
            privacy: .calendarDerived
        )

        let boundary = explanation.evidenceBoundarySummary

        XCTAssertEqual(boundary.evidenceLabel, "Cites local records")
        XCTAssertEqual(boundary.privacyLabel, "Calendar-derived")
        XCTAssertEqual(boundary.citedSourceIDs, [entry.id])
        XCTAssertTrue(boundary.requiresSensitiveReview)
    }

    func testRecommendationEvidenceModelSummarizesLocalCitedEvidence() {
        let entry = EventLedgerEntry(
            id: "ledger-priority-1",
            kind: .priorityChanged,
            occurredAt: "2026-05-12T12:00:00Z",
            source: .goalEngine,
            title: "Priority changed",
            summary: "The goal became time-sensitive.",
            trust: EventLedgerTrustMetadata(confidence: 0.76)
        )
        let explanation = RecommendationExplanation(
            id: "explanation-evidence-model",
            type: .whyPrioritized,
            title: "Why this rose",
            summary: "Local records show priority and deadline pressure.",
            recommendationTitle: "Finish the grant packet",
            evidence: [
                RecommendationExplanationEvidence.fromEventLedgerEntry(entry),
                RecommendationExplanationEvidence(
                    id: "deadline",
                    category: .deadline,
                    title: "Deadline",
                    sourceID: "deadline-1"
                )
            ],
            assumptions: [
                RecommendationExplanationAssumption(
                    id: "assumption-energy",
                    summary: "I assumed this fits an afternoon work block.",
                    fieldKey: "energy_fit"
                )
            ],
            uncertainty: [
                RecommendationExplanationUncertainty(
                    id: "uncertainty-duration",
                    summary: "The exact duration is unclear."
                )
            ],
            userCorrectableFields: ["duration"],
            correctionActions: [
                RecommendationExplanationCorrectionAction(
                    id: "correct-energy",
                    kind: .changeImportance,
                    title: "Change fit",
                    targetFieldKey: "energy_fit"
                )
            ],
            lastUpdatedAt: "2026-05-12T12:01:00Z",
            source: .recommendation,
            relations: RecommendationExplanationRelations(eventLedgerEntryIDs: [entry.id])
        )

        let model = explanation.recommendationEvidenceModel

        XCTAssertEqual(model.explanationID, explanation.id)
        XCTAssertEqual(model.strength, .citedLocalRecords)
        XCTAssertEqual(model.categories, [.deadline, .priority])
        XCTAssertEqual(model.categoryCounts[.deadline], 1)
        XCTAssertEqual(model.categoryCounts[.priority], 1)
        XCTAssertEqual(model.citedSourceIDs, ["deadline-1", entry.id])
        XCTAssertEqual(model.eventLedgerEntryIDs, [entry.id])
        XCTAssertEqual(model.assumptionIDs, ["assumption-energy"])
        XCTAssertEqual(model.uncertaintyIDs, ["uncertainty-duration"])
        XCTAssertEqual(model.correctableFieldKeys, ["duration", "energy_fit"])
        XCTAssertTrue(model.usesDeadlineEvidence)
        XCTAssertTrue(model.usesPriorityRealityEvidence)
        XCTAssertFalse(model.requiresSensitiveReview)
        XCTAssertTrue(model.canDriveRecommendation)
    }

    func testRecommendationEvidenceModelBlocksEvidenceLightAndSensitiveRecommendations() {
        let evidenceLight = RecommendationExplanation(
            id: "explanation-evidence-light-model",
            type: .whyThis,
            title: "Why this",
            summary: "A default suggestion.",
            recommendationTitle: "Start small",
            lastUpdatedAt: "2026-05-12T12:02:00Z",
            source: .system
        ).recommendationEvidenceModel

        let calendarDerived = RecommendationExplanation(
            id: "explanation-calendar-model",
            type: .whyCalendarAware,
            title: "Why calendar-aware",
            summary: "Calendar pressure changed the suggestion.",
            recommendationTitle: "Move deep work",
            evidence: [
                RecommendationExplanationEvidence(
                    id: "calendar",
                    category: .calendarDerived,
                    title: "Calendar pressure"
                )
            ],
            lastUpdatedAt: "2026-05-12T12:03:00Z",
            source: .calendar,
            privacy: .calendarDerived
        ).recommendationEvidenceModel

        XCTAssertEqual(evidenceLight.strength, .evidenceLight)
        XCTAssertFalse(evidenceLight.canDriveRecommendation)
        XCTAssertEqual(calendarDerived.strength, .reviewRequired)
        XCTAssertTrue(calendarDerived.requiresSensitiveReview)
        XCTAssertFalse(calendarDerived.canDriveRecommendation)
    }
}
