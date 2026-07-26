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
        XCTAssertEqual(CanonicalRuntimeCommitSchemaPlan.currentWritableSchemaVersion, 6)
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
            XCTAssertEqual(error, .migrationRequired(expected: 6, actual: 1))
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
            .externalOperationsPersisted, .receiptCorePersisted,
            .receiptHistoryPersisted, .compensationDispositionPersisted,
            .receiptGraphAuthenticated, .compensationConsumed, .idempotencyFinalized,
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

    func testCurrentReceiptTruthCarriesTypedNoncompensableEvidence() {
        let evidence = RuntimeIrreversibilityEvidence(
            version: 1,
            permanence: .currentRuntimeUnsupported,
            reason: .missingPriorSemanticValue,
            commandFamily: "capture",
            commandAction: "route_commitment"
        )
        let undoability = RuntimeAuthorityUndoability.noncompensable(evidence)
        XCTAssertEqual(
            undoability,
            .noncompensable(evidence)
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

    func testPersistedReplaySourceUsesBoundedLatestReceiptAuthorityWithoutJournalAccumulation() throws {
        let source = try String(contentsOf: sourceURL(), encoding: .utf8)
        XCTAssertFalse(source.contains("verifiedSemanticEventRecords"))
        XCTAssertFalse(source.contains("records: [CanonicalRuntimeSemanticEventRecord]"))
        XCTAssertTrue(source.contains(
            "ORDER BY terminal_event_sequence DESC LIMIT 1"
        ))
        XCTAssertTrue(source.contains(
            "terminal_event_sequence = ? LIMIT 2"
        ))
        XCTAssertTrue(source.contains(
            "RuntimeCommittedReceiptAuthority.authenticatePersistedCore("
        ))
    }

    func testTransactionOrderKeepsReceiptChildrenBeforeFinalizationAndNoCancellationAfterReturn() throws {
        let source = try String(contentsOf: sourceURL(), encoding: .utf8)
        let claim = try XCTUnwrap(source.range(of: "claimIdempotency(in: database"))
        let cas = try XCTUnwrap(source.range(of: "applyAggregateCAS("))
        let event = try XCTUnwrap(source.range(of: "appendInTransaction("))
        let receipt = try XCTUnwrap(source.range(of: "persistReceipt(receipt"))
        let final = try XCTUnwrap(source.range(of: "finalizeIdempotency("))
        let consume = try XCTUnwrap(source.range(of: "consumeConfirmation("))
        let core = try XCTUnwrap(source.range(of: "RuntimeCommittedReceiptAuthority.persist("))
        XCTAssertLessThan(claim.lowerBound, cas.lowerBound)
        XCTAssertLessThan(cas.lowerBound, event.lowerBound)
        XCTAssertLessThan(event.lowerBound, receipt.lowerBound)
        XCTAssertLessThan(receipt.lowerBound, consume.lowerBound)
        XCTAssertLessThan(consume.lowerBound, core.lowerBound)
        XCTAssertLessThan(core.lowerBound, final.lowerBound)
        XCTAssertLessThan(consume.lowerBound, final.lowerBound)
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

    func testHistoricalReplayIsIndependentOfLargeUnrelatedJournalPrefix() async throws {
        let database = try await makeStagedDatabase(label: "bounded-historical-replay")
        for index in 0 ... CanonicalRuntimeSemanticEventStore.maximumPageLimit {
            _ = try await commit(
                try await makeCapturePreparation(
                    commandID: "command-unrelated-prefix-\(index)",
                    proposedID: "capture-unrelated-prefix-\(index)"
                ),
                database: database
            )
        }
        let creation = try await makeCapturePreparation(
            commandID: "command-bounded-replay-source",
            proposedID: "capture-bounded-replay-source"
        )
        let original = try await commit(creation, database: database)
        let aggregate = RuntimePreparationAggregateReference(
            family: .capture,
            objectID: try RuntimeDomainObjectID(validating: "capture-bounded-replay-source")
        )
        _ = try await commit(
            try await makeCapturePreparation(
                commandID: "command-bounded-replay-successor",
                action: .markWaiting,
                target: AmbitionsCommandTarget(captureID: "capture-bounded-replay-source"),
                expectedRevision: .exact(0),
                snapshot: RuntimePreparationSnapshot(
                    aggregateRevisions: [aggregate: .exact(0)],
                    cursors: [],
                    privacy: .standard
                ),
                proposedID: "unused-bounded-replay-proposal"
            ),
            database: database
        )
        let beforeReplay = try await authoritySnapshot(database)

        let replay = try await commit(creation, database: database)

        XCTAssertEqual(replay, original)
        XCTAssertEqual(try await authoritySnapshot(database), beforeReplay)
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
                   c.receipt_id AS confirmation_receipt,
                   c.consumed_at_ms AS confirmation_time,
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
        XCTAssertEqual(
            links[0].value(named: "confirmation_receipt"),
            .text(committed.receipt.facts.receiptID.rawValue)
        )
        XCTAssertEqual(
            links[0].value(named: "confirmation_time"),
            .integer(try RuntimeSemanticEventHashing.milliseconds(committed.receipt.facts.committedAt))
        )
        let graph = try await database.transaction(.deferred) { database in
            var budget = RuntimeReceiptDecodedByteBudget(
                maximumBytes: RuntimeCommittedReceiptReadBounds.maximumAccessBudgetBytes
            )
            try RuntimeCommittedReceiptAuthority.loadAuthenticatedGraph(
                receiptID: committed.receipt.facts.receiptID,
                budget: &budget,
                database: database
            )
        }
        XCTAssertEqual(graph.confirmation?.receiptID, committed.receipt.facts.receiptID)
        XCTAssertEqual(graph.confirmation?.token, confirmation.token)
        XCTAssertEqual(graph.confirmation?.decisionDigest, preparation.decisionDigest)
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

    func testConfirmationAuthorityCorruptionBlocksReceiptHistoryEligibilityAndReplay() async throws {
        let corruptions = [
            "receipt", "preparation", "command", "event", "token", "digest", "time", "absent",
        ]
        for corruption in corruptions {
            let database = try await makeStagedDatabase(label: "confirmation-corrupt-\(corruption)")
            let preparation = try await makeReminderPreparation()
            let confirmation = try approvedConfirmation(for: preparation)
            let outcome = try await commit(
                preparation,
                confirmation: confirmation,
                database: database
            )
            try await database.execute("PRAGMA foreign_keys = OFF")
            if corruption == "absent" {
                try await database.execute(
                    "DROP TRIGGER runtime_confirmation_consumptions_immutable_delete"
                )
                try await database.execute("DELETE FROM runtime_confirmation_consumptions")
            } else {
                try await database.execute(
                    "DROP TRIGGER runtime_confirmation_consumptions_immutable_update"
                )
                let mutation: (String, SQLiteBinding) = switch corruption {
                case "receipt": ("receipt_id", .text("receipt.confirmation-corrupt"))
                case "preparation": ("preparation_id", .text("preparation.confirmation-corrupt"))
                case "command": ("command_id", .text("command.confirmation-corrupt"))
                case "event": ("terminal_event_sequence", .integer(
                    Int64(outcome.receipt.facts.lineage.eventSequence + 1_000)
                ))
                case "token": ("token", .text("confirmation.corrupt"))
                case "digest": ("decision_digest", .text(String(repeating: "d", count: 64)))
                case "time": ("consumed_at_ms", .integer(
                    try RuntimeSemanticEventHashing.milliseconds(Self.now) + 1
                ))
                default: throw SnapshotFailure.invalidCount
                }
                try await database.execute(
                    "UPDATE runtime_confirmation_consumptions SET \(mutation.0) = ?",
                    bindings: [mutation.1]
                )
            }
            try await database.execute("PRAGMA foreign_keys = ON")
            try await assertReceiptReadPathsAndReplayBlocked(
                outcome: outcome,
                preparation: preparation,
                confirmation: confirmation,
                expectedReason: .corruptReceiptCore,
                historyExpectedReason: .objectHistoryMismatch,
                database: database
            )
        }
    }

    func testConfirmedReceiptDoesNotBlockLaterUnconfirmedReceiptFinalization() async throws {
        let database = try await makeStagedDatabase(label: "confirmation-cross-receipt-isolation")
        let confirmedPreparation = try await makeReminderPreparation()
        _ = try await commit(
            confirmedPreparation,
            confirmation: try approvedConfirmation(for: confirmedPreparation),
            database: database
        )
        let unconfirmed = try await commit(
            try await makeCapturePreparation(),
            database: database
        )
        XCTAssertNil(unconfirmed.receipt.facts.confirmationToken)
        try await database.transaction(.deferred) { database in
            var budget = RuntimeReceiptDecodedByteBudget(
                maximumBytes: RuntimeCommittedReceiptReadBounds.maximumAccessBudgetBytes
            )
            let graph = try RuntimeCommittedReceiptAuthority.loadAuthenticatedGraph(
                receiptID: unconfirmed.receipt.facts.receiptID,
                budget: &budget,
                database: database
            )
            XCTAssertNil(graph.confirmation)
        }
    }

    func testConfirmationDuplicateExtraAndOrphanRowsAreRejectedByNormalizedAuthority() async throws {
        let database = try await makeStagedDatabase(label: "confirmation-normalized-rejections")
        let preparation = try await makeReminderPreparation()
        let confirmation = try approvedConfirmation(for: preparation)
        let outcome = try await commit(
            preparation,
            confirmation: confirmation,
            database: database
        )
        let exact = (
            receipt: outcome.receipt.facts.receiptID.rawValue,
            preparation: outcome.receipt.facts.preparationID.rawValue,
            command: outcome.receipt.facts.commandID.rawValue,
            event: Int64(outcome.receipt.facts.lineage.eventSequence)
        )
        let attempts: [(String, String, String, String, String, Int64)] = [
            ("duplicate-token", confirmation.token.rawValue, "receipt.orphan-token", "preparation.orphan-token", "command.orphan-token", 9_001),
            ("duplicate-receipt", "confirmation.duplicate-receipt", exact.receipt, "preparation.duplicate-receipt", "command.duplicate-receipt", 9_002),
            ("duplicate-preparation", "confirmation.duplicate-preparation", "receipt.duplicate-preparation", exact.preparation, "command.duplicate-preparation", 9_003),
            ("duplicate-command", "confirmation.duplicate-command", "receipt.duplicate-command", "preparation.duplicate-command", exact.command, 9_004),
            ("duplicate-event", "confirmation.duplicate-event", "receipt.duplicate-event", "preparation.duplicate-event", "command.duplicate-event", exact.event),
            ("extra-owner-row", "confirmation.extra-owner", exact.receipt, exact.preparation, exact.command, exact.event),
            ("orphan-row", "confirmation.orphan", "receipt.orphan", "preparation.orphan", "command.orphan", 9_005),
        ]
        for (label, token, receiptID, preparationID, commandID, eventSequence) in attempts {
            do {
                try await database.execute(
                    """
                    INSERT INTO runtime_confirmation_consumptions(
                        token, receipt_id, preparation_id, command_id,
                        decision_digest, terminal_event_sequence, consumed_at_ms
                    ) VALUES (?, ?, ?, ?, ?, ?, ?)
                    """,
                    bindings: [
                        .text(token), .text(receiptID), .text(preparationID), .text(commandID),
                        .text(preparation.decisionDigest.rawValue), .integer(eventSequence),
                        .integer(try RuntimeSemanticEventHashing.milliseconds(Self.now)),
                    ]
                )
                XCTFail("\(label) must be rejected")
            } catch let error as SQLiteError {
                XCTAssertEqual(error.primaryCode, 19, label)
            }
        }
        let rows = try await database.query(
            "SELECT COUNT(*) AS count FROM runtime_confirmation_consumptions"
        )
        XCTAssertEqual(rows.first?.value(named: "count"), .integer(1))
    }

    func testRuntimeCommandFinalizationRequiresAnchorWhileExplicitNonreceiptScopeRemainsAllowed() async throws {
        let database = try await makeStagedDatabase(label: "missing-anchor-finalization")
        let finalPayload = Data("scope-final".utf8)
        let checksum = LocalRuntimeStorageChecksum.sha256Hex(for: finalPayload)
        for (scope, commandID) in [
            ("runtime.command", "command-missing-anchor"),
            ("fixture.nonreceipt", "command-nonreceipt-scope"),
        ] {
            try await database.execute(
                """
                INSERT INTO runtime_command_idempotency(
                    scope, idempotency_key, command_id, command_fingerprint,
                    claim_version, claim_payload, claimed_at_ms
                ) VALUES (?, ?, ?, ?, 1, ?, 0)
                """,
                bindings: [
                    .text(scope), .text("key.\(commandID)"), .text(commandID),
                    .text(String(repeating: "a", count: 64)), .blob(Data("claim".utf8)),
                ]
            )
        }
        do {
            try await database.execute(
                """
                UPDATE runtime_command_idempotency
                SET final_result_version = 1, final_result_payload = ?,
                    final_result_checksum = ?, finalized_at_ms = 0
                WHERE command_id = 'command-missing-anchor'
                """,
                bindings: [.blob(finalPayload), .text(checksum)]
            )
            XCTFail("runtime.command finalization must require exactly one complete receipt graph")
        } catch let error as SQLiteError {
            XCTAssertEqual(error.extendedCode, 1_811)
        }
        let nonreceipt = try await database.execute(
            """
            UPDATE runtime_command_idempotency
            SET final_result_version = 1, final_result_payload = ?,
                final_result_checksum = ?, finalized_at_ms = 0
            WHERE command_id = 'command-nonreceipt-scope'
            """,
            bindings: [.blob(finalPayload), .text(checksum)]
        )
        XCTAssertEqual(nonreceipt.changedRowCount, 1)
    }

    func testMinimalCommitAnchorTamperAndFutureVersionBlockEveryAuthorityConsumer() async throws {
        let mutations: [(label: String, column: String, value: SQLiteBinding, ignoresCheck: Bool)] = [
            ("receipt", "receipt_id", .text("receipt.anchor-corrupt"), false),
            ("preparation", "preparation_id", .text("preparation.anchor-corrupt"), false),
            ("command", "command_id", .text("command.anchor-corrupt"), false),
            ("terminal-sequence", "terminal_event_sequence", .integer(9_001), false),
            ("created-time", "created_at_ms", .integer(
                try RuntimeSemanticEventHashing.milliseconds(Self.now) + 1
            ), false),
            ("future-version", "receipt_version", .integer(
                Int64(runtimeCommitAnchorVersion + 1)
            ), true),
        ]
        for mutation in mutations {
            let database = try await makeStagedDatabase(label: "anchor-\(mutation.label)")
            let preparation = try await makeCapturePreparation()
            let outcome = try await commit(preparation, database: database)
            try await database.execute("DROP TRIGGER runtime_commit_receipts_immutable_update")
            try await database.execute("PRAGMA foreign_keys = OFF")
            if mutation.ignoresCheck {
                try await database.execute("PRAGMA ignore_check_constraints = ON")
            }
            let update = try await database.execute(
                "UPDATE runtime_commit_receipts SET \(mutation.column) = ? WHERE receipt_id = ?",
                bindings: [
                    mutation.value,
                    .text(outcome.receipt.facts.receiptID.rawValue),
                ]
            )
            XCTAssertEqual(update.changedRowCount, 1, mutation.label)
            if mutation.ignoresCheck {
                try await database.execute("PRAGMA ignore_check_constraints = OFF")
            }
            try await database.execute("PRAGMA foreign_keys = ON")

            try await assertReceiptReadPathsAndReplayBlocked(
                outcome: outcome,
                preparation: preparation,
                confirmation: nil,
                expectedReason: .corruptReceiptCore,
                historyExpectedReason: .objectHistoryMismatch,
                database: database
            )
        }
    }

    func testCompensationConsumptionIsPersistedAndAuthenticatedBeforeGraphPhase() throws {
        let source = try String(contentsOf: receiptAuthoritySourceURL(), encoding: .utf8)
        let insertion = try XCTUnwrap(source.range(of: "insertCompensationConsumption("))
        let authentication = try XCTUnwrap(source.range(of: "try authenticatePersistedCore("))
        XCTAssertLessThan(insertion.lowerBound, authentication.lowerBound)
        XCTAssertTrue(source.contains("allowedUnfinalizedCompensation"))
        XCTAssertTrue(source.contains("requireUnfinalizedConstructionEndpoint"))
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
            .integer(Int64(original.receipt.facts.lineage.eventSequence))
        )
        XCTAssertEqual(
            events[0].value(named: "event_id"),
            .text(original.receipt.facts.lineage.eventID.rawValue)
        )
        XCTAssertEqual(
            events[0].value(named: "event_hash"),
            .text(original.receipt.facts.lineage.eventHash)
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
            compensation: original.decision.writeSet.compensation,
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
        try await database.execute("DROP TRIGGER runtime_command_idempotency_seal_authority")
        let corruption = try await database.execute(
            "UPDATE runtime_command_idempotency SET final_result_payload = ?, final_result_checksum = ?",
            bindings: [
                .blob(payload),
                .text(LocalRuntimeStorageChecksum.sha256Hex(for: payload)),
            ]
        )
        XCTAssertEqual(corruption.changedRowCount, 1)
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

    func testCommittedV6ReceiptGraphRoundTripsAndRequiresConfirmation() async throws {
        let database = try await makeStagedDatabase(label: "receipt-round-trip")
        let outcome = try await commit(try await makeCapturePreparation(), database: database)
        let access = try await receiptAccess(
            for: [outcome.receipt],
            surface: .localInspection
        )

        let result = try await database.transaction(.deferred) { database in
            let core = try RuntimeCommittedReceiptAuthority.loadCore(
                receiptID: outcome.receipt.facts.receiptID,
                database: database
            )
            try RuntimeCommittedReceiptAuthority.authenticatePersistedCore(
                core,
                database: database
            )
            let eligibility = try CanonicalRuntimeStore.compensationEligibilityInTransaction(
                receiptID: core.facts.receiptID,
                access: access,
                at: Self.now,
                database: database
            )
            guard case let .plan(planID, _, _, _) = core.facts.compensation else {
                throw RuntimeAtomicCommitError.corruptAuthority
            }
            return (
                core,
                try RuntimeCommittedReceiptAuthority.loadPlan(
                    planID: planID,
                    database: database
                ),
                eligibility
            )
        }

        XCTAssertEqual(result.0, outcome.receipt)
        XCTAssertEqual(result.1.sourceReceiptID, outcome.receipt.facts.receiptID)
        XCTAssertEqual(result.1.targets.count, 1)
        XCTAssertEqual(result.2, .confirmationRequired)
        for table in [
            "runtime_committed_receipt_cores",
            "runtime_receipt_compensation_dispositions",
            "runtime_object_history",
            "runtime_receipt_object_links",
            "runtime_receipt_artifact_links",
            "runtime_receipt_retention_references",
            "runtime_compensation_plans",
            "runtime_compensation_plan_targets",
        ] {
            let rows = try await database.query("SELECT COUNT(*) AS count FROM \(table)")
            guard case let .integer(count)? = rows.first?.value(named: "count") else {
                return XCTFail("Expected normalized receipt authority count")
            }
            XCTAssertGreaterThan(count, 0, table)
        }
    }

    func testReceiptInsertTriggersRejectForgedArtifactsAndNonCreationTargets() async throws {
        let database = try await makeStagedDatabase(label: "receipt-insert-guards")
        let outcome = try await commit(try await makeCapturePreparation(), database: database)
        guard case let .plan(planID, _, _, _) = outcome.receipt.facts.compensation else {
            return XCTFail("Expected compensation plan")
        }
        do {
            _ = try await database.execute(
                """
                INSERT INTO runtime_receipt_artifact_links(
                    receipt_id, artifact_kind, artifact_id, artifact_digest, link_version
                ) VALUES (?, 'terminal_event', 'forged-event', ?, 1)
                """,
                bindings: [
                    .text(outcome.receipt.facts.receiptID.rawValue),
                    .text(String(repeating: "f", count: 64)),
                ]
            )
            XCTFail("A forged terminal artifact must be rejected at insertion")
        } catch {
        }
        do {
            _ = try await database.execute(
                """
                INSERT INTO runtime_compensation_plan_targets(
                    plan_id, family, object_id, source_prior_revision,
                    source_revision, source_transition_kind, required_current_revision,
                    required_lifecycle, source_state_digest, transition_kind, target_version
                ) VALUES (?, 'capture', 'forged-object', NULL, 1, 'create', 1,
                          'active', ?, 'tombstone', 1)
                """,
                bindings: [
                    .text(planID.rawValue),
                    .text(String(repeating: "e", count: 64)),
                ]
            )
            XCTFail("A target without source create history must be rejected at insertion")
        } catch {
        }
        let reminderPreparation = try await makeReminderPreparation()
        _ = try await commit(
            reminderPreparation,
            confirmation: try approvedConfirmation(for: reminderPreparation),
            database: database
        )
        let operationRows = try await database.query(
            "SELECT operation_id FROM runtime_pending_external_operations WHERE command_id = 'command-reminder'"
        )
        guard case let .text(operationID)? = operationRows.first?.value(named: "operation_id") else {
            return XCTFail("Expected reminder outbox authority")
        }
        do {
            _ = try await database.execute(
                """
                INSERT INTO runtime_compensation_plan_external_operations(
                    plan_id, operation_id, operation_version
                ) VALUES (?, ?, 1)
                """,
                bindings: [.text(planID.rawValue), .text(operationID)]
            )
            XCTFail("A plan must not claim another receipt's pending operation")
        } catch {
        }
    }

    func testFinalizedReceiptGraphRejectsAdditionalRowsAcrossEveryConstructionTable() async throws {
        var coveredTables = Set<String>()

        let captureDatabase = try await makeStagedDatabase(label: "receipt-finalized-insert-capture")
        _ = try await commit(try await makeCapturePreparation(), database: captureDatabase)
        let captureTables = [
            "runtime_semantic_events",
            "runtime_commit_receipts",
            "runtime_commit_projection_invalidations",
            "runtime_committed_receipt_cores",
            "runtime_receipt_compensation_dispositions",
            "runtime_receipt_object_links",
            "runtime_object_history",
            "runtime_receipt_artifact_links",
            "runtime_receipt_retention_references",
            "runtime_compensation_plans",
            "runtime_compensation_plan_targets",
        ]
        try await assertFinalizedReceiptGraphInsertRejected(
            tables: captureTables,
            database: captureDatabase
        )
        coveredTables.formUnion(captureTables)

        let reminderDatabase = try await makeStagedDatabase(label: "receipt-finalized-insert-reminder")
        let reminderPreparation = try await makeReminderPreparation()
        _ = try await commit(
            reminderPreparation,
            confirmation: try approvedConfirmation(for: reminderPreparation),
            database: reminderDatabase
        )
        let reminderTables = [
            "runtime_pending_external_operations",
            "runtime_confirmation_consumptions",
            "runtime_compensation_plan_external_operations",
        ]
        try await assertFinalizedReceiptGraphInsertRejected(
            tables: reminderTables,
            database: reminderDatabase
        )
        coveredTables.formUnion(reminderTables)

        let archiveDatabase = try await makeStagedDatabase(label: "receipt-finalized-insert-tombstone")
        _ = try await commit(try await makeCapturePreparation(), database: archiveDatabase)
        let captureReference = RuntimePreparationAggregateReference(
            family: .capture,
            objectID: try RuntimeDomainObjectID(validating: "capture-1")
        )
        _ = try await commit(
            try await makeCapturePreparation(
                commandID: "command-finalized-insert-archive",
                action: .archive,
                target: AmbitionsCommandTarget(captureID: "capture-1"),
                expectedRevision: .exact(0),
                snapshot: RuntimePreparationSnapshot(
                    aggregateRevisions: [captureReference: .exact(0)],
                    cursors: [],
                    privacy: .standard
                )
            ),
            database: archiveDatabase
        )
        let tombstoneTables = [
            "runtime_commit_tombstones",
            "runtime_object_tombstone_history",
        ]
        try await assertFinalizedReceiptGraphInsertRejected(
            tables: tombstoneTables,
            database: archiveDatabase
        )
        coveredTables.formUnion(tombstoneTables)

        let evidenceDatabase = try await makeStagedDatabase(label: "receipt-finalized-insert-evidence")
        _ = try await commit(try await makeCapturePreparation(), database: evidenceDatabase)
        _ = try await commit(
            try await makeCapturePreparation(
                commandID: "command-finalized-insert-evidence",
                action: .markWaiting,
                target: AmbitionsCommandTarget(captureID: "capture-1"),
                expectedRevision: .exact(0),
                snapshot: RuntimePreparationSnapshot(
                    aggregateRevisions: [captureReference: .exact(0)],
                    cursors: [],
                    privacy: .standard
                )
            ),
            database: evidenceDatabase
        )
        try await assertFinalizedReceiptGraphInsertRejected(
            tables: ["runtime_irreversibility_evidence"],
            database: evidenceDatabase
        )
        coveredTables.insert("runtime_irreversibility_evidence")

        XCTAssertEqual(
            coveredTables,
            CanonicalRuntimeCommittedReceiptSchemaPlan.postFinalizationInsertSealedTables
        )
        XCTAssertFalse(coveredTables.contains("runtime_compensation_consumptions"))
    }

    func testFinalizedNoConfirmationReceiptRejectsLateValidConfirmationConsumption() async throws {
        let database = try await makeStagedDatabase(label: "receipt-late-confirmation-consumption")
        let outcome = try await commit(try await makeCapturePreparation(), database: database)
        let existingRows = try await database.query(
            "SELECT COUNT(*) AS count FROM runtime_confirmation_consumptions"
        )
        XCTAssertEqual(existingRows.first?.value(named: "count"), .integer(0))

        do {
            _ = try await database.execute(
                """
                INSERT INTO runtime_confirmation_consumptions(
                    token, receipt_id, preparation_id, command_id, decision_digest,
                    terminal_event_sequence, consumed_at_ms
                ) VALUES (?, ?, ?, ?, ?, ?, ?)
                """,
                bindings: [
                    .text("confirmation.late.valid-shape"),
                    .text(outcome.receipt.facts.receiptID.rawValue),
                    .text(outcome.receipt.facts.preparationID.rawValue),
                    .text(outcome.receipt.facts.commandID.rawValue),
                    .text(String(repeating: "a", count: 64)),
                    .integer(Int64(outcome.receipt.facts.lineage.eventSequence)),
                    .integer(try RuntimeSemanticEventHashing.milliseconds(Self.now)),
                ]
            )
            XCTFail("A finalized no-confirmation receipt must reject a late confirmation row")
        } catch let error as SQLiteError {
            XCTAssertEqual(error.operation, .step)
            XCTAssertEqual(error.primaryCode, 19)
            XCTAssertEqual(error.extendedCode, 1_811)
        }
        let finalRows = try await database.query(
            "SELECT COUNT(*) AS count FROM runtime_confirmation_consumptions"
        )
        XCTAssertEqual(finalRows.first?.value(named: "count"), .integer(0))
    }

    func testFinalizedReceiptGraphRejectsMismatchedUnfinalizedCommandOwnerBypasses() async throws {
        let database = try await makeStagedDatabase(label: "receipt-mismatched-owner-insert")
        let outcome = try await commit(try await makeCapturePreparation(), database: database)
        let otherCommandID = "command-unfinalized-owner-bypass"
        let claimPayload = Data("unfinalized-claim".utf8)
        _ = try await database.execute(
            """
            INSERT INTO runtime_command_idempotency(
                scope, idempotency_key, command_id, command_fingerprint,
                claim_version, claim_payload, claimed_at_ms
            ) VALUES ('test', ?, ?, ?, 1, ?, 0)
            """,
            bindings: [
                .text("unfinalized-owner-bypass"),
                .text(otherCommandID),
                .text(String(repeating: "b", count: 64)),
                .blob(claimPayload),
            ]
        )
        let receiptInsert = {
            try await database.execute(
                """
                INSERT INTO runtime_commit_receipts(
                    receipt_id, preparation_id, command_id, terminal_event_sequence,
                    receipt_version, created_at_ms
                )
                SELECT 'receipt.owner-bypass', 'preparation.owner-bypass', ?,
                       terminal_event_sequence, receipt_version, created_at_ms
                FROM runtime_commit_receipts WHERE receipt_id = ?
                """,
                bindings: [
                    .text(otherCommandID),
                    .text(outcome.receipt.facts.receiptID.rawValue),
                ]
            )
        }
        do {
            _ = try await receiptInsert()
            XCTFail("Finalized terminal-event ownership must seal a mismatched receipt row")
        } catch let error as SQLiteError {
            XCTAssertEqual(error.extendedCode, 1_811)
        }
        try await database.execute(
            "DROP TRIGGER runtime_commit_receipts_reject_insert_after_finalization"
        )
        do {
            _ = try await receiptInsert()
            XCTFail("Commit receipt insertion must bind command and terminal event")
        } catch let error as SQLiteError {
            XCTAssertEqual(error.extendedCode, 1_811)
        }
        let operationPayload = Data("pending-operation".utf8)
        let pendingInsert = {
            try await database.execute(
                """
                INSERT INTO runtime_pending_external_operations(
                    operation_id, command_id, receipt_id, terminal_event_sequence,
                    operation_kind, status, operation_version, payload,
                    payload_checksum, attempt_count, updated_at_ms
                ) VALUES ('operation.owner-bypass', ?, ?, ?, 'reminder', 'pending',
                          1, ?, ?, 0, 0)
                """,
                bindings: [
                    .text(otherCommandID),
                    .text(outcome.receipt.facts.receiptID.rawValue),
                    .integer(Int64(outcome.receipt.facts.lineage.eventSequence)),
                    .blob(operationPayload),
                    .text(LocalRuntimeStorageChecksum.sha256Hex(for: operationPayload)),
                ]
            )
        }
        do {
            _ = try await pendingInsert()
            XCTFail("Finalized receipt/event ownership must seal a mismatched pending row")
        } catch let error as SQLiteError {
            XCTAssertEqual(error.extendedCode, 1_811)
        }
        try await database.execute(
            "DROP TRIGGER runtime_pending_external_operations_reject_insert_after_finalization"
        )
        do {
            _ = try await pendingInsert()
            XCTFail("Pending operation insertion must bind command, receipt, and terminal event")
        } catch let error as SQLiteError {
            XCTAssertEqual(error.extendedCode, 1_811)
        }

        let confirmationInsert = {
            try await database.execute(
                """
                INSERT INTO runtime_confirmation_consumptions(
                    token, receipt_id, preparation_id, command_id, decision_digest,
                    terminal_event_sequence, consumed_at_ms
                ) VALUES ('confirmation.owner-bypass', ?, ?, ?, ?, ?, 0)
                """,
                bindings: [
                    .text(outcome.receipt.facts.receiptID.rawValue),
                    .text(outcome.receipt.facts.preparationID.rawValue),
                    .text(otherCommandID),
                    .text(String(repeating: "c", count: 64)),
                    .integer(Int64(outcome.receipt.facts.lineage.eventSequence)),
                ]
            )
        }
        do {
            _ = try await confirmationInsert()
            XCTFail("Finalized terminal-event ownership must seal a mismatched confirmation row")
        } catch let error as SQLiteError {
            XCTAssertEqual(error.extendedCode, 1_811)
        }
        try await database.execute(
            "DROP TRIGGER runtime_confirmation_consumptions_reject_insert_after_finalization"
        )
        do {
            _ = try await confirmationInsert()
            XCTFail("Confirmation insertion must bind preparation, command, and terminal event")
        } catch let error as SQLiteError {
            XCTAssertEqual(error.extendedCode, 1_811)
        }

        let receiptRows = try await database.query(
            "SELECT COUNT(*) AS count FROM runtime_commit_receipts"
        )
        let pendingRows = try await database.query(
            "SELECT COUNT(*) AS count FROM runtime_pending_external_operations"
        )
        let confirmationRows = try await database.query(
            "SELECT COUNT(*) AS count FROM runtime_confirmation_consumptions"
        )
        XCTAssertEqual(receiptRows.first?.value(named: "count"), .integer(1))
        XCTAssertEqual(pendingRows.first?.value(named: "count"), .integer(0))
        XCTAssertEqual(confirmationRows.first?.value(named: "count"), .integer(0))
    }

    func testAuthenticatedReceiptQueryRejectsSemanticEventCoreFieldMismatches() async throws {
        let database = try await makeStagedDatabase(label: "event-core-parity")
        let outcome = try await commit(try await makeCapturePreparation(), database: database)
        let graph = try await database.transaction(.deferred) { database in
            var budget = RuntimeReceiptDecodedByteBudget(maximumBytes: 1_048_576)
            return try RuntimeCommittedReceiptAuthority.loadAuthenticatedGraph(
                receiptID: outcome.receipt.facts.receiptID,
                budget: &budget,
                database: database
            )
        }
        let original = graph.core
        let object = try XCTUnwrap(original.facts.objects.first)
        func alteredCore(
            privacy: RuntimeCommittedReceiptPrivacy? = nil,
            object: RuntimeCommittedReceiptObjectLink
        ) -> RuntimeCommittedReceiptCore {
            let facts = original.facts
            return RuntimeCommittedReceiptCore(
                facts: RuntimeCommittedReceiptCoreFacts(
                    version: facts.version,
                    receiptID: facts.receiptID,
                    preparationID: facts.preparationID,
                    commandID: facts.commandID,
                    lineage: facts.lineage,
                    correlationID: facts.correlationID,
                    outcome: facts.outcome,
                    committedAt: facts.committedAt,
                    privacy: privacy ?? facts.privacy,
                    objects: [object],
                    artifacts: facts.artifacts,
                    presentationFacts: facts.presentationFacts,
                    compensation: facts.compensation,
                    retention: facts.retention,
                    confirmationToken: facts.confirmationToken,
                    confirmationDecisionDigest: facts.confirmationDecisionDigest
                ),
                receiptDigest: original.receiptDigest
            )
        }
        let objectVariants = [
            RuntimeCommittedReceiptObjectLink(
                aggregate: object.aggregate, priorRevision: 0,
                terminalRevision: object.terminalRevision, lifecycle: object.lifecycle,
                transition: object.transition, stateDigest: object.stateDigest
            ),
            RuntimeCommittedReceiptObjectLink(
                aggregate: object.aggregate, priorRevision: object.priorRevision,
                terminalRevision: object.terminalRevision + 1, lifecycle: object.lifecycle,
                transition: object.transition, stateDigest: object.stateDigest
            ),
            RuntimeCommittedReceiptObjectLink(
                aggregate: object.aggregate, priorRevision: object.priorRevision,
                terminalRevision: object.terminalRevision, lifecycle: .tombstoned,
                transition: object.transition, stateDigest: object.stateDigest
            ),
            RuntimeCommittedReceiptObjectLink(
                aggregate: object.aggregate, priorRevision: object.priorRevision,
                terminalRevision: object.terminalRevision, lifecycle: object.lifecycle,
                transition: .update, stateDigest: object.stateDigest
            ),
            RuntimeCommittedReceiptObjectLink(
                aggregate: object.aggregate, priorRevision: object.priorRevision,
                terminalRevision: object.terminalRevision, lifecycle: object.lifecycle,
                transition: object.transition, stateDigest: String(repeating: "f", count: 64)
            ),
        ]
        let coreVariants = [
            alteredCore(
                privacy: RuntimeCommittedReceiptPrivacy(classification: .sensitive, localOnly: true),
                object: object
            ),
            alteredCore(
                privacy: RuntimeCommittedReceiptPrivacy(
                    classification: original.facts.privacy.classification,
                    localOnly: false
                ),
                object: object
            ),
        ] + objectVariants.map { alteredCore(object: $0) }
        for variant in coreVariants {
            XCTAssertThrowsError(try RuntimeCommittedReceiptAuthority.authenticateTerminalMutationParity(
                variant,
                eventEvidence: graph.eventEvidence
            ))
        }

        let plan = try await compensationPlan(for: outcome, database: database)
        let preparation = try await makeCompensationPreparation(
            commandID: "command-tombstone-parity",
            plan: plan
        )
        let compensated = try await commit(
            preparation,
            confirmation: try approvedConfirmation(for: preparation),
            database: database
        )
        let compensatedGraph = try await database.transaction(.deferred) { database in
            var budget = RuntimeReceiptDecodedByteBudget(maximumBytes: 1_048_576)
            return try RuntimeCommittedReceiptAuthority.loadAuthenticatedGraph(
                receiptID: compensated.receipt.facts.receiptID,
                budget: &budget,
                database: database
            )
        }
        let tombstonedObject = try XCTUnwrap(compensatedGraph.core.facts.objects.first)
        let tombstone = try XCTUnwrap(compensatedGraph.tombstones.first)
        let alteredTombstone = RuntimeCanonicalTombstoneDraft(
            objectID: tombstone.objectID,
            family: tombstone.family,
            terminalRevision: tombstone.terminalRevision,
            lineage: tombstone.lineage,
            authority: RuntimeCanonicalTombstoneAuthority(
                reason: .archived,
                predecessorDigest: tombstone.authority.predecessorDigest,
                retentionDisposition: tombstone.authority.retentionDisposition,
                recoveryDisposition: tombstone.authority.recoveryDisposition
            )
        )
        XCTAssertThrowsError(try RuntimeCommittedReceiptAuthority.authenticateTerminalTombstoneParity(
            object: tombstonedObject,
            draft: alteredTombstone,
            eventEvidence: compensatedGraph.eventEvidence
        ))
    }

    func testCreateCompensationCommitsOnceAndReplaysWithCausalLineage() async throws {
        let database = try await makeStagedDatabase(label: "compensation-once")
        let source = try await commit(try await makeCapturePreparation(), database: database)
        let plan = try await compensationPlan(for: source, database: database)
        let firstPreparation = try await makeCompensationPreparation(
            commandID: "command-compensate",
            plan: plan
        )
        let competingPreparation = try await makeCompensationPreparation(
            commandID: "command-compensate-competing",
            plan: plan
        )
        let first = try await commit(
            firstPreparation,
            confirmation: try approvedConfirmation(for: firstPreparation),
            database: database
        )
        let snapshotAfterFirst = try await authoritySnapshot(database)
        let replay = try await commit(
            firstPreparation,
            confirmation: try approvedConfirmation(for: firstPreparation),
            database: database
        )

        XCTAssertEqual(replay, first)
        XCTAssertEqual(try await authoritySnapshot(database), snapshotAfterFirst)
        do {
            _ = try await commit(
                competingPreparation,
                confirmation: try approvedConfirmation(for: competingPreparation),
                database: database
            )
            XCTFail("A compensation plan must be consumed only once")
        } catch let error as RuntimeAtomicCommitError {
            XCTAssertEqual(error, .stalePreparation)
        }
        let rows = try await database.query(
            """
            SELECT c.source_receipt_id, c.compensation_receipt_id,
                   e.causation_event_id, e.correlation_id
            FROM runtime_compensation_consumptions AS c
            JOIN runtime_committed_receipt_cores AS r
              ON r.receipt_id = c.compensation_receipt_id
            JOIN runtime_semantic_events AS e
              ON e.sequence = r.terminal_event_sequence
            """
        )
        XCTAssertEqual(rows.count, 1)
        XCTAssertEqual(rows[0].value(named: "source_receipt_id"), .text(source.receipt.facts.receiptID.rawValue))
        XCTAssertEqual(rows[0].value(named: "compensation_receipt_id"), .text(first.receipt.facts.receiptID.rawValue))
        XCTAssertEqual(rows[0].value(named: "causation_event_id"), .text(source.receipt.facts.lineage.eventID.rawValue))
        XCTAssertEqual(rows[0].value(named: "correlation_id"), .text(source.receipt.facts.correlationID.rawValue))
        let aggregate = try await captureState(database)
        XCTAssertEqual(aggregate.lifecycle, .tombstoned)
        XCTAssertEqual(aggregate.transition, .tombstone)
        let replayResult = try await database.transaction(.immediate) { database in
            try RuntimeCanonicalReplayEngine.replayInTransaction(database: database)
        }
        guard case let .complete(reconstruction) = replayResult,
              let replayed = reconstruction.aggregates.first(where: {
                  $0.state.aggregate.kind == .capture &&
                      $0.state.aggregate.id.rawValue == "capture-1"
              }) else {
            return XCTFail("Compensation must preserve canonical replay parity")
        }
        XCTAssertEqual(replayed.state, aggregate)
        XCTAssertTrue(reconstruction.tombstones.contains(where: {
            $0.aggregate.kind == .capture &&
                $0.aggregate.id.rawValue == "capture-1" &&
                $0.reason == .compensatedCreation
        }))
    }

    func testCompensationTargetsAreBoundedUniqueAndCancellationAwareAtEveryEntrySeam() async throws {
        let database = try await makeStagedDatabase(label: "compensation-target-bounds")
        let source = try await commit(try await makeCapturePreparation(), database: database)
        let plan = try await compensationPlan(for: source, database: database)
        let template = try XCTUnwrap(plan.targets.first)
        let oversizedTargets = try (0...RuntimeCompensationLimits.maximumTargets).map { index in
            RuntimeCompensationTargetExpectation(
                aggregate: RuntimeSemanticAggregate(
                    kind: .capture,
                    id: try RuntimeAggregateID(validating: index == 0 ? "capture-1" : "capture-bound-\(index)")
                ),
                sourcePriorRevision: nil,
                sourceRevision: template.sourceRevision,
                sourceTransition: .create,
                requiredCurrentRevision: template.requiredCurrentRevision,
                requiredLifecycle: .active,
                sourceStateDigest: template.sourceStateDigest,
                inverseTransition: .tombstone
            )
        }
        XCTAssertThrowsError(try RuntimeCommittedReceiptCodec.makePlan(
            planID: plan.planID,
            receiptID: plan.sourceReceiptID,
            lineage: plan.sourceLineage,
            correlationID: plan.sourceCorrelationID,
            action: plan.action,
            targets: oversizedTargets,
            externalOperationIDs: [],
            privacy: plan.privacy,
            policyVersion: plan.policyVersion,
            expiresAt: plan.expiresAt,
            requiresConfirmation: plan.requiresConfirmation
        ))
        XCTAssertThrowsError(try RuntimeCommittedReceiptCodec.makePlan(
            planID: plan.planID,
            receiptID: plan.sourceReceiptID,
            lineage: plan.sourceLineage,
            correlationID: plan.sourceCorrelationID,
            action: plan.action,
            targets: [template, template],
            externalOperationIDs: [],
            privacy: plan.privacy,
            policyVersion: plan.policyVersion,
            expiresAt: plan.expiresAt,
            requiresConfirmation: plan.requiresConfirmation
        ))

        let payload = RuntimeCompensationCommand(
            sourceReceiptID: plan.sourceReceiptID,
            planID: plan.planID,
            planDigest: plan.digest,
            sourceLineage: plan.sourceLineage,
            action: plan.action,
            targets: oversizedTargets,
            requiresConfirmation: plan.requiresConfirmation,
            target: plan.action.target,
            content: RuntimeCommandContent()
        )
        let command = AmbitionsCommand(
            id: "command-oversized-compensation",
            source: .reviews,
            typedPayload: .compensation(payload),
            expectedRevision: .exact(template.requiredCurrentRevision),
            idempotencyKey: CommandIdempotencyKey("command-oversized-compensation"),
            createdAt: DomainTimestamp.string(from: Self.now),
            privacy: plan.privacy.classification
        )
        XCTAssertEqual(AmbitionsCommandValidator().validate(command), .invalid)
        let duplicateCommand = AmbitionsCommand(
            id: "command-duplicate-compensation",
            source: .reviews,
            typedPayload: .compensation(RuntimeCompensationCommand(
                sourceReceiptID: plan.sourceReceiptID,
                planID: plan.planID,
                planDigest: plan.digest,
                sourceLineage: plan.sourceLineage,
                action: plan.action,
                targets: [template, template],
                requiresConfirmation: plan.requiresConfirmation,
                target: plan.action.target,
                content: RuntimeCommandContent()
            )),
            expectedRevision: .exact(template.requiredCurrentRevision),
            idempotencyKey: CommandIdempotencyKey("command-duplicate-compensation"),
            createdAt: DomainTimestamp.string(from: Self.now),
            privacy: plan.privacy.classification
        )
        XCTAssertEqual(AmbitionsCommandValidator().validate(duplicateCommand), .invalid)
        let reducerContext = RuntimePreparationContext(
            preparationID: try XCTUnwrap(RuntimePreparationID(rawValue: "preparation.target-bound")),
            confirmationToken: try XCTUnwrap(RuntimeConfirmationToken(rawValue: "confirmation.target-bound")),
            proposedObjectID: nil,
            eventID: try RuntimeEventID(validating: "event.target-bound"),
            receiptID: try RuntimeReceiptID(validating: "receipt.target-bound"),
            rollbackPlanID: try XCTUnwrap(RuntimeRollbackPlanID(rawValue: "rollback.target-bound")),
            externalOperationID: nil,
            issuedAt: Self.now,
            expiresAt: Self.now.addingTimeInterval(60),
            boundary: .localOnly
        )
        let reducerDecision = CompensationMutationReducer().reduce(RuntimeFeatureReducerInput(
            command: command,
            commandID: try RuntimeCommandID(validating: command.id),
            snapshot: .empty(privacy: plan.privacy.classification),
            context: reducerContext
        ))
        XCTAssertEqual(reducerDecision.disposition, .unsupported)
        let duplicateDecision = CompensationMutationReducer().reduce(RuntimeFeatureReducerInput(
            command: duplicateCommand,
            commandID: try RuntimeCommandID(validating: duplicateCommand.id),
            snapshot: .empty(privacy: plan.privacy.classification),
            context: reducerContext
        ))
        XCTAssertEqual(duplicateDecision.disposition, .unsupported)

        let cancellationTask = Task {
            CompensationMutationReducer().reduce(RuntimeFeatureReducerInput(
                command: command,
                commandID: try RuntimeCommandID(validating: command.id),
                snapshot: .empty(privacy: plan.privacy.classification),
                context: reducerContext
            ))
        }
        cancellationTask.cancel()
        let cancelled = try await cancellationTask.value
        XCTAssertEqual(cancelled.disposition, .blocked)
        XCTAssertEqual(cancelled.reason, .cancelled)
        let atomicSource = try String(contentsOf: sourceURL(), encoding: .utf8)
        XCTAssertTrue(atomicSource.contains(
            "command.targets.count <= RuntimeCompensationLimits.maximumTargets"
        ))
        XCTAssertTrue(atomicSource.contains("_ = try RuntimeCommandCodec().encode(preparation.command)"))
    }

    func testOrdinaryFinalizedReceiptCannotBeInsertedAsCompensationConsumption() async throws {
        let database = try await makeStagedDatabase(label: "ordinary-consumption-rejected")
        let source = try await commit(try await makeCapturePreparation(), database: database)
        let plan = try await compensationPlan(for: source, database: database)
        let ordinary = try await commit(try await makePrivateCapturePreparation(), database: database)
        do {
            _ = try await database.execute(
                """
                INSERT INTO runtime_compensation_consumptions(
                    plan_id, source_receipt_id, compensation_receipt_id,
                    compensation_command_id, terminal_event_sequence,
                    consumed_at_ms, consumption_version
                ) VALUES (?, ?, ?, ?, ?, ?, 1)
                """,
                bindings: [
                    .text(plan.planID.rawValue),
                    .text(source.receipt.facts.receiptID.rawValue),
                    .text(ordinary.receipt.facts.receiptID.rawValue),
                    .text(ordinary.receipt.facts.commandID.rawValue),
                    .integer(Int64(ordinary.receipt.facts.lineage.eventSequence)),
                    .integer(try RuntimeSemanticEventHashing.milliseconds(
                        ordinary.receipt.facts.committedAt
                    )),
                ]
            )
            XCTFail("An ordinary finalized receipt must never consume a compensation plan")
        } catch {
        }
    }

    func testForgedCompensationTypePlanAndRecursiveConsumptionNeverReportConsumed() async throws {
        let database = try await makeStagedDatabase(label: "forged-consumption-authentication")
        let source = try await commit(try await makeCapturePreparation(), database: database)
        let sourcePlan = try await compensationPlan(for: source, database: database)
        let ordinary = try await commit(try await makePrivateCapturePreparation(), database: database)
        let otherPlan = try await compensationPlan(for: ordinary, database: database)
        let preparation = try await makeCompensationPreparation(
            commandID: "command-authenticated-consumption",
            plan: sourcePlan
        )
        let compensation = try await commit(
            preparation,
            confirmation: try approvedConfirmation(for: preparation),
            database: database
        )
        XCTAssertEqual(
            try await eligibility(
                for: source.receipt.facts.receiptID,
                at: Self.now,
                database: database
            ),
            .consumed(compensationReceiptID: compensation.receipt.facts.receiptID)
        )

        try await database.execute("DROP TRIGGER runtime_compensation_consumptions_immutable_update")
        _ = try await database.execute(
            """
            UPDATE runtime_compensation_consumptions
            SET compensation_receipt_id = ?, compensation_command_id = ?,
                terminal_event_sequence = ?, consumed_at_ms = ?
            WHERE source_receipt_id = ?
            """,
            bindings: [
                .text(ordinary.receipt.facts.receiptID.rawValue),
                .text(ordinary.receipt.facts.commandID.rawValue),
                .integer(Int64(ordinary.receipt.facts.lineage.eventSequence)),
                .integer(try RuntimeSemanticEventHashing.milliseconds(
                    ordinary.receipt.facts.committedAt
                )),
                .text(source.receipt.facts.receiptID.rawValue),
                ]
        )
        guard case .sourceBlocked = try await eligibility(
            for: source.receipt.facts.receiptID,
            at: Self.now,
            database: database
        ) else {
            return XCTFail("Forged ordinary event type must not authenticate as consumed")
        }

        _ = try await database.execute(
            """
            UPDATE runtime_compensation_consumptions
            SET plan_id = ?, compensation_receipt_id = ?, compensation_command_id = ?,
                terminal_event_sequence = ?, consumed_at_ms = ?
            WHERE source_receipt_id = ?
            """,
            bindings: [
                .text(otherPlan.planID.rawValue),
                .text(compensation.receipt.facts.receiptID.rawValue),
                .text(compensation.receipt.facts.commandID.rawValue),
                .integer(Int64(compensation.receipt.facts.lineage.eventSequence)),
                .integer(try RuntimeSemanticEventHashing.milliseconds(
                    compensation.receipt.facts.committedAt
                )),
                .text(source.receipt.facts.receiptID.rawValue),
            ]
        )
        guard case .sourceBlocked = try await eligibility(
            for: source.receipt.facts.receiptID,
            at: Self.now,
            database: database
        ) else {
            return XCTFail("Mismatched plan authority must not authenticate as consumed")
        }

        _ = try await database.execute(
            "UPDATE runtime_compensation_consumptions SET plan_id = ? WHERE source_receipt_id = ?",
            bindings: [
                .text(sourcePlan.planID.rawValue),
                .text(source.receipt.facts.receiptID.rawValue),
            ]
        )
        try await database.execute("DROP TRIGGER runtime_compensation_consumptions_bind_causation")
        _ = try await database.execute(
            """
            INSERT INTO runtime_compensation_consumptions(
                plan_id, source_receipt_id, compensation_receipt_id,
                compensation_command_id, terminal_event_sequence,
                consumed_at_ms, consumption_version
            ) VALUES (?, ?, ?, ?, ?, ?, 1)
            """,
            bindings: [
                .text(otherPlan.planID.rawValue),
                .text(compensation.receipt.facts.receiptID.rawValue),
                .text(ordinary.receipt.facts.receiptID.rawValue),
                .text(ordinary.receipt.facts.commandID.rawValue),
                .integer(Int64(ordinary.receipt.facts.lineage.eventSequence)),
                .integer(try RuntimeSemanticEventHashing.milliseconds(
                    ordinary.receipt.facts.committedAt
                )),
            ]
        )
        let recursiveRows = try await database.query(
            """
            SELECT source_receipt_id FROM runtime_compensation_consumptions
            WHERE source_receipt_id = ?
            """,
            bindings: [.text(compensation.receipt.facts.receiptID.rawValue)]
        )
        XCTAssertEqual(recursiveRows.count, 1)
        XCTAssertEqual(
            recursiveRows.first?.value(named: "source_receipt_id"),
            .text(compensation.receipt.facts.receiptID.rawValue)
        )
        guard case .sourceBlocked = try await eligibility(
            for: source.receipt.facts.receiptID,
            at: Self.now,
            database: database
        ) else {
            return XCTFail("Recursive compensation consumption must be rejected without recursion")
        }
    }

    func testCompensationEligibilityDistinguishesExternalExpiredStaleAndConsumed() async throws {
        let pendingDatabase = try await makeStagedDatabase(label: "eligibility-pending")
        let reminderPreparation = try await makeReminderPreparation()
        let pendingSource = try await commit(
            reminderPreparation,
            confirmation: try approvedConfirmation(for: reminderPreparation),
            database: pendingDatabase
        )
        let pending = try await eligibility(
            for: pendingSource.receipt.facts.receiptID,
            at: Self.now,
            database: pendingDatabase
        )
        guard case let .pendingExternalWork(operationIDs) = pending else {
            return XCTFail("Expected pending external work")
        }
        XCTAssertEqual(operationIDs.count, 1)

        let expiredDatabase = try await makeStagedDatabase(label: "eligibility-expired")
        let expiredSource = try await commit(try await makeCapturePreparation(), database: expiredDatabase)
        XCTAssertEqual(
            try await eligibility(
                for: expiredSource.receipt.facts.receiptID,
                at: Self.now.addingTimeInterval(31 * 24 * 60 * 60),
                database: expiredDatabase
            ),
            .expired
        )

        let staleDatabase = try await makeStagedDatabase(label: "eligibility-stale")
        let staleSource = try await commit(try await makeCapturePreparation(), database: staleDatabase)
        let update = try await makeCapturePreparation(
            commandID: "command-after-offer",
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
        _ = try await commit(update, database: staleDatabase)
        XCTAssertEqual(
            try await eligibility(
                for: staleSource.receipt.facts.receiptID,
                at: Self.now,
                database: staleDatabase
            ),
            .stale
        )

        let consumedDatabase = try await makeStagedDatabase(label: "eligibility-consumed")
        let consumedSource = try await commit(try await makeCapturePreparation(), database: consumedDatabase)
        let consumedPlan = try await compensationPlan(for: consumedSource, database: consumedDatabase)
        let compensation = try await makeCompensationPreparation(
            commandID: "command-eligibility-consume",
            plan: consumedPlan
        )
        let compensationOutcome = try await commit(
            compensation,
            confirmation: try approvedConfirmation(for: compensation),
            database: consumedDatabase
        )
        XCTAssertEqual(
            try await eligibility(
                for: consumedSource.receipt.facts.receiptID,
                at: Self.now,
                database: consumedDatabase
            ),
            .consumed(compensationReceiptID: compensationOutcome.receipt.facts.receiptID)
        )
    }

    func testCompensationEligibilityTreatsAbsentAndValidAdvancedTargetsAsStale() async throws {
        let absentDatabase = try await makeStagedDatabase(label: "eligibility-target-absent")
        let absentSource = try await commit(
            try await makeCapturePreparation(),
            database: absentDatabase
        )
        let deletion = try await absentDatabase.execute(
            "DELETE FROM runtime_aggregates WHERE aggregate_kind = 'capture' AND aggregate_id = 'capture-1'"
        )
        XCTAssertEqual(deletion.changedRowCount, 1)
        XCTAssertEqual(
            try await eligibility(
                for: absentSource.receipt.facts.receiptID,
                at: Self.now,
                database: absentDatabase
            ),
            .stale
        )

        let advancedDatabase = try await makeStagedDatabase(label: "eligibility-target-advanced")
        let advancedSource = try await commit(
            try await makeCapturePreparation(),
            database: advancedDatabase
        )
        let reference = RuntimePreparationAggregateReference(
            family: .capture,
            objectID: try RuntimeDomainObjectID(validating: "capture-1")
        )
        _ = try await commit(
            try await makeCapturePreparation(
                commandID: "command-eligibility-target-advanced",
                action: .markWaiting,
                target: AmbitionsCommandTarget(captureID: "capture-1"),
                expectedRevision: .exact(0),
                snapshot: RuntimePreparationSnapshot(
                    aggregateRevisions: [reference: .exact(0)],
                    cursors: [],
                    privacy: .standard
                )
            ),
            database: advancedDatabase
        )
        XCTAssertEqual(
            try await eligibility(
                for: advancedSource.receipt.facts.receiptID,
                at: Self.now,
                database: advancedDatabase
            ),
            .stale
        )
    }

    func testCompensationEligibilityRejectsPresentTargetCorruptionInsteadOfStale() async throws {
        for corruption in [
            "checksum", "payload-version", "malformed", "noncanonical", "row-revision",
            "same-revision-digest", "same-revision-lifecycle",
        ] {
            let database = try await makeStagedDatabase(
                label: "eligibility-target-corrupt-\(corruption)"
            )
            let source = try await commit(
                try await makeCapturePreparation(),
                database: database
            )
            let rows = try await database.query(
                "SELECT payload FROM runtime_aggregates WHERE aggregate_kind = 'capture' AND aggregate_id = 'capture-1' LIMIT 2"
            )
            guard rows.count == 1,
                  case let .blob(originalBytes)? = rows.first?.value(named: "payload") else {
                return XCTFail("Expected one canonical target row")
            }
            switch corruption {
            case "checksum":
                try await database.execute(
                    "UPDATE runtime_aggregates SET payload_checksum = ? WHERE aggregate_kind = 'capture' AND aggregate_id = 'capture-1'",
                    bindings: [.text(String(repeating: "0", count: 64))]
                )
            case "payload-version":
                try await database.execute(
                    "UPDATE runtime_aggregates SET payload_version = 2 WHERE aggregate_kind = 'capture' AND aggregate_id = 'capture-1'"
                )
            case "malformed":
                let malformed = Data("{}".utf8)
                try await database.execute(
                    "UPDATE runtime_aggregates SET payload = ?, payload_checksum = ? WHERE aggregate_kind = 'capture' AND aggregate_id = 'capture-1'",
                    bindings: [
                        .blob(malformed),
                        .text(LocalRuntimeStorageChecksum.sha256Hex(for: malformed)),
                    ]
                )
            case "noncanonical":
                let noncanonical = originalBytes + Data(" ".utf8)
                try await database.execute(
                    "UPDATE runtime_aggregates SET payload = ?, payload_checksum = ? WHERE aggregate_kind = 'capture' AND aggregate_id = 'capture-1'",
                    bindings: [
                        .blob(noncanonical),
                        .text(LocalRuntimeStorageChecksum.sha256Hex(for: noncanonical)),
                    ]
                )
            case "row-revision":
                try await database.execute(
                    "UPDATE runtime_aggregates SET revision = revision + 1 WHERE aggregate_kind = 'capture' AND aggregate_id = 'capture-1'"
                )
            case "same-revision-digest":
                let original = try RuntimeCanonicalAggregateStateCodec().decode(originalBytes)
                try await replaceCaptureState(
                    RuntimeCanonicalAggregateState(
                        aggregate: original.aggregate,
                        revision: original.revision,
                        lifecycle: original.lifecycle,
                        transition: .update,
                        commandPayload: capturePayload(action: .routeCommitment),
                        changedObjectIDs: original.changedObjectIDs
                    ),
                    database: database
                )
            case "same-revision-lifecycle":
                let original = try RuntimeCanonicalAggregateStateCodec().decode(originalBytes)
                try await replaceCaptureState(
                    RuntimeCanonicalAggregateState(
                        aggregate: original.aggregate,
                        revision: original.revision,
                        lifecycle: .tombstoned,
                        transition: .tombstone,
                        commandPayload: original.commandPayload,
                        changedObjectIDs: original.changedObjectIDs
                    ),
                    database: database
                )
            default:
                throw SnapshotFailure.invalidCount
            }
            let result = try await eligibility(
                for: source.receipt.facts.receiptID,
                at: Self.now,
                database: database
            )
            guard case let .sourceBlocked(reason, _) = result else {
                return XCTFail("\(corruption) must be source-blocked, not stale")
            }
            XCTAssertEqual(reason, .corruptReceiptCore, corruption)
        }
    }

    func testIdenticalUnsupportedEvidencePersistsForTwoSeparateReceipts() async throws {
        let database = try await makeStagedDatabase(label: "source-bound-evidence")
        _ = try await commit(try await makeCapturePreparation(), database: database)
        let aggregate = RuntimePreparationAggregateReference(
            family: .capture,
            objectID: try RuntimeDomainObjectID(validating: "capture-1")
        )
        let first = try await commit(
            try await makeCapturePreparation(
                commandID: "command-unsupported-one",
                action: .markWaiting,
                target: AmbitionsCommandTarget(captureID: "capture-1"),
                expectedRevision: .exact(0),
                snapshot: RuntimePreparationSnapshot(
                    aggregateRevisions: [aggregate: .exact(0)],
                    cursors: [], privacy: .standard
                )
            ),
            database: database
        )
        let second = try await commit(
            try await makeCapturePreparation(
                commandID: "command-unsupported-two",
                action: .markWaiting,
                target: AmbitionsCommandTarget(captureID: "capture-1"),
                expectedRevision: .exact(1),
                snapshot: RuntimePreparationSnapshot(
                    aggregateRevisions: [aggregate: .exact(1)],
                    cursors: [], privacy: .standard
                )
            ),
            database: database
        )
        let evidenceRows = try await database.query(
            """
            SELECT source_receipt_id, evidence_digest FROM runtime_irreversibility_evidence
            WHERE source_receipt_id IN (?, ?) ORDER BY source_receipt_id
            """,
            bindings: [
                .text(first.receipt.facts.receiptID.rawValue),
                .text(second.receipt.facts.receiptID.rawValue),
            ]
        )
        XCTAssertEqual(evidenceRows.count, 2)
        XCTAssertNotEqual(
            evidenceRows[0].value(named: "evidence_digest"),
            evidenceRows[1].value(named: "evidence_digest")
        )
        for receiptID in [first.receipt.facts.receiptID, second.receipt.facts.receiptID] {
            try await database.transaction(.deferred) { database in
                var budget = RuntimeReceiptDecodedByteBudget(maximumBytes: 1_048_576)
                _ = try RuntimeCommittedReceiptAuthority.loadAuthenticatedGraph(
                    receiptID: receiptID,
                    budget: &budget,
                    database: database
                )
            }
        }
    }

    func testIdempotencyFinalizationRejectsMissingCompensationConsumption() async throws {
        let database = try await makeStagedDatabase(label: "missing-consumption-finalization")
        let source = try await commit(try await makeCapturePreparation(), database: database)
        let plan = try await compensationPlan(for: source, database: database)
        let preparation = try await makeCompensationPreparation(
            commandID: "command-missing-consumption",
            plan: plan
        )
        let compensation = try await commit(
            preparation,
            confirmation: try approvedConfirmation(for: preparation),
            database: database
        )
        let finalRows = try await database.query(
            """
            SELECT final_result_version, final_result_payload, final_result_checksum, finalized_at_ms
            FROM runtime_command_idempotency WHERE command_id = ?
            """,
            bindings: [.text(compensation.receipt.facts.commandID.rawValue)]
        )
        guard finalRows.count == 1,
              case let .integer(version)? = finalRows[0].value(named: "final_result_version"),
              case let .blob(payload)? = finalRows[0].value(named: "final_result_payload"),
              case let .text(checksum)? = finalRows[0].value(named: "final_result_checksum"),
              case let .integer(finalizedAt)? = finalRows[0].value(named: "finalized_at_ms") else {
            return XCTFail("Expected finalized idempotency authority")
        }
        try await database.execute("DROP TRIGGER runtime_command_idempotency_seal_authority")
        let reset = try await database.execute(
            """
            UPDATE runtime_command_idempotency
            SET final_result_version = NULL, final_result_payload = NULL,
                final_result_checksum = NULL, finalized_at_ms = NULL
            WHERE command_id = ?
            """,
            bindings: [.text(compensation.receipt.facts.commandID.rawValue)]
        )
        XCTAssertEqual(reset.changedRowCount, 1)
        try await database.execute("DROP TRIGGER runtime_compensation_consumptions_immutable_delete")
        let removed = try await database.execute(
            "DELETE FROM runtime_compensation_consumptions WHERE compensation_receipt_id = ?",
            bindings: [.text(compensation.receipt.facts.receiptID.rawValue)]
        )
        XCTAssertEqual(removed.changedRowCount, 1)
        do {
            _ = try await database.execute(
                """
                UPDATE runtime_command_idempotency
                SET final_result_version = ?, final_result_payload = ?,
                    final_result_checksum = ?, finalized_at_ms = ?
                WHERE command_id = ?
                """,
                bindings: [
                    .integer(version), .blob(payload), .text(checksum), .integer(finalizedAt),
                    .text(compensation.receipt.facts.commandID.rawValue),
                ]
            )
            XCTFail("Compensation finalization must require its exact consumption row")
        } catch {
        }
    }

    func testFinalizedCompensationGraphAndReplayRejectMissingReverseConsumption() async throws {
        let database = try await makeStagedDatabase(label: "missing-reverse-consumption")
        let source = try await commit(try await makeCapturePreparation(), database: database)
        let plan = try await compensationPlan(for: source, database: database)
        let preparation = try await makeCompensationPreparation(
            commandID: "command-missing-reverse-consumption",
            plan: plan
        )
        let confirmation = try approvedConfirmation(for: preparation)
        let compensation = try await commit(
            preparation,
            confirmation: confirmation,
            database: database
        )
        try await database.execute("DROP TRIGGER runtime_compensation_consumptions_immutable_delete")
        let deletion = try await database.execute(
            "DELETE FROM runtime_compensation_consumptions WHERE compensation_receipt_id = ?",
            bindings: [.text(compensation.receipt.facts.receiptID.rawValue)]
        )
        XCTAssertEqual(deletion.changedRowCount, 1)

        do {
            try await database.transaction(.deferred) { database in
                var budget = RuntimeReceiptDecodedByteBudget(
                    maximumBytes: RuntimeCommittedReceiptReadBounds.maximumAccessBudgetBytes
                )
                _ = try RuntimeCommittedReceiptAuthority.loadAuthenticatedGraph(
                    receiptID: compensation.receipt.facts.receiptID,
                    budget: &budget,
                    database: database
                )
            }
            XCTFail("A finalized compensation receipt must require one reverse consumption row")
        } catch let error as RuntimeCommittedReceiptAuthorityError {
            XCTAssertEqual(error, .corruptAuthority)
        }

        do {
            _ = try await commit(
                preparation,
                confirmation: confirmation,
                database: database
            )
            XCTFail("Persisted replay must not return success after reverse authority is removed")
        } catch let error as RuntimeAtomicCommitError {
            XCTAssertEqual(error, .corruptAuthority)
        }
    }

    func testFinalizedCompensationGraphRejectsMismatchedReverseSource() async throws {
        let database = try await makeStagedDatabase(label: "mismatched-reverse-consumption")
        let source = try await commit(try await makeCapturePreparation(), database: database)
        let otherSource = try await commit(
            try await makeCapturePreparation(
                commandID: "command-other-reverse-source",
                target: AmbitionsCommandTarget(captureID: "capture-other-reverse"),
                snapshot: RuntimePreparationSnapshot(
                    aggregateRevisions: [:], cursors: [], privacy: .standard
                )
            ),
            database: database
        )
        let plan = try await compensationPlan(for: source, database: database)
        let preparation = try await makeCompensationPreparation(
            commandID: "command-mismatched-reverse-consumption",
            plan: plan
        )
        let compensation = try await commit(
            preparation,
            confirmation: try approvedConfirmation(for: preparation),
            database: database
        )
        try await database.execute("DROP TRIGGER runtime_compensation_consumptions_immutable_update")
        let update = try await database.execute(
            "UPDATE runtime_compensation_consumptions SET source_receipt_id = ? WHERE compensation_receipt_id = ?",
            bindings: [
                .text(otherSource.receipt.facts.receiptID.rawValue),
                .text(compensation.receipt.facts.receiptID.rawValue),
            ]
        )
        XCTAssertEqual(update.changedRowCount, 1)
        do {
            try await database.transaction(.deferred) { database in
                var budget = RuntimeReceiptDecodedByteBudget(
                    maximumBytes: RuntimeCommittedReceiptReadBounds.maximumAccessBudgetBytes
                )
                _ = try RuntimeCommittedReceiptAuthority.loadAuthenticatedGraph(
                    receiptID: compensation.receipt.facts.receiptID,
                    budget: &budget,
                    database: database
                )
            }
            XCTFail("A reverse row bound to the wrong source must corrupt compensation authority")
        } catch let error as RuntimeCommittedReceiptAuthorityError {
            XCTAssertEqual(error, .corruptAuthority)
        }
    }

    func testIncomingCompensationReadAndReplayRejectEveryMismatchedReverseField() async throws {
        for mismatch in ReverseConsumptionMismatch.allCases {
            let database = try await makeStagedDatabase(label: "incoming-reverse-\(mismatch)")
            let source = try await commit(try await makeCapturePreparation(), database: database)
            let otherSource = try await commit(
                try await makeCapturePreparation(
                    commandID: "command-incoming-other-\(mismatch)",
                    target: AmbitionsCommandTarget(captureID: "capture-incoming-other-\(mismatch)"),
                    snapshot: RuntimePreparationSnapshot(
                        aggregateRevisions: [:], cursors: [], privacy: .standard
                    )
                ),
                database: database
            )
            let sourcePlan = try await compensationPlan(for: source, database: database)
            let otherPlan = try await compensationPlan(for: otherSource, database: database)
            let preparation = try await makeCompensationPreparation(
                commandID: "command-incoming-compensation-\(mismatch)",
                plan: sourcePlan
            )
            let confirmation = try approvedConfirmation(for: preparation)
            let compensation = try await commit(
                preparation,
                confirmation: confirmation,
                database: database
            )
            try await database.execute(
                "DROP TRIGGER runtime_compensation_consumptions_immutable_update"
            )
            if mismatch == .terminalEvent {
                try await database.execute("DROP TRIGGER runtime_semantic_events_immutable_update")
            }
            let update: (String, [SQLiteBinding]) = switch mismatch {
            case .plan:
                (
                    "UPDATE runtime_compensation_consumptions SET plan_id = ? WHERE compensation_receipt_id = ?",
                    [.text(otherPlan.planID.rawValue), .text(compensation.receipt.facts.receiptID.rawValue)]
                )
            case .source:
                (
                    "UPDATE runtime_compensation_consumptions SET source_receipt_id = ? WHERE compensation_receipt_id = ?",
                    [
                        .text(otherSource.receipt.facts.receiptID.rawValue),
                        .text(compensation.receipt.facts.receiptID.rawValue),
                    ]
                )
            case .command:
                (
                    "UPDATE runtime_compensation_consumptions SET compensation_command_id = ? WHERE compensation_receipt_id = ?",
                    [
                        .text(otherSource.receipt.facts.commandID.rawValue),
                        .text(compensation.receipt.facts.receiptID.rawValue),
                    ]
                )
            case .terminalEvent:
                (
                    "UPDATE runtime_semantic_events SET type_id = (SELECT type_id FROM runtime_semantic_events WHERE sequence = ?) WHERE sequence = ?",
                    [
                        .integer(Int64(source.receipt.facts.lineage.eventSequence)),
                        .integer(Int64(compensation.receipt.facts.lineage.eventSequence)),
                    ]
                )
            case .terminalEventSequence:
                (
                    "UPDATE runtime_compensation_consumptions SET terminal_event_sequence = ? WHERE compensation_receipt_id = ?",
                    [
                        .integer(Int64(otherSource.receipt.facts.lineage.eventSequence)),
                        .text(compensation.receipt.facts.receiptID.rawValue),
                    ]
                )
            case .consumedTime:
                (
                    "UPDATE runtime_compensation_consumptions SET consumed_at_ms = consumed_at_ms + 1 WHERE compensation_receipt_id = ?",
                    [.text(compensation.receipt.facts.receiptID.rawValue)]
                )
            }
            XCTAssertEqual(
                try await database.execute(update.0, bindings: update.1).changedRowCount,
                1
            )
            do {
                try await database.transaction(.deferred) { database in
                    var budget = RuntimeReceiptDecodedByteBudget(
                        maximumBytes: RuntimeCommittedReceiptReadBounds.maximumAccessBudgetBytes
                    )
                    _ = try RuntimeCommittedReceiptAuthority.loadAuthenticatedGraph(
                        receiptID: compensation.receipt.facts.receiptID,
                        budget: &budget,
                        database: database
                    )
                }
                XCTFail("Incoming reverse mismatch \(mismatch) must corrupt compensation reads")
            } catch let error as RuntimeCommittedReceiptAuthorityError {
                XCTAssertEqual(error, .corruptAuthority)
            }
            do {
                _ = try await commit(
                    preparation,
                    confirmation: confirmation,
                    database: database
                )
                XCTFail("Incoming reverse mismatch \(mismatch) must block idempotent replay")
            } catch let error as RuntimeAtomicCommitError {
                XCTAssertEqual(error, .corruptAuthority)
            }
        }
    }

    func testSourceReadAndEligibilityAuthenticateEveryCompensationCounterpartChildFamily() async throws {
        for corruption in CompensationCounterpartChildCorruption.compensationCases {
            let database = try await makeStagedDatabase(label: "outgoing-child-\(corruption)")
            let source = try await commit(try await makeCapturePreparation(), database: database)
            let plan = try await compensationPlan(for: source, database: database)
            let preparation = try await makeCompensationPreparation(
                commandID: "command-outgoing-child-\(corruption)",
                plan: plan
            )
            let compensation = try await commit(
                preparation,
                confirmation: try approvedConfirmation(for: preparation),
                database: database
            )
            try await corruptCounterpartChild(
                corruption,
                receipt: compensation.receipt,
                database: database
            )

            do {
                try await database.transaction(.deferred) { database in
                    var budget = RuntimeReceiptDecodedByteBudget(
                        maximumBytes: RuntimeCommittedReceiptReadBounds.maximumAccessBudgetBytes
                    )
                    _ = try RuntimeCommittedReceiptAuthority.loadAuthenticatedGraph(
                        receiptID: source.receipt.facts.receiptID,
                        budget: &budget,
                        database: database
                    )
                }
                XCTFail("Source graph accepted corrupt compensation \(corruption) authority")
            } catch let error as RuntimeCommittedReceiptAuthorityError {
                XCTAssertEqual(error, .corruptAuthority)
            }
            guard case .sourceBlocked = try await eligibility(
                for: source.receipt.facts.receiptID,
                at: Self.now,
                database: database
            ) else {
                return XCTFail("Eligibility concealed corrupt compensation \(corruption) authority")
            }
            let access = try await receiptAccess(
                for: [source.receipt],
                surface: .localInspection
            )
            let context = try XCTUnwrap(RuntimeCompensationOfferContext(
                commandID: try XCTUnwrap(RuntimeCommandID(
                    rawValue: "offer-outgoing-child-\(corruption)"
                )),
                idempotencyKey: CommandIdempotencyKey("offer-outgoing-child-\(corruption)"),
                source: .reviews
            ))
            let offer = try await database.transaction(.deferred) { database in
                try CanonicalRuntimeStore.compensationOfferInTransaction(
                    receiptID: source.receipt.facts.receiptID,
                    access: access,
                    context: context,
                    at: Self.now,
                    database: database
                )
            }
            guard case let .unavailable(offerEligibility) = offer,
                  case .sourceBlocked = offerEligibility else {
                return XCTFail("Offer concealed corrupt compensation \(corruption) authority")
            }
        }
    }

    func testCompensationReadEligibilityAndReplayAuthenticateEverySourceCounterpartChildFamily() async throws {
        for corruption in CompensationCounterpartChildCorruption.sourceCases {
            let database = try await makeStagedDatabase(label: "incoming-child-\(corruption)")
            let source = try await commit(try await makeCapturePreparation(), database: database)
            let plan = try await compensationPlan(for: source, database: database)
            let preparation = try await makeCompensationPreparation(
                commandID: "command-incoming-child-\(corruption)",
                plan: plan
            )
            let confirmation = try approvedConfirmation(for: preparation)
            let compensation = try await commit(
                preparation,
                confirmation: confirmation,
                database: database
            )
            try await corruptCounterpartChild(
                corruption,
                receipt: source.receipt,
                database: database
            )

            do {
                try await database.transaction(.deferred) { database in
                    var budget = RuntimeReceiptDecodedByteBudget(
                        maximumBytes: RuntimeCommittedReceiptReadBounds.maximumAccessBudgetBytes
                    )
                    _ = try RuntimeCommittedReceiptAuthority.loadAuthenticatedGraph(
                        receiptID: compensation.receipt.facts.receiptID,
                        budget: &budget,
                        database: database
                    )
                }
                XCTFail("Compensation graph accepted corrupt source \(corruption) authority")
            } catch let error as RuntimeCommittedReceiptAuthorityError {
                XCTAssertEqual(error, .corruptAuthority)
            }
            guard case .sourceBlocked = try await eligibility(
                for: compensation.receipt.facts.receiptID,
                at: Self.now,
                database: database
            ) else {
                return XCTFail("Eligibility concealed corrupt source \(corruption) authority")
            }
            do {
                _ = try await commit(
                    preparation,
                    confirmation: confirmation,
                    database: database
                )
                XCTFail("Replay accepted corrupt source \(corruption) authority")
            } catch let error as RuntimeAtomicCommitError {
                XCTAssertEqual(error, .corruptAuthority)
            }
        }
    }

    func testReverseConsumptionRejectsDuplicateAndOrphanReferences() async throws {
        let database = try await makeStagedDatabase(label: "reverse-duplicate-orphan")
        let source = try await commit(try await makeCapturePreparation(), database: database)
        let otherSource = try await commit(
            try await makeCapturePreparation(
                commandID: "command-reverse-duplicate-source",
                target: AmbitionsCommandTarget(captureID: "capture-reverse-duplicate-source"),
                snapshot: RuntimePreparationSnapshot(
                    aggregateRevisions: [:], cursors: [], privacy: .standard
                )
            ),
            database: database
        )
        let plan = try await compensationPlan(for: source, database: database)
        let otherPlan = try await compensationPlan(for: otherSource, database: database)
        let preparation = try await makeCompensationPreparation(
            commandID: "command-reverse-duplicate-compensation",
            plan: plan
        )
        let compensation = try await commit(
            preparation,
            confirmation: try approvedConfirmation(for: preparation),
            database: database
        )
        do {
            _ = try await database.execute(
                """
                INSERT INTO runtime_compensation_consumptions(
                    plan_id, source_receipt_id, compensation_receipt_id,
                    compensation_command_id, terminal_event_sequence,
                    consumed_at_ms, consumption_version
                ) VALUES (?, ?, ?, ?, ?, ?, 1)
                """,
                bindings: [
                    .text(otherPlan.planID.rawValue),
                    .text(otherSource.receipt.facts.receiptID.rawValue),
                    .text(compensation.receipt.facts.receiptID.rawValue),
                    .text(otherSource.receipt.facts.commandID.rawValue),
                    .integer(Int64(otherSource.receipt.facts.lineage.eventSequence)),
                    .integer(try RuntimeSemanticEventHashing.milliseconds(
                        otherSource.receipt.facts.committedAt
                    )),
                ]
            )
            XCTFail("A compensation receipt cannot have a duplicate reverse row")
        } catch {
        }
        do {
            _ = try await database.execute(
                """
                INSERT INTO runtime_compensation_consumptions(
                    plan_id, source_receipt_id, compensation_receipt_id,
                    compensation_command_id, terminal_event_sequence,
                    consumed_at_ms, consumption_version
                ) VALUES ('orphan-plan', 'orphan-source', 'orphan-compensation',
                          'orphan-command', 999999, 0, 1)
                """
            )
            XCTFail("Foreign-key authority must reject orphan reverse references")
        } catch {
        }
    }

    func testFinalizedIdempotencyAuthorityCannotBeRewrittenOrUnfinalized() async throws {
        let database = try await makeStagedDatabase(label: "sealed-finalized-idempotency")
        let outcome = try await commit(try await makeCapturePreparation(), database: database)
        let before = try await database.query(
            """
            SELECT scope, idempotency_key, command_id, command_fingerprint,
                   claim_version, claim_payload, claimed_at_ms,
                   final_result_version, final_result_payload,
                   final_result_checksum, finalized_at_ms
            FROM runtime_command_idempotency WHERE command_id = ?
            """,
            bindings: [.text(outcome.receipt.facts.commandID.rawValue)]
        )
        do {
            _ = try await database.execute(
                """
                UPDATE runtime_command_idempotency
                SET final_result_version = NULL, final_result_payload = NULL,
                    final_result_checksum = NULL, finalized_at_ms = NULL
                WHERE command_id = ?
                """,
                bindings: [.text(outcome.receipt.facts.commandID.rawValue)]
            )
            XCTFail("Finalized idempotency authority must be sealed")
        } catch {
        }
        let after = try await database.query(
            """
            SELECT scope, idempotency_key, command_id, command_fingerprint,
                   claim_version, claim_payload, claimed_at_ms,
                   final_result_version, final_result_payload,
                   final_result_checksum, finalized_at_ms
            FROM runtime_command_idempotency WHERE command_id = ?
            """,
            bindings: [.text(outcome.receipt.facts.commandID.rawValue)]
        )
        XCTAssertEqual(before.count, 1)
        XCTAssertEqual(after.count, 1)
        XCTAssertEqual(before.first?.values, after.first?.values)
    }

    func testReceiptAndHistoryKeysetsByteBoundsScopedRedactionAndCancellation() async throws {
        let database = try await makeStagedDatabase(label: "query-contracts")
        let creation = try await commit(try await makeCapturePreparation(), database: database)
        let update = try await makeCapturePreparation(
            commandID: "command-query-update",
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
        let latest = try await commit(update, database: database)
        let access = try await receiptAccess(
            for: [creation.receipt, latest.receipt],
            surface: .localInspection
        )
        let receiptCursor = RuntimeReceiptCursor(
            highWaterEventSequence: latest.receipt.facts.lineage.eventSequence,
            eventSequence: latest.receipt.facts.lineage.eventSequence,
            accessPolicyDigest: access.digest
        )
        let receiptKeyset = try CanonicalRuntimeStore.receiptKeysetPredicate(
            after: receiptCursor,
            access: access
        )
        let olderReceipts = try await database.query(
            """
            SELECT c.terminal_event_sequence FROM runtime_committed_receipt_cores AS c
            WHERE c.terminal_event_sequence <= ? \(receiptKeyset.sql)
            ORDER BY c.terminal_event_sequence DESC
            """,
            bindings: [
                .integer(Int64(latest.receipt.facts.lineage.eventSequence)),
            ] + receiptKeyset.bindings
        )
        XCTAssertEqual(olderReceipts.count, 1)
        XCTAssertEqual(
            olderReceipts[0].value(named: "terminal_event_sequence"),
            .integer(Int64(creation.receipt.facts.lineage.eventSequence))
        )
        let widgetAccess = try await receiptAccess(
            for: [creation.receipt, latest.receipt],
            surface: .widgetSnapshot
        )
        XCTAssertThrowsError(try CanonicalRuntimeStore.receiptKeysetPredicate(
            after: receiptCursor,
            access: widgetAccess
        )) { error in
            XCTAssertEqual(error as? RuntimeCommittedReceiptQueryError, .cursorBindingMismatch)
        }

        let historyRows = try await database.query(
            "SELECT history_id, terminal_event_sequence FROM runtime_object_history WHERE family = 'capture' AND object_id = 'capture-1' ORDER BY terminal_event_sequence DESC"
        )
        guard case let .text(latestHistoryID)? = historyRows.first?.value(named: "history_id") else {
            return XCTFail("Expected object history")
        }
        let queryBinding = String(repeating: "b", count: 64)
        let historyCursor = RuntimeObjectHistoryCursor(
            highWaterEventSequence: latest.receipt.facts.lineage.eventSequence,
            eventSequence: latest.receipt.facts.lineage.eventSequence,
            historyID: latestHistoryID,
            accessPolicyDigest: access.digest,
            queryBindingDigest: queryBinding
        )
        let historyKeyset = try CanonicalRuntimeStore.objectHistoryKeysetPredicate(
            after: historyCursor,
            access: access,
            queryBindingDigest: queryBinding
        )
        let olderHistory = try await database.query(
            """
            SELECT h.terminal_event_sequence FROM runtime_object_history AS h
            WHERE h.family = 'capture' AND h.object_id = 'capture-1'
              AND h.terminal_event_sequence <= ? \(historyKeyset.sql)
            ORDER BY h.terminal_event_sequence DESC, h.history_id DESC
            """,
            bindings: [
                .integer(Int64(latest.receipt.facts.lineage.eventSequence)),
            ] + historyKeyset.bindings
        )
        XCTAssertEqual(olderHistory.count, 1)
        XCTAssertEqual(
            olderHistory[0].value(named: "terminal_event_sequence"),
            .integer(Int64(creation.receipt.facts.lineage.eventSequence))
        )

        let privateDatabase = try await makeStagedDatabase(label: "scoped-redaction")
        let privateOutcome = try await commit(
            try await makePrivateCapturePreparation(),
            database: privateDatabase
        )
        let otherDigest = String(repeating: "c", count: 64)
        let scopedAuthority = RuntimeReceiptAccessAuthority(
            testingAuthentication: { _ in .authenticated },
            testingReview: { _ in .reviewed }
        )
        let resolvedScopedAccess = try await scopedAuthority.issue(RuntimeReceiptAccessRequest(
            surface: .localInspection,
            purpose: .interactiveInspection,
            subjects: [RuntimeReceiptAccessSubject(
                coreDigest: otherDigest,
                privacy: .privateUserText
            )]
        ))
        let scopedAccess = try XCTUnwrap(resolvedScopedAccess)
        let authorityState = try await privateDatabase.transaction(.deferred) { database in
            try CanonicalRuntimeStore.receiptAuthorityState(
                receiptID: privateOutcome.receipt.facts.receiptID,
                access: scopedAccess,
                now: Self.now,
                database: database
            )
        }
        XCTAssertEqual(authorityState, .unavailable)

        let cancellationAccess = try await receiptAccess(
            for: [privateOutcome.receipt],
            surface: .localInspection
        )
        let cancellationTask = Task {
            await Task.yield()
            return try await privateDatabase.transaction(.deferred) { database in
                try CanonicalRuntimeStore.compensationEligibilityInTransaction(
                    receiptID: privateOutcome.receipt.facts.receiptID,
                    access: cancellationAccess,
                    at: Self.now,
                    database: database
                )
            }
        }
        cancellationTask.cancel()
        do {
            _ = try await cancellationTask.value
            XCTFail("Cancelled receipt query must not complete")
        } catch is CancellationError {
        }
    }

    func testMissingNormalizedReceiptChildrenAreRejectedByAuthentication() async throws {
        let cases = [
            ("runtime_receipt_compensation_dispositions", "source_receipt_id"),
            ("runtime_object_history", "receipt_id"),
            ("runtime_receipt_object_links", "receipt_id"),
            ("runtime_receipt_artifact_links", "receipt_id"),
            ("runtime_receipt_retention_references", "receipt_id"),
            ("runtime_compensation_plans", "source_receipt_id"),
        ]
        for (table, receiptColumn) in cases {
            let database = try await makeStagedDatabase(label: "missing-\(table)")
            let outcome = try await commit(try await makeCapturePreparation(), database: database)
            try await database.execute("DROP TRIGGER \(table)_immutable_delete")
            try await database.execute("PRAGMA foreign_keys = OFF")
            let deletion = try await database.execute(
                "DELETE FROM \(table) WHERE \(receiptColumn) = ?",
                bindings: [.text(outcome.receipt.facts.receiptID.rawValue)]
            )
            XCTAssertEqual(deletion.changedRowCount, 1, "Fixture must delete the intended \(table) authority row")
            try await database.execute("PRAGMA foreign_keys = ON")
            do {
                try await database.transaction(.deferred) { database in
                    try RuntimeCommittedReceiptAuthority.authenticatePersistedCore(
                        outcome.receipt,
                        database: database
                    )
                }
                XCTFail("Expected missing child rejection for \(table)")
            } catch let error as RuntimeCommittedReceiptAuthorityError {
                XCTAssertEqual(error, .corruptAuthority, table)
            }
        }
    }

    func testAuthenticatedGraphRejectsTinyRowArtifactFanoutAtDetectionRow() async throws {
        let database = try await makeStagedDatabase(label: "receipt-artifact-fanout")
        let outcome = try await commit(try await makeCapturePreparation(), database: database)
        try await database.execute("DROP TRIGGER runtime_receipt_artifact_links_bind_authority")
        try await database.execute(
            "DROP TRIGGER runtime_receipt_artifact_links_reject_insert_after_finalization"
        )
        let inserted = try await database.execute(
            """
            INSERT INTO runtime_receipt_artifact_links(
                receipt_id, artifact_kind, artifact_id, artifact_digest, link_version
            ) VALUES (?, 'projection_invalidation', 'forged-tiny-row', ?, 1)
            """,
            bindings: [
                .text(outcome.receipt.facts.receiptID.rawValue),
                .text(String(repeating: "a", count: 64)),
            ]
        )
        XCTAssertEqual(inserted.changedRowCount, 1)
        do {
            try await database.transaction(.deferred) { database in
                var budget = RuntimeReceiptDecodedByteBudget(
                    maximumBytes: RuntimeCommittedReceiptReadBounds.maximumAccessBudgetBytes
                )
                _ = try RuntimeCommittedReceiptAuthority.loadAuthenticatedGraph(
                    receiptID: outcome.receipt.facts.receiptID,
                    budget: &budget,
                    database: database
                )
            }
            XCTFail("One extra tiny artifact row must be detected before graph mapping")
        } catch let error as RuntimeCommittedReceiptAuthorityError {
            XCTAssertEqual(error, .corruptAuthority)
        }
    }

    func testInjectedReceiptCancellationPropagatesAcrossTraversalEventReplayHistoryAndEligibility() async throws {
        let database = try await makeStagedDatabase(label: "receipt-cancellation-checkpoints")
        let outcome = try await commit(try await makeCapturePreparation(), database: database)
        let access = try await receiptAccess(
            for: [outcome.receipt],
            surface: .localInspection
        )
        let aggregate = try XCTUnwrap(outcome.receipt.facts.objects.first?.aggregate)
        let checkpoints: [RuntimeReceiptCancellationCheckpoint] = [
            .graphTraversal,
            .terminalEventRead,
            .replayCoverage,
            .historyTraversal,
            .eligibilityEvaluation,
        ]
        for checkpoint in checkpoints {
            do {
                try await RuntimeReceiptCancellation.$injectedCheck.withValue({ observed in
                    if observed == checkpoint { throw CancellationError() }
                }) {
                    try await database.transaction(.deferred) { database in
                        switch checkpoint {
                        case .graphTraversal, .terminalEventRead:
                            var budget = RuntimeReceiptDecodedByteBudget(
                                maximumBytes: RuntimeCommittedReceiptReadBounds.maximumAccessBudgetBytes
                            )
                            _ = try RuntimeCommittedReceiptAuthority.loadAuthenticatedGraph(
                                receiptID: outcome.receipt.facts.receiptID,
                                budget: &budget,
                                database: database
                            )
                        case .replayCoverage:
                            _ = try CanonicalRuntimeStore.receiptAuthorityState(
                                receiptID: outcome.receipt.facts.receiptID,
                                access: access,
                                now: Self.now,
                                database: database
                            )
                        case .historyTraversal:
                            _ = try CanonicalRuntimeStore.objectHistoryPageInTransaction(
                                aggregate: aggregate,
                                access: access,
                                limit: 1,
                                database: database
                            )
                        case .eligibilityEvaluation:
                            _ = try CanonicalRuntimeStore.compensationEligibilityInTransaction(
                                receiptID: outcome.receipt.facts.receiptID,
                                access: access,
                                at: Self.now,
                                database: database
                            )
                        }
                    }
                }
                XCTFail("Expected cancellation at \(checkpoint)")
            } catch is CancellationError {
            }
        }

        // Supplementary structural assertions keep the broad semantic mappings
        // from silently dropping the explicit cancellation branches.
        let authority = try String(contentsOf: receiptAuthoritySourceURL(), encoding: .utf8)
        let queries = try String(contentsOf: receiptQueriesSourceURL(), encoding: .utf8)
        XCTAssertTrue(authority.contains("RuntimeReceiptCancellation.check(.graphTraversal)"))
        XCTAssertTrue(authority.contains(
            "private static func authenticateTerminalEvent("
        ))
        XCTAssertTrue(authority.contains(
            "} catch is CancellationError {\n            throw CancellationError()"
        ))
        XCTAssertTrue(queries.contains(
            "private static func replayCoverage("
        ))
        XCTAssertTrue(queries.contains(
            "RuntimeReceiptCancellation.check(.replayCoverage)\n        let highWaterRows"
        ))
        XCTAssertTrue(queries.contains(
            "private static func historyAuthorityState("
        ))
        XCTAssertTrue(queries.contains(
            "private static func compensationEligibility("
        ))
        XCTAssertTrue(queries.contains("catch is CancellationError"))
    }

    func testAuthenticatedPlanRejectsTargetFanoutAtDomainMaximumDetectionRow() async throws {
        let database = try await makeStagedDatabase(label: "compensation-target-fanout")
        let outcome = try await commit(try await makeCapturePreparation(), database: database)
        let plan = try await compensationPlan(for: outcome, database: database)
        try await database.execute("DROP TRIGGER runtime_compensation_plan_targets_bind_history")
        try await database.execute("DROP TRIGGER runtime_compensation_plan_targets_maximum")
        try await database.execute(
            "DROP TRIGGER runtime_compensation_plan_targets_reject_insert_after_finalization"
        )
        for index in 1...RuntimeCompensationLimits.maximumTargets {
            _ = try await database.execute(
                """
                INSERT INTO runtime_compensation_plan_targets(
                    plan_id, family, object_id, source_prior_revision, source_revision,
                    source_transition_kind, required_current_revision, required_lifecycle,
                    source_state_digest, transition_kind, target_version
                ) VALUES (?, 'capture', ?, NULL, 0, 'create', 0, 'active', ?, 'tombstone', 1)
                """,
                bindings: [
                    .text(plan.planID.rawValue),
                    .text("forged-target-\(index)"),
                    .text(String(repeating: "b", count: 64)),
                ]
            )
        }
        do {
            try await database.transaction(.deferred) { database in
                try RuntimeCommittedReceiptAuthority.authenticatePersistedCore(
                    outcome.receipt,
                    database: database
                )
            }
            XCTFail("The maximum-plus-one target detection row must corrupt plan authority")
        } catch let error as RuntimeCommittedReceiptAuthorityError {
            XCTAssertEqual(error, .corruptAuthority)
        }
    }

    func testReceiptPrivacyExposureMatrixIsProviderOwnedAndExistenceOpaque() async throws {
        let database = try await makeStagedDatabase(label: "receipt-privacy-matrix")
        let outcome = try await commit(try await makePrivateCapturePreparation(), database: database)

        let full = try await receiptAccess(
            for: [outcome.receipt], surface: .localInspection,
            userReviewed: true, authenticationSatisfied: true
        )
        let fullState = try await database.transaction(.deferred) { database in
            try CanonicalRuntimeStore.receiptAuthorityState(
                receiptID: outcome.receipt.facts.receiptID,
                access: full,
                now: Self.now,
                database: database
            )
        }
        guard case .available = fullState else {
            return XCTFail("Exact locally authenticated private receipt must be fully visible")
        }

        let redacted = try await receiptAccess(
            for: [outcome.receipt], surface: .widgetSnapshot,
            userReviewed: true, authenticationSatisfied: false
        )
        let redactedState = try await database.transaction(.deferred) { database in
            try CanonicalRuntimeStore.receiptAuthorityState(
                receiptID: outcome.receipt.facts.receiptID,
                access: redacted,
                now: Self.now,
                database: database
            )
        }
        guard case .redacted = redactedState else {
            return XCTFail("Reviewed widget access must receive only redacted receipt facts")
        }

        let aggregate = RuntimeSemanticAggregate(
            kind: .capture,
            id: try RuntimeAggregateID(validating: "capture-private")
        )
        let fullHistory = try await database.transaction(.deferred) { database in
            try CanonicalRuntimeStore.objectHistoryPageInTransaction(
                aggregate: aggregate, access: full, database: database
            )
        }
        guard let fullHistoryItem = fullHistory.items.first,
              case .available = fullHistoryItem else {
            return XCTFail("Exact local authentication must expose full object history")
        }
        let redactedHistory = try await database.transaction(.deferred) { database in
            try CanonicalRuntimeStore.objectHistoryPageInTransaction(
                aggregate: aggregate, access: redacted, database: database
            )
        }
        guard let redactedHistoryItem = redactedHistory.items.first,
              case .redacted = redactedHistoryItem else {
            return XCTFail("Reviewed widget access must redact object history")
        }

        let deniedAccesses = [
            try await receiptAccess(
                for: [outcome.receipt], surface: .localInspection,
                userReviewed: true, authenticationSatisfied: false
            ),
            try await receiptAccess(
                for: [outcome.receipt], surface: .widgetSnapshot,
                userReviewed: false, authenticationSatisfied: false
            ),
            try await receiptAccess(
                for: [outcome.receipt], surface: .sourceAtlasPublicReference,
                userReviewed: true, authenticationSatisfied: false
            ),
            try await receiptAccess(
                for: [outcome.receipt], surface: .searchIndex,
                userReviewed: true, authenticationSatisfied: false
            ),
        ]
        for denied in deniedAccesses {
            XCTAssertTrue(denied.authorizations.isEmpty)
            let page = try await database.transaction(.deferred) { database in
                try CanonicalRuntimeStore.committedReceiptPageInTransaction(
                    access: denied,
                    limit: 10,
                    at: Self.now,
                    database: database
                )
            }
            XCTAssertTrue(page.items.isEmpty)
            XCTAssertNil(page.nextCursor)
            let state = try await database.transaction(.deferred) { database in
                try CanonicalRuntimeStore.receiptAuthorityState(
                    receiptID: outcome.receipt.facts.receiptID,
                    access: denied,
                    now: Self.now,
                    database: database
                )
            }
            XCTAssertEqual(state, .unavailable)
            let history = try await database.transaction(.deferred) { database in
                try CanonicalRuntimeStore.objectHistoryPageInTransaction(
                    aggregate: aggregate, access: denied, database: database
                )
            }
            XCTAssertTrue(history.items.isEmpty)
            XCTAssertNil(history.nextCursor)
        }
    }

    func testReceiptReplayCoverageIsPendingUntilCertifiedReplay() async throws {
        let database = try await makeStagedDatabase(label: "receipt-replay-coverage")
        let outcome = try await commit(try await makeCapturePreparation(), database: database)
        let access = try await receiptAccess(
            for: [outcome.receipt], surface: .localInspection
        )
        let pending = try await database.transaction(.deferred) { database in
            try CanonicalRuntimeStore.receiptAuthorityState(
                receiptID: outcome.receipt.facts.receiptID,
                access: access,
                now: Self.now,
                database: database
            )
        }
        guard case let .available(pendingReceipt) = pending else {
            return XCTFail("Fresh committed receipt must remain available before replay certification")
        }
        XCTAssertEqual(pendingReceipt.replayCoverage, .verificationPending)

        _ = try await database.transaction(.immediate) { database in
            try RuntimeCanonicalReplayEngine.replayInTransaction(database: database)
        }
        let certified = try await database.transaction(.deferred) { database in
            try CanonicalRuntimeStore.receiptAuthorityState(
                receiptID: outcome.receipt.facts.receiptID,
                access: access,
                now: Self.now,
                database: database
            )
        }
        guard case let .available(certifiedReceipt) = certified else {
            return XCTFail("Replay-certified receipt must remain available")
        }
        XCTAssertEqual(
            certifiedReceipt.replayCoverage,
            .verifiedThrough(eventSequence: outcome.receipt.facts.lineage.eventSequence)
        )
    }

    func testPostCertificateQuarantineOccurrenceInvalidatesReplayCoverageIncludingNilSource() async throws {
        let database = try await makeStagedDatabase(label: "receipt-replay-invalidated")
        let preparation = try await makeCapturePreparation()
        let outcome = try await commit(preparation, database: database)
        _ = try await database.transaction(.immediate) { database in
            try RuntimeCanonicalReplayEngine.replayInTransaction(database: database)
        }
        _ = try await database.transaction(.immediate) { database in
            try CanonicalRuntimeSemanticEventStore.quarantine(
                sourceEventID: nil,
                sourceEventSequence: nil,
                reason: .malformedEnvelope,
                bytes: Data("post-certificate-quarantine".utf8),
                retention: .inline(Data("post-certificate-quarantine".utf8)),
                observedAtMilliseconds: try RuntimeSemanticEventHashing.milliseconds(Self.now),
                database: database
            )
        }
        let access = try await receiptAccess(
            for: [outcome.receipt], surface: .localInspection
        )
        let state = try await database.transaction(.deferred) { database in
            try CanonicalRuntimeStore.receiptAuthorityState(
                receiptID: outcome.receipt.facts.receiptID,
                access: access,
                now: Self.now,
                database: database
            )
        }
        guard case let .available(receipt) = state,
              case let .invalidated(reason, fingerprint) = receipt.replayCoverage else {
            return XCTFail("Any durable quarantine occurrence must revoke categorical replay coverage")
        }
        XCTAssertEqual(reason, .quarantineOccurrence)
        XCTAssertTrue(RuntimeStoreManifestCodec.isSHA256Hex(fingerprint.rawValue))
    }

    func testPredecessorCorruptionAndQuarantineBlockEveryReceiptReadPathAndReplay() async throws {
        for mode in ["corrupt", "quarantine"] {
            let database = try await makeStagedDatabase(label: "receipt-predecessor-\(mode)")
            let source = try await commit(try await makeCapturePreparation(), database: database)
            let updatePreparation = try await makeCapturePreparation(
                commandID: "command-predecessor-update",
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
            let updated = try await commit(updatePreparation, database: database)
            if mode == "corrupt" {
                try await database.execute("DROP TRIGGER runtime_semantic_events_immutable_update")
                let bytes = Data("corrupt-predecessor".utf8)
                try await database.execute(
                    "UPDATE runtime_semantic_events SET source_bytes = ?, source_digest = ? WHERE sequence = ?",
                    bindings: [
                        .blob(bytes),
                        .text(LocalRuntimeStorageChecksum.sha256Hex(for: bytes)),
                        .integer(Int64(source.receipt.facts.lineage.eventSequence)),
                    ]
                )
            } else {
                let bytes = Data("quarantined-predecessor".utf8)
                _ = try await database.transaction(.immediate) { database in
                    try CanonicalRuntimeSemanticEventStore.quarantine(
                        sourceEventID: source.receipt.facts.lineage.eventID.rawValue,
                        sourceEventSequence: source.receipt.facts.lineage.eventSequence,
                        reason: .corruptEnvelope,
                        bytes: bytes,
                        retention: .inline(bytes),
                        observedAtMilliseconds: try RuntimeSemanticEventHashing.milliseconds(Self.now),
                        database: database
                    )
                }
            }
            try await assertReceiptReadPathsAndReplayBlocked(
                outcome: updated,
                preparation: updatePreparation,
                confirmation: nil,
                expectedReason: mode == "quarantine"
                    ? .eventDependencyQuarantined
                    : .terminalEventIntegrityMismatch,
                database: database
            )
        }
    }

    func testResolvedCausationCorruptionAndQuarantineBlockEveryReceiptReadPathAndReplay() async throws {
        for mode in ["corrupt", "quarantine"] {
            let database = try await makeStagedDatabase(label: "receipt-causation-\(mode)")
            let source = try await commit(try await makeCapturePreparation(), database: database)
            _ = try await commit(
                try await makeCapturePreparation(
                    commandID: "command-causation-intervening",
                    target: AmbitionsCommandTarget(captureID: "capture-intervening"),
                    proposedID: "capture-intervening"
                ),
                database: database
            )
            let plan = try await compensationPlan(for: source, database: database)
            let compensationPreparation = try await makeCompensationPreparation(
                commandID: "command-causation-compensation",
                plan: plan
            )
            let confirmation = try approvedConfirmation(for: compensationPreparation)
            let compensation = try await commit(
                compensationPreparation,
                confirmation: confirmation,
                database: database
            )
            XCTAssertNotEqual(
                compensation.receipt.facts.lineage.eventSequence - 1,
                source.receipt.facts.lineage.eventSequence
            )
            if mode == "corrupt" {
                try await database.execute("DROP TRIGGER runtime_semantic_events_immutable_update")
                let bytes = Data("corrupt-causation".utf8)
                try await database.execute(
                    "UPDATE runtime_semantic_events SET source_bytes = ?, source_digest = ? WHERE sequence = ?",
                    bindings: [
                        .blob(bytes),
                        .text(LocalRuntimeStorageChecksum.sha256Hex(for: bytes)),
                        .integer(Int64(source.receipt.facts.lineage.eventSequence)),
                    ]
                )
            } else {
                let bytes = Data("quarantined-causation".utf8)
                _ = try await database.transaction(.immediate) { database in
                    try CanonicalRuntimeSemanticEventStore.quarantine(
                        sourceEventID: source.receipt.facts.lineage.eventID.rawValue,
                        sourceEventSequence: source.receipt.facts.lineage.eventSequence,
                        reason: .corruptEnvelope,
                        bytes: bytes,
                        retention: .inline(bytes),
                        observedAtMilliseconds: try RuntimeSemanticEventHashing.milliseconds(Self.now),
                        database: database
                    )
                }
            }
            try await assertReceiptReadPathsAndReplayBlocked(
                outcome: compensation,
                preparation: compensationPreparation,
                confirmation: confirmation,
                expectedReason: mode == "quarantine"
                    ? .eventDependencyQuarantined
                    : .terminalEventIntegrityMismatch,
                database: database
            )
        }
    }

    func testReceiptPageHighWaterAndCursorExcludeNewerDeniedRows() async throws {
        let database = try await makeStagedDatabase(label: "receipt-page-existence-opacity")
        let created = try await commit(try await makeCapturePreparation(), database: database)
        let updatedPreparation = try await makeCapturePreparation(
            commandID: "command-visible-update",
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
        let updated = try await commit(updatedPreparation, database: database)
        let deniedNewer = try await commit(try await makePrivateCapturePreparation(), database: database)
        XCTAssertGreaterThan(
            deniedNewer.receipt.facts.lineage.eventSequence,
            updated.receipt.facts.lineage.eventSequence
        )
        let access = try await receiptAccess(
            for: [created.receipt, updated.receipt],
            surface: .localInspection
        )
        let page = try await database.transaction(.deferred) { database in
            try CanonicalRuntimeStore.committedReceiptPageInTransaction(
                access: access,
                limit: 1,
                at: Self.now,
                database: database
            )
        }
        guard case let .available(visible)? = page.items.first else {
            return XCTFail("Expected newest authorized receipt")
        }
        XCTAssertEqual(visible.core.facts.receiptID, updated.receipt.facts.receiptID)
        XCTAssertEqual(
            page.nextCursor?.highWaterEventSequence,
            updated.receipt.facts.lineage.eventSequence
        )
        XCTAssertEqual(
            page.nextCursor?.eventSequence,
            updated.receipt.facts.lineage.eventSequence
        )
    }

    func testPublicEligibilityAndOfferDenyAuthorizationForWrongReceiptDigest() async throws {
        let database = try await makeStagedDatabase(label: "wrong-receipt-compensation-access")
        let outcome = try await commit(try await makePrivateCapturePreparation(), database: database)
        let wrongDigest = String(repeating: "d", count: 64)
        let wrongAuthority = RuntimeReceiptAccessAuthority(
            testingAuthentication: { _ in .authenticated }
        )
        let access = try XCTUnwrap(try await wrongAuthority.issue(RuntimeReceiptAccessRequest(
            surface: .localInspection,
            purpose: .interactiveInspection,
            subjects: [RuntimeReceiptAccessSubject(
                coreDigest: wrongDigest,
                privacy: .privateUserText
            )]
        )))
        XCTAssertEqual(access.authorizedReceiptDigests, Set([wrongDigest]))
        XCTAssertNotEqual(outcome.receipt.receiptDigest, wrongDigest)
        let receiptState = try await database.transaction(.deferred) { database in
            try CanonicalRuntimeStore.receiptAuthorityState(
                receiptID: outcome.receipt.facts.receiptID,
                access: access,
                now: Self.now,
                database: database
            )
        }
        XCTAssertEqual(receiptState, .unavailable)
        let eligibility = try await database.transaction(.deferred) { database in
            try CanonicalRuntimeCommittedReceiptSchemaPlan.requireIntegratedSchema(in: database)
            return try CanonicalRuntimeStore.compensationEligibilityInTransaction(
                receiptID: outcome.receipt.facts.receiptID,
                access: access,
                at: Self.now,
                database: database
            )
        }
        XCTAssertEqual(eligibility, .unavailable)
        let context = try XCTUnwrap(RuntimeCompensationOfferContext(
            commandID: try XCTUnwrap(RuntimeCommandID(rawValue: "wrong-digest-compensation")),
            idempotencyKey: CommandIdempotencyKey("wrong-digest-compensation"),
            source: .reviews
        ))
        let offer = try await database.transaction(.deferred) { database in
            try CanonicalRuntimeCommittedReceiptSchemaPlan.requireIntegratedSchema(in: database)
            return try CanonicalRuntimeStore.compensationOfferInTransaction(
                receiptID: outcome.receipt.facts.receiptID,
                access: access,
                context: context,
                at: Self.now,
                database: database
            )
        }
        guard case let .unavailable(offerEligibility) = offer else {
            return XCTFail("Wrong-receipt authorization must never manufacture a command")
        }
        XCTAssertEqual(offerEligibility, .unavailable)
    }

    func testReceiptSchemaValidationRejectsMissingCoreImmutabilityTriggerAfterPayloadCorruption() async throws {
        let database = try await makeStagedDatabase(label: "receipt-core-schema-corruption")
        let outcome = try await commit(try await makePrivateCapturePreparation(), database: database)
        try await database.execute("DROP TRIGGER runtime_committed_receipt_cores_immutable_update")
        let corruptPayload = Data([0xff])
        let corruption = try await database.execute(
            "UPDATE runtime_committed_receipt_cores SET payload = ?, payload_checksum = ? WHERE receipt_id = ?",
            bindings: [
                .blob(corruptPayload),
                .text(LocalRuntimeStorageChecksum.sha256Hex(for: corruptPayload)),
                .text(outcome.receipt.facts.receiptID.rawValue),
            ]
        )
        XCTAssertEqual(corruption.changedRowCount, 1)

        do {
            try await database.transaction(.deferred) { database in
                try CanonicalRuntimeCommittedReceiptSchemaPlan.requireIntegratedSchema(in: database)
            }
            XCTFail("Missing receipt immutability trigger must fail exact integrated-schema validation")
        } catch let error as RuntimeCanonicalReplayError {
            XCTAssertEqual(error, .corruptAuthority)
        }
    }

    func testReceiptAccessBindsAuthorizedPrivacyClassToCorePrivacy() async throws {
        let database = try await makeStagedDatabase(label: "receipt-access-privacy-binding")
        let outcome = try await commit(try await makePrivateCapturePreparation(), database: database)
        let forgedPrivacyAuthority = RuntimeReceiptAccessAuthority(
            testingAuthentication: { _ in .authenticated }
        )
        let access = try XCTUnwrap(try await forgedPrivacyAuthority.issue(
            RuntimeReceiptAccessRequest(
                surface: .localInspection,
                purpose: .interactiveInspection,
                subjects: [RuntimeReceiptAccessSubject(
                    coreDigest: outcome.receipt.receiptDigest,
                    privacy: .standard
                )]
            )
        ))
        XCTAssertEqual(access.fullReceiptDigests, Set([outcome.receipt.receiptDigest]))

        let receiptState = try await database.transaction(.deferred) { database in
            try CanonicalRuntimeStore.receiptAuthorityState(
                receiptID: outcome.receipt.facts.receiptID,
                access: access,
                now: Self.now,
                database: database
            )
        }
        XCTAssertEqual(receiptState, .unavailable)
        let eligibility = try await database.transaction(.deferred) { database in
            try CanonicalRuntimeStore.compensationEligibilityInTransaction(
                receiptID: outcome.receipt.facts.receiptID,
                access: access,
                at: Self.now,
                database: database
            )
        }
        XCTAssertEqual(eligibility, .unavailable)
        let context = try XCTUnwrap(RuntimeCompensationOfferContext(
            commandID: try XCTUnwrap(RuntimeCommandID(rawValue: "privacy-mismatch-offer")),
            idempotencyKey: CommandIdempotencyKey("privacy-mismatch-offer"),
            source: .reviews
        ))
        let offer = try await database.transaction(.deferred) { database in
            try CanonicalRuntimeStore.compensationOfferInTransaction(
                receiptID: outcome.receipt.facts.receiptID,
                access: access,
                context: context,
                at: Self.now,
                database: database
            )
        }
        XCTAssertEqual(offer, .unavailable(.unavailable))
    }

    func testPublicCompensationOfferReportsAbsentReceiptAsUnavailable() async throws {
        let database = try await makeStagedDatabase(label: "absent-receipt-compensation-offer")
        let access = try await receiptAccess(for: [], surface: .localInspection)
        let context = try XCTUnwrap(RuntimeCompensationOfferContext(
            commandID: try XCTUnwrap(RuntimeCommandID(rawValue: "absent-receipt-compensation")),
            idempotencyKey: CommandIdempotencyKey("absent-receipt-compensation"),
            source: .reviews
        ))
        let offer = try await database.transaction(.deferred) { database in
            try CanonicalRuntimeCommittedReceiptSchemaPlan.requireIntegratedSchema(in: database)
            return try CanonicalRuntimeStore.compensationOfferInTransaction(
                receiptID: try XCTUnwrap(RuntimeReceiptID(rawValue: "absent-receipt")),
                access: access,
                context: context,
                at: Self.now,
                database: database
            )
        }
        XCTAssertEqual(offer, .unavailable(.unavailable))
    }

    func testEligibilityAndOfferPreserveTypedFirstRowBudgetFailure() async throws {
        let database = try await makeStagedDatabase(label: "compensation-first-row-budget")
        let outcome = try await commit(
            try await makeCapturePreparation(
                commandID: "command-compensation-first-row-budget",
                title: String(repeating: "x", count: 250_000)
            ),
            database: database
        )
        let access = try await receiptAccess(
            for: [outcome.receipt],
            surface: .localInspection,
            maximumBytes: RuntimeCommittedReceiptReadBounds.minimumAccessBytes
        )
        do {
            _ = try await database.transaction(.deferred) { database in
                try CanonicalRuntimeStore.compensationEligibilityInTransaction(
                    receiptID: outcome.receipt.facts.receiptID,
                    access: access,
                    at: Self.now,
                    database: database
                )
            }
            XCTFail("Eligibility must preserve its typed first-row budget failure")
        } catch let error as RuntimeCommittedReceiptQueryError {
            XCTAssertEqual(error, .firstRowExceedsBound)
        }
        let context = try XCTUnwrap(RuntimeCompensationOfferContext(
            commandID: try XCTUnwrap(RuntimeCommandID(
                rawValue: "offer-compensation-first-row-budget"
            )),
            idempotencyKey: CommandIdempotencyKey("offer-compensation-first-row-budget"),
            source: .reviews
        ))
        do {
            _ = try await database.transaction(.deferred) { database in
                try CanonicalRuntimeStore.compensationOfferInTransaction(
                    receiptID: outcome.receipt.facts.receiptID,
                    access: access,
                    context: context,
                    at: Self.now,
                    database: database
                )
            }
            XCTFail("Offer must preserve its typed first-row budget failure")
        } catch let error as RuntimeCommittedReceiptQueryError {
            XCTAssertEqual(error, .firstRowExceedsBound)
        }
    }

    func testReceiptPageStopsAfterFirstRealGraphWhenLaterGraphExceedsSharedBudget() async throws {
        let database = try await makeStagedDatabase(label: "receipt-page-real-graph-budget")
        let largePredecessor = try await commit(
            try await makeCapturePreparation(
                commandID: "command-large-predecessor",
                title: String(repeating: "x", count: 250_000)
            ),
            database: database
        )
        let reminder = try await commit(try await makeReminderPreparation(), database: database)
        let plan = try await compensationPlan(for: reminder, database: database)
        let compensationPreparation = try await makeCompensationPreparation(
            commandID: "command-small-page-head",
            plan: plan
        )
        let compensation = try await commit(
            compensationPreparation,
            confirmation: try approvedConfirmation(for: compensationPreparation),
            database: database
        )
        let access = try await receiptAccess(
            for: [largePredecessor.receipt, reminder.receipt, compensation.receipt],
            surface: .localInspection,
            maximumRows: 3,
            maximumBytes: 262_144
        )

        let page = try await database.transaction(.deferred) { database in
            try CanonicalRuntimeCommittedReceiptSchemaPlan.requireIntegratedSchema(in: database)
            return try CanonicalRuntimeStore.committedReceiptPageInTransaction(
                access: access,
                limit: 3,
                at: Self.now,
                database: database
            )
        }

        XCTAssertEqual(page.items.count, 1)
        guard case let .available(head)? = page.items.first else {
            return XCTFail("The bounded page must admit its authenticated head receipt")
        }
        XCTAssertEqual(head.core.facts.receiptID, compensation.receipt.facts.receiptID)
        XCTAssertEqual(
            page.nextCursor?.eventSequence,
            compensation.receipt.facts.lineage.eventSequence
        )
        XCTAssertEqual(
            page.nextCursor?.highWaterEventSequence,
            compensation.receipt.facts.lineage.eventSequence
        )
    }

    func testFutureReceiptCoreAndPlanVersionsAreRejectedAsFuture() async throws {
        let database = try await makeStagedDatabase(label: "future-receipt-bytes")
        let outcome = try await commit(try await makeCapturePreparation(), database: database)
        let plan = try await compensationPlan(for: outcome, database: database)

        var coreObject = try XCTUnwrap(
            JSONSerialization.jsonObject(
                with: RuntimeCommittedReceiptCodec.encode(outcome.receipt)
            ) as? [String: Any]
        )
        var facts = try XCTUnwrap(coreObject["facts"] as? [String: Any])
        facts["version"] = runtimeCommittedReceiptCoreVersion + 1
        coreObject["facts"] = facts
        let futureCore = try JSONSerialization.data(withJSONObject: coreObject, options: [.sortedKeys])
        XCTAssertThrowsError(try RuntimeCommittedReceiptCodec.decodeCore(
            futureCore,
            storedChecksum: LocalRuntimeStorageChecksum.sha256Hex(for: futureCore)
        )) { error in
            XCTAssertEqual(error as? RuntimeCommittedReceiptCodecError, .futureVersion)
        }

        var planObject = try XCTUnwrap(
            JSONSerialization.jsonObject(
                with: RuntimeCommittedReceiptCodec.encode(plan)
            ) as? [String: Any]
        )
        planObject["version"] = runtimeCompensationPlanVersion + 1
        let futurePlan = try JSONSerialization.data(withJSONObject: planObject, options: [.sortedKeys])
        XCTAssertThrowsError(try RuntimeCommittedReceiptCodec.decodePlan(
            futurePlan,
            storedChecksum: LocalRuntimeStorageChecksum.sha256Hex(for: futurePlan)
        )) { error in
            XCTAssertEqual(error as? RuntimeCommittedReceiptCodecError, .futureVersion)
        }
    }

    func testLegacyScheduleUndoCannotEnterCurrentCommitAuthority() async throws {
        let undo = AmbitionsCommand(
            id: "command-legacy-schedule-undo",
            source: .time,
            typedPayload: .schedule(ScheduleCommand(
                action: .undo(CommandUndoIntent(
                    originalReceiptID: try XCTUnwrap(RuntimeCommandReceiptID(rawValue: "receipt-historical")),
                    expectedProjectionVersion: 1
                )),
                target: AmbitionsCommandTarget(timeID: "schedule-1"),
                content: RuntimeCommandContent()
            )),
            expectedRevision: .exact(1),
            createdAt: DomainTimestamp.string(from: Self.now)
        )
        let outcome = await RuntimeMutationPreparationService(
            reader: StagedPreparationReader(snapshot: .empty(privacy: .standard))
        ).prepare(
            undo,
            context: RuntimePreparationContext(
                preparationID: try XCTUnwrap(RuntimePreparationID(rawValue: "preparation.legacy-undo")),
                confirmationToken: try XCTUnwrap(RuntimeConfirmationToken(rawValue: "confirmation.legacy-undo")),
                proposedObjectID: nil,
                eventID: try RuntimeEventID(validating: "event.legacy-undo"),
                receiptID: try RuntimeReceiptID(validating: "receipt.legacy-undo"),
                rollbackPlanID: try XCTUnwrap(RuntimeRollbackPlanID(rawValue: "rollback.legacy-undo")),
                externalOperationID: nil,
                issuedAt: Self.now,
                expiresAt: Self.now.addingTimeInterval(60),
                boundary: .localOnly
            )
        )
        guard case let .unsupported(failure) = outcome else {
            return XCTFail("Legacy schedule undo must remain decode-only")
        }
        XCTAssertEqual(failure.reason, .unsupportedInThisBuild)
    }

    func testNonLocalCreationCannotAdvertiseACompensationPlan() throws {
        let command = AmbitionsCommand(
            id: "command-nonlocal-create",
            source: .capture,
            typedPayload: .capture(CaptureCommand(
                action: .quickCapture(externalCreation: nil),
                target: AmbitionsCommandTarget(),
                content: RuntimeCommandContent(AmbitionsCommandPayload(title: "Non-local"))
            )),
            expectedRevision: .absent,
            createdAt: DomainTimestamp.string(from: Self.now),
            localOnly: false
        )
        let decision = CaptureMutationReducer().reduce(RuntimeFeatureReducerInput(
            command: command,
            commandID: try RuntimeCommandID(validating: command.id),
            snapshot: .empty(privacy: .standard),
            context: RuntimePreparationContext(
                preparationID: try XCTUnwrap(RuntimePreparationID(rawValue: "preparation.nonlocal")),
                confirmationToken: try XCTUnwrap(RuntimeConfirmationToken(rawValue: "confirmation.nonlocal")),
                proposedObjectID: try RuntimeDomainObjectID(validating: "capture-nonlocal"),
                eventID: try RuntimeEventID(validating: "event.nonlocal"),
                receiptID: try RuntimeReceiptID(validating: "receipt.nonlocal"),
                rollbackPlanID: try XCTUnwrap(RuntimeRollbackPlanID(rawValue: "rollback.nonlocal")),
                externalOperationID: nil,
                issuedAt: Self.now,
                expiresAt: Self.now.addingTimeInterval(60),
                boundary: .localOnly
            )
        ))
        guard case let .noncompensable(evidence)? = decision.writeSet.compensation else {
            return XCTFail("Non-local creation must not advertise compensation")
        }
        XCTAssertEqual(evidence.permanence, .currentRuntimeUnsupported)
        XCTAssertEqual(evidence.reason, .externalEffectConstraint)
    }

    func testFrozenV5FinalOutcomeBytesAreMigrationRequiredAndFutureIsDistinct() async throws {
        let database = try await makeStagedDatabase(label: "legacy-v5-final")
        let current = try await commit(try await makeCapturePreparation(), database: database)
        let frozen = FrozenV5FinalOutcome(
            committed: current.committed,
            receipt: FrozenV5Receipt(current.receipt),
            pendingExternalOperations: current.pendingExternalOperations.map(FrozenV5Pending.init)
        )
        let frozenBytes = try RuntimeAtomicCommitCoding.encode(frozen)
        XCTAssertThrowsError(try RuntimeAtomicCommitCoding.decodeFinalOutcome(
            frozenBytes,
            storedChecksum: LocalRuntimeStorageChecksum.sha256Hex(for: frozenBytes)
        )) { error in
            XCTAssertEqual(
                error as? RuntimeAtomicCommitError,
                .migrationRequired(expected: 6, actual: 5)
            )
        }

        let futureBytes = Data("{\"outcomeVersion\":3}".utf8)
        XCTAssertThrowsError(try RuntimeAtomicCommitCoding.decodeFinalOutcome(
            futureBytes,
            storedChecksum: LocalRuntimeStorageChecksum.sha256Hex(for: futureBytes)
        )) { error in
            XCTAssertEqual(
                error as? RuntimeAtomicCommitError,
                .migrationRequired(expected: 2, actual: 3)
            )
        }
        let malformed = Data("{}".utf8)
        XCTAssertThrowsError(try RuntimeAtomicCommitCoding.decodeFinalOutcome(
            malformed,
            storedChecksum: LocalRuntimeStorageChecksum.sha256Hex(for: malformed)
        )) { error in
            XCTAssertEqual(error as? RuntimeAtomicCommitError, .corruptAuthority)
        }
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
            .deletingLastPathComponent()
            .appendingPathComponent("Ambitions/Core/LocalRuntimeOS/Transactions/RuntimeAtomicCommitCoordinator.swift")
    }

    private func receiptAuthoritySourceURL() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("Ambitions/Core/LocalRuntimeOS/Receipts/RuntimeCommittedReceiptAuthority.swift")
    }

    private func receiptQueriesSourceURL() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("Ambitions/Core/LocalRuntimeOS/Receipts/RuntimeCommittedReceiptQueries.swift")
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
            for statement in CanonicalRuntimeReplaySchemaPlan.statements {
                try database.execute(statement)
            }
            for statement in CanonicalRuntimeProjectionSchemaPlan.statements {
                try database.execute(statement)
            }
            for statement in CanonicalRuntimeCommittedReceiptSchemaPlan.statements {
                try database.execute(statement)
            }
            try database.execute(
                "INSERT INTO runtime_store_metadata(singleton_id, schema_version, generation_id, created_at_ms) VALUES (1, 6, 'staged-t12', 0)"
            )
            try database.execute("PRAGMA user_version = 6")
        }
        return database
    }

    private func assertFinalizedReceiptGraphInsertRejected(
        tables: [String],
        database: SQLiteDatabase,
        file: StaticString = #filePath,
        line: UInt = #line
    ) async throws {
        for table in tables {
            let triggerName = "\(table)_reject_insert_after_finalization"
            let triggerRows = try await database.query(
                "SELECT sql FROM sqlite_schema WHERE type = 'trigger' AND name = ? LIMIT 2",
                bindings: [.text(triggerName)]
            )
            XCTAssertEqual(triggerRows.count, 1, triggerName, file: file, line: line)
            guard case let .text(triggerSQL)? = triggerRows.first?.value(named: "sql") else {
                XCTFail("Expected construction seal SQL for \(table)", file: file, line: line)
                continue
            }
            XCTAssertTrue(
                triggerSQL.contains("final_result_version IS NOT NULL"),
                triggerName,
                file: file,
                line: line
            )
            let beforeRows = try await database.query("SELECT COUNT(*) AS count FROM \(table)")
            guard case let .integer(beforeCount)? = beforeRows.first?.value(named: "count") else {
                XCTFail("Expected a count for \(table)", file: file, line: line)
                continue
            }
            XCTAssertGreaterThan(beforeCount, 0, table, file: file, line: line)

            do {
                _ = try await database.execute(
                    "INSERT INTO \(table) SELECT * FROM \(table) LIMIT 1"
                )
                XCTFail(
                    "A finalized command must seal additional rows in \(table)",
                    file: file,
                    line: line
                )
            } catch let error as SQLiteError {
                XCTAssertEqual(error.operation, .step, table, file: file, line: line)
                XCTAssertEqual(error.primaryCode, 19, table, file: file, line: line)
                XCTAssertEqual(error.extendedCode, 1_811, table, file: file, line: line)
            }
            let afterRows = try await database.query("SELECT COUNT(*) AS count FROM \(table)")
            XCTAssertEqual(
                afterRows.first?.value(named: "count"),
                .integer(beforeCount),
                table,
                file: file,
                line: line
            )
        }
    }

    private func assertReceiptReadPathsAndReplayBlocked(
        outcome: RuntimeAtomicCommitFinalOutcome,
        preparation: RuntimePreparation,
        confirmation: RuntimeMutationConfirmation?,
        expectedReason: RuntimeReceiptSourceBlockedReason,
        historyExpectedReason: RuntimeReceiptSourceBlockedReason? = nil,
        database: SQLiteDatabase
    ) async throws {
        let access = try await receiptAccess(
            for: [outcome.receipt], surface: .localInspection
        )
        let receiptState = try await database.transaction(.deferred) { database in
            try CanonicalRuntimeStore.receiptAuthorityState(
                receiptID: outcome.receipt.facts.receiptID,
                access: access,
                now: Self.now,
                database: database
            )
        }
        guard case let .sourceBlocked(reason, _) = receiptState else {
            return XCTFail("Expected receipt source blocking")
        }
        XCTAssertEqual(reason, expectedReason)
        let receiptPage = try await database.transaction(.deferred) { database in
            try CanonicalRuntimeStore.committedReceiptPageInTransaction(
                access: access,
                limit: 1,
                at: Self.now,
                database: database
            )
        }
        guard let firstReceipt = receiptPage.items.first,
              case let .sourceBlocked(pageReason, _) = firstReceipt else {
            return XCTFail("Expected receipt page source blocking")
        }
        XCTAssertEqual(pageReason, expectedReason)
        let aggregate = try XCTUnwrap(outcome.receipt.facts.objects.first?.aggregate)
        let history = try await database.transaction(.deferred) { database in
            try CanonicalRuntimeStore.objectHistoryPageInTransaction(
                aggregate: aggregate,
                access: access,
                database: database
            )
        }
        guard history.items.contains(where: {
            if case let .sourceBlocked(reason, _) = $0 {
                return reason == (historyExpectedReason ?? expectedReason)
            }
            return false
        }) else {
            return XCTFail("Expected history source blocking")
        }
        let eligibility = try await database.transaction(.deferred) { database in
            try CanonicalRuntimeStore.compensationEligibilityInTransaction(
                receiptID: outcome.receipt.facts.receiptID,
                access: access,
                at: Self.now,
                database: database
            )
        }
        guard case let .sourceBlocked(reason, _) = eligibility else {
            return XCTFail("Expected eligibility source blocking")
        }
        XCTAssertEqual(reason, expectedReason)
        do {
            try await database.transaction(.deferred) { database in
                _ = try CanonicalRuntimeStore.authenticatedInvalidations(
                    projectionID: .search,
                    limit: RuntimeCommittedReceiptLimits.maximumProjectionInvalidations,
                    database: database
                )
            }
            XCTFail("Projection admission must reject a corrupt receipt graph")
        } catch let error as RuntimeCanonicalProjectionPersistenceError {
            XCTAssertEqual(error, .corruptInvalidation)
        }
        do {
            _ = try await commit(
                preparation,
                confirmation: confirmation,
                database: database
            )
            XCTFail("Persisted replay must reject a blocked receipt graph")
        } catch let error as RuntimeAtomicCommitError {
            XCTAssertEqual(error, .corruptAuthority)
        }
    }

    private func makeCapturePreparation(
        commandID: String = "command-create",
        title: String = "Capture",
        idempotencyKey: String? = nil,
        action: CaptureCommand.Action = .quickCapture(externalCreation: nil),
        target: AmbitionsCommandTarget = AmbitionsCommandTarget(),
        expectedRevision: RuntimeExpectedRevision = .absent,
        snapshot: RuntimePreparationSnapshot = .empty(privacy: .standard),
        proposedID: String = "capture-1"
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
        return try await prepared(command, snapshot: snapshot, proposedID: proposedID)
    }

    private func makePrivateCapturePreparation() async throws -> RuntimePreparation {
        let command = AmbitionsCommand(
            id: "command-private-create",
            source: .capture,
            typedPayload: .capture(CaptureCommand(
                action: .quickCapture(externalCreation: nil),
                target: AmbitionsCommandTarget(),
                content: RuntimeCommandContent(AmbitionsCommandPayload(title: "Private"))
            )),
            expectedRevision: .absent,
            idempotencyKey: CommandIdempotencyKey("command-private-create"),
            createdAt: DomainTimestamp.string(from: Self.now),
            actor: .user,
            localOnly: true,
            privacy: .privateUserText
        )
        return try await prepared(
            command,
            snapshot: .empty(privacy: .privateUserText),
            proposedID: "capture-private"
        )
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
            compensation: base.decision.writeSet.compensation,
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

    private func compensationPlan(
        for outcome: RuntimeAtomicCommitFinalOutcome,
        database: SQLiteDatabase
    ) async throws -> RuntimeCommittedCompensationPlan {
        try await database.transaction(.deferred) { database in
            guard case let .plan(planID, _, _, _) = outcome.receipt.facts.compensation else {
                throw RuntimeAtomicCommitError.corruptAuthority
            }
            return try RuntimeCommittedReceiptAuthority.loadPlan(
                planID: planID,
                database: database
            )
        }
    }

    private func makeCompensationPreparation(
        commandID: String,
        plan: RuntimeCommittedCompensationPlan
    ) async throws -> RuntimePreparation {
        guard let primary = plan.targets.first(where: {
            $0.aggregate.kind == plan.action.aggregateKind &&
                $0.aggregate.id.rawValue == plan.action.primaryObjectID.rawValue
        }) else {
            throw RuntimeAtomicCommitError.corruptAuthority
        }
        let command = AmbitionsCommand(
            id: commandID,
            source: .reviews,
            typedPayload: .compensation(RuntimeCompensationCommand(
                sourceReceiptID: plan.sourceReceiptID,
                planID: plan.planID,
                planDigest: plan.digest,
                sourceLineage: plan.sourceLineage,
                action: plan.action,
                targets: plan.targets,
                requiresConfirmation: plan.requiresConfirmation,
                target: plan.action.target,
                content: RuntimeCommandContent()
            )),
            expectedRevision: .exact(primary.requiredCurrentRevision),
            idempotencyKey: CommandIdempotencyKey(commandID),
            createdAt: DomainTimestamp.string(from: Self.now),
            actor: .user,
            localOnly: true,
            privacy: plan.privacy.classification
        )
        var revisions: [RuntimePreparationAggregateReference: RuntimeExpectedRevision] = [:]
        for target in plan.targets {
            revisions[RuntimePreparationAggregateReference(
                family: target.aggregate.kind,
                objectID: try RuntimeDomainObjectID(validating: target.aggregate.id.rawValue)
            )] = .exact(target.requiredCurrentRevision)
        }
        return try await prepared(
            command,
            snapshot: RuntimePreparationSnapshot(
                aggregateRevisions: revisions,
                cursors: [],
                privacy: plan.privacy.classification
            ),
            proposedID: "unused-compensation-proposal"
        )
    }

    private func eligibility(
        for receiptID: RuntimeReceiptID,
        at now: Date,
        database: SQLiteDatabase
    ) async throws -> RuntimeCompensationEligibility {
        let coreRows = try await database.query(
            "SELECT core_digest, privacy FROM runtime_committed_receipt_cores WHERE receipt_id = ? LIMIT 2",
            bindings: [.text(receiptID.rawValue)]
        )
        guard coreRows.count == 1, let row = coreRows.first,
              case let .text(coreDigest)? = row.value(named: "core_digest"),
              case let .text(rawPrivacy)? = row.value(named: "privacy"),
              let privacy = EventLedgerPrivacyClassification(rawValue: rawPrivacy) else {
            return .unavailable
        }
        let authority = RuntimeReceiptAccessAuthority(
            testingAuthentication: { _ in .authenticated },
            testingReview: { _ in .reviewed }
        )
        let access = try XCTUnwrap(try await authority.issue(RuntimeReceiptAccessRequest(
            surface: .localInspection,
            purpose: .interactiveInspection,
            subjects: [RuntimeReceiptAccessSubject(coreDigest: coreDigest, privacy: privacy)]
        )))
        try await database.transaction(.deferred) { database in
            try CanonicalRuntimeStore.compensationEligibilityInTransaction(
                receiptID: receiptID,
                access: access,
                at: now,
                database: database
            )
        }
    }

    private func corruptCounterpartChild(
        _ corruption: CompensationCounterpartChildCorruption,
        receipt: RuntimeCommittedReceiptCore,
        database: SQLiteDatabase
    ) async throws {
        let receiptID = receipt.facts.receiptID.rawValue
        switch corruption {
        case .history, .objectLink, .artifact, .retention:
            let table: String
            switch corruption {
            case .history: table = "runtime_object_history"
            case .objectLink: table = "runtime_receipt_object_links"
            case .artifact: table = "runtime_receipt_artifact_links"
            case .retention: table = "runtime_receipt_retention_references"
            default: throw SnapshotFailure.invalidCount
            }
            try await database.execute("DROP TRIGGER \(table)_immutable_delete")
            try await database.execute("PRAGMA foreign_keys = OFF")
            let deletion = try await database.execute(
                "DELETE FROM \(table) WHERE receipt_id = ?",
                bindings: [.text(receiptID)]
            )
            XCTAssertGreaterThan(deletion.changedRowCount, 0)
            try await database.execute("PRAGMA foreign_keys = ON")
        case .tombstone:
            if receipt.facts.objects.contains(where: { $0.lifecycle == .tombstoned }) {
                try await database.execute(
                    "DROP TRIGGER runtime_object_tombstone_history_immutable_delete"
                )
                let deletion = try await database.execute(
                    "DELETE FROM runtime_object_tombstone_history WHERE receipt_id = ?",
                    bindings: [.text(receiptID)]
                )
                XCTAssertGreaterThan(deletion.changedRowCount, 0)
            } else {
                let rows = try await database.query(
                    """
                    SELECT history_id, family, object_id, resulting_revision,
                           terminal_event_sequence, state_digest
                    FROM runtime_object_history WHERE receipt_id = ? LIMIT 1
                    """,
                    bindings: [.text(receiptID)]
                )
                guard rows.count == 1, let row = rows.first,
                      case let .text(historyID)? = row.value(named: "history_id"),
                      case let .text(family)? = row.value(named: "family"),
                      case let .text(objectID)? = row.value(named: "object_id"),
                      case let .integer(revision)? = row.value(named: "resulting_revision"),
                      case let .integer(sequence)? = row.value(named: "terminal_event_sequence"),
                      case let .text(stateDigest)? = row.value(named: "state_digest") else {
                    return XCTFail("Expected source history for extra tombstone corruption")
                }
                let payload = Data([0])
                try await database.execute(
                    "DROP TRIGGER runtime_object_tombstone_history_bind_history"
                )
                try await database.execute(
                    "DROP TRIGGER runtime_object_tombstone_history_reject_insert_after_finalization"
                )
                let insertion = try await database.execute(
                    """
                    INSERT INTO runtime_object_tombstone_history(
                        tombstone_history_id, history_id, receipt_id, family, object_id,
                        terminal_revision, terminal_event_sequence, reason, predecessor_digest,
                        tombstone_version, payload, payload_checksum, created_at_ms
                    ) VALUES (?, ?, ?, ?, ?, ?, ?, 'object_deleted', ?, 1, ?, ?, 0)
                    """,
                    bindings: [
                        .text(String(repeating: "f", count: 64)), .text(historyID), .text(receiptID),
                        .text(family), .text(objectID), .integer(revision), .integer(sequence),
                        .text(stateDigest), .blob(payload),
                        .text(LocalRuntimeStorageChecksum.sha256Hex(for: payload)),
                    ]
                )
                XCTAssertEqual(insertion.changedRowCount, 1)
            }
        case .projectionInvalidation:
            try await database.execute(
                "DROP TRIGGER runtime_commit_projection_invalidations_immutable_delete"
            )
            let deletion = try await database.execute(
                "DELETE FROM runtime_commit_projection_invalidations WHERE terminal_event_sequence = ?",
                bindings: [.integer(Int64(receipt.facts.lineage.eventSequence))]
            )
            XCTAssertGreaterThan(deletion.changedRowCount, 0)
        case .planTarget:
            try await database.execute(
                "DROP TRIGGER runtime_compensation_plan_targets_immutable_delete"
            )
            let deletion = try await database.execute(
                """
                DELETE FROM runtime_compensation_plan_targets WHERE plan_id = (
                    SELECT plan_id FROM runtime_compensation_plans
                    WHERE source_receipt_id = ? LIMIT 1
                )
                """,
                bindings: [.text(receiptID)]
            )
            XCTAssertGreaterThan(deletion.changedRowCount, 0)
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

    private func receiptAccess(
        for cores: [RuntimeCommittedReceiptCore],
        surface: SensitiveSurface,
        userReviewed: Bool = true,
        authenticationSatisfied: Bool = true,
        maximumRows: Int = 50,
        maximumBytes: Int = RuntimeCommittedReceiptReadBounds.defaultAccessBytes
    ) async throws -> RuntimeReceiptReadAccess {
        let authority = RuntimeReceiptAccessAuthority(
            testingAuthentication: { _ in
                authenticationSatisfied ? .authenticated : .denied
            },
            testingReview: { _ in userReviewed ? .reviewed : .denied }
        )
        return try XCTUnwrap(try await authority.issue(RuntimeReceiptAccessRequest(
            surface: surface,
            purpose: .interactiveInspection,
            subjects: cores.map {
                RuntimeReceiptAccessSubject(
                    coreDigest: $0.receiptDigest,
                    privacy: $0.facts.privacy.classification
                )
            },
            maximumRows: maximumRows,
            maximumBytes: maximumBytes
        )))
    }

    private static let now = Date(timeIntervalSince1970: 1_800_000_000)
}

private struct StagedPreparationReader: RuntimePreparationReading {
    let snapshot: RuntimePreparationSnapshot
    func read(_ request: RuntimePreparationReadRequest) async throws -> RuntimePreparationSnapshot { snapshot }
}

private enum ReverseConsumptionMismatch: CaseIterable {
    case plan
    case source
    case command
    case terminalEvent
    case terminalEventSequence
    case consumedTime
}

private enum CompensationCounterpartChildCorruption: String, CaseIterable {
    case history
    case objectLink
    case tombstone
    case artifact
    case retention
    case projectionInvalidation
    case planTarget

    static let compensationCases: [Self] = [
        .history, .objectLink, .tombstone, .artifact, .retention, .projectionInvalidation,
    ]
    static let sourceCases: [Self] = [
        .history, .objectLink, .tombstone, .artifact, .retention, .projectionInvalidation, .planTarget,
    ]
}

private struct AuthoritySnapshot: Equatable {
    static let tables = [
        "runtime_aggregates", "runtime_command_idempotency", "runtime_semantic_events",
        "runtime_semantic_event_quarantine", "runtime_commit_receipts",
        "runtime_commit_projection_invalidations", "runtime_pending_external_operations",
        "runtime_confirmation_consumptions", "runtime_commit_tombstones",
        "runtime_committed_receipt_cores", "runtime_receipt_compensation_dispositions",
        "runtime_object_history", "runtime_receipt_object_links",
        "runtime_object_tombstone_history", "runtime_receipt_artifact_links",
        "runtime_receipt_retention_references", "runtime_compensation_plans",
        "runtime_compensation_plan_targets", "runtime_compensation_plan_external_operations",
        "runtime_irreversibility_evidence", "runtime_compensation_consumptions",
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

private enum FrozenV5UndoabilityReason: String, Codable {
    case missingTypedCompensationContract = "missing_typed_compensation_contract"
}

private enum FrozenV5Undoability: Codable {
    case typedPlan(RuntimeRollbackPlanID)
    case notUndoable(reason: FrozenV5UndoabilityReason)
}

private struct FrozenV5ObjectLink: Codable {
    let aggregate: RuntimeSemanticAggregate
    let terminalRevision: UInt64
    let lifecycle: RuntimeAggregateLifecycle
}

private struct FrozenV5WorkReference: Codable {
    enum Kind: String, Codable { case projectionInvalidation, externalOperation }
    let kind: Kind
    let stableID: String
    let lineage: RuntimeAuthorityLineageReference
}

private struct FrozenV5Receipt: Codable {
    let receiptID: RuntimeReceiptID
    let preparationID: RuntimePreparationID
    let commandID: RuntimeCommandID
    let lineage: RuntimeAuthorityLineageReference
    let aggregateStates: [RuntimeCanonicalAggregateState]
    let tombstones: [RuntimeCanonicalTombstoneDraft]
    let unresolvedWork: [FrozenV5WorkReference]
    let objectLinks: [FrozenV5ObjectLink]
    let undoability: FrozenV5Undoability
    let confirmationToken: RuntimeConfirmationToken?
    let confirmationDecisionDigest: RuntimeCommandFingerprint?
    let committedAt: Date

    init(_ value: RuntimeCommittedReceiptCore) {
        receiptID = value.facts.receiptID
        preparationID = value.facts.preparationID
        commandID = value.facts.commandID
        lineage = value.facts.lineage
        aggregateStates = []
        tombstones = []
        unresolvedWork = []
        objectLinks = value.facts.objects.map {
            FrozenV5ObjectLink(
                aggregate: $0.aggregate,
                terminalRevision: $0.terminalRevision,
                lifecycle: $0.lifecycle
            )
        }
        undoability = switch value.facts.compensation {
        case let .plan(planID, _, _, _): .typedPlan(planID)
        case .noncompensable: .notUndoable(reason: .missingTypedCompensationContract)
        }
        confirmationToken = value.facts.confirmationToken
        confirmationDecisionDigest = value.facts.confirmationDecisionDigest
        committedAt = value.facts.committedAt
    }
}

private struct FrozenV5Pending: Codable {
    let operationID: RuntimeExternalOperationID
    let kind: RuntimeExternalEffectKind
    let status: String
    let lineage: RuntimeAuthorityLineageReference

    init(_ value: RuntimeCanonicalPendingExternalOperation) {
        operationID = value.operationID
        kind = value.kind
        status = value.status
        lineage = value.lineage
    }
}

private struct FrozenV5FinalOutcome: Codable {
    let committed: RuntimeCommittedMutation
    let receipt: FrozenV5Receipt
    let pendingExternalOperations: [FrozenV5Pending]
}
