import Foundation

public struct RuntimeEvent: Codable, Sendable, Equatable {
    public let id: String
    public let kind: String
    public let aggregate: RuntimeAggregateReference
    public let aggregateRevision: Int64
    public let payload: Data

    public init(
        id: String,
        kind: String,
        aggregate: RuntimeAggregateReference,
        aggregateRevision: Int64,
        payload: Data
    ) {
        self.id = id
        self.kind = kind
        self.aggregate = aggregate
        self.aggregateRevision = aggregateRevision
        self.payload = payload
    }
}

public struct RuntimeStateChange: Codable, Sendable, Equatable {
    public let aggregate: RuntimeAggregateReference
    public let expectedRevision: Int64?
    public let newRevision: Int64
    public let value: Data

    public init(
        aggregate: RuntimeAggregateReference,
        expectedRevision: Int64?,
        newRevision: Int64,
        value: Data
    ) {
        self.aggregate = aggregate
        self.expectedRevision = expectedRevision
        self.newRevision = newRevision
        self.value = value
    }
}

public struct RuntimeProjectionChange: Codable, Sendable, Equatable {
    public let projection: String
    public let cursor: String
    public let payload: Data

    public init(projection: String, cursor: String, payload: Data) {
        self.projection = projection
        self.cursor = cursor
        self.payload = payload
    }
}

public struct RuntimeExternalEffectEnvelope: Codable, Sendable, Equatable {
    public let id: String
    public let kind: String
    public let idempotencyKey: String
    public let payload: Data

    public init(
        id: String,
        kind: String,
        idempotencyKey: String,
        payload: Data
    ) {
        self.id = id
        self.kind = kind
        self.idempotencyKey = idempotencyKey
        self.payload = payload
    }
}

public enum RuntimeCompensation: Codable, Sendable, Equatable {
    case inverseCommand(RuntimeCommand)
    case compensatingCommand(RuntimeCommand)
}

public struct RuntimeReceipt: Codable, Sendable, Equatable {
    public let id: String
    public let commandID: String
    public let canonicalRevision: Int64
    public let eventIDs: [String]
    public let projectionCursors: [String: String]
    public let externalEffectIDs: [String]
    public let semanticUndoEligible: Bool

    public init(
        id: String,
        commandID: String,
        canonicalRevision: Int64,
        eventIDs: [String],
        projectionCursors: [String: String],
        externalEffectIDs: [String],
        semanticUndoEligible: Bool
    ) {
        self.id = id
        self.commandID = commandID
        self.canonicalRevision = canonicalRevision
        self.eventIDs = eventIDs
        self.projectionCursors = projectionCursors
        self.externalEffectIDs = externalEffectIDs
        self.semanticUndoEligible = semanticUndoEligible
    }
}

public enum RuntimeInvariantViolation: String, Error, Sendable, Equatable {
    case emptyCommandIdentity
    case mutationHasNoEvents
    case mutationHasNoStateChanges
    case receiptCommandIdentityMismatch
    case receiptEventIdentityMismatch
    case receiptProjectionIdentityMismatch
    case receiptExternalEffectIdentityMismatch
    case invalidRevisionTransition
    case undoEligibilityMismatch
}

public struct RuntimeTransition: Codable, Sendable, Equatable {
    public let commandID: String
    public let stateChanges: [RuntimeStateChange]
    public let events: [RuntimeEvent]
    public let projectionChanges: [RuntimeProjectionChange]
    public let receipt: RuntimeReceipt
    public let compensation: RuntimeCompensation?
    public let externalEffects: [RuntimeExternalEffectEnvelope]

    public init(
        commandID: String,
        stateChanges: [RuntimeStateChange],
        events: [RuntimeEvent],
        projectionChanges: [RuntimeProjectionChange],
        receipt: RuntimeReceipt,
        compensation: RuntimeCompensation?,
        externalEffects: [RuntimeExternalEffectEnvelope]
    ) {
        self.commandID = commandID
        self.stateChanges = stateChanges
        self.events = events
        self.projectionChanges = projectionChanges
        self.receipt = receipt
        self.compensation = compensation
        self.externalEffects = externalEffects
    }

    public func validate() throws {
        guard !commandID.isEmpty else {
            throw RuntimeInvariantViolation.emptyCommandIdentity
        }
        guard !events.isEmpty else {
            throw RuntimeInvariantViolation.mutationHasNoEvents
        }
        guard !stateChanges.isEmpty else {
            throw RuntimeInvariantViolation.mutationHasNoStateChanges
        }
        guard receipt.commandID == commandID else {
            throw RuntimeInvariantViolation.receiptCommandIdentityMismatch
        }
        guard receipt.eventIDs == events.map(\.id) else {
            throw RuntimeInvariantViolation.receiptEventIdentityMismatch
        }
        guard receipt.projectionCursors == Dictionary(
            uniqueKeysWithValues: projectionChanges.map {
                ($0.projection, $0.cursor)
            }
        ) else {
            throw RuntimeInvariantViolation.receiptProjectionIdentityMismatch
        }
        guard receipt.externalEffectIDs == externalEffects.map(\.id) else {
            throw RuntimeInvariantViolation.receiptExternalEffectIdentityMismatch
        }
        guard stateChanges.allSatisfy({ change in
            let expectedNewRevision = (change.expectedRevision ?? 0) + 1
            return change.newRevision == expectedNewRevision
        }) else {
            throw RuntimeInvariantViolation.invalidRevisionTransition
        }
        guard receipt.semanticUndoEligible == (compensation != nil) else {
            throw RuntimeInvariantViolation.undoEligibilityMismatch
        }
    }
}
