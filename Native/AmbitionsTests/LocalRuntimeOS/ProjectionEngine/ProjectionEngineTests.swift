@testable import Ambitions
import XCTest

final class ProjectionEngineTests: XCTestCase {
    func testProjectionEngineOwnerFilesExistUnderCanonicalTree() throws {
        let root = try repoRoot()
        let requiredPaths = [
            "Native/Ambitions/Core/LocalRuntimeOS/ProjectionEngine/ProjectionDefinition.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/ProjectionEngine/ProjectionCursor.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/ProjectionEngine/ProjectionInvalidation.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/ProjectionEngine/ProjectionMaterializer.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/ProjectionEngine/RuntimeProjectionPipeline.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/ProjectionEngine/RuntimeSnapshot.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/ProjectionEngine/ProjectionChecksum.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/ProjectionEngine/TodayProjection.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/ProjectionEngine/GoalsProjection.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/ProjectionEngine/TimeProjection.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/ProjectionEngine/YouProjection.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/ProjectionEngine/SearchProjection.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/ProjectionEngine/WidgetProjection.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/ProjectionEngine/AppIntentProjection.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/ProjectionEngine/ReceiptProjection.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/ProjectionEngine/PrivacyProjection.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/ProjectionEngine/ProjectionStoreSurfaceReadAdapter.swift",
        ]

        for path in requiredPaths {
            XCTAssertTrue(FileManager.default.fileExists(atPath: root.appendingPathComponent(path).path), path)
        }
    }

    func testCanonicalDefinitionsCoverAllProjectionIDsAndInventoryExistingReadModels() throws {
        let root = try repoRoot()
        let definitions = ProjectionDefinition.allCanonical
        XCTAssertEqual(definitions.map(\.id).sorted(), ProjectionID.allCases.sorted())

        for definition in definitions {
            XCTAssertFalse(definition.consumesEventKinds.isEmpty, "\(definition.id) must declare runtime event inputs")
            XCTAssertFalse(definition.readModelInventory.isEmpty, "\(definition.id) must inventory existing read-model scaffolding")
            XCTAssertTrue(definition.readModelInventory.allSatisfy { $0.mutationAuthorityAllowed == false })
            for entry in definition.readModelInventory {
                XCTAssertTrue(
                    FileManager.default.fileExists(atPath: root.appendingPathComponent(entry.sourcePath).path),
                    "\(definition.id) inventory path missing: \(entry.sourcePath)"
                )
            }
        }
    }

    func testMaterializerBuildsSurfaceProjectionsFromRuntimeEvents() async throws {
        let store = InMemoryRuntimeEventStore()
        let today = try await store.append(commandEvent(
            id: "command-today-capture",
            kind: .quickCapture,
            source: .today,
            target: AmbitionsCommandTarget(captureID: "capture-1", destination: .captureInbox),
            summary: "Captured appointment note",
            privacy: .standard
        ))
        let goal = try await store.append(commandEvent(
            id: "command-goal-create",
            kind: .createGoal,
            source: .goals,
            target: AmbitionsCommandTarget(goalID: "goal-1", destination: .goals),
            summary: "Created goal",
            privacy: .standard
        ))
        let time = try await store.append(timePlacementEvent())
        let proof = try await store.append(proofEvent())
        let privateCommand = try await store.append(commandEvent(
            id: "command-private-widget-filter",
            kind: .openDestination,
            source: .widget,
            target: AmbitionsCommandTarget(destination: .today),
            summary: "Private widget route",
            privacy: .privateUserText
        ))

        let batch = try await ProjectionMaterializer(store: store).materializeAll(materializedAt: "2026-06-30T06:00:00Z")

        XCTAssertTrue(batch.today.startHereCommandEventIDs.contains(today.id))
        XCTAssertEqual(batch.goals.recordsByGoalID["goal-1"], [goal.id, proof.id])
        XCTAssertTrue(batch.time.placementEventIDs.contains(time.id))
        XCTAssertTrue(batch.you.proofEventIDs.contains(proof.id))
        XCTAssertTrue(batch.search.rebuildSourceEventIDs.contains(today.id))
        XCTAssertTrue(batch.receipt.receiptEventIDs.contains(goal.id))
        XCTAssertTrue(batch.privacy.redactionRequiredEventIDs.contains(privateCommand.id))
        XCTAssertFalse(batch.widget.rows.map(\.eventID).contains(privateCommand.id))
        let blockedAppIntentAction = AppIntentProjectionAction(record: ProjectionEventRecord(envelope: privateCommand))
        XCTAssertFalse(blockedAppIntentAction.canRunFromIntent)
        XCTAssertEqual(blockedAppIntentAction.title, "Open Ambitions")
        XCTAssertEqual(blockedAppIntentAction.blockedReason, "Requires in-app confirmation or private context.")
        XCTAssertEqual(batch.cursors[.today]?.eventCursor, privateCommand.cursor)
        XCTAssertEqual(batch.cursors[.privacy]?.eventCursor, privateCommand.cursor)
        XCTAssertTrue(batch.invalidations.contains { $0.projectionID == .today && $0.eventID == privateCommand.id })
    }

    func testMaterializerReportsDiffsFromPreviousCursors() async throws {
        let store = InMemoryRuntimeEventStore()
        _ = try await store.append(commandEvent(
            id: "command-first",
            kind: .quickCapture,
            source: .today,
            target: AmbitionsCommandTarget(captureID: "capture-first", destination: .captureInbox),
            summary: "First",
            privacy: .standard
        ))
        let firstBatch = try await ProjectionMaterializer(store: store).materializeAll(materializedAt: "2026-06-30T06:00:00Z")

        let second = try await store.append(commandEvent(
            id: "command-second",
            kind: .quickCapture,
            source: .today,
            target: AmbitionsCommandTarget(captureID: "capture-second", destination: .captureInbox),
            summary: "Second",
            privacy: .standard
        ))
        let secondBatch = try await ProjectionMaterializer(store: store).materializeAll(
            previousCursors: firstBatch.cursors,
            materializedAt: "2026-06-30T06:01:00Z"
        )

        let todayDiff = try XCTUnwrap(secondBatch.diffs.first { $0.projectionID == .today })
        let todayInvalidation = try XCTUnwrap(secondBatch.invalidations.first { $0.projectionID == .today })

        XCTAssertEqual(todayDiff.addedEventIDs, [second.id])
        XCTAssertTrue(todayDiff.checksumChanged)
        XCTAssertEqual(todayInvalidation.previousCursor, firstBatch.today.cursor)
        XCTAssertEqual(todayInvalidation.nextCursor, secondBatch.today.cursor)
        XCTAssertEqual(todayInvalidation.reason, .eventAppended)
    }

    func testProjectionStoreSurfaceReadAdapterFeedsTodayGoalsTimeYouAndSearchWithFreshnessReceipts() async throws {
        let directory = try scratchDirectory()
        let store = InMemoryRuntimeEventStore()
        let today = try await store.append(commandEvent(
            id: "command-adapter-today",
            kind: .quickCapture,
            source: .today,
            target: AmbitionsCommandTarget(captureID: "capture-adapter", destination: .captureInbox),
            summary: "Captured adapter appointment",
            privacy: .standard
        ))
        let goal = try await store.append(commandEvent(
            id: "command-adapter-goal",
            kind: .createGoal,
            source: .goals,
            target: AmbitionsCommandTarget(goalID: "goal-adapter", destination: .goals),
            summary: "Created adapter goal",
            privacy: .standard
        ))
        let time = try await store.append(timePlacementEvent())
        let proof = try await store.append(proofEvent())
        let batch = try await ProjectionMaterializer(store: store).materializeAll(materializedAt: "2026-06-30T06:10:00Z")
        let projectionStore = ProjectionStoreSQLite(databaseURL: directory.appendingPathComponent("projections.sqlite"))
        let searchIndex = FTSIndex(store: SearchStoreFTS(databaseURL: directory.appendingPathComponent("search.sqlite")))
        try await projectionStore.save(batch: batch, updatedAt: "2026-06-30T06:11:00Z")
        _ = try await searchIndex.rebuild(from: batch.search, updatedAt: "2026-06-30T06:11:00Z")
        let adapter = ProjectionStoreSurfaceReadAdapter(projectionStore: projectionStore, searchIndex: searchIndex)

        let todayRead = try await adapter.readToday(minimumEventCursor: batch.today.cursor.eventCursor, inspectedAt: "2026-06-30T06:12:00Z")
        let goalsRead = try await adapter.readGoals(minimumEventCursor: batch.goals.cursor.eventCursor, inspectedAt: "2026-06-30T06:12:00Z")
        let timeRead = try await adapter.readTime(minimumEventCursor: batch.time.cursor.eventCursor, inspectedAt: "2026-06-30T06:12:00Z")
        let youRead = try await adapter.readYou(minimumEventCursor: batch.you.cursor.eventCursor, inspectedAt: "2026-06-30T06:12:00Z")
        let widgetRead = try await adapter.readWidget(minimumEventCursor: batch.widget.cursor.eventCursor, inspectedAt: "2026-06-30T06:12:00Z")
        let appIntentRead = try await adapter.readAppIntent(minimumEventCursor: batch.appIntent.cursor.eventCursor, inspectedAt: "2026-06-30T06:12:00Z")
        let privacyRead = try await adapter.readPrivacy(minimumEventCursor: batch.privacy.cursor.eventCursor, inspectedAt: "2026-06-30T06:12:00Z")
        let searchRead = try await adapter.search(
            SearchRecallQuery(rawText: "adapter", limit: 10),
            minimumEventCursor: batch.search.cursor.eventCursor,
            searchedAt: "2026-06-30T06:12:00Z"
        )

        XCTAssertEqual(todayRead.status, .available)
        XCTAssertTrue(todayRead.isSurfaceReadable)
        XCTAssertEqual(todayRead.source, .projectionStoreSQLite)
        XCTAssertEqual(todayRead.fallbackRole, .rebuildInputOnly)
        XCTAssertTrue(todayRead.projection?.startHereCommandEventIDs.contains(today.id) == true)
        XCTAssertEqual(goalsRead.projection?.recordsByGoalID["goal-adapter"], [goal.id])
        XCTAssertTrue(goalsRead.projection?.proofEventIDs.contains(proof.id) == true)
        XCTAssertTrue(timeRead.projection?.placementEventIDs.contains(time.id) == true)
        XCTAssertTrue(youRead.projection?.proofEventIDs.contains(proof.id) == true)
        XCTAssertEqual(widgetRead.status, .available)
        XCTAssertTrue(widgetRead.projection?.rows.contains { $0.eventID == today.id } == true)
        XCTAssertEqual(appIntentRead.status, .available)
        XCTAssertTrue(appIntentRead.projection?.actions.contains { $0.eventID == today.id } == true)
        XCTAssertEqual(privacyRead.status, .available)
        XCTAssertTrue(privacyRead.projection?.buckets.contains { $0.id == .standard } == true)
        XCTAssertEqual(searchRead.projectionState.status, .available)
        XCTAssertEqual(searchRead.source, .searchStoreFTS)
        XCTAssertTrue(searchRead.results.contains { $0.provenance.eventID == today.id })
        XCTAssertEqual(searchRead.indexHealth?.storageHealth.storageTier, .searchStoreFTS)

        let futureCursor = RuntimeEventCursor(
            sequence: proof.cursor.sequence + 10,
            eventID: "runtime.event.future",
            checksum: "future-checksum",
            occurredAt: "2026-06-30T06:13:00Z"
        )
        let staleToday = try await adapter.readToday(minimumEventCursor: futureCursor, inspectedAt: "2026-06-30T06:13:30Z")
        XCTAssertEqual(staleToday.status, .staleProjection)
        XCTAssertFalse(staleToday.isSurfaceReadable)
        XCTAssertEqual(staleToday.repairReceipt?.safeRebuildRequired, true)
        XCTAssertEqual(staleToday.repairReceipt?.fallbackRole, .rebuildInputOnly)

        let emptyProjectionStore = ProjectionStoreSQLite(databaseURL: directory.appendingPathComponent("empty-projections.sqlite"))
        let emptyAdapter = ProjectionStoreSurfaceReadAdapter(projectionStore: emptyProjectionStore, searchIndex: searchIndex)
        let missingYou = try await emptyAdapter.readYou(inspectedAt: "2026-06-30T06:14:00Z")
        XCTAssertEqual(missingYou.status, .missingProjection)
        XCTAssertNil(missingYou.projection)
        XCTAssertEqual(missingYou.repairReceipt?.safeRebuildRequired, true)
    }
}

private extension ProjectionEngineTests {
    func commandEvent(
        id: String,
        kind: AmbitionsCommandKind,
        source: AmbitionsCommandSource,
        target: AmbitionsCommandTarget,
        summary: String,
        privacy: EventLedgerPrivacyClassification
    ) -> RuntimeEvent {
        let command = AmbitionsCommand(
            id: id,
            kind: kind,
            source: source,
            target: target,
            payload: AmbitionsCommandPayload(rawText: summary),
            createdAt: "2026-06-30T06:00:00Z",
            privacy: privacy
        )
        let result = AmbitionsCommandExecutionResult(
            status: .succeeded,
            summary: summary,
            route: target.destination,
            target: target,
            eventLedgerEntryIDs: ["ledger.\(id)"],
            metadata: ["objectID": target.captureID ?? target.goalID ?? "object-\(id)"]
        )
        return RuntimeEvent.commandExecution(
            command: command,
            result: result,
            recordedAt: "2026-06-30T06:00:00Z",
            commandRecordID: "command.execution.\(id)"
        )
    }

    func timePlacementEvent() -> RuntimeEvent {
        RuntimeEvent(
            commandID: "command-time-placement",
            actor: .user,
            source: .time,
            target: AmbitionsCommandTarget(timeID: "time-1", stepID: "step-1", destination: .time),
            privacy: .calendarDerived,
            occurredAt: "2026-06-30T06:00:30Z",
            payload: .timePlacementProposed(
                RuntimeTimePlacementEventPayload(
                    proposalID: "placement-1",
                    stepID: "step-1",
                    timeBlockID: "time-1",
                    placementSummary: "Placed step in protected time"
                )
            )
        )
    }

    func proofEvent() -> RuntimeEvent {
        RuntimeEvent(
            commandID: "command-proof",
            actor: .system,
            source: .you,
            target: AmbitionsCommandTarget(goalID: "goal-1", destination: .you),
            privacy: .standard,
            occurredAt: "2026-06-30T06:00:45Z",
            payload: .proofAttached(
                RuntimeProofAttachmentEventPayload(
                    proofID: "proof-1",
                    objectID: "goal-1",
                    sourceRecordIDs: ["source-1"]
                )
            )
        )
    }

    func repoRoot() throws -> URL {
        var candidate = URL(fileURLWithPath: #filePath)
        while candidate.path != "/" {
            if FileManager.default.fileExists(atPath: candidate.appendingPathComponent("project.yml").path) {
                return candidate
            }
            candidate.deleteLastPathComponent()
        }
        throw NSError(domain: "ProjectionEngineTests", code: 1)
    }

    func scratchDirectory() throws -> URL {
        let directory = URL(fileURLWithPath: "/tmp", isDirectory: true)
            .appendingPathComponent("ambitions-projection-engine-tests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        addTeardownBlock {
            try? FileManager.default.removeItem(at: directory)
        }
        return directory
    }
}
