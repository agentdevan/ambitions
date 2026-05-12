import Foundation

enum ConflictPolicySignal: Codable, Sendable, Equatable {
    case noConflict
    case acceptIncoming
    case keepLocal
    case requiresUserDecision
}

struct ConflictPolicyDecision: Codable, Sendable, Equatable {
    let signal: ConflictPolicySignal
    let localMarker: String?
    let incomingMarker: String?
    let reason: String
}

struct ConflictPolicyCandidate: Sendable, Equatable {
    let entityKind: String
    let localRevision: Int?
    let incomingRevision: Int?
    let localUpdatedAt: String?
    let incomingUpdatedAt: String?
    let valuesAreEqual: Bool
    let safeAutomaticMergeAllowed: Bool

    init(
        entityKind: String,
        localRevision: Int? = nil,
        incomingRevision: Int? = nil,
        localUpdatedAt: String? = nil,
        incomingUpdatedAt: String? = nil,
        valuesAreEqual: Bool,
        safeAutomaticMergeAllowed: Bool = true
    ) {
        self.entityKind = entityKind
        self.localRevision = localRevision
        self.incomingRevision = incomingRevision
        self.localUpdatedAt = localUpdatedAt
        self.incomingUpdatedAt = incomingUpdatedAt
        self.valuesAreEqual = valuesAreEqual
        self.safeAutomaticMergeAllowed = safeAutomaticMergeAllowed
    }
}

struct LocalConflictPolicyEngine: Sendable {
    func decide(_ candidate: ConflictPolicyCandidate) -> ConflictPolicyDecision {
        if candidate.valuesAreEqual {
            return ConflictPolicyDecision(
                signal: .noConflict,
                localMarker: candidate.localRevision.map(String.init) ?? candidate.localUpdatedAt,
                incomingMarker: candidate.incomingRevision.map(String.init) ?? candidate.incomingUpdatedAt,
                reason: "Local and incoming \(candidate.entityKind) data already match."
            )
        }

        guard candidate.safeAutomaticMergeAllowed else {
            return ConflictPolicyDecision(
                signal: .requiresUserDecision,
                localMarker: marker(revision: candidate.localRevision, updatedAt: candidate.localUpdatedAt),
                incomingMarker: marker(revision: candidate.incomingRevision, updatedAt: candidate.incomingUpdatedAt),
                reason: "\(candidate.entityKind.capitalized) data does not have a safe automatic merge signal."
            )
        }

        if let localRevision = candidate.localRevision, let incomingRevision = candidate.incomingRevision {
            if incomingRevision > localRevision {
                return ConflictPolicyDecision(
                    signal: .acceptIncoming,
                    localMarker: String(localRevision),
                    incomingMarker: String(incomingRevision),
                    reason: "Incoming \(candidate.entityKind) revision is newer than local data."
                )
            }
            if incomingRevision < localRevision {
                return ConflictPolicyDecision(
                    signal: .keepLocal,
                    localMarker: String(localRevision),
                    incomingMarker: String(incomingRevision),
                    reason: "Local \(candidate.entityKind) revision is newer than the incoming snapshot."
                )
            }
        }

        switch compareTimestamp(local: candidate.localUpdatedAt, incoming: candidate.incomingUpdatedAt) {
        case .acceptIncoming:
            return ConflictPolicyDecision(
                signal: .acceptIncoming,
                localMarker: candidate.localUpdatedAt,
                incomingMarker: candidate.incomingUpdatedAt,
                reason: "Incoming \(candidate.entityKind) timestamp is newer than local data."
            )
        case .keepLocal:
            return ConflictPolicyDecision(
                signal: .keepLocal,
                localMarker: candidate.localUpdatedAt,
                incomingMarker: candidate.incomingUpdatedAt,
                reason: "Local \(candidate.entityKind) data is newer than the incoming snapshot."
            )
        case .requiresDecision:
            return ConflictPolicyDecision(
                signal: .requiresUserDecision,
                localMarker: marker(revision: candidate.localRevision, updatedAt: candidate.localUpdatedAt),
                incomingMarker: marker(revision: candidate.incomingRevision, updatedAt: candidate.incomingUpdatedAt),
                reason: "\(candidate.entityKind.capitalized) data differs without a safe automatic merge signal."
            )
        }
    }

    private enum TimestampComparison {
        case acceptIncoming
        case keepLocal
        case requiresDecision
    }

    private func compareTimestamp(local: String?, incoming: String?) -> TimestampComparison {
        switch (local, incoming) {
        case let (local?, incoming?) where incoming > local:
            return .acceptIncoming
        case let (local?, incoming?) where incoming < local:
            return .keepLocal
        default:
            return .requiresDecision
        }
    }

    private func marker(revision: Int?, updatedAt: String?) -> String? {
        switch (revision, updatedAt) {
        case let (revision?, updatedAt?):
            return "\(revision)|\(updatedAt)"
        case let (revision?, nil):
            return String(revision)
        case let (nil, updatedAt?):
            return updatedAt
        default:
            return nil
        }
    }
}
