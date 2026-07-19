import Foundation
import SwiftData

struct SwiftDataExecutionLedgerReplayInspectionRepository: ExecutionLedgerReplayInspectionRepository {
    let store: AmbitionsPersistenceStore

    struct ReplayCandidate: Sendable {
        let projection: ExecutionLedgerReplayBrowserProjection
        let sortDate: Date?
        let sortKey: String
    }

    func fetch(_ query: ExecutionLedgerReplayInspectionQuery) async throws -> ExecutionLedgerReplayInspectionProjection {
        try await store.read { context in
            let commandRecords = try context.fetch(FetchDescriptor<CommandExecutionRecord>())
                .compactMap { try? RepositoryMapping.commandExecutionRecord(from: $0) }
            let receiptRecords = try context.fetch(FetchDescriptor<ActionReceiptHistoryRecordModel>())
                .compactMap { try? RepositoryMapping.actionReceiptHistoryRecord(from: $0) }
            let snapshotEnvelopes = try context.fetch(FetchDescriptor<RuntimeSnapshotLedgerRecord>())
                .compactMap { try? RepositoryMapping.runtimeSnapshotLedgerEnvelope(from: $0) }

            return Self.project(
                query: query,
                commandRecords: commandRecords,
                receiptRecords: receiptRecords,
                snapshotEnvelopes: snapshotEnvelopes
            )
        }
    }

    static func project(
        query: ExecutionLedgerReplayInspectionQuery,
        commandRecords: [AmbitionsCommandExecutionRecord],
        receiptRecords: [ActionReceiptHistoryRecord],
        snapshotEnvelopes: [RuntimeSnapshotLedgerEnvelope]
    ) -> ExecutionLedgerReplayInspectionProjection {
        let receiptRecords = ActionReceiptHistoryProjection(records: receiptRecords).records
        let receiptsByID = Dictionary(uniqueKeysWithValues: receiptRecords.map { ($0.id, $0) })
        let sortedCommands = commandRecords.sorted(by: commandSort)
        var usedReceiptIDs = Set<String>()
        var candidates: [ReplayCandidate] = []

        for commandRecord in sortedCommands {
            guard query.commandID == nil || query.commandID == commandRecord.commandID else {
                continue
            }
            guard let receiptID = query.receiptID ?? receiptID(from: commandRecord.result.metadata),
                  let receiptRecord = receiptsByID[receiptID] else {
                continue
            }
            guard query.receiptID == nil || query.receiptID == receiptRecord.id else {
                continue
            }

            candidates.append(candidate(
                commandRecord: commandRecord,
                receiptRecord: receiptRecord,
                snapshotEnvelopes: snapshotEnvelopes
            ))
            usedReceiptIDs.insert(receiptRecord.id)
        }

        if query.commandID == nil {
            let receiptCandidates = query.receiptID.flatMap { receiptsByID[$0].map { [$0] } } ?? receiptRecords
            for receiptRecord in receiptCandidates where usedReceiptIDs.contains(receiptRecord.id) == false {
                let snapshotEnvelope = snapshotEnvelope(for: receiptRecord, in: snapshotEnvelopes)
                guard query.receiptID != nil || snapshotEnvelope != nil else {
                    continue
                }
                candidates.append(candidate(
                    commandRecord: nil,
                    receiptRecord: receiptRecord,
                    snapshotEnvelopes: snapshotEnvelopes
                ))
                usedReceiptIDs.insert(receiptRecord.id)
            }
        }

        let sorted = candidates.sorted {
            if $0.sortDate != $1.sortDate {
                return ($0.sortDate ?? .distantPast) > ($1.sortDate ?? .distantPast)
            }
            return $0.sortKey > $1.sortKey
        }
        let limited = Array(sorted.prefix(query.limit)).map(\.projection)

        return ExecutionLedgerReplayInspectionProjection(
            query: query,
            items: limited,
            totalCandidateCount: candidates.count,
            emptyTitle: "No replay records matched",
            emptyDetail: "Use a command ID or receipt ID tied to local receipt history.",
            localOnly: true
        )
    }

    static func candidate(
        commandRecord: AmbitionsCommandExecutionRecord?,
        receiptRecord: ActionReceiptHistoryRecord,
        snapshotEnvelopes: [RuntimeSnapshotLedgerEnvelope]
    ) -> ReplayCandidate {
        let snapshotEnvelope = snapshotEnvelope(for: receiptRecord, in: snapshotEnvelopes)
        let outcome = LedgerReplayOutcome(
            idempotencyKey: LedgerIdempotencyKey(commandRecord?.commandID ?? receiptRecord.id),
            decision: commandRecord == nil ? .lookupUnavailable : .replayExistingReceipt,
            doubleApplyDisposition: commandRecord == nil ? .skipUnverifiedMutation : .skipDuplicateMutation,
            receiptSummary: commandRecord?.result.summary ?? receiptRecord.receipt.summary
        )
        let proofEntry = ActionReceiptProofLedgerEntry(
            receipt: receiptRecord.receipt,
            privacyLevel: receiptRecord.privacyLevel,
            localOnly: receiptRecord.localOnly,
            visibilityLevels: [.peek, .trail, .search],
            proofRelevance: receiptRecord.proofRelevance,
            runtimeLineage: receiptRecord.runtimeLineage
        )
        let projection = ExecutionLedgerReplayBrowserProjection(
            receiptRecord: receiptRecord,
            proofLedgerEntry: proofEntry,
            runtimeSnapshotEnvelope: snapshotEnvelope,
            commandExecutionRecord: commandRecord,
            replayOutcome: outcome
        )
        return ReplayCandidate(
            projection: projection,
            sortDate: commandRecord.map { PersistedTemporalValue.date(from: $0.recordedAt) } ?? PersistedTemporalValue.date(from: receiptRecord.receipt.occurredAt),
            sortKey: commandRecord?.id ?? receiptRecord.id
        )
    }

    static func snapshotEnvelope(
        for receiptRecord: ActionReceiptHistoryRecord,
        in snapshotEnvelopes: [RuntimeSnapshotLedgerEnvelope]
    ) -> RuntimeSnapshotLedgerEnvelope? {
        let proofIDs = Set(receiptRecord.proofReferenceIDs)
        return snapshotEnvelopes
            .filter { envelope in
                envelope.receiptIDs.contains(receiptRecord.id) ||
                    envelope.proofInputReferenceIDs.contains(where: { proofIDs.contains($0) })
            }
            .sorted {
                if $0.generatedAt != $1.generatedAt {
                    return $0.generatedAt > $1.generatedAt
                }
                return $0.id > $1.id
            }
            .first
    }

    static func receiptID(from metadata: [String: String]) -> String? {
        for key in ["receiptID", "receiptId", "actionReceiptID", "actionReceiptRecordID"] {
            guard let value = metadata[key]?.trimmingCharacters(in: .whitespacesAndNewlines),
                  value.isEmpty == false else {
                continue
            }
            return value
        }
        return nil
    }

    static func commandSort(_ lhs: AmbitionsCommandExecutionRecord, _ rhs: AmbitionsCommandExecutionRecord) -> Bool {
        let lhsDate = PersistedTemporalValue.date(from: lhs.recordedAt)
        let rhsDate = PersistedTemporalValue.date(from: rhs.recordedAt)
        if lhsDate == rhsDate {
            return lhs.id > rhs.id
        }
        return lhsDate > rhsDate
    }
}
