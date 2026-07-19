@testable import Ambitions
import XCTest

final class SourceAtlasNoPrivateGraphEgressAuditTests: XCTestCase {
    func testValidPublicReferenceRecordsHaveNoPrivateGraphFindings() {
        let records = [
            SourceAtlasNoPrivateGraphEgressRecord(
                surface: .requestShape,
                identifier: "public-request",
                inspectedValue: "pack_id=public-sports manifest_version=manifest.v1 sha256=\(Self.hash)"
            ),
            SourceAtlasNoPrivateGraphEgressRecord(
                surface: .fixture,
                identifier: "public-fixture",
                inspectedValue: "official_current current reviewed public_reference"
            ),
            SourceAtlasNoPrivateGraphEgressRecord(
                surface: .inspectionDetail,
                identifier: "source-inspection-current",
                inspectedValue: SourceInspectionPresentationFixtures.defaultDetail.accessibilityValue
            ),
        ]

        XCTAssertEqual(SourceAtlasNoPrivateGraphEgressAudit.validate(records), [])
    }

    func testAuditFailsOnPrivateRuntimeEgressMarkers() {
        let forbiddenValues = [
            "goal_text=Launch my private goal",
            "goal_id=goal-123",
            "goals_payload=goal route",
            "capture_text=private capture",
            "capture_id=capture-123",
            "captures_payload=capture route",
            "schedule_assumption=Friday night",
            "schedule_capacity=low",
            "life_capital=relationship",
            "proof_id=proof-123",
            "proof_payload=photo",
            "receipt_id=receipt-123",
            "receipt_payload=receipt-123",
            "private_graph_id=node-1",
            "private_life_graph=node-2",
            "account_secret=secret",
            "user_id=user-123",
            "inferred_priority=high",
            "behavior_history=opened every night",
            "behavior_pattern=late-night recovery",
            "personalization_signal=protect mornings",
            "personalization_factor=energy",
            "final_schedule=tomorrow",
            "step_list=call person",
        ]

        let records = forbiddenValues.enumerated().map { index, value in
            SourceAtlasNoPrivateGraphEgressRecord(
                surface: .requestShape,
                identifier: "invalid-\(index)",
                inspectedValue: value
            )
        }

        let findings = SourceAtlasNoPrivateGraphEgressAudit.validate(records)
        XCTAssertGreaterThanOrEqual(findings.count, forbiddenValues.count)
        XCTAssertTrue(findings.contains { $0.forbiddenToken == "goal_text" })
        XCTAssertTrue(findings.contains { $0.forbiddenToken == "goal_id" })
        XCTAssertTrue(findings.contains { $0.forbiddenToken == "capture_text" })
        XCTAssertTrue(findings.contains { $0.forbiddenToken == "capture_id" })
        XCTAssertTrue(findings.contains { $0.forbiddenToken == "account_secret" })
        XCTAssertTrue(findings.contains { $0.forbiddenToken == "inferred_priority" })
        XCTAssertTrue(findings.contains { $0.forbiddenToken == "personalization" })
    }

    private static let hash = String(repeating: "a", count: 64)
}
