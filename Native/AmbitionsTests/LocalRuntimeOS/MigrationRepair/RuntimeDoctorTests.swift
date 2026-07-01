import XCTest
@testable import Ambitions

final class RuntimeDoctorTests: XCTestCase {
    func testSeededHistoricalLedgerCreatesBlockedUpgradeMatrixForEverySwiftDataRecord() {
        let plan = MigrationPlanner().plan(
            from: .seededHistoricalV0,
            to: .current
        )

        XCTAssertEqual(plan.mutationEntries.count, SchemaLedger.current.swiftDataEntries.count)
        XCTAssertTrue(plan.mutationEntries.allSatisfy { $0.action == .versionChange })
        XCTAssertTrue(plan.mutationEntries.allSatisfy { $0.requiredGates == MigrationPlanEntry.requiredMutationGates })
        XCTAssertTrue(plan.mutationEntries.allSatisfy { $0.executionAllowed == false })
        XCTAssertEqual(MigrationPlanValidator().validate(plan), [])
    }

    func testRecoveryAssessmentBlocksHistoricalUpgradeUntilBackupAndProofGatesExist() {
        let plan = MigrationPlanner().plan(
            from: .seededHistoricalV0,
            to: .current
        )
        let readiness = RepairPlanEngine().evaluate(
            plan: plan,
            proofs: []
        )
        let assessment = RuntimeDoctor(
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
        XCTAssertEqual(assessment.receipt.inspectionSurfaceTitle, "Search Ambitions")
        XCTAssertFalse(assessment.receipt.migrationExecutionAllowed)
        XCTAssertFalse(assessment.receipt.destructiveResetAllowed)
    }

    func testCorruptStoreSignalOpensNonDestructiveRecoveryReview() {
        let plan = MigrationPlanner().plan(
            from: .current,
            to: .current
        )
        let readiness = RepairPlanEngine().evaluate(
            plan: plan,
            proofs: []
        )
        let assessment = RuntimeDoctor(
            timestampProvider: { "2026-05-31T16:25:00Z" },
            idProvider: { "corrupt-store-test" }
        ).assess(
            plan: plan,
            readiness: readiness,
            preMigrationBackup: nil,
            recoverySignals: [
                CorruptionQuarantineSignal(
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
        XCTAssertEqual(assessment.receipt.inspectionSummary, "You / Search Ambitions can inspect this storage migration source, receipt, and reason before any recovery action.")
        XCTAssertFalse(assessment.receipt.destructiveResetAllowed)
    }

    func testCommandEventReplayDriftOpensReplayRepairReview() throws {
        let plan = MigrationPlanner().plan(
            from: .current,
            to: .current
        )
        let readiness = RepairPlanEngine().evaluate(
            plan: plan,
            proofs: []
        )
        let staleRecordCommand = runtimeDoctorCommand(id: "command.record-without-event")
        let eventOnlyCommand = runtimeDoctorCommand(id: "command.event-without-record")
        let staleRecord = AmbitionsCommandExecutionRecord(
            command: staleRecordCommand,
            result: AmbitionsCommandExecutionResult(
                status: .succeeded,
                summary: "Receipt exists without runtime event.",
                target: AmbitionsCommandTarget(captureID: "capture-stale-record")
            ),
            recordedAt: "2026-05-31T16:30:00Z"
        )
        let eventOnlyEnvelope = try RuntimeEventEnvelope.make(
            sequence: 1,
            previousChecksum: nil,
            event: RuntimeEvent.commandExecution(
                command: eventOnlyCommand,
                result: AmbitionsCommandExecutionResult(
                    status: .succeeded,
                    summary: "Runtime event lacks materialized receipt.",
                    target: AmbitionsCommandTarget(captureID: "capture-event-only")
                ),
                recordedAt: "2026-05-31T16:31:00Z",
                commandRecordID: "command.execution.command.event-without-record"
            ),
            deviceID: "runtime-doctor-replay-drift"
        )

        let assessment = RuntimeDoctor(
            timestampProvider: { "2026-05-31T16:32:00Z" },
            idProvider: { "replay-repair-test" }
        ).assess(
            plan: plan,
            readiness: readiness,
            preMigrationBackup: nil,
            commandRecords: [staleRecord],
            runtimeEvents: [eventOnlyEnvelope]
        )

        XCTAssertEqual(assessment.mode, .replayRepairRequired)
        XCTAssertTrue(assessment.canOpenRecoveryMode)
        XCTAssertFalse(assessment.canExecuteMigration)
        XCTAssertTrue(assessment.issues.contains { $0.kind == .commandRecordMissingRuntimeEvent })
        XCTAssertTrue(assessment.issues.contains { $0.kind == .runtimeEventMissingCommandRecord })
        XCTAssertFalse(assessment.issues.contains { $0.kind == .migrationReadinessBlocked })
        XCTAssertTrue(assessment.issues.allSatisfy { $0.message.contains("runtime event") || $0.message.contains("Runtime command event") })
    }
}

private extension RuntimeDoctorTests {
    func runtimeDoctorCommand(id: String) -> AmbitionsCommand {
        AmbitionsCommand(
            id: id,
            kind: .quickCapture,
            source: .today,
            payload: AmbitionsCommandPayload(rawText: "Runtime doctor drift fixture"),
            createdAt: "2026-05-31T16:30:00Z",
            actor: .user,
            sourceSurface: "today"
        )
    }
}
