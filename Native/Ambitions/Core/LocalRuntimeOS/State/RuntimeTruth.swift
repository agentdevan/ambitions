import Foundation

enum RuntimeTruthState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case current
    case proposed
    case accepted
    case external
    case stale
    case unknown
    case historical
    case saving
    case pending
    case settledChanged = "settled_changed"
    case settledUnchanged = "settled_unchanged"
    case blocked
    case failed
    case conflict
    case recovering
    case recovered
    case irreversible
    case undoAvailable = "undo_available"
}

enum RuntimeTruthOwner: Codable, Sendable, Equatable, Hashable {
    case runtime
    case aggregate(RuntimeAggregateID)
    case domainObject(RuntimeDomainObjectID)
    case externalOperation(RuntimeExternalOperationID)
}

enum RuntimeTruthSubject: Codable, Sendable, Equatable, Hashable {
    case aggregate(RuntimeAggregateID)
    case domainObject(RuntimeDomainObjectID)
    case externalOperation(RuntimeExternalOperationID)
}

enum RuntimeTruthProvenance: Codable, Sendable, Equatable, Hashable {
    case command(RuntimeCommandID)
    case event(RuntimeEventID)
    case receipt(RuntimeReceiptID)
    case externalOperation(RuntimeExternalOperationID)
    case migration(RuntimeMigrationID)
    case system
}

struct RuntimeTruthFact: Codable, Sendable, Equatable, Hashable {
    let state: RuntimeTruthState
    let owner: RuntimeTruthOwner
    let subject: RuntimeTruthSubject
    let revision: UInt64
    let observedAt: Date
    let provenance: RuntimeTruthProvenance
    let permittedTransitions: [RuntimeTruthState]

    private enum CodingKeys: String, CodingKey {
        case state
        case owner
        case subject
        case revision
        case observedAt
        case provenance
        case permittedTransitions
    }

    init<Transitions: Sequence>(
        state: RuntimeTruthState,
        owner: RuntimeTruthOwner,
        subject: RuntimeTruthSubject,
        revision: UInt64,
        observedAt: Date,
        provenance: RuntimeTruthProvenance,
        permittedTransitions: Transitions
    ) where Transitions.Element == RuntimeTruthState {
        self.state = state
        self.owner = owner
        self.subject = subject
        self.revision = revision
        self.observedAt = observedAt
        self.provenance = provenance
        let uniqueTransitions = Set(permittedTransitions)
        self.permittedTransitions = RuntimeTruthState.allCases.filter(uniqueTransitions.contains)
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            state: try container.decode(RuntimeTruthState.self, forKey: .state),
            owner: try container.decode(RuntimeTruthOwner.self, forKey: .owner),
            subject: try container.decode(RuntimeTruthSubject.self, forKey: .subject),
            revision: try container.decode(UInt64.self, forKey: .revision),
            observedAt: try container.decode(Date.self, forKey: .observedAt),
            provenance: try container.decode(RuntimeTruthProvenance.self, forKey: .provenance),
            permittedTransitions: try container.decode([RuntimeTruthState].self, forKey: .permittedTransitions)
        )
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(state, forKey: .state)
        try container.encode(owner, forKey: .owner)
        try container.encode(subject, forKey: .subject)
        try container.encode(revision, forKey: .revision)
        try container.encode(observedAt, forKey: .observedAt)
        try container.encode(provenance, forKey: .provenance)
        try container.encode(permittedTransitions, forKey: .permittedTransitions)
    }

    func permitsTransition(to state: RuntimeTruthState) -> Bool {
        permittedTransitions.contains(state)
    }
}
