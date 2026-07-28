import AmbitionsRuntimeSQLite
@testable import Ambitions
import Foundation
import XCTest

final class RuntimeGenerationBoundedReadTests: XCTestCase {
    func testV8KeysetPagesRemainStableAcrossGenerationMigration() async throws {
        try await withRuntimeGenerationHarness(seed: 15_000) { harness in
            _ = try await harness.installFirstGeneration()
            let source = try await harness.openActiveStore()
            try await Self.seedCanonicalRows(in: source, tombstoneCount: 0)

            let first = try await source.withReadTransaction { database in
                try CanonicalRuntimeStore.readEvents(
                    from: database,
                    after: nil,
                    limit: 2
                )
            }
            let second = try await source.withReadTransaction { database in
                try CanonicalRuntimeStore.readEvents(
                    from: database,
                    after: try XCTUnwrap(first.nextCursor),
                    limit: 2
                )
            }
            XCTAssertEqual(first.items.map(\.eventID), ["event-1", "event-2"])
            XCTAssertEqual(second.items.map(\.eventID), ["event-3"])
            XCTAssertEqual(
                Set((first.items + second.items).map(\.eventID)).count,
                3
            )
            XCTAssertEqual(CanonicalRuntimeStore.maximumPageLimit, 200)

            let vault = try XCTAttachmentFixtures.vault(
                root: harness.locations.attachmentVaultURL,
                token: "bounded-read-vault"
            )
            let target = try await harness.lifecycle.migrateActiveGeneration(
                source: source,
                vault: vault,
                keyCustody: FixedRuntimeAttachmentKeyCustody()
            )
            let migrated = try await harness.openActiveStore()
            let migratedPage = try await migrated.withReadTransaction { database in
                try CanonicalRuntimeStore.readEvents(
                    from: database,
                    after: nil,
                    limit: 3
                )
            }
            XCTAssertEqual(migrated.resolved.selector.generationID, target.generationID)
            XCTAssertEqual(migratedPage.items.map(\.eventID), [
                "event-1", "event-2", "event-3",
            ])
            try await source.close()
            try await migrated.close()
            return ()
        }
    }

    func testV8TombstoneKeysetPaginationDoesNotDuplicateOrSkip() async throws {
        try await withRuntimeGenerationHarness(seed: 15_100) { harness in
            _ = try await harness.installFirstGeneration()
            let store = try await harness.openActiveStore()
            try await Self.seedCanonicalRows(in: store, tombstoneCount: 3)

            let first = try await store.withReadTransaction { database in
                try CanonicalRuntimeStore.readTombstones(
                    from: database,
                    after: nil,
                    limit: 2
                )
            }
            let second = try await store.withReadTransaction { database in
                try CanonicalRuntimeStore.readTombstones(
                    from: database,
                    after: try XCTUnwrap(first.nextCursor),
                    limit: 2
                )
            }
            XCTAssertEqual(first.items.map(\.objectID.id), ["object-1", "object-2"])
            XCTAssertEqual(second.items.map(\.objectID.id), ["object-3"])
            XCTAssertEqual(
                Set((first.items + second.items).map(\.objectID.id)).count,
                3
            )
            try await store.close()
            return ()
        }
    }

    func testCumulativePageByteCeilingIsTypedAndLeavesV8ConnectionUsable() async throws {
        try await withRuntimeGenerationHarness(seed: 15_200) { harness in
            _ = try await harness.installFirstGeneration()
            let store = try await harness.openActiveStore()
            try await Self.seedCanonicalRows(
                in: store,
                tombstoneCount: 5,
                tombstonePayloadByteCount: 1_048_000
            )

            do {
                _ = try await store.withReadTransaction { database in
                    try CanonicalRuntimeStore.readTombstones(
                        from: database,
                        after: nil,
                        limit: 5
                    )
                }
                XCTFail("Expected cumulative decoded-page budget rejection")
            } catch {
                XCTAssertEqual(
                    error as? LocalRuntimeStorageError,
                    .canonicalReadPageTooLarge(
                        maximumBytes: CanonicalRuntimeStore.maximumReadPageBytes
                    )
                )
            }

            let metadataCount = try await store.withReadTransaction { database in
                try database.query(
                    "SELECT COUNT(*) AS count FROM runtime_store_metadata"
                ).first?.value(named: "count")
            }
            XCTAssertEqual(metadataCount, .integer(1))
            try await store.close()
            return ()
        }
    }
}

private extension RuntimeGenerationBoundedReadTests {
    static func seedCanonicalRows(
        in store: CanonicalRuntimeStoreV8,
        tombstoneCount: Int,
        tombstonePayloadByteCount: Int = 1
    ) async throws {
        _ = try await store.withWriteTransaction { database in
            try database.execute(
                """
                INSERT INTO runtime_aggregates(
                    aggregate_kind, aggregate_id, revision,
                    payload_version, payload, payload_checksum
                ) VALUES (?, ?, ?, ?, ?, ?)
                """,
                bindings: [
                    .text("goal"), .text("goal-1"), .integer(3),
                    .integer(1), .blob(Data([0x01])),
                    .text(String(repeating: "a", count: 64)),
                ]
            )
            for index in 1...3 {
                try database.execute(
                    """
                    INSERT INTO runtime_command_idempotency(
                        scope, idempotency_key, command_id, command_fingerprint,
                        claim_version, claim_payload, claimed_at_ms
                    ) VALUES (?, ?, ?, ?, ?, ?, ?)
                    """,
                    bindings: [
                        .text("test"), .text("key-\(index)"),
                        .text("command-\(index)"),
                        .text(String(repeating: String(index), count: 64)),
                        .integer(1), .blob(Data([UInt8(index)])),
                        .integer(Int64(index)),
                    ]
                )
                try database.execute(
                    """
                    INSERT INTO runtime_events(
                        event_id, command_id, aggregate_kind, aggregate_id,
                        correlation_id, causation_event_id, event_version,
                        payload, payload_checksum, previous_event_hash,
                        event_hash, recorded_at_ms
                    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                    """,
                    bindings: [
                        .text("event-\(index)"), .text("command-\(index)"),
                        .text("goal"), .text("goal-1"), .text("correlation-1"),
                        index == 1 ? .null : .text("event-\(index - 1)"),
                        .integer(1), .blob(Data([UInt8(index)])),
                        .text(String(repeating: "b", count: 64)),
                        index == 1
                            ? .null
                            : .text(String(repeating: String(index - 1), count: 64)),
                        .text(String(repeating: String(index), count: 64)),
                        .integer(Int64(index)),
                    ]
                )
            }
            if tombstoneCount > 0 {
                for index in 1...tombstoneCount {
                    try database.execute(
                        """
                        INSERT INTO runtime_tombstones(
                            object_kind, object_id, revision,
                            causal_event_sequence, tombstone_version,
                            payload, checksum, created_at_ms
                        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)
                        """,
                        bindings: [
                            .text("goal"), .text("object-\(index)"),
                            .integer(Int64(index)), .integer(Int64(min(index, 3))),
                            .integer(1),
                            .blob(Data(
                                repeating: UInt8(index),
                                count: tombstonePayloadByteCount
                            )),
                            .text(String(repeating: "c", count: 64)),
                            .integer(Int64(index)),
                        ]
                    )
                }
            }
        }
    }
}
