import Foundation

public struct TemporarySQLiteStore: Sendable {
    public let directoryURL: URL
    public let databaseURL: URL

    public static func create(
        fileName: String = "store.sqlite"
    ) throws -> Self {
        guard !fileName.isEmpty,
              fileName != ".",
              fileName != "..",
              URL(fileURLWithPath: fileName).lastPathComponent == fileName
        else {
            throw TemporarySQLiteStoreError.invalidFileName
        }

        let directoryURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        do {
            try FileManager.default.createDirectory(
                at: directoryURL,
                withIntermediateDirectories: false
            )
        } catch {
            throw TemporarySQLiteStoreError.creationFailed
        }
        return Self(
            directoryURL: directoryURL,
            databaseURL: directoryURL.appendingPathComponent(fileName)
        )
    }

    public func remove() throws {
        do {
            try FileManager.default.removeItem(at: directoryURL)
        } catch {
            throw TemporarySQLiteStoreError.removalFailed
        }
    }
}

public enum TemporarySQLiteStoreError: Error, Sendable, Equatable {
    case invalidFileName
    case creationFailed
    case removalFailed
}

extension TemporarySQLiteStoreError: CustomStringConvertible, LocalizedError {
    public var description: String {
        switch self {
        case .invalidFileName:
            "The temporary database file name is invalid."
        case .creationFailed:
            "The temporary database directory could not be created."
        case .removalFailed:
            "The temporary database directory could not be removed."
        }
    }

    public var errorDescription: String? {
        description
    }
}
