import Foundation

public struct RuntimeCommitResult: Codable, Sendable, Equatable {
    public let receiptID: String
    public let canonicalRevision: Int64
    public let projectionCursors: [String: String]
    public let semanticUndoEligible: Bool

    public init(
        receiptID: String,
        canonicalRevision: Int64,
        projectionCursors: [String: String],
        semanticUndoEligible: Bool
    ) {
        self.receiptID = receiptID
        self.canonicalRevision = canonicalRevision
        self.projectionCursors = projectionCursors
        self.semanticUndoEligible = semanticUndoEligible
    }
}

public struct RuntimeRejection: Codable, Sendable, Equatable {
    public let code: String
    public let recovery: String

    public init(code: String, recovery: String) {
        self.code = code
        self.recovery = recovery
    }
}

public struct RuntimeConflict: Codable, Sendable, Equatable {
    public let expectedRevision: Int64
    public let actualRevision: Int64

    public init(expectedRevision: Int64, actualRevision: Int64) {
        self.expectedRevision = expectedRevision
        self.actualRevision = actualRevision
    }
}

public struct RuntimeExternalEffectFailure: Codable, Sendable, Equatable {
    public let effectID: String
    public let code: String
    public let recovery: String

    public init(effectID: String, code: String, recovery: String) {
        self.effectID = effectID
        self.code = code
        self.recovery = recovery
    }
}

public enum RuntimeOutcomeState: String, Codable, Sendable, CaseIterable {
    case committed
    case committedNeedsProjectionCatchUp = "committed_needs_projection_catch_up"
    case rejected
    case conflicted
    case externalEffectPending = "external_effect_pending"
    case externalEffectReconciled = "external_effect_reconciled"
    case externalEffectFailed = "external_effect_failed"
}

public enum RuntimeOutcome: Codable, Sendable, Equatable {
    case committed(RuntimeCommitResult)
    case committedNeedsProjectionCatchUp(
        RuntimeCommitResult,
        pendingProjections: [String]
    )
    case rejected(RuntimeRejection)
    case conflicted(RuntimeConflict)
    case externalEffectPending(RuntimeCommitResult, effectIDs: [String])
    case externalEffectReconciled(RuntimeCommitResult, effectIDs: [String])
    case externalEffectFailed(
        RuntimeCommitResult,
        failures: [RuntimeExternalEffectFailure]
    )

    public var state: RuntimeOutcomeState {
        switch self {
        case .committed:
            .committed
        case .committedNeedsProjectionCatchUp:
            .committedNeedsProjectionCatchUp
        case .rejected:
            .rejected
        case .conflicted:
            .conflicted
        case .externalEffectPending:
            .externalEffectPending
        case .externalEffectReconciled:
            .externalEffectReconciled
        case .externalEffectFailed:
            .externalEffectFailed
        }
    }
}
