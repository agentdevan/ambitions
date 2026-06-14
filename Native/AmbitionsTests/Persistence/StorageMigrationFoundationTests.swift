import XCTest
@testable import Ambitions

final class StorageMigrationFoundationTests: XCTestCase {
    func testHistoricalLedgerCreatesFailSafeReviewPipelineWithoutExecution() async {
        let adapter = makeAdapter(snapshot: Self.nonEmptySnapshot())

        let report = await adapter.prepareReview(
            from: .seededHistoricalV0,
            to: .current
        )

        XCTAssertEqual(report.schemaVersion, storageMigrationFoundationSchemaVersion)
        XCTAssertEqual(report.reviewState, .readyForUserReview)
        XCTAssertTrue(report.isFailSafeGreen)
        XCTAssertEqual(report.schemaManifest.mutationEntryCount, StorageSchemaVersionLedger.current.swiftDataEntries.count)
        XCTAssertEqual(report.backupReport?.receipt?.id, "pre-migration-backup.foundation-review-test")
        XCTAssertEqual(report.dryRunReport?.mode, .replaceLocalStore)
        XCTAssertEqual(report.dryRunReport?.wouldResetLocalStore, true)
        XCTAssertEqual(report.dryRunReport?.durableMutationAllowed, false)
        XCTAssertEqual(report.resetReview.wouldResetLocalStore, true)
        XCTAssertEqual(report.resetReview.requiresExplicitConfirmation, true)
        XCTAssertEqual(report.resetReview.destructiveResetAllowed, false)
        XCTAssertEqual(report.resetReview.sourceRecordID, "SourceRecord.storage-migration-reset.foundation-review-test")
        XCTAssertEqual(Set(report.compactionHooks.map(\.kind)), Set(StorageMigrationCompactionHookKind.allCases))
        XCTAssertTrue(report.compactionHooks.allSatisfy { $0.reviewRequired && $0.executionAllowed == false })
        XCTAssertTrue(report.compactionHooks.allSatisfy { $0.sourceRecordID.hasPrefix("SourceRecord.storage-migration-compaction.") })
        XCTAssertEqual(report.recoveryAssessment.mode, .migrationReviewRequired)
        XCTAssertEqual(report.recoveryAssessment.receipt.inspectionSurfaceTitle, "What Ambitions knows")
        XCTAssertFalse(report.migrationExecutionAllowed)
        XCTAssertFalse(report.destructiveResetAllowed)
        XCTAssertFalse(report.recoveryAssessment.receipt.migrationExecutionAllowed)
        XCTAssertFalse(report.recoveryAssessment.receipt.destructiveResetAllowed)
        XCTAssertTrue(report.requiresUserReview)
        XCTAssertTrue(report.readiness.issues.contains { issue in
            guard case let .missingProof(_, gate, expectedProofKind) = issue else {
                return false
            }
            return gate == .userReview && expectedProofKind == .userReviewApproval
        })
        XCTAssertFalse(report.systemProofs.contains { $0.kind == .userReviewApproval })
    }

    func testNoChangeLedgerSkipsBackupDryRunAndCompactionWithoutOpeningMigrationReview() async {
        let adapter = makeAdapter(snapshot: Self.emptySnapshot())

        let report = await adapter.prepareReview(
            from: .current,
            to: .current
        )

        XCTAssertEqual(report.reviewState, .noMigrationRequired)
        XCTAssertTrue(report.isFailSafeGreen)
        XCTAssertTrue(report.migrationPlan.mutationEntries.isEmpty)
        XCTAssertNil(report.backupReport)
        XCTAssertNil(report.dryRunReport)
        XCTAssertTrue(report.compactionHooks.isEmpty)
        XCTAssertEqual(report.resetReview.wouldResetLocalStore, false)
        XCTAssertEqual(report.recoveryAssessment.mode, .normal)
        XCTAssertTrue(report.recoveryAssessment.issues.isEmpty)
        XCTAssertTrue(report.readiness.issues.contains(.mutationPlanHasNoMutation))
        XCTAssertFalse(report.migrationExecutionAllowed)
        XCTAssertFalse(report.destructiveResetAllowed)
    }

    func testCorruptStoreSignalOpensNonDestructiveRecoveryReview() async {
        let adapter = makeAdapter(snapshot: Self.emptySnapshot())

        let report = await adapter.prepareReview(
            from: .current,
            to: .current,
            recoverySignals: [
                StorageRecoverySignal(
                    id: "open-did-not-complete",
                    kind: .corruptStoreOpenFailed,
                    message: "Simulated corrupt-store open failure."
                )
            ]
        )

        XCTAssertEqual(report.recoveryAssessment.mode, .corruptionReviewRequired)
        XCTAssertTrue(report.recoveryAssessment.canOpenRecoveryMode)
        XCTAssertFalse(report.recoveryAssessment.canExecuteMigration)
        XCTAssertTrue(report.recoveryAssessment.issues.contains { $0.kind == .corruptStoreSignal })
        XCTAssertTrue(report.recoveryAssessment.issues.contains { $0.kind == .destructiveResetNotAuthorized })
        XCTAssertEqual(report.recoveryAssessment.receipt.sourceRecordID, "SourceRecord.storage-recovery.foundation-review-test")
        XCTAssertEqual(report.recoveryAssessment.receipt.receiptID, "Receipt.storage-recovery.foundation-review-test")
        XCTAssertEqual(report.recoveryAssessment.receipt.replayTraceID, "ReplayTrace.storage-recovery.foundation-review-test")
        XCTAssertFalse(report.recoveryAssessment.receipt.destructiveResetAllowed)
        XCTAssertFalse(report.resetReview.destructiveResetAllowed)
    }

    func testInvariantBlockerStopsBackupAndDryRunBeforeExecutionPosture() async {
        let adapter = makeAdapter(
            snapshot: Self.nonEmptySnapshot(),
            invariantReport: StorageInvariantReport(
                issues: [
                    StorageInvariantIssue(
                        storedTypeName: "GoalRecord",
                        recordID: "goal-broken",
                        fieldName: "title",
                        kind: .emptyRequiredValue,
                        message: "Goal title is empty."
                    )
                ]
            )
        )

        let report = await adapter.prepareReview(
            from: .seededHistoricalV0,
            to: .current
        )

        XCTAssertEqual(report.reviewState, .blocked)
        XCTAssertFalse(report.isFailSafeGreen)
        XCTAssertTrue(report.blockers.contains { $0.kind == .invariantBlocker })
        XCTAssertTrue(report.blockers.contains { $0.kind == .backupBlocked })
        XCTAssertNil(report.backupReport?.receipt)
        XCTAssertNil(report.dryRunReport)
        XCTAssertFalse(report.migrationExecutionAllowed)
        XCTAssertFalse(report.destructiveResetAllowed)
        XCTAssertFalse(report.recoveryAssessment.receipt.destructiveResetAllowed)
    }

    private func makeAdapter(
        snapshot: PortableAppSnapshot,
        invariantReport: StorageInvariantReport = StorageInvariantReport(issues: [])
    ) -> StorageMigrationFoundationAdapter {
        StorageMigrationFoundationAdapter(
            snapshotService: FixedMigrationSnapshotService(snapshot: snapshot),
            invariantReportProvider: { invariantReport },
            recoveryCoordinator: StorageMigrationRecoveryCoordinator(
                timestampProvider: { "2026-06-14T09:00:00Z" },
                idProvider: { "foundation-review-test" }
            ),
            timestampProvider: { "2026-06-14T09:00:00Z" },
            idProvider: { "foundation-review-test" }
        )
    }

    private static func nonEmptySnapshot() -> PortableAppSnapshot {
        var state = AppStateSnapshot.default
        state.userDisplayName = "Migration User"
        return PortableAppSnapshot(
            metadata: PortableAppSnapshotMetadata(
                schemaVersion: .v1,
                exportedAt: "2026-06-14T09:00:00Z",
                source: "native.local.repositories",
                trustPosture: .localOnly
            ),
            goals: [],
            drafts: [],
            evidence: [],
            feedback: [],
            captures: [],
            teachingSignals: [],
            appState: state
        )
    }

    private static func emptySnapshot() -> PortableAppSnapshot {
        PortableAppSnapshot(
            metadata: PortableAppSnapshotMetadata(
                schemaVersion: .v1,
                exportedAt: "2026-06-14T09:00:00Z",
                source: "native.local.repositories",
                trustPosture: .localOnly
            ),
            goals: [],
            drafts: [],
            evidence: [],
            feedback: [],
            captures: [],
            teachingSignals: [],
            appState: .default
        )
    }
}

private struct FixedMigrationSnapshotService: PortableSnapshotServicing {
    let snapshot: PortableAppSnapshot

    func exportSnapshot() async throws -> PortableAppSnapshot {
        snapshot
    }

    func exportSnapshot(selection: PortableExportSelection) async throws -> PortableAppSnapshot {
        snapshot
    }

    func dryRunImportSnapshot(_ snapshot: PortableAppSnapshot, mode: PortableImportMode) async throws -> PortableImportDryRunReport {
        PortableImportDryRunReport(
            mode: mode,
            wouldResetLocalStore: mode == .replaceLocalStore,
            wouldImportGoalCount: snapshot.goals.count,
            wouldImportDraftCount: snapshot.drafts.count,
            wouldImportEvidenceCount: snapshot.evidence.count,
            wouldImportFeedbackCount: snapshot.feedback.count,
            wouldImportActionReceiptHistoryCount: snapshot.actionReceiptHistory.count,
            wouldImportEntityRevisionTombstoneCount: snapshot.entityRevisionTombstones.count,
            wouldImportCaptureCount: snapshot.captures.count,
            wouldImportTeachingSignalCount: snapshot.teachingSignals.count,
            wouldImportAppStateCount: snapshot.appState == .default ? 0 : 1,
            conflicts: [],
            warnings: []
        )
    }

    func manualMergePlan(for snapshot: PortableAppSnapshot) async throws -> PortableManualMergePlan {
        let dryRun = try await dryRunImportSnapshot(snapshot, mode: .mergeWithConflictReport)
        return PortableManualMergePlan(dryRunReport: dryRun)
    }

    func importSnapshot(_ snapshot: PortableAppSnapshot, mode: PortableImportMode) async throws -> PortableImportReport {
        throw MigrationFoundationFixtureError.importMustRemainUnavailable
    }
}

private enum MigrationFoundationFixtureError: Error {
    case importMustRemainUnavailable
}
