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
}
