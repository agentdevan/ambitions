import Foundation

enum RuntimeDoctorHealthDomain: String, CaseIterable, Codable, Sendable, Equatable, Hashable {
    case commandJournal = "command_journal"
    case eventStore = "event_store"
    case projectionStore = "projection_store"
    case searchIndex = "search_index"
    case blobVault = "blob_vault"
    case sideEffectOutbox = "side_effect_outbox"
    case syncContinuity = "sync_continuity"
    case privacyBoundary = "privacy_boundary"
    case migrationState = "migration_state"
    case storageTier = "storage_tier"

    var userFacingName: String {
        switch self {
        case .commandJournal:
            return "saved action log"
        case .eventStore:
            return "local history"
        case .projectionStore:
            return "local view cache"
        case .searchIndex:
            return "local search"
        case .blobVault:
            return "private attachments"
        case .sideEffectOutbox:
            return "external handoff queue"
        case .syncContinuity:
            return "continuity metadata"
        case .privacyBoundary:
            return "privacy boundary"
        case .migrationState:
            return "storage migration state"
        case .storageTier:
            return "local storage"
        }
    }
}

enum RuntimeDoctorDriftKind: String, Codable, Sendable, Equatable, Hashable {
    case missingHealthReader = "missing_health_reader"
    case commandEventReconciliationDrift = "command_event_reconciliation_drift"
    case eventStoreCursorDrift = "event_store_cursor_drift"
    case projectionStoreChecksumDrift = "projection_store_checksum_drift"
    case searchIndexDrift = "search_index_drift"
    case blobVaultCorruption = "blob_vault_corruption"
    case sideEffectOutboxDrift = "side_effect_outbox_drift"
    case syncContinuityDrift = "sync_continuity_drift"
    case privacyRedactionDrift = "privacy_redaction_drift"
    case migrationStateDrift = "migration_state_drift"
    case storageTierDrift = "storage_tier_drift"
}

enum RuntimeDoctorRepairActionKind: String, CaseIterable, Codable, Sendable, Equatable, Hashable {
    case commandEventReconciliation = "command_event_reconciliation"
    case projectionRebuild = "projection_rebuild"
    case searchRebuild = "search_rebuild"
    case corruptBlobQuarantine = "corrupt_blob_quarantine"
    case sideEffectOutboxReconcile = "side_effect_outbox_reconcile"
    case syncContinuityHold = "sync_continuity_hold"
    case privacyRedactionReview = "privacy_redaction_review"
    case dryMigration = "dry_migration"
    case preMigrationBackup = "pre_migration_backup"
    case restoreBackup = "restore_backup"
    case restoreRollback = "restore_rollback"
    case storageInvariantCheck = "storage_invariant_check"
}

enum RuntimeDoctorRepairProofStage: String, Codable, Sendable, Equatable, Hashable {
    case before
    case expectedAfter = "expected_after"
}

struct RuntimeDoctorDriftSignal: Identifiable, Codable, Sendable, Equatable, Hashable {
    let id: String
    let domain: RuntimeDoctorHealthDomain
    let kind: RuntimeDoctorDriftKind
    let severity: LocalRuntimeDiagnosticSeverity
    let redactedSummary: String
    let redactedDetail: String
    let evidenceIDs: [String]
    let localOnly: Bool
    let privacy: RuntimePrivacyClass

    init(
        id: String,
        domain: RuntimeDoctorHealthDomain,
        kind: RuntimeDoctorDriftKind,
        severity: LocalRuntimeDiagnosticSeverity,
        summary: String,
        detail: String,
        evidenceIDs: [String],
        localOnly: Bool,
        privacy: RuntimePrivacyClass
    ) {
        self.id = id
        self.domain = domain
        self.kind = kind
        self.severity = severity
        self.redactedSummary = LocalRuntimeDiagnosticsRedactor.redact(summary, privacy: privacy)
        self.redactedDetail = LocalRuntimeDiagnosticsRedactor.redact(detail, privacy: privacy)
        self.evidenceIDs = Self.orderedUnique(evidenceIDs.map(LocalRuntimeDiagnosticsRedactor.fingerprint))
        self.localOnly = localOnly
        self.privacy = privacy
    }

    private static func orderedUnique(_ values: [String]) -> [String] {
        Array(Set(values.filter { $0.isEmpty == false })).sorted()
    }
}

struct RuntimeDoctorHealthReader: Identifiable, Codable, Sendable, Equatable, Hashable {
    let id: String
    let domain: RuntimeDoctorHealthDomain
    let componentID: String
    let diagnostics: [LocalRuntimeDiagnosticRecord]
    let evidenceIDs: [String]
    let localOnly: Bool
    let generatedAt: String

    init(
        id: String? = nil,
        domain: RuntimeDoctorHealthDomain,
        componentID: String,
        diagnostics: [LocalRuntimeDiagnosticRecord],
        evidenceIDs: [String] = [],
        localOnly: Bool = true,
        generatedAt: String
    ) {
        self.id = id ?? "runtime_doctor_health_reader.\(domain.rawValue)"
        self.domain = domain
        self.componentID = componentID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.diagnostics = diagnostics.sorted { $0.id < $1.id }
        self.evidenceIDs = Self.orderedUnique(evidenceIDs.map(LocalRuntimeDiagnosticsRedactor.fingerprint))
        self.localOnly = localOnly
        self.generatedAt = generatedAt.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var driftSignals: [RuntimeDoctorDriftSignal] {
        diagnostics.filter(\.requiresAttention).map { record in
            RuntimeDoctorDriftSignal(
                id: "runtime_doctor_drift.\(domain.rawValue).\(record.id)",
                domain: domain,
                kind: Self.driftKind(for: domain, record: record),
                severity: record.severity,
                summary: record.summary,
                detail: record.redactedDetail,
                evidenceIDs: record.evidenceIDs + evidenceIDs,
                localOnly: localOnly && record.localOnly,
                privacy: record.privacy
            )
        }
    }

    private static func driftKind(
        for domain: RuntimeDoctorHealthDomain,
        record: LocalRuntimeDiagnosticRecord
    ) -> RuntimeDoctorDriftKind {
        switch domain {
        case .commandJournal:
            return .commandEventReconciliationDrift
        case .eventStore:
            return .eventStoreCursorDrift
        case .projectionStore:
            return .projectionStoreChecksumDrift
        case .searchIndex:
            return .searchIndexDrift
        case .blobVault:
            return .blobVaultCorruption
        case .sideEffectOutbox:
            return .sideEffectOutboxDrift
        case .syncContinuity:
            return .syncContinuityDrift
        case .privacyBoundary:
            return .privacyRedactionDrift
        case .migrationState:
            return .migrationStateDrift
        case .storageTier:
            if record.id.contains("event") {
                return .eventStoreCursorDrift
            }
            return .storageTierDrift
        }
    }

    private static func orderedUnique(_ values: [String]) -> [String] {
        Array(Set(values.filter { $0.isEmpty == false })).sorted()
    }
}
