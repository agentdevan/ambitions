import Foundation

enum CapabilitySourceLifecycleChange: String, Codable, Sendable, Equatable, Hashable {
    case archive
    case trash
    case restore
    case corrected
    case redacted
    case permanentlyDeleted = "permanently_deleted"
}

struct CapabilitySourceLifecycleReconciliation: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let causalCommandID: String
    let expectedCapabilityRevision: Int
    let idempotencyKey: String
    let source: CapabilityEvidenceSourceReference
    let change: CapabilitySourceLifecycleChange

    init(id: String, causalCommandID: String, expectedCapabilityRevision: Int, idempotencyKey: String, source: CapabilityEvidenceSourceReference, change: CapabilitySourceLifecycleChange) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.causalCommandID = causalCommandID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.expectedCapabilityRevision = max(0, expectedCapabilityRevision)
        self.idempotencyKey = idempotencyKey.trimmingCharacters(in: .whitespacesAndNewlines)
        self.source = source
        self.change = change
    }
}

enum CapabilitySourceLifecycleReconciliationStatus: String, Codable, Sendable, Equatable, Hashable {
    case settled
    case pendingNoRelationship = "pending_no_relationship"
    case duplicate
}

struct CapabilitySourceLifecycleReconciliationResult: Codable, Sendable, Equatable, Hashable {
    let status: CapabilitySourceLifecycleReconciliationStatus
    let causalCommandID: String
    let receipt: CapabilityStoreAppendReceipt?
    let affectedRelationshipIDs: [String]
}

/// Receives lifecycle facts from an owning source aggregate. It never changes
/// that source and only reconciles matching Capability evidence in one event.
actor CapabilitySourceLifecycleReconciler {
    private let store: CapabilityStateStore
    private var resultsByIdempotencyKey: [String: CapabilitySourceLifecycleReconciliationResult] = [:]

    init(store: CapabilityStateStore) {
        self.store = store
    }

    func reconcile(_ request: CapabilitySourceLifecycleReconciliation) async throws -> CapabilitySourceLifecycleReconciliationResult {
        if let result = resultsByIdempotencyKey[request.idempotencyKey] {
            return CapabilitySourceLifecycleReconciliationResult(
                status: .duplicate, causalCommandID: result.causalCommandID,
                receipt: result.receipt, affectedRelationshipIDs: result.affectedRelationshipIDs
            )
        }
        let snapshot = await store.currentSnapshot()
        let matches = snapshot.evidenceRelationships.filter { relationship in
            relationship.source.kind == request.source.kind && relationship.source.stableID == request.source.stableID
        }
        guard matches.isEmpty == false else {
            let result = CapabilitySourceLifecycleReconciliationResult(
                status: .pendingNoRelationship, causalCommandID: request.causalCommandID,
                receipt: nil, affectedRelationshipIDs: []
            )
            resultsByIdempotencyKey[request.idempotencyKey] = result
            return result
        }
        let updated = matches.map { relationship in
            CapabilityEvidenceRelationship(
                id: relationship.id, revision: relationship.revision + 1,
                capabilityID: relationship.capabilityID, source: request.source,
                relationKind: relationship.relationKind,
                userApprovedContext: retainsContext(for: request.change) ? relationship.userApprovedContext : nil,
                occurredAt: relationship.occurredAt, freshnessUpdatedAt: relationship.freshnessUpdatedAt,
                availability: availability(for: request.change),
                contradictionState: contradiction(for: request.change, existing: relationship.contradictionState),
                lineageIDs: relationship.lineageIDs + [request.causalCommandID]
            )
        }
        let receipt = try await store.append(
            .reconcileEvidence(updated), expectedRevision: request.expectedCapabilityRevision,
            idempotencyKey: request.idempotencyKey
        )
        let result = CapabilitySourceLifecycleReconciliationResult(
            status: .settled, causalCommandID: request.causalCommandID, receipt: receipt,
            affectedRelationshipIDs: updated.map(\.id).sorted()
        )
        resultsByIdempotencyKey[request.idempotencyKey] = result
        return result
    }

    private func availability(for change: CapabilitySourceLifecycleChange) -> CapabilityEvidenceAvailability {
        switch change {
        case .archive: return .archived
        case .trash: return .trashed
        case .restore, .corrected: return .available
        case .redacted: return .redacted
        case .permanentlyDeleted: return .permanentlyDeleted
        }
    }

    private func contradiction(for change: CapabilitySourceLifecycleChange, existing: CapabilityEvidenceContradictionState) -> CapabilityEvidenceContradictionState {
        switch change {
        case .corrected, .redacted, .permanentlyDeleted: return .needsReview
        case .archive, .trash, .restore: return existing
        }
    }

    private func retainsContext(for change: CapabilitySourceLifecycleChange) -> Bool {
        change != .redacted && change != .permanentlyDeleted
    }
}
