import XCTest
@testable import Ambitions

final class StorageMigrationRecoveryTests: XCTestCase {
    func testSeededHistoricalLedgerCreatesBlockedUpgradeMatrixForEverySwiftDataRecord() {
        let plan = StorageMigrationPlanScaffold().plan(
            from: .seededHistoricalV0,
            to: .current
        )

        XCTAssertEqual(plan.mutationEntries.count, StorageSchemaVersionLedger.current.swiftDataEntries.count)
        XCTAssertTrue(plan.mutationEntries.allSatisfy { $0.action == .versionChange })
        XCTAssertTrue(plan.mutationEntries.allSatisfy { $0.requiredGates == StorageMigrationPlanEntry.requiredMutationGates })
        XCTAssertTrue(plan.mutationEntries.allSatisfy { $0.executionAllowed == false })
        XCTAssertEqual(StorageMigrationPlanValidator().validate(plan), [])
    }

    func testRecoveryAssessmentBlocksHistoricalUpgradeUntilBackupAndProofGatesExist() {
        let plan = StorageMigrationPlanScaffold().plan(
            from: .seededHistoricalV0,
            to: .current
        )
        let readiness = StorageMigrationExecutionReadinessEvaluator().evaluate(
            plan: plan,
            proofs: []
        )
        let assessment = StorageMigrationRecoveryCoordinator(
            timestampProvider: { "2026-05-31T16:20:00Z" },
            idProvider: { "storage-recovery-test" }
        ).assess(
            plan: plan,
            readiness: readiness,
            preMigrationBackup: nil
        )

        XCTAssertEqual(assessment.mode, .migrationReviewRequired)
        XCTAssertTrue(assessment.canOpenRecoveryMode)
        XCTAssertFalse(assessment.canExecuteMigration)
        XCTAssertTrue(assessment.issues.contains { $0.kind == .migrationReadinessBlocked })
        XCTAssertTrue(assessment.issues.contains { $0.kind == .missingPreMigrationBackupReceipt })
        XCTAssertEqual(assessment.receipt.sourceRecordID, "SourceRecord.storage-recovery.storage-recovery-test")
        XCTAssertEqual(assessment.receipt.receiptID, "Receipt.storage-recovery.storage-recovery-test")
        XCTAssertEqual(assessment.receipt.replayTraceID, "ReplayTrace.storage-recovery.storage-recovery-test")
        XCTAssertEqual(assessment.receipt.inspectionSurfaceTitle, "What Ambitions knows")
        XCTAssertFalse(assessment.receipt.migrationExecutionAllowed)
        XCTAssertFalse(assessment.receipt.destructiveResetAllowed)
    }

    func testCorruptStoreSignalOpensNonDestructiveRecoveryReview() {
        let plan = StorageMigrationPlanScaffold().plan(
            from: .current,
            to: .current
        )
        let readiness = StorageMigrationExecutionReadinessEvaluator().evaluate(
            plan: plan,
            proofs: []
        )
        let assessment = StorageMigrationRecoveryCoordinator(
            timestampProvider: { "2026-05-31T16:25:00Z" },
            idProvider: { "corrupt-store-test" }
        ).assess(
            plan: plan,
            readiness: readiness,
            preMigrationBackup: nil,
            recoverySignals: [
                StorageRecoverySignal(
                    id: "open",
                    kind: .corruptStoreOpenFailed,
                    message: "Simulated corrupt-store open failure."
                )
            ]
        )

        XCTAssertEqual(assessment.mode, .corruptionReviewRequired)
        XCTAssertTrue(assessment.canOpenRecoveryMode)
        XCTAssertFalse(assessment.canExecuteMigration)
        XCTAssertTrue(assessment.issues.contains { $0.kind == .corruptStoreSignal })
        XCTAssertTrue(assessment.issues.contains { $0.kind == .destructiveResetNotAuthorized })
        XCTAssertEqual(assessment.receipt.inspectionSummary, "You / What Ambitions knows can inspect this storage migration source, receipt, and reason before any recovery action.")
        XCTAssertFalse(assessment.receipt.destructiveResetAllowed)
    }
}
