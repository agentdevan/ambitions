import XCTest
@testable import Ambitions

final class AmbitionsOSControlPlaneModelsTests: XCTestCase {
    private let classifier = AmbitionsOSControlPlaneClassifier()

    func testControlPlanePersistentUserSurfacesMatchStageRootSurfacesExactly() {
        let stageRoots = AmbitionsSurface.allCases.map(\.rawValue)
        let controlPlaneRoots = AmbitionsOSControlPlaneSurface.canonicalPersistentUserSurfaces.map(\.rawValue)
        let allControlPlaneCases = AmbitionsOSControlPlaneSurface.allCases.map(\.rawValue)

        XCTAssertEqual(stageRoots, ["today", "goals", "time", "you"])
        XCTAssertEqual(controlPlaneRoots, stageRoots)
        XCTAssertEqual(
            allControlPlaneCases.filter { ["capture", "captures", "plan", "profile", "motion"].contains($0) },
            []
        )
        XCTAssertTrue(AmbitionsOSControlPlaneSurface.time.isPersistentUserSurface)
        XCTAssertFalse(AmbitionsOSControlPlaneSurface.captureComposer.isPersistentUserSurface)
        XCTAssertTrue(AmbitionsOSControlPlaneSurface.captureComposer.isGlobalComposerOrCommand)
    }

    func testCaptureComposerClassifiesLocalWorkWithoutBecomingRootSurface() {
        let request = AmbitionsOSControlPlaneWorkRequest(
            id: "capture-composer",
            title: "Route captured intent",
            surface: .captureComposer,
            signals: [.localOnly],
            requestedAt: "2026-05-06T15:29:00Z"
        )

        let classification = classifier.classify(request)

        XCTAssertFalse(request.surface.isPersistentUserSurface)
        XCTAssertTrue(request.surface.isGlobalComposerOrCommand)
        XCTAssertEqual(classification.disposition, .allowLocalWork)
        XCTAssertEqual(classification.requiredGates, [])
        XCTAssertTrue(classification.allowedOutputs.contains(.recommendation))
        XCTAssertTrue(classification.canReachEventLog)
    }

    func testSourceSensitiveRegulatedWorkRequiresSourceAndSafetyReview() {
        let request = AmbitionsOSControlPlaneWorkRequest(
            id: "career-requirement",
            title: "Review nursing program requirement",
            surface: .goals,
            signals: [.sourceSensitive, .regulatedDomain],
            sourceState: .sourceNeeded,
            freshnessState: .staleCritical,
            reviewState: .needsSourceReview,
            requestedAt: "2026-05-06T15:30:00Z"
        )

        let classification = classifier.classify(request)

        XCTAssertEqual(classification.workClass, .interactive)
        XCTAssertEqual(classification.disposition, .requireReview)
        XCTAssertTrue(classification.requiredGates.contains(.sourceVerification))
        XCTAssertTrue(classification.requiredGates.contains(.safetyReview))
        XCTAssertTrue(classification.requiredGates.contains(.userApproval))
        XCTAssertTrue(classification.allowedOutputs.contains(.sourceRequest))
        XCTAssertTrue(classification.blocksRecommendation)
        XCTAssertFalse(classification.canReachEventLog)
    }

    func testGraphDeltaProposalRequiresReviewRecordBeforeEventLog() {
        let request = AmbitionsOSControlPlaneWorkRequest(
            id: "graph-delta",
            title: "Project graph delta",
            surface: .you,
            signals: [.graphDeltaProposal],
            deltaReviewRecord: nil,
            requestedAt: "2026-05-06T15:31:00Z"
        )

        let classification = classifier.classify(request)

        XCTAssertEqual(classification.disposition, .requireReview)
        XCTAssertTrue(classification.requiredGates.contains(.graphDeltaReview))
        XCTAssertTrue(classification.requiredGates.contains(.trustReview))
        XCTAssertTrue(classification.allowedOutputs.contains(.reviewRequest))
        XCTAssertTrue(classification.blocksRecommendation)
        XCTAssertFalse(classification.canReachEventLog)
    }

    func testApprovedGraphDeltaReviewCanReachProjectionWithoutExternalClaim() {
        let request = AmbitionsOSControlPlaneWorkRequest(
            id: "approved-graph-delta",
            title: "Project approved graph delta",
            surface: .you,
            signals: [.graphDeltaProposal],
            deltaReviewRecord: approvedReviewRecord(),
            requestedAt: "2026-05-06T15:32:00Z"
        )

        let classification = classifier.classify(request)

        XCTAssertEqual(classification.disposition, .allowLocalWork)
        XCTAssertEqual(classification.requiredGates, [])
        XCTAssertTrue(classification.allowedOutputs.contains(.projection))
        XCTAssertTrue(classification.allowedOutputs.contains(.receipt))
        XCTAssertTrue(classification.canReachEventLog)
        XCTAssertFalse(classification.blocksRecommendation)
    }

    func testExternalAndBackgroundWorkRequiresPrivacyCompatibilityAndBudgetGates() {
        let request = AmbitionsOSControlPlaneWorkRequest(
            id: "external-background",
            title: "Prepare external projection",
            surface: .externalProjection,
            signals: [.externalSurface, .backgroundExecution, .compatibilitySurface],
            requestedAt: "2026-05-06T15:33:00Z"
        )

        let classification = classifier.classify(request)

        XCTAssertEqual(classification.workClass, .background)
        XCTAssertEqual(classification.disposition, .requireReview)
        XCTAssertTrue(classification.requiredGates.contains(.privacyProjection))
        XCTAssertTrue(classification.requiredGates.contains(.compatibilityReview))
        XCTAssertTrue(classification.requiredGates.contains(.performanceBudget))
        XCTAssertTrue(classification.requiredGates.contains(.deterministicFallback))
        XCTAssertTrue(classification.allowedOutputs.contains(.privacyProjection))
        XCTAssertFalse(classification.canReachEventLog)
    }

    func testSafetyAndReleaseSignalsBlockWorkInsteadOfRoutingToRecommendation() {
        let safety = classifier.classify(
            AmbitionsOSControlPlaneWorkRequest(
                id: "safety",
                title: "Unsafe request",
                surface: .captureComposer,
                signals: [.crisisOrSafety],
                requestedAt: "2026-05-06T15:34:00Z"
            )
        )
        let release = classifier.classify(
            AmbitionsOSControlPlaneWorkRequest(
                id: "release",
                title: "Public platform claim",
                surface: .runtimeContract,
                signals: [.releaseClaim],
                requestedAt: "2026-05-06T15:35:00Z"
            )
        )

        XCTAssertEqual(safety.disposition, .blocked)
        XCTAssertTrue(safety.requiredGates.contains(.safetyReview))
        XCTAssertFalse(safety.allowedOutputs.contains(.recommendation))
        XCTAssertEqual(release.disposition, .blocked)
        XCTAssertTrue(release.requiredGates.contains(.releaseEvidenceReview))
        XCTAssertFalse(release.canReachEventLog)
    }
}

private extension AmbitionsOSControlPlaneModelsTests {
    func approvedReviewRecord() -> LifeGraphDeltaReviewRecord {
        LifeGraphDeltaReviewRecord(
            id: "review-approved",
            delta: approvedDelta(),
            requestedAt: "2026-05-06T15:32:00Z",
            surface: .you,
            decision: .approvedForProjection,
            receiptIDs: ["receipt-approved"],
            risks: []
        )
    }

    func approvedDelta() -> HumanProgressGraphDelta {
        let node = HumanProgressGraphNode(
            id: "goal-path-approved",
            family: .goalPath,
            title: "Reviewable path",
            sourceState: .sourceBacked,
            freshnessState: .current,
            reviewState: .ready,
            createdAt: "2026-05-06T15:32:00Z"
        )
        let event = LifeGraphEventLogEntry(
            id: "event-approved",
            kind: .graphDeltaProposed,
            occurredAt: "2026-05-06T15:32:00Z",
            actor: .user,
            scope: .you,
            affectedNodeIDs: [node.id],
            sourceState: .sourceBacked,
            freshnessState: .current,
            reviewState: .ready,
            summary: "Approved graph delta."
        )
        return HumanProgressGraphDelta(
            id: "delta-approved",
            proposedAt: "2026-05-06T15:32:00Z",
            nodesToUpsert: [node],
            event: event,
            rollbackHint: "Remove projection before applying future graph change."
        )
    }
}
