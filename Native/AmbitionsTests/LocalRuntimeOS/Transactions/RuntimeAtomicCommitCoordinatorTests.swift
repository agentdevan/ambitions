@testable import Ambitions
import AmbitionsRuntimeSQLite
import Foundation
import XCTest

final class RuntimeAtomicCommitCoordinatorTests: XCTestCase {
    func testCanonicalAggregateStateCodecIsExactAndPreservesTombstoneLifecycle() throws {
        let aggregate = RuntimeSemanticAggregate(
            kind: .capture,
            id: try RuntimeAggregateID(validating: "capture-1")
        )
        let objectID = try RuntimeDomainObjectID(validating: "capture-1")
        let command = CaptureCommand(
            action: .archive,
            target: AmbitionsCommandTarget(captureID: "capture-1"),
            content: RuntimeCommandContent(AmbitionsCommandPayload(title: "Archive"))
        )
        let state = RuntimeCanonicalAggregateState(
            aggregate: aggregate,
            revision: 8,
            lifecycle: .tombstoned,
            transition: .tombstone,
            commandPayload: .capture(command),
            changedObjectIDs: [objectID]
        )
        let codec = RuntimeCanonicalAggregateStateCodec()
        let bytes = try codec.encode(state)

        XCTAssertEqual(try codec.decode(bytes), state)
        XCTAssertEqual(try codec.encode(codec.decode(bytes)), bytes)
        XCTAssertEqual(try codec.decode(bytes).lifecycle, .tombstoned)
    }

    func testSchemaV1CompatibilityAndStagedV3SelectionAreExplicit() {
        XCTAssertEqual(canonicalRuntimeStoreSchemaVersion, 1)
        XCTAssertEqual(CanonicalRuntimeCommitSchemaPlan.sourceSchemaVersion, 1)
        XCTAssertEqual(CanonicalRuntimeCommitSchemaPlan.targetSchemaVersion, 3)
        XCTAssertFalse(CanonicalRuntimeStore.expectedRuntimeTables.contains("runtime_commit_receipts"))
        XCTAssertTrue(CanonicalRuntimeCommitSchemaPlan.tables.contains("runtime_commit_receipts"))
        XCTAssertTrue(CanonicalRuntimeSemanticEventSchemaPlan.tables.contains("runtime_semantic_events"))
    }

    func testSchemaV1CommitCheckIsTypedMigrationRequiredAndDoesNotUpgrade() async throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("runtime-t09-v1-\(UUID().uuidString)", isDirectory: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let database = try SQLiteDatabase(url: directory.appendingPathComponent("Runtime.sqlite"))
        try await database.execute("PRAGMA user_version = 1")
        do {
            try await database.transaction(.immediate) { database in
                try CanonicalRuntimeCommitSchemaPlan.requireIntegratedSchema(in: database)
            }
            XCTFail("Expected staged schema requirement")
        } catch let error as RuntimeAtomicCommitError {
            XCTAssertEqual(error, .migrationRequired(expected: 3, actual: 1))
        }
        let version = try await database.query("PRAGMA user_version")
        XCTAssertEqual(version.first?.values.first, .integer(1))
        let tables = try await database.query(
            "SELECT name FROM sqlite_schema WHERE name LIKE 'runtime_commit_%'"
        )
        XCTAssertTrue(tables.isEmpty)
    }

    func testEveryCommitArtifactReferencesSemanticEventAuthorityOnly() {
        let schema = CanonicalRuntimeCommitSchemaPlan.statements.joined(separator: "\n")
        XCTAssertTrue(schema.contains("REFERENCES runtime_semantic_events(sequence)"))
        XCTAssertFalse(schema.contains("REFERENCES runtime_events(sequence)"))
        XCTAssertTrue(schema.contains("runtime_commit_receipts"))
        XCTAssertTrue(schema.contains("runtime_commit_projection_invalidations"))
        XCTAssertTrue(schema.contains("runtime_pending_external_operations"))
        XCTAssertTrue(schema.contains("runtime_confirmation_consumptions"))
        XCTAssertTrue(schema.contains("runtime_commit_tombstones"))
        XCTAssertTrue(schema.contains("payload_checksum TEXT NOT NULL CHECK (length(payload_checksum) = 64 AND payload_checksum NOT GLOB '*[^0-9a-f]*')"))
    }

    func testFaultInventoryCoversEveryDurablePhase() {
        XCTAssertEqual(Set(RuntimeAtomicCommitPhase.allCases), [
            .claimed, .snapshotsLoaded, .reduced, .aggregatesApplied,
            .eventAppended, .invalidationsPersisted, .receiptPersisted,
            .externalOperationsPersisted, .idempotencyFinalized,
            .confirmationConsumed,
        ])
    }

    func testTypedReceiptCarriesDeterministicEventAndUnresolvedWorkLineage() throws {
        let eventID = try RuntimeEventID(validating: "event-1")
        let lineage = RuntimeAuthorityLineageReference(
            eventID: eventID,
            eventSequence: 11,
            eventHash: String(repeating: "a", count: 64)
        )
        let unresolved = RuntimeAuthorityUnresolvedWorkReference(
            kind: .projectionInvalidation,
            stableID: "invalidation.11.projection.today",
            lineage: lineage
        )
        let tombstone = RuntimeCanonicalTombstoneDraft(
            objectID: try RuntimeDomainObjectID(validating: "capture-1"),
            family: RuntimeSemanticAggregateKind.capture.rawValue,
            terminalRevision: 4,
            lineage: lineage,
            authority: RuntimeCanonicalTombstoneAuthority(
                reason: .archived,
                predecessorDigest: String(repeating: "b", count: 64),
                retentionDisposition: .retainedUntilDownstreamPolicy,
                recoveryDisposition: .explicitTypedRestorationRequired
            )
        )

        XCTAssertEqual(unresolved.lineage.eventID, eventID)
        XCTAssertEqual(tombstone.lineage.eventSequence, 11)
        XCTAssertEqual(tombstone.terminalRevision, 4)
    }

    func testCurrentReceiptTruthDoesNotInventCompensationAuthority() {
        let undoability = RuntimeAuthorityUndoability.notUndoable(
            reason: .missingTypedCompensationContract
        )
        XCTAssertEqual(
            undoability,
            .notUndoable(reason: .missingTypedCompensationContract)
        )
    }

    func testSourceHasOneNonSuspendingAuthorityTransactionAndNoForbiddenCalls() throws {
        let source = try String(contentsOf: sourceURL(), encoding: .utf8)
        XCTAssertTrue(source.contains("withAtomicCommitTransaction { database in"))
        XCTAssertTrue(source.contains("claimIdempotency(in: database"))
        XCTAssertTrue(source.contains("applyAggregateCAS("))
        XCTAssertTrue(source.contains("appendInTransaction("))
        XCTAssertTrue(source.contains("finalizeIdempotency("))
        XCTAssertTrue(source.contains("consumeConfirmation("))
        XCTAssertTrue(source.contains("Task.checkCancellation()"))
        XCTAssertFalse(source.contains("ProjectionMaterializer"))
        XCTAssertFalse(source.contains("ProjectionStoreSQLite"))
        XCTAssertFalse(source.contains("SearchStoreFTS"))
        XCTAssertFalse(source.contains("RuntimeTransactionCoordinator("))
        XCTAssertFalse(source.contains("EventStoreSQLite"))
        XCTAssertFalse(source.contains("RuntimeCommandMutationCommitter"))
        XCTAssertFalse(source.contains("EventKit"))
        XCTAssertFalse(source.contains("NotificationCenter"))
        XCTAssertFalse(source.contains("try?"))
    }

    func testTransactionOrderKeepsFinalizationBeforeConfirmationAndNoCancellationAfterReturn() throws {
        let source = try String(contentsOf: sourceURL(), encoding: .utf8)
        let claim = try XCTUnwrap(source.range(of: "claimIdempotency(in: database"))
        let cas = try XCTUnwrap(source.range(of: "applyAggregateCAS("))
        let event = try XCTUnwrap(source.range(of: "appendInTransaction("))
        let receipt = try XCTUnwrap(source.range(of: "persistReceipt(receipt"))
        let final = try XCTUnwrap(source.range(of: "finalizeIdempotency("))
        let consume = try XCTUnwrap(source.range(of: "consumeConfirmation("))
        XCTAssertLessThan(claim.lowerBound, cas.lowerBound)
        XCTAssertLessThan(cas.lowerBound, event.lowerBound)
        XCTAssertLessThan(event.lowerBound, receipt.lowerBound)
        XCTAssertLessThan(receipt.lowerBound, final.lowerBound)
        XCTAssertLessThan(final.lowerBound, consume.lowerBound)
    }

    func testErrorsRemainRedacted() {
        let privateValues = ["secret title", "/private/store/path", "capture.private.123"]
        for error in [
            RuntimeAtomicCommitError.malformedPreparation,
            .privacyMismatch,
            .stalePreparation,
            .eventQuarantined,
            .migrationRequired(expected: 3, actual: 1),
            .corruptAuthority,
        ] {
            for value in privateValues {
                XCTAssertFalse(error.description.contains(value))
            }
        }
    }

    func testEveryInjectedPhaseAndCancellationRollBackEveryAuthorityArtifact() async throws {
        for phase in RuntimeAtomicCommitPhase.allCases {
            let failureDatabase = try await makeStagedDatabase(label: "fault-\(phase.rawValue)")
            let preparation = try await makeCapturePreparation()
            do {
                _ = try await commit(
                    preparation,
                    database: failureDatabase,
                    failAfterPhase: phase
                )
                XCTFail("Expected phase fault \(phase)")
            } catch let error as RuntimeAtomicCommitError {
                XCTAssertEqual(error, .injectedFailure(phase))
            }
            XCTAssertEqual(try await authoritySnapshot(failureDatabase), .empty)

            let cancellationDatabase = try await makeStagedDatabase(label: "cancel-\(phase.rawValue)")
            do {
                _ = try await commit(
                    preparation,
                    database: cancellationDatabase,
                    cancelAfterPhase: phase
                )
                XCTFail("Expected cancellation \(phase)")
            } catch is CancellationError {
            }
            XCTAssertEqual(try await authoritySnapshot(cancellationDatabase), .empty)
        }
    }

    func testExactReplayWritesNothingAndCollisionPreservesOriginal() async throws {
        let database = try await makeStagedDatabase(label: "replay")
        let original = try await makeCapturePreparation(title: "Original", idempotencyKey: "same-key")
        let first = try await commit(original, database: database)
        let afterFirst = try await authoritySnapshot(database)
        let replay = try await commit(original, database: database)

        XCTAssertEqual(replay, first)
        XCTAssertEqual(try await authoritySnapshot(database), afterFirst)

        let collision = try await makeCapturePreparation(
            commandID: "command-collision",
            title: "Different semantics",
            idempotencyKey: "same-key"
        )
        do {
            _ = try await commit(collision, database: database)
            XCTFail("Expected semantic collision")
        } catch let error as CanonicalRuntimeTransactionError {
            XCTAssertEqual(error, .idempotencyCollision)
        }
        XCTAssertEqual(try await authoritySnapshot(database), afterFirst)
    }

    func testHistoricalReplayAllowsCurrentAggregateToAdvanceAndWritesNothing() async throws {
        let database = try await makeStagedDatabase(label: "historical-replay")
        let creation = try await makeCapturePreparation()
        let original = try await commit(creation, database: database)
        let update = try await makeCapturePreparation(
            commandID: "command-after-original",
            action: .markWaiting,
            target: AmbitionsCommandTarget(captureID: "capture-1"),
            expectedRevision: .exact(0),
            snapshot: RuntimePreparationSnapshot(
                aggregateRevisions: [RuntimePreparationAggregateReference(
                    family: .capture,
                    objectID: try RuntimeDomainObjectID(validating: "capture-1")
                ): .exact(0)],
                cursors: [], privacy: .standard
            )
        )
        _ = try await commit(update, database: database)
        let afterUpdate = try await authoritySnapshot(database)

        let historicalReplay = try await commit(creation, database: database)

        XCTAssertEqual(historicalReplay, original)
        XCTAssertEqual(try await authoritySnapshot(database), afterUpdate)
        let aggregate = try await database.query(
            "SELECT revision FROM runtime_aggregates WHERE aggregate_kind = 'capture' AND aggregate_id = 'capture-1'"
        )
        XCTAssertEqual(aggregate.first?.value(named: "revision"), .integer(1))
    }

    func testSameRevisionChecksumValidPayloadMutationIsRejected() async throws {
        let database = try await makeStagedDatabase(label: "same-revision-mutation")
        let creation = try await makeCapturePreparation()
        _ = try await commit(creation, database: database)
        let historical = try await captureState(database)
        let mutated = RuntimeCanonicalAggregateState(
            aggregate: historical.aggregate,
            revision: historical.revision,
            lifecycle: .active,
            transition: .update,
            commandPayload: capturePayload(action: .routeCommitment),
            changedObjectIDs: historical.changedObjectIDs
        )
        try await replaceCaptureState(mutated, database: database)
        do {
            _ = try await commit(creation, database: database)
            XCTFail("Expected same-revision state mutation rejection")
        } catch let error as RuntimeAtomicCommitError {
            XCTAssertEqual(error, .corruptAuthority)
        }
    }

    func testAdvancedRowWithoutExactSemanticEventIsRejected() async throws {
        let database = try await makeStagedDatabase(label: "advanced-without-event")
        let creation = try await makeCapturePreparation()
        _ = try await commit(creation, database: database)
        let historical = try await captureState(database)
        let advanced = RuntimeCanonicalAggregateState(
            aggregate: historical.aggregate,
            revision: 1,
            lifecycle: .active,
            transition: .update,
            commandPayload: capturePayload(action: .markWaiting),
            changedObjectIDs: historical.changedObjectIDs
        )
        try await replaceCaptureState(advanced, database: database)
        do {
            _ = try await commit(creation, database: database)
            XCTFail("Expected missing exact-revision event rejection")
        } catch let error as RuntimeAtomicCommitError {
            XCTAssertEqual(error, .corruptAuthority)
        }
    }

    func testAdvancedRowWithMismatchedEventFactsIsRejected() async throws {
        let database = try await makeStagedDatabase(label: "advanced-mismatched-event")
        let creation = try await makeCapturePreparation()
        _ = try await commit(creation, database: database)
        let update = try await makeCapturePreparation(
            commandID: "command-valid-update",
            action: .markWaiting,
            target: AmbitionsCommandTarget(captureID: "capture-1"),
            expectedRevision: .exact(0),
            snapshot: RuntimePreparationSnapshot(
                aggregateRevisions: [RuntimePreparationAggregateReference(
                    family: .capture,
                    objectID: try RuntimeDomainObjectID(validating: "capture-1")
                ): .exact(0)],
                cursors: [], privacy: .standard
            )
        )
        _ = try await commit(update, database: database)
        let live = try await captureState(database)
        let mismatched = RuntimeCanonicalAggregateState(
            aggregate: live.aggregate,
            revision: live.revision,
            lifecycle: live.lifecycle,
            transition: live.transition,
            commandPayload: capturePayload(action: .routeCommitment),
            changedObjectIDs: live.changedObjectIDs
        )
        try await replaceCaptureState(mismatched, database: database)
        do {
            _ = try await commit(creation, database: database)
            XCTFail("Expected event-fact mismatch rejection")
        } catch let error as RuntimeAtomicCommitError {
            XCTAssertEqual(error, .corruptAuthority)
        }
    }

    func testQuarantineOnlyPathRollsBackClaimAggregateAndQuarantine() async throws {
        let database = try await makeStagedDatabase(label: "quarantine")
        let preparation = try await makeCapturePreparation()
        do {
            _ = try await commit(
                preparation,
                database: database,
                semanticEventBytesOverride: Data("{".utf8)
            )
            XCTFail("Expected quarantined event to reject authority")
        } catch let error as RuntimeAtomicCommitError {
            XCTAssertEqual(error, .eventQuarantined)
        }
        XCTAssertEqual(try await authoritySnapshot(database), .empty)
    }

    func testConfirmationRemainsReusableAfterRollbackAndIsConsumedWithLinkedCommit() async throws {
        let database = try await makeStagedDatabase(label: "confirmation")
        let preparation = try await makeReminderPreparation()
        let confirmation = try approvedConfirmation(for: preparation)
        do {
            _ = try await commit(
                preparation,
                confirmation: confirmation,
                database: database,
                failAfterPhase: .idempotencyFinalized
            )
            XCTFail("Expected rollback before confirmation consumption")
        } catch let error as RuntimeAtomicCommitError {
            XCTAssertEqual(error, .injectedFailure(.idempotencyFinalized))
        }
        XCTAssertEqual(try await authoritySnapshot(database), .empty)

        let committed = try await commit(
            preparation,
            confirmation: confirmation,
            database: database
        )
        let replay = try await commit(
            preparation,
            confirmation: confirmation,
            database: database
        )
        XCTAssertEqual(replay, committed)
        let links = try await database.query(
            """
            SELECT r.terminal_event_sequence AS receipt_event,
                   o.terminal_event_sequence AS operation_event,
                   c.terminal_event_sequence AS confirmation_event,
                   e.sequence AS semantic_event
            FROM runtime_commit_receipts r
            JOIN runtime_pending_external_operations o ON o.receipt_id = r.receipt_id
            JOIN runtime_confirmation_consumptions c ON c.command_id = r.command_id
            JOIN runtime_semantic_events e ON e.sequence = r.terminal_event_sequence
            """
        )
        XCTAssertEqual(links.count, 1)
        XCTAssertEqual(links[0].value(named: "receipt_event"), links[0].value(named: "semantic_event"))
        XCTAssertEqual(links[0].value(named: "operation_event"), links[0].value(named: "semantic_event"))
        XCTAssertEqual(links[0].value(named: "confirmation_event"), links[0].value(named: "semantic_event"))
        for table in [
            "runtime_commit_receipts", "runtime_commit_projection_invalidations",
            "runtime_pending_external_operations",
        ] {
            let checksums = try await database.query("SELECT payload, payload_checksum FROM \(table)")
            XCTAssertFalse(checksums.isEmpty)
            for row in checksums {
                guard case let .blob(payload)? = row.value(named: "payload"),
                      case let .text(checksum)? = row.value(named: "payload_checksum") else {
                    return XCTFail("Expected artifact checksum")
                }
                XCTAssertTrue(RuntimeStoreManifestCodec.isSHA256Hex(checksum))
                XCTAssertEqual(LocalRuntimeStorageChecksum.sha256Hex(for: payload), checksum)
            }
        }
    }

    func testActorSerializedTaskGroupAndRestartedIdenticalSubmissionsReturnExactOutcome() async throws {
        let database = try await makeStagedDatabase(label: "concurrent")
        let preparation = try await makeCapturePreparation()
        let outcomes = try await withThrowingTaskGroup(of: RuntimeAtomicCommitFinalOutcome.self) { group in
            for _ in 0..<24 {
                group.addTask {
                    try await database.transaction(.immediate) { database in
                        try CanonicalRuntimeStore.atomicCommitInTransaction(
                            preparation: preparation,
                            confirmation: nil,
                            submittedAt: Self.now,
                            database: database
                        )
                    }
                }
            }
            return try await group.reduce(into: []) { $0.append($1) }
        }
        XCTAssertTrue(outcomes.dropFirst().allSatisfy { $0 == outcomes[0] })
        let beforeRestart = try await authoritySnapshot(database)
        let restarted = try SQLiteDatabase(
            url: database.databaseURL,
            configuration: SQLiteConfiguration(openMode: .existingOnly)
        )
        XCTAssertEqual(try await commit(preparation, database: restarted), outcomes[0])
        XCTAssertEqual(try await authoritySnapshot(restarted), beforeRestart)
    }

    func testExactCASReadsChecksummedStateAndAdvancesZeroToOne() async throws {
        let database = try await makeStagedDatabase(label: "cas")
        _ = try await commit(try await makeCapturePreparation(), database: database)
        let update = try await makeCapturePreparation(
            commandID: "command-update",
            action: .markWaiting,
            target: AmbitionsCommandTarget(captureID: "capture-1"),
            expectedRevision: .exact(0),
            snapshot: RuntimePreparationSnapshot(
                aggregateRevisions: [RuntimePreparationAggregateReference(
                    family: .capture,
                    objectID: try RuntimeDomainObjectID(validating: "capture-1")
                ): .exact(0)],
                cursors: [],
                privacy: .standard
            )
        )
        _ = try await commit(update, database: database)
        let aggregate = try await database.query(
            "SELECT revision, payload, payload_checksum FROM runtime_aggregates WHERE aggregate_kind = 'capture' AND aggregate_id = 'capture-1'"
        )
        XCTAssertEqual(aggregate.first?.value(named: "revision"), .integer(1))
        guard case let .blob(bytes)? = aggregate.first?.value(named: "payload"),
              case let .text(checksum)? = aggregate.first?.value(named: "payload_checksum") else {
            return XCTFail("Expected checksummed state")
        }
        XCTAssertEqual(LocalRuntimeStorageChecksum.sha256Hex(for: bytes), checksum)
        XCTAssertEqual(try RuntimeCanonicalAggregateStateCodec().decode(bytes).revision, 1)
    }

    func testCommitAfterTombstoneRejectsBothStoredLifecycleAndDurableTombstoneAuthority() async throws {
        let database = try await makeStagedDatabase(label: "commit-after-tombstone")
        _ = try await commit(try await makeCapturePreparation(), database: database)
        let reference = RuntimePreparationAggregateReference(
            family: .capture,
            objectID: try RuntimeDomainObjectID(validating: "capture-1")
        )
        let archive = try await makeCapturePreparation(
            commandID: "command-archive",
            action: .archive,
            target: AmbitionsCommandTarget(captureID: "capture-1"),
            expectedRevision: .exact(0),
            snapshot: RuntimePreparationSnapshot(
                aggregateRevisions: [reference: .exact(0)],
                cursors: [], privacy: .standard
            )
        )
        _ = try await commit(archive, database: database)

        func attemptedUpdate(_ commandID: String) async throws -> RuntimePreparation {
            try await makeCapturePreparation(
                commandID: commandID,
                action: .markWaiting,
                target: AmbitionsCommandTarget(captureID: "capture-1"),
                expectedRevision: .exact(1),
                snapshot: RuntimePreparationSnapshot(
                    aggregateRevisions: [reference: .exact(1)],
                    cursors: [], privacy: .standard
                )
            )
        }
        do {
            _ = try await commit(try await attemptedUpdate("command-after-tombstoned-state"), database: database)
            XCTFail("A non-restore write must not advance tombstoned aggregate state")
        } catch let error as RuntimeAtomicCommitError {
            XCTAssertEqual(error, .corruptAuthority)
        }

        let forgedActive = RuntimeCanonicalAggregateState(
            aggregate: RuntimeSemanticAggregate(
                kind: .capture,
                id: try RuntimeAggregateID(validating: "capture-1")
            ),
            revision: 1,
            lifecycle: .active,
            transition: .update,
            commandPayload: capturePayload(action: .markWaiting),
            changedObjectIDs: [try RuntimeDomainObjectID(validating: "capture-1")]
        )
        try await replaceCaptureState(forgedActive, database: database)
        do {
            _ = try await commit(try await attemptedUpdate("command-after-durable-tombstone"), database: database)
            XCTFail("A durable tombstone must block a forged active aggregate row")
        } catch let error as RuntimeAtomicCommitError {
            XCTAssertEqual(error, .corruptAuthority)
        }
        let events = try await database.query("SELECT COUNT(*) AS count FROM runtime_semantic_events")
        XCTAssertEqual(events.first?.value(named: "count"), .integer(2))
    }

    func testReminderDeleteAndCaptureArchiveKeepLinkedGoalAsReadOnlyDependency() async throws {
        let reminderDatabase = try await makeStagedDatabase(label: "reminder-linked-goal")
        let reminderCreate = try await makeReminderPreparation()
        _ = try await commit(
            reminderCreate,
            confirmation: try approvedConfirmation(for: reminderCreate),
            database: reminderDatabase
        )
        let goalReference = RuntimePreparationAggregateReference(
            family: .goal,
            objectID: try RuntimeDomainObjectID(validating: "goal-1")
        )
        let reminderReference = RuntimePreparationAggregateReference(
            family: .reminder,
            objectID: try RuntimeDomainObjectID(validating: "reminder-1")
        )
        try await seedAggregate(
            goalReference,
            payload: reminderCreate.command.typedPayload,
            database: reminderDatabase
        )
        let deleteCommand = AmbitionsCommand(
            id: "command-reminder-delete",
            source: .time,
            typedPayload: .reminder(ReminderCommand(
                action: .delete,
                target: AmbitionsCommandTarget(goalID: "goal-1", timeID: "reminder-1"),
                content: RuntimeCommandContent(AmbitionsCommandPayload(title: "Delete reminder"))
            )),
            expectedRevision: .exact(0),
            createdAt: DomainTimestamp.string(from: Self.now)
        )
        let delete = try await prepared(
            deleteCommand,
            snapshot: RuntimePreparationSnapshot(
                aggregateRevisions: [goalReference: .exact(0), reminderReference: .exact(0)],
                cursors: [], privacy: .standard
            ),
            proposedID: "unused-reminder-delete"
        )
        XCTAssertEqual(delete.decision.writeSet.transitions.map(\.aggregate), [reminderReference])
        _ = try await commit(
            delete,
            confirmation: try approvedConfirmation(for: delete),
            database: reminderDatabase
        )
        let reminderRows = try await reminderDatabase.query(
            "SELECT aggregate_kind, revision FROM runtime_aggregates ORDER BY aggregate_kind"
        )
        XCTAssertEqual(reminderRows.map { $0.value(named: "aggregate_kind") }, [.text("goal"), .text("reminder")])
        XCTAssertEqual(reminderRows.map { $0.value(named: "revision") }, [.integer(0), .integer(1)])

        let archiveDatabase = try await makeStagedDatabase(label: "archive-linked-goal")
        _ = try await commit(try await makeCapturePreparation(), database: archiveDatabase)
        try await seedAggregate(
            goalReference,
            payload: capturePayload(action: .archive),
            database: archiveDatabase
        )
        let captureReference = RuntimePreparationAggregateReference(
            family: .capture,
            objectID: try RuntimeDomainObjectID(validating: "capture-1")
        )
        let archive = try await makeCapturePreparation(
            commandID: "command-linked-archive",
            action: .archive,
            target: AmbitionsCommandTarget(goalID: "goal-1", captureID: "capture-1"),
            expectedRevision: .exact(0),
            snapshot: RuntimePreparationSnapshot(
                aggregateRevisions: [goalReference: .exact(0), captureReference: .exact(0)],
                cursors: [], privacy: .standard
            )
        )
        XCTAssertEqual(archive.decision.writeSet.transitions.map(\.aggregate), [captureReference])
        _ = try await commit(archive, database: archiveDatabase)
        let archiveRows = try await archiveDatabase.query(
            "SELECT aggregate_kind, revision FROM runtime_aggregates ORDER BY aggregate_kind"
        )
        XCTAssertEqual(archiveRows.map { $0.value(named: "aggregate_kind") }, [.text("capture"), .text("goal")])
        XCTAssertEqual(archiveRows.map { $0.value(named: "revision") }, [.integer(1), .integer(0)])
    }

    func testStableMultiAggregateCASUsesEachBoundTransitionRevision() async throws {
        let database = try await makeStagedDatabase(label: "multi-cas")
        let preparation = try explicitMultiAggregatePreparation(
            try await makeStepPreparation()
        )
        try await seedStepAggregates(for: preparation.command.typedPayload, database: database)
        _ = try await commit(preparation, database: database)
        let rows = try await database.query(
            "SELECT aggregate_kind, aggregate_id, revision FROM runtime_aggregates WHERE aggregate_id IN ('goal-1', 'step-1') ORDER BY aggregate_kind, aggregate_id"
        )
        XCTAssertEqual(rows.map { $0.value(named: "aggregate_kind") }, [.text("goal"), .text("step")])
        XCTAssertEqual(rows.map { $0.value(named: "aggregate_id") }, [.text("goal-1"), .text("step-1")])
        XCTAssertEqual(rows.map { $0.value(named: "revision") }, [.integer(1), .integer(1)])
    }

    func testSameRawIDCrossFamilyCommitWritesOneEventAndReplaysAtomically() async throws {
        let database = try await makeStagedDatabase(label: "cross-family-one-event")
        let shared = try RuntimeDomainObjectID(validating: "shared-family-object")
        let capture = RuntimePreparationAggregateReference(family: .capture, objectID: shared)
        let goal = RuntimePreparationAggregateReference(family: .goal, objectID: shared)
        let basePreparation = try await makeCapturePreparation(
            commandID: "command-cross-family-one-event",
            action: .attachToGoal,
            target: AmbitionsCommandTarget(goalID: shared.rawValue, captureID: shared.rawValue),
            expectedRevision: .exact(0),
            snapshot: RuntimePreparationSnapshot(
                aggregateRevisions: [capture: .exact(0), goal: .exact(0)],
                cursors: [],
                privacy: .standard
            )
        )
        let preparation = try withExplicitWrites(
            basePreparation,
            withExplicitWrites: [capture, goal]
        )
        try await seedSameRawCrossFamilyAggregates(
            id: shared,
            payload: preparation.command.typedPayload,
            database: database
        )

        _ = try await commit(preparation, database: database)

        let rows = try await database.query(
            "SELECT aggregate_kind, aggregate_id, revision FROM runtime_aggregates ORDER BY aggregate_kind, aggregate_id"
        )
        XCTAssertEqual(rows.map { $0.value(named: "aggregate_kind") }, [.text("capture"), .text("goal")])
        XCTAssertEqual(rows.map { $0.value(named: "aggregate_id") }, [.text(shared.rawValue), .text(shared.rawValue)])
        XCTAssertEqual(rows.map { $0.value(named: "revision") }, [.integer(1), .integer(1)])
        let events = try await database.query(
            "SELECT source_bytes FROM runtime_semantic_events WHERE command_id = ?",
            bindings: [.text(preparation.commandID.rawValue)]
        )
        XCTAssertEqual(events.count, 1)
        guard case let .blob(bytes)? = events.first?.value(named: "source_bytes") else {
            return XCTFail("Expected one canonical event")
        }
        let decoded = try RuntimeSemanticEventCodec().decode(bytes).event
        XCTAssertEqual(decoded.mutation.primaryAggregate, RuntimeSemanticAggregate(
            kind: .capture,
            id: try RuntimeAggregateID(validating: shared.rawValue)
        ))
        XCTAssertEqual(decoded.mutation.aggregateTransitions.map(\.aggregate.kind), [.capture, .goal])
        let replay = try await database.transaction(.immediate) { database in
            try RuntimeCanonicalReplayEngine.replayInTransaction(database: database)
        }
        guard case let .complete(reconstruction) = replay else {
            return XCTFail("Expected complete atomic replay")
        }
        XCTAssertEqual(reconstruction.aggregates.map(\.state.aggregate.kind), [.capture, .goal])
    }

    func testSameRevisionMultiAggregateReplayBindsCompleteCommandEventChain() async throws {
        let database = try await makeStagedDatabase(label: "multi-replay-chain")
        let preparation = try explicitMultiAggregatePreparation(
            try await makeStepPreparation()
        )
        try await seedStepAggregates(for: preparation.command.typedPayload, database: database)
        let original = try await commit(preparation, database: database)
        let beforeReplay = try await authoritySnapshot(database)

        let replay = try await commit(preparation, database: database)

        XCTAssertEqual(replay, original)
        XCTAssertEqual(try await authoritySnapshot(database), beforeReplay)
        let events = try await database.query(
            """
            SELECT sequence, event_id, aggregate_kind, aggregate_id,
                   canonical_revision, causation_event_id, event_hash, source_bytes
            FROM runtime_semantic_events
            WHERE command_id = ?
            ORDER BY sequence
            """,
            bindings: [.text(preparation.commandID.rawValue)]
        )
        XCTAssertEqual(events.count, 1)
        XCTAssertEqual(events[0].value(named: "aggregate_kind"), .text("step"))
        XCTAssertEqual(events[0].value(named: "aggregate_id"), .text("step-1"))
        XCTAssertEqual(events[0].value(named: "canonical_revision"), .integer(1))
        XCTAssertEqual(events[0].value(named: "event_id"), .text("event.command-step"))
        XCTAssertEqual(events[0].value(named: "causation_event_id"), .null)
        guard case let .blob(sourceBytes)? = events[0].value(named: "source_bytes") else {
            return XCTFail("Expected canonical semantic event")
        }
        let decoded = try RuntimeSemanticEventCodec().decode(sourceBytes).event
        XCTAssertEqual(
            decoded.mutation.aggregateTransitions.map(\.aggregate),
            [
                RuntimeSemanticAggregate(kind: .goal, id: try RuntimeAggregateID(validating: "goal-1")),
                RuntimeSemanticAggregate(kind: .step, id: try RuntimeAggregateID(validating: "step-1")),
            ]
        )
        XCTAssertEqual(decoded.mutation.primaryAggregate?.id.rawValue, "step-1")
        XCTAssertEqual(
            events[0].value(named: "sequence"),
            .integer(Int64(original.receipt.lineage.eventSequence))
        )
        XCTAssertEqual(
            events[0].value(named: "event_id"),
            .text(original.receipt.lineage.eventID.rawValue)
        )
        XCTAssertEqual(
            events[0].value(named: "event_hash"),
            .text(original.receipt.lineage.eventHash)
        )
    }

    func testImmutableJournalAndExplicitPrefixVerificationRejectHistoricalSourceTampering() async throws {
        let database = try await makeStagedDatabase(label: "append-corrupt-middle-source")
        _ = try await commit(try await makeCapturePreparation(), database: database)
        func update(_ commandID: String, _ revision: UInt64, _ action: CaptureCommand.Action) async throws -> RuntimePreparation {
            let reference = RuntimePreparationAggregateReference(
                family: .capture,
                objectID: try RuntimeDomainObjectID(validating: "capture-1")
            )
            return try await makeCapturePreparation(
                commandID: commandID,
                action: action,
                target: AmbitionsCommandTarget(captureID: "capture-1"),
                expectedRevision: .exact(revision),
                snapshot: RuntimePreparationSnapshot(
                    aggregateRevisions: [reference: .exact(revision)],
                    cursors: [], privacy: .standard
                )
            )
        }
        _ = try await commit(try await update("command-middle-1", 0, .markWaiting), database: database)
        _ = try await commit(try await update("command-middle-2", 1, .routeCommitment), database: database)
        let rows = try await database.query(
            "SELECT sequence, source_bytes FROM runtime_semantic_events ORDER BY sequence"
        )
        XCTAssertEqual(rows.count, 3)
        guard case let .integer(sequence)? = rows[1].value(named: "sequence"),
              case var .blob(sourceBytes)? = rows[1].value(named: "source_bytes"),
              sourceBytes.isEmpty == false else {
            return XCTFail("Expected middle semantic event source")
        }
        let immutableTrigger = try XCTUnwrap(
            CanonicalRuntimeSemanticEventSchemaPlan.statements.first {
                $0.contains("CREATE TRIGGER runtime_semantic_events_immutable_update")
            }
        )
        let triggerBeforeBypass = try await database.query(
            "SELECT name FROM sqlite_schema WHERE type = 'trigger' AND name = 'runtime_semantic_events_immutable_update'"
        )
        XCTAssertEqual(triggerBeforeBypass.count, 1)
        do {
            try await database.execute(
                "UPDATE runtime_semantic_events SET source_bytes = ? WHERE sequence = ?",
                bindings: [.blob(sourceBytes), .integer(sequence)]
            )
            XCTFail("The immutable journal trigger must reject ordinary historical mutation")
        } catch {}
        try await database.execute("DROP TRIGGER runtime_semantic_events_immutable_update")
        let triggerDuringBypass = try await database.query(
            "SELECT name FROM sqlite_schema WHERE type = 'trigger' AND name = 'runtime_semantic_events_immutable_update'"
        )
        XCTAssertTrue(triggerDuringBypass.isEmpty)
        sourceBytes[sourceBytes.startIndex] ^= 0xff
        try await database.execute(
            "UPDATE runtime_semantic_events SET source_bytes = ?, source_digest = ? WHERE sequence = ?",
            bindings: [
                .blob(sourceBytes),
                .text(LocalRuntimeStorageChecksum.sha256Hex(for: sourceBytes)),
                .integer(sequence),
            ]
        )
        try await database.execute(immutableTrigger)
        let triggerAfterBypass = try await database.query(
            "SELECT name FROM sqlite_schema WHERE type = 'trigger' AND name = 'runtime_semantic_events_immutable_update'"
        )
        XCTAssertEqual(triggerAfterBypass.count, 1)
        do {
            _ = try await database.transaction(.deferred) { database in
                try CanonicalRuntimeSemanticEventStore.verifiedSourceChainDigestThrough(
                    3,
                    database: database
                )
            }
            XCTFail("Explicit replay/checkpoint/retention prefix verification must reject tampered source")
        } catch {}
    }

    func testUnboundMixedRevisionWriteSetFailsInsteadOfGuessing() async throws {
        let database = try await makeStagedDatabase(label: "mixed-revision")
        let original = try explicitMultiAggregatePreparation(
            try await makeStepPreparation()
        )
        try await seedStepAggregates(for: original.command.typedPayload, database: database)
        let transitions = original.decision.writeSet.transitions.enumerated().map { index, value in
            RuntimeObjectTransitionIntent(
                aggregate: value.aggregate,
                expectedRevision: index == 0 ? .exact(0) : .exact(1),
                transition: value.transition
            )
        }
        let writeSet = RuntimeMutationWriteSet(
            transitions: transitions,
            events: original.decision.writeSet.events,
            projectionInvalidations: original.decision.writeSet.projectionInvalidations,
            receiptIntentID: original.decision.writeSet.receiptIntentID,
            rollbackIntentID: original.decision.writeSet.rollbackIntentID,
            externalEffect: original.decision.writeSet.externalEffect
        )
        let decision = RuntimeReducerDecision(
            family: original.decision.family,
            action: original.decision.action,
            disposition: original.decision.disposition,
            readSet: original.decision.readSet,
            writeSet: writeSet,
            confirmationScope: original.decision.confirmationScope,
            reason: original.decision.reason,
            recovery: original.decision.recovery
        )
        let payloadDigest = try XCTUnwrap(RuntimePreparationDigest.value(original.command.typedPayload))
        let decisionDigest = try XCTUnwrap(RuntimePreparationDigest.decision(
            commandPayloadDigest: payloadDigest,
            decision: decision,
            preparationID: original.preparationID
        ))
        let mixed = RuntimePreparation(
            preparationID: original.preparationID,
            command: original.command,
            commandID: original.commandID,
            commandFingerprint: original.commandFingerprint,
            commandVersion: original.commandVersion,
            decision: decision,
            decisionDigest: decisionDigest,
            authorization: original.authorization,
            confirmationRequest: original.confirmationRequest,
            issuedAt: original.issuedAt,
            expiresAt: original.expiresAt,
            schemaVersion: original.schemaVersion
        )
        let before = try await authoritySnapshot(database)
        do {
            _ = try await commit(mixed, database: database)
            XCTFail("Expected unbound mixed revision rejection")
        } catch let error as RuntimeAtomicCommitError {
            XCTAssertEqual(error, .stalePreparation)
        }
        XCTAssertEqual(try await authoritySnapshot(database), before)
    }

    func testCorruptStoredAggregateChecksumFailsBeforeCASAndPreservesEvidence() async throws {
        let database = try await makeStagedDatabase(label: "corrupt-checksum")
        _ = try await commit(try await makeCapturePreparation(), database: database)
        try await database.execute(
            "UPDATE runtime_aggregates SET payload_checksum = ? WHERE aggregate_kind = 'capture' AND aggregate_id = 'capture-1'",
            bindings: [.text(String(repeating: "0", count: 64))]
        )
        let before = try await authoritySnapshot(database)
        let update = try await makeCapturePreparation(
            commandID: "command-corrupt-update",
            action: .markWaiting,
            target: AmbitionsCommandTarget(captureID: "capture-1"),
            expectedRevision: .exact(0),
            snapshot: RuntimePreparationSnapshot(
                aggregateRevisions: [RuntimePreparationAggregateReference(
                    family: .capture,
                    objectID: try RuntimeDomainObjectID(validating: "capture-1")
                ): .exact(0)],
                cursors: [], privacy: .standard
            )
        )
        do {
            _ = try await commit(update, database: database)
            XCTFail("Expected corrupt authority")
        } catch let error as RuntimeAtomicCommitError {
            XCTAssertEqual(error, .corruptAuthority)
        }
        XCTAssertEqual(try await authoritySnapshot(database), before)
        let preserved = try await database.query(
            "SELECT payload_checksum FROM runtime_aggregates WHERE aggregate_kind = 'capture' AND aggregate_id = 'capture-1'"
        )
        XCTAssertEqual(preserved.first?.value(named: "payload_checksum"), .text(String(repeating: "0", count: 64)))
    }

    func testFinalReplayRejectsChecksumValidButStructurallyCorruptBytesWithoutWriting() async throws {
        let database = try await makeStagedDatabase(label: "corrupt-final")
        let preparation = try await makeCapturePreparation()
        _ = try await commit(preparation, database: database)
        let before = try await authoritySnapshot(database)
        let rows = try await database.query(
            "SELECT final_result_payload FROM runtime_command_idempotency"
        )
        guard case var .blob(payload)? = rows.first?.value(named: "final_result_payload"),
              payload.isEmpty == false else { return XCTFail("Expected finalized bytes") }
        payload[payload.startIndex] ^= 0xff
        try await database.execute(
            "UPDATE runtime_command_idempotency SET final_result_payload = ?, final_result_checksum = ?",
            bindings: [
                .blob(payload),
                .text(LocalRuntimeStorageChecksum.sha256Hex(for: payload)),
            ]
        )
        do {
            _ = try await commit(preparation, database: database)
            XCTFail("Expected corrupt finalized replay")
        } catch let error as RuntimeAtomicCommitError {
            XCTAssertEqual(error, .corruptAuthority)
        }
        XCTAssertEqual(try await authoritySnapshot(database), before)
        let preserved = try await database.query("SELECT final_result_payload FROM runtime_command_idempotency")
        XCTAssertEqual(preserved.first?.value(named: "final_result_payload"), .blob(payload))
    }

    func testSQLiteFaultMappingIsTypedAndRedacted() {
        XCTAssertEqual(
            RuntimeAtomicCommitFailureMapping.reason(
                LocalRuntimeStorageError.canonicalStorageFull(operation: "atomic")
            ),
            .storageFull
        )
        XCTAssertEqual(
            RuntimeAtomicCommitFailureMapping.reason(
                LocalRuntimeStorageError.canonicalIOFailure(operation: "atomic")
            ),
            .storageIO
        )
        XCTAssertEqual(
            RuntimeAtomicCommitFailureMapping.reason(
                LocalRuntimeStorageError.canonicalSQLiteFailure(operation: "atomic", code: 5, extendedCode: 5)
            ),
            .storageBusy
        )
    }

    private func sourceURL() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("Ambitions/Core/LocalRuntimeOS/Transactions/RuntimeAtomicCommitCoordinator.swift")
    }

    private func commit(
        _ preparation: RuntimePreparation,
        confirmation: RuntimeMutationConfirmation? = nil,
        database: SQLiteDatabase,
        failAfterPhase: RuntimeAtomicCommitPhase? = nil,
        cancelAfterPhase: RuntimeAtomicCommitPhase? = nil,
        semanticEventBytesOverride: Data? = nil
    ) async throws -> RuntimeAtomicCommitFinalOutcome {
        try await database.transaction(.immediate) { database in
            try CanonicalRuntimeStore.atomicCommitInTransaction(
                preparation: preparation,
                confirmation: confirmation,
                submittedAt: Self.now,
                failAfterPhase: failAfterPhase,
                cancelAfterPhase: cancelAfterPhase,
                semanticEventBytesOverride: semanticEventBytesOverride,
                database: database
            )
        }
    }

    private func makeStagedDatabase(label: String) async throws -> SQLiteDatabase {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("runtime-t09-\(label)-\(UUID().uuidString)", isDirectory: true)
        let database = try SQLiteDatabase(url: directory.appendingPathComponent("Runtime.sqlite"))
        try await database.transaction(.exclusive) { database in
            for statement in CanonicalRuntimeStore.schemaStatements {
                try database.execute(statement)
            }
            for statement in CanonicalRuntimeCommitSchemaPlan.stagedIntegratedStatements {
                try database.execute(statement)
            }
            try database.execute(
                "INSERT INTO runtime_store_metadata(singleton_id, schema_version, generation_id, created_at_ms) VALUES (1, 3, 'staged-t09', 0)"
            )
            try database.execute("PRAGMA user_version = 3")
        }
        return database
    }

    private func makeCapturePreparation(
        commandID: String = "command-create",
        title: String = "Capture",
        idempotencyKey: String? = nil,
        action: CaptureCommand.Action = .quickCapture(externalCreation: nil),
        target: AmbitionsCommandTarget = AmbitionsCommandTarget(),
        expectedRevision: RuntimeExpectedRevision = .absent,
        snapshot: RuntimePreparationSnapshot = .empty(privacy: .standard)
    ) async throws -> RuntimePreparation {
        let command = AmbitionsCommand(
            id: commandID,
            source: .capture,
            typedPayload: .capture(CaptureCommand(
                action: action,
                target: target,
                content: RuntimeCommandContent(AmbitionsCommandPayload(title: title))
            )),
            expectedRevision: expectedRevision,
            idempotencyKey: CommandIdempotencyKey(idempotencyKey ?? commandID),
            createdAt: DomainTimestamp.string(from: Self.now)
        )
        return try await prepared(command, snapshot: snapshot, proposedID: "capture-1")
    }

    private func capturePayload(action: CaptureCommand.Action) -> RuntimeCommandPayload {
        .capture(CaptureCommand(
            action: action,
            target: AmbitionsCommandTarget(captureID: "capture-1"),
            content: RuntimeCommandContent(AmbitionsCommandPayload(title: "Mutated"))
        ))
    }

    private func captureState(_ database: SQLiteDatabase) async throws -> RuntimeCanonicalAggregateState {
        let rows = try await database.query(
            "SELECT payload FROM runtime_aggregates WHERE aggregate_kind = 'capture' AND aggregate_id = 'capture-1'"
        )
        guard case let .blob(bytes)? = rows.first?.value(named: "payload") else {
            throw SnapshotFailure.invalidCount
        }
        return try RuntimeCanonicalAggregateStateCodec().decode(bytes)
    }

    private func replaceCaptureState(
        _ state: RuntimeCanonicalAggregateState,
        database: SQLiteDatabase
    ) async throws {
        let bytes = try RuntimeCanonicalAggregateStateCodec().encode(state)
        try await database.execute(
            "UPDATE runtime_aggregates SET revision = ?, payload = ?, payload_checksum = ? WHERE aggregate_kind = 'capture' AND aggregate_id = 'capture-1'",
            bindings: [
                .integer(Int64(state.revision)), .blob(bytes),
                .text(LocalRuntimeStorageChecksum.sha256Hex(for: bytes)),
            ]
        )
    }

    private func makeReminderPreparation() async throws -> RuntimePreparation {
        let command = AmbitionsCommand(
            id: "command-reminder",
            source: .time,
            typedPayload: .reminder(ReminderCommand(
                action: .create,
                target: AmbitionsCommandTarget(),
                content: RuntimeCommandContent(AmbitionsCommandPayload(title: "Remember"))
            )),
            expectedRevision: .absent,
            createdAt: DomainTimestamp.string(from: Self.now)
        )
        return try await prepared(command, snapshot: .empty(privacy: .standard), proposedID: "reminder-1")
    }

    private func makeStepPreparation() async throws -> RuntimePreparation {
        let goalID = try RuntimeDomainObjectID(validating: "goal-1")
        let stepID = try RuntimeDomainObjectID(validating: "step-1")
        let command = AmbitionsCommand(
            id: "command-step",
            source: .today,
            typedPayload: .step(StepCommand(
                action: .complete,
                target: AmbitionsCommandTarget(goalID: goalID.rawValue, stepID: stepID.rawValue),
                content: RuntimeCommandContent(AmbitionsCommandPayload(title: "Complete"))
            )),
            expectedRevision: .exact(0),
            createdAt: DomainTimestamp.string(from: Self.now)
        )
        return try await prepared(
            command,
            snapshot: RuntimePreparationSnapshot(
                aggregateRevisions: [
                    RuntimePreparationAggregateReference(family: .goal, objectID: goalID): .exact(0),
                    RuntimePreparationAggregateReference(family: .step, objectID: stepID): .exact(0),
                ],
                cursors: [], privacy: .standard
            ),
            proposedID: "unused-step-proposal"
        )
    }

    private func explicitMultiAggregatePreparation(
        _ base: RuntimePreparation
    ) throws -> RuntimePreparation {
        try withExplicitWrites(
            base,
            withExplicitWrites: base.decision.readSet.objects.map(\.aggregate)
        )
    }

    private func withExplicitWrites(
        _ base: RuntimePreparation,
        withExplicitWrites aggregates: [RuntimePreparationAggregateReference]
    ) throws -> RuntimePreparation {
        let transitions = try aggregates.map { aggregate in
            guard let dependency = base.decision.readSet.objects.first(where: {
                $0.aggregate == aggregate
            }) else {
                throw RuntimeAtomicCommitError.malformedPreparation
            }
            return RuntimeObjectTransitionIntent(
                aggregate: aggregate,
                expectedRevision: dependency.expectedRevision,
                transition: base.decision.writeSet.transitions.first(where: {
                    $0.aggregate == aggregate
                })?.transition ?? .update
            )
        }
        let writeSet = RuntimeMutationWriteSet(
            transitions: transitions,
            events: base.decision.writeSet.events,
            projectionInvalidations: base.decision.writeSet.projectionInvalidations,
            receiptIntentID: base.decision.writeSet.receiptIntentID,
            rollbackIntentID: base.decision.writeSet.rollbackIntentID,
            externalEffect: base.decision.writeSet.externalEffect
        )
        let decision = RuntimeReducerDecision(
            family: base.decision.family,
            action: base.decision.action,
            disposition: base.decision.disposition,
            readSet: base.decision.readSet,
            writeSet: writeSet,
            confirmationScope: base.decision.confirmationScope,
            reason: base.decision.reason,
            recovery: base.decision.recovery
        )
        let payloadDigest = try XCTUnwrap(RuntimePreparationDigest.value(base.command.typedPayload))
        let decisionDigest = try XCTUnwrap(RuntimePreparationDigest.decision(
            commandPayloadDigest: payloadDigest,
            decision: decision,
            preparationID: base.preparationID
        ))
        return RuntimePreparation(
            preparationID: base.preparationID,
            command: base.command,
            commandID: base.commandID,
            commandFingerprint: base.commandFingerprint,
            commandVersion: base.commandVersion,
            decision: decision,
            decisionDigest: decisionDigest,
            authorization: base.authorization,
            confirmationRequest: base.confirmationRequest,
            issuedAt: base.issuedAt,
            expiresAt: base.expiresAt,
            schemaVersion: base.schemaVersion
        )
    }

    private func seedStepAggregates(
        for payload: RuntimeCommandPayload,
        database: SQLiteDatabase
    ) async throws {
        try await database.transaction(.immediate) { database in
            for (family, id) in [
                (RuntimeSemanticAggregateKind.goal, "goal-1"),
                (RuntimeSemanticAggregateKind.step, "step-1"),
            ] {
                let state = RuntimeCanonicalAggregateState(
                    aggregate: RuntimeSemanticAggregate(
                        kind: family,
                        id: try RuntimeAggregateID(validating: id)
                    ),
                    revision: 0,
                    lifecycle: .active,
                    transition: .update,
                    commandPayload: payload,
                    changedObjectIDs: [try RuntimeDomainObjectID(validating: id)]
                )
                let bytes = try RuntimeCanonicalAggregateStateCodec().encode(state)
                try database.execute(
                    "INSERT INTO runtime_aggregates(aggregate_kind, aggregate_id, revision, payload_version, payload, payload_checksum) VALUES (?, ?, 0, 1, ?, ?)",
                    bindings: [
                        .text(family.rawValue), .text(id), .blob(bytes),
                        .text(LocalRuntimeStorageChecksum.sha256Hex(for: bytes)),
                    ]
                )
            }
        }
    }

    private func seedAggregate(
        _ reference: RuntimePreparationAggregateReference,
        payload: RuntimeCommandPayload,
        database: SQLiteDatabase
    ) async throws {
        let state = RuntimeCanonicalAggregateState(
            aggregate: RuntimeSemanticAggregate(
                kind: reference.family,
                id: try RuntimeAggregateID(validating: reference.objectID.rawValue)
            ),
            revision: 0,
            lifecycle: .active,
            transition: .update,
            commandPayload: payload,
            changedObjectIDs: [reference.objectID]
        )
        let bytes = try RuntimeCanonicalAggregateStateCodec().encode(state)
        try await database.execute(
            "INSERT INTO runtime_aggregates(aggregate_kind, aggregate_id, revision, payload_version, payload, payload_checksum) VALUES (?, ?, 0, 1, ?, ?)",
            bindings: [
                .text(reference.family.rawValue), .text(reference.objectID.rawValue),
                .blob(bytes), .text(LocalRuntimeStorageChecksum.sha256Hex(for: bytes)),
            ]
        )
    }

    private func seedSameRawCrossFamilyAggregates(
        id: RuntimeDomainObjectID,
        payload: RuntimeCommandPayload,
        database: SQLiteDatabase
    ) async throws {
        try await database.transaction(.immediate) { database in
            for family in [RuntimeSemanticAggregateKind.capture, .goal] {
                let state = RuntimeCanonicalAggregateState(
                    aggregate: RuntimeSemanticAggregate(
                        kind: family,
                        id: try RuntimeAggregateID(validating: id.rawValue)
                    ),
                    revision: 0,
                    lifecycle: .active,
                    transition: .update,
                    commandPayload: payload,
                    changedObjectIDs: [id]
                )
                let bytes = try RuntimeCanonicalAggregateStateCodec().encode(state)
                try database.execute(
                    "INSERT INTO runtime_aggregates(aggregate_kind, aggregate_id, revision, payload_version, payload, payload_checksum) VALUES (?, ?, 0, 1, ?, ?)",
                    bindings: [
                        .text(family.rawValue), .text(id.rawValue), .blob(bytes),
                        .text(LocalRuntimeStorageChecksum.sha256Hex(for: bytes)),
                    ]
                )
            }
        }
    }

    private func prepared(
        _ command: AmbitionsCommand,
        snapshot: RuntimePreparationSnapshot,
        proposedID: String
    ) async throws -> RuntimePreparation {
        guard let preparationID = RuntimePreparationID(rawValue: "preparation.\(command.id)"),
              let confirmationToken = RuntimeConfirmationToken(rawValue: "confirmation.\(command.id)"),
              let rollbackPlanID = RuntimeRollbackPlanID(rawValue: "rollback.\(command.id)") else {
            throw PreparationFailure(reason: .identityMismatch)
        }
        let context = RuntimePreparationContext(
            preparationID: preparationID,
            confirmationToken: confirmationToken,
            proposedObjectID: try RuntimeDomainObjectID(validating: proposedID),
            eventID: try RuntimeEventID(validating: "event.\(command.id)"),
            receiptID: try RuntimeReceiptID(validating: "receipt.\(command.id)"),
            rollbackPlanID: rollbackPlanID,
            externalOperationID: try RuntimeExternalOperationID(validating: "external.\(command.id)"),
            issuedAt: Self.now,
            expiresAt: Self.now.addingTimeInterval(600),
            boundary: .localOnly
        )
        let outcome = await RuntimeMutationPreparationService(
            reader: StagedPreparationReader(snapshot: snapshot)
        ).prepare(command, context: context)
        switch outcome {
        case let .ready(value), let .requiresConfirmation(value): return value
        case let .blocked(failure), let .unsupported(failure):
            throw PreparationFailure(reason: failure.reason)
        }
    }

    private func approvedConfirmation(for preparation: RuntimePreparation) throws -> RuntimeMutationConfirmation {
        let request = try XCTUnwrap(preparation.confirmationRequest)
        return RuntimeMutationConfirmation(
            token: request.token,
            preparationID: request.preparationID,
            commandID: request.commandID,
            commandFingerprint: request.commandFingerprint,
            actor: request.actor,
            scope: request.scope,
            target: request.target,
            decisionDigest: request.decisionDigest,
            decision: .approved,
            decidedAt: Self.now.addingTimeInterval(1)
        )
    }

    private func authoritySnapshot(_ database: SQLiteDatabase) async throws -> AuthoritySnapshot {
        var counts: [String: Int64] = [:]
        for table in AuthoritySnapshot.tables {
            let rows = try await database.query("SELECT COUNT(*) AS count FROM \(table)")
            guard case let .integer(count)? = rows.first?.value(named: "count") else {
                throw SnapshotFailure.invalidCount
            }
            counts[table] = count
        }
        let sequenceRows = try await database.query(
            "SELECT name, seq FROM sqlite_sequence WHERE name LIKE 'runtime_%' ORDER BY name"
        )
        let sequences = sequenceRows.reduce(into: [String: Int64]()) { result, row in
            guard case let .text(name)? = row.value(named: "name"),
                  case let .integer(sequence)? = row.value(named: "seq") else { return }
            result[name] = sequence
        }
        return AuthoritySnapshot(counts: counts, sequences: sequences)
    }

    private static let now = Date(timeIntervalSince1970: 1_800_000_000)
}

private struct StagedPreparationReader: RuntimePreparationReading {
    let snapshot: RuntimePreparationSnapshot
    func read(_ request: RuntimePreparationReadRequest) async throws -> RuntimePreparationSnapshot { snapshot }
}

private struct AuthoritySnapshot: Equatable {
    static let tables = [
        "runtime_aggregates", "runtime_command_idempotency", "runtime_semantic_events",
        "runtime_semantic_event_quarantine", "runtime_commit_receipts",
        "runtime_commit_projection_invalidations", "runtime_pending_external_operations",
        "runtime_confirmation_consumptions", "runtime_commit_tombstones",
    ]
    static let empty = AuthoritySnapshot(
        counts: Dictionary(uniqueKeysWithValues: tables.map { ($0, 0) }),
        sequences: [:]
    )
    let counts: [String: Int64]
    let sequences: [String: Int64]
}

private struct PreparationFailure: Error { let reason: RuntimeRecoveryReason }
private enum SnapshotFailure: Error { case invalidCount }
