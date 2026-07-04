import Foundation

let runtimeDoctorRepairOperatorSchemaVersion = "runtime_doctor_repair_operator.native.v1"

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
        case .continuity:
            return [.continuityHold]
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
            sourceOwner: "Core/LocalRuntimeOS/Repair/RuntimeDoctor"
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
        case .continuityHold:
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
                "Require Repair review before storage mutation.",
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
        case .continuityHold:
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
