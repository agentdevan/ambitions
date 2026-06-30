import CryptoKit
import Foundation

struct RuntimeEventChecksumMaterial: Codable, Equatable, Hashable {
    let id: String
    let sequence: Int64
    let previousChecksum: String?
    let causalClock: RuntimeCausalClock
    let event: RuntimeEvent
    let schemaVersion: String
}

enum RuntimeEventChecksum {
    static let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        return encoder
    }()

    static func digest(_ material: RuntimeEventChecksumMaterial) throws -> String {
        let data = try encoder.encode(material)
        let digest = SHA256.hash(data: data)
        return digest.map { String(format: "%02x", $0) }.joined()
    }

    static func isValid(_ envelope: RuntimeEventEnvelope) -> Bool {
        (try? digest(envelope.checksumMaterial)) == envelope.checksum
    }
}
