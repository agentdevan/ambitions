import CryptoKit
import Foundation

enum SharedExternalSnapshotStore {
    static let appGroupIdentifier = "group.com.ambitions.shared"
    static let relativeDirectory = "ExternalSnapshots"
    static let fileName = "external-snapshot.v1.json"
    static let snapshotRecordID = "external-surface-current"
    static let snapshotKind = "widget_projection_external_surface"

    static func snapshotFileURL(fileManager: FileManager = .default) -> URL? {
        snapshotDirectoryURL(fileManager: fileManager)?.appendingPathComponent(fileName)
    }

    static func snapshotRecordFileURL(fileManager: FileManager = .default) -> URL? {
        snapshotDirectoryURL(fileManager: fileManager)?.appendingPathComponent("\(snapshotRecordID).snapshot.json")
    }

    private static func snapshotDirectoryURL(fileManager: FileManager) -> URL? {
        fileManager.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier)?
            .appendingPathComponent(relativeDirectory, isDirectory: true)
    }
}

struct SharedExternalSnapshotRecord: Codable, Sendable, Equatable {
    let id: String
    let snapshotKind: String
    let createdAt: String
    let privacyClasses: [String]
    let containsPrivateRuntimeData: Bool
    let payloadChecksum: String
    let payloadData: Data
    let schemaVersion: String

    var isSafeForExternalProcess: Bool {
        id == SharedExternalSnapshotStore.snapshotRecordID &&
            snapshotKind == SharedExternalSnapshotStore.snapshotKind &&
            containsPrivateRuntimeData == false &&
            privacyClasses.contains("private_user_text") == false &&
            privacyClasses.contains("sensitive") == false &&
            Self.sha256Hex(for: payloadData) == payloadChecksum
    }

    func verifiedPayloadData() throws -> Data {
        guard isSafeForExternalProcess else {
            throw SharedExternalSnapshotRecordError.unsafeOrCorruptSnapshotRecord
        }
        return payloadData
    }

    private static func sha256Hex(for data: Data) -> String {
        SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
    }
}

enum SharedExternalSnapshotRecordError: LocalizedError {
    case unsafeOrCorruptSnapshotRecord

    var errorDescription: String? {
        switch self {
        case .unsafeOrCorruptSnapshotRecord:
            return "External snapshot record is unsafe or corrupt."
        }
    }
}
