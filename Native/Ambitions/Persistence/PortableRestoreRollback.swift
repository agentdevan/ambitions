import Foundation

enum PortableRestoreRollbackStatus: String, Codable, Sendable, Equatable {
    case importSucceeded = "import_succeeded"
    case blockedBeforeImport = "blocked_before_import"
    case rollbackRestoredBackup = "rollback_restored_backup"
    case rollbackFailed = "rollback_failed"
}

struct PortableRestoreRollbackReport: Codable, Sendable, Equatable {
    let status: PortableRestoreRollbackStatus
    let requestedMode: PortableImportMode
    let incomingDryRunReport: PortableImportDryRunReport?
    let rollbackDryRunReport: PortableImportDryRunReport?
    let importReport: PortableImportReport?
    let rollbackReport: PortableImportReport?
    let importErrorMessage: String?
    let rollbackErrorMessage: String?
    let rollbackAttempted: Bool
    let durableMutationAllowed: Bool
    let noClaimBoundary: String

    init(
        status: PortableRestoreRollbackStatus,
        requestedMode: PortableImportMode,
        incomingDryRunReport: PortableImportDryRunReport?,
        rollbackDryRunReport: PortableImportDryRunReport?,
        importReport: PortableImportReport?,
        rollbackReport: PortableImportReport?,
        importErrorMessage: String?,
        rollbackErrorMessage: String?,
        rollbackAttempted: Bool,
        durableMutationAllowed: Bool = false,
        noClaimBoundary: String = "Restore rollback is local backup recovery proof only. It is not a migration-safe or data-loss-proof claim."
    ) {
        self.status = status
        self.requestedMode = requestedMode
        self.incomingDryRunReport = incomingDryRunReport
        self.rollbackDryRunReport = rollbackDryRunReport
        self.importReport = importReport
        self.rollbackReport = rollbackReport
        self.importErrorMessage = importErrorMessage
        self.rollbackErrorMessage = rollbackErrorMessage
        self.rollbackAttempted = rollbackAttempted
        self.durableMutationAllowed = durableMutationAllowed
        self.noClaimBoundary = noClaimBoundary
    }
}

struct PortableRestoreRollbackService: Sendable {
    let snapshotService: any PortableSnapshotServicing

    init(snapshotService: any PortableSnapshotServicing) {
        self.snapshotService = snapshotService
    }

    func restoreSnapshotWithRollback(
        _ snapshot: PortableAppSnapshot,
        mode: PortableImportMode,
        rollbackPackage providedRollbackPackage: PortableAppSnapshot? = nil
    ) async -> PortableRestoreRollbackReport {
        let incomingDryRun: PortableImportDryRunReport
        do {
            incomingDryRun = try await snapshotService.dryRunImportSnapshot(snapshot, mode: mode)
        } catch {
            return PortableRestoreRollbackReport(
                status: .blockedBeforeImport,
                requestedMode: mode,
                incomingDryRunReport: nil,
                rollbackDryRunReport: nil,
                importReport: nil,
                rollbackReport: nil,
                importErrorMessage: "Incoming package dry run failed before import: \(error)",
                rollbackErrorMessage: nil,
                rollbackAttempted: false
            )
        }

        let rollbackPackage: PortableAppSnapshot
        do {
            if let providedRollbackPackage {
                rollbackPackage = providedRollbackPackage
            } else {
                rollbackPackage = try await snapshotService.exportSnapshot(selection: .all)
            }
        } catch {
            return PortableRestoreRollbackReport(
                status: .blockedBeforeImport,
                requestedMode: mode,
                incomingDryRunReport: incomingDryRun,
                rollbackDryRunReport: nil,
                importReport: nil,
                rollbackReport: nil,
                importErrorMessage: "Could not prepare rollback package before import: \(error)",
                rollbackErrorMessage: nil,
                rollbackAttempted: false
            )
        }

        let rollbackDryRun: PortableImportDryRunReport
        do {
            rollbackDryRun = try await snapshotService.dryRunImportSnapshot(rollbackPackage, mode: .replaceLocalStore)
        } catch {
            return PortableRestoreRollbackReport(
                status: .blockedBeforeImport,
                requestedMode: mode,
                incomingDryRunReport: incomingDryRun,
                rollbackDryRunReport: nil,
                importReport: nil,
                rollbackReport: nil,
                importErrorMessage: "Rollback package dry run failed before import: \(error)",
                rollbackErrorMessage: nil,
                rollbackAttempted: false
            )
        }

        do {
            let importReport = try await snapshotService.importSnapshot(snapshot, mode: mode)
            return PortableRestoreRollbackReport(
                status: .importSucceeded,
                requestedMode: mode,
                incomingDryRunReport: incomingDryRun,
                rollbackDryRunReport: rollbackDryRun,
                importReport: importReport,
                rollbackReport: nil,
                importErrorMessage: nil,
                rollbackErrorMessage: nil,
                rollbackAttempted: false
            )
        } catch {
            let importErrorMessage = "\(error)"
            do {
                let rollbackReport = try await snapshotService.importSnapshot(rollbackPackage, mode: .replaceLocalStore)
                return PortableRestoreRollbackReport(
                    status: .rollbackRestoredBackup,
                    requestedMode: mode,
                    incomingDryRunReport: incomingDryRun,
                    rollbackDryRunReport: rollbackDryRun,
                    importReport: nil,
                    rollbackReport: rollbackReport,
                    importErrorMessage: importErrorMessage,
                    rollbackErrorMessage: nil,
                    rollbackAttempted: true
                )
            } catch {
                return PortableRestoreRollbackReport(
                    status: .rollbackFailed,
                    requestedMode: mode,
                    incomingDryRunReport: incomingDryRun,
                    rollbackDryRunReport: rollbackDryRun,
                    importReport: nil,
                    rollbackReport: nil,
                    importErrorMessage: importErrorMessage,
                    rollbackErrorMessage: "\(error)",
                    rollbackAttempted: true
                )
            }
        }
    }
}
