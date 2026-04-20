import XCTest
@testable import Ambitions

final class GoalUnderstandingServiceTests: XCTestCase {
    func testServiceBuildsUnderstandingFromClassificationAndClarification() {
        let intake = GoalEngineIntakeService()
        let clarificationService = DefaultGoalClarificationService()
        let understandingService = DefaultGoalUnderstandingService()

        let classification = intake.classify(
            rawInput: "Launch my business",
            referenceNow: GoalEngineFixtures.fixedNow
        )
        let context = GoalEngineOrchestrationContextSnapshot(
            goalID: nil,
            actorName: nil,
            preferredPlanningStrictness: .starterFriendly,
            goalOwnerRole: nil,
            supportScope: nil,
            deadlineHints: [],
            existingGoalReferences: [],
            sourceScreen: nil,
            sourceFlow: nil,
            clarifiedFields: [:],
            referenceNow: GoalEngineFixtures.fixedNow,
            knowledgeContext: nil
        )
        let clarification = clarificationService.analyze(classification: classification, context: context)

        let understanding = understandingService.build(
            classification: classification,
            clarification: clarification,
            context: context
        )

        XCTAssertEqual(understanding.subject.normalizedTitle, classification.title)
        XCTAssertEqual(understanding.mode.goalMode, classification.mode.value)
        XCTAssertEqual(understanding.ownership.executionOwnership, classification.executionOwnership.value)
        XCTAssertEqual(understanding.readiness.decision, clarification.decision)
        XCTAssertFalse(understanding.alternateInterpretations.isEmpty)
        XCTAssertTrue(understanding.audit.evidence.contains(where: { $0.origin == .rawInput }))
        XCTAssertTrue(understanding.audit.evidence.contains(where: { $0.origin == .clarification }))
        XCTAssertTrue(understanding.audit.evidence.contains(where: { $0.origin == .derivedInference }))
    }

    func testServiceKeepsKnowledgeContextOptionalAndStructural() {
        let intake = GoalEngineIntakeService()
        let clarificationService = DefaultGoalClarificationService()
        let understandingService = DefaultGoalUnderstandingService()

        let classification = intake.classify(
            rawInput: "Launch my portfolio this summer",
            referenceNow: GoalEngineFixtures.fixedNow
        )
        let knowledgeContext = GoalUnderstandingKnowledgeContext(
            claims: [
                KnowledgeClaim(
                    id: "claim-1",
                    providerID: "official-api",
                    subject: "portfolio deadlines",
                    payload: KnowledgeClaimPayload(summary: "Applications typically close in late summer.", detail: nil),
                    source: KnowledgeSourceRecord(
                        id: "source-1",
                        providerID: "official-api",
                        entityTitle: "Portfolio Calendar",
                        publisher: "Example Org",
                        locator: "https://example.com",
                        provenanceKind: .official,
                        isOfficial: true
                    ),
                    freshness: KnowledgeFreshnessMetadata(
                        retrievedAt: GoalEngineFixtures.fixedNow,
                        publishedAt: "2026-04-01T00:00:00Z",
                        staleAfter: "2026-08-31T00:00:00Z",
                        expiresAt: nil,
                        state: .fresh
                    ),
                    trustLevel: .high,
                    confidence: .medium,
                    uncertaintyFlags: [],
                    explanation: KnowledgeExplanationMetadata(
                        summary: "Official seasonal timing guidance.",
                        supportingSourceIDs: ["source-1"],
                        notes: []
                    )
                )
            ],
            sources: [],
            providerStatuses: [
                KnowledgeProviderStatus(
                    provider: KnowledgeProviderDescriptor(id: "official-api", type: .officialAPI, displayName: "Official API"),
                    availability: .available,
                    detail: "Available",
                    runtimeTrustPosture: .localOnly
                )
            ]
        )
        let context = GoalEngineOrchestrationContextSnapshot(
            goalID: nil,
            actorName: nil,
            preferredPlanningStrictness: .balanced,
            goalOwnerRole: nil,
            supportScope: nil,
            deadlineHints: [],
            existingGoalReferences: [],
            sourceScreen: nil,
            sourceFlow: nil,
            clarifiedFields: [:],
            referenceNow: GoalEngineFixtures.fixedNow,
            knowledgeContext: knowledgeContext
        )
        let clarification = clarificationService.analyze(classification: classification, context: context)

        let understanding = understandingService.build(
            classification: classification,
            clarification: clarification,
            context: context
        )

        XCTAssertTrue(understanding.audit.evidence.contains(where: { $0.origin == .knowledgeContext }))
        XCTAssertTrue(understanding.dependencies.contains(where: { $0.sourceClaimIDs.contains("claim-1") }))
    }
}
