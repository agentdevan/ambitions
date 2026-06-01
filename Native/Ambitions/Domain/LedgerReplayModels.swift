import Foundation

enum LedgerRecordTaxonomyKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case command
    case event
    case sideEffect = "side_effect"
    case receipt
}

enum LedgerReplayDecision: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case applyFresh = "apply_fresh"
    case replayExistingReceipt = "replay_existing_receipt"
    case lookupUnavailable = "lookup_unavailable"
}

struct LedgerIdempotencyKey: Codable, Sendable, Equatable, Hashable {
    let rawValue: String

    init(_ rawValue: String) {
        self.rawValue = rawValue
    }

    var isWellFormed: Bool {
        rawValue.isEmpty == false
    }
}

enum LedgerDoubleApplyDisposition: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case applyOnce = "apply_once"
    case skipDuplicateMutation = "skip_duplicate_mutation"
    case skipUnverifiedMutation = "skip_unverified_mutation"
}

struct LedgerReplayOutcome: Codable, Sendable, Equatable, Hashable {
    let idempotencyKey: LedgerIdempotencyKey
    let decision: LedgerReplayDecision
    let doubleApplyDisposition: LedgerDoubleApplyDisposition
    let receiptSummary: String

    var isReplay: Bool {
        decision == .replayExistingReceipt
    }
}

enum ExecutionLedgerReplayValidationState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case deterministic
    case reviewRequired = "review_required"
    case unavailable
}

struct ExecutionLedgerReplayBrowserProjection: Sendable, Equatable, Identifiable {
    let receiptRecord: ActionReceiptHistoryRecord
    let proofLedgerEntry: ActionReceiptProofLedgerEntry
    let runtimeSnapshotEnvelope: RuntimeSnapshotLedgerEnvelope?
    let replayOutcome: LedgerReplayOutcome
    let sourceRecordIDs: [String]
    let receiptIDs: [String]
    let replayTraceIDs: [String]
    let runtimeSnapshotChecksum: String?
    let runtimeSnapshotProvenanceHash: String?
    let privacyPostureLabel: String
    let exportPostureLabel: String
    let proofImmutabilityLabel: String
    let closureImmutabilityLabel: String
    let runtimeSnapshotValidationReport: RuntimeSnapshotLedgerReplayValidationReport?
    let deterministicReplayValidationState: ExecutionLedgerReplayValidationState
    let summary: String

    init(
        receiptRecord: ActionReceiptHistoryRecord,
        proofLedgerEntry: ActionReceiptProofLedgerEntry,
        runtimeSnapshotEnvelope: RuntimeSnapshotLedgerEnvelope? = nil,
        replayOutcome: LedgerReplayOutcome
    ) {
        self.receiptRecord = receiptRecord
        self.proofLedgerEntry = proofLedgerEntry
        self.runtimeSnapshotEnvelope = runtimeSnapshotEnvelope
        self.replayOutcome = replayOutcome
        self.sourceRecordIDs = Self.normalizedIDs(
            receiptRecord.sourceRecordIDs +
                (runtimeSnapshotEnvelope?.sourceRecordIDs ?? [])
        )
        self.receiptIDs = Self.normalizedIDs(
            [receiptRecord.id] +
                (runtimeSnapshotEnvelope?.receiptIDs ?? [])
        )
        self.replayTraceIDs = Self.normalizedIDs(runtimeSnapshotEnvelope?.replayTraceIDs ?? [])
        self.runtimeSnapshotChecksum = runtimeSnapshotEnvelope?.checksum
        self.runtimeSnapshotProvenanceHash = runtimeSnapshotEnvelope?.provenanceHash
        self.privacyPostureLabel = proofLedgerEntry.privacyPostureLabel
        self.exportPostureLabel = runtimeSnapshotEnvelope?.exportPostureLabel ?? proofLedgerEntry.exportPostureLabel
        self.proofImmutabilityLabel = proofLedgerEntry.proofImmutabilityLabel
        self.closureImmutabilityLabel = proofLedgerEntry.closureImmutabilityLabel
        self.runtimeSnapshotValidationReport = Self.runtimeSnapshotValidationReport(
            receiptRecord: receiptRecord,
            proofLedgerEntry: proofLedgerEntry,
            runtimeSnapshotEnvelope: runtimeSnapshotEnvelope
        )
        self.deterministicReplayValidationState = Self.deterministicReplayValidationState(
            runtimeSnapshotValidationReport: self.runtimeSnapshotValidationReport,
            replayOutcome: replayOutcome,
            proofLedgerEntry: proofLedgerEntry
        )
        self.summary = Self.makeSummary(
            receiptRecord: receiptRecord,
            proofLedgerEntry: proofLedgerEntry,
            runtimeSnapshotEnvelope: runtimeSnapshotEnvelope,
            replayOutcome: replayOutcome,
            validationState: self.deterministicReplayValidationState,
            validationReport: self.runtimeSnapshotValidationReport
        )
    }

    var id: String {
        "execution-ledger.replay-browser.\(receiptRecord.id)"
    }

    var isReadOnly: Bool {
        true
    }

    var sourceLabel: String {
        "Source: Execution ledger"
    }

    var reviewLabel: String {
        switch deterministicReplayValidationState {
        case .deterministic:
            return "Read-only replay browser"
        case .reviewRequired:
            return "Review in owning flow"
        case .unavailable:
            return "Replay validation unavailable"
        }
    }

    var reversibilityLabel: String {
        "\(proofImmutabilityLabel) · \(closureImmutabilityLabel)"
    }

    var sourceSummary: String {
        sourceRecordIDs.isEmpty ? "Source records hidden" : "Source records: \(sourceRecordIDs.joined(separator: ", "))"
    }

    var receiptSummary: String {
        receiptIDs.isEmpty ? "Receipt IDs hidden" : "Receipt IDs: \(receiptIDs.joined(separator: ", "))"
    }

    var replayTraceSummary: String {
        replayTraceIDs.isEmpty ? "Replay trace IDs hidden" : "Replay trace IDs: \(replayTraceIDs.joined(separator: ", "))"
    }

    var snapshotSummary: String {
        guard let runtimeSnapshotChecksum, let runtimeSnapshotProvenanceHash else {
            return "Runtime snapshot not attached"
        }
        return "Runtime snapshot checksum \(runtimeSnapshotChecksum) · provenance \(runtimeSnapshotProvenanceHash)"
    }

    var validationLabel: String {
        switch deterministicReplayValidationState {
        case .deterministic:
            return "Deterministic replay validated"
        case .reviewRequired:
            return "Replay review required"
        case .unavailable:
            return "Replay validation unavailable"
        }
    }

    var summaryLines: [String] {
        [
            sourceSummary,
            receiptSummary,
            replayTraceSummary,
            snapshotSummary,
            "Privacy: \(privacyPostureLabel)",
            "Export: \(exportPostureLabel)",
            "Proof: \(proofImmutabilityLabel)",
            "Closure: \(closureImmutabilityLabel)",
            "Replay: \(replayOutcome.decision.rawValue) / \(replayOutcome.doubleApplyDisposition.rawValue)",
            "Validation: \(validationLabel)"
        ]
    }

    private static func normalizedIDs(_ values: [String]) -> [String] {
        var seen = Set<String>()
        return values
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { $0.isEmpty == false }
            .filter { seen.insert($0).inserted }
    }

    private static func runtimeSnapshotValidationReport(
        receiptRecord: ActionReceiptHistoryRecord,
        proofLedgerEntry: ActionReceiptProofLedgerEntry,
        runtimeSnapshotEnvelope: RuntimeSnapshotLedgerEnvelope?
    ) -> RuntimeSnapshotLedgerReplayValidationReport? {
        guard let runtimeSnapshotEnvelope else {
            return nil
        }

        let reference = proofLedgerEntry.proofReferenceIDs.first.map {
            RuntimeSnapshotLedgerArtifactReference(
                kind: .proofInput,
                artifactID: $0,
                envelopeID: runtimeSnapshotEnvelope.id,
                envelopeChecksum: runtimeSnapshotEnvelope.checksum
            )
        } ?? RuntimeSnapshotLedgerArtifactReference(
            kind: .receipt,
            artifactID: receiptRecord.id,
            envelopeID: runtimeSnapshotEnvelope.id,
            envelopeChecksum: runtimeSnapshotEnvelope.checksum
        )

        return runtimeSnapshotEnvelope.validate(reference: reference)
    }

    private static func deterministicReplayValidationState(
        runtimeSnapshotValidationReport: RuntimeSnapshotLedgerReplayValidationReport?,
        replayOutcome: LedgerReplayOutcome,
        proofLedgerEntry: ActionReceiptProofLedgerEntry
    ) -> ExecutionLedgerReplayValidationState {
        guard let runtimeSnapshotValidationReport else {
            return .unavailable
        }

        guard runtimeSnapshotValidationReport.isValid else {
            return .reviewRequired
        }

        guard replayOutcome.isReplay,
              replayOutcome.doubleApplyDisposition == .skipDuplicateMutation,
              proofLedgerEntry.noSilentChanges else {
            return .reviewRequired
        }

        return .deterministic
    }

    private static func makeSummary(
        receiptRecord: ActionReceiptHistoryRecord,
        proofLedgerEntry: ActionReceiptProofLedgerEntry,
        runtimeSnapshotEnvelope: RuntimeSnapshotLedgerEnvelope?,
        replayOutcome: LedgerReplayOutcome,
        validationState: ExecutionLedgerReplayValidationState,
        validationReport: RuntimeSnapshotLedgerReplayValidationReport?
    ) -> String {
        var lines: [String] = [
            "Read-only replay browser for receipt \(receiptRecord.id)",
            "Replay validation: \(validationState.rawValue)"
        ]

        if let validationReport {
            lines.append(validationReport.message)
        }

        lines.append(contentsOf: [
            proofLedgerEntry.privacyPostureLabel,
            proofLedgerEntry.exportPostureLabel,
            proofLedgerEntry.proofImmutabilityLabel,
            proofLedgerEntry.closureImmutabilityLabel,
            runtimeSnapshotEnvelope.map { "Runtime snapshot checksum \($0.checksum) · provenance \($0.provenanceHash)" } ?? "Runtime snapshot provenance unavailable",
            "Replay decision: \(replayOutcome.decision.rawValue)"
        ])

        return lines.joined(separator: " · ")
    }
}
