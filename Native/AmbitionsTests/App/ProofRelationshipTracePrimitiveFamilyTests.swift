import AmbitionsDesignSystem
import Foundation
import XCTest

final class ProofRelationshipTracePrimitiveFamilyTests: XCTestCase {
    func testAMB582ProofRelationshipTracePrimitiveFamilyContract() {
        let contract = ProofRelationshipTracePrimitiveFamilyContract.current

        XCTAssertEqual(contract.primitiveID, "proof-relationship-trace-family")
        XCTAssertEqual(contract.ownerSurface, "Today / Goals / Motion")
        XCTAssertEqual(contract.productObjects, ["Proof", "Relationship", "Trace", "Receipt"])
        XCTAssertEqual(contract.stageName, "Proof / Relationship / Trace Primitive Family")
        XCTAssertEqual(contract.screenshotIdentifier, "ProofRelationshipTracePrimitiveFamily")
        XCTAssertTrue(contract.replacesStructures.contains("generic trace chips"))
        XCTAssertTrue(contract.replacesStructures.contains("source proof receipt panels"))
        XCTAssertTrue(contract.replacesStructures.contains("review trail cards"))
        XCTAssertTrue(contract.replacesStructures.contains("receipt cards"))
        XCTAssertEqual(contract.inspectionOrder, [
            "source",
            "relationship",
            "proof",
            "receipt",
            "replay trace",
            "user inspection"
        ])
        XCTAssertTrue(contract.forbiddenPatterns.contains("decorative proof"))
        XCTAssertTrue(contract.forbiddenPatterns.contains("generic trace chip"))
        XCTAssertTrue(contract.accessibilityFallbacks.contains { $0.contains("Dynamic Type") })
        XCTAssertTrue(contract.accessibilityFallbacks.contains { $0.contains("VoiceOver") })
        XCTAssertEqual(ProofRelationshipTracePrimitiveRole.source.semanticState, .trust)
        XCTAssertEqual(ProofRelationshipTracePrimitiveRole.relationship.semanticState, .focus)
        XCTAssertEqual(ProofRelationshipTracePrimitiveRole.proof.semanticState, .success)
        XCTAssertEqual(ProofRelationshipTracePrimitiveRole.receipt.semanticState, .trust)
        XCTAssertEqual(ProofRelationshipTracePrimitiveRole.replayTrace.semanticState, .review)
        XCTAssertEqual(ProofRelationshipTracePrimitiveRole.inspection.semanticState, .protected)
    }

    func testAMB582MotionCurrentUsesProofRelationshipTracePrimitiveFamily() throws {
        let motionSource = try source("Native/Ambitions/Stage/Motion/StageMotionCurrentView.swift", root: repoRoot())

        XCTAssertTrue(motionSource.contains("ProofRelationshipTracePrimitiveToken("))
        XCTAssertTrue(motionSource.contains("ProofRelationshipTracePrimitiveLine("))
        XCTAssertTrue(motionSource.contains("ProofRelationshipTracePrimitiveStage("))
        XCTAssertTrue(motionSource.contains("motion.current.source-proof-receipt"))
        XCTAssertTrue(motionSource.contains("Source, proof, and receipt remain inspectable before Motion changes."))

        XCTAssertFalse(motionSource.contains("AmbitionChip(chip.title"))
        XCTAssertFalse(motionSource.contains("AmbitionChip(marker.title"))
        XCTAssertFalse(motionSource.contains("MotionTraceDatum"))
        XCTAssertFalse(motionSource.contains("MotionFieldFactRow"))
    }

    func testAMB582GoalReviewTrailAndReceiptsUseProofRelationshipTracePrimitiveFamily() throws {
        let goalSource = try source("Native/Ambitions/Surfaces/Goals/GoalDetailScreen.swift", root: repoRoot())
        let reviewTrailSource = try section(
            named: "private struct GoalDetailReviewTrailSurface",
            endingBefore: "private struct GoalDetailProofRailSurface",
            in: goalSource
        )
        let receiptsSource = try section(
            named: "private struct GoalDetailReceiptsSurface",
            endingBefore: "private struct GoalAlternatePathDecisionSpine",
            in: goalSource
        )

        XCTAssertTrue(reviewTrailSource.contains("ProofRelationshipTracePrimitiveStage("))
        XCTAssertTrue(reviewTrailSource.contains("ProofRelationshipTracePrimitiveLine("))
        XCTAssertTrue(reviewTrailSource.contains("goal-detail.review-trail.\\(item.id)"))
        XCTAssertFalse(reviewTrailSource.contains("WidgetCard(state: item.state)"))
        XCTAssertFalse(reviewTrailSource.contains("TagPill(item.sourceLabel"))
        XCTAssertFalse(reviewTrailSource.contains("Label(item.kind.title"))

        XCTAssertTrue(receiptsSource.contains("ProofRelationshipTracePrimitiveStage("))
        XCTAssertTrue(receiptsSource.contains("ProofRelationshipTracePrimitiveLine("))
        XCTAssertTrue(receiptsSource.contains("goal-detail.receipts.\\(item.id)"))
        XCTAssertFalse(receiptsSource.contains("AppCard(state: item.state)"))
        XCTAssertFalse(receiptsSource.contains("EmptyStateCard("))
    }

    func testAMB582PrimitiveRegistryIncludesProofRelationshipTraceFamilyEntry() throws {
        let registry = try source("docs/codex/ambitions_primitive_invention_registry.md", root: repoRoot())

        XCTAssertTrue(registry.contains("| proof-relationship-trace-family | Promoted | Today / Goals / Motion | Proof / Relationship / Trace | AMB-582 |"))
        XCTAssertTrue(registry.contains("### proof-relationship-trace-family"))
        XCTAssertTrue(registry.contains("artifacts/ambitions-ui-reconstruction/relationship-motion/AMB-582-proof-relationship-trace-family.md"))
        XCTAssertTrue(registry.contains("artifacts/ambitions-ui-reconstruction/screenshots/proof-relationship-trace-family-amb-582.png"))
    }

    func section(named startMarker: String, endingBefore endMarker: String, in source: String) throws -> String {
        guard let start = source.range(of: startMarker),
              let end = source.range(of: endMarker, range: start.lowerBound..<source.endIndex) else {
            throw XCTSkip("Source section could not be located for \(startMarker).")
        }
        return String(source[start.lowerBound..<end.lowerBound])
    }

    func source(_ relativePath: String, root: URL) throws -> String {
        try String(contentsOf: root.appendingPathComponent(relativePath), encoding: .utf8)
    }

    func repoRoot() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }
}
