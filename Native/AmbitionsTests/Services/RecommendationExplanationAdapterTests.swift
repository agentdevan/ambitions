import XCTest
@testable import Ambitions

final class RecommendationExplanationAdapterTests: XCTestCase {
    func testGoalExplainabilityAdapterPreservesWhyThisLinesAndCorrections() throws {
        let metadata = try metadata(
            input: "Submit my conference talk proposal by 2026-05-15",
            goalID: "goal-shared-explanation"
        )
        let goalID = try XCTUnwrap(metadata.context.goalID)
        let goalState = DefaultGoalExplainabilityProjector().makeState(
            metadata: metadata,
            applicableSignals: nil,
            primaryStepID: "step-primary",
            whyNow: WhyNowExplanationMetadata(
                conciseReason: "The deadline is close enough to protect momentum.",
                reasons: ["Deadline pressure is rising."]
            )
        )

        let explanation = DefaultRecommendationExplanationAdapter().makeGoalWhyThisExplanation(
            goalID: goalID,
            state: goalState,
            primaryStepID: "step-primary",
            lastUpdatedAt: "2026-04-24T12:00:00Z"
        )

        XCTAssertEqual(explanation.type, .whyThis)
        XCTAssertEqual(explanation.source, .goalDetail)
        XCTAssertEqual(explanation.relations.goalIDs, [goalID])
        XCTAssertEqual(explanation.summary, goalState.whyThis.compactSummary)
        XCTAssertTrue(explanation.evidenceCategories.contains(.userInput))
        XCTAssertTrue(explanation.evidenceCategories.contains(.path))
        XCTAssertTrue(explanation.evidenceCategories.contains(.memoryEvent))
        XCTAssertEqual(explanation.confidence, goalState.confidence.pathConfidence ?? goalState.confidence.understandingConfidence)
        XCTAssertTrue(explanation.localOnly)
    }

    func testAdapterBuildsLedgerEvidenceForPriorityAndContextLensEvents() {
        let priorityEntry = EventLedgerEntry(
            id: "ledger-priority",
            kind: .priorityChanged,
            occurredAt: "2026-04-24T12:00:00Z",
            source: .recommendation,
            title: "Priority changed",
            summary: "User raised priority.",
            trust: EventLedgerTrustMetadata(isUserConfirmed: true)
        )
        let contextEntry = EventLedgerEntry(
            id: "ledger-context",
            kind: .contextInferred,
            occurredAt: "2026-04-24T12:05:00Z",
            source: .recommendation,
            title: "Context inferred",
            summary: "Likely Work lens."
        )
        let adapter = DefaultRecommendationExplanationAdapter()

        let priorityEvidence = adapter.makeEvidence(from: priorityEntry)
        let contextEvidence = adapter.makeEvidence(from: contextEntry)

        XCTAssertEqual(priorityEvidence.category, .priority)
        XCTAssertTrue(priorityEvidence.isPriorityRelevant)
        XCTAssertEqual(priorityEvidence.eventLedgerEntryID, priorityEntry.id)
        XCTAssertEqual(contextEvidence.category, .contextLens)
        XCTAssertTrue(contextEvidence.isContextLensDerived)
        XCTAssertEqual(contextEvidence.eventLedgerEntryID, contextEntry.id)
    }
}

private extension RecommendationExplanationAdapterTests {
    func metadata(input: String, goalID: String) throws -> GoalOrchestrationMetadata {
        let result = GoalEngineOrchestrator().compileGoal(
            input,
            context: GoalEngineOrchestrationContext(
                goalID: goalID,
                referenceNow: GoalEngineFixtures.fixedNow
            )
        )

        switch result {
        case let .planned(planned):
            return planned.metadata
        case let .starterPlanned(starter):
            return starter.metadata
        case let .clarificationRequired(required):
            return required.metadata
        case let .blocked(blocked):
            return blocked.metadata
        }
    }
}
