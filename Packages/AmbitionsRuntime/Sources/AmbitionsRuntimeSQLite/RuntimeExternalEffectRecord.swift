import Foundation
import AmbitionsRuntimeCore

public enum RuntimeExternalEffectStatus: String, Codable, Sendable, Equatable {
    case pending
    case claimed
    case reconciled
    case failed
}

public struct RuntimeExternalEffectClaim: Codable, Sendable, Equatable {
    public let id: String
    public let claimedAt: Date

    public init(id: String, claimedAt: Date) {
        self.id = id
        self.claimedAt = claimedAt
    }
}

public struct RuntimeExternalEffectRecord: Sendable, Equatable {
    public let envelope: RuntimeExternalEffectEnvelope
    public let status: RuntimeExternalEffectStatus
    public let attemptCount: Int64
    public let claim: RuntimeExternalEffectClaim?
    public let failureDescription: String?

    public init(
        envelope: RuntimeExternalEffectEnvelope,
        status: RuntimeExternalEffectStatus,
        attemptCount: Int64,
        claim: RuntimeExternalEffectClaim?,
        failureDescription: String?
    ) {
        self.envelope = envelope
        self.status = status
        self.attemptCount = attemptCount
        self.claim = claim
        self.failureDescription = failureDescription
    }
}

public enum RuntimeExternalEffectError: Error, Sendable, Equatable {
    case effectNotFound(effectID: String)
    case invalidTransition(
        effectID: String,
        status: RuntimeExternalEffectStatus
    )
    case claimMismatch(
        effectID: String,
        expectedClaimID: String,
        actualClaimID: String
    )
}
