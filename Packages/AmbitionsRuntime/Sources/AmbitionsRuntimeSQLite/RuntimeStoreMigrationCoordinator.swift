import CryptoKit
import Foundation
import SQLite3

#if canImport(Darwin)
import Darwin
#else
import Glibc
#endif

public actor RuntimeStoreMigrationCoordinator {
    public nonisolated let rootDirectoryURL: URL

    private let activePointerURL: URL
    private let stagingRootURL: URL

    public init(rootDirectoryURL: URL) throws {
        let standardizedRoot = rootDirectoryURL.standardizedFileURL
        do {
            try FileManager.default.createDirectory(
                at: standardizedRoot,
                withIntermediateDirectories: true
            )
        } catch {
            throw RuntimeStoreMigrationError.fileOperationFailed(
                operation: "create coordinator root",
                description: String(describing: error)
            )
        }
        let resolvedRoot = standardizedRoot.resolvingSymlinksInPath()
        self.rootDirectoryURL = resolvedRoot
        activePointerURL = resolvedRoot.appendingPathComponent(
            "RuntimeStore.active.json",
            isDirectory: false
        )
        stagingRootURL = resolvedRoot.appendingPathComponent(
            "MigrationStaging",
            isDirectory: true
        )
    }

    public func reserveStaging(
        migrationIdentity: String
    ) throws -> RuntimeStoreMigrationReservation {
        try Self.validateMigrationIdentity(migrationIdentity)
        let reservation = expectedReservation(for: migrationIdentity)
        do {
            try FileManager.default.createDirectory(
                at: reservation.stagingDirectoryURL,
                withIntermediateDirectories: true
            )
        } catch {
            throw RuntimeStoreMigrationError.fileOperationFailed(
                operation: "create migration staging directory",
                description: String(describing: error)
            )
        }
        let resolvedDirectory = reservation.stagingDirectoryURL
            .resolvingSymlinksInPath()
        guard Self.isInsideRoot(resolvedDirectory, root: rootDirectoryURL),
              resolvedDirectory == reservation.stagingDirectoryURL
        else {
            throw RuntimeStoreMigrationError.reservationPathMismatch(
                expected: reservation.stagingDirectoryURL,
                actual: resolvedDirectory
            )
        }
        return reservation
    }

    public func verify(
        reservation: RuntimeStoreMigrationReservation,
        expectations: RuntimeStoreVerificationExpectations
    ) async throws -> RuntimeStoreVerificationReport {
        try validate(reservation)
        guard expectations.schemaVersion == 1 else {
            throw RuntimeStoreMigrationError.unsupportedVerificationSchemaVersion(
                expectations.schemaVersion
            )
        }
        guard reservation.migrationIdentity == expectations.migrationIdentity else {
            throw RuntimeStoreMigrationError.mismatchedMigrationIdentity(
                expected: reservation.migrationIdentity,
                actual: expectations.migrationIdentity
            )
        }
        try Self.requireRegularFile(reservation.stagedStoreURL)

        let first = try await Self.inspectStore(at: reservation.stagedStoreURL)
        try Self.compare(first, with: expectations)
        let restarted = try await Self.inspectStore(at: reservation.stagedStoreURL)
        guard first.snapshot == restarted.snapshot,
              first.outbox == restarted.outbox,
              first.counts == restarted.counts,
              first.checksums == restarted.checksums,
              first.integrityResult == restarted.integrityResult
        else {
            throw RuntimeStoreMigrationError.restartMismatch
        }
        guard expectations.restartEquivalent else {
            throw RuntimeStoreMigrationError.verificationMismatch(
                field: "restartEquivalent",
                expected: String(expectations.restartEquivalent),
                actual: "true"
            )
        }
        return RuntimeStoreVerificationReport(
            migrationIdentity: reservation.migrationIdentity,
            canonicalRevision: first.snapshot.canonicalRevision,
            counts: first.counts,
            checksums: first.checksums,
            sqliteIntegrityResult: first.integrityResult,
            restartEquivalent: true
        )
    }

    public func activate(
        reservation: RuntimeStoreMigrationReservation,
        verifiedReport: RuntimeStoreVerificationReport,
        activatedAt: Date,
        failurePoint: RuntimeStoreMigrationFailurePoint? = nil
    ) async throws -> RuntimeStoreActivePointer {
        try validate(reservation)
        guard verifiedReport.schemaVersion == 1 else {
            throw RuntimeStoreMigrationError.unsupportedVerificationSchemaVersion(
                verifiedReport.schemaVersion
            )
        }
        guard reservation.migrationIdentity == verifiedReport.migrationIdentity else {
            throw RuntimeStoreMigrationError.mismatchedMigrationIdentity(
                expected: reservation.migrationIdentity,
                actual: verifiedReport.migrationIdentity
            )
        }

        let expectations = RuntimeStoreVerificationExpectations(
            migrationIdentity: verifiedReport.migrationIdentity,
            canonicalRevision: verifiedReport.canonicalRevision,
            counts: verifiedReport.counts,
            checksums: verifiedReport.checksums,
            sqliteIntegrityResult: verifiedReport.sqliteIntegrityResult,
            restartEquivalent: verifiedReport.restartEquivalent
        )
        let freshReport = try await verify(
            reservation: reservation,
            expectations: expectations
        )
        try validate(reservation)
        guard freshReport == verifiedReport else {
            throw RuntimeStoreMigrationError.verificationMismatch(
                field: "verifiedReport",
                expected: String(describing: verifiedReport),
                actual: String(describing: freshReport)
            )
        }

        let existingPointer = try readPointerIfPresent()
        if let existingPointer {
            _ = try validateStore(existingPointer.currentStore)
        }

        try RuntimeStoreMigrationFileSystem.checkpointAndTruncateWAL(
            at: reservation.stagedStoreURL
        )
        try RuntimeStoreMigrationFileSystem.syncFile(
            reservation.stagedStoreURL
        )
        let digest = try RuntimeStoreMigrationFileSystem.digest(
            reservation.stagedStoreURL
        )
        let finalFilename = "RuntimeStore.\(reservation.migrationIdentity).\(digest).sqlite"
        try Self.validateStoreFilename(finalFilename)
        let finalURL = rootDirectoryURL.appendingPathComponent(finalFilename)
        guard !FileManager.default.fileExists(atPath: finalURL.path) else {
            throw RuntimeStoreMigrationError.finalStoreAlreadyExists(finalFilename)
        }
        do {
            try FileManager.default.moveItem(
                at: reservation.stagedStoreURL,
                to: finalURL
            )
        } catch {
            throw RuntimeStoreMigrationError.fileOperationFailed(
                operation: "promote staged runtime store",
                description: String(describing: error)
            )
        }
        try RuntimeStoreMigrationFileSystem.syncDirectory(
            reservation.stagingDirectoryURL
        )
        try RuntimeStoreMigrationFileSystem.syncDirectory(rootDirectoryURL)

        let currentStore = RuntimeStoreFileIdentity(
            filename: finalFilename,
            digest: digest,
            migrationIdentity: reservation.migrationIdentity
        )
        let pointer = RuntimeStoreActivePointer(
            currentStore: currentStore,
            previousStore: existingPointer?.currentStore,
            migrationIdentity: reservation.migrationIdentity,
            activatedAt: activatedAt
        )
        try writePointer(
            pointer,
            failurePoint: failurePoint
        )
        return pointer
    }

    public func resolveActiveStore() throws -> URL {
        guard let pointer = try readPointerIfPresent() else {
            throw RuntimeStoreMigrationError.noActiveStore
        }
        guard pointer.migrationIdentity == pointer.currentStore.migrationIdentity else {
            throw RuntimeStoreMigrationError.invalidPointer(
                "Current store migration identity does not match the pointer."
            )
        }
        return try validateStore(pointer.currentStore)
    }

    public func rollback(
        activatedAt: Date
    ) throws -> RuntimeStoreActivePointer {
        guard let pointer = try readPointerIfPresent() else {
            throw RuntimeStoreMigrationError.noActiveStore
        }
        _ = try validateStore(pointer.currentStore)
        guard let previousStore = pointer.previousStore else {
            throw RuntimeStoreMigrationError.noPreviousStore
        }
        _ = try validateStore(previousStore)

        let rolledBack = RuntimeStoreActivePointer(
            currentStore: previousStore,
            previousStore: pointer.currentStore,
            migrationIdentity: previousStore.migrationIdentity,
            activatedAt: activatedAt
        )
        try writePointer(rolledBack, failurePoint: nil)
        return rolledBack
    }

    private func expectedReservation(
        for migrationIdentity: String
    ) -> RuntimeStoreMigrationReservation {
        let stagingDirectory = stagingRootURL.appendingPathComponent(
            migrationIdentity,
            isDirectory: true
        )
        return RuntimeStoreMigrationReservation(
            migrationIdentity: migrationIdentity,
            stagingDirectoryURL: stagingDirectory,
            stagedStoreURL: stagingDirectory.appendingPathComponent(
                "RuntimeStore.sqlite.next",
                isDirectory: false
            )
        )
    }

    private func validate(
        _ reservation: RuntimeStoreMigrationReservation
    ) throws {
        guard reservation.schemaVersion == 1 else {
            throw RuntimeStoreMigrationError.unsupportedReservationSchemaVersion(
                reservation.schemaVersion
            )
        }
        try Self.validateMigrationIdentity(reservation.migrationIdentity)
        let expected = expectedReservation(for: reservation.migrationIdentity)
        let actualStore = reservation.stagedStoreURL.standardizedFileURL
        guard actualStore == expected.stagedStoreURL else {
            throw RuntimeStoreMigrationError.reservationPathMismatch(
                expected: expected.stagedStoreURL,
                actual: actualStore
            )
        }
        let actualDirectory = reservation.stagingDirectoryURL.standardizedFileURL
        guard actualDirectory == expected.stagingDirectoryURL else {
            throw RuntimeStoreMigrationError.reservationPathMismatch(
                expected: expected.stagingDirectoryURL,
                actual: actualDirectory
            )
        }
        let resolvedDirectory = actualDirectory.resolvingSymlinksInPath()
        guard resolvedDirectory == expected.stagingDirectoryURL,
              Self.isInsideRoot(resolvedDirectory, root: rootDirectoryURL)
        else {
            throw RuntimeStoreMigrationError.reservationPathMismatch(
                expected: expected.stagingDirectoryURL,
                actual: resolvedDirectory
            )
        }
        guard Self.isInsideRoot(actualStore, root: rootDirectoryURL) else {
            throw RuntimeStoreMigrationError.reservationPathMismatch(
                expected: expected.stagedStoreURL,
                actual: actualStore
            )
        }
    }

    private func readPointerIfPresent() throws -> RuntimeStoreActivePointer? {
        guard FileManager.default.fileExists(atPath: activePointerURL.path) else {
            return nil
        }
        do {
            let data = try Data(contentsOf: activePointerURL)
            let envelope = try JSONDecoder().decode(
                RuntimeStorePointerSchemaEnvelope.self,
                from: data
            )
            guard envelope.schemaVersion == 1 else {
                throw RuntimeStoreMigrationError.unsupportedPointerSchemaVersion(
                    envelope.schemaVersion
                )
            }
            let pointer = try JSONDecoder().decode(
                RuntimeStoreActivePointer.self,
                from: data
            )
            return pointer
        } catch let error as RuntimeStoreMigrationError {
            throw error
        } catch {
            throw RuntimeStoreMigrationError.invalidPointer(
                String(describing: error)
            )
        }
    }

    private func validateStore(
        _ identity: RuntimeStoreFileIdentity
    ) throws -> URL {
        try Self.validateStoreFilename(identity.filename)
        try Self.validateMigrationIdentity(identity.migrationIdentity)
        let url = rootDirectoryURL.appendingPathComponent(identity.filename)
        try Self.requireRegularFile(url)
        let observedDigest = try RuntimeStoreMigrationFileSystem.digest(url)
        guard observedDigest == identity.digest else {
            throw RuntimeStoreMigrationError.digestMismatch(
                filename: identity.filename,
                expected: identity.digest,
                actual: observedDigest
            )
        }
        let integrity = try RuntimeStoreMigrationFileSystem.integrityResult(
            at: url,
            immutable: true
        )
        guard integrity == "ok" else {
            throw RuntimeStoreMigrationError.sqliteIntegrityFailed(integrity)
        }
        return url
    }

    private func writePointer(
        _ pointer: RuntimeStoreActivePointer,
        failurePoint: RuntimeStoreMigrationFailurePoint?
    ) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        let data: Data
        do {
            data = try encoder.encode(pointer)
        } catch {
            throw RuntimeStoreMigrationError.fileOperationFailed(
                operation: "encode active-store pointer",
                description: String(describing: error)
            )
        }
        let temporaryURL = rootDirectoryURL.appendingPathComponent(
            ".RuntimeStore.active.\(UUID().uuidString).tmp"
        )
        try RuntimeStoreMigrationFileSystem.writeAndSync(
            data,
            to: temporaryURL
        )
        if failurePoint == .beforePointerRename {
            throw RuntimeStoreMigrationError.injectedFailure(.beforePointerRename)
        }
        try RuntimeStoreMigrationFileSystem.atomicRename(
            temporaryURL,
            to: activePointerURL
        )
        try RuntimeStoreMigrationFileSystem.syncDirectory(rootDirectoryURL)
        if failurePoint == .afterPointerRename {
            throw RuntimeStoreMigrationError.injectedFailure(.afterPointerRename)
        }
    }

    private static func inspectStore(
        at url: URL
    ) async throws -> RuntimeStoreMigrationObservation {
        let store = try RuntimeStoreSQLite(databaseURL: url)
        let snapshot = try await store.snapshot()
        let outbox = try await store.externalEffectRecords()
        let counts = RuntimeStoreVerificationCounts(
            stateCount: snapshot.stateChanges.count,
            eventCount: snapshot.events.count,
            projectionCount: snapshot.projectionChanges.count,
            receiptCount: snapshot.receipts.count,
            outboxCount: outbox.count
        )
        let checksums = try RuntimeStoreStableChecksums(
            snapshot: snapshot,
            outbox: outbox
        )
        let integrity = try RuntimeStoreMigrationFileSystem.integrityResult(at: url)
        guard integrity == "ok" else {
            throw RuntimeStoreMigrationError.sqliteIntegrityFailed(integrity)
        }
        return RuntimeStoreMigrationObservation(
            snapshot: snapshot,
            outbox: outbox,
            counts: counts,
            checksums: checksums,
            integrityResult: integrity
        )
    }

    private static func compare(
        _ observation: RuntimeStoreMigrationObservation,
        with expectations: RuntimeStoreVerificationExpectations
    ) throws {
        try requireEqual(
            field: "canonicalRevision",
            expected: expectations.canonicalRevision,
            actual: observation.snapshot.canonicalRevision
        )
        try requireEqual(
            field: "stateCount",
            expected: expectations.counts.stateCount,
            actual: observation.counts.stateCount
        )
        try requireEqual(
            field: "eventCount",
            expected: expectations.counts.eventCount,
            actual: observation.counts.eventCount
        )
        try requireEqual(
            field: "projectionCount",
            expected: expectations.counts.projectionCount,
            actual: observation.counts.projectionCount
        )
        try requireEqual(
            field: "receiptCount",
            expected: expectations.counts.receiptCount,
            actual: observation.counts.receiptCount
        )
        try requireEqual(
            field: "outboxCount",
            expected: expectations.counts.outboxCount,
            actual: observation.counts.outboxCount
        )
        try requireEqual(
            field: "stateChecksum",
            expected: expectations.checksums.stateChecksum,
            actual: observation.checksums.stateChecksum
        )
        try requireEqual(
            field: "eventChecksum",
            expected: expectations.checksums.eventChecksum,
            actual: observation.checksums.eventChecksum
        )
        try requireEqual(
            field: "projectionChecksum",
            expected: expectations.checksums.projectionChecksum,
            actual: observation.checksums.projectionChecksum
        )
        try requireEqual(
            field: "receiptChecksum",
            expected: expectations.checksums.receiptChecksum,
            actual: observation.checksums.receiptChecksum
        )
        try requireEqual(
            field: "outboxChecksum",
            expected: expectations.checksums.outboxChecksum,
            actual: observation.checksums.outboxChecksum
        )
        try requireEqual(
            field: "sqliteIntegrityResult",
            expected: expectations.sqliteIntegrityResult,
            actual: observation.integrityResult
        )
    }

    private static func requireEqual<Value: Equatable>(
        field: String,
        expected: Value,
        actual: Value
    ) throws {
        guard expected == actual else {
            throw RuntimeStoreMigrationError.verificationMismatch(
                field: field,
                expected: String(describing: expected),
                actual: String(describing: actual)
            )
        }
    }

    private static func validateMigrationIdentity(_ identity: String) throws {
        let permitted = CharacterSet.alphanumerics.union(
            CharacterSet(charactersIn: "-._")
        )
        guard !identity.isEmpty,
              identity.utf8.count <= 80,
              identity != ".",
              identity != "..",
              identity.unicodeScalars.allSatisfy(permitted.contains)
        else {
            throw RuntimeStoreMigrationError.invalidMigrationIdentity(identity)
        }
    }

    private static func validateStoreFilename(_ filename: String) throws {
        guard !filename.isEmpty,
              filename == URL(fileURLWithPath: filename).lastPathComponent,
              !filename.contains("/"),
              !filename.contains("\\"),
              filename != ".",
              filename != "..",
              !filename.contains("\0")
        else {
            throw RuntimeStoreMigrationError.unsafeStoreFilename(filename)
        }
    }

    private static func requireRegularFile(_ url: URL) throws {
        guard RuntimeStoreMigrationFileSystem.isRegularFileWithoutFollowingLinks(url) else {
            throw RuntimeStoreMigrationError.storeIsNotRegularFile(
                url.lastPathComponent
            )
        }
    }

    private static func isInsideRoot(_ url: URL, root: URL) -> Bool {
        let rootPath = root.standardizedFileURL.path
        let path = url.standardizedFileURL.path
        return path == rootPath || path.hasPrefix(rootPath + "/")
    }
}

private struct RuntimeStoreMigrationObservation: Sendable, Equatable {
    let snapshot: RuntimeStoreSnapshot
    let outbox: [RuntimeExternalEffectRecord]
    let counts: RuntimeStoreVerificationCounts
    let checksums: RuntimeStoreStableChecksums
    let integrityResult: String
}

private struct RuntimeStorePointerSchemaEnvelope: Decodable {
    let schemaVersion: Int
}

private enum RuntimeStoreMigrationFileSystem {
    static func isRegularFileWithoutFollowingLinks(_ url: URL) -> Bool {
        var fileStatus = stat()
        let result = url.path.withCString { path in
            lstat(path, &fileStatus)
        }
        guard result == 0 else { return false }
        return fileStatus.st_mode & S_IFMT == S_IFREG
    }

    static func digest(_ url: URL) throws -> String {
        do {
            let handle = try FileHandle(forReadingFrom: url)
            defer { try? handle.close() }
            var hasher = SHA256()
            while true {
                let data = try handle.read(upToCount: 1_048_576) ?? Data()
                guard !data.isEmpty else { break }
                hasher.update(data: data)
            }
            return hasher.finalize()
                .map { String(format: "%02x", $0) }
                .joined()
        } catch {
            throw RuntimeStoreMigrationError.fileOperationFailed(
                operation: "digest runtime store",
                description: String(describing: error)
            )
        }
    }

    static func integrityResult(
        at url: URL,
        immutable: Bool = false
    ) throws -> String {
        var database: OpaquePointer?
        let filename: String
        let flags: Int32
        if immutable {
            let escapedPath = url.path.addingPercentEncoding(
                withAllowedCharacters: .urlPathAllowed
            ) ?? url.path
            filename = "file:\(escapedPath)?immutable=1"
            flags = SQLITE_OPEN_READONLY | SQLITE_OPEN_FULLMUTEX | SQLITE_OPEN_URI
        } else {
            filename = url.path
            flags = SQLITE_OPEN_READWRITE | SQLITE_OPEN_FULLMUTEX
        }
        let openResult = sqlite3_open_v2(
            filename,
            &database,
            flags,
            nil
        )
        guard openResult == SQLITE_OK, let database else {
            let message = database.map { String(cString: sqlite3_errmsg($0)) }
                ?? "SQLite open failed with code \(openResult)."
            if let database { sqlite3_close(database) }
            throw RuntimeStoreMigrationError.sqliteIntegrityFailed(message)
        }
        defer { sqlite3_close(database) }

        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(
            database,
            "PRAGMA integrity_check",
            -1,
            &statement,
            nil
        ) == SQLITE_OK, let statement else {
            throw RuntimeStoreMigrationError.sqliteIntegrityFailed(
                String(cString: sqlite3_errmsg(database))
            )
        }
        defer { sqlite3_finalize(statement) }

        var results: [String] = []
        while true {
            switch sqlite3_step(statement) {
            case SQLITE_ROW:
                guard let text = sqlite3_column_text(statement, 0) else {
                    throw RuntimeStoreMigrationError.sqliteIntegrityFailed(
                        "SQLite integrity check returned an empty result."
                    )
                }
                results.append(String(cString: text))
            case SQLITE_DONE:
                return results.joined(separator: "\n")
            default:
                throw RuntimeStoreMigrationError.sqliteIntegrityFailed(
                    String(cString: sqlite3_errmsg(database))
                )
            }
        }
    }

    static func checkpointAndTruncateWAL(at url: URL) throws {
        var database: OpaquePointer?
        let openResult = sqlite3_open_v2(
            url.path,
            &database,
            SQLITE_OPEN_READWRITE | SQLITE_OPEN_FULLMUTEX,
            nil
        )
        guard openResult == SQLITE_OK, let database else {
            let message = database.map { String(cString: sqlite3_errmsg($0)) }
                ?? "SQLite open failed with code \(openResult)."
            if let database { sqlite3_close(database) }
            throw RuntimeStoreMigrationError.fileOperationFailed(
                operation: "open staged store for WAL checkpoint",
                description: message
            )
        }
        defer { sqlite3_close(database) }
        var logFrames: Int32 = 0
        var checkpointedFrames: Int32 = 0
        let result = sqlite3_wal_checkpoint_v2(
            database,
            nil,
            SQLITE_CHECKPOINT_TRUNCATE,
            &logFrames,
            &checkpointedFrames
        )
        guard result == SQLITE_OK else {
            throw RuntimeStoreMigrationError.fileOperationFailed(
                operation: "checkpoint and truncate staged WAL",
                description: String(cString: sqlite3_errmsg(database))
            )
        }
    }

    static func writeAndSync(_ data: Data, to url: URL) throws {
        let descriptor = url.path.withCString { path -> Int32 in
            #if canImport(Darwin)
            Darwin.open(path, O_WRONLY | O_CREAT | O_EXCL, S_IRUSR | S_IWUSR)
            #else
            Glibc.open(path, O_WRONLY | O_CREAT | O_EXCL, S_IRUSR | S_IWUSR)
            #endif
        }
        guard descriptor >= 0 else {
            throw posixError(operation: "create temporary active-store pointer")
        }
        var pendingError: RuntimeStoreMigrationError?
        do {
            try data.withUnsafeBytes { bytes in
                var offset = 0
                while offset < bytes.count {
                    let written: Int
                    #if canImport(Darwin)
                    written = Darwin.write(
                        descriptor,
                        bytes.baseAddress?.advanced(by: offset),
                        bytes.count - offset
                    )
                    #else
                    written = Glibc.write(
                        descriptor,
                        bytes.baseAddress?.advanced(by: offset),
                        bytes.count - offset
                    )
                    #endif
                    guard written > 0 else {
                        throw posixError(operation: "write temporary active-store pointer")
                    }
                    offset += written
                }
            }
            try syncDescriptor(
                descriptor,
                operation: "sync temporary active-store pointer"
            )
        } catch let error as RuntimeStoreMigrationError {
            pendingError = error
        } catch {
            pendingError = .fileOperationFailed(
                operation: "write temporary active-store pointer",
                description: String(describing: error)
            )
        }
        #if canImport(Darwin)
        let closeResult = Darwin.close(descriptor)
        #else
        let closeResult = Glibc.close(descriptor)
        #endif
        if let pendingError { throw pendingError }
        guard closeResult == 0 else {
            throw posixError(operation: "close temporary active-store pointer")
        }
    }

    static func syncFile(_ url: URL) throws {
        let descriptor = url.path.withCString { path -> Int32 in
            #if canImport(Darwin)
            Darwin.open(path, O_RDONLY)
            #else
            Glibc.open(path, O_RDONLY)
            #endif
        }
        guard descriptor >= 0 else {
            throw posixError(operation: "open staged store for sync")
        }
        defer {
            #if canImport(Darwin)
            _ = Darwin.close(descriptor)
            #else
            _ = Glibc.close(descriptor)
            #endif
        }
        try syncDescriptor(descriptor, operation: "sync staged store")
    }

    static func syncDirectory(_ url: URL) throws {
        let descriptor = url.path.withCString { path -> Int32 in
            #if canImport(Darwin)
            Darwin.open(path, O_RDONLY)
            #else
            Glibc.open(path, O_RDONLY)
            #endif
        }
        guard descriptor >= 0 else {
            throw posixError(operation: "open runtime-store directory for sync")
        }
        defer {
            #if canImport(Darwin)
            _ = Darwin.close(descriptor)
            #else
            _ = Glibc.close(descriptor)
            #endif
        }
        try syncDescriptor(descriptor, operation: "sync runtime-store directory")
    }

    static func atomicRename(_ source: URL, to destination: URL) throws {
        let result = source.path.withCString { sourcePath in
            destination.path.withCString { destinationPath in
                #if canImport(Darwin)
                Darwin.rename(sourcePath, destinationPath)
                #else
                Glibc.rename(sourcePath, destinationPath)
                #endif
            }
        }
        guard result == 0 else {
            throw posixError(operation: "atomically rename active-store pointer")
        }
    }

    private static func syncDescriptor(
        _ descriptor: Int32,
        operation: String
    ) throws {
        #if canImport(Darwin)
        let result = Darwin.fsync(descriptor)
        #else
        let result = Glibc.fsync(descriptor)
        #endif
        guard result == 0 else { throw posixError(operation: operation) }
    }

    private static func posixError(
        operation: String
    ) -> RuntimeStoreMigrationError {
        .fileOperationFailed(
            operation: operation,
            description: String(cString: strerror(errno))
        )
    }
}
