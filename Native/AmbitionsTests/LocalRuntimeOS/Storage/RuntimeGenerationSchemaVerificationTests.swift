import AmbitionsRuntimeSQLite
@testable import Ambitions
import Foundation
import XCTest

final class RuntimeGenerationSchemaVerificationTests: XCTestCase {
    func testV8TargetVerificationRequiresIntegrityForeignKeysWALAndExactSchema() async throws {
        try await withEmptyV8Database { fixture in
            let verified = try await RuntimeGenerationDatabaseAuthority.verifyExactV8ReadOnly(
                at: fixture.databaseURL
            )
            let integrity = try await verified.integrityCheck()
            let foreignKeyViolations = try await verified.foreignKeyCheck()
            let journal = try await verified.query("PRAGMA journal_mode")
            let synchronous = try await verified.query("PRAGMA synchronous")

            XCTAssertTrue(integrity.isOK)
            XCTAssertTrue(foreignKeyViolations.isEmpty)
            XCTAssertEqual(journal.first?.value(at: 0), .text("wal"))
            XCTAssertEqual(synchronous.first?.value(at: 0), .integer(2))
            try await verified.close()
            return ()
        }
    }

    func testV8SchemaRejectsNegativeAggregateRevision() async throws {
        try await withEmptyV8Database { fixture in
            do {
                try await fixture.database.execute(
                    """
                    INSERT INTO runtime_aggregates(
                        aggregate_kind, aggregate_id, revision,
                        payload_version, payload, payload_checksum
                    ) VALUES (?, ?, ?, ?, ?, ?)
                    """,
                    bindings: [
                        .text("goal"), .text("goal-negative"), .integer(-1),
                        .integer(1), .blob(Data([1])),
                        .text(String(repeating: "a", count: 64)),
                    ]
                )
                XCTFail("Expected nonnegative aggregate revision constraint")
            } catch let error as SQLiteError {
                XCTAssertEqual(error.primaryCode, 19)
            }
            return ()
        }
    }

    func testV8SchemaRejectsOrphanEventAndNoncanonicalDigest() async throws {
        try await withEmptyV8Database { fixture in
            let foreignKeys = try await fixture.database.query(
                "PRAGMA foreign_key_list(runtime_events)"
            )
            XCTAssertTrue(foreignKeys.contains { row in
                row.value(named: "from") == .text("command_id") &&
                    row.value(named: "table") == .text("runtime_command_idempotency")
            })

            do {
                try await fixture.database.execute(
                    """
                    INSERT INTO runtime_aggregates(
                        aggregate_kind, aggregate_id, revision,
                        payload_version, payload, payload_checksum
                    ) VALUES (?, ?, ?, ?, ?, ?)
                    """,
                    bindings: [
                        .text("goal"), .text("uppercase-sha"), .integer(0),
                        .integer(1), .blob(Data()),
                        .text(String(repeating: "A", count: 64)),
                    ]
                )
                XCTFail("Expected canonical lowercase digest constraint")
            } catch let error as SQLiteError {
                XCTAssertEqual(error.primaryCode, 19)
            }
            return ()
        }
    }

    func testV8IdempotencySchemaContainsClaimAndFinalizationAuthority() async throws {
        try await withEmptyV8Database { fixture in
            let rows = try await fixture.database.query(
                "PRAGMA table_info(runtime_command_idempotency)"
            )
            let names = rows.compactMap { row -> String? in
                guard case let .text(name)? = row.value(named: "name") else { return nil }
                return name
            }
            XCTAssertEqual(names, [
                "scope", "idempotency_key", "command_id", "command_fingerprint",
                "claim_version", "claim_payload", "claimed_at_ms",
                "final_result_version", "final_result_payload",
                "final_result_checksum", "finalized_at_ms",
            ])
            return ()
        }
    }

    func testOlderEffectiveUserVersionCannotVerifyAsV8() async throws {
        try await withEmptyV8Database { fixture in
            try await fixture.database.execute("PRAGMA user_version = 0")
            do {
                let verified = try await RuntimeGenerationDatabaseAuthority.verifyExactV8ReadOnly(
                    at: fixture.databaseURL
                )
                try await verified.close()
                XCTFail("Expected older schema verification rejection")
            } catch {
                XCTAssertTrue(
                    error is RuntimeGenerationControlError ||
                        error is LocalRuntimeStorageError
                )
            }
            return ()
        }
    }

    func testFutureEffectiveUserVersionCannotVerifyAsV8() async throws {
        try await withEmptyV8Database { fixture in
            try await fixture.database.execute(
                "PRAGMA user_version = \(runtimeCanonicalAttachmentSchemaVersion + 1)"
            )
            do {
                let verified = try await RuntimeGenerationDatabaseAuthority.verifyExactV8ReadOnly(
                    at: fixture.databaseURL
                )
                try await verified.close()
                XCTFail("Expected future schema verification rejection")
            } catch {
                XCTAssertTrue(
                    error is RuntimeGenerationControlError ||
                        error is LocalRuntimeStorageError
                )
            }
            return ()
        }
    }

    func testSameNamedIndexWithWrongDefinitionBlocksVerification() async throws {
        try await withEmptyV8Database { fixture in
            try await fixture.database.transaction(.immediate) { database in
                try database.execute("DROP INDEX runtime_events_command_sequence_idx")
                try database.execute(
                    """
                    CREATE INDEX runtime_events_command_sequence_idx
                    ON runtime_events(aggregate_id, sequence)
                    """
                )
            }
            do {
                let verified = try await RuntimeGenerationDatabaseAuthority.verifyExactV8ReadOnly(
                    at: fixture.databaseURL
                )
                try await verified.close()
                XCTFail("Expected compiled schema definition mismatch")
            } catch {
                XCTAssertTrue(
                    error is RuntimeGenerationControlError ||
                        error is LocalRuntimeStorageError
                )
            }
            return ()
        }
    }

    func testFullMaintenanceAuditValidatesIntegrityForeignKeysAndIdentity() async throws {
        try await withEmptyV8Database { fixture in
            let integrity = try await fixture.database.integrityCheck()
            let violations = try await fixture.database.foreignKeyCheck()
            let artifact = try RuntimeGenerationDatabaseAuthority.artifact(
                at: fixture.databaseURL,
                relativePath: "Stores/\(fixture.generationID.pathComponent)/Runtime.sqlite"
            )

            XCTAssertTrue(integrity.isOK)
            XCTAssertTrue(violations.isEmpty)
            XCTAssertGreaterThan(artifact.byteCount, 0)
            XCTAssertEqual(artifact.sha256.count, 64)
            XCTAssertNotNil(artifact.fileIdentity)
            return ()
        }
    }
}
