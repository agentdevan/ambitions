import Foundation
import SQLite3

public struct SQLiteConfiguration: Sendable, Equatable {
    public var busyTimeoutMilliseconds: Int32
    public var synchronousPolicy: SQLiteSynchronousPolicy
    /// Maps to `SQLITE_LIMIT_LENGTH` for strings, blobs, and encoded rows.
    public var maximumValueBytes: Int32?

    public init(
        busyTimeoutMilliseconds: Int32 = 5_000,
        synchronousPolicy: SQLiteSynchronousPolicy = .full,
        maximumValueBytes: Int32? = nil
    ) {
        self.busyTimeoutMilliseconds = busyTimeoutMilliseconds
        self.synchronousPolicy = synchronousPolicy
        self.maximumValueBytes = maximumValueBytes
    }
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

public struct SQLiteExecutionResult: Sendable, Equatable {
    public let changedRowCount: Int32
    public let lastInsertedRowID: Int64

    init(changedRowCount: Int32, lastInsertedRowID: Int64) {
        self.changedRowCount = changedRowCount
        self.lastInsertedRowID = lastInsertedRowID
    }
}

public enum SQLiteTransactionMode: String, Codable, Sendable, CaseIterable {
    case deferred = "DEFERRED"
    case immediate = "IMMEDIATE"
    case exclusive = "EXCLUSIVE"
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

    init(
        precedingFailure: SQLiteTransactionFailurePhase,
        rollbackFailure: SQLiteError
    ) {
        self.precedingFailure = precedingFailure
        self.rollbackFailure = rollbackFailure
    }
}

extension SQLiteTransactionRollbackError: CustomStringConvertible, LocalizedError {
    public var description: String {
        "SQLite transaction \(precedingFailure.rawValue) failed, and rollback "
            + "also failed (code \(rollbackFailure.primaryCode), extended code "
            + "\(rollbackFailure.extendedCode))."
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
