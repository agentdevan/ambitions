import Foundation
import SQLite3

/// An actor-owned SQLite connection exposing prepared, value-oriented APIs.
///
/// The connection handle and prepared statements remain private to this actor.
/// This module provides storage mechanics and deliberately owns no Ambitions
/// command, migration, projection, receipt, or other product policy.
public actor SQLiteDatabase {
    public let databaseURL: URL
    public let configuration: SQLiteConfiguration

    private var handle: OpaquePointer?
    private var terminalError: SQLiteError?
    private let authorizerState: SQLiteAuthorizerState

    public init(
        url: URL,
        configuration: SQLiteConfiguration = SQLiteConfiguration()
    ) throws {
        databaseURL = url.standardizedFileURL
        self.configuration = configuration
        handle = nil
        terminalError = nil
        authorizerState = SQLiteAuthorizerState()

        guard configuration.busyTimeoutMilliseconds >= 0,
              configuration.maximumValueBytes.map({ $0 > 0 }) ?? true
        else {
            throw SQLiteError(
                operation: .configure,
                extendedCode: SQLITE_MISUSE
            )
        }

        do {
            try FileManager.default.createDirectory(
                at: databaseURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
        } catch {
            throw SQLiteError(
                operation: .open,
                extendedCode: SQLITE_CANTOPEN
            )
        }

        var openedHandle: OpaquePointer?
        let flags = SQLITE_OPEN_CREATE
            | SQLITE_OPEN_READWRITE
            | SQLITE_OPEN_FULLMUTEX
            | SQLITE_OPEN_URI
        let openResult = sqlite3_open_v2(
            databaseURL.path,
            &openedHandle,
            flags,
            nil
        )
        guard openResult == SQLITE_OK, let openedHandle else {
            if let openedHandle {
                sqlite3_close_v2(openedHandle)
            }
            throw SQLiteError(
                operation: .open,
                extendedCode: openResult == SQLITE_OK
                    ? SQLITE_MISUSE
                    : openResult
            )
        }
        handle = openedHandle
        sqlite3_extended_result_codes(openedHandle, 1)

        do {
            try Self.configure(openedHandle, configuration: configuration)
            try Self.setPublicStatementAuthorizer(
                openedHandle,
                state: authorizerState
            )
        } catch {
            sqlite3_close_v2(openedHandle)
            handle = nil
            throw error
        }
    }

    deinit {
        if let handle {
            sqlite3_close_v2(handle)
        }
    }

    @discardableResult
    public func execute(
        _ sql: String,
        bindings: [SQLiteBinding] = []
    ) throws -> SQLiteExecutionResult {
        guard let handle else {
            throw unavailableError(operation: .prepare)
        }
        let statement = try prepare(sql, operation: .prepare)
        defer { sqlite3_finalize(statement) }
        try bind(bindings, to: statement)

        let stepResult = sqlite3_step(statement)
        guard stepResult == SQLITE_DONE else {
            throw databaseError(
                handle: handle,
                operation: .step,
                resultCode: stepResult
            )
        }
        return SQLiteExecutionResult(
            changedRowCount: sqlite3_changes(handle),
            lastInsertedRowID: sqlite3_last_insert_rowid(handle)
        )
    }

    public func query(
        _ sql: String,
        bindings: [SQLiteBinding] = []
    ) throws -> [SQLiteRow] {
        try query(sql, bindings: bindings, operation: .step)
    }

    /// Runs a transaction without a suspension point or actor reentrancy.
    ///
    /// The isolated synchronous closure can call database methods directly but
    /// cannot `await`. Public statements always deny transaction-control SQL;
    /// only this wrapper temporarily authorizes its own control statements.
    /// Body and commit failures trigger rollback before the original error is
    /// rethrown. An unresolved rollback closes and poisons the connection and
    /// throws `SQLiteTransactionRollbackError`, so durability is never
    /// overstated.
    public func transaction<Result: Sendable>(
        _ mode: SQLiteTransactionMode = .immediate,
        _ operation: @Sendable (
            _ database: isolated SQLiteDatabase
        ) throws -> Result
    ) throws -> Result {
        guard let handle, sqlite3_get_autocommit(handle) != 0 else {
            throw misuseError(operation: .transaction)
        }
        do {
            try executeTransactionStatement("BEGIN \(mode.rawValue) TRANSACTION")
        } catch {
            let beginError = error
            if let activeHandle = self.handle,
               sqlite3_get_autocommit(activeHandle) == 0 {
                try rollback(after: .body)
            }
            throw beginError
        }
        guard sqlite3_get_autocommit(handle) == 0 else {
            throw misuseError(operation: .transaction)
        }

        let result: Result
        do {
            result = try operation(self)
        } catch {
            let bodyError = error
            try rollback(after: .body)
            throw bodyError
        }

        do {
            try executeTransactionStatement("COMMIT TRANSACTION")
            guard sqlite3_get_autocommit(handle) != 0 else {
                throw misuseError(operation: .transaction)
            }
        } catch {
            let commitError = error
            if self.handle != nil {
                try rollback(after: .commit)
            }
            throw commitError
        }
        return result
    }

    public func checkpoint(
        _ mode: SQLiteCheckpointMode = .passive
    ) throws -> SQLiteCheckpointResult {
        guard let handle else {
            throw unavailableError(operation: .checkpoint)
        }
        var logFrameCount: Int32 = 0
        var checkpointedFrameCount: Int32 = 0
        let result = sqlite3_wal_checkpoint_v2(
            handle,
            "main",
            mode.sqliteValue,
            &logFrameCount,
            &checkpointedFrameCount
        )
        guard result == SQLITE_OK else {
            throw databaseError(
                handle: handle,
                operation: .checkpoint,
                resultCode: result
            )
        }
        return SQLiteCheckpointResult(
            logFrameCount: logFrameCount,
            checkpointedFrameCount: checkpointedFrameCount
        )
    }

    public func backup(
        to destinationURL: URL,
        pagesPerStep: Int32 = 128,
        busyRetryLimit: Int = 50
    ) throws -> SQLiteBackupResult {
        guard let sourceHandle = handle,
              pagesPerStep > 0,
              busyRetryLimit >= 0
        else {
            throw misuseError(operation: .backup)
        }

        let destinationURL = destinationURL.standardizedFileURL
        guard destinationURL != databaseURL else {
            throw misuseError(operation: .backup)
        }
        do {
            try FileManager.default.createDirectory(
                at: destinationURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
        } catch {
            throw SQLiteError(
                operation: .backup,
                extendedCode: SQLITE_CANTOPEN
            )
        }

        var destinationHandle: OpaquePointer?
        let openResult = sqlite3_open_v2(
            destinationURL.path,
            &destinationHandle,
            SQLITE_OPEN_CREATE | SQLITE_OPEN_READWRITE | SQLITE_OPEN_FULLMUTEX,
            nil
        )
        guard openResult == SQLITE_OK, let destinationHandle else {
            if let destinationHandle {
                sqlite3_close_v2(destinationHandle)
            }
            throw SQLiteError(
                operation: .backup,
                extendedCode: openResult == SQLITE_OK
                    ? SQLITE_MISUSE
                    : openResult
            )
        }
        sqlite3_extended_result_codes(destinationHandle, 1)
        defer { sqlite3_close_v2(destinationHandle) }

        guard let backup = sqlite3_backup_init(
            destinationHandle,
            "main",
            sourceHandle,
            "main"
        ) else {
            throw databaseError(
                handle: destinationHandle,
                operation: .backup,
                resultCode: sqlite3_errcode(destinationHandle),
                fallbackCode: SQLITE_ERROR
            )
        }

        var retriesRemaining = busyRetryLimit
        var stepResult: Int32
        repeat {
            stepResult = sqlite3_backup_step(backup, pagesPerStep)
            if stepResult == SQLITE_BUSY || stepResult == SQLITE_LOCKED {
                guard retriesRemaining > 0 else { break }
                retriesRemaining -= 1
                sqlite3_sleep(10)
            }
        } while stepResult == SQLITE_OK
            || stepResult == SQLITE_BUSY
            || stepResult == SQLITE_LOCKED

        let pageCount = sqlite3_backup_pagecount(backup)
        let remainingPageCount = sqlite3_backup_remaining(backup)
        let finishResult = sqlite3_backup_finish(backup)
        guard stepResult == SQLITE_DONE, finishResult == SQLITE_OK else {
            let result = stepResult == SQLITE_DONE ? finishResult : stepResult
            throw databaseError(
                handle: destinationHandle,
                operation: .backup,
                resultCode: result
            )
        }
        return SQLiteBackupResult(
            pageCount: pageCount,
            remainingPageCount: remainingPageCount
        )
    }

    public func integrityCheck() throws -> SQLiteIntegrityResult {
        let rows = try query(
            "PRAGMA integrity_check",
            bindings: [],
            operation: .integrityCheck
        )
        let messages = rows.compactMap { row -> String? in
            guard case let .text(message) = row.values.first else { return nil }
            return message
        }
        guard messages.count == rows.count, !messages.isEmpty else {
            throw misuseError(operation: .integrityCheck)
        }
        return SQLiteIntegrityResult(messages: messages)
    }

    public func foreignKeyCheck() throws -> [SQLiteForeignKeyViolation] {
        let rows = try query(
            "PRAGMA foreign_key_check",
            bindings: [],
            operation: .foreignKeyCheck
        )
        return try rows.map { row in
            guard row.values.count == 4,
                  case let .text(table) = row.values[0],
                  case let .text(parentTable) = row.values[2],
                  case let .integer(constraintIndex) = row.values[3]
            else {
                throw misuseError(operation: .foreignKeyCheck)
            }
            let rowID: Int64?
            switch row.values[1] {
            case let .integer(value):
                rowID = value
            case .null:
                rowID = nil
            default:
                throw misuseError(operation: .foreignKeyCheck)
            }
            return SQLiteForeignKeyViolation(
                table: table,
                rowID: rowID,
                parentTable: parentTable,
                constraintIndex: constraintIndex
            )
        }
    }
}

private extension SQLiteDatabase {
    static func configure(
        _ handle: OpaquePointer,
        configuration: SQLiteConfiguration
    ) throws {
        let busyTimeoutResult = sqlite3_busy_timeout(
            handle,
            configuration.busyTimeoutMilliseconds
        )
        guard busyTimeoutResult == SQLITE_OK else {
            throw databaseError(
                handle: handle,
                operation: .configure,
                resultCode: busyTimeoutResult
            )
        }
        try executeRaw("PRAGMA foreign_keys=ON", handle: handle)
        try executeRaw("PRAGMA journal_mode=WAL", handle: handle)
        try executeRaw(
            "PRAGMA synchronous=\(configuration.synchronousPolicy.rawValue)",
            handle: handle
        )
        if let maximumValueBytes = configuration.maximumValueBytes {
            _ = sqlite3_limit(handle, SQLITE_LIMIT_LENGTH, maximumValueBytes)
        }
    }

    static func executeRaw(
        _ sql: String,
        handle: OpaquePointer
    ) throws {
        let result = sqlite3_exec(handle, sql, nil, nil, nil)
        guard result == SQLITE_OK else {
            throw databaseError(
                handle: handle,
                operation: .configure,
                resultCode: result
            )
        }
    }

    func prepare(
        _ sql: String,
        operation: SQLiteOperation
    ) throws -> OpaquePointer {
        guard let handle else {
            throw unavailableError(operation: operation)
        }
        var statement: OpaquePointer?
        let result = sqlite3_prepare_v2(handle, sql, -1, &statement, nil)
        guard result == SQLITE_OK else {
            throw databaseError(
                handle: handle,
                operation: operation,
                resultCode: result
            )
        }
        guard let statement else {
            throw misuseError(operation: operation)
        }
        return statement
    }

    func bind(
        _ bindings: [SQLiteBinding],
        to statement: OpaquePointer
    ) throws {
        guard let handle else {
            throw unavailableError(operation: .bind)
        }
        guard Int(sqlite3_bind_parameter_count(statement)) == bindings.count else {
            throw misuseError(operation: .bind)
        }

        for (offset, binding) in bindings.enumerated() {
            let index = Int32(offset + 1)
            let result: Int32
            switch binding {
            case .null:
                result = sqlite3_bind_null(statement, index)
            case let .integer(value):
                result = sqlite3_bind_int64(statement, index, value)
            case let .real(value):
                result = sqlite3_bind_double(statement, index, value)
            case let .text(value):
                let utf8 = value.utf8CString
                result = utf8.withUnsafeBufferPointer { buffer in
                    sqlite3_bind_text64(
                        statement,
                        index,
                        buffer.baseAddress,
                        UInt64(buffer.count - 1),
                        sqliteTransient,
                        UInt8(SQLITE_UTF8)
                    )
                }
            case let .blob(value) where value.isEmpty:
                result = sqlite3_bind_zeroblob(statement, index, 0)
            case let .blob(value):
                result = value.withUnsafeBytes { bytes in
                    sqlite3_bind_blob64(
                        statement,
                        index,
                        bytes.baseAddress,
                        UInt64(value.count),
                        sqliteTransient
                    )
                }
            }
            guard result == SQLITE_OK else {
                throw databaseError(
                    handle: handle,
                    operation: .bind,
                    resultCode: result
                )
            }
        }
    }

    func query(
        _ sql: String,
        bindings: [SQLiteBinding],
        operation: SQLiteOperation
    ) throws -> [SQLiteRow] {
        guard let handle else {
            throw unavailableError(operation: operation)
        }
        let statement = try prepare(sql, operation: operation)
        defer { sqlite3_finalize(statement) }
        try bind(bindings, to: statement)

        var rows: [SQLiteRow] = []
        while true {
            let stepResult = sqlite3_step(statement)
            switch stepResult {
            case SQLITE_ROW:
                rows.append(try readRow(statement))
            case SQLITE_DONE:
                return rows
            default:
                throw databaseError(
                    handle: handle,
                    operation: operation,
                    resultCode: stepResult
                )
            }
        }
    }

    func readRow(_ statement: OpaquePointer) throws -> SQLiteRow {
        let count = sqlite3_column_count(statement)
        var names: [String] = []
        var values: [SQLiteValue] = []
        names.reserveCapacity(Int(count))
        values.reserveCapacity(Int(count))

        for index in 0..<count {
            guard let columnName = sqlite3_column_name(statement, index),
                  let decodedColumnName = String(validatingCString: columnName)
            else {
                throw decodingError(extendedCode: SQLITE_CORRUPT)
            }
            names.append(decodedColumnName)
            switch sqlite3_column_type(statement, index) {
            case SQLITE_INTEGER:
                values.append(.integer(sqlite3_column_int64(statement, index)))
            case SQLITE_FLOAT:
                values.append(.real(sqlite3_column_double(statement, index)))
            case SQLITE_TEXT:
                guard let text = sqlite3_column_text(statement, index) else {
                    throw decodingError(extendedCode: SQLITE_CORRUPT)
                }
                let byteCount = Int(sqlite3_column_bytes(statement, index))
                let buffer = UnsafeBufferPointer(
                    start: text,
                    count: byteCount
                )
                guard let value = String(bytes: buffer, encoding: .utf8) else {
                    throw decodingError(extendedCode: SQLITE_MISMATCH)
                }
                values.append(.text(value))
            case SQLITE_BLOB:
                let count = Int(sqlite3_column_bytes(statement, index))
                if count == 0 {
                    values.append(.blob(Data()))
                } else if let bytes = sqlite3_column_blob(statement, index) {
                    values.append(.blob(Data(bytes: bytes, count: count)))
                } else {
                    throw decodingError(extendedCode: SQLITE_CORRUPT)
                }
            case SQLITE_NULL:
                values.append(.null)
            default:
                throw decodingError(extendedCode: SQLITE_CORRUPT)
            }
        }
        return SQLiteRow(columnNames: names, values: values)
    }

    func decodingError(extendedCode: Int32) -> SQLiteError {
        SQLiteError(operation: .decode, extendedCode: extendedCode)
    }

    func executeTransactionStatement(_ sql: String) throws {
        guard let handle else {
            throw unavailableError(operation: .transaction)
        }
        precondition(!authorizerState.allowsInternalTransactionControl)
        authorizerState.allowsInternalTransactionControl = true
        defer { authorizerState.allowsInternalTransactionControl = false }

        var errorMessage: UnsafeMutablePointer<CChar>?
        let result = sqlite3_exec(handle, sql, nil, nil, &errorMessage)
        if let errorMessage {
            sqlite3_free(errorMessage)
        }
        guard result == SQLITE_OK else {
            throw databaseError(
                handle: handle,
                operation: .transaction,
                resultCode: result
            )
        }
    }

    static func setPublicStatementAuthorizer(
        _ handle: OpaquePointer,
        state: SQLiteAuthorizerState
    ) throws {
        let result = sqlite3_set_authorizer(
            handle,
            sqlitePublicStatementAuthorizer,
            Unmanaged.passUnretained(state).toOpaque()
        )
        guard result == SQLITE_OK else {
            throw databaseError(
                handle: handle,
                operation: .configure,
                resultCode: result
            )
        }
    }

    func rollback(after phase: SQLiteTransactionFailurePhase) throws {
        guard let handle else {
            throw SQLiteTransactionRollbackError(
                precedingFailure: phase,
                rollbackFailure: unavailableError(operation: .transaction)
            )
        }
        guard sqlite3_get_autocommit(handle) == 0 else {
            return
        }
        do {
            try executeTransactionStatement("ROLLBACK TRANSACTION")
        } catch {
            if let activeHandle = self.handle,
               sqlite3_get_autocommit(activeHandle) != 0 {
                return
            }
            let rollbackError = error as? SQLiteError
                ?? misuseError(operation: .transaction)
            poisonConnectionAfterUnresolvedRollback(rollbackError)
            throw SQLiteTransactionRollbackError(
                precedingFailure: phase,
                rollbackFailure: rollbackError
            )
        }
        guard let activeHandle = self.handle,
              sqlite3_get_autocommit(activeHandle) != 0
        else {
            let rollbackError = misuseError(operation: .transaction)
            poisonConnectionAfterUnresolvedRollback(rollbackError)
            throw SQLiteTransactionRollbackError(
                precedingFailure: phase,
                rollbackFailure: rollbackError
            )
        }
    }

    func unavailableError(operation: SQLiteOperation) -> SQLiteError {
        terminalError ?? SQLiteError(
            operation: operation,
            extendedCode: SQLITE_MISUSE
        )
    }

    func misuseError(operation: SQLiteOperation) -> SQLiteError {
        terminalError ?? SQLiteError(
            operation: operation,
            extendedCode: SQLITE_MISUSE
        )
    }

    static func databaseError(
        handle: OpaquePointer,
        operation: SQLiteOperation,
        resultCode: Int32,
        fallbackCode: Int32 = SQLITE_MISUSE
    ) -> SQLiteError {
        let observedExtendedCode = sqlite3_extended_errcode(handle)
        let immediateCode = resultCode == SQLITE_OK ? fallbackCode : resultCode
        let extendedCode: Int32
        if observedExtendedCode != SQLITE_OK,
           observedExtendedCode & 0xFF == immediateCode & 0xFF {
            extendedCode = observedExtendedCode
        } else {
            extendedCode = immediateCode == SQLITE_OK
                ? SQLITE_MISUSE
                : immediateCode
        }
        return SQLiteError(
            operation: operation,
            extendedCode: extendedCode
        )
    }
}

extension SQLiteDatabase {
    func poisonConnectionAfterUnresolvedRollback(_ rollbackError: SQLiteError) {
        guard terminalError == nil else { return }
        terminalError = SQLiteError(
            operation: .connection,
            extendedCode: rollbackError.extendedCode
        )
        if let handle {
            sqlite3_close_v2(handle)
            self.handle = nil
        }
    }
}

private extension SQLiteCheckpointMode {
    var sqliteValue: Int32 {
        switch self {
        case .passive:
            SQLITE_CHECKPOINT_PASSIVE
        case .full:
            SQLITE_CHECKPOINT_FULL
        case .restart:
            SQLITE_CHECKPOINT_RESTART
        case .truncate:
            SQLITE_CHECKPOINT_TRUNCATE
        }
    }
}

/// Synchronously consulted only while SQLite is executing on its actor-owned
/// connection. The callback cannot suspend or escape the SQLite call.
private final class SQLiteAuthorizerState {
    var allowsInternalTransactionControl = false
}

private func sqlitePublicStatementAuthorizer(
    _ context: UnsafeMutableRawPointer?,
    _ actionCode: Int32,
    _ firstDetail: UnsafePointer<CChar>?,
    _ secondDetail: UnsafePointer<CChar>?,
    _ databaseName: UnsafePointer<CChar>?,
    _ triggerName: UnsafePointer<CChar>?
) -> Int32 {
    _ = firstDetail
    _ = secondDetail
    _ = databaseName
    _ = triggerName
    switch actionCode {
    case SQLITE_TRANSACTION, SQLITE_SAVEPOINT:
        guard let context else { return SQLITE_DENY }
        let state = Unmanaged<SQLiteAuthorizerState>
            .fromOpaque(context)
            .takeUnretainedValue()
        return state.allowsInternalTransactionControl ? SQLITE_OK : SQLITE_DENY
    default:
        SQLITE_OK
    }
}

private let sqliteTransient = unsafeBitCast(
    -1,
    to: sqlite3_destructor_type.self
)
