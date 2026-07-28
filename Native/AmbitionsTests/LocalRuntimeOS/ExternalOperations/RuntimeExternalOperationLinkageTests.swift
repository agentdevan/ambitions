@testable import Ambitions
import XCTest

final class RuntimeExternalOperationLinkageTests: XCTestCase {
    func testT09CommitUsesV7AuthorityAndT12CompensationRelationIsDurable() {
        XCTAssertEqual(CanonicalRuntimeCommitSchemaPlan.currentWritableSchemaVersion, 8)
        let sql = CanonicalRuntimeExternalOperationSchemaPlan.fullGenerationStatements
            .joined(separator: "\n")
        XCTAssertTrue(sql.contains("FOREIGN KEY (command_id) REFERENCES runtime_command_idempotency(command_id)"))
        XCTAssertTrue(sql.contains("FOREIGN KEY (receipt_id) REFERENCES runtime_commit_receipts(receipt_id)"))
        XCTAssertTrue(sql.contains("FOREIGN KEY (compensation_plan_id) REFERENCES runtime_compensation_plans(plan_id)"))
        XCTAssertTrue(sql.contains("runtime_compensation_plan_external_operations"))
        XCTAssertTrue(sql.contains("external compensation relation mismatch"))
        XCTAssertTrue(sql.contains("UNIQUE (source_operation_id)"))
    }

    func testNormalizedGraphOwnsCreationCurrentHistoryAttemptsOutcomesAndInvalidations() {
        XCTAssertEqual(CanonicalRuntimeExternalOperationSchemaPlan.tables, Set([
            "runtime_external_operation_creations",
            "runtime_external_operation_targets",
            "runtime_external_operation_current",
            "runtime_external_operation_history",
            "runtime_external_operation_attempt_starts",
            "runtime_external_operation_attempt_outcomes",
            "runtime_external_operation_transition_invalidations",
        ]))
    }

    func testFailedCompensatingRemovalCannotOfferASecondSuccessor() {
        let failed = RuntimeCommittedReceiptAuthority.CompensatingRemovalState.failed
        XCTAssertFalse(failed.permitsSuccessorCreation)
        XCTAssertTrue(failed.requiresOperatorResolution)

        let missing = RuntimeCommittedReceiptAuthority.CompensatingRemovalState.missing
        XCTAssertTrue(missing.permitsSuccessorCreation)
        XCTAssertFalse(missing.requiresOperatorResolution)
    }
}
