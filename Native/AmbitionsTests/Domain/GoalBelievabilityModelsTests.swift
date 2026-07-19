import XCTest
@testable import Ambitions

final class GoalBelievabilityModelsTests: XCTestCase {
    func testGoalHealthStatusTaxonomyCoversBatch71States() {
        XCTAssertEqual(
            Set(GoalHealthStatus.allCases),
            [
                .believable,
                .tight,
                .atRisk,
                .unrealistic,
                .blocked,
                .underdefined,
                .passive,
                .optionalSomeday,
                .waiting
            ]
        )
    }

    func testGoalHealthSignalTaxonomyCoversPriorityRealityInputs() {
        XCTAssertEqual(
            Set(GoalHealthSignal.allCases),
            [
                .enoughCapacity,
                .limitedCapacity,
                .noOpenWindow,
                .deadlineClose,
                .hardDeadline,
                .highConsequence,
                .lowConsequence,
                .highEffort,
                .passiveFlexible,
                .activePriority,
                .contextMismatch,
                .calendarDerivedConflict,
                .missingDeadline,
                .missingEffort,
                .missingPriority,
                .blockedByWaiting,
                .scopeIncreased,
                .deliverableAdded,
                .recoveryNeeded
            ]
        )
    }

    func testAssessmentSnapshotNormalizesReferencesAndSummaries() {
        let priority = GoalPriorityRealityAssessment(
            importance: .high,
            urgency: .elevated,
            deadline: .high,
            consequence: .high,
            capacity: .moderate,
            overallPressure: .high,
            summary: "Separated dimensions."
        )
        let assessment = GoalBelievabilityAssessment(
            id: "assessment-1",
            goalID: "goal-1",
            captureID: "capture-1",
            planID: "plan-1",
            stepID: "step-1",
            subjectKind: .goal,
            generatedAt: "2026-04-25T12:00:00Z",
            status: .tight,
            confidence: .high,
            posture: .active,
            priorityReality: priority,
            deadlineRisk: GoalDeadlineRisk(level: .high, isDeadlineBound: true, isHardDeadline: true, summary: "Hard deadline."),
            consequenceLevel: .high,
            effortLevel: .moderate,
            contextLens: .freeTime,
            contextFit: .low,
            capacityFit: GoalCapacityFit(level: .moderate, openWindowFit: .low, hasEnoughCapacity: true, summary: "Enough time."),
            signals: [.hardDeadline, .hardDeadline, .enoughCapacity],
            reasons: [
                GoalBelievabilityReason(id: "b", summary: "Second."),
                GoalBelievabilityReason(id: "a", summary: "First.")
            ],
            recommendations: [
                GoalBelievabilityRecommendation(id: "keep", title: "Keep going", summary: "Enough evidence.")
            ],
            assumptions: [],
            correctionSuggestions: [.changeDeadline, .changeDeadline],
            hasCalendarDerivedEvidence: true,
            privacy: .calendarDerived,
            relatedRealitySnapshotID: "reality-1",
            eventLedgerEntryIDs: ["ledger-2", "ledger-1", "ledger-1"],
            recommendationExplanationIDs: ["explanation-1", "explanation-1"]
        )

        XCTAssertEqual(assessment.schemaVersion, goalBelievabilitySchemaVersion)
        XCTAssertEqual(assessment.signals, [.enoughCapacity, .hardDeadline])
        XCTAssertEqual(assessment.eventLedgerEntryIDs, ["ledger-1", "ledger-2"])
        XCTAssertEqual(assessment.correctionSuggestions, [.changeDeadline])
        XCTAssertEqual(assessment.summary.status, .tight)
        XCTAssertEqual(assessment.summary.reasonSummaries, ["First.", "Second."])
        XCTAssertTrue(assessment.localOnly)

        let snapshot = GoalBelievabilitySnapshot(
            id: "snapshot-1",
            generatedAt: "2026-04-25T12:00:00Z",
            assessments: [assessment],
            relatedRealitySnapshotID: "reality-1"
        )

        XCTAssertEqual(snapshot.privacy, .calendarDerived)
        XCTAssertEqual(snapshot.eventLedgerEntryIDs, ["ledger-1", "ledger-2"])
        XCTAssertEqual(snapshot.recommendationExplanationIDs, ["explanation-1"])
    }
}
