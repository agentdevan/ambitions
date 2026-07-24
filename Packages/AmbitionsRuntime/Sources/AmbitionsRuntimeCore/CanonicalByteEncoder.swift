import Foundation

/// A fixed JSON encoding configuration for deterministic `Codable` bytes.
///
/// This type owns serialization mechanics only. Callers remain responsible for
/// defining the meaning, schema, and compatibility policy of encoded values.
public struct CanonicalByteEncoder: Sendable {
    public init() {}

    public func encode<Value: Encodable>(_ value: Value) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        encoder.dateEncodingStrategy = .millisecondsSince1970
        encoder.dataEncodingStrategy = .base64
        encoder.nonConformingFloatEncodingStrategy = .throw

        do {
            return try encoder.encode(value)
        } catch {
            throw CanonicalEncodingError.encodingFailed
        }
    }
}

public enum CanonicalEncodingError: Error, Sendable, Equatable {
    case encodingFailed
}

extension CanonicalEncodingError: CustomStringConvertible, LocalizedError {
    public var description: String {
        "Canonical byte encoding failed."
    }

    public var errorDescription: String? {
        description
    }
}
