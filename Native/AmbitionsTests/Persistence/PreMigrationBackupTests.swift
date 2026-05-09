import XCTest
@testable import Ambitions

final class PreMigrationBackupTests: XCTestCase {
    func testPrepareBackupCreatesReceiptWithoutAuthorizingMigrationExecution() async throws {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        let repositories = makeRepositories(store: store)
        var state = AppStateSnapshot.default
        state.userDisplayName = "Backup User"
        try await repositories.appState.saveState(state)

        let snapshotService = PortableSnapshotService(
            repositories: repositories,
            resetStore: { try await store.resetAllData() }
        )
        let backupService = PreMigrationBackupService(
            snapshotService: snapshotService,
            invariantReportProvider: { try await StorageInvariantChecker().check(store: store) },
            timestampProvider: { "2026-05-08T18:00:00Z" },
            idProvider: { "backup.receipt.test" }
        )
        let plan = StorageMigrationPlanScaffold().plan(
            from: .current,
            to: ledgerWithChangedVersion()
        )

        let report = try await backupService.prepareBackup(for: plan)

        XCTAssertTrue(report.isGreen)
        XCTAssertTrue(report.blockers.isEmpty)
        XCTAssertEqual(report.receipt?.id, "backup.receipt.test")
        XCTAssertEqual(report.receipt?.createdAt, "2026-05-08T18:00:00Z")
        XCTAssertEqual(report.receipt?.snapshotSchemaVersion, PortableSnapshotSchemaVersion.v1.rawValue)
        XCTAssertEqual(report.receipt?.backedUpAppStateCount, 1)
        XCTAssertEqual(report.receipt?.migrationMutationEntryCount, 1)
        XCTAssertEqual(report.receipt?.backupRestoresGateSatisfied, true)
        XCTAssertEqual(report.receipt?.migrationExecutionAllowed, false)
        XCTAssertEqual(report.migrationExecutionAllowed, false)
        XCTAssertEqual(report.backupPackage?.appState.userDisplayName, "Backup User")
    }

    func testBackupGateBlocksWhenStorageInvariantReportHasBlockers() async throws {
        let snapshotService = FixedSnapshotService(snapshot: nonEmptySnapshot())
        let backupService = PreMigrationBackupService(
            snapshotService: snapshotService,
            invariantReportProvider: {
                StorageInvariantReport(
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
            }
        )

        let report = try await backupService.prepareBackup(
            for: StorageMigrationPlanScaffold().plan(from: .current, to: ledgerWithChangedVersion())
        )

        XCTAssertFalse(report.isGreen)
        XCTAssertNil(report.receipt)
        XCTAssertEqual(report.blockers.map(\.kind), [.invariantBlocker])
        XCTAssertEqual(report.migrationExecutionAllowed, false)
    }

    func testBackupGateBlocksMalformedMutationPlanAndDoesNotCountEmptyPackages() async throws {
        let snapshotService = FixedSnapshotService(snapshot: emptySnapshot())
        let backupService = PreMigrationBackupService(
            snapshotService: snapshotService,
            invariantReportProvider: { StorageInvariantReport(issues: []) }
        )
        let plan = StorageMigrationPlan(
            sourceLedgerSchemaVersion: storageSchemaVersionLedgerSchemaVersion,
            targetLedgerSchemaVersion: storageSchemaVersionLedgerSchemaVersion,
            entries: [
                StorageMigrationPlanEntry(
                    id: "migration.version_change.swiftdata.goal_record",
                    sourceEntryID: "swiftdata.goal_record",
                    targetEntryID: "swiftdata.goal_record",
                    storedTypeName: "GoalRecord",
                    action: .versionChange,
                    fromVersion: goalEngineSchemaVersion,
                    toVersion: "\(goalEngineSchemaVersion).next",
                    requiredGates: [.storageInvariantCheck],
                    executionAllowed: true,
                    notes: "Malformed test plan."
                )
            ],
            executionAllowed: true
        )

        let report = try await backupService.prepareBackup(for: plan)
        let blockerKinds = Set(report.blockers.map(\.kind))

        XCTAssertFalse(report.isGreen)
        XCTAssertNil(report.receipt)
        XCTAssertTrue(blockerKinds.contains(.invalidMigrationPlan))
        XCTAssertTrue(blockerKinds.contains(.mutationMissingBackupGate))
        XCTAssertTrue(blockerKinds.contains(.migrationExecutionAlreadyAllowed))
        XCTAssertTrue(blockerKinds.contains(.emptyBackupPackage))
        XCTAssertEqual(report.migrationExecutionAllowed, false)
    }
}

private struct FixedSnapshotService: PortableSnapshotServicing {
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
            wouldImportGoalCount: 0,
            wouldImportDraftCount: 0,
            wouldImportEvidenceCount: 0,
            wouldImportFeedbackCount: 0,
            wouldImportCaptureCount: 0,
            wouldImportAppStateCount: 0,
            conflicts: [],
            warnings: []
        )
    }

    func importSnapshot(_ snapshot: PortableAppSnapshot, mode: PortableImportMode) async throws -> PortableImportReport {
        PortableImportReport(
            mode: mode,
            importedGoalCount: 0,
            importedDraftCount: 0,
            importedEvidenceCount: 0,
            importedFeedbackCount: 0,
            importedCaptureCount: 0,
            importedAppStateCount: 0,
            conflicts: [],
            warnings: []
        )
    }
}

private extension PreMigrationBackupTests {
    func makeRepositories(store: AmbitionsPersistenceStore) -> AppRepositories {
        AppRepositories(
            goals: SwiftDataGoalRepository(store: store),
            drafts: SwiftDataGoalDraftRepository(store: store),
            evidence: SwiftDataProgressEvidenceRepository(store: store),
            feedback: SwiftDataFeedbackEventRepository(store: store),
            captures: SwiftDataCaptureRepository(store: store),
            teaching: SwiftDataGoalTeachingSignalRepository(store: store),
            appState: SwiftDataAppStateRepository(store: store)
        )
    }
}

private func ledgerWithChangedVersion() -> StorageSchemaVersionLedger {
    StorageSchemaVersionLedger(
        entries: StorageSchemaVersionLedger.current.entries.map { entry in
            guard entry.id == "swiftdata.goal_record" else {
                return entry
            }
            return StorageSchemaVersionEntry(
                id: entry.id,
                family: entry.family,
                owner: entry.owner,
                storedTypeName: entry.storedTypeName,
                currentVersion: "\(entry.currentVersion).next",
                versionEvidence: entry.versionEvidence,
                migrationReadiness: entry.migrationReadiness,
                rollbackRequirement: entry.rollbackRequirement,
                notes: entry.notes
            )
        }
    )
}

private func nonEmptySnapshot() -> PortableAppSnapshot {
    var state = AppStateSnapshot.default
    state.userDisplayName = "Backup User"
    return PortableAppSnapshot(
        metadata: PortableAppSnapshotMetadata(
            schemaVersion: .v1,
            exportedAt: "2026-05-08T18:00:00Z",
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

private func emptySnapshot() -> PortableAppSnapshot {
    PortableAppSnapshot(
        metadata: PortableAppSnapshotMetadata(
            schemaVersion: .v1,
            exportedAt: "2026-05-08T18:00:00Z",
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
