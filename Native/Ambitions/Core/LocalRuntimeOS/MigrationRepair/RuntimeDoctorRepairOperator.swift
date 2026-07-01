import Foundation

let runtimeDoctorRepairOperatorSchemaVersion = "runtime_doctor_repair_operator.native.v1"

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

struct RuntimeDoctorHealthReaders: Sendable, Equatable, Hashable {
    func commandJournal(
        diagnostics: [LocalRuntimeDiagnosticRecord],
        evidenceIDs: [String] = [],
        generatedAt: String
    ) -> RuntimeDoctorHealthReader {
        reader(
            domain: .commandJournal,
            componentID: "CommandJournalHealthReader",
            diagnostics: diagnostics,
            evidenceIDs: evidenceIDs,
            generatedAt: generatedAt
        )
    }

    func eventStore(
        diagnostics: [LocalRuntimeDiagnosticRecord],
        evidenceIDs: [String] = [],
        generatedAt: String
    ) -> RuntimeDoctorHealthReader {
        reader(
            domain: .eventStore,
            componentID: "EventStoreHealthReader",
            diagnostics: diagnostics,
            evidenceIDs: evidenceIDs,
            generatedAt: generatedAt
        )
    }

    func projectionStore(
        diagnostics: [LocalRuntimeDiagnosticRecord],
        evidenceIDs: [String] = [],
        generatedAt: String
    ) -> RuntimeDoctorHealthReader {
        reader(
            domain: .projectionStore,
            componentID: "ProjectionStoreHealthReader",
            diagnostics: diagnostics,
            evidenceIDs: evidenceIDs,
            generatedAt: generatedAt
        )
    }

    func searchIndex(
        diagnostics: [LocalRuntimeDiagnosticRecord],
        evidenceIDs: [String] = [],
        generatedAt: String
    ) -> RuntimeDoctorHealthReader {
        reader(
            domain: .searchIndex,
            componentID: "SearchIndexHealthReader",
            diagnostics: diagnostics,
            evidenceIDs: evidenceIDs,
            generatedAt: generatedAt
        )
    }

    func blobVault(
        diagnostics: [LocalRuntimeDiagnosticRecord],
        evidenceIDs: [String] = [],
        generatedAt: String
    ) -> RuntimeDoctorHealthReader {
        reader(
            domain: .blobVault,
            componentID: "BlobVaultHealthReader",
            diagnostics: diagnostics,
            evidenceIDs: evidenceIDs,
            generatedAt: generatedAt
        )
    }

    func sideEffectOutbox(
        diagnostics: [LocalRuntimeDiagnosticRecord],
        evidenceIDs: [String] = [],
        generatedAt: String
    ) -> RuntimeDoctorHealthReader {
        reader(
            domain: .sideEffectOutbox,
            componentID: "SideEffectOutboxHealthReader",
            diagnostics: diagnostics,
            evidenceIDs: evidenceIDs,
            generatedAt: generatedAt
        )
    }

    func syncContinuity(
        diagnostics: [LocalRuntimeDiagnosticRecord],
        evidenceIDs: [String] = [],
        generatedAt: String
    ) -> RuntimeDoctorHealthReader {
        reader(
            domain: .syncContinuity,
            componentID: "SyncContinuityHealthReader",
            diagnostics: diagnostics,
            evidenceIDs: evidenceIDs,
            generatedAt: generatedAt
        )
    }

    func privacyBoundary(
        diagnostics: [LocalRuntimeDiagnosticRecord],
        evidenceIDs: [String] = [],
        generatedAt: String
    ) -> RuntimeDoctorHealthReader {
        reader(
            domain: .privacyBoundary,
            componentID: "PrivacyBoundaryHealthReader",
            diagnostics: diagnostics,
            evidenceIDs: evidenceIDs,
            generatedAt: generatedAt
        )
    }

    func migrationState(
        diagnostics: [LocalRuntimeDiagnosticRecord],
        evidenceIDs: [String] = [],
        generatedAt: String
    ) -> RuntimeDoctorHealthReader {
        reader(
            domain: .migrationState,
            componentID: "MigrationStateHealthReader",
            diagnostics: diagnostics,
            evidenceIDs: evidenceIDs,
            generatedAt: generatedAt
        )
    }

    func storageTier(
        diagnostics: [LocalRuntimeDiagnosticRecord],
        evidenceIDs: [String] = [],
        generatedAt: String
    ) -> RuntimeDoctorHealthReader {
        reader(
            domain: .storageTier,
            componentID: "StorageTierHealthReader",
            diagnostics: diagnostics,
            evidenceIDs: evidenceIDs,
            generatedAt: generatedAt
        )
    }

    private func reader(
        domain: RuntimeDoctorHealthDomain,
        componentID: String,
        diagnostics: [LocalRuntimeDiagnosticRecord],
        evidenceIDs: [String],
        generatedAt: String
    ) -> RuntimeDoctorHealthReader {
        RuntimeDoctorHealthReader(
            domain: domain,
            componentID: componentID,
            diagnostics: diagnostics,
            evidenceIDs: evidenceIDs,
            generatedAt: generatedAt
        )
    }
}

struct RuntimeDoctorHealthSnapshot: Codable, Sendable, Equatable, Hashable {
    let schemaVersion: String
    let generatedAt: String
    let readers: [RuntimeDoctorHealthReader]
    let commandEventProjectionReceiptReplayRequired: Bool
    let releaseHealthClaimed: Bool

    init(
        schemaVersion: String = runtimeDoctorRepairOperatorSchemaVersion,
        generatedAt: String,
        readers: [RuntimeDoctorHealthReader],
        commandEventProjectionReceiptReplayRequired: Bool = true,
        releaseHealthClaimed: Bool = false
    ) {
        self.schemaVersion = schemaVersion
        self.generatedAt = generatedAt.trimmingCharacters(in: .whitespacesAndNewlines)
        self.readers = readers.sorted { $0.domain.rawValue < $1.domain.rawValue }
        self.commandEventProjectionReceiptReplayRequired = commandEventProjectionReceiptReplayRequired
        self.releaseHealthClaimed = releaseHealthClaimed
    }

    var driftSignals: [RuntimeDoctorDriftSignal] {
        readers.flatMap(\.driftSignals).sorted {
            if $0.domain != $1.domain {
                return $0.domain.rawValue < $1.domain.rawValue
            }
            return $0.id < $1.id
        }
    }
}

struct RuntimeDoctorRepairProof: Identifiable, Codable, Sendable, Equatable, Hashable {
    let id: String
    let stage: RuntimeDoctorRepairProofStage
    let evidenceIDs: [String]
    let redactedSummary: String

    init(
        id: String,
        stage: RuntimeDoctorRepairProofStage,
        evidenceIDs: [String],
        summary: String,
        privacy: RuntimePrivacyClass
    ) {
        self.id = id
        self.stage = stage
        self.evidenceIDs = Array(Set(evidenceIDs.map(LocalRuntimeDiagnosticsRedactor.fingerprint).filter { $0.isEmpty == false })).sorted()
        self.redactedSummary = LocalRuntimeDiagnosticsRedactor.redact(summary, privacy: privacy)
    }
}

struct RuntimeDoctorRepairReceipt: Identifiable, Codable, Sendable, Equatable, Hashable {
    let id: String
    let schemaVersion: String
    let createdAt: String
    let domain: RuntimeDoctorHealthDomain
    let action: RuntimeDoctorRepairActionKind
    let sourceRecordID: String
    let receiptID: String
    let replayTraceID: String
    let beforeEvidenceIDs: [String]
    let expectedAfterEvidenceIDs: [String]
    let localOnly: Bool
    let privatePayloadIncluded: Bool
    let executionAllowed: Bool
    let destructiveResetAllowed: Bool
}

struct RuntimeDoctorRepairPlan: Identifiable, Codable, Sendable, Equatable, Hashable {
    let id: String
    let domain: RuntimeDoctorHealthDomain
    let action: RuntimeDoctorRepairActionKind
    let redactedSummary: String
    let previewSteps: [String]
    let beforeProof: RuntimeDoctorRepairProof
    let expectedAfterProof: RuntimeDoctorRepairProof
    let receipt: RuntimeDoctorRepairReceipt
    let localOnly: Bool
    let previewOnly: Bool
    let executionAllowed: Bool
    let requiresUserReview: Bool
    let sourceOwner: String

    var youDiagnosticLine: String {
        "You can review a local repair preview for \(domain.userFacingName): \(redactedSummary) No private details leave this device."
    }
}

struct RuntimeDoctorRepairAssessment: Codable, Sendable, Equatable, Hashable {
    let schemaVersion: String
    let generatedAt: String
    let status: LocalBackendHealthStatus
    let plans: [RuntimeDoctorRepairPlan]
    let driftSignals: [RuntimeDoctorDriftSignal]
    let missingHealthDomains: [RuntimeDoctorHealthDomain]
    let localOnly: Bool
    let releaseHealthClaimed: Bool

    var hasRepairableDrift: Bool {
        plans.isEmpty == false
    }

    var canExecuteRepairs: Bool {
        plans.allSatisfy(\.executionAllowed) && plans.isEmpty == false
    }

    var youDiagnosticLines: [String] {
        plans.map(\.youDiagnosticLine)
    }
}

struct RuntimeDoctorRepairOperator: Sendable {
    let timestampProvider: @Sendable () -> String
    let idProvider: @Sendable () -> String

    init(
        timestampProvider: @escaping @Sendable () -> String = { DomainTimestamp.string(from: .now) },
        idProvider: @escaping @Sendable () -> String = { UUID().uuidString }
    ) {
        self.timestampProvider = timestampProvider
        self.idProvider = idProvider
    }

    func diagnose(snapshot: RuntimeDoctorHealthSnapshot) -> RuntimeDoctorRepairAssessment {
        var signals = snapshot.driftSignals
        let presentDomains = Set(snapshot.readers.map(\.domain))
        let missingDomains = RuntimeDoctorHealthDomain.allCases.filter { presentDomains.contains($0) == false }
        for domain in missingDomains {
            signals.append(missingSignal(for: domain, generatedAt: snapshot.generatedAt))
        }

        let plans = signals.flatMap { signal in
            repairActions(for: signal).map { action in
                repairPlan(for: signal, action: action)
            }
        }.sorted {
            if $0.domain != $1.domain {
                return $0.domain.rawValue < $1.domain.rawValue
            }
            if $0.action != $1.action {
                return $0.action.rawValue < $1.action.rawValue
            }
            return $0.id < $1.id
        }

        return RuntimeDoctorRepairAssessment(
            schemaVersion: runtimeDoctorRepairOperatorSchemaVersion,
            generatedAt: snapshot.generatedAt,
            status: status(for: signals),
            plans: plans,
            driftSignals: signals.sorted { $0.id < $1.id },
            missingHealthDomains: missingDomains,
            localOnly: plans.allSatisfy(\.localOnly) && signals.allSatisfy(\.localOnly),
            releaseHealthClaimed: snapshot.releaseHealthClaimed
        )
    }

    private func missingSignal(
        for domain: RuntimeDoctorHealthDomain,
        generatedAt: String
    ) -> RuntimeDoctorDriftSignal {
        RuntimeDoctorDriftSignal(
            id: "runtime_doctor_drift.\(domain.rawValue).missing_health_reader",
            domain: domain,
            kind: .missingHealthReader,
            severity: .warning,
            summary: "RuntimeDoctor has no local health reader for \(domain.userFacingName).",
            detail: "Local drift cannot be assessed for \(domain.rawValue) until a health reader is wired.",
            evidenceIDs: [domain.rawValue, generatedAt],
            localOnly: true,
            privacy: .systemOwned
        )
    }

    private func repairActions(
        for signal: RuntimeDoctorDriftSignal
    ) -> [RuntimeDoctorRepairActionKind] {
        switch signal.domain {
        case .commandJournal, .eventStore:
            return [.commandEventReconciliation]
        case .projectionStore:
            return [.projectionRebuild]
        case .searchIndex:
            return [.searchRebuild]
        case .blobVault:
            return [.corruptBlobQuarantine]
        case .sideEffectOutbox:
            return [.sideEffectOutboxReconcile]
        case .syncContinuity:
            return [.syncContinuityHold]
        case .privacyBoundary:
            return [.privacyRedactionReview]
        case .migrationState:
            return [.dryMigration, .preMigrationBackup, .restoreBackup, .restoreRollback]
        case .storageTier:
            return [.storageInvariantCheck]
        }
    }

    private func repairPlan(
        for signal: RuntimeDoctorDriftSignal,
        action: RuntimeDoctorRepairActionKind
    ) -> RuntimeDoctorRepairPlan {
        let createdAt = timestampProvider()
        let seed = idProvider()
        let evidenceSeed = signal.evidenceIDs.joined(separator: ".")
        let fingerprint = LocalRuntimeDiagnosticsRedactor.fingerprint(
            "\(signal.id).\(action.rawValue).\(evidenceSeed)"
        )
        let planID = "runtime_doctor_repair.\(signal.domain.rawValue).\(action.rawValue).\(fingerprint)"
        let beforeProof = RuntimeDoctorRepairProof(
            id: "runtime_doctor_before.\(fingerprint)",
            stage: .before,
            evidenceIDs: signal.evidenceIDs,
            summary: "Before repair: \(signal.redactedSummary)",
            privacy: signal.privacy
        )
        let expectedAfterProof = RuntimeDoctorRepairProof(
            id: "runtime_doctor_after.\(fingerprint)",
            stage: .expectedAfter,
            evidenceIDs: signal.evidenceIDs + [action.rawValue, signal.domain.rawValue],
            summary: "Expected after repair: \(expectedAfterSummary(for: action, domain: signal.domain))",
            privacy: .systemOwned
        )
        let receipt = RuntimeDoctorRepairReceipt(
            id: "runtime_doctor_receipt.\(fingerprint)",
            schemaVersion: runtimeDoctorRepairOperatorSchemaVersion,
            createdAt: createdAt,
            domain: signal.domain,
            action: action,
            sourceRecordID: "SourceRecord.runtime-doctor.\(signal.domain.rawValue).\(fingerprint)",
            receiptID: "Receipt.runtime-doctor.\(signal.domain.rawValue).\(action.rawValue).\(seed).\(fingerprint)",
            replayTraceID: "ReplayTrace.runtime-doctor.\(signal.domain.rawValue).\(fingerprint)",
            beforeEvidenceIDs: beforeProof.evidenceIDs,
            expectedAfterEvidenceIDs: expectedAfterProof.evidenceIDs,
            localOnly: true,
            privatePayloadIncluded: false,
            executionAllowed: false,
            destructiveResetAllowed: false
        )

        return RuntimeDoctorRepairPlan(
            id: planID,
            domain: signal.domain,
            action: action,
            redactedSummary: signal.redactedSummary,
            previewSteps: previewSteps(for: action, domain: signal.domain),
            beforeProof: beforeProof,
            expectedAfterProof: expectedAfterProof,
            receipt: receipt,
            localOnly: true,
            previewOnly: true,
            executionAllowed: false,
            requiresUserReview: true,
            sourceOwner: "Core/LocalRuntimeOS/MigrationRepair/RuntimeDoctor"
        )
    }

    private func previewSteps(
        for action: RuntimeDoctorRepairActionKind,
        domain: RuntimeDoctorHealthDomain
    ) -> [String] {
        switch action {
        case .commandEventReconciliation:
            return [
                "Compare command journal links with runtime event replay authority.",
                "Preview missing receipt or replay-link records without mutating canonical state.",
                "Require a new local receipt before any reconciliation is applied.",
            ]
        case .projectionRebuild:
            return [
                "Read runtime events from the event journal.",
                "Preview projection materialization for Today, Goals, Time, You, and Search.",
                "Write no projection rows until the user reviews the rebuild receipt.",
            ]
        case .searchRebuild:
            return [
                "Read sanitized projection inputs.",
                "Preview FTS rebuild rows and provenance checksums.",
                "Keep private values redacted from the preview.",
            ]
        case .corruptBlobQuarantine:
            return [
                "Fingerprint the corrupt blob reference.",
                "Move the blob reference into quarantine planning.",
                "Require backup/export review before destructive cleanup.",
            ]
        case .sideEffectOutboxReconcile:
            return [
                "Compare queued side effects with prior local commit receipts.",
                "Hold external attempts without commit proof.",
                "Preview retry, drop, or rollback choices locally.",
            ]
        case .syncContinuityHold:
            return [
                "Keep local storage authoritative.",
                "Hold continuity metadata locally until proof is valid.",
                "Block private graph backend authority.",
            ]
        case .privacyRedactionReview:
            return [
                "Regenerate diagnostics through the redactor.",
                "Require local authentication where the privacy class demands it.",
                "Keep private payloads out of repair previews.",
            ]
        case .dryMigration:
            return [
                "Run migration planning in dry-run mode.",
                "Compare source and target schema ledgers.",
                "Produce a review receipt before any storage mutation.",
            ]
        case .preMigrationBackup:
            return [
                "Prepare an encrypted local backup plan.",
                "Record backup checksum evidence.",
                "Block migration execution until backup receipt exists.",
            ]
        case .restoreBackup:
            return [
                "Preview available local backup packages.",
                "Verify backup manifest and checksum evidence.",
                "Require explicit restore review before any write.",
            ]
        case .restoreRollback:
            return [
                "Preview rollback from migration receipts.",
                "Verify replay trace and backup references.",
                "Keep destructive reset unavailable by default.",
            ]
        case .storageInvariantCheck:
            return [
                "Read local storage tier health.",
                "Preview invariant failures by tier.",
                "Require MigrationRepair review before storage mutation.",
            ]
        }
    }

    private func expectedAfterSummary(
        for action: RuntimeDoctorRepairActionKind,
        domain: RuntimeDoctorHealthDomain
    ) -> String {
        switch action {
        case .commandEventReconciliation:
            return "Command journal and runtime event receipts agree for \(domain.userFacingName)."
        case .projectionRebuild:
            return "Local projections can be rebuilt from runtime events."
        case .searchRebuild:
            return "Local search can be rebuilt from sanitized projections."
        case .corruptBlobQuarantine:
            return "Corrupt blob references are quarantined before cleanup."
        case .sideEffectOutboxReconcile:
            return "External handoff queue only contains attempts backed by local receipts."
        case .syncContinuityHold:
            return "Continuity remains metadata-only and local storage stays authoritative."
        case .privacyRedactionReview:
            return "Diagnostics are redacted and local-only before inspection."
        case .dryMigration:
            return "Migration plan has dry-run evidence before execution."
        case .preMigrationBackup:
            return "Migration has local backup receipt evidence."
        case .restoreBackup:
            return "Restore plan references verified local backup evidence."
        case .restoreRollback:
            return "Rollback plan references receipts and replay traces."
        case .storageInvariantCheck:
            return "Storage invariant evidence is available for review."
        }
    }

    private func status(
        for signals: [RuntimeDoctorDriftSignal]
    ) -> LocalBackendHealthStatus {
        if signals.contains(where: { $0.severity == .critical }) {
            return .red
        }
        if signals.contains(where: { $0.severity == .warning }) {
            return .yellow
        }
        return .green
    }
}
