import Foundation
import SQLite3

#if canImport(Darwin)
import Darwin
#else
import Glibc
#endif

extension RuntimeStoreMigrationFileSystem {
    static func backupSQLiteStore(
        sourceURL: URL,
        destinationURL: URL
    ) throws {
        let sourceParentDescriptor = try openDirectory(
            at: sourceURL.deletingLastPathComponent()
        )
        defer { close(sourceParentDescriptor) }
        let destinationParentDescriptor = try openDirectory(
            at: destinationURL.deletingLastPathComponent()
        )
        defer { close(destinationParentDescriptor) }
        let sourceParentIdentity = try identity(sourceParentDescriptor)
        let destinationParentIdentity = try identity(destinationParentDescriptor)
        let pinnedSourceURL = URL(
            fileURLWithPath: try canonicalPath(sourceParentDescriptor),
            isDirectory: true
        ).appendingPathComponent(sourceURL.lastPathComponent)
        let pinnedDestinationURL = URL(
            fileURLWithPath: try canonicalPath(destinationParentDescriptor),
            isDirectory: true
        ).appendingPathComponent(destinationURL.lastPathComponent)
        let sourceDescriptor = try openRegularFile(
            parentDescriptor: sourceParentDescriptor,
            name: sourceURL.lastPathComponent,
            flags: O_RDONLY
        )
        defer { close(sourceDescriptor) }
        let destinationDescriptor = try openRegularFile(
            parentDescriptor: destinationParentDescriptor,
            name: destinationURL.lastPathComponent,
            flags: O_RDWR
        )
        defer { close(destinationDescriptor) }
        let sourceIdentity = try identity(sourceDescriptor)
        let destinationIdentity = try identity(destinationDescriptor)
        var source: OpaquePointer?
        var destination: OpaquePointer?
        let sourceFlags = SQLITE_OPEN_READONLY | SQLITE_OPEN_FULLMUTEX
            | SQLITE_OPEN_NOFOLLOW
        let destinationFlags = SQLITE_OPEN_READWRITE | SQLITE_OPEN_FULLMUTEX
            | SQLITE_OPEN_NOFOLLOW
        guard sqlite3_open_v2(
            pinnedSourceURL.path,
            &source,
            sourceFlags,
            nil
        ) == SQLITE_OK, let source else {
            let description = source.map { String(cString: sqlite3_errmsg($0)) }
                ?? "Unable to open captured staged store."
            if let source { sqlite3_close(source) }
            throw RuntimeStoreMigrationError.fileOperationFailed(
                operation: "open captured staged store",
                description: description
            )
        }
        defer { sqlite3_close(source) }
        guard sqlite3_open_v2(
            pinnedDestinationURL.path,
            &destination,
            destinationFlags,
            nil
        ) == SQLITE_OK, let destination else {
            let description = destination.map { String(cString: sqlite3_errmsg($0)) }
                ?? "Unable to open sealed candidate."
            if let destination { sqlite3_close(destination) }
            throw RuntimeStoreMigrationError.fileOperationFailed(
                operation: "open sealed runtime-store candidate",
                description: description
            )
        }
        defer { sqlite3_close(destination) }
        try requireStableDirectory(
            at: pinnedSourceURL.deletingLastPathComponent(),
            expected: sourceParentIdentity
        )
        try requireStableDirectory(
            at: pinnedDestinationURL.deletingLastPathComponent(),
            expected: destinationParentIdentity
        )
        try requireStableIdentity(
            url: pinnedSourceURL,
            flags: O_RDONLY,
            expected: sourceIdentity
        )
        try requireStableIdentity(
            url: pinnedDestinationURL,
            flags: O_RDWR,
            expected: destinationIdentity
        )
        try requireSQLiteFileNotMoved(
            source,
            operation: "pin captured staged store"
        )
        try requireSQLiteFileNotMoved(
            destination,
            operation: "pin sealed runtime-store candidate"
        )
        guard let backup = sqlite3_backup_init(
            destination,
            "main",
            source,
            "main"
        ) else {
            throw RuntimeStoreMigrationError.fileOperationFailed(
                operation: "initialize SQLite backup",
                description: String(cString: sqlite3_errmsg(destination))
            )
        }
        let stepResult = sqlite3_backup_step(backup, -1)
        let finishResult = sqlite3_backup_finish(backup)
        guard stepResult == SQLITE_DONE, finishResult == SQLITE_OK else {
            throw RuntimeStoreMigrationError.fileOperationFailed(
                operation: "seal SQLite verification candidate",
                description: String(cString: sqlite3_errmsg(destination))
            )
        }
    }

    static func checkpointAndTruncateWAL(at url: URL) throws {
        let parentDescriptor = try openDirectory(
            at: url.deletingLastPathComponent()
        )
        defer { close(parentDescriptor) }
        let parentIdentity = try identity(parentDescriptor)
        let pinnedURL = URL(
            fileURLWithPath: try canonicalPath(parentDescriptor),
            isDirectory: true
        ).appendingPathComponent(url.lastPathComponent)
        let descriptor = try openRegularFile(
            parentDescriptor: parentDescriptor,
            name: url.lastPathComponent,
            flags: O_RDWR
        )
        defer { close(descriptor) }
        let expectedIdentity = try identity(descriptor)
        var database: OpaquePointer?
        let result = sqlite3_open_v2(
            pinnedURL.path,
            &database,
            SQLITE_OPEN_READWRITE | SQLITE_OPEN_FULLMUTEX
                | SQLITE_OPEN_NOFOLLOW,
            nil
        )
        guard result == SQLITE_OK, let database else {
            let description = database.map { String(cString: sqlite3_errmsg($0)) }
                ?? "SQLite open failed with code \(result)."
            if let database { sqlite3_close(database) }
            throw RuntimeStoreMigrationError.fileOperationFailed(
                operation: "open sealed store for WAL checkpoint",
                description: description
            )
        }
        defer { sqlite3_close(database) }
        try requireStableDirectory(
            at: pinnedURL.deletingLastPathComponent(),
            expected: parentIdentity
        )
        try requireStableIdentity(
            url: pinnedURL,
            flags: O_RDWR,
            expected: expectedIdentity
        )
        try requireSQLiteFileNotMoved(
            database,
            operation: "pin sealed store for WAL checkpoint"
        )
        var logFrames: Int32 = 0
        var checkpointedFrames: Int32 = 0
        let checkpointResult = sqlite3_wal_checkpoint_v2(
            database,
            nil,
            SQLITE_CHECKPOINT_TRUNCATE,
            &logFrames,
            &checkpointedFrames
        )
        guard checkpointResult == SQLITE_OK else {
            throw RuntimeStoreMigrationError.fileOperationFailed(
                operation: "checkpoint and truncate sealed store WAL",
                description: String(cString: sqlite3_errmsg(database))
            )
        }
    }

    static func rename(
        sourceParentDescriptor: Int32,
        sourceName: String,
        destinationParentDescriptor: Int32,
        destinationName: String,
        operation: String
    ) throws {
        let result = sourceName.withCString { source in
            destinationName.withCString { destination in
                systemRenameAtExclusive(
                    sourceParentDescriptor,
                    source,
                    destinationParentDescriptor,
                    destination
                )
            }
        }
        guard result == 0 else { throw posixError(operation: operation) }
    }

    static func replace(
        sourceParentDescriptor: Int32,
        sourceName: String,
        destinationParentDescriptor: Int32,
        destinationName: String,
        operation: String
    ) throws {
        let result = sourceName.withCString { source in
            destinationName.withCString { destination in
                systemRenameAt(
                    sourceParentDescriptor,
                    source,
                    destinationParentDescriptor,
                    destination
                )
            }
        }
        guard result == 0 else { throw posixError(operation: operation) }
    }

    private static func requireStableIdentity(
        url: URL,
        flags: Int32,
        expected: RuntimeStoreMigrationFileIdentity
    ) throws {
        let reopened = try openRegularFile(at: url, flags: flags)
        defer { close(reopened) }
        guard try identity(reopened) == expected else {
            throw RuntimeStoreMigrationError.unsafeFilesystemEntry(
                url.lastPathComponent
            )
        }
    }

    static func requireSQLiteFileNotMoved(
        _ database: OpaquePointer?,
        operation: String
    ) throws {
        var moved: Int32 = 0
        let result = sqlite3_file_control(
            database,
            "main",
            SQLITE_FCNTL_HAS_MOVED,
            &moved
        )
        guard result == SQLITE_OK, moved == 0 else {
            throw RuntimeStoreMigrationError.fileOperationFailed(
                operation: operation,
                description: "The SQLite handle no longer matches its pinned path."
            )
        }
    }

    private static func systemRenameAtExclusive(
        _ sourceDescriptor: Int32,
        _ source: UnsafePointer<CChar>,
        _ destinationDescriptor: Int32,
        _ destination: UnsafePointer<CChar>
    ) -> Int32 {
        #if canImport(Darwin)
        Darwin.renameatx_np(
            sourceDescriptor,
            source,
            destinationDescriptor,
            destination,
            UInt32(RENAME_EXCL)
        )
        #else
        let linkResult = Glibc.linkat(
            sourceDescriptor,
            source,
            destinationDescriptor,
            destination,
            0
        )
        guard linkResult == 0 else { return linkResult }
        let unlinkResult = Glibc.unlinkat(sourceDescriptor, source, 0)
        if unlinkResult != 0 {
            _ = Glibc.unlinkat(destinationDescriptor, destination, 0)
        }
        return unlinkResult
        #endif
    }
}
