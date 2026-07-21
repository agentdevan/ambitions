import CryptoKit
import Foundation

protocol PendingEventKitOperationStoring: Sendable {
    func resolve(fingerprint: String, proposedOperationID: String) async throws -> String
    func complete(fingerprint: String, operationID: String) async throws
}

actor MemoryPendingEventKitOperationStore: PendingEventKitOperationStoring {
    private var operationIDs: [String: String] = [:]

    func resolve(fingerprint: String, proposedOperationID: String) async throws -> String {
        if let existing = operationIDs[fingerprint] { return existing }
        let operationID = UUID(uuidString: proposedOperationID)?.uuidString.lowercased()
            ?? UUID().uuidString.lowercased()
        operationIDs[fingerprint] = operationID
        return operationID
    }

    func complete(fingerprint: String, operationID: String) async throws {
        guard operationIDs[fingerprint] == operationID else { return }
        operationIDs.removeValue(forKey: fingerprint)
    }
}

actor FilePendingEventKitOperationStore: PendingEventKitOperationStoring {
    private struct Envelope: Codable {
        var operationIDs: [String: String] = [:]
    }

    let fileURL: URL
    private let fileManager: FileManager

    init(fileURL: URL, fileManager: FileManager = .default) {
        self.fileURL = fileURL
        self.fileManager = fileManager
    }

    func resolve(fingerprint: String, proposedOperationID: String) async throws -> String {
        var resolved = proposedOperationID
        try coordinatedWrite { envelope in
            if let existing = envelope.operationIDs[fingerprint] {
                resolved = existing
            } else {
                resolved = UUID(uuidString: proposedOperationID)?.uuidString.lowercased()
                    ?? UUID().uuidString.lowercased()
                envelope.operationIDs[fingerprint] = resolved
            }
        }
        return resolved
    }

    func complete(fingerprint: String, operationID: String) async throws {
        try coordinatedWrite { envelope in
            guard envelope.operationIDs[fingerprint] == operationID else { return }
            envelope.operationIDs.removeValue(forKey: fingerprint)
        }
    }

    static func defaultStore() -> FilePendingEventKitOperationStore {
        let externalURL = SharedExternalCreationStore().sideEffectLedgerFileURL()
        return FilePendingEventKitOperationStore(
            fileURL: externalURL.deletingLastPathComponent().appendingPathComponent("eventkit-pending-operations.json")
        )
    }

    static func fingerprint(kind: String, goalID: String, stepID: String) -> String {
        let semanticIdentity = [kind, goalID, stepID].joined(separator: "\u{1f}")
        let digest = SHA256.hash(data: Data(semanticIdentity.utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
    }

    private func coordinatedWrite(_ mutation: (inout Envelope) throws -> Void) throws {
        try fileManager.createDirectory(
            at: fileURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        let directoryURL = fileURL.deletingLastPathComponent()
        let coordinator = NSFileCoordinator(filePresenter: nil)
        var coordinationError: NSError?
        var result: Result<Void, Error>?
        coordinator.coordinate(
            writingItemAt: directoryURL,
            options: [],
            error: &coordinationError
        ) { coordinatedDirectoryURL in
            let coordinatedURL = coordinatedDirectoryURL.appendingPathComponent(fileURL.lastPathComponent)
            result = Result {
                var envelope: Envelope
                if fileManager.fileExists(atPath: coordinatedURL.path) {
                    envelope = try JSONDecoder().decode(Envelope.self, from: Data(contentsOf: coordinatedURL))
                } else {
                    envelope = Envelope()
                }
                try mutation(&envelope)
                let encoder = JSONEncoder()
                encoder.outputFormatting = [.sortedKeys]
                try encoder.encode(envelope).write(to: coordinatedURL, options: .atomic)
            }
        }
        if let coordinationError { throw coordinationError }
        guard let result else { throw CocoaError(.fileWriteUnknown) }
        try result.get()
    }
}
