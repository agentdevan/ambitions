import Foundation

enum RuntimeIdentityKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case command
    case aggregate
    case event
    case receipt
    case projectionCursor = "projection_cursor"
    case externalOperation = "external_operation"
    case migration
    case storeGeneration = "store_generation"
    case blob
    case domainObject = "domain_object"
}

protocol RuntimeIdentityValue: RawRepresentable, Codable, Sendable, Hashable, Comparable where RawValue == String {
    static var identityKind: RuntimeIdentityKind { get }
}

extension RuntimeIdentityValue {
    init(validating rawValue: String) throws {
        guard let identity = Self(rawValue: rawValue) else {
            throw RuntimeFoundationError.invalidIdentity(Self.identityKind)
        }
        self = identity
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        guard let identity = Self(rawValue: rawValue) else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Invalid \(Self.identityKind.rawValue) runtime identity."
            )
        }
        self = identity
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }

    static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.rawValue.utf8.lexicographicallyPrecedes(rhs.rawValue.utf8)
    }
}

struct RuntimeCommandID: RuntimeIdentityValue {
    static let identityKind = RuntimeIdentityKind.command
    let rawValue: String

    init?(rawValue: String) {
        guard let normalized = RuntimeIdentityNormalizer.normalize(rawValue) else { return nil }
        self.rawValue = normalized
    }
}

struct RuntimeAggregateID: RuntimeIdentityValue {
    static let identityKind = RuntimeIdentityKind.aggregate
    let rawValue: String

    init?(rawValue: String) {
        guard let normalized = RuntimeIdentityNormalizer.normalize(rawValue) else { return nil }
        self.rawValue = normalized
    }
}

struct RuntimeEventID: RuntimeIdentityValue {
    static let identityKind = RuntimeIdentityKind.event
    let rawValue: String

    init?(rawValue: String) {
        guard let normalized = RuntimeIdentityNormalizer.normalize(rawValue) else { return nil }
        self.rawValue = normalized
    }
}

struct RuntimeReceiptID: RuntimeIdentityValue {
    static let identityKind = RuntimeIdentityKind.receipt
    let rawValue: String

    init?(rawValue: String) {
        guard let normalized = RuntimeIdentityNormalizer.normalize(rawValue) else { return nil }
        self.rawValue = normalized
    }
}

struct RuntimeProjectionCursorID: RuntimeIdentityValue {
    static let identityKind = RuntimeIdentityKind.projectionCursor
    let rawValue: String

    init?(rawValue: String) {
        guard let normalized = RuntimeIdentityNormalizer.normalize(rawValue) else { return nil }
        self.rawValue = normalized
    }
}

struct RuntimeExternalOperationID: RuntimeIdentityValue {
    static let identityKind = RuntimeIdentityKind.externalOperation
    let rawValue: String

    init?(rawValue: String) {
        guard let normalized = RuntimeIdentityNormalizer.normalize(rawValue) else { return nil }
        self.rawValue = normalized
    }
}

struct RuntimeMigrationID: RuntimeIdentityValue {
    static let identityKind = RuntimeIdentityKind.migration
    let rawValue: String

    init?(rawValue: String) {
        guard let normalized = RuntimeIdentityNormalizer.normalize(rawValue) else { return nil }
        self.rawValue = normalized
    }
}

struct RuntimeStoreGenerationID: RuntimeIdentityValue {
    static let identityKind = RuntimeIdentityKind.storeGeneration
    let rawValue: String

    init?(rawValue: String) {
        guard let normalized = RuntimeIdentityNormalizer.normalize(rawValue) else { return nil }
        self.rawValue = normalized
    }
}

struct RuntimeBlobID: RuntimeIdentityValue {
    static let identityKind = RuntimeIdentityKind.blob
    let rawValue: String

    init?(rawValue: String) {
        guard let normalized = RuntimeIdentityNormalizer.normalize(rawValue) else { return nil }
        self.rawValue = normalized
    }
}

struct RuntimeDomainObjectID: RuntimeIdentityValue {
    static let identityKind = RuntimeIdentityKind.domainObject
    let rawValue: String

    init?(rawValue: String) {
        guard let normalized = RuntimeIdentityNormalizer.normalize(rawValue) else { return nil }
        self.rawValue = normalized
    }
}

private enum RuntimeIdentityNormalizer {
    static func normalize(_ rawValue: String) -> String? {
        guard rawValue.unicodeScalars.contains(where: CharacterSet.controlCharacters.contains) == false else {
            return nil
        }
        let trimmed = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false else { return nil }
        return trimmed.precomposedStringWithCanonicalMapping
    }
}
