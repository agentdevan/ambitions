@testable import Ambitions
import AmbitionsRuntimeSQLite
import Foundation
import XCTest

final class RuntimeCanonicalReplayTests: XCTestCase {
    func testReplaySchemaIsAdditiveV4AndCheckpointRowsAreImmutable() {
        XCTAssertEqual(CanonicalRuntimeReplaySchemaPlan.sourceSchemaVersion, 3)
        XCTAssertEqual(CanonicalRuntimeReplaySchemaPlan.targetSchemaVersion, 4)
        XCTAssertTrue(CanonicalRuntimeReplaySchemaPlan.tables.contains("runtime_replay_checkpoints"))
        XCTAssertTrue(CanonicalRuntimeReplaySchemaPlan.tables.contains("runtime_replay_checkpoint_aggregates"))
        XCTAssertTrue(CanonicalRuntimeReplaySchemaPlan.tables.contains("runtime_replay_checkpoint_tombstones"))
        XCTAssertTrue(CanonicalRuntimeReplaySchemaPlan.tables.contains("runtime_replay_retention_holds"))
        XCTAssertTrue(CanonicalRuntimeReplaySchemaPlan.tables.contains("runtime_replay_quarantine_occurrences"))
        XCTAssertTrue(CanonicalRuntimeReplaySchemaPlan.tables.contains("runtime_replay_verified_high_water"))
        XCTAssertTrue(CanonicalRuntimeReplaySchemaPlan.tables.contains("runtime_replay_verified_reconstructions"))
        let schema = CanonicalRuntimeReplaySchemaPlan.statements.joined(separator: "\n")
        XCTAssertTrue(schema.contains("immutable replay checkpoint"))
        XCTAssertTrue(schema.contains("immutable quarantine occurrence"))
        XCTAssertFalse(schema.contains("REFERENCES runtime_semantic_events(sequence)"))
        XCTAssertTrue(schema.contains("through_event_id"))
        XCTAssertTrue(schema.contains("through_event_hash"))
        XCTAssertTrue(schema.contains("chain_anchor_digest"))
        XCTAssertTrue(schema.contains("source_chain_digest"))
        XCTAssertTrue(schema.contains("immutable verified reconstruction"))
        XCTAssertTrue(schema.contains("runtime_replay_verified_reconstructions_immutable_update"))
        XCTAssertTrue(schema.contains("runtime_replay_verified_reconstructions_immutable_delete"))
        XCTAssertFalse(CanonicalRuntimeStore.expectedRuntimeTables.contains("runtime_replay_checkpoints"))
        XCTAssertEqual(CanonicalRuntimeCommitSchemaPlan.writableAuthoritySchemaVersions, Set([4]))
    }

    func testAtomicCommitSchemaCatalogAcceptsIntegratedV4WithoutChangingV3Authority() async throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("runtime-t10-v4-\(UUID().uuidString)", isDirectory: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let database = try SQLiteDatabase(url: directory.appendingPathComponent("Runtime.sqlite"))
        try await database.transaction(.exclusive) { database in
            for statement in CanonicalRuntimeStore.schemaStatements {
                try database.execute(statement)
            }
            for statement in CanonicalRuntimeReplaySchemaPlan.stagedIntegratedStatements {
                try database.execute(statement)
            }
            try database.execute(
                "INSERT INTO runtime_store_metadata(singleton_id, schema_version, generation_id, created_at_ms) VALUES (1, 4, 'staged-t10', 0)"
            )
            try database.execute("PRAGMA user_version = 4")
            try CanonicalRuntimeCommitSchemaPlan.requireIntegratedSchema(in: database)
            try CanonicalRuntimeReplaySchemaPlan.requireIntegratedSchema(in: database)
        }
        XCTAssertEqual(CanonicalRuntimeCommitSchemaPlan.targetSchemaVersion, 3)
        XCTAssertEqual(CanonicalRuntimeReplaySchemaPlan.targetSchemaVersion, 4)
    }

    func testEverySemanticFamilyReconstructsTheSharedCanonicalStateCodec() throws {
        for fixture in try semanticFixtures() {
            var reconstruction = try reconstructionBefore(fixture.event, command: fixture.command)
            let sequence = reconstruction.cursor == nil ? 1 : 2
            let previous = try reconstruction.cursor.map { try SHA256Digest(hexadecimal: $0.eventHash) }
            let record = try semanticRecord(event: fixture.event, sequence: UInt64(sequence), previous: previous)
            let applied = RuntimeCanonicalReplayReducer().apply(
                record,
                to: reconstruction
            )
            guard case let .accepted(next) = applied else {
                return XCTFail("Expected accepted replay for \(fixture.event.typeID)")
            }
            let state = try XCTUnwrap(next.aggregates.first?.state)
            XCTAssertEqual(state.aggregate, record.lineage.aggregate)
            XCTAssertEqual(state.revision, record.lineage.canonicalAggregateRevision)
            XCTAssertEqual(state.commandPayload, fixture.command)
            XCTAssertEqual(
                try RuntimeCanonicalAggregateStateCodec().decode(
                    RuntimeCanonicalAggregateStateCodec().encode(state)
                ),
                state
            )
            reconstruction = next
        }
    }

    func testWriterCodecAndReplayConstructEveryStableSemanticEventType() throws {
        let codec = RuntimeSemanticEventCodec()
        var producedTypes = Set<RuntimeSemanticEventTypeID>()

        for (index, command) in try writerMutationCommands().enumerated() {
            guard case let .mutating(typeID) = RuntimeSemanticEventClassifier.classify(command) else {
                return XCTFail("Writer fixture must classify as a mutation")
            }
            let objectID = try RuntimeDomainObjectID(validating: "writer-event-\(index)")
            let aggregate = RuntimeSemanticAggregate(
                kind: typeID.aggregateKind,
                id: try RuntimeAggregateID(validating: objectID.rawValue)
            )
            let priorRevision: UInt64? = typeID.isCreation ? nil : 0
            let resultingRevision: UInt64 = typeID.isCreation ? 0 : 1
            let transition = typeID.legalAggregateTransition
            let lifecycle = typeID.legalAggregateLifecycle
            let predecessorState: RuntimeCanonicalAggregateState? = priorRevision.map { revision in
                RuntimeCanonicalAggregateState(
                    aggregate: aggregate,
                    revision: revision,
                    lifecycle: .active,
                    transition: .update,
                    commandPayload: command,
                    changedObjectIDs: [objectID]
                )
            }
            let predecessorDigest = try predecessorState.map {
                LocalRuntimeStorageChecksum.sha256Hex(
                    for: try RuntimeCanonicalAggregateStateCodec().encode($0)
                )
            }
            let state = RuntimeCanonicalAggregateState(
                aggregate: aggregate,
                revision: resultingRevision,
                lifecycle: lifecycle,
                transition: transition,
                commandPayload: command,
                changedObjectIDs: [objectID]
            )
            let event = try RuntimeAtomicSemanticEventFactory.make(
                command: command,
                primaryAggregate: aggregate,
                primaryPriorRevision: priorRevision,
                primaryResultingRevision: resultingRevision,
                changedObjectIDs: [objectID],
                transitionInputs: [RuntimeAtomicSemanticTransitionInput(
                    state: state,
                    priorRevision: priorRevision,
                    predecessorStateDigest: predecessorDigest
                )]
            )
            XCTAssertEqual(event.typeID, typeID)
            let sourceBytes = try codec.encode(event)
            XCTAssertEqual(try codec.decode(sourceBytes).event, event)

            let reconstruction: RuntimeCanonicalReconstruction
            let sequence: UInt64
            let previous: SHA256Digest?
            if let predecessorState {
                let cursor = RuntimeCanonicalReplayCursor(
                    sequence: 1,
                    eventID: "writer-seed-\(index)",
                    eventHash: String(repeating: "d", count: 64)
                )
                let predecessorBytes = try RuntimeCanonicalAggregateStateCodec().encode(predecessorState)
                reconstruction = try RuntimeCanonicalReconstruction(
                    cursor: cursor,
                    lastCorrelationID: "writer-seed-correlation-\(index)",
                    aggregates: [RuntimeCanonicalReplayAggregate(
                        state: predecessorState,
                        canonicalBytes: predecessorBytes,
                        stateDigest: LocalRuntimeStorageChecksum.sha256Hex(for: predecessorBytes),
                        lastEvent: cursor
                    )],
                    tombstones: []
                )
                sequence = 2
                previous = try SHA256Digest(hexadecimal: cursor.eventHash)
            } else {
                reconstruction = .empty
                sequence = 1
                previous = nil
            }
            let record = try semanticRecord(event: event, sequence: sequence, previous: previous)
            guard case let .accepted(next) = RuntimeCanonicalReplayReducer().apply(record, to: reconstruction) else {
                return XCTFail("Replay must accept writer-produced \(typeID.rawValue)")
            }
            XCTAssertEqual(next.aggregates.first?.state, state)
            producedTypes.insert(typeID)
        }

        XCTAssertEqual(producedTypes, Set(RuntimeSemanticEventTypeID.allCases))
    }

    private func reconstructionBefore(
        _ event: RuntimeSemanticEvent,
        command: RuntimeCommandPayload
    ) throws -> RuntimeCanonicalReconstruction {
        guard let revision = event.mutation.priorRevision else { return .empty }
        let cursor = RuntimeCanonicalReplayCursor(
            sequence: 1,
            eventID: "event-seed",
            eventHash: String(repeating: "d", count: 64)
        )
        let state = RuntimeCanonicalAggregateState(
            aggregate: RuntimeSemanticAggregate(kind: event.aggregateKind, id: event.mutation.aggregateID),
            revision: revision,
            lifecycle: .active,
            transition: .update,
            commandPayload: command,
            changedObjectIDs: event.mutation.changedObjectIDs
        )
        let bytes = try RuntimeCanonicalAggregateStateCodec().encode(state)
        return try RuntimeCanonicalReconstruction(
            cursor: cursor,
            lastCorrelationID: "correlation-seed",
            aggregates: [RuntimeCanonicalReplayAggregate(
                state: state,
                canonicalBytes: bytes,
                stateDigest: LocalRuntimeStorageChecksum.sha256Hex(for: bytes),
                lastEvent: cursor
            )],
            tombstones: []
        )
    }

    func testReducerStopsAtFirstAggregateRevisionDivergenceWithoutPayloadEvidence() throws {
        let created = try captureEvent(id: "capture-revision", revision: 0, prior: nil, action: .quickCapture(externalCreation: nil))
        let skipped = try captureEvent(id: "capture-revision", revision: 2, prior: 1, action: .markWaiting)
        let first = try semanticRecord(event: created, sequence: 1)
        let second = try semanticRecord(event: skipped, sequence: 2, previous: first.lineage.eventHash)
        guard case let .accepted(prefix) = RuntimeCanonicalReplayReducer().apply(first, to: .empty) else {
            return XCTFail("Expected verified prefix")
        }
        let result = RuntimeCanonicalReplayReducer().apply(second, to: prefix)
        guard case let .blocked(evidence, retained) = result else {
            return XCTFail("Expected first-divergence evidence")
        }
        XCTAssertEqual(evidence.code, .aggregateRevisionMismatch)
        XCTAssertEqual(evidence.lastVerifiedCursor, prefix.cursor)
        XCTAssertEqual(evidence.divergentSequence, 2)
        XCTAssertEqual(evidence.expectedRevision, 0)
        XCTAssertEqual(evidence.observedRevision, 1)
        XCTAssertNil(evidence.privatePayload)
        XCTAssertEqual(retained, prefix)
    }

    func testDeleteThenCreationIsSilentIdentityReuseAndTypedRestorationIsRequired() throws {
        let created = try captureEvent(id: "capture-reuse", revision: 0, prior: nil, action: .quickCapture(externalCreation: nil))
        let archived = try captureEvent(id: "capture-reuse", revision: 1, prior: 0, action: .archive)
        let recreated = try captureEvent(id: "capture-reuse", revision: 0, prior: nil, action: .quickCapture(externalCreation: nil))
        let first = try semanticRecord(event: created, sequence: 1)
        let second = try semanticRecord(event: archived, sequence: 2, previous: first.lineage.eventHash)
        let third = try semanticRecord(event: recreated, sequence: 3, previous: second.lineage.eventHash)
        guard case let .accepted(one) = RuntimeCanonicalReplayReducer().apply(first, to: .empty),
              case let .accepted(two) = RuntimeCanonicalReplayReducer().apply(second, to: one) else {
            return XCTFail("Expected verified tombstoned prefix")
        }
        XCTAssertEqual(two.tombstones.first?.reason, .archived)
        XCTAssertEqual(two.tombstones.first?.recoveryDisposition, .explicitTypedRestorationRequired)
        guard case let .blocked(evidence, _) = RuntimeCanonicalReplayReducer().apply(third, to: two) else {
            return XCTFail("Expected silent identity reuse to block")
        }
        XCTAssertEqual(evidence.code, .silentIdentityReuse)
    }

    func testCheckpointCodecBindsCursorStateTombstonesAndManifestDigest() throws {
        let event = try captureEvent(id: "capture-checkpoint", revision: 0, prior: nil, action: .quickCapture(externalCreation: nil))
        let record = try semanticRecord(event: event, sequence: 1)
        guard case let .accepted(reconstruction) = RuntimeCanonicalReplayReducer().apply(record, to: .empty) else {
            return XCTFail("Expected reconstruction")
        }
        let checkpoint = try RuntimeCanonicalReplayCheckpoint.testOnlyMake(
            reconstruction: reconstruction,
            sourceChainDigest: try RuntimeCanonicalReplaySourceChain.advance(
                prior: RuntimeCanonicalReplaySourceChain.emptyDigest,
                lineage: record.lineage
            ).hexadecimal,
            createdAt: Date(timeIntervalSince1970: 1_800_000_000)
        )
        let codec = RuntimeCanonicalReplayCheckpointCodec()
        let bytes = try codec.encode(checkpoint)
        XCTAssertEqual(try codec.decode(bytes), checkpoint)
        XCTAssertEqual(try codec.encode(codec.decode(bytes)), bytes)
        XCTAssertEqual(checkpoint.highWaterCursor, reconstruction.cursor)
        XCTAssertEqual(checkpoint.stateDigest, reconstruction.stateDigest)
        XCTAssertTrue(RuntimeStoreManifestCodec.isSHA256Hex(checkpoint.sourceChainDigest))
        XCTAssertTrue(RuntimeStoreManifestCodec.isSHA256Hex(checkpoint.manifestDigest))
    }

    func testWholeSourceChainBindsEveryPrefixFactNotOnlyTailIdentity() throws {
        let first = try semanticRecord(
            event: captureEvent(id: "chain-one", revision: 0, prior: nil, action: .quickCapture(externalCreation: nil)),
            sequence: 1
        )
        let second = try semanticRecord(
            event: captureEvent(id: "chain-two", revision: 0, prior: nil, action: .quickCapture(externalCreation: nil)),
            sequence: 2,
            previous: first.lineage.eventHash
        )
        let prefix = try RuntimeCanonicalReplaySourceChain.advance(
            prior: RuntimeCanonicalReplaySourceChain.emptyDigest,
            lineage: first.lineage
        )
        let whole = try RuntimeCanonicalReplaySourceChain.advance(prior: prefix, lineage: second.lineage)
        let changedPrefix = try RuntimeCanonicalReplaySourceChain.advance(
            prior: RuntimeCanonicalReplaySourceChain.emptyDigest,
            sequence: first.lineage.sequence,
            eventID: first.lineage.eventID,
            eventHash: first.lineage.eventHash,
            sourceDigest: SHA256Digest.digest(Data("different-source-fact".utf8)),
            previousEventHash: first.lineage.previousEventHash
        )
        let changedWhole = try RuntimeCanonicalReplaySourceChain.advance(prior: changedPrefix, lineage: second.lineage)
        XCTAssertNotEqual(whole, changedWhole)
    }

    func testEveryEventTypeHasOneExhaustiveLegalTransitionAndLifecycle() {
        let creations: Set<RuntimeSemanticEventTypeID> = [
            .captureCreated, .goalCreated, .scheduleItemCreated, .reminderCreated,
        ]
        let tombstones: Set<RuntimeSemanticEventTypeID> = [
            .captureArchived, .reminderDeleted, .objectDeleted, .memoryForgotten,
        ]
        for type in RuntimeSemanticEventTypeID.allCases {
            if creations.contains(type) {
                XCTAssertEqual(type.legalAggregateTransition, .create, type.rawValue)
            } else if tombstones.contains(type) {
                XCTAssertEqual(type.legalAggregateTransition, .tombstone, type.rawValue)
            } else if type == .captureAttachedToGoal {
                XCTAssertEqual(type.legalAggregateTransition, .attach, type.rawValue)
            } else {
                XCTAssertEqual(type.legalAggregateTransition, .update, type.rawValue)
            }
            XCTAssertEqual(
                type.legalAggregateLifecycle,
                tombstones.contains(type) ? .tombstoned : .active,
                type.rawValue
            )
        }
    }

    func testEventTypeRejectsIllegalTransitionAndLifecyclePair() throws {
        let aggregate = RuntimeSemanticAggregate(
            kind: .capture,
            id: try RuntimeAggregateID(validating: "illegal-transition")
        )
        let command = CaptureCommand(
            action: .quickCapture(externalCreation: nil),
            target: AmbitionsCommandTarget(captureID: "illegal-transition"),
            content: RuntimeCommandContent(AmbitionsCommandPayload(title: "Illegal"))
        )
        let state = RuntimeCanonicalAggregateState(
            aggregate: aggregate,
            revision: 0,
            lifecycle: .tombstoned,
            transition: .tombstone,
            commandPayload: .capture(command),
            changedObjectIDs: [try RuntimeDomainObjectID(validating: "illegal-transition")]
        )
        let bytes = try RuntimeCanonicalAggregateStateCodec().encode(state)
        XCTAssertThrowsError(try RuntimeSemanticMutation(
            semanticType: .captureCreated,
            aggregateID: aggregate.id,
            priorRevision: nil,
            resultingRevision: 0,
            changedObjectIDs: state.changedObjectIDs,
            primaryAggregate: aggregate,
            aggregateTransitions: [RuntimeSemanticAggregateTransition(
                aggregate: aggregate,
                priorRevision: nil,
                resultingRevision: 0,
                lifecycle: .tombstoned,
                transition: .tombstone,
                canonicalStateBytes: bytes,
                canonicalStateDigest: LocalRuntimeStorageChecksum.sha256Hex(for: bytes),
                tombstone: RuntimeCanonicalTombstoneAuthority(
                    reason: .archived,
                    predecessorDigest: String(repeating: "a", count: 64),
                    retentionDisposition: .retainedUntilDownstreamPolicy,
                    recoveryDisposition: .explicitTypedRestorationRequired
                )
            )]
        ))
    }

    func testTombstoneParityKeyIncludesFamilyWhenRawIdentityMatches() throws {
        let cursor = RuntimeCanonicalReplayCursor(
            sequence: 1, eventID: "event-family", eventHash: String(repeating: "a", count: 64)
        )
        func tombstone(_ kind: RuntimeSemanticAggregateKind) throws -> RuntimeCanonicalReplayTombstone {
            RuntimeCanonicalReplayTombstone(
                aggregate: RuntimeSemanticAggregate(
                    kind: kind,
                    id: try RuntimeAggregateID(validating: "shared-object-id")
                ),
                terminalRevision: 1,
                reason: .objectDeleted,
                causalCursor: cursor,
                predecessorDigest: String(repeating: "b", count: 64),
                retentionDisposition: .retainedUntilDownstreamPolicy,
                recoveryDisposition: .explicitTypedRestorationRequired
            )
        }
        let capture = try tombstone(.capture)
        let reminder = try tombstone(.reminder)
        XCTAssertNotEqual(capture.paritySortKey, reminder.paritySortKey)
        XCTAssertEqual([reminder, capture].sorted { $0.paritySortKey < $1.paritySortKey }, [capture, reminder])
    }

    func testDivergenceEvidenceIsRedactedAndPinpointsExactSafeFacts() {
        let evidence = RuntimeCanonicalReplayDivergence(
            code: .liveStateDivergence,
            lastVerifiedCursor: nil,
            divergentEventID: "event-divergence",
            divergentSequence: 7,
            expectedHash: String(repeating: "c", count: 64),
            observedHash: String(repeating: "d", count: 64),
            expectedRevision: 4,
            observedRevision: 5,
            quarantineReference: nil
        )
        XCTAssertEqual(evidence.divergentEventID, "event-divergence")
        XCTAssertEqual(evidence.divergentSequence, 7)
        XCTAssertEqual(evidence.expectedRevision, 4)
        XCTAssertEqual(evidence.observedRevision, 5)
        XCTAssertNil(evidence.privatePayload)
    }

    func testCheckpointManifestRejectsDifferentSourceChainBinding() throws {
        let record = try semanticRecord(
            event: captureEvent(id: "checkpoint-chain", revision: 0, prior: nil, action: .quickCapture(externalCreation: nil)),
            sequence: 1
        )
        guard case let .accepted(reconstruction) = RuntimeCanonicalReplayReducer().apply(record, to: .empty) else {
            return XCTFail("Expected reconstruction")
        }
        let one = try RuntimeCanonicalReplayCheckpoint.testOnlyMake(
            reconstruction: reconstruction,
            sourceChainDigest: String(repeating: "1", count: 64),
            createdAt: Date(timeIntervalSince1970: 1_800_000_000)
        )
        let two = try RuntimeCanonicalReplayCheckpoint.testOnlyMake(
            reconstruction: reconstruction,
            sourceChainDigest: String(repeating: "2", count: 64),
            createdAt: Date(timeIntervalSince1970: 1_800_000_000)
        )
        XCTAssertNotEqual(one.manifestDigest, two.manifestDigest)
    }

    func testTransitionCollectionRejectsDuplicateFamilyIDAndWrongSemanticPrimary() throws {
        let event = try captureEvent(
            id: "transition-collection", revision: 0, prior: nil,
            action: .quickCapture(externalCreation: nil)
        )
        let transition = try XCTUnwrap(event.mutation.aggregateTransitions.first)
        XCTAssertThrowsError(try RuntimeSemanticMutation(
            semanticType: .captureCreated,
            aggregateID: transition.aggregate.id,
            priorRevision: nil,
            resultingRevision: 0,
            changedObjectIDs: event.mutation.changedObjectIDs,
            primaryAggregate: transition.aggregate,
            aggregateTransitions: [transition, transition]
        ))
        XCTAssertThrowsError(try RuntimeSemanticMutation(
            semanticType: .goalCreated,
            aggregateID: transition.aggregate.id,
            priorRevision: nil,
            resultingRevision: 0,
            changedObjectIDs: event.mutation.changedObjectIDs,
            primaryAggregate: transition.aggregate,
            aggregateTransitions: [transition]
        ))
    }

    func testReplayAppliesMultiTransitionEventAllOrNoneWhenSecondaryFails() throws {
        let id = try RuntimeAggregateID(validating: "atomic-multi-transition")
        let changed = [try RuntimeDomainObjectID(validating: id.rawValue)]
        let command = CaptureCommand(
            action: .quickCapture(externalCreation: nil),
            target: AmbitionsCommandTarget(captureID: id.rawValue, goalID: id.rawValue),
            content: RuntimeCommandContent(AmbitionsCommandPayload(title: "Atomic"))
        )
        let capture = RuntimeSemanticAggregate(kind: .capture, id: id)
        let goal = RuntimeSemanticAggregate(kind: .goal, id: id)
        func transition(
            aggregate: RuntimeSemanticAggregate,
            prior: UInt64?,
            revision: UInt64,
            kind: RuntimeObjectTransitionKind
        ) throws -> RuntimeSemanticAggregateTransition {
            let state = RuntimeCanonicalAggregateState(
                aggregate: aggregate, revision: revision, lifecycle: .active,
                transition: kind, commandPayload: .capture(command), changedObjectIDs: changed
            )
            let bytes = try RuntimeCanonicalAggregateStateCodec().encode(state)
            return RuntimeSemanticAggregateTransition(
                aggregate: aggregate, priorRevision: prior, resultingRevision: revision,
                lifecycle: .active, transition: kind, canonicalStateBytes: bytes,
                canonicalStateDigest: LocalRuntimeStorageChecksum.sha256Hex(for: bytes),
                tombstone: nil
            )
        }
        let mutation = try RuntimeSemanticMutation(
            semanticType: .captureCreated,
            aggregateID: id,
            priorRevision: nil,
            resultingRevision: 0,
            changedObjectIDs: changed,
            primaryAggregate: capture,
            aggregateTransitions: [
                try transition(aggregate: capture, prior: nil, revision: 0, kind: .create),
                try transition(aggregate: goal, prior: 0, revision: 1, kind: .update),
            ]
        )
        let event = RuntimeSemanticEvent.capture(.created(
            try RuntimeCaptureMutationPayload(mutation: mutation, facts: command)
        ))
        let record = try semanticRecord(event: event, sequence: 1)
        guard case let .blocked(evidence, retained) = RuntimeCanonicalReplayReducer().apply(record, to: .empty) else {
            return XCTFail("Missing secondary authority must reject the entire event")
        }
        XCTAssertEqual(evidence.code, .aggregateMissing)
        XCTAssertEqual(retained, .empty)
    }

    func testDefaultDenyRetentionEnumeratesEveryCurrentAuthorityBlocker() {
        let evidence = RuntimeCanonicalRetentionEvidence(
            hasUnknownOrCorruptEvents: true,
            hasQuarantineOccurrences: true,
            hasUnresolvedProjectionWork: true,
            hasUnresolvedExternalWork: true,
            hasRetainedReceipts: true,
            hasRetainedIdempotency: true,
            hasRetainedLineage: true,
            hasRecoveryNeeds: true,
            hasExplicitHolds: true,
            downstreamReceiptPolicyAvailable: false,
            downstreamExternalPolicyAvailable: false,
            downstreamBlobPolicyAvailable: false
        )
        let eligibility = RuntimeCanonicalRetentionPolicy().evaluate(evidence)
        XCTAssertFalse(eligibility.destructivePruneAllowed)
        XCTAssertTrue(eligibility.checkpointAllowed)
        XCTAssertEqual(Set(eligibility.blockers), Set(RuntimeCanonicalRetentionBlocker.allCases))
    }

    func testCurrentCompactionIsCheckpointOnlyAndNeverDestructive() {
        let cursor = RuntimeCanonicalReplayCursor(
            sequence: 9,
            eventID: "event-9",
            eventHash: String(repeating: "a", count: 64)
        )
        let eligibility = RuntimeCanonicalRetentionEligibility(
            checkpointAllowed: true,
            destructivePruneAllowed: false,
            blockers: [.downstreamAuthorityUnavailable]
        )
        let plan = RuntimeCanonicalCompactionPlanner().plan(
            verifiedCursor: cursor,
            stateDigest: String(repeating: "b", count: 64),
            eligibility: eligibility
        )
        XCTAssertEqual(plan.disposition, .checkpointOnly)
        XCTAssertNil(plan.pruneThroughSequence)
        XCTAssertEqual(plan.revalidationAnchor, cursor)
    }

    func testCheckpointAnchorRequiresExactIdentityAndHash() {
        let anchor = RuntimeCanonicalReplayCursor(
            sequence: 4,
            eventID: "event-4",
            eventHash: String(repeating: "c", count: 64)
        )
        XCTAssertTrue(anchor.isWellFormed)
        XCTAssertTrue(anchor.matchesSourceAnchor(
            eventID: "event-4",
            eventHash: String(repeating: "c", count: 64)
        ))
        XCTAssertFalse(anchor.matchesSourceAnchor(
            eventID: "event-other",
            eventHash: String(repeating: "c", count: 64)
        ))
        XCTAssertFalse(anchor.matchesSourceAnchor(
            eventID: "event-4",
            eventHash: String(repeating: "d", count: 64)
        ))
        XCTAssertFalse(RuntimeCanonicalReplayCursor(
            sequence: 4,
            eventID: "event-4",
            eventHash: "private-value"
        ).isWellFormed)
    }

    func testSQLiteGenesisCheckpointTailResumeAndImmutableAttestationBinding() async throws {
        let database = try await makeReplayDatabase(label: "genesis-checkpoint-tail")
        let created = try captureEvent(
            id: "sqlite-checkpoint", revision: 0, prior: nil,
            action: .quickCapture(externalCreation: nil)
        )
        _ = try await Self.appendAndMaterialize(created, sequenceHint: 1, database: database)
        let genesis = try await database.transaction(.immediate) { database in
            try RuntimeCanonicalReplayEngine.replayInTransaction(database: database)
        }
        guard case let .complete(reconstruction) = genesis,
              let cursor = reconstruction.cursor else {
            return XCTFail("Expected verified genesis replay")
        }
        let attestations = try await database.query(
            "SELECT event_sequence, source_chain_digest, reconstruction_digest FROM runtime_replay_verified_reconstructions"
        )
        XCTAssertEqual(attestations.count, 1)
        XCTAssertEqual(attestations[0].value(named: "event_sequence"), .integer(1))
        XCTAssertEqual(attestations[0].value(named: "reconstruction_digest"), .text(reconstruction.stateDigest))
        let eligibility = RuntimeCanonicalRetentionPolicy().evaluate(
            try await database.transaction(.immediate) { database in
                try RuntimeCanonicalReplayEngine.retentionEvidenceInTransaction(database: database)
            }
        )
        let plan = RuntimeCanonicalCompactionPlanner().plan(
            verifiedCursor: cursor,
            stateDigest: reconstruction.stateDigest,
            eligibility: eligibility
        )
        let cancelled = Task { () -> Bool in
            withUnsafeCurrentTask { $0?.cancel() }
            do {
                _ = try await database.transaction(.immediate) { database in
                    try RuntimeCanonicalReplayEngine.applyCompactionInTransaction(
                        plan,
                        reconstruction: reconstruction,
                        createdAt: Date(timeIntervalSince1970: 1_800_000_099),
                        database: database
                    )
                }
                return false
            } catch is CancellationError {
                return true
            } catch {
                return false
            }
        }
        let wasCancelled = await cancelled.value
        XCTAssertTrue(wasCancelled)
        let checkpointsAfterCancellation = try await database.query("SELECT 1 FROM runtime_replay_checkpoints")
        XCTAssertTrue(checkpointsAfterCancellation.isEmpty)
        let checkpoint = try await database.transaction(.immediate) { database in
            try RuntimeCanonicalReplayEngine.applyCompactionInTransaction(
                plan,
                reconstruction: reconstruction,
                createdAt: Date(timeIntervalSince1970: 1_800_000_100),
                database: database
            )
        }
        let checkpointID = "checkpoint.\(checkpoint.highWaterCursor.sequence).\(checkpoint.manifestDigest)"
        let beforeDuplicate = try await database.query(
            "SELECT COUNT(*) AS count FROM runtime_replay_checkpoints"
        )
        do {
            _ = try await database.transaction(.immediate) { database in
                try RuntimeCanonicalReplayEngine.applyCompactionInTransaction(
                    plan,
                    reconstruction: reconstruction,
                    createdAt: checkpoint.createdAt,
                    database: database
                )
            }
            XCTFail("Strict checkpoint publication must reject a duplicate instead of repairing it")
        } catch {}
        XCTAssertEqual(
            try await database.query("SELECT COUNT(*) AS count FROM runtime_replay_checkpoints"),
            beforeDuplicate
        )
        let update = try captureEvent(
            id: "sqlite-checkpoint", revision: 1, prior: 0, action: .markWaiting
        )
        _ = try await Self.appendAndMaterialize(update, sequenceHint: 2, database: database)
        do {
            _ = try await database.transaction(.immediate) { database in
                try RuntimeCanonicalReplayEngine.applyCompactionInTransaction(
                    plan,
                    reconstruction: reconstruction,
                    createdAt: Date(timeIntervalSince1970: 1_800_000_101),
                    database: database
                )
            }
            XCTFail("A stale compaction plan must not publish after the tail advances")
        } catch {}
        let resumed = try await database.transaction(.immediate) { database in
            try RuntimeCanonicalReplayEngine.replayInTransaction(
                database: database,
                checkpointID: checkpointID
            )
        }
        guard case let .complete(tail) = resumed else { return XCTFail("Expected checkpoint tail replay") }
        XCTAssertEqual(tail.cursor?.sequence, 2)
        XCTAssertEqual(tail.aggregates.first?.state.revision, 1)
        try await database.execute("DROP TRIGGER runtime_replay_checkpoint_aggregates_immutable_delete")
        try await database.execute(
            "DELETE FROM runtime_replay_checkpoint_aggregates WHERE checkpoint_id = ?",
            bindings: [.text(checkpointID)]
        )
        let aggregateDeleteTrigger = try XCTUnwrap(
            CanonicalRuntimeReplaySchemaPlan.statements.first {
                $0.contains("CREATE TRIGGER runtime_replay_checkpoint_aggregates_immutable_delete")
            }
        )
        try await database.execute(aggregateDeleteTrigger)
        do {
            _ = try await database.transaction(.immediate) { database in
                try RuntimeCanonicalReplayEngine.loadCheckpointInTransaction(
                    checkpointID: checkpointID,
                    database: database
                )
            }
            XCTFail("A partial checkpoint must never be loaded or silently repaired")
        } catch {}
    }

    func testSQLiteReplayCrossesKeysetPageBoundaryWithoutSkippingOrDuplicating() async throws {
        let database = try await makeReplayDatabase(label: "multipage")
        _ = try await Self.appendAndMaterialize(
            captureEvent(id: "multipage-capture", revision: 0, prior: nil, action: .quickCapture(externalCreation: nil)),
            sequenceHint: 1,
            database: database
        )
        for revision in 1...UInt64(CanonicalRuntimeSemanticEventStore.maximumPageLimit + 1) {
            _ = try await Self.appendAndMaterialize(
                captureEvent(
                    id: "multipage-capture", revision: revision,
                    prior: revision - 1, action: .markWaiting
                ),
                sequenceHint: revision + 1,
                database: database
            )
        }
        let replay = try await database.transaction(.immediate) { database in
            try RuntimeCanonicalReplayEngine.replayInTransaction(database: database)
        }
        guard case let .complete(value) = replay else { return XCTFail("Expected multipage replay") }
        XCTAssertEqual(
            value.cursor?.sequence,
            UInt64(CanonicalRuntimeSemanticEventStore.maximumPageLimit + 2)
        )
        XCTAssertEqual(
            value.aggregates.first?.state.revision,
            UInt64(CanonicalRuntimeSemanticEventStore.maximumPageLimit + 1)
        )
    }

    func testCheckpointAttestationAndHighWaterMutualDigestForgeryCannotReplaceSourcePrefix() async throws {
        let database = try await makeReplayDatabase(label: "checkpoint-mutual-forgery")
        _ = try await Self.appendAndMaterialize(
            captureEvent(id: "forged-prefix", revision: 0, prior: nil, action: .quickCapture(externalCreation: nil)),
            sequenceHint: 1,
            database: database
        )
        let replay = try await database.transaction(.immediate) { database in
            try RuntimeCanonicalReplayEngine.replayInTransaction(database: database)
        }
        guard case let .complete(reconstruction) = replay,
              let cursor = reconstruction.cursor else {
            return XCTFail("Expected verified reconstruction")
        }
        let eligibility = RuntimeCanonicalRetentionPolicy().evaluate(
            try await database.transaction(.immediate) { database in
                try RuntimeCanonicalReplayEngine.retentionEvidenceInTransaction(database: database)
            }
        )
        let plan = RuntimeCanonicalCompactionPlanner().plan(
            verifiedCursor: cursor,
            stateDigest: reconstruction.stateDigest,
            eligibility: eligibility
        )
        let checkpoint = try await database.transaction(.immediate) { database in
            try RuntimeCanonicalReplayEngine.applyCompactionInTransaction(
                plan,
                reconstruction: reconstruction,
                createdAt: Date(timeIntervalSince1970: 1_800_000_110),
                database: database
            )
        }
        let originalID = "checkpoint.\(checkpoint.highWaterCursor.sequence).\(checkpoint.manifestDigest)"
        let forged = try RuntimeCanonicalReplayCheckpoint.testOnlyMake(
            reconstruction: reconstruction,
            sourceChainDigest: String(repeating: "f", count: 64),
            createdAt: checkpoint.createdAt
        )
        let forgedID = "checkpoint.\(forged.highWaterCursor.sequence).\(forged.manifestDigest)"
        let forgedHeader = try RuntimeCanonicalReplayEngine.testOnlyCheckpointHeaderBytes(forged)
        let forgedChecksum = LocalRuntimeStorageChecksum.sha256Hex(for: forgedHeader)
        let triggerNames = [
            "runtime_replay_checkpoints_immutable_update",
            "runtime_replay_checkpoint_aggregates_immutable_update",
            "runtime_replay_checkpoint_tombstones_immutable_update",
            "runtime_replay_verified_reconstructions_immutable_update",
        ]
        for name in triggerNames {
            try await database.execute("DROP TRIGGER \(name)")
        }
        try await database.transaction(.immediate) { database in
            try database.execute("PRAGMA defer_foreign_keys = ON")
            try database.execute(
                """
                UPDATE runtime_replay_checkpoints
                SET checkpoint_id = ?, source_chain_digest = ?, manifest_digest = ?,
                    payload = ?, payload_checksum = ?
                WHERE checkpoint_id = ?
                """,
                bindings: [
                    .text(forgedID), .text(forged.sourceChainDigest),
                    .text(forged.manifestDigest), .blob(forgedHeader),
                    .text(forgedChecksum), .text(originalID),
                ]
            )
            try database.execute(
                "UPDATE runtime_replay_checkpoint_aggregates SET checkpoint_id = ? WHERE checkpoint_id = ?",
                bindings: [.text(forgedID), .text(originalID)]
            )
            try database.execute(
                "UPDATE runtime_replay_checkpoint_tombstones SET checkpoint_id = ? WHERE checkpoint_id = ?",
                bindings: [.text(forgedID), .text(originalID)]
            )
            try database.execute(
                "UPDATE runtime_replay_verified_reconstructions SET source_chain_digest = ? WHERE event_sequence = ?",
                bindings: [.text(forged.sourceChainDigest), .integer(Int64(cursor.sequence))]
            )
            try database.execute(
                "UPDATE runtime_replay_verified_high_water SET chain_anchor_digest = ? WHERE singleton_id = 1",
                bindings: [.text(forged.sourceChainDigest)]
            )
        }
        for name in triggerNames {
            let statement = try XCTUnwrap(CanonicalRuntimeReplaySchemaPlan.statements.first {
                $0.contains("CREATE TRIGGER \(name)")
            })
            try await database.execute(statement)
        }
        do {
            _ = try await database.transaction(.immediate) { database in
                try RuntimeCanonicalReplayEngine.loadCheckpointInTransaction(
                    checkpointID: forgedID,
                    database: database
                )
            }
            XCTFail("Mutually forged checkpoint, attestation, and high-water digests must not replace authenticated source bytes")
        } catch {}
    }

    func testCheckpointLoadAuthenticatesEverySourceRowInItsPrefix() async throws {
        let database = try await makeReplayDatabase(label: "checkpoint-prefix-source")
        _ = try await Self.appendAndMaterialize(
            captureEvent(id: "prefix-source", revision: 0, prior: nil, action: .quickCapture(externalCreation: nil)),
            sequenceHint: 1,
            database: database
        )
        _ = try await Self.appendAndMaterialize(
            captureEvent(id: "prefix-source", revision: 1, prior: 0, action: .markWaiting),
            sequenceHint: 2,
            database: database
        )
        let replay = try await database.transaction(.immediate) { database in
            try RuntimeCanonicalReplayEngine.replayInTransaction(database: database)
        }
        guard case let .complete(reconstruction) = replay,
              let cursor = reconstruction.cursor else {
            return XCTFail("Expected verified prefix")
        }
        let eligibility = RuntimeCanonicalRetentionPolicy().evaluate(
            try await database.transaction(.immediate) { database in
                try RuntimeCanonicalReplayEngine.retentionEvidenceInTransaction(database: database)
            }
        )
        let checkpoint = try await database.transaction(.immediate) { database in
            try RuntimeCanonicalReplayEngine.applyCompactionInTransaction(
                RuntimeCanonicalCompactionPlanner().plan(
                    verifiedCursor: cursor,
                    stateDigest: reconstruction.stateDigest,
                    eligibility: eligibility
                ),
                reconstruction: reconstruction,
                createdAt: Date(timeIntervalSince1970: 1_800_000_111),
                database: database
            )
        }
        let checkpointID = "checkpoint.\(checkpoint.highWaterCursor.sequence).\(checkpoint.manifestDigest)"
        try await database.execute("DROP TRIGGER runtime_semantic_events_immutable_update")
        try await database.execute(
            "UPDATE runtime_semantic_events SET source_bytes = zeroblob(length(source_bytes)) WHERE sequence = 1"
        )
        let trigger = try XCTUnwrap(CanonicalRuntimeSemanticEventSchemaPlan.statements.first {
            $0.contains("CREATE TRIGGER runtime_semantic_events_immutable_update")
        })
        try await database.execute(trigger)
        do {
            _ = try await database.transaction(.immediate) { database in
                try RuntimeCanonicalReplayEngine.loadCheckpointInTransaction(
                    checkpointID: checkpointID,
                    database: database
                )
            }
            XCTFail("Checkpoint load must authenticate every source row in the prefix")
        } catch {}
    }

    func testCheckpointColumnsHashesHighWaterAndAttestationEachFailClosed() async throws {
        let database = try await makeReplayDatabase(label: "checkpoint-bindings")
        _ = try await Self.appendAndMaterialize(
            captureEvent(id: "checkpoint-bindings", revision: 0, prior: nil, action: .quickCapture(externalCreation: nil)),
            sequenceHint: 1,
            database: database
        )
        let replay = try await database.transaction(.immediate) { database in
            try RuntimeCanonicalReplayEngine.replayInTransaction(database: database)
        }
        guard case let .complete(reconstruction) = replay,
              let cursor = reconstruction.cursor else {
            return XCTFail("Expected verified reconstruction")
        }
        let eligibility = RuntimeCanonicalRetentionPolicy().evaluate(
            try await database.transaction(.immediate) { database in
                try RuntimeCanonicalReplayEngine.retentionEvidenceInTransaction(database: database)
            }
        )
        let checkpoint = try await database.transaction(.immediate) { database in
            try RuntimeCanonicalReplayEngine.applyCompactionInTransaction(
                RuntimeCanonicalCompactionPlanner().plan(
                    verifiedCursor: cursor,
                    stateDigest: reconstruction.stateDigest,
                    eligibility: eligibility
                ),
                reconstruction: reconstruction,
                createdAt: Date(timeIntervalSince1970: 1_800_000_112),
                database: database
            )
        }
        let checkpointID = "checkpoint.\(checkpoint.highWaterCursor.sequence).\(checkpoint.manifestDigest)"
        let stored = try await database.query(
            "SELECT payload_checksum FROM runtime_replay_checkpoints WHERE checkpoint_id = ?",
            bindings: [.text(checkpointID)]
        )
        guard case let .text(payloadChecksum)? = stored.first?.value(named: "payload_checksum") else {
            return XCTFail("Expected checkpoint checksum")
        }
        try await database.execute("DROP TRIGGER runtime_replay_checkpoints_immutable_update")
        for mutation in [
            "UPDATE runtime_replay_checkpoints SET high_water_event_id = 'forged-event' WHERE checkpoint_id = '\(checkpointID)'",
            "UPDATE runtime_replay_checkpoints SET high_water_event_hash = '\(String(repeating: "e", count: 64))' WHERE checkpoint_id = '\(checkpointID)'",
            "UPDATE runtime_replay_checkpoints SET payload_checksum = '\(String(repeating: "d", count: 64))' WHERE checkpoint_id = '\(checkpointID)'",
        ] {
            try await database.execute(mutation)
            do {
                _ = try await database.transaction(.immediate) { database in
                    try RuntimeCanonicalReplayEngine.loadCheckpointInTransaction(
                        checkpointID: checkpointID,
                        database: database
                    )
                }
                XCTFail("Forged checkpoint column or hash must fail closed")
            } catch {}
            try await database.execute(
                """
                UPDATE runtime_replay_checkpoints
                SET high_water_event_id = ?, high_water_event_hash = ?, payload_checksum = ?
                WHERE checkpoint_id = ?
                """,
                bindings: [
                    .text(cursor.eventID), .text(cursor.eventHash),
                    .text(payloadChecksum), .text(checkpointID),
                ]
            )
        }
        let checkpointTrigger = try XCTUnwrap(CanonicalRuntimeReplaySchemaPlan.statements.first {
            $0.contains("CREATE TRIGGER runtime_replay_checkpoints_immutable_update")
        })
        try await database.execute(checkpointTrigger)

        try await database.execute(
            "UPDATE runtime_replay_verified_high_water SET event_id = 'forged-high-water' WHERE singleton_id = 1"
        )
        let highWaterEvidence = try await database.transaction(.immediate) { database in
            try RuntimeCanonicalReplayEngine.retentionEvidenceInTransaction(database: database)
        }
        XCTAssertTrue(highWaterEvidence.hasUnknownOrCorruptEvents)
        try await database.execute(
            "UPDATE runtime_replay_verified_high_water SET event_id = ? WHERE singleton_id = 1",
            bindings: [.text(cursor.eventID)]
        )

        try await database.execute("DROP TRIGGER runtime_replay_verified_reconstructions_immutable_update")
        try await database.execute(
            "UPDATE runtime_replay_verified_reconstructions SET event_hash = ? WHERE event_sequence = ?",
            bindings: [.text(String(repeating: "c", count: 64)), .integer(Int64(cursor.sequence))]
        )
        do {
            _ = try await database.transaction(.immediate) { database in
                try RuntimeCanonicalReplayEngine.loadCheckpointInTransaction(
                    checkpointID: checkpointID,
                    database: database
                )
            }
            XCTFail("Forged attestation must fail checkpoint loading")
        } catch {}
    }

    func testSQLiteSchemaTamperAndVerifiedAttestationMutationFailClosed() async throws {
        let database = try await makeReplayDatabase(label: "schema-attestation-tamper")
        _ = try await Self.appendAndMaterialize(
            captureEvent(id: "tamper-capture", revision: 0, prior: nil, action: .quickCapture(externalCreation: nil)),
            sequenceHint: 1,
            database: database
        )
        _ = try await database.transaction(.immediate) { database in
            try RuntimeCanonicalReplayEngine.replayInTransaction(database: database)
        }
        do {
            try await database.execute(
                "UPDATE runtime_replay_verified_reconstructions SET reconstruction_digest = ? WHERE event_sequence = 1",
                bindings: [.text(String(repeating: "f", count: 64))]
            )
            XCTFail("Verified reconstruction attestation must be immutable")
        } catch {}
        try await database.execute("DROP TRIGGER runtime_replay_verified_reconstructions_immutable_update")
        do {
            try await database.transaction(.immediate) { database in
                try CanonicalRuntimeReplaySchemaPlan.requireIntegratedSchema(in: database)
            }
            XCTFail("Exact schema validation must reject a missing attestation trigger")
        } catch {}
    }

    func testSQLiteExactSchemaCatalogRejectsSameNameWrongIndexDefinition() async throws {
        let database = try await makeReplayDatabase(label: "schema-index-definition")
        try await database.execute("DROP INDEX runtime_replay_checkpoints_sequence_idx")
        try await database.execute(
            "CREATE INDEX runtime_replay_checkpoints_sequence_idx ON runtime_replay_checkpoints(checkpoint_id, high_water_sequence)"
        )
        do {
            try await database.transaction(.immediate) { database in
                try CanonicalRuntimeReplaySchemaPlan.requireIntegratedSchema(in: database)
            }
            XCTFail("Exact normalized SQL and index_xinfo validation must reject a same-name wrong index")
        } catch {}
    }

    func testSQLiteActorSerializedTaskGroupMaintainsOneConditionalHighWaterChain() async throws {
        let database = try await makeReplayDatabase(label: "high-water-race")
        let first = try captureEvent(
            id: "race-a", revision: 0, prior: nil, action: .quickCapture(externalCreation: nil)
        )
        let second = try captureEvent(
            id: "race-b", revision: 0, prior: nil, action: .quickCapture(externalCreation: nil)
        )
        let outcomes = await withTaskGroup(of: Bool.self, returning: [Bool].self) { group in
            group.addTask {
                (try? await Self.appendAndMaterialize(first, sequenceHint: 1, database: database)) != nil
            }
            group.addTask {
                (try? await Self.appendAndMaterialize(second, sequenceHint: 2, database: database)) != nil
            }
            return await group.reduce(into: []) { $0.append($1) }
        }
        XCTAssertEqual(outcomes.filter { $0 }.count, 2)
        let marker = try await database.query(
            "SELECT event_sequence, chain_anchor_digest FROM runtime_replay_verified_high_water WHERE singleton_id = 1"
        )
        XCTAssertEqual(marker.count, 1)
        XCTAssertEqual(marker[0].value(named: "event_sequence"), .integer(2))
        guard case let .text(digest)? = marker[0].value(named: "chain_anchor_digest") else {
            return XCTFail("Expected chained high-water digest")
        }
        XCTAssertTrue(RuntimeStoreManifestCodec.isSHA256Hex(digest))
    }

    func testSQLiteV1ReplayIsAmbiguousAndMalformedFutureEventsRemainQuarantined() async throws {
        let legacyDatabase = try await makeReplayDatabase(label: "legacy-v1")
        let command = CaptureCommand(
            action: .quickCapture(externalCreation: nil),
            target: AmbitionsCommandTarget(captureID: "legacy-v1-capture"),
            content: RuntimeCommandContent(AmbitionsCommandPayload(title: "Legacy"))
        )
        let mutation = try RuntimeSemanticMutation(
            semanticType: .captureCreated,
            aggregateID: RuntimeAggregateID(validating: "legacy-v1-capture"),
            priorRevision: nil,
            resultingRevision: 0,
            changedObjectIDs: [try RuntimeDomainObjectID(validating: "legacy-v1-capture")]
        )
        let legacy = RuntimeSemanticEvent.capture(.created(
            try RuntimeCaptureMutationPayload(mutation: mutation, facts: command)
        ))
        let legacyBytes = try RuntimeSemanticEventCodec().encode(legacy)
        XCTAssertEqual(try RuntimeSemanticEventCodec().inspectHeader(legacyBytes).payloadVersion, 1)
        try await legacyDatabase.transaction(.immediate) { database in
            let outcome = try CanonicalRuntimeSemanticEventStore.appendInTransaction(
                try CanonicalRuntimeSemanticEventAppendRequest(
                    eventID: RuntimeEventID(validating: "legacy-v1-event"),
                    commandID: RuntimeCommandID(validating: "legacy-v1-command"),
                    aggregate: RuntimeSemanticAggregate(
                        kind: .capture,
                        id: RuntimeAggregateID(validating: "legacy-v1-capture")
                    ),
                    canonicalAggregateRevision: 0,
                    correlationID: RuntimeCorrelationID(validating: "legacy-v1-correlation"),
                    causationEventID: nil,
                    occurredAt: Date(timeIntervalSince1970: 1_800_000_000),
                    canonicalBytes: legacyBytes
                ),
                to: database
            )
            guard case .appended = outcome else { throw RuntimeCanonicalReplayError.corruptAuthority }
        }
        let legacyReplay = try await legacyDatabase.transaction(.immediate) { database in
            try RuntimeCanonicalReplayEngine.replayInTransaction(database: database)
        }
        guard case let .blocked(divergence, prefix) = legacyReplay else {
            return XCTFail("V1 replay must not guess canonical aggregate state")
        }
        XCTAssertEqual(divergence.code, .legacyReplayAmbiguous)
        XCTAssertEqual(prefix, .empty)

        for (label, bytes) in [
            ("malformed", Data("{".utf8)),
            ("future", Data(String(decoding: legacyBytes, as: UTF8.self)
                .replacingOccurrences(of: "\"payload_version\":1", with: "\"payload_version\":999")
                .utf8)),
        ] {
            let database = try await makeReplayDatabase(label: "quarantine-\(label)")
            let outcome = try await database.transaction(.immediate) { database in
                try CanonicalRuntimeSemanticEventStore.appendInTransaction(
                    try CanonicalRuntimeSemanticEventAppendRequest(
                        eventID: RuntimeEventID(validating: "quarantine-\(label)-event"),
                        commandID: RuntimeCommandID(validating: "quarantine-\(label)-command"),
                        aggregate: RuntimeSemanticAggregate(
                            kind: .capture,
                            id: RuntimeAggregateID(validating: "quarantine-\(label)-capture")
                        ),
                        canonicalAggregateRevision: 0,
                        correlationID: RuntimeCorrelationID(validating: "quarantine-\(label)-correlation"),
                        causationEventID: nil,
                        occurredAt: Date(timeIntervalSince1970: 1_800_000_000),
                        canonicalBytes: bytes
                    ),
                    to: database
                )
            }
            guard case .quarantined = outcome else { return XCTFail("Expected \(label) quarantine") }
            let replay = try await database.transaction(.immediate) { database in
                try RuntimeCanonicalReplayEngine.replayInTransaction(database: database)
            }
            guard case let .blocked(evidence, _) = replay else {
                return XCTFail("Quarantine must block replay")
            }
            XCTAssertEqual(evidence.code, .quarantinePresent)
            XCTAssertNil(evidence.privatePayload)
        }
    }

    func testTombstoneParityContainsEveryMalformedAndStructuralFailureAsRedactedDivergence() async throws {
        let reconstruction = try tombstonedCaptureReconstruction()
        let tombstone = try XCTUnwrap(reconstruction.tombstones.first)
        let correct = try tombstoneDraft(tombstone)
        let malformed = Data("{".utf8)
        let wrongFamily = RuntimeCanonicalTombstoneDraft(
            objectID: correct.objectID, family: RuntimeSemanticAggregateKind.goal.rawValue,
            terminalRevision: correct.terminalRevision, lineage: correct.lineage, authority: correct.authority
        )
        let wrongRevision = RuntimeCanonicalTombstoneDraft(
            objectID: correct.objectID, family: correct.family,
            terminalRevision: correct.terminalRevision + 1, lineage: correct.lineage, authority: correct.authority
        )
        let wrongLineage = RuntimeCanonicalTombstoneDraft(
            objectID: correct.objectID, family: correct.family,
            terminalRevision: correct.terminalRevision,
            lineage: RuntimeAuthorityLineageReference(
                eventID: try RuntimeEventID(validating: "wrong-event"),
                eventSequence: correct.lineage.eventSequence + 1,
                eventHash: String(repeating: "f", count: 64)
            ),
            authority: correct.authority
        )
        let cases: [(String, Data?, String, UInt64, UInt64)] = [
            ("malformed", malformed, correct.family, correct.terminalRevision, correct.lineage.eventSequence),
            ("structurally-wrong-family", try canonicalTombstoneBytes(wrongFamily), correct.family, correct.terminalRevision, correct.lineage.eventSequence),
            ("wrong-row-family", try canonicalTombstoneBytes(correct), RuntimeSemanticAggregateKind.goal.rawValue, correct.terminalRevision, correct.lineage.eventSequence),
            ("wrong-row-revision", try canonicalTombstoneBytes(correct), correct.family, correct.terminalRevision + 1, correct.lineage.eventSequence),
            ("wrong-payload-revision", try canonicalTombstoneBytes(wrongRevision), correct.family, correct.terminalRevision, correct.lineage.eventSequence),
            ("wrong-lineage", try canonicalTombstoneBytes(wrongLineage), correct.family, correct.terminalRevision, correct.lineage.eventSequence),
            ("missing", nil, correct.family, correct.terminalRevision, correct.lineage.eventSequence),
        ]
        for (label, payload, family, revision, sequence) in cases {
            let database = try await makeReplayDatabase(label: "tombstone-\(label)")
            if let payload {
                try await insertTombstoneRow(
                    payload: payload, objectID: correct.objectID.rawValue,
                    family: family, revision: revision, sequence: sequence,
                    database: database
                )
            }
            let divergence = try await database.transaction(.immediate) { database in
                try RuntimeCanonicalReplayEngine.testOnlyFirstLiveTombstoneDivergence(
                    reconstruction,
                    database: database
                )
            }
            XCTAssertEqual(divergence?.code, .liveTombstoneDivergence, label)
            XCTAssertEqual(divergence?.divergentEventID, tombstone.causalCursor.eventID, label)
            XCTAssertNil(divergence?.privatePayload, label)
        }

        let extraDatabase = try await makeReplayDatabase(label: "tombstone-extra")
        let correctBytes = try canonicalTombstoneBytes(correct)
        try await insertTombstoneRow(
            payload: correctBytes, objectID: correct.objectID.rawValue,
            family: correct.family, revision: correct.terminalRevision,
            sequence: correct.lineage.eventSequence, database: extraDatabase
        )
        let extraDraft = RuntimeCanonicalTombstoneDraft(
            objectID: try RuntimeDomainObjectID(validating: "unexpected-tombstone"),
            family: RuntimeSemanticAggregateKind.goal.rawValue,
            terminalRevision: 1, lineage: correct.lineage, authority: correct.authority
        )
        try await insertTombstoneRow(
            payload: try canonicalTombstoneBytes(extraDraft), objectID: extraDraft.objectID.rawValue,
            family: extraDraft.family, revision: extraDraft.terminalRevision,
            sequence: extraDraft.lineage.eventSequence, database: extraDatabase
        )
        let extra = try await extraDatabase.transaction(.immediate) { database in
            try RuntimeCanonicalReplayEngine.testOnlyFirstLiveTombstoneDivergence(
                reconstruction,
                database: database
            )
        }
        XCTAssertEqual(extra?.code, .liveTombstoneDivergence)
        XCTAssertNil(extra?.privatePayload)
    }

    func testLiveAggregateParityReportsExactRedactedMissingExtraFamilyRevisionAndPayloadFacts() async throws {
        let event = try captureEvent(
            id: "live-aggregate-parity", revision: 0, prior: nil,
            action: .quickCapture(externalCreation: nil)
        )
        let record = try semanticRecord(event: event, sequence: 1)
        guard case let .accepted(reconstruction) = RuntimeCanonicalReplayReducer().apply(record, to: .empty),
              let expected = reconstruction.aggregates.first else {
            return XCTFail("Expected aggregate reconstruction")
        }
        let cases: [(String, String, String, UInt64, Data, String)] = [
            ("wrong-family", "goal", expected.state.aggregate.id.rawValue, expected.state.revision, expected.canonicalBytes, expected.stateDigest),
            ("wrong-id", expected.state.aggregate.kind.rawValue, "other-id", expected.state.revision, expected.canonicalBytes, expected.stateDigest),
            ("wrong-revision", expected.state.aggregate.kind.rawValue, expected.state.aggregate.id.rawValue, 9, expected.canonicalBytes, expected.stateDigest),
            ("wrong-payload", expected.state.aggregate.kind.rawValue, expected.state.aggregate.id.rawValue, expected.state.revision, Data("private-corruption".utf8), LocalRuntimeStorageChecksum.sha256Hex(for: Data("private-corruption".utf8))),
        ]
        let missingDatabase = try await makeReplayDatabase(label: "aggregate-missing")
        let missing = try await missingDatabase.transaction(.immediate) { database in
            try RuntimeCanonicalReplayEngine.testOnlyFirstLiveAggregateDivergence(
                reconstruction,
                database: database
            )
        }
        XCTAssertEqual(missing?.divergentEventID, expected.lastEvent.eventID)
        XCTAssertNil(missing?.privatePayload)
        for (label, family, objectID, revision, payload, checksum) in cases {
            let database = try await makeReplayDatabase(label: "aggregate-\(label)")
            try await database.execute(
                """
                INSERT INTO runtime_aggregates(
                    aggregate_kind, aggregate_id, revision, payload_version, payload, payload_checksum
                ) VALUES (?, ?, ?, 1, ?, ?)
                """,
                bindings: [
                    .text(family), .text(objectID), .integer(Int64(revision)),
                    .blob(payload), .text(checksum),
                ]
            )
            let divergence = try await database.transaction(.immediate) { database in
                try RuntimeCanonicalReplayEngine.testOnlyFirstLiveAggregateDivergence(
                    reconstruction,
                    database: database
                )
            }
            XCTAssertEqual(divergence?.code, .liveStateDivergence, label)
            XCTAssertNil(divergence?.privatePayload, label)
        }
        let extraDatabase = try await makeReplayDatabase(label: "aggregate-extra")
        for objectID in [expected.state.aggregate.id.rawValue, "zz-extra-aggregate"] {
            try await extraDatabase.execute(
                "INSERT INTO runtime_aggregates(aggregate_kind, aggregate_id, revision, payload_version, payload, payload_checksum) VALUES ('capture', ?, 0, 1, ?, ?)",
                bindings: [
                    .text(objectID), .blob(expected.canonicalBytes), .text(expected.stateDigest),
                ]
            )
        }
        let extra = try await extraDatabase.transaction(.immediate) { database in
            try RuntimeCanonicalReplayEngine.testOnlyFirstLiveAggregateDivergence(
                reconstruction,
                database: database
            )
        }
        XCTAssertEqual(extra?.code, .liveStateDivergence)
        XCTAssertNil(extra?.privatePayload)
    }

    private func makeReplayDatabase(label: String) async throws -> SQLiteDatabase {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("runtime-replay-\(label)-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let database = try SQLiteDatabase(url: directory.appendingPathComponent("Runtime.sqlite"))
        try await database.transaction(.exclusive) { database in
            for statement in CanonicalRuntimeStore.schemaStatements {
                try database.execute(statement)
            }
            for statement in CanonicalRuntimeReplaySchemaPlan.stagedIntegratedStatements {
                try database.execute(statement)
            }
            try database.execute(
                "INSERT INTO runtime_store_metadata(singleton_id, schema_version, generation_id, created_at_ms) VALUES (1, 4, 'replay-tests', 0)"
            )
            try database.execute("PRAGMA user_version = 4")
        }
        try await database.execute("PRAGMA foreign_keys = OFF")
        return database
    }

    private func tombstonedCaptureReconstruction() throws -> RuntimeCanonicalReconstruction {
        let created = try captureEvent(
            id: "capture-tombstone-parity", revision: 0, prior: nil,
            action: .quickCapture(externalCreation: nil)
        )
        let archived = try captureEvent(
            id: "capture-tombstone-parity", revision: 1, prior: 0, action: .archive
        )
        let first = try semanticRecord(event: created, sequence: 1)
        let second = try semanticRecord(event: archived, sequence: 2, previous: first.lineage.eventHash)
        guard case let .accepted(one) = RuntimeCanonicalReplayReducer().apply(first, to: .empty),
              case let .accepted(two) = RuntimeCanonicalReplayReducer().apply(second, to: one) else {
            throw RuntimeCanonicalReplayError.corruptAuthority
        }
        return two
    }

    private func tombstoneDraft(
        _ tombstone: RuntimeCanonicalReplayTombstone
    ) throws -> RuntimeCanonicalTombstoneDraft {
        RuntimeCanonicalTombstoneDraft(
            objectID: try RuntimeDomainObjectID(validating: tombstone.aggregate.id.rawValue),
            family: tombstone.aggregate.kind.rawValue,
            terminalRevision: tombstone.terminalRevision,
            lineage: RuntimeAuthorityLineageReference(
                eventID: try XCTUnwrap(tombstone.causalCursor.typedEventID),
                eventSequence: tombstone.causalCursor.sequence,
                eventHash: tombstone.causalCursor.eventHash
            ),
            authority: RuntimeCanonicalTombstoneAuthority(
                reason: tombstone.reason,
                predecessorDigest: tombstone.predecessorDigest,
                retentionDisposition: tombstone.retentionDisposition,
                recoveryDisposition: tombstone.recoveryDisposition
            )
        )
    }

    private func canonicalTombstoneBytes(_ draft: RuntimeCanonicalTombstoneDraft) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        encoder.dateEncodingStrategy = .millisecondsSince1970
        return try encoder.encode(draft)
    }

    private func insertTombstoneRow(
        payload: Data,
        objectID: String,
        family: String,
        revision: UInt64,
        sequence: UInt64,
        database: SQLiteDatabase
    ) async throws {
        try await database.execute(
            """
            INSERT INTO runtime_commit_tombstones(
                object_id, family, terminal_revision, terminal_event_sequence,
                tombstone_version, payload, payload_checksum, created_at_ms
            ) VALUES (?, ?, ?, ?, 1, ?, ?, 0)
            """,
            bindings: [
                .text(objectID), .text(family), .integer(Int64(revision)),
                .integer(Int64(sequence)), .blob(payload),
                .text(LocalRuntimeStorageChecksum.sha256Hex(for: payload)),
            ]
        )
    }

    @discardableResult
    private static func appendAndMaterialize(
        _ event: RuntimeSemanticEvent,
        sequenceHint: UInt64,
        database: SQLiteDatabase
    ) async throws -> CanonicalRuntimeSemanticEventRecord {
        try await database.transaction(.immediate) { database in
            let bytes = try RuntimeSemanticEventCodec().encode(event)
            let primary = try XCTUnwrap(event.mutation.primaryAggregate)
            let append = try CanonicalRuntimeSemanticEventStore.appendInTransaction(
                try CanonicalRuntimeSemanticEventAppendRequest(
                    eventID: RuntimeEventID(validating: "sqlite-replay-event-\(sequenceHint)"),
                    commandID: RuntimeCommandID(validating: "sqlite-replay-command-\(sequenceHint)"),
                    aggregate: primary,
                    canonicalAggregateRevision: event.mutation.resultingRevision,
                    correlationID: RuntimeCorrelationID(validating: "sqlite-replay-correlation-\(sequenceHint)"),
                    causationEventID: nil,
                    occurredAt: Date(timeIntervalSince1970: Double(1_800_000_000 + sequenceHint)),
                    canonicalBytes: bytes
                ),
                to: database
            )
            guard case let .appended(record) = append else {
                throw RuntimeCanonicalReplayError.corruptAuthority
            }
            for transition in event.mutation.aggregateTransitions {
                try database.execute(
                    """
                    INSERT INTO runtime_aggregates(
                        aggregate_kind, aggregate_id, revision, payload_version, payload, payload_checksum
                    ) VALUES (?, ?, ?, 1, ?, ?)
                    ON CONFLICT(aggregate_kind, aggregate_id) DO UPDATE SET
                        revision = excluded.revision, payload_version = excluded.payload_version,
                        payload = excluded.payload, payload_checksum = excluded.payload_checksum
                    """,
                    bindings: [
                        .text(transition.aggregate.kind.rawValue),
                        .text(transition.aggregate.id.rawValue),
                        .integer(Int64(transition.resultingRevision)),
                        .blob(transition.canonicalStateBytes),
                        .text(transition.canonicalStateDigest),
                    ]
                )
            }
            return record
        }
    }

    private func writerMutationCommands() throws -> [RuntimeCommandPayload] {
        let target = AmbitionsCommandTarget(
            goalID: "goal-writer", captureID: "capture-writer", timeID: "time-writer",
            reviewID: "review-writer", stepID: "step-writer",
            recommendationID: "recommendation-writer"
        )
        let content = RuntimeCommandContent(AmbitionsCommandPayload(title: "Writer coverage"))
        let recovery = RecoveryRecommendationCommand(
            goalID: RuntimeCommandObjectID(rawValue: "goal-writer"),
            captureID: nil,
            timeID: nil,
            title: "Recover",
            explanationID: nil
        )
        let goal = Self.writerFixtureGoal()
        let todayPlan = TodayGoalStepActionPlan(
            actionKind: .complete,
            goalID: goal.id,
            stepID: "step-writer",
            expectedGoalRevision: goal.revision,
            updatedGoal: goal,
            writesGoal: true,
            feedbackEvents: [],
            evidence: [],
            capture: nil
        )
        let ritualPlan = TimeRitualActionPlan(
            actionKind: .minimumVersion,
            goalID: goal.id,
            stepID: "step-writer",
            expectedGoalRevision: goal.revision,
            updatedGoal: goal,
            writesGoal: true,
            feedbackEvents: [],
            evidence: []
        )
        let receipt = TodayReceiptDomainEvent(
            kind: .closure,
            receipt: ActionReceipt(
                id: "receipt-writer",
                resultState: .completed,
                title: "Completed",
                summary: "Completed",
                sourceDomain: .today,
                occurredAt: "2026-07-24T12:00:00Z",
                affectedObjects: [LifeGraphObjectReference(kind: .step, id: "step-writer")]
            ),
            privacyLevel: .safeToShow,
            localOnly: true,
            proofRelevance: .notProof,
            requiresConfirmationBeforeBroaderUse: false
        )
        let calendarWrite = CalendarWriteCommandIntent(
            operationID: try RuntimeExternalOperationID(validating: "calendar-writer"),
            userConfirmed: true,
            placement: nil,
            destinationStepID: RuntimeCommandObjectID(rawValue: "step-writer"),
            destinationStepTitle: "Step",
            originalBlockID: RuntimeCommandObjectID(rawValue: "time-writer"),
            displacedDisposition: .notDisplaced,
            destinationStepPressure: nil,
            originStepPressure: nil,
            lifeshapeImpact: .recalculatedBeforeCommit,
            scheduleBlockID: RuntimeCommandObjectID(rawValue: "schedule-writer")
        )
        let receiptID = try XCTUnwrap(RuntimeCommandReceiptID(rawValue: "receipt-writer"))

        return [
            .capture(CaptureCommand(action: .quickCapture(externalCreation: nil), target: target, content: content)),
            .capture(CaptureCommand(action: .routeCommitment, target: target, content: content)),
            .capture(CaptureCommand(action: .attachToGoal(nil), target: target, content: content)),
            .capture(CaptureCommand(action: .markWaiting, target: target, content: content)),
            .capture(CaptureCommand(action: .archive, target: target, content: content)),
            .goal(GoalCommand(action: .create, target: target, content: content)),
            .goal(GoalCommand(action: .update, target: target, content: content)),
            .goal(GoalCommand(action: .setPriority, target: target, content: content)),
            .goal(GoalCommand(action: .setUrgency, target: target, content: content)),
            .goal(GoalCommand(action: .setDeadline, target: target, content: content)),
            .goal(GoalCommand(action: .setContextLens, target: target, content: content)),
            .goal(GoalCommand(action: .clearContextLens, target: target, content: content)),
            .goal(GoalCommand(action: .addDeliverable, target: target, content: content)),
            .goal(GoalCommand(action: .removeDeliverable, target: target, content: content)),
            .goal(GoalCommand(action: .addScopeItem, target: target, content: content)),
            .goal(GoalCommand(action: .removeScopeItem, target: target, content: content)),
            .step(StepCommand(action: .startSession, target: target, content: content)),
            .step(StepCommand(action: .complete, target: target, content: content)),
            .step(StepCommand(action: .delay, target: target, content: content)),
            .step(StepCommand(action: .split, target: target, content: content)),
            .step(StepCommand(action: .recover(recovery), target: target, content: content)),
            .step(StepCommand(action: .todayGoalStep(todayPlan), target: target, content: content)),
            .schedule(ScheduleCommand(action: .createItem(nil), target: target, content: content)),
            .schedule(ScheduleCommand(action: .schedule(nil), target: target, content: content)),
            .schedule(ScheduleCommand(action: .placeStep(nil), target: target, content: content)),
            .schedule(ScheduleCommand(action: .protectWindow(nil), target: target, content: content)),
            .schedule(ScheduleCommand(
                action: .correctWindow(TimeCorrectionCommandIntent(action: .addBuffer, start: nil, end: nil)),
                target: target,
                content: content
            )),
            .schedule(ScheduleCommand(
                action: .undo(CommandUndoIntent(
                    originalReceiptID: receiptID,
                    expectedProjectionVersion: 1
                )),
                target: target,
                content: content
            )),
            .schedule(ScheduleCommand(action: .ritual(ritualPlan), target: target, content: content)),
            .schedule(ScheduleCommand(action: .calendarWrite(calendarWrite), target: target, content: content)),
            .reminder(ReminderCommand(action: .create, target: target, content: content)),
            .reminder(ReminderCommand(action: .update, target: target, content: content)),
            .reminder(ReminderCommand(action: .delete, target: target, content: content)),
            .profile(ProfileCommand(
                action: .updatePreferences,
                target: target,
                content: content,
                preferences: ProfilePreferencesCommandValues(
                    preferredTab: .today,
                    appearancePreference: .system,
                    accentFamily: .sage,
                    reviewCadenceDays: 7,
                    localOnlyModeEnabled: true
                )
            )),
            .history(HistoryCommand(action: .dismissRecommendation, target: target, content: content)),
            .history(HistoryCommand(action: .todayReceipt(receipt), target: target, content: content)),
            .repair(RepairCommand(action: .recover, recommendation: recovery, target: target, content: content)),
            .importDeletion(ImportDeletionCommand(action: .deleteObject, target: target, content: content)),
            .importDeletion(ImportDeletionCommand(action: .forgetMemory, target: target, content: content)),
            .externalOperation(ExternalOperationCommand(
                operationID: try RuntimeExternalOperationID(validating: "external-reminder-writer"),
                kind: .reminder,
                target: target,
                title: "Reminder"
            )),
            .externalOperation(ExternalOperationCommand(
                operationID: try RuntimeExternalOperationID(validating: "external-calendar-writer"),
                kind: .calendarEvent,
                target: target,
                title: "Calendar"
            )),
        ]
    }

    private static func writerFixtureGoal() -> Goal {
        Goal(
            schemaVersion: goalEngineSchemaVersion,
            id: "goal-writer",
            revision: 1,
            createdAt: "2026-07-24T12:00:00Z",
            updatedAt: "2026-07-24T12:00:00Z",
            state: .active,
            title: "Writer fixture goal",
            summary: nil,
            mode: .project,
            relationshipKind: .independent,
            actor: GoalActor(
                actorID: "actor.local",
                displayName: "Local",
                ownership: .self,
                roleLabel: nil,
                isPrimary: true
            ),
            parentGoalID: nil,
            childGoalIDs: [],
            supportGoalIDs: [],
            tags: [],
            timing: GoalTiming(
                tempo: .untimed,
                timingType: .suggestedNext,
                startsOn: nil,
                dueAt: nil,
                targetBy: nil,
                windowStart: nil,
                windowEnd: nil,
                suggestedNextAt: nil,
                repeatEveryDays: nil,
                progressReviewCadenceDays: nil
            ),
            planningStrategy: PlanningStrategy(
                strategyKind: .adaptive,
                allowParallelSteps: true,
                maxActiveSteps: 1,
                preferredSectionOrder: [.activeSteps],
                defaultStepType: .actionUnit,
                autoGenerateReviewSection: false,
                preferShortSteps: true,
                revisitCadenceDays: nil
            ),
            progressStrategy: ProgressStrategy(
                metricKind: .stepCompletion,
                rollupMethod: .sum,
                targetStepCount: nil,
                targetEvidenceCount: nil,
                targetMinutes: nil,
                supportsUntimedProgress: true,
                countsChildGoals: false,
                countsSupportGoals: false
            ),
            plan: nil
        )
    }

    private func semanticFixtures() throws -> [(event: RuntimeSemanticEvent, command: RuntimeCommandPayload, sequence: UInt64)] {
        let target = AmbitionsCommandTarget(
            goalID: "goal-family", captureID: "capture-family", timeID: "time-family",
            reviewID: "review-family", stepID: "step-family",
            recommendationID: "recommendation-family"
        )
        let content = RuntimeCommandContent(AmbitionsCommandPayload(title: "Canonical facts"))
        let changed = [try RuntimeDomainObjectID(validating: "object-family")]
        let capture = CaptureCommand(action: .quickCapture(externalCreation: nil), target: target, content: content)
        let goal = GoalCommand(action: .create, target: target, content: content)
        let step = StepCommand(action: .complete, target: target, content: content)
        let schedule = ScheduleCommand(action: .createItem(nil), target: target, content: content)
        let reminder = ReminderCommand(action: .create, target: target, content: content)
        let profile = ProfileCommand(
            action: .updatePreferences, target: target, content: content,
            preferences: ProfilePreferencesCommandValues(
                preferredTab: .today, appearancePreference: .system,
                accentFamily: .blueGray, reviewCadenceDays: 7, localOnlyModeEnabled: true
            )
        )
        let history = HistoryCommand(action: .dismissRecommendation, target: target, content: content)
        let repair = RepairCommand(
            action: .recover,
            recommendation: RecoveryRecommendationCommand(
                goalID: RuntimeCommandObjectID(rawValue: "goal-family"),
                captureID: nil, timeID: nil, title: "Recover", explanationID: nil
            ),
            target: target, content: content
        )
        let deletion = ImportDeletionCommand(action: .deleteObject, target: target, content: content)
        let operation = ExternalOperationCommand(
            operationID: try RuntimeExternalOperationID(validating: "operation-family"),
            kind: .reminder, target: target, title: "Reminder"
        )
        func mutation(
            _ type: RuntimeSemanticEventTypeID,
            _ id: String,
            _ command: RuntimeCommandPayload
        ) throws -> RuntimeSemanticMutation {
            let aggregate = RuntimeSemanticAggregate(
                kind: type.aggregateKind,
                id: try RuntimeAggregateID(validating: id)
            )
            let transition: RuntimeObjectTransitionKind = type.isCreation
                ? .create
                : (type == .objectDeleted ? .tombstone : .update)
            let prior: UInt64? = type.isCreation ? nil : 0
            let state = RuntimeCanonicalAggregateState(
                aggregate: aggregate,
                revision: type.isCreation ? 0 : 1,
                lifecycle: transition == .tombstone ? .tombstoned : .active,
                transition: transition,
                commandPayload: command,
                changedObjectIDs: changed
            )
            let bytes = try RuntimeCanonicalAggregateStateCodec().encode(state)
            let tombstone: RuntimeCanonicalTombstoneAuthority?
            if transition == .tombstone {
                let predecessor = RuntimeCanonicalAggregateState(
                    aggregate: aggregate, revision: 0, lifecycle: .active,
                    transition: .update, commandPayload: command, changedObjectIDs: changed
                )
                let predecessorBytes = try RuntimeCanonicalAggregateStateCodec().encode(predecessor)
                tombstone = RuntimeCanonicalTombstoneAuthority(
                    reason: .objectDeleted,
                    predecessorDigest: LocalRuntimeStorageChecksum.sha256Hex(for: predecessorBytes),
                    retentionDisposition: .retainedUntilDownstreamPolicy,
                    recoveryDisposition: .explicitTypedRestorationRequired
                )
            } else {
                tombstone = nil
            }
            return try RuntimeSemanticMutation(
                semanticType: type,
                aggregateID: aggregate.id,
                priorRevision: prior,
                resultingRevision: state.revision,
                changedObjectIDs: changed,
                primaryAggregate: aggregate,
                aggregateTransitions: [RuntimeSemanticAggregateTransition(
                    aggregate: aggregate, priorRevision: prior,
                    resultingRevision: state.revision, lifecycle: state.lifecycle,
                    transition: transition, canonicalStateBytes: bytes,
                    canonicalStateDigest: LocalRuntimeStorageChecksum.sha256Hex(for: bytes),
                    tombstone: tombstone
                )]
            )
        }
        return [
            (.capture(.created(try RuntimeCaptureMutationPayload(mutation: mutation(.captureCreated, "capture-family", .capture(capture)), facts: capture))), .capture(capture), 1),
            (.goal(.created(try RuntimeGoalMutationPayload(mutation: mutation(.goalCreated, "goal-family", .goal(goal)), facts: goal))), .goal(goal), 2),
            (.step(.completed(try RuntimeStepMutationPayload(mutation: mutation(.stepCompleted, "step-family", .step(step)), facts: step))), .step(step), 3),
            (.schedule(.itemCreated(try RuntimeScheduleMutationPayload(mutation: mutation(.scheduleItemCreated, "time-family", .schedule(schedule)), facts: schedule))), .schedule(schedule), 4),
            (.reminder(.created(try RuntimeReminderMutationPayload(mutation: mutation(.reminderCreated, "time-family", .reminder(reminder)), facts: reminder))), .reminder(reminder), 5),
            (.profile(.preferencesUpdated(try RuntimeProfileMutationPayload(mutation: mutation(.profilePreferencesUpdated, "profile.local", .profile(profile)), facts: profile))), .profile(profile), 6),
            (.history(.recommendationDismissed(try RuntimeHistoryMutationPayload(mutation: mutation(.historyRecommendationDismissed, "review-family", .history(history)), facts: history))), .history(history), 7),
            (.repair(.recovered(try RuntimeRepairMutationPayload(mutation: mutation(.repairRecovered, "recommendation-family", .repair(repair)), facts: repair))), .repair(repair), 8),
            (.importDeletion(.objectDeleted(try RuntimeImportDeletionMutationPayload(mutation: mutation(.objectDeleted, "object-family", .importDeletion(deletion)), facts: deletion))), .importDeletion(deletion), 9),
            (.externalOperation(.reminderRequested(try RuntimeExternalOperationMutationPayload(mutation: mutation(.externalReminderRequested, "operation-family", .externalOperation(operation)), facts: operation))), .externalOperation(operation), 10),
        ]
    }

    private func captureEvent(
        id: String,
        revision: UInt64,
        prior: UInt64?,
        action: CaptureCommand.Action
    ) throws -> RuntimeSemanticEvent {
        let command = CaptureCommand(
            action: action,
            target: AmbitionsCommandTarget(captureID: id),
            content: RuntimeCommandContent(AmbitionsCommandPayload(title: "Capture"))
        )
        let aggregate = RuntimeSemanticAggregate(
            kind: .capture,
            id: try RuntimeAggregateID(validating: id)
        )
        let transitionKind: RuntimeObjectTransitionKind = action.isArchive
            ? .tombstone
            : (prior == nil ? .create : .update)
        let state = RuntimeCanonicalAggregateState(
            aggregate: aggregate,
            revision: revision,
            lifecycle: action.isArchive ? .tombstoned : .active,
            transition: transitionKind,
            commandPayload: .capture(command),
            changedObjectIDs: [try RuntimeDomainObjectID(validating: id)]
        )
        let stateBytes = try RuntimeCanonicalAggregateStateCodec().encode(state)
        let tombstone: RuntimeCanonicalTombstoneAuthority?
        if action.isArchive {
            let predecessorCommand = CaptureCommand(
                action: .quickCapture(externalCreation: nil),
                target: AmbitionsCommandTarget(captureID: id),
                content: RuntimeCommandContent(AmbitionsCommandPayload(title: "Capture"))
            )
            let predecessorState = RuntimeCanonicalAggregateState(
                aggregate: aggregate,
                revision: try XCTUnwrap(prior),
                lifecycle: .active,
                transition: .create,
                commandPayload: .capture(predecessorCommand),
                changedObjectIDs: [try RuntimeDomainObjectID(validating: id)]
            )
            let predecessorBytes = try RuntimeCanonicalAggregateStateCodec().encode(predecessorState)
            tombstone = RuntimeCanonicalTombstoneAuthority(
                reason: .archived,
                predecessorDigest: LocalRuntimeStorageChecksum.sha256Hex(for: predecessorBytes),
                retentionDisposition: .retainedUntilDownstreamPolicy,
                recoveryDisposition: .explicitTypedRestorationRequired
            )
        } else {
            tombstone = nil
        }
        let mutation = try RuntimeSemanticMutation(
            semanticType: action.isArchive ? .captureArchived : (prior == nil ? .captureCreated : .captureMarkedWaiting),
            aggregateID: RuntimeAggregateID(validating: id),
            priorRevision: prior,
            resultingRevision: revision,
            changedObjectIDs: [try RuntimeDomainObjectID(validating: id)],
            primaryAggregate: aggregate,
            aggregateTransitions: [RuntimeSemanticAggregateTransition(
                aggregate: aggregate,
                priorRevision: prior,
                resultingRevision: revision,
                lifecycle: state.lifecycle,
                transition: transitionKind,
                canonicalStateBytes: stateBytes,
                canonicalStateDigest: LocalRuntimeStorageChecksum.sha256Hex(for: stateBytes),
                tombstone: tombstone
            )]
        )
        let payload = try RuntimeCaptureMutationPayload(mutation: mutation, facts: command)
        if action.isArchive { return .capture(.archived(payload)) }
        if prior == nil { return .capture(.created(payload)) }
        return .capture(.markedWaiting(payload))
    }

    private func semanticRecord(
        event: RuntimeSemanticEvent,
        sequence: UInt64,
        previous: SHA256Digest? = nil
    ) throws -> CanonicalRuntimeSemanticEventRecord {
        let bytes = try RuntimeSemanticEventCodec().encode(event)
        let payloadVersion = try RuntimeSemanticEventCodec().inspectHeader(bytes).payloadVersion
        let aggregate = RuntimeSemanticAggregate(kind: event.aggregateKind, id: event.mutation.aggregateID)
        let eventID = try RuntimeEventID(validating: "event-\(sequence)")
        let commandID = try RuntimeCommandID(validating: "command-\(sequence)")
        let correlationID = try RuntimeCorrelationID(validating: "correlation-\(sequence)")
        let sourceDigest = SHA256Digest.digest(bytes)
        let occurredAt = Date(timeIntervalSince1970: Double(1_800_000_000 + sequence))
        let hash = try RuntimeSemanticEventHashing.eventHash(
            eventID: eventID, commandID: commandID, aggregate: aggregate,
            canonicalAggregateRevision: event.mutation.resultingRevision,
            sequence: sequence, correlationID: correlationID, causationEventID: nil,
            occurredAt: occurredAt, previousEventHash: previous,
            sourceDigest: sourceDigest, typeID: event.typeID, payloadVersion: payloadVersion
        )
        return CanonicalRuntimeSemanticEventRecord(
            lineage: RuntimeSemanticEventLineage(
                eventID: eventID, commandID: commandID, aggregate: aggregate,
                canonicalAggregateRevision: event.mutation.resultingRevision,
                sequence: sequence, correlationID: correlationID, causationEventID: nil,
                occurredAt: occurredAt, previousEventHash: previous,
                sourceDigest: sourceDigest, eventHash: hash
            ),
            event: event, sourceBytes: bytes, sourcePayloadVersion: payloadVersion, wasUpcast: false
        )
    }
}

private extension CaptureCommand.Action {
    var isArchive: Bool {
        if case .archive = self { return true }
        return false
    }
}
