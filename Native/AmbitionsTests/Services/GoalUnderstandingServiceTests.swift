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

    func testServiceConsumesKnowledgeIngestionBridgeForPlanningEvidence() {
        let intake = GoalEngineIntakeService()
        let clarificationService = DefaultGoalClarificationService()
        let understandingService = DefaultGoalUnderstandingService()
        let response = KnowledgeProviderResponse(
            claimSet: KnowledgeClaimSet(claims: [], conflictState: .none, degradationSummary: nil),
            providerInputs: [
                KnowledgeProviderClaimInput(
                    providerClaimKey: "claim-1",
                    providerID: "official-api",
                    subject: "portfolio deadlines",
                    summary: "Applications typically close in late summer.",
                    detail: nil,
                    source: KnowledgeProviderSourceInput(
                        providerSourceKey: "source-1",
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
                    uncertaintyFlags: []
                )
            ],
            providerStatuses: [
                KnowledgeProviderStatus(
                    provider: KnowledgeProviderDescriptor(id: "official-api", type: .officialAPI, displayName: "Official API"),
                    availability: .available,
                    detail: "Available",
                    runtimeTrustPosture: .localOnly
                )
            ]
        )

        let knowledgeContext = response.goalUnderstandingKnowledgeContext()
        let bridgedSourceID = knowledgeContext.sources[0].id
        let classification = intake.classify(
            rawInput: "Launch my portfolio this summer",
            referenceNow: GoalEngineFixtures.fixedNow
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

        XCTAssertTrue(understanding.audit.evidence.contains(where: { $0.sourceRecordID == bridgedSourceID }))
        XCTAssertTrue(understanding.dependencies.contains(where: { $0.sourceRecordIDs.contains(bridgedSourceID) }))
        XCTAssertTrue(understanding.constraints.contains(where: { $0.source == .knowledgeContext }))

        let trace = PrivateLifeRuntimeKernel().makeReplayableDecisionTrace(
            PrivateLifeRuntimeKernelDecisionInput(
                traceContext: PrivateLifeRuntimeKernelTraceContext(
                    runtimeContext: RuntimeContextSnapshot(
                        clientContext: .iphoneApp,
                        capabilities: .currentLocalRuntime,
                        syncStatus: SyncCapabilityStatus(
                            backendKind: .localOnly,
                            trustPosture: .localOnly,
                            availability: .unavailable,
                            detail: "Knowledge-to-runtime bridge remains local-only."
                        ),
                        knowledgeProviderStatuses: knowledgeContext.providerStatuses,
                        memorySummary: RuntimeMemorySummary(
                            memory: RuntimeMemorySnapshot(
                                goals: [],
                                drafts: [],
                                evidence: [],
                                feedback: [],
                                captures: [],
                                appState: .default
                            )
                        ),
                        externalSurfaceSnapshot: nil
                    )
                ),
                decisionKey: "knowledge.runtime.bridge",
                goalText: classification.title,
                recommendationTrace: RecommendationTrace(
                    id: "trace.knowledge.runtime.bridge",
                    recommendationID: "recommendation.knowledge.runtime.bridge",
                    source: RecommendationTraceSource(
                        citedSourceIDs: [bridgedSourceID],
                        sourceAtlasBlockReasons: [],
                        localEvidenceCategories: [.sourceTruth],
                        canSupportRecommendation: true
                    ),
                    reason: RecommendationTraceReason(
                        explanationID: "explanation.knowledge.runtime.bridge",
                        summary: "Planning used normalized knowledge source context.",
                        evidenceCategoryIDs: ["source_truth"]
                    ),
                    fit: RecommendationTraceFit(
                        state: .fits,
                        blockReasons: [],
                        canDriveRecommendation: true
                    ),
                    uncertainty: RecommendationTraceUncertainty(
                        uncertaintyIDs: [],
                        summaries: []
                    ),
                    control: RecommendationTraceControl(
                        correctionActionIDs: ["review-source"],
                        controlActionIDs: ["open-what-ambitions-knows", "reset-source-use"],
                        correctableFieldKeys: ["sourceRecord", "receipt", "replayTrace"],
                        hasRequiredControl: true
                    ),
                    receiptBehavior: RecommendationTraceReceiptBehavior.available(
                        receiptIDs: ["receipt.knowledge.runtime.bridge"],
                        actionReceiptIDs: ["receipt.knowledge.runtime.bridge"],
                        proofReferenceIDs: [bridgedSourceID]
                    )
                )
            )
        )

        XCTAssertEqual(trace.recommendation?.source.citedSourceIDs, [bridgedSourceID])
        XCTAssertEqual(trace.decisionReceipt?.sourceRecordIDs, ["receipt.knowledge.runtime.bridge"])
        XCTAssertEqual(trace.decisionReceipt?.replayTraceLabel, "Replay trace stays inspectable")
        XCTAssertTrue(trace.decisionReceipt?.hasProofBridge ?? false)
    }
}
