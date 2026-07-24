import AmbitionsRuntimeSQLite
@testable import Ambitions
import Dispatch
import XCTest

final class CanonicalRuntimeStoreIdempotencyCASTests: XCTestCase {
    func testSemanticFingerprintExcludesJournalAndDiagnosticMetadata() throws {
        let first = AmbitionsCommand(
            id: "command-1",
            kind: .quickCapture,
            source: .today,
            payload: AmbitionsCommandPayload(rawText: "same semantic command"),
            createdAt: "2026-07-24T10:00:00Z",
            actor: .user,
            sourceSurface: "today"
        )
        let replayAttempt = AmbitionsCommand(
            id: "command-2",
            kind: .quickCapture,
            source: .today,
            payload: AmbitionsCommandPayload(rawText: "same semantic command"),
            createdAt: "2026-07-24T11:00:00Z",
            actor: .user,
            sourceSurface: "capture"
        )
        let distinct = AmbitionsCommand(
            id: "command-3",
            kind: .quickCapture,
            source: .today,
            payload: AmbitionsCommandPayload(rawText: "different semantic command"),
            createdAt: "2026-07-24T10:00:00Z",
            actor: .user,
            sourceSurface: "today"
        )

        XCTAssertEqual(
            try CanonicalCommandSemanticFingerprint.semanticV2(command: first),
            try CanonicalCommandSemanticFingerprint.semanticV2(command: replayAttempt)
        )
        XCTAssertNotEqual(
            try CanonicalCommandSemanticFingerprint.semanticV2(command: first),
            try CanonicalCommandSemanticFingerprint.semanticV2(command: distinct)
        )

        for authorizationDistinct in [
            AmbitionsCommand(
                id: "command-source", kind: .quickCapture, source: .capture,
                payload: AmbitionsCommandPayload(rawText: "same semantic command"),
                createdAt: first.createdAt
            ),
            AmbitionsCommand(
                id: "command-actor", kind: .quickCapture, source: .today,
                payload: AmbitionsCommandPayload(rawText: "same semantic command"),
                createdAt: first.createdAt, actor: .system
            ),
            AmbitionsCommand(
                id: "command-locality", kind: .quickCapture, source: .today,
                payload: AmbitionsCommandPayload(rawText: "same semantic command"),
                createdAt: first.createdAt, localOnly: false
            ),
            AmbitionsCommand(
                id: "command-privacy", kind: .quickCapture, source: .today,
                payload: AmbitionsCommandPayload(rawText: "same semantic command"),
                createdAt: first.createdAt, privacy: .privateUserText
            ),
            AmbitionsCommand(
                id: "command-revision", kind: .quickCapture, source: .today,
                payload: AmbitionsCommandPayload(rawText: "same semantic command"),
                expectedRevision: .exact(1), createdAt: first.createdAt
            ),
        ] {
            XCTAssertNotEqual(
                try CanonicalCommandSemanticFingerprint.semanticV2(command: first),
                try CanonicalCommandSemanticFingerprint.semanticV2(command: authorizationDistinct)
            )
        }
    }

    func testClaimFinalizeReplayScopeSeparationCollisionAndOwnership() async throws {
        let database = try await makeDatabase()
        let fingerprint = try CanonicalCommandSemanticFingerprint(
            digestSHA256: String(repeating: "a", count: 64)
        )
        let request = try CanonicalIdempotencyClaimRequest(
            scope: "command",
            key: "same-key",
            commandID: "command-1",
            fingerprint: fingerprint,
            ownerID: "transaction-1",
            claimedAtMilliseconds: 100
        )
        let result = try CanonicalIdempotencyFinalization(
            ownerID: "transaction-1",
            resultPayload: Data("result".utf8),
            finalizedAtMilliseconds: 200
        )

        let finalized = try await database.transaction(.immediate) { database in
            guard case .claimed = try CanonicalRuntimeStore.claimIdempotency(
                in: database,
                request: request
            ) else {
                throw CanonicalRuntimeTransactionError.corruptStoredRecord
            }
            return try CanonicalRuntimeStore.finalizeIdempotency(
                in: database,
                identity: request.claimIdentity,
                finalization: result
            )
        }
        XCTAssertEqual(finalized.payload, Data("result".utf8))

        let replay = try await database.transaction(.deferred) { database in
            try CanonicalRuntimeStore.claimIdempotency(in: database, request: request)
        }
        XCTAssertEqual(replay, .replay(finalized))

        let freshCommandReplayRequest = try CanonicalIdempotencyClaimRequest(
            scope: request.scope,
            key: request.key,
            commandID: "command-fresh-replay",
            fingerprint: fingerprint,
            ownerID: "transaction-fresh-replay",
            claimedAtMilliseconds: 250
        )
        let freshCommandReplay = try await database.transaction(.deferred) { database in
            try CanonicalRuntimeStore.claimIdempotency(
                in: database,
                request: freshCommandReplayRequest
            )
        }
        XCTAssertEqual(freshCommandReplay, .replay(finalized))
        guard case let .replay(freshResult) = freshCommandReplay else {
            return XCTFail("Expected exact finalized replay")
        }
        XCTAssertEqual(freshResult.payload, result.resultPayload)
        XCTAssertEqual(freshResult.payloadChecksumSHA256, finalized.payloadChecksumSHA256)
        let storedIdentityRows = try await database.query(
            "SELECT command_id FROM runtime_command_idempotency WHERE scope = ? AND idempotency_key = ?",
            bindings: [.text(request.scope), .text(request.key)]
        )
        XCTAssertEqual(storedIdentityRows.count, 1)
        XCTAssertEqual(storedIdentityRows.first?.value(named: "command_id"), .text(request.commandID))

        let otherScope = try CanonicalIdempotencyClaimRequest(
            scope: "import",
            key: "same-key",
            commandID: "command-2",
            fingerprint: fingerprint,
            ownerID: "transaction-2",
            claimedAtMilliseconds: 300
        )
        _ = try await database.transaction(.immediate) { database in
            _ = try CanonicalRuntimeStore.claimIdempotency(in: database, request: otherScope)
            return try CanonicalRuntimeStore.finalizeIdempotency(
                in: database,
                identity: otherScope.claimIdentity,
                finalization: try CanonicalIdempotencyFinalization(
                    ownerID: otherScope.ownerID,
                    resultPayload: Data("other-scope".utf8),
                    finalizedAtMilliseconds: 400
                )
            )
        }

        let collision = try CanonicalIdempotencyClaimRequest(
            scope: request.scope,
            key: request.key,
            commandID: request.commandID,
            fingerprint: try CanonicalCommandSemanticFingerprint(
                digestSHA256: String(repeating: "b", count: 64)
            ),
            ownerID: "transaction-3",
            claimedAtMilliseconds: 400
        )
        await assertThrows(.idempotencyCollision) {
            try await database.transaction(.immediate) { database in
                try CanonicalRuntimeStore.claimIdempotency(in: database, request: collision)
            }
        }

        let wrongOwner = try CanonicalIdempotencyClaimIdentity(
            scope: request.scope,
            key: request.key,
            ownerID: "not-the-owner"
        )
        await assertThrows(.claimOwnershipMismatch) {
            try await database.transaction(.immediate) { database in
                try CanonicalRuntimeStore.finalizeIdempotency(
                    in: database,
                    identity: wrongOwner,
                    finalization: try CanonicalIdempotencyFinalization(
                        ownerID: wrongOwner.ownerID,
                        resultPayload: Data("replacement".utf8),
                        finalizedAtMilliseconds: 500
                    )
                )
            }
        }
    }

    func testDuplicateFinalizeReturnsImmutableOriginalAndCorruptOrFutureResultsFailClosed() async throws {
        let database = try await makeDatabase()
        let request = try claimRequest()
        let original = try finalization(payload: "original")
        let duplicate = try finalization(payload: "replacement")

        let first = try await database.transaction(.immediate) { database in
            _ = try CanonicalRuntimeStore.claimIdempotency(in: database, request: request)
            return try CanonicalRuntimeStore.finalizeIdempotency(
                in: database,
                identity: request.claimIdentity,
                finalization: original
            )
        }
        let second = try await database.transaction(.immediate) { database in
            try CanonicalRuntimeStore.finalizeIdempotency(
                in: database,
                identity: request.claimIdentity,
                finalization: duplicate
            )
        }
        XCTAssertEqual(first, second)
        XCTAssertEqual(second.payload, Data("original".utf8))

        try await database.execute(
            "UPDATE runtime_command_idempotency SET final_result_version = 2"
        )
        await assertThrows(.unsupportedFinalResultVersion(maximumSupported: 1, actual: 2)) {
            try await database.transaction(.deferred) { database in
                try CanonicalRuntimeStore.claimIdempotency(in: database, request: request)
            }
        }
        try await database.execute(
            "UPDATE runtime_command_idempotency SET final_result_version = 1, final_result_checksum = ?",
            bindings: [.text(String(repeating: "0", count: 64))]
        )
        await assertThrows(.corruptStoredRecord) {
            try await database.transaction(.deferred) { database in
                try CanonicalRuntimeStore.claimIdempotency(in: database, request: request)
            }
        }
    }

    func testThrownTransactionRollsBackClaimAndFinalResult() async throws {
        let database = try await makeDatabase()
        let request = try claimRequest()
        do {
            try await database.transaction(.immediate) { database in
                _ = try CanonicalRuntimeStore.claimIdempotency(in: database, request: request)
                throw InjectedFailure()
            }
            XCTFail("Expected injected failure")
        } catch is InjectedFailure {
        }

        let rows = try await database.query(
            "SELECT scope FROM runtime_command_idempotency"
        )
        XCTAssertTrue(rows.isEmpty)
    }

    func testCancellationAfterTransactionBeginsRollsBackClaim() async throws {
        let database = try await makeDatabase()
        let request = try claimRequest()
        let entered = DispatchSemaphore(value: 0)
        let release = DispatchSemaphore(value: 0)
        let operation = Task.detached {
            try await database.transaction(.immediate) { database in
                _ = try CanonicalRuntimeStore.claimIdempotency(
                    in: database,
                    request: request
                )
                entered.signal()
                release.wait()
                try Task.checkCancellation()
            }
        }
        Self.wait(entered)
        operation.cancel()
        release.signal()
        do {
            try await operation.value
            XCTFail("Expected cancellation")
        } catch is CancellationError {
        }
        let rows = try await database.query(
            "SELECT scope FROM runtime_command_idempotency"
        )
        XCTAssertTrue(rows.isEmpty)
    }

    func testBusyFailureLeavesNoClaimOrResult() async throws {
        let holderDatabase = try await makeDatabase()
        let contenderDatabase = try SQLiteDatabase(
            url: holderDatabase.databaseURL,
            configuration: SQLiteConfiguration(
                busyTimeoutMilliseconds: 0,
                synchronousPolicy: .full,
                openMode: .existingOnly,
                maximumValueBytes: CanonicalRuntimeStore.maximumSQLiteValueBytes
            )
        )
        let entered = DispatchSemaphore(value: 0)
        let release = DispatchSemaphore(value: 0)
        let holder = Task.detached {
            try await holderDatabase.transaction(.exclusive) { _ in
                entered.signal()
                release.wait()
            }
        }
        Self.wait(entered)
        do {
            _ = try await contenderDatabase.transaction(.immediate) { database in
                try CanonicalRuntimeStore.claimIdempotency(
                    in: database,
                    request: try Self.claimRequestStatic()
                )
            }
            XCTFail("Expected SQLite busy failure")
        } catch let error as SQLiteError {
            XCTAssertEqual(error.primaryCode, 5)
        }
        release.signal()
        _ = try await holder.value
        let rows = try await holderDatabase.query(
            "SELECT scope FROM runtime_command_idempotency"
        )
        XCTAssertTrue(rows.isEmpty)
    }

    func testSQLiteFullFailureLeavesNoClaimOrFinalResult() async throws {
        let database = try await makeDatabase()
        let pageRows = try await database.query("PRAGMA page_count")
        guard case let .integer(pageCount)? = pageRows.first?.values.first else {
            return XCTFail("Expected page count")
        }
        _ = try await database.query("PRAGMA max_page_count = \(pageCount)")
        do {
            try await database.transaction(.immediate) { database in
                let request = try Self.claimRequestStatic()
                _ = try CanonicalRuntimeStore.claimIdempotency(
                    in: database,
                    request: request
                )
                _ = try CanonicalRuntimeStore.finalizeIdempotency(
                    in: database,
                    identity: request.claimIdentity,
                    finalization: CanonicalIdempotencyFinalization(
                        ownerID: request.ownerID,
                        resultPayload: Data(repeating: 0x41, count: 900_000),
                        finalizedAtMilliseconds: 200
                    )
                )
            }
            XCTFail("Expected SQLite full failure")
        } catch let error as SQLiteError {
            XCTAssertEqual(error.primaryCode, 13)
        }
        let rows = try await database.query(
            "SELECT scope FROM runtime_command_idempotency"
        )
        XCTAssertTrue(rows.isEmpty)
    }

    func testAbsentAndExactCASAdvanceAtomicallyWithObservedConflictEvidence() async throws {
        let database = try await makeDatabase()
        let key = try CanonicalAggregateKey(kind: "goal", id: "goal-1")
        let missingKey = try CanonicalAggregateKey(kind: "goal", id: "missing")
        await assertThrows(
            .revisionConflict(.init(
                sortedMutationIndex: 0,
                expected: .exact(0),
                observedRevision: nil
            ))
        ) {
            try await database.transaction(.immediate) { database in
                try CanonicalRuntimeStore.applyAggregateCAS(
                    in: database,
                    mutations: [try Self.mutation(
                        key: missingKey,
                        expected: .exact(0),
                        payload: "missing"
                    )]
                )
            }
        }
        let inserted = try await database.transaction(.immediate) { database in
            try CanonicalRuntimeStore.applyAggregateCAS(
                in: database,
                mutations: [try Self.mutation(key: key, expected: .absent, payload: "v0")]
            )
        }
        XCTAssertEqual(inserted.map(\.revision), [0])

        let updated = try await database.transaction(.immediate) { database in
            try CanonicalRuntimeStore.applyAggregateCAS(
                in: database,
                mutations: [try Self.mutation(key: key, expected: .exact(0), payload: "v1")]
            )
        }
        XCTAssertEqual(updated.map(\.revision), [1])

        await assertThrows(
            .revisionConflict(.init(sortedMutationIndex: 0, expected: .exact(0), observedRevision: 1))
        ) {
            try await database.transaction(.immediate) { database in
                try CanonicalRuntimeStore.applyAggregateCAS(
                    in: database,
                    mutations: [try Self.mutation(key: key, expected: .exact(0), payload: "stale")]
                )
            }
        }
        await assertThrows(.duplicateAggregateKey(sortedMutationIndex: 1)) {
            try await database.transaction(.immediate) { database in
                try CanonicalRuntimeStore.applyAggregateCAS(
                    in: database,
                    mutations: [
                        try Self.mutation(key: key, expected: .exact(1), payload: "first"),
                        try Self.mutation(key: key, expected: .exact(1), payload: "duplicate"),
                    ]
                )
            }
        }
    }

    func testMultiAggregateConflictRollsBackEarlierSortedMutation() async throws {
        let database = try await makeDatabase()
        let firstKey = try CanonicalAggregateKey(kind: "goal", id: "a")
        let secondKey = try CanonicalAggregateKey(kind: "goal", id: "b")
        _ = try await database.transaction(.immediate) { database in
            try CanonicalRuntimeStore.applyAggregateCAS(
                in: database,
                mutations: [try Self.mutation(key: secondKey, expected: .absent, payload: "existing")]
            )
        }

        await assertThrows(
            .revisionConflict(.init(sortedMutationIndex: 1, expected: .absent, observedRevision: 0))
        ) {
            try await database.transaction(.immediate) { database in
                try CanonicalRuntimeStore.applyAggregateCAS(
                    in: database,
                    mutations: [
                        try Self.mutation(key: secondKey, expected: .absent, payload: "collision"),
                        try Self.mutation(key: firstKey, expected: .absent, payload: "must-rollback"),
                    ]
                )
            }
        }
        let rows = try await database.query(
            "SELECT aggregate_id FROM runtime_aggregates ORDER BY aggregate_id"
        )
        XCTAssertEqual(rows.compactMap { $0.value(named: "aggregate_id") }, [.text("b")])
    }

    func testConcurrentIdenticalClaimsConvergeAndDistinctClaimCollides() async throws {
        let firstDatabase = try await makeDatabase()
        let secondDatabase = try SQLiteDatabase(
            url: firstDatabase.databaseURL,
            configuration: CanonicalRuntimeStore.sqliteConfiguration(openMode: .existingOnly)
        )
        let firstRequest = try claimRequest(ownerID: "transaction-a")
        let secondRequest = try claimRequest(ownerID: "transaction-b")

        async let first = Self.commit(
            request: firstRequest,
            payload: "canonical",
            in: firstDatabase
        )
        async let second = Self.commit(
            request: secondRequest,
            payload: "canonical",
            in: secondDatabase
        )
        let outcomes = try await (first, second)
        XCTAssertEqual(
            [outcomes.0.payload, outcomes.1.payload],
            [Data("canonical".utf8), Data("canonical".utf8)]
        )

        let distinct = try CanonicalIdempotencyClaimRequest(
            scope: firstRequest.scope,
            key: firstRequest.key,
            commandID: firstRequest.commandID,
            fingerprint: CanonicalCommandSemanticFingerprint(
                digestSHA256: String(repeating: "b", count: 64)
            ),
            ownerID: "transaction-c",
            claimedAtMilliseconds: 500
        )
        await assertThrows(.idempotencyCollision) {
            try await secondDatabase.transaction(.immediate) { database in
                try CanonicalRuntimeStore.claimIdempotency(in: database, request: distinct)
            }
        }
    }

    func testAbsentCreateRaceAndCompetingExactUpdateHaveSingleWinner() async throws {
        let firstDatabase = try await makeDatabase()
        let secondDatabase = try SQLiteDatabase(
            url: firstDatabase.databaseURL,
            configuration: CanonicalRuntimeStore.sqliteConfiguration(openMode: .existingOnly)
        )
        let key = try CanonicalAggregateKey(kind: "goal", id: "race")
        let absent = try Self.mutation(key: key, expected: .absent, payload: "created")

        async let firstCreate = Self.captureCAS(absent, in: firstDatabase)
        async let secondCreate = Self.captureCAS(absent, in: secondDatabase)
        let createPair = await (firstCreate, secondCreate)
        let creates = [createPair.0, createPair.1]
        XCTAssertEqual(creates.filter(\.isSuccess).count, 1)
        XCTAssertEqual(creates.filter(\.isRevisionConflict).count, 1)

        let exact = try Self.mutation(key: key, expected: .exact(0), payload: "updated")
        async let firstUpdate = Self.captureCAS(exact, in: firstDatabase)
        async let secondUpdate = Self.captureCAS(exact, in: secondDatabase)
        let updatePair = await (firstUpdate, secondUpdate)
        let updates = [updatePair.0, updatePair.1]
        XCTAssertEqual(updates.filter(\.isSuccess).count, 1)
        XCTAssertEqual(updates.filter(\.isRevisionConflict).count, 1)
    }

    func testPrivacySafeErrorsNeverRenderCommandOrPayloadMaterial() throws {
        let errors: [CanonicalRuntimeTransactionError] = [
            .idempotencyCollision,
            .claimOwnershipMismatch,
            .corruptStoredRecord,
            .revisionConflict(.init(
                sortedMutationIndex: 0,
                expected: .absent,
                observedRevision: nil
            )),
        ]
        for error in errors {
            let rendered = String(describing: error)
            XCTAssertFalse(rendered.contains("private command body"))
            XCTAssertFalse(rendered.contains("/Library/"))
            XCTAssertFalse(rendered.contains("goal-private-id"))
        }
    }
}

private extension CanonicalRuntimeStoreIdempotencyCASTests {
    func makeDatabase() async throws -> SQLiteDatabase {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(
            "canonical-idempotency-cas-\(UUID().uuidString)",
            isDirectory: true
        )
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: false)
        addTeardownBlock { try? FileManager.default.removeItem(at: root) }
        let database = try SQLiteDatabase(
            url: root.appendingPathComponent("Runtime.sqlite"),
            configuration: CanonicalRuntimeStore.sqliteConfiguration(openMode: .createOrOpen)
        )
        try await CanonicalRuntimeStore.installSchema(
            in: database,
            generationID: try RuntimeStoreGenerationID(
                validating: "11111111-2222-4333-8444-555555555555"
            ),
            createdAtMilliseconds: 1
        )
        return database
    }

    func claimRequest(
        ownerID: String = "transaction-1"
    ) throws -> CanonicalIdempotencyClaimRequest {
        try CanonicalIdempotencyClaimRequest(
            scope: "command",
            key: "key-1",
            commandID: "command-1",
            fingerprint: CanonicalCommandSemanticFingerprint(
                digestSHA256: String(repeating: "a", count: 64)
            ),
            ownerID: ownerID,
            claimedAtMilliseconds: 100
        )
    }

    func finalization(payload: String) throws -> CanonicalIdempotencyFinalization {
        try CanonicalIdempotencyFinalization(
            ownerID: "transaction-1",
            resultPayload: Data(payload.utf8),
            finalizedAtMilliseconds: 200
        )
    }

    static func commit(
        request: CanonicalIdempotencyClaimRequest,
        payload: String,
        in database: SQLiteDatabase
    ) async throws -> CanonicalIdempotencyFinalResult {
        try await database.transaction(.immediate) { database in
            switch try CanonicalRuntimeStore.claimIdempotency(
                in: database,
                request: request
            ) {
            case let .replay(result):
                return result
            case .claimed:
                return try CanonicalRuntimeStore.finalizeIdempotency(
                    in: database,
                    identity: request.claimIdentity,
                    finalization: CanonicalIdempotencyFinalization(
                        ownerID: request.ownerID,
                        resultPayload: Data(payload.utf8),
                        finalizedAtMilliseconds: 600
                    )
                )
            }
        }
    }

    static func captureCAS(
        _ mutation: CanonicalAggregateCASMutation,
        in database: SQLiteDatabase
    ) async -> CASCapture {
        do {
            _ = try await database.transaction(.immediate) { database in
                try CanonicalRuntimeStore.applyAggregateCAS(
                    in: database,
                    mutations: [mutation]
                )
            }
            return .success
        } catch let error as CanonicalRuntimeTransactionError {
            if case .revisionConflict = error { return .revisionConflict }
            return .otherFailure
        } catch {
            return .otherFailure
        }
    }

    static func claimRequestStatic() throws -> CanonicalIdempotencyClaimRequest {
        try CanonicalIdempotencyClaimRequest(
            scope: "command",
            key: "key-static",
            commandID: "command-static",
            fingerprint: CanonicalCommandSemanticFingerprint(
                digestSHA256: String(repeating: "c", count: 64)
            ),
            ownerID: "transaction-static",
            claimedAtMilliseconds: 100
        )
    }

    static func wait(_ semaphore: DispatchSemaphore) {
        semaphore.wait()
    }

    static func mutation(
        key: CanonicalAggregateKey,
        expected: RuntimeExpectedRevision,
        payload: String
    ) throws -> CanonicalAggregateCASMutation {
        try CanonicalAggregateCASMutation(
            key: key,
            expectedRevision: expected,
            payloadVersion: 1,
            payload: Data(payload.utf8)
        )
    }

    func assertThrows<T>(
        _ expected: CanonicalRuntimeTransactionError,
        operation: () async throws -> T
    ) async {
        do {
            _ = try await operation()
            XCTFail("Expected canonical transaction error")
        } catch {
            XCTAssertEqual(error as? CanonicalRuntimeTransactionError, expected)
        }
    }
}

private struct InjectedFailure: Error {}

private enum CASCapture: Equatable {
    case success
    case revisionConflict
    case otherFailure

    var isSuccess: Bool { self == .success }
    var isRevisionConflict: Bool { self == .revisionConflict }
}
