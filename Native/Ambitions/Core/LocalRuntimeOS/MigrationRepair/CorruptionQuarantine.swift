import Foundation

let corruptionQuarantineSchemaVersion = "corruption_quarantine.native.v1"

enum CorruptionQuarantineSignalKind: String, Sendable, Equatable, Hashable {
    case corruptStoreOpenFailed = "corrupt_store_open_failed"
    case decodeFailure = "decode_failure"
    case invariantBlocker = "invariant_blocker"
}

struct CorruptionQuarantineSignal: Identifiable, Sendable, Equatable, Hashable {
    let id: String
    let kind: CorruptionQuarantineSignalKind
    let message: String

    init(id: String, kind: CorruptionQuarantineSignalKind, message: String) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.kind = kind
        self.message = message.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

struct CorruptionQuarantineDecision: Identifiable, Sendable, Equatable, Hashable {
    let id: String
    let schemaVersion: String
    let createdAt: String
    let signals: [CorruptionQuarantineSignal]
    let quarantineRequired: Bool
    let destructiveResetAllowed: Bool
    let sourceRecordID: String
    let receiptID: String
    let replayTraceID: String
    let summary: String

    init(
        id: String,
        schemaVersion: String = corruptionQuarantineSchemaVersion,
        createdAt: String,
        signals: [CorruptionQuarantineSignal],
        quarantineRequired: Bool,
        destructiveResetAllowed: Bool = false,
        sourceRecordID: String,
        receiptID: String,
        replayTraceID: String,
        summary: String
    ) {
        self.id = id
        self.schemaVersion = schemaVersion
        self.createdAt = createdAt
        self.signals = signals.sorted { $0.id < $1.id }
        self.quarantineRequired = quarantineRequired
        self.destructiveResetAllowed = destructiveResetAllowed
        self.sourceRecordID = sourceRecordID
        self.receiptID = receiptID
        self.replayTraceID = replayTraceID
        self.summary = summary
    }
}

struct CorruptionQuarantine: Sendable {
    let timestampProvider: @Sendable () -> String
    let idProvider: @Sendable () -> String

    init(
        timestampProvider: @escaping @Sendable () -> String = { DomainTimestamp.string(from: .now) },
        idProvider: @escaping @Sendable () -> String = { UUID().uuidString }
    ) {
        self.timestampProvider = timestampProvider
        self.idProvider = idProvider
    }

    func evaluate(signals: [CorruptionQuarantineSignal]) -> CorruptionQuarantineDecision {
        let decisionID = idProvider()
        let normalizedSignals = signals
            .filter { $0.id.isEmpty == false || $0.message.isEmpty == false }
            .map { signal in
                CorruptionQuarantineSignal(
                    id: signal.id.isEmpty ? "signal.\(signal.kind.rawValue)" : signal.id,
                    kind: signal.kind,
                    message: signal.message.isEmpty ? "Corruption signal \(signal.kind.rawValue) requires review." : signal.message
                )
            }

        return CorruptionQuarantineDecision(
            id: decisionID,
            createdAt: timestampProvider(),
            signals: normalizedSignals,
            quarantineRequired: normalizedSignals.isEmpty == false,
            destructiveResetAllowed: false,
            sourceRecordID: "SourceRecord.corruption-quarantine.\(decisionID)",
            receiptID: "Receipt.corruption-quarantine.\(decisionID)",
            replayTraceID: "ReplayTrace.corruption-quarantine.\(decisionID)",
            summary: normalizedSignals.isEmpty
                ? "No corrupt-store signal is present; quarantine is not required."
                : "Corrupt-store signals are quarantined for user review before any repair, import, rollback, or destructive reset."
        )
    }
}
