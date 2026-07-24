import AmbitionsRuntimeSQLite
import Foundation
@testable import Ambitions
import XCTest

final class CanonicalRuntimeStoreEventTests: XCTestCase {
    func testT08SchemaIsAdditiveAndDoesNotMutateT06Identity() {
        XCTAssertEqual(CanonicalRuntimeSemanticEventSchemaPlan.sourceSchemaVersion, 1)
        XCTAssertEqual(CanonicalRuntimeSemanticEventSchemaPlan.targetSchemaVersion, 2)
        XCTAssertTrue(CanonicalRuntimeStore.expectedRuntimeTables.isDisjoint(with: CanonicalRuntimeSemanticEventSchemaPlan.tables))
        XCTAssertTrue(CanonicalRuntimeStore.expectedRuntimeIndexes.isDisjoint(with: CanonicalRuntimeSemanticEventSchemaPlan.indexes))
        XCTAssertFalse(CanonicalRuntimeStore.schemaStatements.joined().contains("runtime_semantic_events"))
    }

    func testIsolatedAppendRequiresCanonicalFamilyAndRevisionThenBuildsContinuousHashes() async throws {
        let database = try await makeDatabase()
        try await seedAuthority(database, revision: 1, commandIDs: ["command-1", "command-2"])
        let first = try await append(database, eventID: "event-1", commandID: "command-1", prior: 0, result: 1)
        try await setAggregateRevision(2, database: database)
        let second = try await append(
            database, eventID: "event-2", commandID: "command-2", prior: 1, result: 2,
            causationEventID: "event-1"
        )

        XCTAssertEqual(first.sequence, 1)
        XCTAssertEqual(second.sequence, 2)
        XCTAssertNil(first.lineage.previousEventHash)
        XCTAssertEqual(second.lineage.previousEventHash, first.lineage.eventHash)
        XCTAssertEqual(try first.recomputedEventHash(), first.lineage.eventHash)
        XCTAssertEqual(try second.recomputedEventHash(), second.lineage.eventHash)

        let mismatched = try appendRequest(
            eventID: "event-family-mismatch", commandID: "command-2", prior: 1, result: 2,
            aggregateKind: .capture
        )
        await XCTAssertThrowsErrorAsync(
            try await database.transaction(.immediate) { isolated in
                try CanonicalRuntimeSemanticEventStore.appendInTransaction(mismatched, to: isolated)
            }
        ) { XCTAssertEqual($0 as? CanonicalRuntimeSemanticEventStoreError, .aggregateMismatch) }
    }

    func testAppendRejectsPayloadRevisionDifferentFromCanonicalAggregateRevision() async throws {
        let database = try await makeDatabase()
        try await seedAuthority(database, revision: 2, commandIDs: ["command-1"])
        let request = try appendRequest(
            eventID: "event-1", commandID: "command-1", prior: 0, result: 1,
            canonicalRevision: 2
        )

        await XCTAssertThrowsErrorAsync(
            try await database.transaction(.immediate) { isolated in
                try CanonicalRuntimeSemanticEventStore.appendInTransaction(request, to: isolated)
            }
        ) { XCTAssertEqual($0 as? CanonicalRuntimeSemanticEventStoreError, .aggregateRevisionMismatch) }
    }

    func testAbsentCASCreationRevisionZeroFeedsEventAppendInSameTransaction() async throws {
        let database = try await makeDatabase()
        try await seedCommands(database, commandIDs: ["command-create"])
        let event = try goalCreationEvent()
        let bytes = try RuntimeSemanticEventCodec().encode(event)
        let request = try CanonicalRuntimeSemanticEventAppendRequest(
            eventID: RuntimeEventID(validating: "event-create"),
            commandID: RuntimeCommandID(validating: "command-create"),
            aggregate: RuntimeSemanticAggregate(kind: .goal, id: RuntimeAggregateID(validating: "goal-created")),
            canonicalAggregateRevision: 0,
            correlationID: RuntimeCorrelationID(validating: "correlation-create"),
            causationEventID: nil,
            occurredAt: Date(timeIntervalSince1970: 1),
            canonicalBytes: bytes
        )

        let outcome = try await database.transaction(.immediate) { isolated in
            try isolated.execute(
                """
                INSERT INTO runtime_aggregates(
                    aggregate_kind, aggregate_id, revision, payload_version, payload, payload_checksum
                ) VALUES (?, ?, ?, ?, ?, ?)
                """,
                bindings: [.text("goal"), .text("goal-created"), .integer(0), .integer(1), .blob(Data()), .text(String(repeating: "c", count: 64))]
            )
            return try CanonicalRuntimeSemanticEventStore.appendInTransaction(request, to: isolated)
        }

        guard case let .appended(record) = outcome else { return XCTFail("Expected creation event") }
        XCTAssertNil(record.event.mutation.priorRevision)
        XCTAssertEqual(record.event.mutation.resultingRevision, 0)
        XCTAssertEqual(record.lineage.canonicalAggregateRevision, 0)
    }

    func testDeletedTailCannotReuseSequenceAndAppendRevalidatesWholeChain() async throws {
        let database = try await makeDatabase()
        try await seedAuthority(database, revision: 1, commandIDs: ["command-1", "command-2", "command-3"])
        _ = try await append(database, eventID: "event-1", commandID: "command-1", prior: 0, result: 1)
        try await setAggregateRevision(2, database: database)
        _ = try await append(database, eventID: "event-2", commandID: "command-2", prior: 1, result: 2)
        try await database.execute("DROP TRIGGER runtime_semantic_events_immutable_delete")
        try await database.execute("DELETE FROM runtime_semantic_events WHERE event_id = ?", bindings: [.text("event-2")])
        try await setAggregateRevision(3, database: database)

        await XCTAssertThrowsErrorAsync(
            try await append(database, eventID: "event-3", commandID: "command-3", prior: 2, result: 3)
        ) { XCTAssertEqual($0 as? CanonicalRuntimeSemanticEventStoreError, .invalidSequence) }
    }

    func testCursorReadVerifiesGenesisPrefixAndBlocksRowsAfterCorruption() async throws {
        let database = try await makeDatabase()
        try await seedAuthority(database, revision: 1, commandIDs: ["command-1", "command-2"])
        _ = try await append(database, eventID: "event-1", commandID: "command-1", prior: 0, result: 1)
        try await setAggregateRevision(2, database: database)
        _ = try await append(database, eventID: "event-2", commandID: "command-2", prior: 1, result: 2, causationEventID: "event-1")
        try await database.execute("DROP TRIGGER runtime_semantic_events_immutable_update")
        try await database.execute(
            "UPDATE runtime_semantic_events SET event_hash = ? WHERE event_id = ?",
            bindings: [.text(String(repeating: "f", count: 64)), .text("event-1")]
        )
        let cursor = try CanonicalRuntimeEventCursor(sequence: 1, eventID: "event-1")

        await XCTAssertThrowsErrorAsync(
            try await database.transaction(.immediate) { isolated in
                try CanonicalRuntimeSemanticEventStore.readInTransaction(from: isolated, after: cursor, limit: 10)
            }
        ) { XCTAssertEqual($0 as? CanonicalRuntimeSemanticEventStoreError, .hashChainBroken) }
    }

    func testCodecFailureReasonsStayTypedAndSameSourceDedupesIndependentOfRequestIdentity() async throws {
        let database = try await makeDatabase()
        try await seedAuthority(database, revision: 1, commandIDs: ["command-1"])
        let valid = try RuntimeSemanticEventCodec().encode(try goalEvent(prior: 0, result: 1))
        let unknown = valid.replacingUTF8("ambitions.goal.updated", with: "ambitions.goal.future")

        for eventID in ["event-rejected-1", "event-rejected-2"] {
            let request = try appendRequest(
                eventID: eventID, commandID: "command-1", prior: 0, result: 1,
                canonicalBytes: unknown
            )
            let outcome = try await database.transaction(.immediate) { isolated in
                try CanonicalRuntimeSemanticEventStore.appendInTransaction(request, to: isolated)
            }
            guard case let .quarantined(record) = outcome else { return XCTFail("Expected quarantine") }
            XCTAssertEqual(record.reason, .unknownType)
            XCTAssertEqual(record.inlineSourceBytes, unknown)
        }
        let rows = try await database.query("SELECT COUNT(*) AS count FROM runtime_semantic_event_quarantine")
        let events = try await database.query("SELECT COUNT(*) AS count FROM runtime_semantic_events")
        XCTAssertEqual(rows.first?.value(named: "count"), .integer(1))
        XCTAssertEqual(events.first?.value(named: "count"), .integer(0))
    }

    func testOversizeQuarantineDefersUntilVerifiedBlobAuthorityExists() async throws {
        let bytes = Data(repeating: 0x41, count: RuntimeSemanticEventLimits.canonical.maximumEnvelopeBytes + 1)
        XCTAssertThrowsError(
            try CanonicalRuntimeSemanticEventAppendRequest(
                eventID: RuntimeEventID(validating: "event-oversize"),
                commandID: RuntimeCommandID(validating: "command-1"),
                aggregate: RuntimeSemanticAggregate(kind: .goal, id: RuntimeAggregateID(validating: "goal-1")),
                canonicalAggregateRevision: 1,
                correlationID: RuntimeCorrelationID(validating: "correlation-1"),
                causationEventID: nil,
                occurredAt: Date(timeIntervalSince1970: 1),
                canonicalBytes: bytes
            )
        ) {
            XCTAssertEqual(
                $0 as? CanonicalRuntimeSemanticEventStoreError,
                .oversizeQuarantineDeferredUntilBlobAuthority
            )
        }
    }

    private func makeDatabase() async throws -> SQLiteDatabase {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent("semantic-event-correction-\(UUID().uuidString)", isDirectory: true)
        let database = try SQLiteDatabase(
            url: directory.appendingPathComponent("Runtime.sqlite"),
            configuration: CanonicalRuntimeStore.sqliteConfiguration(openMode: .createOrOpen)
        )
        try await CanonicalRuntimeStore.installSchema(
            in: database,
            generationID: RuntimeStoreGenerationID(validating: "generation-1"),
            createdAtMilliseconds: 1
        )
        try await database.transaction(.immediate) { isolated in
            try CanonicalRuntimeSemanticEventSchemaPlan.install(in: isolated)
        }
        return database
    }

    private func seedAuthority(_ database: SQLiteDatabase, revision: Int64, commandIDs: [String]) async throws {
        try await database.transaction(.immediate) { isolated in
            try isolated.execute(
                """
                INSERT INTO runtime_aggregates(
                    aggregate_kind, aggregate_id, revision, payload_version, payload, payload_checksum
                ) VALUES (?, ?, ?, ?, ?, ?)
                """,
                bindings: [.text("goal"), .text("goal-1"), .integer(revision), .integer(1), .blob(Data()), .text(String(repeating: "a", count: 64))]
            )
            try insertCommands(commandIDs, in: isolated)
        }
    }

    private func seedCommands(_ database: SQLiteDatabase, commandIDs: [String]) async throws {
        try await database.transaction(.immediate) { isolated in
            try insertCommands(commandIDs, in: isolated)
        }
    }

    private func insertCommands(_ commandIDs: [String], in database: isolated SQLiteDatabase) throws {
        for (index, commandID) in commandIDs.enumerated() {
            try database.execute(
                """
                INSERT INTO runtime_command_idempotency(
                    scope, idempotency_key, command_id, command_fingerprint,
                    claim_version, claim_payload, claimed_at_ms
                ) VALUES (?, ?, ?, ?, ?, ?, ?)
                """,
                bindings: [.text("test"), .text("key-\(index)"), .text(commandID), .text(String(repeating: "b", count: 64)), .integer(1), .blob(Data()), .integer(Int64(index + 1))]
            )
        }
    }

    private func setAggregateRevision(_ revision: Int64, database: SQLiteDatabase) async throws {
        try await database.execute(
            "UPDATE runtime_aggregates SET revision = ? WHERE aggregate_kind = ? AND aggregate_id = ?",
            bindings: [.integer(revision), .text("goal"), .text("goal-1")]
        )
    }

    private func append(
        _ database: SQLiteDatabase,
        eventID: String,
        commandID: String,
        prior: UInt64,
        result: UInt64,
        causationEventID: String? = nil
    ) async throws -> CanonicalRuntimeSemanticEventRecord {
        let request = try appendRequest(
            eventID: eventID, commandID: commandID, prior: prior, result: result,
            causationEventID: causationEventID
        )
        let outcome = try await database.transaction(.immediate) { isolated in
            try CanonicalRuntimeSemanticEventStore.appendInTransaction(request, to: isolated)
        }
        guard case let .appended(record) = outcome else { throw CanonicalRuntimeSemanticEventStoreError.malformedStoredRow }
        return record
    }

    private func appendRequest(
        eventID: String,
        commandID: String,
        prior: UInt64,
        result: UInt64,
        canonicalRevision: UInt64? = nil,
        aggregateKind: RuntimeSemanticAggregateKind = .goal,
        causationEventID: String? = nil,
        canonicalBytes: Data? = nil
    ) throws -> CanonicalRuntimeSemanticEventAppendRequest {
        let bytes: Data
        if let canonicalBytes {
            bytes = canonicalBytes
        } else {
            bytes = try RuntimeSemanticEventCodec().encode(goalEvent(prior: prior, result: result))
        }
        return try CanonicalRuntimeSemanticEventAppendRequest(
            eventID: RuntimeEventID(validating: eventID),
            commandID: RuntimeCommandID(validating: commandID),
            aggregate: RuntimeSemanticAggregate(kind: aggregateKind, id: RuntimeAggregateID(validating: "goal-1")),
            canonicalAggregateRevision: canonicalRevision ?? result,
            correlationID: RuntimeCorrelationID(validating: "correlation-1"),
            causationEventID: try causationEventID.map(RuntimeEventID.init(validating:)),
            occurredAt: Date(timeIntervalSince1970: Double(result)),
            canonicalBytes: bytes
        )
    }

    private func goalEvent(prior: UInt64, result: UInt64) throws -> RuntimeSemanticEvent {
        let mutation = try RuntimeSemanticMutation(
            semanticType: .goalUpdated,
            aggregateID: RuntimeAggregateID(validating: "goal-1"),
            priorRevision: prior,
            resultingRevision: result,
            changedObjectIDs: [RuntimeDomainObjectID(validating: "goal-1")]
        )
        let payload = try RuntimeGoalMutationPayload(
            mutation: mutation,
            facts: GoalCommand(
                action: .update,
                target: AmbitionsCommandTarget(goalID: "goal-1"),
                content: RuntimeCommandContent(AmbitionsCommandPayload(title: "Goal revision \(result)"))
            )
        )
        return .goal(.updated(payload))
    }

    private func goalCreationEvent() throws -> RuntimeSemanticEvent {
        let mutation = try RuntimeSemanticMutation(
            semanticType: .goalCreated,
            aggregateID: RuntimeAggregateID(validating: "goal-created"),
            priorRevision: nil,
            resultingRevision: 0,
            changedObjectIDs: [RuntimeDomainObjectID(validating: "goal-created")]
        )
        let payload = try RuntimeGoalMutationPayload(
            mutation: mutation,
            facts: GoalCommand(
                action: .create,
                target: AmbitionsCommandTarget(goalID: "goal-created"),
                content: RuntimeCommandContent(AmbitionsCommandPayload(title: "Created goal"))
            )
        )
        return .goal(.created(payload))
    }
}

private func XCTAssertThrowsErrorAsync<T>(
    _ expression: @autoclosure () async throws -> T,
    _ errorHandler: (Error) -> Void = { _ in },
    file: StaticString = #filePath,
    line: UInt = #line
) async {
    do { _ = try await expression(); XCTFail("Expected expression to throw", file: file, line: line) }
    catch { errorHandler(error) }
}

private extension Data {
    func replacingUTF8(_ source: String, with replacement: String) -> Data {
        Data(String(decoding: self, as: UTF8.self).replacingOccurrences(of: source, with: replacement).utf8)
    }
}
