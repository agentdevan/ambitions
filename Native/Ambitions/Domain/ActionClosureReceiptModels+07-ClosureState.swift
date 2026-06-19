import Foundation

extension ClosureState {
    var actionReceiptResultState: ActionReceiptResultState {
        switch self {
        case .completed, .stillCounts:
            .completed
        case .moved:
            .moved
        case .waiting, .blocked, .needsRecovery, .needsReview, .awaitingClosure:
            .needsConfirmation
        case .skippedIntentionally, .notNeeded:
            .changed
        case .now, .next, .later:
            .scheduled
        }
    }

    var changedFactKind: ActionReceiptChangedFactKind {
        switch self {
        case .completed, .stillCounts:
            .completedAction
        case .moved:
            .movedActionToLater
        case .waiting:
            .markedWaiting
        case .blocked, .needsRecovery, .needsReview, .awaitingClosure, .skippedIntentionally, .notNeeded, .now, .next, .later:
            .changedField
        }
    }

    var undoAvailability: ActionReceiptUndoAvailability {
        switch self {
        case .completed, .stillCounts, .moved, .skippedIntentionally, .notNeeded, .waiting:
            .requiresConfirmation
        case .blocked, .needsRecovery, .needsReview, .awaitingClosure, .now, .next, .later:
            .unavailable
        }
    }

    var nextAction: ActionReceiptNextAction? {
        switch self {
        case .awaitingClosure, .needsReview:
            ActionReceiptNextAction(kind: .openToday, title: "Close the loop", destination: .today)
        case .needsRecovery, .blocked:
            ActionReceiptNextAction(kind: .openTime, title: "Adjust time", destination: .time)
        case .completed, .stillCounts, .moved, .skippedIntentionally, .notNeeded, .waiting, .now, .next, .later:
            nil
        }
    }

    func receiptTitle(stepTitle: String) -> String {
        switch self {
        case .completed:
            "Completed"
        case .stillCounts:
            "Still Counts"
        case .moved:
            "Rescheduled"
        case .skippedIntentionally:
            "Skipped intentionally"
        case .notNeeded:
            "Not Needed"
        case .blocked, .needsRecovery:
            "Needs Recovery"
        case .waiting:
            "Waiting"
        case .needsReview, .awaitingClosure:
            "Needs a quick check"
        case .now, .next, .later:
            displayLabel
        }
    }

    func receiptSummary(stepTitle: String) -> String {
        switch self {
        case .completed:
            "Completed · recorded today"
        case .stillCounts:
            "Still Counts · smaller version completed"
        case .moved:
            "Rescheduled · receipt saved"
        case .skippedIntentionally:
            "Skipped intentionally · receipt saved"
        case .notNeeded:
            "Not Needed · receipt saved"
        case .blocked, .needsRecovery:
            "Needs Recovery · review before changing the plan"
        case .waiting:
            "Waiting · dependency noted"
        case .needsReview, .awaitingClosure:
            "Needs a quick check · Close the loop"
        case .now, .next, .later:
            "\(displayLabel) · scheduled"
        }
    }

    func changedFactSummary(stepTitle: String) -> String {
        "\(stepTitle) -> \(displayLabel)"
    }
}

struct ActionReceiptProjection: Sendable, Equatable {
    let receipts: [ActionReceipt]
    let rejectedReceiptIDs: [String]
    let lifeGraphProjection: LifeGraphRelationshipProjection

    init(receipts: [ActionReceipt] = []) {
        var seen = Set<String>()
        var accepted: [ActionReceipt] = []
        var rejected: [String] = []

        for receipt in receipts {
            guard receipt.isWellFormed, seen.insert(receipt.dedupeKey).inserted else {
                rejected.append(receipt.id.isEmpty ? "malformed-receipt" : receipt.id)
                continue
            }
            accepted.append(receipt)
        }

        self.receipts = accepted.sorted { lhs, rhs in
            if lhs.occurredAt != rhs.occurredAt {
                return lhs.occurredAt > rhs.occurredAt
            }
            return lhs.orderingKey < rhs.orderingKey
        }
        self.rejectedReceiptIDs = rejected.sorted()
        self.lifeGraphProjection = LifeGraphRelationshipProjection(
            relationships: self.receipts.flatMap(Self.projectedRelationships)
        )
    }

    func receipts(for object: LifeGraphObjectReference) -> [ActionReceipt] {
        receipts.filter { receipt in
            receipt.affectedObjects.contains { $0.stableKey == object.stableKey }
        }
    }

    func receipts(resultState: ActionReceiptResultState) -> [ActionReceipt] {
        receipts.filter { $0.resultState == resultState }
    }

    func correctionAvailableReceipts() -> [ActionReceipt] {
        receipts.filter { $0.correctionAvailability.isAvailable || $0.resultState == .correctionAvailable }
    }

    func undoAvailableReceipts() -> [ActionReceipt] {
        receipts.filter { $0.undoAvailability.isAvailable || $0.resultState == .undoAvailable }
    }

    func displaySummaries(limit: Int? = nil) -> [ActionReceiptDisplaySummary] {
        let summaries = receipts.map(\.displaySummary)
        guard let limit else { return summaries }
        return Array(summaries.prefix(max(0, limit)))
    }

    func historyProjection(
        privacyByReceiptID: [String: ActionReceiptPrivacyLevel] = [:],
        localOnlyByReceiptID: [String: Bool] = [:],
        proofRelevanceByReceiptID: [String: ActionReceiptProofRelevance] = [:]
    ) -> ActionReceiptHistoryProjection {
        ActionReceiptHistoryProjection(
            records: receipts.map { receipt in
                ActionReceiptHistoryRecord(
                    receipt: receipt,
                    privacyLevel: privacyByReceiptID[receipt.id] ?? .safeToShow,
                    localOnly: localOnlyByReceiptID[receipt.id] ?? true,
                    proofRelevance: proofRelevanceByReceiptID[receipt.id]
                )
            }
        )
    }

    func searchReceipts(
        _ query: ActionReceiptSearchQuery = ActionReceiptSearchQuery(),
        privacyByReceiptID: [String: ActionReceiptPrivacyLevel] = [:],
        localOnlyByReceiptID: [String: Bool] = [:],
        proofRelevanceByReceiptID: [String: ActionReceiptProofRelevance] = [:]
    ) -> ActionReceiptSearchProjection {
        historyProjection(
            privacyByReceiptID: privacyByReceiptID,
            localOnlyByReceiptID: localOnlyByReceiptID,
            proofRelevanceByReceiptID: proofRelevanceByReceiptID
        ).search(query)
    }

    func relationshipProjection(for object: LifeGraphObjectReference) -> LifeGraphRelationshipProjection {
        LifeGraphRelationshipProjection(
            relationships: lifeGraphProjection.relationships.filter {
                $0.source.stableKey == object.stableKey || $0.target.stableKey == object.stableKey
            }
        )
    }

    static func projectedRelationships(for receipt: ActionReceipt) -> [LifeGraphRelationship] {
        guard receipt.isWellFormed else { return [] }

        let receiptObject = receipt.lifeGraphObjectReference
        var relationships = receipt.affectedObjects.map { affectedObject in
            LifeGraphRelationship(
                kind: .explains,
                source: receiptObject,
                target: affectedObject,
                note: receipt.summary
            )
        }

        if let sourceObject = receipt.sourceObject {
            relationships.append(
                LifeGraphRelationship(
                    kind: .createdFrom,
                    source: receiptObject,
                    target: sourceObject,
                    note: receipt.why?.body
                )
            )
        }

        if receipt.correctionAvailability.isAvailable {
            relationships.append(contentsOf: receipt.affectedObjects.map { affectedObject in
                LifeGraphRelationship(
                    kind: .corrects,
                    source: receiptObject,
                    target: affectedObject,
                    note: receipt.why?.body
                )
            })
        }

        return relationships
    }
}
