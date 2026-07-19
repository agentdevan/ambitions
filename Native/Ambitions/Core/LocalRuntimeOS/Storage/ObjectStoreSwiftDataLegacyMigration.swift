import Foundation

extension AmbitionsPersistenceStore {
    static func legacyAppGroupPersistentStoreURL(fileManager: FileManager = .default) -> URL? {
        fileManager.containerURL(forSecurityApplicationGroupIdentifier: AppGroupSnapshotStore.appGroupIdentifier)?
            .appendingPathComponent("Library", isDirectory: true)
            .appendingPathComponent("Application Support", isDirectory: true)
            .appendingPathComponent("default.store", isDirectory: false)
    }

    @discardableResult
    static func migrateLegacyAppGroupPersistentStoreIfNeeded(
        to canonicalStoreURL: URL,
        legacyStoreURL: URL?,
        fileManager: FileManager = .default
    ) throws -> Bool {
        guard let legacyStoreURL else {
            return false
        }

        let canonicalPath = canonicalStoreURL.standardizedFileURL.path
        let legacyPath = legacyStoreURL.standardizedFileURL.path
        guard canonicalPath != legacyPath else {
            return false
        }

        let legacyFiles = persistentStoreSidecarURLs(for: legacyStoreURL)
            .filter { fileManager.fileExists(atPath: $0.path) }
        guard legacyFiles.isEmpty == false else {
            return false
        }

        let canonicalFiles = persistentStoreSidecarURLs(for: canonicalStoreURL)
        guard canonicalFiles.contains(where: { fileManager.fileExists(atPath: $0.path) }) == false else {
            return try removeEmptyLegacyStoreFiles(from: legacyFiles, fileManager: fileManager)
        }

        try preparePersistentStoreParentDirectory(for: canonicalStoreURL, fileManager: fileManager)
        for sourceURL in legacyFiles {
            let destinationURL = canonicalStoreURL
                .deletingLastPathComponent()
                .appendingPathComponent(sourceURL.lastPathComponent, isDirectory: false)
            try fileManager.copyItem(at: sourceURL, to: destinationURL)
        }

        for sourceURL in legacyFiles {
            try fileManager.removeItem(at: sourceURL)
        }
        return true
    }

    static func persistentStoreSidecarURLs(for persistentStoreURL: URL?) -> [URL] {
        guard let persistentStoreURL else {
            return []
        }
        let directory = persistentStoreURL.deletingLastPathComponent()
        let fileName = persistentStoreURL.lastPathComponent
        return ["", "-shm", "-wal"].map { suffix in
            directory.appendingPathComponent(fileName + suffix, isDirectory: false)
        }
    }

    private static func removeEmptyLegacyStoreFiles(from legacyFiles: [URL], fileManager: FileManager) throws -> Bool {
        var removedAnyFile = false
        for fileURL in legacyFiles {
            let attributes = try fileManager.attributesOfItem(atPath: fileURL.path)
            let byteCount = (attributes[.size] as? NSNumber)?.int64Value ?? -1
            guard byteCount == 0 else {
                continue
            }
            try fileManager.removeItem(at: fileURL)
            removedAnyFile = true
        }
        return removedAnyFile
    }
}
