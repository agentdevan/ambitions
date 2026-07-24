import Dispatch
import Foundation
import XCTest
@testable import AmbitionsRuntimeSQLite

final class SQLiteDatabaseTests: XCTestCase {
    func testPreparedStatementsRoundTripTypedValuesAndApplyPragmas() async throws {
        let database = try SQLiteDatabase(url: try databaseURL())
        _ = try await database.execute(
            """
            CREATE TABLE values_table (
                integer_value INTEGER,
                real_value REAL,
                text_value TEXT,
                blob_value BLOB,
                null_value TEXT
            )
            """
        )
        _ = try await database.execute(
            """
            INSERT INTO values_table (
                integer_value, real_value, text_value, blob_value, null_value
            ) VALUES (?, ?, ?, ?, ?)
            """,
            bindings: [
                .integer(42),
                .real(3.5),
                .text("value"),
                .blob(Data([1, 2, 3])),
                .null
            ]
        )

        let rows = try await database.query(
            """
            SELECT integer_value, real_value, text_value, blob_value, null_value
            FROM values_table
            """
        )
        XCTAssertEqual(rows.count, 1)
        XCTAssertEqual(rows[0].value(named: "integer_value"), .integer(42))
        XCTAssertEqual(rows[0].value(named: "real_value"), .real(3.5))
        XCTAssertEqual(rows[0].value(named: "text_value"), .text("value"))
        XCTAssertEqual(rows[0].value(named: "blob_value"), .blob(Data([1, 2, 3])))
        XCTAssertEqual(rows[0].value(named: "null_value"), .null)

        let foreignKeys = try await database.query("PRAGMA foreign_keys")
        let journalMode = try await database.query("PRAGMA journal_mode")
        let synchronous = try await database.query("PRAGMA synchronous")
        let busyTimeout = try await database.query("PRAGMA busy_timeout")
        XCTAssertEqual(foreignKeys[0][0], .integer(1))
        XCTAssertEqual(journalMode[0][0], .text("wal"))
        XCTAssertEqual(synchronous[0][0], .integer(2))
        XCTAssertEqual(busyTimeout[0][0], .integer(5_000))
    }

    func testTextBindingAndReadingPreserveEmbeddedNULBytes() async throws {
        let database = try SQLiteDatabase(url: try databaseURL())
        _ = try await database.execute(
            "CREATE TABLE text_values (value TEXT NOT NULL)"
        )
        let value = "prefix\u{0}suffix"
        _ = try await database.execute(
            "INSERT INTO text_values (value) VALUES (?)",
            bindings: [.text(value)]
        )
        _ = try await database.execute(
            "INSERT INTO text_values (value) VALUES (?)",
            bindings: [.text("")]
        )

        let rows = try await database.query(
            "SELECT value FROM text_values ORDER BY rowid"
        )
        XCTAssertEqual(rows.map { $0[0] }, [.text(value), .text("")])
    }

    func testInvalidUTF8TextFailsWithPrivacySafeDecodeError() async throws {
        let database = try SQLiteDatabase(url: try databaseURL())
        _ = try await database.execute(
            "CREATE TABLE invalid_text (value BLOB NOT NULL)"
        )
        _ = try await database.execute(
            "INSERT INTO invalid_text (value) VALUES (?)",
            bindings: [.blob(Data([0xC3, 0x28]))]
        )

        do {
            _ = try await database.query(
                "SELECT CAST(value AS TEXT) FROM invalid_text"
            )
            XCTFail("Expected strict UTF-8 decoding to reject invalid bytes.")
        } catch let error as SQLiteError {
            XCTAssertEqual(error.operation, .decode)
            XCTAssertEqual(error.primaryCode, 20)
            XCTAssertEqual(error.primaryCode, error.extendedCode & 0xFF)
            XCTAssertFalse(error.description.contains("0xC3"))
        }
    }

    func testOversizedBlobBindingUsesSQLiteLimitWithoutIntegerNarrowing() async throws {
        let database = try SQLiteDatabase(
            url: try databaseURL(),
            configuration: SQLiteConfiguration(maximumValueBytes: 1_024)
        )
        _ = try await database.execute(
            "CREATE TABLE blob_values (value BLOB NOT NULL)"
        )

        do {
            _ = try await database.execute(
                "INSERT INTO blob_values (value) VALUES (?)",
                bindings: [.blob(Data(repeating: 0xA5, count: 2_048))]
            )
            XCTFail("Expected the configured SQLite value limit to reject the blob.")
        } catch let error as SQLiteError {
            XCTAssertEqual(error.operation, .bind)
            XCTAssertEqual(error.primaryCode, 18)
            XCTAssertEqual(error.primaryCode, error.extendedCode & 0xFF)
        }
    }

    func testErrorsUseImmediateNonzeroResultCodesInsteadOfStaleDiagnostics() async throws {
        let database = try SQLiteDatabase(url: try databaseURL())
        _ = try await database.execute(
            "CREATE TABLE error_codes (value TEXT UNIQUE NOT NULL)"
        )
        _ = try await database.execute(
            "INSERT INTO error_codes (value) VALUES ('duplicate')"
        )
        do {
            _ = try await database.execute(
                "INSERT INTO error_codes (value) VALUES ('duplicate')"
            )
            XCTFail("Expected a constraint error to seed connection diagnostics.")
        } catch let error as SQLiteError {
            XCTAssertEqual(error.primaryCode, 19)
            XCTAssertNotEqual(error.extendedCode, 0)
        }

        do {
            _ = try await database.execute("SELECT 1")
            XCTFail("Expected execute to reject a row-producing statement.")
        } catch let error as SQLiteError {
            XCTAssertEqual(error.operation, .step)
            XCTAssertEqual(error.primaryCode, 100)
            XCTAssertNotEqual(error.extendedCode, 0)
        }

        for emptyStatement in ["", "-- comment only"] {
            do {
                _ = try await database.execute(emptyStatement)
                XCTFail("Expected execute to reject a nil prepared statement.")
            } catch let error as SQLiteError {
                XCTAssertEqual(error.operation, .prepare)
                XCTAssertEqual(error.primaryCode, 21)
                XCTAssertNotEqual(error.extendedCode, 0)
            }

            do {
                _ = try await database.query(emptyStatement)
                XCTFail("Expected query to reject a nil prepared statement.")
            } catch let error as SQLiteError {
                XCTAssertEqual(error.operation, .step)
                XCTAssertEqual(error.primaryCode, 21)
                XCTAssertNotEqual(error.extendedCode, 0)
            }
        }
    }

    func testSQLiteErrorCannotRepresentConnectionSuccessAsFailure() {
        let error = SQLiteError(operation: .step, extendedCode: 0)
        XCTAssertEqual(error.primaryCode, 21)
        XCTAssertEqual(error.extendedCode, 21)
    }

    func testScopedTransactionCommitsAndThrownBodyRollsBack() async throws {
        let database = try SQLiteDatabase(url: try databaseURL())
        _ = try await database.execute(
            "CREATE TABLE items (id INTEGER PRIMARY KEY, value TEXT NOT NULL)"
        )

        do {
            try await database.transaction { database -> Void in
                _ = try database.execute(
                    "INSERT INTO items (id, value) VALUES (?, ?)",
                    bindings: [.integer(1), .text("rolled-back")]
                )
                throw TransactionTestError.expectedBodyFailure
            }
            XCTFail("Expected the transaction body to fail.")
        } catch TransactionTestError.expectedBodyFailure {
            // The original body error is preserved after successful rollback.
        }
        let afterRollback = try await database.query("SELECT id FROM items")
        XCTAssertTrue(afterRollback.isEmpty)

        try await database.transaction(.exclusive) { database in
            _ = try database.execute(
                "INSERT INTO items (id, value) VALUES (?, ?)",
                bindings: [.integer(2), .text("committed")]
            )
        }
        let afterCommit = try await database.query("SELECT id FROM items")
        XCTAssertEqual(afterCommit.map { $0[0] }, [.integer(2)])
    }

    func testCommitFailureAutomaticallyRollsBackDeferredConstraint() async throws {
        let database = try SQLiteDatabase(url: try databaseURL())
        _ = try await database.execute("CREATE TABLE parent (id INTEGER PRIMARY KEY)")
        _ = try await database.execute(
            """
            CREATE TABLE child (
                id INTEGER PRIMARY KEY,
                parent_id INTEGER NOT NULL,
                FOREIGN KEY(parent_id) REFERENCES parent(id)
                    DEFERRABLE INITIALLY DEFERRED
            )
            """
        )

        do {
            try await database.transaction { database in
                _ = try database.execute(
                    "INSERT INTO child (id, parent_id) VALUES (?, ?)",
                    bindings: [.integer(1), .integer(999)]
                )
            }
            XCTFail("Expected deferred foreign-key validation at commit.")
        } catch let error as SQLiteError {
            XCTAssertEqual(error.operation, .transaction)
            XCTAssertEqual(error.primaryCode, error.extendedCode & 0xFF)
        }

        let rows = try await database.query("SELECT id FROM child")
        XCTAssertTrue(rows.isEmpty)
    }

    func testForeignKeysRejectInvalidWritesAndCheckReportsStoredViolations() async throws {
        let database = try SQLiteDatabase(url: try databaseURL())
        _ = try await database.execute(
            "CREATE TABLE parent (id INTEGER PRIMARY KEY)"
        )
        _ = try await database.execute(
            """
            CREATE TABLE child (
                id INTEGER PRIMARY KEY,
                parent_id INTEGER NOT NULL REFERENCES parent(id)
            )
            """
        )

        do {
            _ = try await database.execute(
                "INSERT INTO child (id, parent_id) VALUES (?, ?)",
                bindings: [.integer(1), .integer(999)]
            )
            XCTFail("Expected foreign-key enforcement to reject the write.")
        } catch let error as SQLiteError {
            XCTAssertEqual(error.operation, .step)
            XCTAssertEqual(error.primaryCode, 19)
        }

        _ = try await database.execute("PRAGMA foreign_keys=OFF")
        _ = try await database.execute(
            "INSERT INTO child (id, parent_id) VALUES (?, ?)",
            bindings: [.integer(2), .integer(999)]
        )
        _ = try await database.execute("PRAGMA foreign_keys=ON")

        let violations = try await database.foreignKeyCheck()
        XCTAssertEqual(violations.count, 1)
        XCTAssertEqual(violations[0].table, "child")
        XCTAssertEqual(violations[0].rowID, 2)
        XCTAssertEqual(violations[0].parentTable, "parent")
    }

    func testScopedTransactionCannotInterleaveOtherCallsOnSameActor() async throws {
        let database = try SQLiteDatabase(url: try databaseURL())
        _ = try await database.execute(
            """
            CREATE TABLE ordering (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                value TEXT NOT NULL
            )
            """
        )
        let entered = AsyncStream<Void>.makeStream()
        let release = DispatchSemaphore(value: 0)

        let first = Task {
            try await database.transaction { database in
                _ = try database.execute(
                    "INSERT INTO ordering (value) VALUES ('first-start')"
                )
                entered.continuation.yield(())
                release.wait()
                _ = try database.execute(
                    "INSERT INTO ordering (value) VALUES ('first-end')"
                )
            }
        }
        var enteredIterator = entered.stream.makeAsyncIterator()
        _ = await enteredIterator.next()
        let secondAttempted = AsyncStream<Void>.makeStream()
        let second = Task {
            secondAttempted.continuation.yield(())
            try await database.transaction { database in
                _ = try database.execute(
                    "INSERT INTO ordering (value) VALUES ('second')"
                )
            }
        }

        var secondIterator = secondAttempted.stream.makeAsyncIterator()
        _ = await secondIterator.next()
        release.signal()
        try await first.value
        try await second.value
        let rows = try await database.query(
            "SELECT value FROM ordering ORDER BY id"
        )
        XCTAssertEqual(
            rows.map { $0[0] },
            [.text("first-start"), .text("first-end"), .text("second")]
        )
    }

    func testScopedBodyRejectsTransactionControlWithoutDurableCommit() async throws {
        let database = try SQLiteDatabase(url: try databaseURL())
        _ = try await database.execute(
            "CREATE TABLE guarded_values (value TEXT NOT NULL)"
        )

        for transactionSQL in [
            "COMMIT",
            "END",
            "ROLLBACK",
            "BEGIN",
            "SAVEPOINT nested",
            "RELEASE nested"
        ] {
            do {
                try await database.transaction { database in
                    _ = try database.execute(
                        "INSERT INTO guarded_values (value) VALUES ('uncommitted')"
                    )
                    _ = try database.execute(transactionSQL)
                }
                XCTFail("Expected transaction-control SQL to be denied.")
            } catch let error as SQLiteError {
                XCTAssertEqual(error.primaryCode, 23)
                XCTAssertEqual(error.primaryCode, error.extendedCode & 0xFF)
            }
            let rows = try await database.query(
                "SELECT COUNT(*) FROM guarded_values"
            )
            XCTAssertEqual(rows.first?[0], .integer(0))
        }
    }

    func testPublicExecuteAndQueryRejectRawTransactionControl() async throws {
        let database = try SQLiteDatabase(url: try databaseURL())
        _ = try await database.execute(
            "CREATE TABLE committed_value (value INTEGER NOT NULL)"
        )
        try await database.transaction { database in
            _ = try database.execute(
                "INSERT INTO committed_value (value) VALUES (1)"
            )
        }
        let transactionStatements = [
            "COMMIT",
            "END",
            "ROLLBACK",
            "BEGIN",
            "SAVEPOINT nested",
            "RELEASE nested"
        ]

        for transactionSQL in transactionStatements {
            do {
                _ = try await database.execute(transactionSQL)
                XCTFail("Expected execute to deny transaction-control SQL.")
            } catch let error as SQLiteError {
                XCTAssertEqual(error.primaryCode, 23)
                XCTAssertEqual(error.primaryCode, error.extendedCode & 0xFF)
            }

            do {
                _ = try await database.query(transactionSQL)
                XCTFail("Expected query to deny transaction-control SQL.")
            } catch let error as SQLiteError {
                XCTAssertEqual(error.primaryCode, 23)
                XCTAssertEqual(error.primaryCode, error.extendedCode & 0xFF)
            }
        }

        let rows = try await database.query("SELECT 1")
        XCTAssertEqual(rows.first?[0], .integer(1))
    }

    func testUnresolvedRollbackPoisonSeamRejectsEveryLaterOperation() async throws {
        let database = try SQLiteDatabase(url: try databaseURL())
        let backupURL = try databaseURL()
        await database.poisonConnectionAfterUnresolvedRollback(
            SQLiteError(operation: .transaction, extendedCode: 10)
        )

        await assertConnectionPoisoned {
            _ = try await database.execute("CREATE TABLE unavailable (id INTEGER)")
        }
        await assertConnectionPoisoned {
            _ = try await database.query("SELECT 1")
        }
        await assertConnectionPoisoned {
            try await database.transaction { _ in () }
        }
        await assertConnectionPoisoned {
            _ = try await database.checkpoint()
        }
        await assertConnectionPoisoned {
            _ = try await database.backup(to: backupURL)
        }
        await assertConnectionPoisoned {
            _ = try await database.integrityCheck()
        }
        await assertConnectionPoisoned {
            _ = try await database.foreignKeyCheck()
        }
    }

    func testBusyAndConstraintErrorsExposeCodesWithoutSQLOrBoundValues() async throws {
        let url = try databaseURL()
        let first = try SQLiteDatabase(url: url)
        let second = try SQLiteDatabase(
            url: url,
            configuration: SQLiteConfiguration(busyTimeoutMilliseconds: 1)
        )
        _ = try await first.execute(
            "CREATE TABLE secrets (id INTEGER PRIMARY KEY, value TEXT UNIQUE)"
        )
        let writerEntered = AsyncStream<Void>.makeStream()
        let releaseWriter = DispatchSemaphore(value: 0)
        let holdingWriter = Task {
            try await first.transaction { database in
                _ = try database.execute(
                    "INSERT INTO secrets (id, value) VALUES (?, ?)",
                    bindings: [.integer(1), .text("held-value")]
                )
                writerEntered.continuation.yield(())
                releaseWriter.wait()
            }
        }
        var writerIterator = writerEntered.stream.makeAsyncIterator()
        _ = await writerIterator.next()

        let observedBusyError: Error?
        do {
            _ = try await second.execute(
                "INSERT INTO secrets /* private-sql-marker */ (id, value) VALUES (?, ?)",
                bindings: [.integer(2), .text("private-bound-marker")]
            )
            XCTFail("Expected the second writer to report a busy database.")
            observedBusyError = nil
        } catch {
            observedBusyError = error
        }
        releaseWriter.signal()
        try await holdingWriter.value
        let busyError = try XCTUnwrap(observedBusyError as? SQLiteError)
        XCTAssertEqual(busyError.primaryCode, 5)
        XCTAssertEqual(busyError.primaryCode, busyError.extendedCode & 0xFF)
        XCTAssertFalse(busyError.description.contains("private-sql-marker"))
        XCTAssertFalse(busyError.description.contains("private-bound-marker"))

        _ = try await first.execute(
            "INSERT INTO secrets (id, value) VALUES (?, ?)",
            bindings: [.integer(3), .text("duplicate-private-marker")]
        )
        do {
            _ = try await first.execute(
                "INSERT INTO secrets (id, value) VALUES (?, ?)",
                bindings: [.integer(4), .text("duplicate-private-marker")]
            )
            XCTFail("Expected a uniqueness violation.")
        } catch let error as SQLiteError {
            XCTAssertEqual(error.primaryCode, 19)
            XCTAssertFalse(error.description.contains("duplicate-private-marker"))
        }
    }

    func testWALCheckpointOnlineBackupAndIntegrityCheck() async throws {
        let sourceURL = try databaseURL()
        let backupURL = sourceURL.deletingLastPathComponent()
            .appendingPathComponent("backup.sqlite")
        let database = try SQLiteDatabase(url: sourceURL)
        _ = try await database.execute(
            "CREATE TABLE records (id INTEGER PRIMARY KEY, value TEXT NOT NULL)"
        )
        _ = try await database.execute(
            "INSERT INTO records (id, value) VALUES (?, ?)",
            bindings: [.integer(1), .text("backed-up")]
        )

        let checkpoint = try await database.checkpoint(.full)
        XCTAssertGreaterThanOrEqual(checkpoint.logFrameCount, 0)
        XCTAssertGreaterThanOrEqual(checkpoint.checkpointedFrameCount, 0)
        let backup = try await database.backup(to: backupURL, pagesPerStep: 1)
        XCTAssertGreaterThan(backup.pageCount, 0)
        XCTAssertEqual(backup.remainingPageCount, 0)

        let backupDatabase = try SQLiteDatabase(url: backupURL)
        let backedUpRows = try await backupDatabase.query(
            "SELECT value FROM records WHERE id = ?",
            bindings: [.integer(1)]
        )
        XCTAssertEqual(backedUpRows.first?[0], .text("backed-up"))

        let integrity = try await database.integrityCheck()
        let backupIntegrity = try await backupDatabase.integrityCheck()
        XCTAssertTrue(integrity.isOK)
        XCTAssertTrue(backupIntegrity.isOK)
    }

    func testActorSerializesConcurrentPreparedOperations() async throws {
        let database = try SQLiteDatabase(url: try databaseURL())
        _ = try await database.execute(
            "CREATE TABLE concurrent_values (id INTEGER PRIMARY KEY)"
        )

        try await withThrowingTaskGroup(of: Void.self) { group in
            for value in 0..<64 {
                group.addTask {
                    _ = try await database.execute(
                        "INSERT INTO concurrent_values (id) VALUES (?)",
                        bindings: [.integer(Int64(value))]
                    )
                }
            }
            try await group.waitForAll()
        }

        let rows = try await database.query(
            "SELECT COUNT(*) AS count FROM concurrent_values"
        )
        XCTAssertEqual(rows.first?.value(named: "count"), .integer(64))
    }

    private func databaseURL() throws -> URL {
        let directoryURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(
            at: directoryURL,
            withIntermediateDirectories: false
        )
        addTeardownBlock {
            try? FileManager.default.removeItem(at: directoryURL)
        }
        return directoryURL.appendingPathComponent("database.sqlite")
    }

    private func assertConnectionPoisoned(
        _ operation: () async throws -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) async {
        do {
            try await operation()
            XCTFail("Expected the poisoned connection to fail closed.", file: file, line: line)
        } catch let error as SQLiteError {
            XCTAssertEqual(error.operation, .connection, file: file, line: line)
            XCTAssertEqual(error.primaryCode, 10, file: file, line: line)
        } catch {
            XCTFail("Expected SQLiteError from poisoned connection.", file: file, line: line)
        }
    }
}

private enum TransactionTestError: Error, Sendable {
    case expectedBodyFailure
}
