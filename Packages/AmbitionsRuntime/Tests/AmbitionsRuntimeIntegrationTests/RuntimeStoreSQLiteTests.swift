import Foundation
import SQLite3
import XCTest
import AmbitionsRuntimeCore
@testable import AmbitionsRuntimeSQLite

final class RuntimeStoreSQLiteTests: XCTestCase {
    func testAtomicCommitPersistsCanonicalStoryAndSurvivesRestart() async throws {
        let databaseURL = temporaryDatabaseURL()
        let transition = makeTransition()
        let store = try RuntimeStoreSQLite(databaseURL: databaseURL)

        let firstReceipt = try await store.commit(
            transition,
            idempotencyKey: "capture.001.commit"
        )
        let duplicateReceipt = try await store.commit(
            transition,
            idempotencyKey: "capture.001.commit"
        )
        let firstSnapshot = try await store.snapshot()

        XCTAssertEqual(firstReceipt, transition.receipt)
        XCTAssertEqual(duplicateReceipt, firstReceipt)
        XCTAssertEqual(firstSnapshot.canonicalRevision, 1)
        XCTAssertEqual(firstSnapshot.stateChanges, transition.stateChanges)
        XCTAssertEqual(firstSnapshot.events, transition.events)
        XCTAssertEqual(firstSnapshot.projectionChanges, transition.projectionChanges)
        XCTAssertEqual(firstSnapshot.receipts, [transition.receipt])
        XCTAssertEqual(firstSnapshot.externalEffects, transition.externalEffects)

        let restarted = try RuntimeStoreSQLite(databaseURL: databaseURL)
        let restartedSnapshot = try await restarted.snapshot()
        let restartedReceipt = try await restarted.receipt(
            forCommandID: transition.commandID
        )

        XCTAssertEqual(restartedSnapshot, firstSnapshot)
        XCTAssertEqual(restartedReceipt, firstReceipt)
    }

    func testInjectedInteriorFailureRollsBackEveryAuthorityTable() async throws {
        let store = try RuntimeStoreSQLite(
            databaseURL: temporaryDatabaseURL(),
            failurePoint: .afterEvents
        )

        do {
            _ = try await store.commit(
                makeTransition(),
                idempotencyKey: "capture.001.commit"
            )
            XCTFail("Expected injected failure")
        } catch let error as RuntimeStoreError {
            XCTAssertEqual(error, .injectedFailure(.afterEvents))
        }

        let snapshot = try await store.snapshot()
        XCTAssertEqual(snapshot, .empty)
    }

    func testInjectedAfterCommitFailurePreservesCompleteStoryAndRetryIsIdempotent() async throws {
        let databaseURL = temporaryDatabaseURL()
        let transition = makeTransition()
        let failingStore = try RuntimeStoreSQLite(
            databaseURL: databaseURL,
            failurePoint: .afterCommit
        )

        do {
            _ = try await failingStore.commit(
                transition,
                idempotencyKey: "capture.001.commit"
            )
            XCTFail("Expected injected failure")
        } catch let error as RuntimeStoreError {
            XCTAssertEqual(error, .injectedFailure(.afterCommit))
        }

        let restarted = try RuntimeStoreSQLite(databaseURL: databaseURL)
        let snapshot = try await restarted.snapshot()
        let retriedReceipt = try await restarted.commit(
            transition,
            idempotencyKey: "capture.001.commit"
        )

        XCTAssertEqual(snapshot.canonicalRevision, 1)
        XCTAssertEqual(snapshot.stateChanges, transition.stateChanges)
        XCTAssertEqual(snapshot.events, transition.events)
        XCTAssertEqual(snapshot.projectionChanges, transition.projectionChanges)
        XCTAssertEqual(snapshot.receipts, [transition.receipt])
        XCTAssertEqual(snapshot.externalEffects, transition.externalEffects)
        XCTAssertEqual(retriedReceipt, transition.receipt)
        let retriedSnapshot = try await restarted.snapshot()
        XCTAssertEqual(retriedSnapshot, snapshot)
    }

    func testStaleExpectedRevisionRejectsBeforeMutation() async throws {
        let store = try RuntimeStoreSQLite(databaseURL: temporaryDatabaseURL())
        _ = try await store.commit(
            makeTransition(),
            idempotencyKey: "capture.001.commit"
        )
        let stale = makeTransition(
            commandID: "command.capture.002",
            expectedRevision: 0,
            newRevision: 1
        )

        do {
            _ = try await store.commit(
                stale,
                idempotencyKey: "capture.002.commit"
            )
            XCTFail("Expected revision conflict")
        } catch let error as RuntimeStoreError {
            XCTAssertEqual(
                error,
                .revisionConflict(expected: 0, actual: 1)
            )
        }

        let snapshot = try await store.snapshot()
        XCTAssertEqual(snapshot.receipts.count, 1)
        XCTAssertEqual(snapshot.canonicalRevision, 1)
    }

    func testExternalEffectLifecyclePersistsAcrossRestartAndRetry() async throws {
        let databaseURL = temporaryDatabaseURL()
        let transition = makeTransition()
        let effect = try XCTUnwrap(transition.externalEffects.first)
        let store = try RuntimeStoreSQLite(databaseURL: databaseURL)
        _ = try await store.commit(
            transition,
            idempotencyKey: "capture.001.commit"
        )

        let pendingRecords = try await store.externalEffectRecords()
        let pending = try XCTUnwrap(pendingRecords.first)
        XCTAssertEqual(pending.envelope, effect)
        XCTAssertEqual(pending.status, .pending)
        XCTAssertEqual(pending.attemptCount, 0)
        XCTAssertNil(pending.claim)
        XCTAssertNil(pending.failureDescription)

        let firstClaimTime = Date(timeIntervalSince1970: 100)
        let claimedResult = try await store.claimNextExternalEffect(
            claimID: "worker.1",
            claimedAt: firstClaimTime
        )
        let claimed = try XCTUnwrap(claimedResult)
        XCTAssertEqual(claimed.status, .claimed)
        XCTAssertEqual(claimed.attemptCount, 1)
        XCTAssertEqual(
            claimed.claim,
            RuntimeExternalEffectClaim(
                id: "worker.1",
                claimedAt: firstClaimTime
            )
        )
        XCTAssertNil(claimed.failureDescription)

        let failed = try await store.markExternalEffectFailed(
            effectID: effect.id,
            claimID: "worker.1",
            failureDescription: "network unavailable"
        )
        XCTAssertEqual(failed.status, .failed)
        XCTAssertEqual(failed.attemptCount, 1)
        XCTAssertNil(failed.claim)
        XCTAssertEqual(failed.failureDescription, "network unavailable")

        let restarted = try RuntimeStoreSQLite(databaseURL: databaseURL)
        let restartedRecords = try await restarted.externalEffectRecords()
        XCTAssertEqual(restartedRecords, [failed])

        let retryTime = Date(timeIntervalSince1970: 200)
        let retriedResult = try await restarted.claimNextExternalEffect(
            claimID: "worker.2",
            claimedAt: retryTime
        )
        let retried = try XCTUnwrap(retriedResult)
        XCTAssertEqual(retried.status, .claimed)
        XCTAssertEqual(retried.attemptCount, 2)
        XCTAssertEqual(
            retried.claim,
            RuntimeExternalEffectClaim(id: "worker.2", claimedAt: retryTime)
        )
        XCTAssertNil(retried.failureDescription)

        let reconciled = try await restarted.markExternalEffectReconciled(
            effectID: effect.id,
            claimID: "worker.2"
        )
        let repeated = try await restarted.markExternalEffectReconciled(
            effectID: effect.id,
            claimID: "worker.2"
        )
        XCTAssertEqual(reconciled.status, .reconciled)
        XCTAssertNil(reconciled.claim)
        XCTAssertEqual(repeated, reconciled)

        let finalRestart = try RuntimeStoreSQLite(databaseURL: databaseURL)
        let finalClaim = try await finalRestart.claimNextExternalEffect(
            claimID: "worker.3",
            claimedAt: Date(timeIntervalSince1970: 300)
        )
        XCTAssertNil(finalClaim)
        let finalRecords = try await finalRestart.externalEffectRecords()
        XCTAssertEqual(finalRecords, [reconciled])
    }

    func testConcurrentStoresCannotClaimTheSameEligibleEffect() async throws {
        let databaseURL = temporaryDatabaseURL()
        let transition = makeTransition()
        let writer = try RuntimeStoreSQLite(databaseURL: databaseURL)
        _ = try await writer.commit(
            transition,
            idempotencyKey: "capture.001.commit"
        )
        let firstStore = try RuntimeStoreSQLite(databaseURL: databaseURL)
        let secondStore = try RuntimeStoreSQLite(databaseURL: databaseURL)
        let claimTime = Date(timeIntervalSince1970: 400)

        async let first = firstStore.claimNextExternalEffect(
            claimID: "worker.1",
            claimedAt: claimTime
        )
        async let second = secondStore.claimNextExternalEffect(
            claimID: "worker.2",
            claimedAt: claimTime
        )
        let claimResults = try await [first, second]
        let claims = claimResults.compactMap { $0 }

        XCTAssertEqual(claims.count, 1)
        XCTAssertEqual(claims.first?.envelope, transition.externalEffects.first)
        XCTAssertEqual(claims.first?.attemptCount, 1)

        let restarted = try RuntimeStoreSQLite(databaseURL: databaseURL)
        let restartedClaim = try await restarted.claimNextExternalEffect(
            claimID: "worker.3",
            claimedAt: Date(timeIntervalSince1970: 500)
        )
        XCTAssertNil(restartedClaim)
    }

    func testEligibleEffectsAreClaimedInInsertionOrder() async throws {
        let transition = makeTransition(
            effectIDs: ["effect.first", "effect.second", "effect.third"]
        )
        let store = try RuntimeStoreSQLite(
            databaseURL: temporaryDatabaseURL()
        )
        _ = try await store.commit(
            transition,
            idempotencyKey: "capture.001.commit"
        )

        var claimedIDs: [String] = []
        for index in 1...3 {
            let record = try await store.claimNextExternalEffect(
                claimID: "worker.\(index)",
                claimedAt: Date(timeIntervalSince1970: TimeInterval(index))
            )
            claimedIDs.append(try XCTUnwrap(record).envelope.id)
        }

        XCTAssertEqual(
            claimedIDs,
            ["effect.first", "effect.second", "effect.third"]
        )
    }

    func testRecoveryCutoffReclaimsOnlyAbandonedClaims() async throws {
        let databaseURL = temporaryDatabaseURL()
        let transition = makeTransition()
        let writer = try RuntimeStoreSQLite(databaseURL: databaseURL)
        _ = try await writer.commit(
            transition,
            idempotencyKey: "capture.001.commit"
        )
        let originalClaimTime = Date(timeIntervalSince1970: 600)
        _ = try await writer.claimNextExternalEffect(
            claimID: "worker.original",
            claimedAt: originalClaimTime
        )

        let restarted = try RuntimeStoreSQLite(databaseURL: databaseURL)
        let newerThanCutoff = try await restarted.claimNextExternalEffect(
            claimID: "worker.recovery",
            claimedAt: Date(timeIntervalSince1970: 700),
            recoveringClaimsAtOrBefore: Date(timeIntervalSince1970: 599)
        )
        XCTAssertNil(newerThanCutoff)

        let recoveredResult = try await restarted.claimNextExternalEffect(
            claimID: "worker.recovery",
            claimedAt: Date(timeIntervalSince1970: 701),
            recoveringClaimsAtOrBefore: originalClaimTime
        )
        let recovered = try XCTUnwrap(recoveredResult)
        XCTAssertEqual(recovered.status, .claimed)
        XCTAssertEqual(recovered.attemptCount, 2)
        XCTAssertEqual(recovered.claim?.id, "worker.recovery")
    }

    func testMismatchedClaimRejectsWithoutChangingDurableRecord() async throws {
        let databaseURL = temporaryDatabaseURL()
        let transition = makeTransition()
        let effect = try XCTUnwrap(transition.externalEffects.first)
        let store = try RuntimeStoreSQLite(databaseURL: databaseURL)
        _ = try await store.commit(
            transition,
            idempotencyKey: "capture.001.commit"
        )
        let claimedResult = try await store.claimNextExternalEffect(
            claimID: "worker.owner",
            claimedAt: Date(timeIntervalSince1970: 800)
        )
        let claimed = try XCTUnwrap(claimedResult)

        do {
            _ = try await store.markExternalEffectReconciled(
                effectID: effect.id,
                claimID: "worker.other"
            )
            XCTFail("Expected claim mismatch")
        } catch let error as RuntimeExternalEffectError {
            XCTAssertEqual(
                error,
                .claimMismatch(
                    effectID: effect.id,
                    expectedClaimID: "worker.owner",
                    actualClaimID: "worker.other"
                )
            )
        }

        let records = try await store.externalEffectRecords()
        XCTAssertEqual(records, [claimed])
    }

    func testCurrentSchemaDatabaseMigratesAdditivelyForDurableClaims() async throws {
        let databaseURL = temporaryDatabaseURL()
        try FileManager.default.createDirectory(
            at: databaseURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        var database: OpaquePointer?
        XCTAssertEqual(
            sqlite3_open_v2(
                databaseURL.path,
                &database,
                SQLITE_OPEN_CREATE | SQLITE_OPEN_READWRITE,
                nil
            ),
            SQLITE_OK
        )
        let legacySchema = """
        CREATE TABLE runtime_external_effects (
            effect_id TEXT PRIMARY KEY,
            command_id TEXT NOT NULL,
            effect_json BLOB NOT NULL,
            status TEXT NOT NULL CHECK(
                status IN ('pending', 'reconciled', 'failed')
            )
        );
        """
        XCTAssertEqual(
            sqlite3_exec(database, legacySchema, nil, nil, nil),
            SQLITE_OK
        )
        XCTAssertEqual(sqlite3_close(database), SQLITE_OK)
        database = nil

        let transition = makeTransition()
        let store = try RuntimeStoreSQLite(databaseURL: databaseURL)
        _ = try await store.commit(
            transition,
            idempotencyKey: "capture.001.commit"
        )
        let claimed = try await store.claimNextExternalEffect(
            claimID: "worker.migrated",
            claimedAt: Date(timeIntervalSince1970: 900)
        )

        XCTAssertEqual(claimed?.status, .claimed)
        XCTAssertEqual(claimed?.attemptCount, 1)
    }

    func testLegacyExternalEffectStatusesBackfillOnceAndPreserveEligibilityAcrossReopens() async throws {
        let databaseURL = temporaryDatabaseURL()
        try FileManager.default.createDirectory(
            at: databaseURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        var database: OpaquePointer?
        XCTAssertEqual(
            sqlite3_open_v2(
                databaseURL.path,
                &database,
                SQLITE_OPEN_CREATE | SQLITE_OPEN_READWRITE,
                nil
            ),
            SQLITE_OK
        )
        let legacySchema = """
        CREATE TABLE runtime_external_effects (
            effect_id TEXT PRIMARY KEY,
            command_id TEXT NOT NULL,
            effect_json BLOB NOT NULL,
            status TEXT NOT NULL CHECK(
                status IN ('pending', 'reconciled', 'failed')
            )
        );
        """
        XCTAssertEqual(
            sqlite3_exec(database, legacySchema, nil, nil, nil),
            SQLITE_OK
        )

        let effects = makeTransition(
            effectIDs: [
                "effect.legacy.pending",
                "effect.legacy.reconciled",
                "effect.legacy.failed"
            ]
        ).externalEffects
        let statuses = ["pending", "reconciled", "failed"]
        for (effect, status) in zip(effects, statuses) {
            let encodedEffect = try JSONEncoder().encode(effect)
                .map { String(format: "%02x", $0) }
                .joined()
            let insert = """
            INSERT INTO runtime_external_effects (
                effect_id, command_id, effect_json, status
            ) VALUES (
                '\(effect.id)', 'command.legacy', X'\(encodedEffect)', '\(status)'
            );
            """
            XCTAssertEqual(sqlite3_exec(database, insert, nil, nil, nil), SQLITE_OK)
        }
        XCTAssertEqual(sqlite3_close(database), SQLITE_OK)
        database = nil

        let migrated = try RuntimeStoreSQLite(databaseURL: databaseURL)
        let initialRecords = try await migrated.externalEffectRecords()
        XCTAssertEqual(
            initialRecords.map(\.status),
            [.pending, .reconciled, .failed]
        )
        XCTAssertEqual(initialRecords.map(\.attemptCount), [0, 0, 0])

        let pendingClaimResult = try await migrated.claimNextExternalEffect(
            claimID: "worker.pending",
            claimedAt: Date(timeIntervalSince1970: 1_000)
        )
        let pendingClaim = try XCTUnwrap(pendingClaimResult)
        XCTAssertEqual(pendingClaim.envelope.id, "effect.legacy.pending")
        XCTAssertEqual(pendingClaim.status, .claimed)

        let reopenedAfterClaim = try RuntimeStoreSQLite(databaseURL: databaseURL)
        let recordsAfterClaim = try await reopenedAfterClaim.externalEffectRecords()
        XCTAssertEqual(recordsAfterClaim[0], pendingClaim)
        XCTAssertEqual(recordsAfterClaim[1].status, .reconciled)
        XCTAssertEqual(recordsAfterClaim[2].status, .failed)

        _ = try await reopenedAfterClaim.markExternalEffectReconciled(
            effectID: pendingClaim.envelope.id,
            claimID: "worker.pending"
        )
        let failedClaimResult = try await reopenedAfterClaim.claimNextExternalEffect(
            claimID: "worker.failed",
            claimedAt: Date(timeIntervalSince1970: 1_001)
        )
        let failedClaim = try XCTUnwrap(failedClaimResult)
        XCTAssertEqual(failedClaim.envelope.id, "effect.legacy.failed")
        XCTAssertEqual(failedClaim.status, .claimed)
        XCTAssertEqual(failedClaim.attemptCount, 1)

        let noEligibleEffects = try await reopenedAfterClaim.claimNextExternalEffect(
            claimID: "worker.unexpected",
            claimedAt: Date(timeIntervalSince1970: 1_002)
        )
        XCTAssertNil(noEligibleEffects)
    }

    private func temporaryDatabaseURL() -> URL {
        FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
            .appendingPathComponent("RuntimeStore.sqlite")
    }

    private func makeTransition(
        commandID: String = "command.capture.001",
        expectedRevision: Int64 = 0,
        newRevision: Int64 = 1,
        effectIDs: [String]? = nil
    ) -> RuntimeTransition {
        let aggregate = RuntimeAggregateReference(
            kind: "capture",
            id: "capture.001"
        )
        let event = RuntimeEvent(
            id: "event.\(commandID)",
            kind: "capture.committed",
            aggregate: aggregate,
            aggregateRevision: newRevision,
            payload: Data("event".utf8)
        )
        let projection = RuntimeProjectionChange(
            projection: "today",
            cursor: "cursor.\(newRevision)",
            payload: Data("projection".utf8)
        )
        let effects = (effectIDs ?? ["effect.\(commandID)"]).map { effectID in
            RuntimeExternalEffectEnvelope(
                id: effectID,
                kind: "extension.snapshot.refresh",
                idempotencyKey: effectID,
                payload: Data("effect".utf8)
            )
        }
        return RuntimeTransition(
            commandID: commandID,
            stateChanges: [
                RuntimeStateChange(
                    aggregate: aggregate,
                    expectedRevision: expectedRevision,
                    newRevision: newRevision,
                    value: Data("state".utf8)
                )
            ],
            events: [event],
            projectionChanges: [projection],
            receipt: RuntimeReceipt(
                id: "receipt.\(commandID)",
                commandID: commandID,
                canonicalRevision: newRevision,
                eventIDs: [event.id],
                projectionCursors: [projection.projection: projection.cursor],
                externalEffectIDs: effects.map(\.id),
                semanticUndoEligible: false
            ),
            compensation: nil,
            externalEffects: effects
        )
    }
}
