import Foundation

let runtimeConflictReportSchemaVersion = "runtime_conflict_report.native.v1"

enum RuntimeConflictKind: String, Sendable, Codable, Equatable, Hashable, CaseIterable {
    case duplicateIdempotencyKey = "duplicate_idempotency_key"
    case staleReadSetObjectOverlap = "stale_read_set_object_overlap"
    case projectionCursorRegression = "projection_cursor_regression"
}

struct RuntimeConflict: Sendable, Codable, Equatable, Hashable, Identifiable {
    let id: String
    let kind: RuntimeConflictKind
    let objectIDs: [String]
    let relatedReceiptID: String?
    let summary: String

    init(kind: RuntimeConflictKind, commandID: String, objectIDs: [String], relatedReceiptID: String?, summary: String) {
        self.kind = kind
        self.objectIDs = RuntimeTransactionObjectFacts.normalized(objectIDs)
        self.relatedReceiptID = relatedReceiptID?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false ? relatedReceiptID : nil
        self.summary = summary
        self.id = [
            "runtime.conflict",
            kind.rawValue,
            commandID,
            self.objectIDs.joined(separator: "-"),
            self.relatedReceiptID ?? "none",
        ].joined(separator: ".")
    }
}

struct RuntimeConflictReport: Sendable, Codable, Equatable, Hashable {
    let transactionID: String
    let commandID: String
    let conflicts: [RuntimeConflict]
    let checkedReceiptIDs: [String]
    let schemaVersion: String

    init(
        transactionID: String,
        commandID: String,
        conflicts: [RuntimeConflict],
        checkedReceiptIDs: [String],
        schemaVersion: String = runtimeConflictReportSchemaVersion
    ) {
        self.transactionID = transactionID
        self.commandID = commandID
        self.conflicts = conflicts.sorted { $0.id < $1.id }
        self.checkedReceiptIDs = RuntimeTransactionObjectFacts.normalized(checkedReceiptIDs)
        self.schemaVersion = schemaVersion
    }

    var hasBlockingConflict: Bool {
        conflicts.isEmpty == false
    }
}

struct RuntimeConflictDetector: Sendable {
    func detect(
        transaction: RuntimeTransaction,
        committedReceipts: [RuntimeCommitReceipt]
    ) -> RuntimeConflictReport {
        let readSequence = transaction.readSet.latestEventCursor?.sequence ?? 0
        let affected = Set(transaction.writeSet.affectedObjectIDs)
        let currentProjectionSequences = Dictionary(uniqueKeysWithValues: transaction.readSet.projectionCursors.map { ($0.projectionID, $0.sequence) })
        var conflicts: [RuntimeConflict] = []

        for receipt in committedReceipts {
            if receipt.idempotencyKey == transaction.idempotencyKey {
                conflicts.append(
                    RuntimeConflict(
                        kind: .duplicateIdempotencyKey,
                        commandID: transaction.commandID,
                        objectIDs: receipt.affectedObjectIDs,
                        relatedReceiptID: receipt.id,
                        summary: "A committed receipt already exists for this idempotency key."
                    )
                )
            }

            let overlap = affected.intersection(receipt.affectedObjectIDs)
            if overlap.isEmpty == false && receipt.eventCursor.sequence > readSequence {
                conflicts.append(
                    RuntimeConflict(
                        kind: .staleReadSetObjectOverlap,
                        commandID: transaction.commandID,
                        objectIDs: Array(overlap),
                        relatedReceiptID: receipt.id,
                        summary: "The transaction read set is older than an already committed write for the same object."
                    )
                )
            }

            for cursor in receipt.projectionCursors {
                if let currentSequence = currentProjectionSequences[cursor.projectionID], currentSequence < cursor.sequence {
                    conflicts.append(
                        RuntimeConflict(
                            kind: .projectionCursorRegression,
                            commandID: transaction.commandID,
                            objectIDs: receipt.affectedObjectIDs,
                            relatedReceiptID: receipt.id,
                            summary: "The transaction read set has an older projection cursor than a committed receipt."
                        )
                    )
                }
            }
        }

        return RuntimeConflictReport(
            transactionID: transaction.id,
            commandID: transaction.commandID,
            conflicts: conflicts,
            checkedReceiptIDs: committedReceipts.map(\.id)
        )
    }
}
