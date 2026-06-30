import CryptoKit
import Foundation

struct ProjectionChecksumMaterial: Codable, Equatable, Hashable {
    let projectionID: ProjectionID
    let definitionSchemaVersion: String
    let materializedAt: String
    let eventCursors: [RuntimeEventCursor]
    let recordIDs: [String]
    let payloadFingerprint: String
}

enum ProjectionChecksum {
    static let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        return encoder
    }()

    static func digest<T: Encodable>(_ value: T) throws -> String {
        let data = try encoder.encode(value)
        let digest = SHA256.hash(data: data)
        return digest.map { String(format: "%02x", $0) }.joined()
    }

    static func cursor(
        projectionID: ProjectionID,
        definition: ProjectionDefinition,
        materializedAt: String,
        records: [ProjectionEventRecord],
        payloadFingerprint: String
    ) throws -> ProjectionCursor {
        let material = ProjectionChecksumMaterial(
            projectionID: projectionID,
            definitionSchemaVersion: definition.schemaVersion,
            materializedAt: materializedAt,
            eventCursors: records.map(\.cursor),
            recordIDs: records.map(\.id),
            payloadFingerprint: payloadFingerprint
        )
        return ProjectionCursor(
            projectionID: projectionID,
            eventCursor: records.last?.cursor,
            checksum: try digest(material),
            materializedAt: materializedAt
        )
    }
}
