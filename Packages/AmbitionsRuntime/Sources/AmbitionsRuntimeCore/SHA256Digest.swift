import CryptoKit
import Foundation

/// A validated, stable SHA-256 digest value.
public struct SHA256Digest: Hashable, Sendable {
    public static let byteCount = 32

    private let storage: [UInt8]

    public init(bytes: [UInt8]) throws {
        guard bytes.count == Self.byteCount else {
            throw SHA256DigestError.invalidDigest
        }
        storage = bytes
    }

    public init(hexadecimal: String) throws {
        guard hexadecimal.count == Self.byteCount * 2 else {
            throw SHA256DigestError.invalidDigest
        }

        var bytes: [UInt8] = []
        bytes.reserveCapacity(Self.byteCount)
        var index = hexadecimal.startIndex
        for _ in 0..<Self.byteCount {
            let nextIndex = hexadecimal.index(index, offsetBy: 2)
            guard let byte = UInt8(String(hexadecimal[index..<nextIndex]), radix: 16) else {
                throw SHA256DigestError.invalidDigest
            }
            bytes.append(byte)
            index = nextIndex
        }
        storage = bytes
    }

    private init(uncheckedBytes: [UInt8]) {
        storage = uncheckedBytes
    }

    public static func digest(_ data: Data) -> Self {
        Self(uncheckedBytes: Array(CryptoKit.SHA256.hash(data: data)))
    }

    public static func digest<Value: Encodable>(
        canonicalEncoding value: Value,
        using encoder: CanonicalByteEncoder = CanonicalByteEncoder()
    ) throws -> Self {
        digest(try encoder.encode(value))
    }

    public var bytes: [UInt8] {
        storage
    }

    public var data: Data {
        Data(storage)
    }

    public var hexadecimal: String {
        storage.map { String(format: "%02x", $0) }.joined()
    }
}

extension SHA256Digest: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        try self.init(hexadecimal: container.decode(String.self))
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(hexadecimal)
    }
}

extension SHA256Digest: CustomStringConvertible {
    public var description: String {
        hexadecimal
    }
}

public enum SHA256DigestError: Error, Sendable, Equatable {
    case invalidDigest
}

extension SHA256DigestError: CustomStringConvertible, LocalizedError {
    public var description: String {
        "The SHA-256 digest is invalid."
    }

    public var errorDescription: String? {
        description
    }
}
