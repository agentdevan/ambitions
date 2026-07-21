import Foundation

public struct RuntimeAggregateReference: Codable, Sendable, Equatable, Hashable {
    public let kind: String
    public let id: String

    public init(kind: String, id: String) {
        self.kind = kind
        self.id = id
    }
}

public enum RuntimeCommandOrigin: String, Codable, Sendable, CaseIterable {
    case app
    case appIntent = "app_intent"
    case deepLink = "deep_link"
    case notification
    case shareExtension = "share_extension"
    case widget
    case migration
    case repair
}

public enum RuntimePrivacyClass: String, Codable, Sendable, CaseIterable {
    case `private`
    case sensitive
    case publicReference = "public_reference"
    case redacted
}

public struct RuntimeCommand: Codable, Sendable, Equatable {
    public let id: String
    public let kind: String
    public let aggregate: RuntimeAggregateReference
    public let payload: Data

    public init(
        id: String,
        kind: String,
        aggregate: RuntimeAggregateReference,
        payload: Data
    ) {
        self.id = id
        self.kind = kind
        self.aggregate = aggregate
        self.payload = payload
    }
}

public struct RuntimeExecutionContext: Codable, Sendable, Equatable {
    public let idempotencyKey: String
    public let expectedRevision: Int64?
    public let issuedAt: Date
    public let origin: RuntimeCommandOrigin
    public let privacyClass: RuntimePrivacyClass

    public init(
        idempotencyKey: String,
        expectedRevision: Int64?,
        issuedAt: Date,
        origin: RuntimeCommandOrigin,
        privacyClass: RuntimePrivacyClass
    ) {
        self.idempotencyKey = idempotencyKey
        self.expectedRevision = expectedRevision
        self.issuedAt = issuedAt
        self.origin = origin
        self.privacyClass = privacyClass
    }
}

public struct RuntimeCommandEnvelope: Codable, Sendable, Equatable {
    public let schemaVersion: Int
    public let command: RuntimeCommand
    public let context: RuntimeExecutionContext

    public init(
        schemaVersion: Int = 1,
        command: RuntimeCommand,
        context: RuntimeExecutionContext
    ) {
        self.schemaVersion = schemaVersion
        self.command = command
        self.context = context
    }
}
