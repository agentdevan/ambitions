import Foundation
import SQLite3

public struct SQLiteConfiguration: Sendable, Equatable {
    public var busyTimeoutMilliseconds: Int32
    public var synchronousPolicy: SQLiteSynchronousPolicy
    public var openMode: SQLiteOpenMode
    public var journalMode: SQLiteJournalMode
    /// Maps to `SQLITE_LIMIT_LENGTH` for strings, blobs, and encoded rows.
    public var maximumValueBytes: Int32?
    /// Required authority for a live WAL-aware read-only snapshot. The source
    /// must be contained by this app-private root and every writer/importer of
    /// that namespace must honor the named advisory lock.
    public var readOnlySnapshotAuthority: SQLiteReadOnlySnapshotAuthority?

    public init(
        busyTimeoutMilliseconds: Int32 = 5_000,
        synchronousPolicy: SQLiteSynchronousPolicy = .full,
        openMode: SQLiteOpenMode = .createOrOpen,
        journalMode: SQLiteJournalMode = .wal,
        maximumValueBytes: Int32? = nil,
        readOnlySnapshotAuthority: SQLiteReadOnlySnapshotAuthority? = nil
    ) {
        self.busyTimeoutMilliseconds = busyTimeoutMilliseconds
        self.synchronousPolicy = synchronousPolicy
        self.openMode = openMode
        self.journalMode = journalMode
        self.maximumValueBytes = maximumValueBytes
        self.readOnlySnapshotAuthority = readOnlySnapshotAuthority
    }
}

/// A deliberately narrow capability for WAL-aware import reads. SQLite may
/// create or update bounded `-shm` coordination bytes even on a read-only main
/// database; callers must acknowledge that behavior and own the entire source
/// namespace under a cross-process advisory lock.
public struct SQLiteReadOnlySnapshotAuthority: Sendable, Equatable {
    public let appPrivateRootURL: URL
    public let coordinationLockURL: URL
    public let allowsBoundedSharedMemoryCoordination: Bool

    public init(
        appPrivateRootURL: URL,
        coordinationLockURL: URL,
        allowsBoundedSharedMemoryCoordination: Bool
    ) {
        self.appPrivateRootURL = appPrivateRootURL.standardizedFileURL
        self.coordinationLockURL = coordinationLockURL.standardizedFileURL
        self.allowsBoundedSharedMemoryCoordination = allowsBoundedSharedMemoryCoordination
    }
}

public enum SQLiteJournalMode: String, Codable, Sendable, CaseIterable {
    case wal = "WAL"
    case delete = "DELETE"
}

public enum SQLiteOpenMode: String, Codable, Sendable, CaseIterable {
    case createOrOpen = "create_or_open"
    case existingOnly = "existing_only"
    /// Opens an existing database with SQLite's read-only flag and enables
    /// `query_only`. Verification code uses this mode so inspecting a staged
    /// generation cannot create, checkpoint, recover, or otherwise mutate it.
    case readOnlyExisting = "read_only_existing"
    /// Opens an externally owned live SQLite database read-only while allowing
    /// SQLite to observe and consistently snapshot a valid WAL. This mode is
    /// allowed only with an explicit app-private namespace/coordination-lock
    /// authority. SQLite may update bounded `-shm` coordination bytes; it does
    /// not mutate canonical rows or checkpoint the source. Unlike
    /// `readOnlyExisting`, this mode is not immutable and is only for import.
    case readOnlySnapshot = "read_only_snapshot"
}

public enum SQLiteSynchronousPolicy: String, Codable, Sendable, CaseIterable {
    case off = "OFF"
    case normal = "NORMAL"
    case full = "FULL"
    case extra = "EXTRA"
}

public enum SQLiteBinding: Sendable, Equatable {
    case null
    case integer(Int64)
    case real(Double)
    case text(String)
    case blob(Data)
}

public enum SQLiteValue: Sendable, Equatable {
    case null
    case integer(Int64)
    case real(Double)
    case text(String)
    case blob(Data)
}

public struct SQLiteRow: Sendable, Equatable {
    public let columnNames: [String]
    public let values: [SQLiteValue]

    init(columnNames: [String], values: [SQLiteValue]) {
        self.columnNames = columnNames
        self.values = values
    }

    public subscript(index: Int) -> SQLiteValue {
        values[index]
    }

    public func value(named name: String) -> SQLiteValue? {
        guard let index = columnNames.firstIndex(of: name) else { return nil }
        return values[index]
    }
}

/// A finite materialization and VM-work budget for one SQLite statement.
///
/// The database layer never exposes an unbounded `sqlite3_step` loop. Callers
/// that need a larger scan must explicitly select a budget and should normally
/// use a keyset cursor rather than raise this limit indefinitely.
public struct SQLiteQueryBudget: Sendable, Equatable {
    public let maximumDecodedBytes: Int
    public let maximumRowCount: Int
    public let maximumProgressCallbacks: Int
    public let progressInstructionInterval: Int32

    public init(
        maximumDecodedBytes: Int,
        maximumRowCount: Int,
        maximumProgressCallbacks: Int,
        progressInstructionInterval: Int32 = 1_000
    ) throws {
        guard maximumDecodedBytes >= 0,
              maximumRowCount >= 0,
              maximumProgressCallbacks > 0,
              progressInstructionInterval > 0 else {
            throw SQLiteError(operation: .configure, extendedCode: SQLITE_MISUSE)
        }
        self.maximumDecodedBytes = maximumDecodedBytes
        self.maximumRowCount = maximumRowCount
        self.maximumProgressCallbacks = maximumProgressCallbacks
        self.progressInstructionInterval = progressInstructionInterval
    }

    /// A deliberately conservative compatibility ceiling. Production callers
    /// should select a smaller page-specific budget whenever they know one.
    public static let `default` = try! SQLiteQueryBudget(
        maximumDecodedBytes: 4 * 1_024 * 1_024,
        maximumRowCount: 4_096,
        maximumProgressCallbacks: 100_000
    )

    /// Integrity and foreign-key diagnostics are bounded separately because
    /// they can report many independent violations on corrupt input.
    public static let diagnostics = try! SQLiteQueryBudget(
        maximumDecodedBytes: 1 * 1_024 * 1_024,
        maximumRowCount: 1_024,
        maximumProgressCallbacks: 250_000
    )
}

public enum SQLiteQueryBudgetLimit: String, Sendable, Equatable {
    case decodedBytes
    case rowCount
    case virtualMachineWork
    case cancelled
}

public struct SQLiteQueryBudgetExceeded: Error, Sendable, Equatable {
    public let limit: SQLiteQueryBudgetLimit
    public let maximumBytes: Int
    public let maximumRowCount: Int
    public let maximumProgressCallbacks: Int

    init(
        limit: SQLiteQueryBudgetLimit = .decodedBytes,
        maximumBytes: Int,
        maximumRowCount: Int = 0,
        maximumProgressCallbacks: Int = 0
    ) {
        self.limit = limit
        self.maximumBytes = maximumBytes
        self.maximumRowCount = maximumRowCount
        self.maximumProgressCallbacks = maximumProgressCallbacks
    }
}

public struct SQLiteExecutionResult: Sendable, Equatable {
    public let changedRowCount: Int32
    public let lastInsertedRowID: Int64

    init(changedRowCount: Int32, lastInsertedRowID: Int64) {
        self.changedRowCount = changedRowCount
        self.lastInsertedRowID = lastInsertedRowID
    }
}

public struct SQLiteReservedFileIdentity: Sendable, Equatable {
    public let device: UInt64
    public let inode: UInt64

    init(device: UInt64, inode: UInt64) {
        self.device = device
        self.inode = inode
    }
}

public enum SQLiteTransactionMode: String, Codable, Sendable, CaseIterable {
    case deferred = "DEFERRED"
    case immediate = "IMMEDIATE"
    case exclusive = "EXCLUSIVE"
}

/// A deny-by-default write boundary enforced by SQLite's statement authorizer.
/// Reads are limited to an explicit source catalog, and every table mutation
/// (including mutations performed by triggers) must name an allowed table.
/// Schema, attachment, pragma-write, and transaction-control statements remain
/// forbidden to the public transaction body.
public struct SQLiteWriteAuthorization: Sendable, Equatable {
    public let allowedTables: Set<String>
    public let allowedReadTables: Set<String>

    public init(
        allowedTables: Set<String>,
        allowedReadTables: Set<String>
    ) throws {
        guard allowedTables.isEmpty == false,
              allowedReadTables.isEmpty == false,
              allowedTables.allSatisfy({ table in
                  table.isEmpty == false &&
                      table == table.lowercased() &&
                      table.unicodeScalars.allSatisfy {
                          CharacterSet.alphanumerics.union(
                              CharacterSet(charactersIn: "_")
                          ).contains($0)
                      }
              }),
              allowedReadTables.allSatisfy({ table in
                  table.isEmpty == false && table == table.lowercased()
              }) else {
            throw SQLiteError(operation: .configure, extendedCode: SQLITE_MISUSE)
        }
        self.allowedTables = allowedTables
        self.allowedReadTables = allowedReadTables
    }
}

/// A narrowly named bootstrap capability. It is intentionally distinct from
/// ordinary mutation authority: schema construction is never permitted by a
/// normal write transaction.
public struct SQLiteBootstrapAuthorization: Sendable, Equatable {
    public let allowedSchemaObjects: Set<String>

    public init(allowedSchemaObjects: Set<String>) throws {
        guard allowedSchemaObjects.isEmpty == false,
              allowedSchemaObjects.allSatisfy(Self.isSafeIdentifier) else {
            throw SQLiteError(operation: .configure, extendedCode: SQLITE_MISUSE)
        }
        self.allowedSchemaObjects = allowedSchemaObjects
    }

    static func isSafeIdentifier(_ value: String) -> Bool {
        value.isEmpty == false && value == value.lowercased() &&
            value.unicodeScalars.allSatisfy {
                CharacterSet.alphanumerics.union(
                    CharacterSet(charactersIn: "_")
                ).contains($0)
            }
    }
}

/// A one-purpose capability for a recognized in-place schema upgrade. Unlike
/// bootstrap it may drop only explicitly named prior schema objects; unlike a
/// normal write capability it may issue only the matching DDL and data-row
/// mutations supplied by the caller.
public struct SQLiteSchemaMigrationAuthorization: Sendable, Equatable {
    public let allowedSchemaObjects: Set<String>
    public let allowedTables: Set<String>
    public let allowedReadTables: Set<String>

    public init(
        allowedSchemaObjects: Set<String>,
        allowedTables: Set<String>,
        allowedReadTables: Set<String>
    ) throws {
        guard allowedSchemaObjects.isEmpty == false,
              allowedTables.isEmpty == false,
              allowedReadTables.isEmpty == false,
              allowedSchemaObjects.allSatisfy(SQLiteBootstrapAuthorization.isSafeIdentifier),
              allowedTables.allSatisfy(SQLiteBootstrapAuthorization.isSafeIdentifier),
              allowedReadTables.allSatisfy(SQLiteBootstrapAuthorization.isSafeIdentifier) else {
            throw SQLiteError(operation: .configure, extendedCode: SQLITE_MISUSE)
        }
        self.allowedSchemaObjects = allowedSchemaObjects
        self.allowedTables = allowedTables
        self.allowedReadTables = allowedReadTables
    }
}

public enum SQLiteTransactionFailurePhase: String, Codable, Sendable, Equatable {
    case body
    case commit
}

/// Reports that a failed transaction could not also be rolled back cleanly.
///
/// The body error is deliberately not rendered because it may contain private
/// caller values. The phase and safe SQLite rollback diagnostics remain clear.
public struct SQLiteTransactionRollbackError: Error, Sendable, Equatable {
    public let precedingFailure: SQLiteTransactionFailurePhase
    public let rollbackFailure: SQLiteError
    /// `nil` means SQLite accepted the terminal close. A non-nil value means
    /// the actor retained the poisoned handle because ownership is
    /// indeterminate; no further statements can execute on that connection.
    public let closeFailure: SQLiteError?

    init(
        precedingFailure: SQLiteTransactionFailurePhase,
        rollbackFailure: SQLiteError,
        closeFailure: SQLiteError? = nil
    ) {
        self.precedingFailure = precedingFailure
        self.rollbackFailure = rollbackFailure
        self.closeFailure = closeFailure
    }
}

/// COMMIT returned an error after SQLite had already left the transaction.
/// Callers must reconcile by idempotency identity because durability cannot be
/// truthfully classified as success or rollback from the return code alone.
public struct SQLiteTransactionCommitIndeterminateError: Error, Sendable, Equatable {
    public let commitFailure: SQLiteError

    init(commitFailure: SQLiteError) {
        self.commitFailure = commitFailure
    }
}

extension SQLiteTransactionRollbackError: CustomStringConvertible, LocalizedError {
    public var description: String {
        "SQLite transaction \(precedingFailure.rawValue) failed, and rollback "
            + "also failed (code \(rollbackFailure.primaryCode), extended code "
            + "\(rollbackFailure.extendedCode))"
            + (closeFailure == nil ? "." : "; terminal close is indeterminate.")
    }

    public var errorDescription: String? {
        description
    }
}

public enum SQLiteCheckpointMode: Sendable, Equatable {
    case passive
    case full
    case restart
    case truncate
}

public struct SQLiteCheckpointResult: Sendable, Equatable {
    public let logFrameCount: Int32
    public let checkpointedFrameCount: Int32

    init(logFrameCount: Int32, checkpointedFrameCount: Int32) {
        self.logFrameCount = logFrameCount
        self.checkpointedFrameCount = checkpointedFrameCount
    }
}

public struct SQLiteBackupResult: Sendable, Equatable {
    public let pageCount: Int32
    public let remainingPageCount: Int32

    init(pageCount: Int32, remainingPageCount: Int32) {
        self.pageCount = pageCount
        self.remainingPageCount = remainingPageCount
    }
}

public struct SQLiteIntegrityResult: Sendable, Equatable {
    public let messages: [String]

    public var isOK: Bool {
        messages == ["ok"]
    }

    init(messages: [String]) {
        self.messages = messages
    }
}

public struct SQLiteForeignKeyViolation: Sendable, Equatable {
    public let table: String
    public let rowID: Int64?
    public let parentTable: String
    public let constraintIndex: Int64

    init(
        table: String,
        rowID: Int64?,
        parentTable: String,
        constraintIndex: Int64
    ) {
        self.table = table
        self.rowID = rowID
        self.parentTable = parentTable
        self.constraintIndex = constraintIndex
    }
}

public enum SQLiteOperation: String, Codable, Sendable, CaseIterable {
    case open
    case configure
    case prepare
    case bind
    case step
    case decode
    case transaction
    case connection = "connection state"
    case close
    case checkpoint
    case backup
    case integrityCheck = "integrity check"
    case foreignKeyCheck = "foreign-key check"
}

/// A privacy-safe SQLite error that retains numeric diagnostics only.
///
/// SQL text, database paths, SQLite messages, and bound values are deliberately
/// excluded so error logging cannot disclose caller data.
public struct SQLiteError: Error, Sendable, Equatable {
    public let operation: SQLiteOperation
    public let primaryCode: Int32
    public let extendedCode: Int32

    init(
        operation: SQLiteOperation,
        extendedCode: Int32
    ) {
        self.operation = operation
        let failureCode = extendedCode == SQLITE_OK
            ? SQLITE_MISUSE
            : extendedCode
        self.extendedCode = failureCode
        primaryCode = failureCode & 0xFF
    }
}

extension SQLiteError: CustomStringConvertible, LocalizedError {
    public var description: String {
        "SQLite \(operation.rawValue) failed "
            + "(code \(primaryCode), extended code \(extendedCode))."
    }

    public var errorDescription: String? {
        description
    }
}
