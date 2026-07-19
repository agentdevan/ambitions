import Foundation

enum RestoreRollbackStatus: String, Codable, Sendable, Equatable {
    case importSucceeded = "import_succeeded"
    case blockedBeforeImport = "blocked_before_import"
    case rollbackRestoredBackup = "rollback_restored_backup"
    case rollbackFailed = "rollback_failed"
}

enum RestoreRollbackDiagnosticKind: String, Codable, Sendable, Equatable, Hashable {
    case importSucceeded = "import_succeeded"
    case blockedBeforeImport = "blocked_before_import"
    case rollbackRestored = "rollback_restored"
    case rollbackFailed = "rollback_failed"
}

struct RestoreRollbackReport: Codable, Sendable, Equatable {
    let status: RestoreRollbackStatus
    let diagnosticKind: RestoreRollbackDiagnosticKind
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

    private enum CodingKeys: String, CodingKey {
        case status
        case diagnosticKind
        case requestedMode
        case incomingDryRunReport
        case rollbackDryRunReport
        case importReport
        case rollbackReport
        case importErrorMessage
        case rollbackErrorMessage
        case rollbackAttempted
        case durableMutationAllowed
        case noClaimBoundary
    }

    init(
        status: RestoreRollbackStatus,
        diagnosticKind: RestoreRollbackDiagnosticKind? = nil,
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
        self.diagnosticKind = diagnosticKind ?? Self.diagnosticKind(for: status)
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

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let status = try container.decode(RestoreRollbackStatus.self, forKey: .status)
        self.status = status
        self.diagnosticKind = try container.decodeIfPresent(
            RestoreRollbackDiagnosticKind.self,
            forKey: .diagnosticKind
        ) ?? Self.diagnosticKind(for: status)
        self.requestedMode = try container.decode(PortableImportMode.self, forKey: .requestedMode)
        self.incomingDryRunReport = try container.decodeIfPresent(PortableImportDryRunReport.self, forKey: .incomingDryRunReport)
        self.rollbackDryRunReport = try container.decodeIfPresent(PortableImportDryRunReport.self, forKey: .rollbackDryRunReport)
        self.importReport = try container.decodeIfPresent(PortableImportReport.self, forKey: .importReport)
        self.rollbackReport = try container.decodeIfPresent(PortableImportReport.self, forKey: .rollbackReport)
        self.importErrorMessage = try container.decodeIfPresent(String.self, forKey: .importErrorMessage)
        self.rollbackErrorMessage = try container.decodeIfPresent(String.self, forKey: .rollbackErrorMessage)
        self.rollbackAttempted = try container.decode(Bool.self, forKey: .rollbackAttempted)
        self.durableMutationAllowed = try container.decode(Bool.self, forKey: .durableMutationAllowed)
        self.noClaimBoundary = try container.decode(String.self, forKey: .noClaimBoundary)
    }

    private static func diagnosticKind(for status: RestoreRollbackStatus) -> RestoreRollbackDiagnosticKind {
        switch status {
        case .importSucceeded:
            return .importSucceeded
        case .blockedBeforeImport:
            return .blockedBeforeImport
        case .rollbackRestoredBackup:
            return .rollbackRestored
        case .rollbackFailed:
            return .rollbackFailed
        }
    }
}

struct RestoreRollback: Sendable {
    let snapshotService: any PortableSnapshotServicing

    init(snapshotService: any PortableSnapshotServicing) {
        self.snapshotService = snapshotService
    }

    func restoreSnapshotWithRollback(
        _ snapshot: PortableAppSnapshot,
        mode: PortableImportMode,
        rollbackPackage providedRollbackPackage: PortableAppSnapshot? = nil
    ) async -> RestoreRollbackReport {
        let incomingDryRun: PortableImportDryRunReport
        do {
            incomingDryRun = try await snapshotService.dryRunImportSnapshot(snapshot, mode: mode)
        } catch {
            return RestoreRollbackReport(
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
            return RestoreRollbackReport(
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
            return RestoreRollbackReport(
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
            return RestoreRollbackReport(
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
                return RestoreRollbackReport(
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
                return RestoreRollbackReport(
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
