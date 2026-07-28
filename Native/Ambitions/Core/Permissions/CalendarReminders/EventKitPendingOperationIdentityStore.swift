import CryptoKit
import Foundation

protocol PendingEventKitOperationStoring: Sendable {
    func resolve(fingerprint: String, proposedOperationID: String) async throws -> String
    func complete(fingerprint: String, operationID: String) async throws
}

enum EventKitPendingOperationRecoveryError: Error, Sendable, Equatable {
    case recoveryRequired(fileName: String)
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

    static func defaultStore() -> FilePendingEventKitOperationStore? {
        guard let localRoot = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            return nil
        }
        return FilePendingEventKitOperationStore(
            fileURL: localRoot
                .appendingPathComponent("Ambitions", isDirectory: true)
                .appendingPathComponent("EventKit", isDirectory: true)
                .appendingPathComponent("eventkit-pending-operations.json")
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
                    try verifyPrivateFileProtection(at: coordinatedURL)
                    envelope = try JSONDecoder().decode(Envelope.self, from: Data(contentsOf: coordinatedURL))
                } else {
                    envelope = Envelope()
                }
                try mutation(&envelope)
                let encoder = JSONEncoder()
                encoder.outputFormatting = [.sortedKeys]
                try writeProtectedAtomically(try encoder.encode(envelope), to: coordinatedURL)
            }
        }
        if let coordinationError { throw coordinationError }
        guard let result else { throw CocoaError(.fileWriteUnknown) }
        try result.get()
    }

    private func applyPrivateFileProtection(to url: URL) throws {
        #if os(iOS)
        try fileManager.setAttributes(
            [.protectionKey: FileProtectionType.complete],
            ofItemAtPath: url.path
        )
        #else
        _ = url
        #endif
    }

    private func writeProtectedAtomically(_ data: Data, to destination: URL) throws {
        let directory = destination.deletingLastPathComponent()
        try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        try applyPrivateFileProtection(to: directory)
        let stagingFile = directory.appendingPathComponent(
            ".\(destination.lastPathComponent).\(UUID().uuidString.lowercased()).pending"
        )
        let rollback = directory.appendingPathComponent(
            ".\(destination.lastPathComponent).\(UUID().uuidString.lowercased()).rollback"
        )
        guard fileManager.createFile(atPath: stagingFile.path, contents: nil) else {
            throw CocoaError(.fileWriteUnknown)
        }
        var didActivate = false
        do {
            try applyPrivateFileProtection(to: stagingFile)
            try verifyPrivateFileProtection(at: stagingFile)
            try data.write(to: stagingFile)
            try verifyPrivateFileProtection(at: stagingFile)
            if fileManager.fileExists(atPath: destination.path) {
                _ = try fileManager.replaceItemAt(
                    destination,
                    withItemAt: stagingFile,
                    backupItemName: rollback.lastPathComponent
                )
                didActivate = true
                try verifyPrivateFileProtection(at: rollback)
            } else {
                try fileManager.moveItem(at: stagingFile, to: destination)
                didActivate = true
            }
            try verifyPrivateFileProtection(at: destination)
            try? fileManager.removeItem(at: rollback)
        } catch {
            var recoveryRequired = false
            if didActivate {
                try? fileManager.removeItem(at: destination)
                if fileManager.fileExists(atPath: destination.path) {
                    recoveryRequired = true
                }
                if fileManager.fileExists(atPath: rollback.path) {
                    if (try? verifyPrivateFileProtection(at: rollback)) != nil {
                        if fileManager.fileExists(atPath: destination.path) == false {
                            try? fileManager.copyItem(at: rollback, to: destination)
                        }
                        if (try? verifyPrivateFileProtection(at: destination)) == nil {
                            try? fileManager.removeItem(at: destination)
                            recoveryRequired = true
                        } else {
                            try? fileManager.removeItem(at: rollback)
                        }
                    } else {
                        recoveryRequired = true
                    }
                }
            }
            try? fileManager.removeItem(at: stagingFile)
            if recoveryRequired {
                throw EventKitPendingOperationRecoveryError.recoveryRequired(fileName: destination.lastPathComponent)
            }
            throw error
        }
    }

    private func verifyPrivateFileProtection(at url: URL) throws {
        #if os(iOS)
        let attributes = try fileManager.attributesOfItem(atPath: url.path)
        guard (attributes[.protectionKey] as? FileProtectionType) == .complete else {
            throw CocoaError(.fileWriteNoPermission)
        }
        #else
        _ = url
        #endif
    }
}
