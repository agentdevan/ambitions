import XCTest
@testable import Ambitions

final class PortableRestoreRollbackTests: XCTestCase {
    func testRestoreRollbackRestoresBackupWhenImportThrowsAfterMutation() async throws {
        let backup = snapshot(displayName: "Backup User")
        let incoming = snapshot(displayName: "Incoming Fails")
        let damaged = snapshot(displayName: "Damaged Partial Import")
        let scripted = ScriptedRollbackSnapshotService(
            current: backup,
            failingImportDisplayName: "Incoming Fails",
            damagedSnapshot: damaged
        )
        let service = PortableRestoreRollbackService(snapshotService: scripted)

        let report = await service.restoreSnapshotWithRollback(
            incoming,
            mode: .replaceLocalStore,
            rollbackPackage: backup
        )
        let currentDisplayName = await scripted.currentDisplayName()
        let importCallCount = await scripted.importCallCount()

        XCTAssertEqual(report.status, .rollbackRestoredBackup)
        XCTAssertEqual(report.requestedMode, .replaceLocalStore)
        XCTAssertTrue(report.rollbackAttempted)
        XCTAssertFalse(report.durableMutationAllowed)
        XCTAssertEqual(report.diagnosticKind, .rollbackRestored)
        XCTAssertEqual(report.rollbackReport?.importedAppStateCount, 1)
        XCTAssertEqual(currentDisplayName, "Backup User")
        XCTAssertEqual(importCallCount, 2)
        XCTAssertTrue(report.noClaimBoundary.contains("not a migration-safe"))
    }

    func testRestoreRollbackBlocksBeforeImportWhenIncomingDryRunFails() async throws {
        let backup = snapshot(displayName: "Backup User")
        let incoming = snapshot(displayName: "Incoming Dry Run Fails")
        let scripted = ScriptedRollbackSnapshotService(
            current: backup,
            dryRunFailureDisplayName: "Incoming Dry Run Fails"
        )
        let service = PortableRestoreRollbackService(snapshotService: scripted)

        let report = await service.restoreSnapshotWithRollback(
            incoming,
            mode: .replaceLocalStore,
            rollbackPackage: backup
        )
        let currentDisplayName = await scripted.currentDisplayName()
        let importCallCount = await scripted.importCallCount()

        XCTAssertEqual(report.status, .blockedBeforeImport)
        XCTAssertEqual(report.diagnosticKind, .blockedBeforeImport)
        XCTAssertFalse(report.rollbackAttempted)
        XCTAssertNil(report.rollbackReport)
        XCTAssertEqual(currentDisplayName, "Backup User")
        XCTAssertEqual(importCallCount, 0)
        XCTAssertTrue(report.importErrorMessage?.contains("dry run failed") == true)
    }

    func testRestoreRollbackReportsRollbackFailedWhenRollbackImportAlsoThrows() async throws {
        let backup = snapshot(displayName: "Rollback Package Fails")
        let incoming = snapshot(displayName: "Incoming Fails")
        let damaged = snapshot(displayName: "Damaged Partial Import")
        let scripted = ScriptedRollbackSnapshotService(
            current: backup,
            failingImportDisplayName: "Incoming Fails",
            rollbackFailureDisplayName: "Rollback Package Fails",
            damagedSnapshot: damaged
        )
        let service = PortableRestoreRollbackService(snapshotService: scripted)

        let report = await service.restoreSnapshotWithRollback(
            incoming,
            mode: .replaceLocalStore,
            rollbackPackage: backup
        )
        let currentDisplayName = await scripted.currentDisplayName()
        let importCallCount = await scripted.importCallCount()

        XCTAssertEqual(report.status, .rollbackFailed)
        XCTAssertEqual(report.diagnosticKind, .rollbackFailed)
        XCTAssertTrue(report.rollbackAttempted)
        XCTAssertFalse(report.durableMutationAllowed)
        XCTAssertNil(report.rollbackReport)
        XCTAssertNotNil(report.rollbackErrorMessage)
        XCTAssertEqual(currentDisplayName, "Damaged Partial Import")
        XCTAssertEqual(importCallCount, 2)
    }

    func testRestoreRollbackWrapperCanCompleteRealReplaceImportWithoutRollbackAttempt() async throws {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        let repositories = AppRepositories(
            goals: SwiftDataGoalRepository(store: store),
            drafts: SwiftDataGoalDraftRepository(store: store),
            evidence: SwiftDataProgressEvidenceRepository(store: store),
            feedback: SwiftDataFeedbackEventRepository(store: store),
            captures: SwiftDataCaptureRepository(store: store),
            teaching: SwiftDataGoalTeachingSignalRepository(store: store),
            appState: SwiftDataAppStateRepository(store: store)
        )
        var localState = AppStateSnapshot.default
        localState.userDisplayName = "Before Restore"
        var incomingState = AppStateSnapshot.default
        incomingState.userDisplayName = "After Restore"
        try await repositories.appState.saveState(localState)

        let snapshotService = PortableSnapshotService(
            repositories: repositories,
            resetStore: { try await store.resetAllData() }
        )
        let service = PortableRestoreRollbackService(snapshotService: snapshotService)
        let report = await service.restoreSnapshotWithRollback(
            snapshot(displayName: incomingState.userDisplayName),
            mode: .replaceLocalStore
        )
        let restoredState = try await repositories.appState.loadState()

        XCTAssertEqual(report.status, .importSucceeded)
        XCTAssertEqual(report.diagnosticKind, .importSucceeded)
        XCTAssertFalse(report.rollbackAttempted)
        XCTAssertEqual(report.importReport?.importedAppStateCount, 1)
        XCTAssertEqual(report.rollbackDryRunReport?.wouldResetLocalStore, true)
        XCTAssertEqual(restoredState.userDisplayName, "After Restore")
    }

    func testRestoreRollbackReportDecodesOlderPayloadWithoutDiagnosticKind() throws {
        let payload = """
        {
          "status": "rollback_restored_backup",
          "requestedMode": "replace_local_store",
          "rollbackAttempted": true,
          "durableMutationAllowed": false,
          "noClaimBoundary": "Restore rollback is local backup recovery proof only. It is not a migration-safe or data-loss-proof claim."
        }
        """.data(using: .utf8)!

        let report = try JSONDecoder().decode(PortableRestoreRollbackReport.self, from: payload)

        XCTAssertEqual(report.status, .rollbackRestoredBackup)
        XCTAssertEqual(report.diagnosticKind, .rollbackRestored)
        XCTAssertTrue(report.rollbackAttempted)
        XCTAssertFalse(report.durableMutationAllowed)
    }
}

private enum ScriptedRollbackError: Error, CustomStringConvertible {
    case dryRunFailed
    case importFailed

    var description: String {
        switch self {
        case .dryRunFailed:
            return "scripted dry run failed"
        case .importFailed:
            return "scripted import failed"
        }
    }
}

private actor ScriptedRollbackSnapshotService: PortableSnapshotServicing {
    private var current: PortableAppSnapshot
    private let dryRunFailureDisplayName: String?
    private let failingImportDisplayName: String?
    private let rollbackFailureDisplayName: String?
    private let damagedSnapshot: PortableAppSnapshot?
    private var imports = 0

    init(
        current: PortableAppSnapshot,
        dryRunFailureDisplayName: String? = nil,
        failingImportDisplayName: String? = nil,
        rollbackFailureDisplayName: String? = nil,
        damagedSnapshot: PortableAppSnapshot? = nil
    ) {
        self.current = current
        self.dryRunFailureDisplayName = dryRunFailureDisplayName
        self.failingImportDisplayName = failingImportDisplayName
        self.rollbackFailureDisplayName = rollbackFailureDisplayName
        self.damagedSnapshot = damagedSnapshot
    }

    func exportSnapshot() async throws -> PortableAppSnapshot {
        current
    }

    func exportSnapshot(selection: PortableExportSelection) async throws -> PortableAppSnapshot {
        current
    }

    func dryRunImportSnapshot(_ snapshot: PortableAppSnapshot, mode: PortableImportMode) async throws -> PortableImportDryRunReport {
        if snapshot.appState.userDisplayName == dryRunFailureDisplayName {
            throw ScriptedRollbackError.dryRunFailed
        }
        return PortableImportDryRunReport(
            mode: mode,
            wouldResetLocalStore: mode == .replaceLocalStore,
            wouldImportGoalCount: snapshot.goals.count,
            wouldImportDraftCount: snapshot.drafts.count,
            wouldImportEvidenceCount: snapshot.evidence.count,
            wouldImportFeedbackCount: snapshot.feedback.count,
            wouldImportCaptureCount: snapshot.captures.count,
            wouldImportTeachingSignalCount: snapshot.teachingSignals.count,
            wouldImportAppStateCount: 1,
            conflicts: [],
            warnings: []
        )
    }

    func manualMergePlan(for snapshot: PortableAppSnapshot) async throws -> PortableManualMergePlan {
        let dryRun = try await dryRunImportSnapshot(snapshot, mode: .mergeWithConflictReport)
        return PortableManualMergePlan(dryRunReport: dryRun)
    }

    func importSnapshot(_ snapshot: PortableAppSnapshot, mode: PortableImportMode) async throws -> PortableImportReport {
        imports += 1
        if snapshot.appState.userDisplayName == failingImportDisplayName
            || snapshot.appState.userDisplayName == rollbackFailureDisplayName {
            if let damagedSnapshot {
                current = damagedSnapshot
            }
            throw ScriptedRollbackError.importFailed
        }

        current = snapshot
        return PortableImportReport(
            mode: mode,
            importedGoalCount: snapshot.goals.count,
            importedDraftCount: snapshot.drafts.count,
            importedEvidenceCount: snapshot.evidence.count,
            importedFeedbackCount: snapshot.feedback.count,
            importedCaptureCount: snapshot.captures.count,
            importedTeachingSignalCount: snapshot.teachingSignals.count,
            importedAppStateCount: 1,
            conflicts: [],
            warnings: []
        )
    }

    func currentDisplayName() -> String {
        current.appState.userDisplayName
    }

    func importCallCount() -> Int {
        imports
    }
}

private func snapshot(displayName: String) -> PortableAppSnapshot {
    var appState = AppStateSnapshot.default
    appState.userDisplayName = displayName
    return PortableAppSnapshot(
        metadata: PortableAppSnapshotMetadata(
            schemaVersion: .v1,
            exportedAt: "2026-05-08T23:00:00Z",
            source: "native.local.repositories",
            trustPosture: .localOnly
        ),
        goals: [],
        drafts: [],
        evidence: [],
        feedback: [],
        captures: [],
        teachingSignals: [],
        appState: appState
    )
}
