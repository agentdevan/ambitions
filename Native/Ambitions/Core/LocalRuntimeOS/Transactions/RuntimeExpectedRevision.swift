import Foundation

enum RuntimeExpectedRevision: Codable, Sendable, Equatable, Hashable {
    case absent
    case exact(UInt64)

    private enum Kind: String, Codable {
        case absent
        case exact
    }

    private enum CodingKeys: String, CodingKey, CaseIterable {
        case kind
        case revision
    }

    private struct AnyCodingKey: CodingKey {
        let stringValue: String
        let intValue: Int?

        init?(stringValue: String) {
            self.stringValue = stringValue
            self.intValue = nil
        }

        init?(intValue: Int) {
            self.stringValue = String(intValue)
            self.intValue = intValue
        }
    }

    init(from decoder: Decoder) throws {
        let allFields = try decoder.container(keyedBy: AnyCodingKey.self).allKeys
        let supportedFields = Set(CodingKeys.allCases.map(\.rawValue))
        guard allFields.allSatisfy({ supportedFields.contains($0.stringValue) }) else {
            throw DecodingError.dataCorrupted(
                .init(codingPath: decoder.codingPath, debugDescription: "Unexpected expected-revision field.")
            )
        }

        let container = try decoder.container(keyedBy: CodingKeys.self)
        switch try container.decode(Kind.self, forKey: .kind) {
        case .absent:
            guard container.contains(.revision) == false else {
                throw DecodingError.dataCorruptedError(
                    forKey: .revision,
                    in: container,
                    debugDescription: "Absent expected revision cannot include a revision value."
                )
            }
            self = .absent
        case .exact:
            guard container.contains(.revision) else {
                throw DecodingError.keyNotFound(
                    CodingKeys.revision,
                    .init(codingPath: decoder.codingPath, debugDescription: "Exact expected revision requires a revision value.")
                )
            }
            self = .exact(try container.decode(UInt64.self, forKey: .revision))
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .absent:
            try container.encode(Kind.absent, forKey: .kind)
        case let .exact(revision):
            try container.encode(Kind.exact, forKey: .kind)
            try container.encode(revision, forKey: .revision)
        }
    }
}
