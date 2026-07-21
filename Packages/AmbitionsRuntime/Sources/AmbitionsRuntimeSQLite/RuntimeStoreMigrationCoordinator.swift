import CryptoKit
import Foundation
import SQLite3

#if canImport(Darwin)
import Darwin

@_silgen_name("fcntl")
private func runtimeStoreMigrationFcntlPath(
    _ descriptor: Int32,
    _ command: Int32,
    _ path: UnsafeMutablePointer<CChar>
) -> Int32
#else
import Glibc
#endif

public actor RuntimeStoreMigrationCoordinator {
    public nonisolated let rootDirectoryURL: URL

    let rootDescriptor: Int32
    let controlDatabase: RuntimeStoreMigrationControlDatabase
    private let verificationIssuanceHook: (@Sendable () async -> Void)?

    public init(rootDirectoryURL: URL) throws {
        try self.init(
            rootDirectoryURL: rootDirectoryURL,
            verificationIssuanceHook: nil
        )
    }

    init(
        rootDirectoryURL: URL,
        verificationIssuanceHook: (@Sendable () async -> Void)?
    ) throws {
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
        let descriptor = try RuntimeStoreMigrationFileSystem.openDirectory(
            at: standardizedRoot
        )
        do {
            let pinnedRoot = URL(
                fileURLWithPath: try RuntimeStoreMigrationFileSystem
                    .canonicalPath(descriptor),
                isDirectory: true
            )
            try RuntimeStoreMigrationFileSystem.ensureControlDatabaseFile(
                rootDescriptor: descriptor
            )
            let database = try RuntimeStoreMigrationControlDatabase(
                rootDescriptor: descriptor,
                rootDirectoryURL: pinnedRoot
            )
            self.rootDirectoryURL = pinnedRoot
            rootDescriptor = descriptor
            controlDatabase = database
            self.verificationIssuanceHook = verificationIssuanceHook
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
        try requireNoPendingIntent()
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
        try requireNoPendingIntent()
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
        if let verificationIssuanceHook {
            await verificationIssuanceHook()
        }
        try controlDatabase.withImmediateTransaction { connection in
            if let pending = try reconcilePendingIntent(connection: connection) {
                throw RuntimeStoreMigrationError.pendingAuthorityIntent(
                    pending.intentIdentity
                )
            }
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

        let intent = try prepareOrResumeActivation(
            reservation: reservation,
            verifiedReport: verifiedReport,
            activatedAt: activatedAt
        )
        return try publishActivation(
            intent,
            verifiedReport: verifiedReport,
            failurePoint: failurePoint
        )
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
    let rootDescriptor: Int32

    init(
        rootDescriptor: Int32,
        rootDirectoryURL: URL
    ) throws {
        self.rootDescriptor = rootDescriptor
        url = rootDirectoryURL.appendingPathComponent(
            RuntimeStoreMigrationFileSystem.controlDatabaseFilename
        )
        let connection = try RuntimeStoreMigrationControlConnection(
            url: url,
            rootDescriptor: rootDescriptor
        )
        try connection.installSchema()
    }

    func withImmediateTransaction<Value>(
        _ body: (RuntimeStoreMigrationControlConnection) throws -> Value
    ) throws -> Value {
        let connection = try RuntimeStoreMigrationControlConnection(
            url: url,
            rootDescriptor: rootDescriptor
        )
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
    var database: OpaquePointer?
    private var pinnedDescriptor: Int32 = -1

    init(
        url: URL,
        rootDescriptor: Int32
    ) throws {
        let rootIdentity = try RuntimeStoreMigrationFileSystem.identity(
            rootDescriptor
        )
        try RuntimeStoreMigrationFileSystem.requireStableDirectory(
            at: url.deletingLastPathComponent(),
            expected: rootIdentity
        )
        let descriptor = try RuntimeStoreMigrationFileSystem.openRegularFile(
            parentDescriptor: rootDescriptor,
            name: RuntimeStoreMigrationFileSystem.controlDatabaseFilename,
            flags: O_RDWR
        )
        let expectedIdentity = try RuntimeStoreMigrationFileSystem.identity(
            descriptor
        )
        let flags = SQLITE_OPEN_CREATE | SQLITE_OPEN_READWRITE
            | SQLITE_OPEN_FULLMUTEX | SQLITE_OPEN_NOFOLLOW
        let result = sqlite3_open_v2(url.path, &database, flags, nil)
        guard result == SQLITE_OK, database != nil else {
            let description = message
            if let database { sqlite3_close(database) }
            database = nil
            RuntimeStoreMigrationFileSystem.close(descriptor)
            throw RuntimeStoreMigrationError.fileOperationFailed(
                operation: "open migration control database",
                description: description
            )
        }
        do {
            try RuntimeStoreMigrationFileSystem.requireStableDirectory(
                at: url.deletingLastPathComponent(),
                expected: rootIdentity
            )
        } catch {
            sqlite3_close(database)
            database = nil
            RuntimeStoreMigrationFileSystem.close(descriptor)
            throw error
        }
        let reopenedDescriptor: Int32
        do {
            reopenedDescriptor = try RuntimeStoreMigrationFileSystem.openRegularFile(
                parentDescriptor: rootDescriptor,
                name: RuntimeStoreMigrationFileSystem.controlDatabaseFilename,
                flags: O_RDWR
            )
        } catch {
            sqlite3_close(database)
            database = nil
            RuntimeStoreMigrationFileSystem.close(descriptor)
            throw error
        }
        let reopenedIdentity = try RuntimeStoreMigrationFileSystem.identity(
            reopenedDescriptor
        )
        RuntimeStoreMigrationFileSystem.close(reopenedDescriptor)
        do {
            guard expectedIdentity == reopenedIdentity else {
                throw RuntimeStoreMigrationError.unsafeFilesystemEntry(
                    RuntimeStoreMigrationFileSystem.controlDatabaseFilename
                )
            }
            try RuntimeStoreMigrationFileSystem.requireSQLiteFileNotMoved(
                database,
                operation: "pin migration control database"
            )
        } catch {
            sqlite3_close(database)
            database = nil
            RuntimeStoreMigrationFileSystem.close(descriptor)
            throw error
        }
        pinnedDescriptor = descriptor
        sqlite3_busy_timeout(database, 30_000)
        do {
            try configureDurability()
        } catch {
            sqlite3_close(database)
            database = nil
            RuntimeStoreMigrationFileSystem.close(descriptor)
            throw error
        }
    }

    deinit {
        if let database { sqlite3_close(database) }
        RuntimeStoreMigrationFileSystem.close(pinnedDescriptor)
    }

    var message: String {
        database.map { String(cString: sqlite3_errmsg($0)) }
            ?? "SQLite control database unavailable"
    }

    func installSchema() throws {
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
            CREATE TABLE IF NOT EXISTS migration_pending_intent (
                singleton INTEGER PRIMARY KEY CHECK(singleton = 1),
                intent_json BLOB NOT NULL
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

    func prepare(
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

    static func blob(
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

    static func canonicalPath(_ descriptor: Int32) throws -> String {
        #if canImport(Darwin)
        var buffer = [CChar](repeating: 0, count: Int(PATH_MAX))
        let result = buffer.withUnsafeMutableBufferPointer { storage in
            runtimeStoreMigrationFcntlPath(
                descriptor,
                F_GETPATH,
                storage.baseAddress!
            )
        }
        guard result == 0 else {
            throw posixError(operation: "resolve pinned coordinator root")
        }
        let terminator = buffer.firstIndex(of: 0) ?? buffer.endIndex
        let bytes = buffer[..<terminator].map(UInt8.init(bitPattern:))
        guard let path = String(bytes: bytes, encoding: .utf8) else {
            throw RuntimeStoreMigrationError.fileOperationFailed(
                operation: "decode pinned coordinator root",
                description: "The filesystem returned a non-UTF-8 path."
            )
        }
        return path
        #else
        let link = "/proc/self/fd/\(descriptor)"
        do {
            return try FileManager.default.destinationOfSymbolicLink(atPath: link)
        } catch {
            throw RuntimeStoreMigrationError.fileOperationFailed(
                operation: "resolve pinned coordinator root",
                description: String(describing: error)
            )
        }
        #endif
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

    static func openRegularFile(
        at url: URL,
        flags: Int32
    ) throws -> Int32 {
        let descriptor = url.path.withCString { path in
            systemOpen(path, flags | O_NOFOLLOW, 0)
        }
        guard descriptor >= 0 else {
            if errno == ENOENT { throw MissingEntry() }
            if errno == ELOOP {
                throw RuntimeStoreMigrationError.storeIsNotRegularFile(
                    url.lastPathComponent
                )
            }
            throw posixError(
                operation: "open regular file \(url.lastPathComponent)"
            )
        }
        do {
            try requireRegularDescriptor(
                descriptor,
                name: url.lastPathComponent
            )
            return descriptor
        } catch {
            close(descriptor)
            throw error
        }
    }

    static func requireStableDirectory(
        at url: URL,
        expected: RuntimeStoreMigrationFileIdentity
    ) throws {
        let descriptor = try openDirectory(at: url)
        defer { close(descriptor) }
        guard try identity(descriptor) == expected else {
            throw RuntimeStoreMigrationError.unsafeFilesystemEntry(
                url.lastPathComponent
            )
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

    static func posixError(
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

    static func systemRenameAt(
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
