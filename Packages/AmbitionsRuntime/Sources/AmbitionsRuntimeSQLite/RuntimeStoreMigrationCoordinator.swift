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

    let rootDescriptor: Int32
    let controlDatabase: RuntimeStoreMigrationControlDatabase

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
        let descriptor = try RuntimeStoreMigrationFileSystem.openDirectory(
            at: resolvedRoot
        )
        do {
            try RuntimeStoreMigrationFileSystem.ensureControlDatabaseFile(
                rootDescriptor: descriptor
            )
            let database = try RuntimeStoreMigrationControlDatabase(
                url: resolvedRoot.appendingPathComponent(
                    ".RuntimeStore.migration-control.sqlite"
                )
            )
            self.rootDirectoryURL = resolvedRoot
            rootDescriptor = descriptor
            controlDatabase = database
        } catch {
            RuntimeStoreMigrationFileSystem.close(descriptor)
            throw error
        }
    }

    deinit {
        RuntimeStoreMigrationFileSystem.close(rootDescriptor)
    }

    public func reserveStaging(
        migrationIdentity: String
    ) throws -> RuntimeStoreMigrationReservation {
        try Self.validateMigrationIdentity(migrationIdentity)
        let stagingRootDescriptor = try RuntimeStoreMigrationFileSystem
            .ensureDirectory(
                parentDescriptor: rootDescriptor,
                name: "MigrationStaging"
            )
        defer {
            RuntimeStoreMigrationFileSystem.close(stagingRootDescriptor)
        }
        let stagingDescriptor = try RuntimeStoreMigrationFileSystem
            .ensureDirectory(
                parentDescriptor: stagingRootDescriptor,
                name: migrationIdentity
            )
        RuntimeStoreMigrationFileSystem.close(stagingDescriptor)
        try RuntimeStoreMigrationFileSystem.syncDescriptor(
            stagingRootDescriptor,
            operation: "sync staging root directory"
        )
        try RuntimeStoreMigrationFileSystem.syncDescriptor(
            rootDescriptor,
            operation: "sync coordinator root directory"
        )

        let reservation = expectedReservation(
            for: migrationIdentity,
            reservationIdentity: UUID().uuidString
        )
        try controlDatabase.withImmediateTransaction { connection in
            try connection.insertReservation(reservation)
        }
        return reservation
    }

    public func verify(
        reservation: RuntimeStoreMigrationReservation,
        expectations: RuntimeStoreVerificationExpectations
    ) async throws -> RuntimeStoreVerificationReport {
        try validateReservationStructure(reservation)
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
        try controlDatabase.withImmediateTransaction { connection in
            try connection.requireReservation(reservation)
        }

        let verificationIdentity = UUID().uuidString
        let capturedSource = try captureStagedStore(
            reservation: reservation,
            verificationIdentity: verificationIdentity
        )
        let candidateFilename = ".RuntimeStore.candidate.\(verificationIdentity).sqlite"
        let candidateURL = rootDirectoryURL.appendingPathComponent(candidateFilename)
        let candidateDescriptor = try RuntimeStoreMigrationFileSystem
            .createExclusiveRegularFile(
                parentDescriptor: rootDescriptor,
                name: candidateFilename
            )
        RuntimeStoreMigrationFileSystem.close(candidateDescriptor)

        try RuntimeStoreMigrationFileSystem.backupSQLiteStore(
            sourceURL: capturedSource,
            destinationURL: candidateURL
        )
        try RuntimeStoreMigrationFileSystem.checkpointAndTruncateWAL(
            at: candidateURL
        )

        let first = try inspectRootStore(filename: candidateFilename)
        try Self.compare(first.observation, with: expectations)
        let restarted = try inspectRootStore(filename: candidateFilename)
        guard first.fileIdentity == restarted.fileIdentity,
              first.digest == restarted.digest,
              first.observation == restarted.observation
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

        let expectationsDigest = try Self.stableDigest(expectations)
        let report = RuntimeStoreVerificationReport(
            reservationIdentity: reservation.reservationIdentity,
            verificationIdentity: verificationIdentity,
            migrationIdentity: reservation.migrationIdentity,
            canonicalRevision: first.observation.snapshot.canonicalRevision,
            counts: first.observation.counts,
            checksums: first.observation.checksums,
            sqliteIntegrityResult: first.observation.integrityResult,
            restartEquivalent: true,
            candidateDigest: first.digest,
            expectationsDigest: expectationsDigest
        )
        try controlDatabase.withImmediateTransaction { connection in
            try connection.requireReservation(reservation)
            try connection.insertVerification(
                report: report,
                expectations: expectations,
                candidateFilename: candidateFilename
            )
        }
        return report
    }

    public func activate(
        reservation: RuntimeStoreMigrationReservation,
        verifiedReport: RuntimeStoreVerificationReport,
        activatedAt: Date,
        failurePoint: RuntimeStoreMigrationFailurePoint? = nil
    ) async throws -> RuntimeStoreActivePointer {
        try validateReservationStructure(reservation)
        guard verifiedReport.schemaVersion == 2 else {
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

        let result = try controlDatabase.withImmediateTransaction { connection in
            try connection.requireReservation(reservation)
            let issuance = try connection.requireVerification(
                identity: verifiedReport.verificationIdentity
            )
            guard !issuance.consumed else {
                throw RuntimeStoreMigrationError.verificationAlreadyConsumed(
                    verifiedReport.verificationIdentity
                )
            }
            guard issuance.report == verifiedReport,
                  issuance.report.reservationIdentity
                    == reservation.reservationIdentity,
                  issuance.report.migrationIdentity
                    == reservation.migrationIdentity,
                  try Self.stableDigest(issuance.expectations)
                    == verifiedReport.expectationsDigest
            else {
                throw RuntimeStoreMigrationError.verificationIdentityMismatch
            }

            let sealedCandidate = try inspectRootStore(
                filename: issuance.candidateFilename
            )
            guard sealedCandidate.digest == verifiedReport.candidateDigest else {
                throw RuntimeStoreMigrationError.digestMismatch(
                    filename: issuance.candidateFilename,
                    expected: verifiedReport.candidateDigest,
                    actual: sealedCandidate.digest
                )
            }
            try Self.compare(
                sealedCandidate.observation,
                with: issuance.expectations
            )

            let existingPointer = try readPointerIfPresent()
            if let existingPointer {
                _ = try validateStore(existingPointer.currentStore)
            }
            let generation = try connection.authorityGeneration()
            let finalFilename = "RuntimeStore.\(reservation.migrationIdentity)."
                + "\(sealedCandidate.digest).sqlite"
            try Self.validateStoreFilename(finalFilename)
            guard !RuntimeStoreMigrationFileSystem.entryExists(
                parentDescriptor: rootDescriptor,
                name: finalFilename
            ) else {
                throw RuntimeStoreMigrationError.finalStoreAlreadyExists(
                    finalFilename
                )
            }

            try RuntimeStoreMigrationFileSystem.rename(
                sourceParentDescriptor: rootDescriptor,
                sourceName: issuance.candidateFilename,
                destinationParentDescriptor: rootDescriptor,
                destinationName: finalFilename,
                operation: "promote sealed runtime-store candidate"
            )
            let promoted = try inspectRootStore(filename: finalFilename)
            guard promoted.fileIdentity == sealedCandidate.fileIdentity,
                  promoted.digest == sealedCandidate.digest,
                  promoted.observation == sealedCandidate.observation
            else {
                throw RuntimeStoreMigrationError.verificationIdentityMismatch
            }
            try RuntimeStoreMigrationFileSystem.syncDescriptor(
                rootDescriptor,
                operation: "sync promoted runtime-store directory"
            )

            let currentStore = RuntimeStoreFileIdentity(
                filename: finalFilename,
                digest: promoted.digest,
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
                injectBeforeRename: failurePoint == .beforePointerRename
            )
            try connection.consumeVerification(
                identity: verifiedReport.verificationIdentity
            )
            try connection.advanceAuthorityGeneration(expected: generation)
            return pointer
        }
        if failurePoint == .afterPointerRename {
            throw RuntimeStoreMigrationError.injectedFailure(.afterPointerRename)
        }
        return result
    }

}

struct RuntimeStoreMigrationObservation: Sendable, Equatable {
    let snapshot: RuntimeStoreSnapshot
    let outbox: [RuntimeExternalEffectRecord]
    let counts: RuntimeStoreVerificationCounts
    let checksums: RuntimeStoreStableChecksums
    let integrityResult: String
}

struct RuntimeStoreMigrationInspectedFile: Sendable, Equatable {
    let fileIdentity: RuntimeStoreMigrationFileIdentity
    let digest: String
    let observation: RuntimeStoreMigrationObservation
}

struct RuntimeStoreMigrationFileIdentity: Sendable, Equatable {
    let device: UInt64
    let inode: UInt64
}

struct RuntimeStorePointerSchemaEnvelope: Decodable {
    let schemaVersion: Int
}

struct RuntimeStoreVerificationIssuance {
    let report: RuntimeStoreVerificationReport
    let expectations: RuntimeStoreVerificationExpectations
    let candidateFilename: String
    let consumed: Bool
}

struct RuntimeStoreMigrationControlDatabase {
    let url: URL

    init(url: URL) throws {
        self.url = url
        let connection = try RuntimeStoreMigrationControlConnection(url: url)
        try connection.installSchema()
    }

    func withImmediateTransaction<Value>(
        _ body: (RuntimeStoreMigrationControlConnection) throws -> Value
    ) throws -> Value {
        let connection = try RuntimeStoreMigrationControlConnection(url: url)
        try connection.execute("BEGIN IMMEDIATE")
        do {
            let value = try body(connection)
            try connection.execute("COMMIT")
            return value
        } catch {
            try? connection.execute("ROLLBACK")
            throw error
        }
    }
}

final class RuntimeStoreMigrationControlConnection {
    private var database: OpaquePointer?

    init(url: URL) throws {
        let flags = SQLITE_OPEN_CREATE | SQLITE_OPEN_READWRITE
            | SQLITE_OPEN_FULLMUTEX
        let result = sqlite3_open_v2(url.path, &database, flags, nil)
        guard result == SQLITE_OK, database != nil else {
            let description = message
            if let database { sqlite3_close(database) }
            database = nil
            throw RuntimeStoreMigrationError.fileOperationFailed(
                operation: "open migration control database",
                description: description
            )
        }
        sqlite3_busy_timeout(database, 30_000)
    }

    deinit {
        if let database { sqlite3_close(database) }
    }

    var message: String {
        database.map { String(cString: sqlite3_errmsg($0)) }
            ?? "SQLite control database unavailable"
    }

    func installSchema() throws {
        try execute("PRAGMA journal_mode=WAL")
        try execute("PRAGMA synchronous=FULL")
        try execute(
            """
            CREATE TABLE IF NOT EXISTS migration_reservations (
                reservation_identity TEXT PRIMARY KEY,
                migration_identity TEXT NOT NULL
            );
            CREATE TABLE IF NOT EXISTS migration_verifications (
                verification_identity TEXT PRIMARY KEY,
                reservation_identity TEXT NOT NULL,
                report_json BLOB NOT NULL,
                expectations_json BLOB NOT NULL,
                candidate_filename TEXT NOT NULL,
                consumed INTEGER NOT NULL DEFAULT 0 CHECK(consumed IN (0, 1)),
                FOREIGN KEY(reservation_identity)
                    REFERENCES migration_reservations(reservation_identity)
            );
            CREATE TABLE IF NOT EXISTS migration_authority (
                singleton INTEGER PRIMARY KEY CHECK(singleton = 1),
                generation INTEGER NOT NULL
            );
            INSERT INTO migration_authority(singleton, generation)
            VALUES (1, 0)
            ON CONFLICT(singleton) DO NOTHING;
            """
        )
    }

    func insertReservation(
        _ reservation: RuntimeStoreMigrationReservation
    ) throws {
        try execute(
            """
            INSERT INTO migration_reservations(
                reservation_identity, migration_identity
            ) VALUES (?, ?)
            """,
            bindings: [
                .text(reservation.reservationIdentity),
                .text(reservation.migrationIdentity)
            ]
        )
    }

    func requireReservation(
        _ reservation: RuntimeStoreMigrationReservation
    ) throws {
        let statement = try prepare(
            """
            SELECT migration_identity
            FROM migration_reservations
            WHERE reservation_identity = ?
            """,
            bindings: [.text(reservation.reservationIdentity)]
        )
        defer { sqlite3_finalize(statement) }
        guard sqlite3_step(statement) == SQLITE_ROW,
              let value = sqlite3_column_text(statement, 0)
        else {
            throw RuntimeStoreMigrationError.reservationNotIssued(
                reservation.reservationIdentity
            )
        }
        let migrationIdentity = String(cString: value)
        guard migrationIdentity == reservation.migrationIdentity else {
            throw RuntimeStoreMigrationError.verificationIdentityMismatch
        }
    }

    func insertVerification(
        report: RuntimeStoreVerificationReport,
        expectations: RuntimeStoreVerificationExpectations,
        candidateFilename: String
    ) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        try execute(
            """
            UPDATE migration_verifications
            SET consumed = 1
            WHERE reservation_identity = ? AND consumed = 0
            """,
            bindings: [.text(report.reservationIdentity)]
        )
        try execute(
            """
            INSERT INTO migration_verifications(
                verification_identity,
                reservation_identity,
                report_json,
                expectations_json,
                candidate_filename,
                consumed
            ) VALUES (?, ?, ?, ?, ?, 0)
            """,
            bindings: [
                .text(report.verificationIdentity),
                .text(report.reservationIdentity),
                .blob(try encoder.encode(report)),
                .blob(try encoder.encode(expectations)),
                .text(candidateFilename)
            ]
        )
    }

    func requireVerification(
        identity: String
    ) throws -> RuntimeStoreVerificationIssuance {
        let statement = try prepare(
            """
            SELECT report_json, expectations_json, candidate_filename, consumed
            FROM migration_verifications
            WHERE verification_identity = ?
            """,
            bindings: [.text(identity)]
        )
        defer { sqlite3_finalize(statement) }
        guard sqlite3_step(statement) == SQLITE_ROW else {
            throw RuntimeStoreMigrationError.verificationNotIssued(identity)
        }
        let reportData = try Self.blob(statement, column: 0)
        let expectationsData = try Self.blob(statement, column: 1)
        guard let candidateValue = sqlite3_column_text(statement, 2) else {
            throw RuntimeStoreMigrationError.verificationIdentityMismatch
        }
        return try RuntimeStoreVerificationIssuance(
            report: JSONDecoder().decode(
                RuntimeStoreVerificationReport.self,
                from: reportData
            ),
            expectations: JSONDecoder().decode(
                RuntimeStoreVerificationExpectations.self,
                from: expectationsData
            ),
            candidateFilename: String(cString: candidateValue),
            consumed: sqlite3_column_int(statement, 3) != 0
        )
    }

    func consumeVerification(identity: String) throws {
        try execute(
            """
            UPDATE migration_verifications
            SET consumed = 1
            WHERE verification_identity = ? AND consumed = 0
            """,
            bindings: [.text(identity)]
        )
        guard sqlite3_changes(database) == 1 else {
            throw RuntimeStoreMigrationError.verificationAlreadyConsumed(identity)
        }
    }

    func authorityGeneration() throws -> Int64 {
        let statement = try prepare(
            "SELECT generation FROM migration_authority WHERE singleton = 1"
        )
        defer { sqlite3_finalize(statement) }
        guard sqlite3_step(statement) == SQLITE_ROW else {
            throw RuntimeStoreMigrationError.fileOperationFailed(
                operation: "read migration authority generation",
                description: message
            )
        }
        return sqlite3_column_int64(statement, 0)
    }

    func advanceAuthorityGeneration(expected: Int64) throws {
        try execute(
            """
            UPDATE migration_authority
            SET generation = generation + 1
            WHERE singleton = 1 AND generation = ?
            """,
            bindings: [.integer(expected)]
        )
        guard sqlite3_changes(database) == 1 else {
            throw RuntimeStoreMigrationError.authorityConflict(
                expectedGeneration: expected,
                actualGeneration: try authorityGeneration()
            )
        }
    }

    func execute(
        _ sql: String,
        bindings: [RuntimeStoreMigrationControlBinding] = []
    ) throws {
        if bindings.isEmpty {
            var errorMessage: UnsafeMutablePointer<CChar>?
            guard sqlite3_exec(database, sql, nil, nil, &errorMessage) == SQLITE_OK else {
                let description = errorMessage.map { String(cString: $0) } ?? message
                sqlite3_free(errorMessage)
                throw RuntimeStoreMigrationError.fileOperationFailed(
                    operation: "execute migration control transaction",
                    description: description
                )
            }
            return
        }
        let statement = try prepare(sql, bindings: bindings)
        defer { sqlite3_finalize(statement) }
        guard sqlite3_step(statement) == SQLITE_DONE else {
            throw RuntimeStoreMigrationError.fileOperationFailed(
                operation: "execute migration control statement",
                description: message
            )
        }
    }

    private func prepare(
        _ sql: String,
        bindings: [RuntimeStoreMigrationControlBinding] = []
    ) throws -> OpaquePointer {
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(database, sql, -1, &statement, nil) == SQLITE_OK,
              let statement
        else {
            throw RuntimeStoreMigrationError.fileOperationFailed(
                operation: "prepare migration control statement",
                description: message
            )
        }
        do {
            try bind(bindings, to: statement)
            return statement
        } catch {
            sqlite3_finalize(statement)
            throw error
        }
    }

    private func bind(
        _ bindings: [RuntimeStoreMigrationControlBinding],
        to statement: OpaquePointer
    ) throws {
        for (offset, binding) in bindings.enumerated() {
            let index = Int32(offset + 1)
            let result: Int32
            switch binding {
            case let .integer(value):
                result = sqlite3_bind_int64(statement, index, value)
            case let .text(value):
                result = sqlite3_bind_text(
                    statement,
                    index,
                    value,
                    -1,
                    runtimeStoreMigrationSQLiteTransient
                )
            case let .blob(value):
                result = value.withUnsafeBytes { bytes in
                    sqlite3_bind_blob(
                        statement,
                        index,
                        bytes.baseAddress,
                        Int32(value.count),
                        runtimeStoreMigrationSQLiteTransient
                    )
                }
            }
            guard result == SQLITE_OK else {
                throw RuntimeStoreMigrationError.fileOperationFailed(
                    operation: "bind migration control statement",
                    description: message
                )
            }
        }
    }

    private static func blob(
        _ statement: OpaquePointer,
        column: Int32
    ) throws -> Data {
        let count = Int(sqlite3_column_bytes(statement, column))
        guard count > 0,
              let bytes = sqlite3_column_blob(statement, column)
        else { return Data() }
        return Data(bytes: bytes, count: count)
    }
}

enum RuntimeStoreMigrationControlBinding {
    case integer(Int64)
    case text(String)
    case blob(Data)
}

private let runtimeStoreMigrationSQLiteTransient = unsafeBitCast(
    -1,
    to: sqlite3_destructor_type.self
)

enum RuntimeStoreMigrationFileSystem {
    struct MissingEntry: Error {}

    static let controlDatabaseFilename = ".RuntimeStore.migration-control.sqlite"

    static func openDirectory(at url: URL) throws -> Int32 {
        let descriptor = url.path.withCString { path in
            systemOpen(path, O_RDONLY | O_DIRECTORY | O_NOFOLLOW, 0)
        }
        guard descriptor >= 0 else {
            throw posixError(operation: "open coordinator root directory")
        }
        return descriptor
    }

    static func ensureDirectory(
        parentDescriptor: Int32,
        name: String
    ) throws -> Int32 {
        let createResult = name.withCString { value in
            systemMkdirAt(parentDescriptor, value, S_IRWXU)
        }
        guard createResult == 0 || errno == EEXIST else {
            throw posixError(operation: "create runtime-store directory \(name)")
        }
        do {
            return try openDirectory(
                parentDescriptor: parentDescriptor,
                name: name
            )
        } catch {
            if errno == ELOOP || errno == ENOTDIR {
                throw RuntimeStoreMigrationError.unsafeFilesystemEntry(name)
            }
            throw error
        }
    }

    static func openDirectory(
        parentDescriptor: Int32,
        name: String
    ) throws -> Int32 {
        let descriptor = name.withCString { value in
            systemOpenAt(
                parentDescriptor,
                value,
                O_RDONLY | O_DIRECTORY | O_NOFOLLOW,
                0
            )
        }
        guard descriptor >= 0 else {
            if errno == ELOOP || errno == ENOTDIR {
                throw RuntimeStoreMigrationError.unsafeFilesystemEntry(name)
            }
            throw posixError(operation: "open runtime-store directory \(name)")
        }
        return descriptor
    }

    static func ensureControlDatabaseFile(rootDescriptor: Int32) throws {
        do {
            let descriptor = try openRegularFile(
                parentDescriptor: rootDescriptor,
                name: controlDatabaseFilename,
                flags: O_RDWR
            )
            close(descriptor)
        } catch is MissingEntry {
            let descriptor = try createExclusiveRegularFile(
                parentDescriptor: rootDescriptor,
                name: controlDatabaseFilename
            )
            close(descriptor)
            try syncDescriptor(
                rootDescriptor,
                operation: "sync migration control database directory"
            )
        }
    }

    static func createExclusiveRegularFile(
        parentDescriptor: Int32,
        name: String
    ) throws -> Int32 {
        let descriptor = name.withCString { value in
            systemOpenAt(
                parentDescriptor,
                value,
                O_RDWR | O_CREAT | O_EXCL | O_NOFOLLOW,
                S_IRUSR | S_IWUSR
            )
        }
        guard descriptor >= 0 else {
            throw posixError(operation: "create regular file \(name)")
        }
        do {
            try requireRegularDescriptor(descriptor, name: name)
            return descriptor
        } catch {
            close(descriptor)
            throw error
        }
    }

    static func openRegularFile(
        parentDescriptor: Int32,
        name: String,
        flags: Int32
    ) throws -> Int32 {
        let descriptor = name.withCString { value in
            systemOpenAt(
                parentDescriptor,
                value,
                flags | O_NOFOLLOW,
                0
            )
        }
        guard descriptor >= 0 else {
            if errno == ENOENT { throw MissingEntry() }
            if errno == ELOOP {
                throw RuntimeStoreMigrationError.storeIsNotRegularFile(name)
            }
            throw posixError(operation: "open regular file \(name)")
        }
        do {
            try requireRegularDescriptor(descriptor, name: name)
            return descriptor
        } catch {
            close(descriptor)
            throw error
        }
    }

    static func requireRegularEntry(
        parentDescriptor: Int32,
        name: String
    ) throws {
        let descriptor = try openRegularFile(
            parentDescriptor: parentDescriptor,
            name: name,
            flags: O_RDONLY
        )
        close(descriptor)
    }

    static func entryExists(
        parentDescriptor: Int32,
        name: String
    ) -> Bool {
        var status = stat()
        let result = name.withCString { value in
            systemStatAt(parentDescriptor, value, &status, AT_SYMLINK_NOFOLLOW)
        }
        return result == 0
    }

    static func identity(
        _ descriptor: Int32
    ) throws -> RuntimeStoreMigrationFileIdentity {
        var status = stat()
        guard systemFStat(descriptor, &status) == 0 else {
            throw posixError(operation: "identify runtime store")
        }
        return RuntimeStoreMigrationFileIdentity(
            device: UInt64(status.st_dev),
            inode: UInt64(status.st_ino)
        )
    }

    static func readAll(_ descriptor: Int32) throws -> Data {
        guard systemLseek(descriptor, 0, SEEK_SET) >= 0 else {
            throw posixError(operation: "seek runtime-store file")
        }
        var result = Data()
        var buffer = [UInt8](repeating: 0, count: 65_536)
        while true {
            let count = systemRead(descriptor, &buffer, buffer.count)
            guard count >= 0 else {
                throw posixError(operation: "read runtime-store file")
            }
            guard count > 0 else { return result }
            result.append(contentsOf: buffer[0..<count])
        }
    }

    static func writeAll(_ data: Data, to descriptor: Int32) throws {
        try data.withUnsafeBytes { bytes in
            var offset = 0
            while offset < bytes.count {
                let count = systemWrite(
                    descriptor,
                    bytes.baseAddress?.advanced(by: offset),
                    bytes.count - offset
                )
                guard count > 0 else {
                    throw posixError(operation: "write runtime-store file")
                }
                offset += count
            }
        }
    }

    static func digest(_ descriptor: Int32) throws -> String {
        guard systemLseek(descriptor, 0, SEEK_SET) >= 0 else {
            throw posixError(operation: "seek runtime store for digest")
        }
        var hasher = SHA256()
        var buffer = [UInt8](repeating: 0, count: 1_048_576)
        while true {
            let count = systemRead(descriptor, &buffer, buffer.count)
            guard count >= 0 else {
                throw posixError(operation: "digest runtime store")
            }
            guard count > 0 else { break }
            hasher.update(data: Data(buffer[0..<count]))
        }
        return hasher.finalize()
            .map { String(format: "%02x", $0) }
            .joined()
    }

    static func backupSQLiteStore(
        sourceURL: URL,
        destinationURL: URL
    ) throws {
        var source: OpaquePointer?
        var destination: OpaquePointer?
        let sourceFlags = SQLITE_OPEN_READONLY | SQLITE_OPEN_FULLMUTEX
        let destinationFlags = SQLITE_OPEN_READWRITE | SQLITE_OPEN_FULLMUTEX
        guard sqlite3_open_v2(
            sourceURL.path,
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
            destinationURL.path,
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
        var database: OpaquePointer?
        let result = sqlite3_open_v2(
            url.path,
            &database,
            SQLITE_OPEN_READWRITE | SQLITE_OPEN_FULLMUTEX,
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

    static func descriptorPath(_ descriptor: Int32) -> String {
        #if canImport(Darwin)
        "/dev/fd/\(descriptor)"
        #else
        "/proc/self/fd/\(descriptor)"
        #endif
    }

    static func syncDescriptor(
        _ descriptor: Int32,
        operation: String
    ) throws {
        guard systemFSync(descriptor) == 0 else {
            throw posixError(operation: operation)
        }
    }

    static func close(_ descriptor: Int32) {
        guard descriptor >= 0 else { return }
        _ = systemClose(descriptor)
    }

    private static func requireRegularDescriptor(
        _ descriptor: Int32,
        name: String
    ) throws {
        var status = stat()
        guard systemFStat(descriptor, &status) == 0,
              status.st_mode & S_IFMT == S_IFREG
        else {
            throw RuntimeStoreMigrationError.storeIsNotRegularFile(name)
        }
    }

    private static func posixError(
        operation: String
    ) -> RuntimeStoreMigrationError {
        .fileOperationFailed(
            operation: operation,
            description: String(cString: strerror(errno))
        )
    }

    private static func systemOpen(
        _ path: UnsafePointer<CChar>,
        _ flags: Int32,
        _ mode: mode_t
    ) -> Int32 {
        #if canImport(Darwin)
        Darwin.open(path, flags, mode)
        #else
        Glibc.open(path, flags, mode)
        #endif
    }

    private static func systemOpenAt(
        _ descriptor: Int32,
        _ path: UnsafePointer<CChar>,
        _ flags: Int32,
        _ mode: mode_t
    ) -> Int32 {
        #if canImport(Darwin)
        Darwin.openat(descriptor, path, flags, mode)
        #else
        Glibc.openat(descriptor, path, flags, mode)
        #endif
    }

    private static func systemMkdirAt(
        _ descriptor: Int32,
        _ path: UnsafePointer<CChar>,
        _ mode: mode_t
    ) -> Int32 {
        #if canImport(Darwin)
        Darwin.mkdirat(descriptor, path, mode)
        #else
        Glibc.mkdirat(descriptor, path, mode)
        #endif
    }

    private static func systemStatAt(
        _ descriptor: Int32,
        _ path: UnsafePointer<CChar>,
        _ status: UnsafeMutablePointer<stat>,
        _ flags: Int32
    ) -> Int32 {
        #if canImport(Darwin)
        Darwin.fstatat(descriptor, path, status, flags)
        #else
        Glibc.fstatat(descriptor, path, status, flags)
        #endif
    }

    private static func systemFStat(
        _ descriptor: Int32,
        _ status: UnsafeMutablePointer<stat>
    ) -> Int32 {
        #if canImport(Darwin)
        Darwin.fstat(descriptor, status)
        #else
        Glibc.fstat(descriptor, status)
        #endif
    }

    private static func systemRenameAt(
        _ sourceDescriptor: Int32,
        _ source: UnsafePointer<CChar>,
        _ destinationDescriptor: Int32,
        _ destination: UnsafePointer<CChar>
    ) -> Int32 {
        #if canImport(Darwin)
        Darwin.renameat(
            sourceDescriptor,
            source,
            destinationDescriptor,
            destination
        )
        #else
        Glibc.renameat(
            sourceDescriptor,
            source,
            destinationDescriptor,
            destination
        )
        #endif
    }

    private static func systemLseek(
        _ descriptor: Int32,
        _ offset: off_t,
        _ whence: Int32
    ) -> off_t {
        #if canImport(Darwin)
        Darwin.lseek(descriptor, offset, whence)
        #else
        Glibc.lseek(descriptor, offset, whence)
        #endif
    }

    private static func systemRead(
        _ descriptor: Int32,
        _ buffer: UnsafeMutableRawPointer,
        _ count: Int
    ) -> Int {
        #if canImport(Darwin)
        Darwin.read(descriptor, buffer, count)
        #else
        Glibc.read(descriptor, buffer, count)
        #endif
    }

    private static func systemWrite(
        _ descriptor: Int32,
        _ buffer: UnsafeRawPointer?,
        _ count: Int
    ) -> Int {
        #if canImport(Darwin)
        Darwin.write(descriptor, buffer, count)
        #else
        Glibc.write(descriptor, buffer, count)
        #endif
    }

    private static func systemFSync(_ descriptor: Int32) -> Int32 {
        #if canImport(Darwin)
        Darwin.fsync(descriptor)
        #else
        Glibc.fsync(descriptor)
        #endif
    }

    private static func systemClose(_ descriptor: Int32) -> Int32 {
        #if canImport(Darwin)
        Darwin.close(descriptor)
        #else
        Glibc.close(descriptor)
        #endif
    }
}
