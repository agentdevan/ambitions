import XCTest
@testable import Ambitions

final class ExecutionResilienceModelsTests: XCTestCase {
    func testDisruptionTaxonomyCoversBatch72States() {
        XCTAssertEqual(
            Set(ExecutionDisruptionKind.allCases),
            [
                .missedAction,
                .slippedDeadline,
                .overloadedDay,
                .noOpenWindow,
                .blockedByWaiting,
                .priorityConflict,
                .lowerPriorityDisplaced,
                .passiveGoalCrowding,
                .calendarConflict,
                .contextMismatch,
                .lowCapacity,
                .stalePlan,
                .underdefinedNextStep,
                .scopeIncrease,
                .deliverableAdded,
                .recoveryAlreadyInProgress
            ]
        )
    }

    func testRecoveryStrategyTaxonomyCoversBatch72Actions() {
        XCTAssertEqual(
            Set(ExecutionRecoveryStrategy.allCases),
            [
                .doSmallestNextStep,
                .rescheduleLater,
                .splitIntoSmallerStep,
                .deferPassiveWork,
                .protectDeadlineWork,
                .moveToWaiting,
                .clarifyNextStep,
                .reduceScope,
                .acceptSlip,
                .askForDecision,
                .keepAsSomeday,
                .openTime,
                .openGoal,
                .openCapture
            ]
        )
    }

    func testAssessmentNormalizesReferencesAndSummaries() {
        let disruption = ExecutionDisruption(
            id: "d-low",
            kind: .blockedByWaiting,
            title: "Waiting",
            summary: "Waiting work should not pressure Today.",
            severity: .low,
            evidenceReferenceIDs: ["ledger-b", "ledger-a", "ledger-a"]
        )
        let option = ExecutionRecoveryOption(
            id: "option",
            title: "Keep waiting",
            summary: "Keep this out of pressure.",
            strategy: .moveToWaiting,
            expectedEffect: "No false urgency.",
            tradeoff: RecoveryTradeoff(summary: "Progress waits for the blocker.", protectsHighPriorityWork: false, defersPassiveOrFlexibleWork: false, displacesLowerPriorityWork: false, requiresUserDecision: false),
            urgencyBasis: "Blocked by waiting.",
            capacityBasis: "Waiting consumes no open execution capacity.",
            requiresUserConfirmation: false,
            relatedCommandKind: .markWaiting,
            eventLedgerEntryIDs: ["ledger-b", "ledger-a"],
            recommendationExplanationIDs: ["explanation-b", "explanation-a", "explanation-a"]
        )

        let assessment = ExecutionResilienceAssessment(
            id: "assessment",
            generatedAt: "2026-04-25T12:00:00Z",
            relatedGoalIDs: ["goal-b", "goal-a", "goal-a"],
            relatedCaptureIDs: ["capture-a"],
            relatedTimeIDs: ["time-a"],
            relatedBelievabilityAssessmentIDs: ["believability-b", "believability-a"],
            status: .blocked,
            disruptions: [disruption],
            recoveryOptions: [option],
            recommendedRecoveryOptionID: "option",
            smallestUsefulNextStep: "Wait for the blocker to change.",
            reasons: [.waitingOrBlocked, .waitingOrBlocked],
            assumptions: [
                RecommendationExplanationAssumption(id: "b", summary: "Second"),
                RecommendationExplanationAssumption(id: "a", summary: "First")
            ],
            correctionSuggestions: [.changeRoute, .changeRoute],
            eventLedgerEntryIDs: ["ledger-b", "ledger-a", "ledger-a"],
            recommendationExplanationIDs: ["explanation-b", "explanation-a"]
        )

        XCTAssertEqual(assessment.schemaVersion, executionResilienceSchemaVersion)
        XCTAssertEqual(assessment.relatedGoalIDs, ["goal-a", "goal-b"])
        XCTAssertEqual(assessment.relatedTimeIDs, ["time-a"])
        XCTAssertEqual(assessment.relatedBelievabilityAssessmentIDs, ["believability-a", "believability-b"])
        XCTAssertEqual(assessment.reasons, [.waitingOrBlocked])
        XCTAssertEqual(assessment.assumptions.map(\.id), ["a", "b"])
        XCTAssertEqual(assessment.eventLedgerEntryIDs, ["ledger-a", "ledger-b"])
        XCTAssertEqual(assessment.recommendationExplanationIDs, ["explanation-a", "explanation-b"])
        XCTAssertEqual(assessment.recommendedRecoveryOption?.strategy, .moveToWaiting)
        XCTAssertEqual(assessment.recommendation?.optionID, "option")

        let snapshot = ExecutionResilienceSnapshot(
            id: "snapshot",
            generatedAt: "2026-04-25T12:00:00Z",
            assessments: [assessment],
            relatedRealitySnapshotID: "reality",
            relatedNowStateID: "now"
        )

        XCTAssertEqual(snapshot.eventLedgerEntryIDs, ["ledger-a", "ledger-b"])
        XCTAssertEqual(snapshot.recommendationExplanationIDs, ["explanation-a", "explanation-b"])
        XCTAssertEqual(snapshot.relatedRealitySnapshotID, "reality")
        XCTAssertTrue(snapshot.localOnly)
    }
}
