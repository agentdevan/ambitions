import Foundation

enum LastKnownGoodStoreIssue: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case missingPayload = "missing_payload"
    case missingRollbackPointer = "missing_rollback_pointer"
    case hashMismatch = "hash_mismatch"
    case quarantined = "quarantined"
}

struct LastKnownGoodSelection: Sendable, Equatable, Hashable {
    let payload: SourceAtlasStorePayload?
    let issues: [LastKnownGoodStoreIssue]
    let rollbackPointer: String?

    var canUse: Bool {
        payload != nil && issues.isEmpty
    }
}

struct LastKnownGoodStore: Sendable {
    private let store: SourceAtlasStore

    init(store: SourceAtlasStore = SourceAtlasStore()) {
        self.store = store
    }

    func select(
        entry: SourceAtlasFreshnessPackEntry,
        payload: SourceAtlasStorePayload?
    ) -> LastKnownGoodSelection {
        var issues: Set<LastKnownGoodStoreIssue> = []
        let rollbackPointer = entry.rollbackPointers["last_known_good"]

        guard let payload else {
            issues.insert(.missingPayload)
            return LastKnownGoodSelection(
                payload: nil,
                issues: LastKnownGoodStoreIssue.allCases.filter { issues.contains($0) },
                rollbackPointer: rollbackPointer
            )
        }
        guard let rollbackPointer else {
            issues.insert(.missingRollbackPointer)
            return LastKnownGoodSelection(
                payload: nil,
                issues: LastKnownGoodStoreIssue.allCases.filter { issues.contains($0) },
                rollbackPointer: nil
            )
        }
        if payload.declaredSHA256 != rollbackPointer.lowercased() {
            issues.insert(.hashMismatch)
        }

        let loadResult = store.load(bundled: nil, cached: nil, lastKnownGood: payload)
        if loadResult.hasPack == false {
            issues.insert(.quarantined)
        }

        return LastKnownGoodSelection(
            payload: issues.isEmpty ? payload : nil,
            issues: LastKnownGoodStoreIssue.allCases.filter { issues.contains($0) },
            rollbackPointer: rollbackPointer
        )
    }
}
