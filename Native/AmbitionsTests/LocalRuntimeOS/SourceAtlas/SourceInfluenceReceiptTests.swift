import XCTest
@testable import Ambitions

final class SourceInfluenceReceiptTests: XCTestCase {
    func testReceiptCarriesOnlyPublicInfluenceAndLocalDecisionIdentifiers() throws {
        let receipt = SourceInfluenceReceipt(
            recordedAt: "2026-07-05T17:00:00Z",
            publicPlanningContextID: "context.public.varsity",
            selectedPackID: "source-atlas/v1/domain/sports/pack-public-varsity",
            selectedPackDomainID: "sports",
            manifestVersionID: "manifest.public.varsity",
            localDecisionOutputID: "step-candidate-field.local",
            localSelectedCandidateID: "candidate.local.selected",
            sourceIDs: ["source-public-varsity", " source-public-varsity "],
            claimIDs: ["claim-public-varsity"],
            requirementIDs: ["requirement-public-proof"],
            proofNeedIDs: ["proof-public-varsity"],
            starterActionIDs: ["starter-public-varsity"]
        )

        let encoded = try String(data: JSONEncoder().encode(receipt), encoding: .utf8) ?? ""
        let bridgeReceipt = receipt.bridgeReceipt

        XCTAssertEqual(receipt.schemaVersion, sourceInfluenceReceiptSchemaVersion)
        XCTAssertEqual(receipt.sourceIDs, ["source-public-varsity"])
        XCTAssertTrue(receipt.canInfluenceLocalPlanning)
        XCTAssertEqual(bridgeReceipt.kind, .sourceAtlasInfluenceReceiptRecorded)
        XCTAssertTrue(bridgeReceipt.details.contains("private-input-included=false"))
        XCTAssertTrue(bridgeReceipt.details.contains("private-life-graph-included=false"))
        XCTAssertTrue(bridgeReceipt.details.contains("source-atlas-final-step-owner=false"))
        XCTAssertTrue(bridgeReceipt.details.contains("source-atlas-final-schedule-owner=false"))
        XCTAssertTrue(bridgeReceipt.details.contains("source-atlas-stores-runtime-state=false"))
        XCTAssertTrue(bridgeReceipt.details.contains("can-influence-local-planning=true"))
        XCTAssertTrue(bridgeReceipt.relatedIDs.contains("source-public-varsity"))
        XCTAssertTrue(bridgeReceipt.relatedIDs.contains("candidate.local.selected"))
        XCTAssertFalse(encoded.contains("PRIVATE-GOAL-TEXT"))
        XCTAssertFalse(encoded.contains("account_id"))
        XCTAssertFalse(encoded.contains("device_id"))
        XCTAssertFalse(encoded.contains("goal_text"))
        XCTAssertFalse(encoded.contains("final_schedule"))
    }

    func testReceiptCannotInfluenceLocalPlanningWhenBoundaryIsViolated() {
        let receipt = SourceInfluenceReceipt(
            recordedAt: "2026-07-05T17:00:00Z",
            publicPlanningContextID: "context.public.varsity",
            selectedPackID: "source-atlas/v1/domain/sports/pack-public-varsity",
            selectedPackDomainID: "sports",
            localDecisionOutputID: "step-candidate-field.local",
            localSelectedCandidateID: "candidate.local.selected",
            sourceIDs: ["source-public-varsity"],
            claimIDs: ["claim-public-varsity"],
            requirementIDs: ["requirement-public-proof"],
            proofNeedIDs: ["proof-public-varsity"],
            starterActionIDs: ["starter-public-varsity"],
            sourceAtlasCreatesFinalSteps: true
        )

        XCTAssertFalse(receipt.canInfluenceLocalPlanning)
        XCTAssertTrue(receipt.bridgeReceipt.details.contains("can-influence-local-planning=false"))
        XCTAssertTrue(receipt.bridgeReceipt.details.contains("source-atlas-final-step-owner=true"))
    }
}
