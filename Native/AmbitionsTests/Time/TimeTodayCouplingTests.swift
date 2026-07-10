import XCTest
@testable import Ambitions

final class TimeTodayCouplingTests: XCTestCase {
    func testPlaceStepUpdatesTimeAndTodayAndRuntimeRequiresCoupling() throws {
        let before = try LifeShapeEngine().project(LifeShapeStressScenarios.denseDayInput)
        let target = try XCTUnwrap(before.todayBuckets.first { $0.layer == .open })
        let command = timeCommand(kind: .placeStepInTime, timeID: target.id, stepID: "step.deep-work")

        let mutation = try TimeMutation.make(command: command, beforeProjection: before)
        let afterTarget = try XCTUnwrap(mutation.afterProjection.todayBuckets.first { $0.id == target.id })
        let runtime = PrivateLifeRuntime()

        XCTAssertEqual(mutation.actionKind, .placeStep)
        XCTAssertEqual(afterTarget.recommendedStepID, "step.deep-work")
        XCTAssertLessThan(afterTarget.end, target.end)
        XCTAssertTrue(mutation.todayRecompute.recomputedToday)
        XCTAssertTrue(mutation.todayRecompute.hasTimeCauseProof)
        XCTAssertEqual(mutation.todayRecompute.afterStartHereStepID, "step.deep-work")
        XCTAssertNil(runtime.mutation(
            for: command,
            beforeSnapshot: before.semanticSummary,
            afterSnapshot: mutation.afterProjection.semanticSummary,
            targetSurface: .time
        ))

        let runtimeMutation = runtime.mutation(
            for: command,
            beforeSnapshot: before.semanticSummary,
            afterSnapshot: mutation.afterProjection.semanticSummary,
            targetSurface: .time,
            timeMutation: mutation
        )

        XCTAssertNotNil(runtimeMutation)
        XCTAssertEqual(runtimeMutation?.stageMutation.visibleUserFacingChange, "Step placed")
        XCTAssertEqual(runtimeMutation?.timeMutation?.todayRecompute.afterStartHereStepID, "step.deep-work")
        XCTAssertTrue(runtimeMutation?.stageMutation.affectedObjectIDs.contains(target.id) == true)
    }

    func testCommittedTimeCommandAdvancesTodayFromSameAuthorityLineageAndReplaysIdentically() async throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("time-today-authority-\(UUID().uuidString)", isDirectory: true)
        defer { try? FileManager.default.removeItem(at: root) }
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        let eventURL = root.appendingPathComponent("EventStore.sqlite")
        let projectionURL = root.appendingPathComponent("ProjectionStore.sqlite")
        let scheduleURL = root.appendingPathComponent("LifeCalendar.json")
        let command = timeCommand(
            kind: .placeStepInTime,
            timeID: "time.today.lineage",
            stepID: "step.today.lineage",
            metadata: [
                "start": "2027-02-19T13:00:00Z",
                "end": "2027-02-19T13:30:00Z",
            ]
        )
        let context = CommandExecutionContext(now: try XCTUnwrap(DomainTimestamp.date(from: command.createdAt)))
        let events = EventStoreSQLite(databaseURL: eventURL, deviceID: "time-today-first")
        let projections = ProjectionStoreSQLite(databaseURL: projectionURL)
        let first = await AmbitionsCommandExecutor.test(
            runtimeEvents: events,
            projectionStore: projections,
            scheduleStoreFileURL: scheduleURL
        ).execute(command, context: context)

        XCTAssertEqual(first.status, .succeeded)
        let storedReceipt = try await events.authorityReceipt(commandID: command.id)
        let receipt = try XCTUnwrap(storedReceipt)
        let storedFirstTodayRecord = try await projections.fetchRecord(id: .today)
        let firstTodayRecord = try XCTUnwrap(storedFirstTodayRecord)
        let firstToday = try LocalRuntimeStorageCoding.decode(TodayProjection.self, from: firstTodayRecord.payloadData)
        let storedFirstTimeRecord = try await projections.fetchRecord(id: .time)
        let firstTimeRecord = try XCTUnwrap(storedFirstTimeRecord)
        let authorityEvents = try await events.fetchEvents(matching: .all, limit: nil)
        let semanticEvent = try XCTUnwrap(authorityEvents.first { $0.event.kind == .domainMutation })
        let commandEvent = try XCTUnwrap(authorityEvents.first { $0.id == receipt.eventID })

        XCTAssertEqual(semanticEvent.event.commandID, receipt.commandID)
        XCTAssertEqual(commandEvent.event.commandID, receipt.commandID)
        XCTAssertEqual(commandEvent.previousChecksum, semanticEvent.checksum)
        XCTAssertEqual(firstToday.cursor.sequence, receipt.eventCursor.sequence)
        XCTAssertEqual(firstTimeRecord.cursor.sequence, receipt.eventCursor.sequence)
        XCTAssertEqual(firstToday.timeMutationEventIDs, [semanticEvent.id])
        XCTAssertEqual(firstToday.recentRecords.last?.commandID, command.id)
        XCTAssertEqual(firstToday.recentRecords.last?.metadata["domainEventTypeID"], "ambitions.time.step_placed")

        var legacyPayload = try XCTUnwrap(JSONSerialization.jsonObject(with: firstTodayRecord.payloadData) as? [String: Any])
        legacyPayload.removeValue(forKey: "timeMutationEventIDs")
        let legacyData = try JSONSerialization.data(withJSONObject: legacyPayload, options: [.sortedKeys])
        let legacyToday = try LocalRuntimeStorageCoding.decode(TodayProjection.self, from: legacyData)
        XCTAssertEqual(legacyToday.timeMutationEventIDs, [])
        try await projections.save([StoredProjectionRecord(
            id: .today,
            cursor: firstTodayRecord.cursor,
            payloadChecksum: LocalRuntimeStorageChecksum.sha256Hex(for: legacyData),
            payloadSchemaVersion: firstTodayRecord.payloadSchemaVersion,
            payloadData: legacyData,
            materializedAt: firstTodayRecord.materializedAt,
            updatedAt: firstTodayRecord.updatedAt
        )])

        let restartedEvents = EventStoreSQLite(databaseURL: eventURL, deviceID: "time-today-restarted")
        let restartedProjections = ProjectionStoreSQLite(databaseURL: projectionURL)
        let rebuilt = try await ProjectionMaterializer(store: restartedEvents).materializeAll(
            materializedAt: firstToday.cursor.materializedAt
        )
        try await restartedProjections.save(batch: rebuilt, updatedAt: firstTodayRecord.updatedAt)
        let replay = await AmbitionsCommandExecutor.test(
            runtimeEvents: restartedEvents,
            projectionStore: restartedProjections,
            scheduleStoreFileURL: scheduleURL
        ).execute(command, context: context)
        let storedReplayedTodayRecord = try await restartedProjections.fetchRecord(id: .today)
        let replayedTodayRecord = try XCTUnwrap(storedReplayedTodayRecord)
        let replayedToday = try LocalRuntimeStorageCoding.decode(TodayProjection.self, from: replayedTodayRecord.payloadData)

        XCTAssertEqual(replay.status, .succeeded)
        XCTAssertEqual(replay.metadata["runtimeReceiptID"], first.metadata["runtimeReceiptID"])
        XCTAssertEqual(replayedTodayRecord.payloadChecksum, firstTodayRecord.payloadChecksum)
        XCTAssertEqual(replayedToday, firstToday)
    }

    func testLiveTodayReadModelShowsCommittedLifeCalendarBlockAndRemovesItAfterUndo() async throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("time-today-live-read-model-\(UUID().uuidString)", isDirectory: true)
        defer { try? FileManager.default.removeItem(at: root) }
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        let scheduleURL = root.appendingPathComponent("LifeCalendar.json")
        let projections = ProjectionStoreSQLite(databaseURL: root.appendingPathComponent("ProjectionStore.sqlite"))
        let executor = AmbitionsCommandExecutor.test(
            runtimeEvents: EventStoreSQLite(databaseURL: root.appendingPathComponent("EventStore.sqlite")),
            projectionStore: projections,
            scheduleStoreFileURL: scheduleURL
        )
        let repositories = try makeRepositories()
        let today = RepositoryBackedTodayService(
            repositories: repositories,
            lifeCalendarStoreFileURL: scheduleURL
        )
        let now = try XCTUnwrap(DomainTimestamp.date(from: "2027-02-19T12:20:00Z"))
        let before = try await today.loadTodayExperience(
            userDisplayName: "Local User",
            now: now,
            entryContext: .standard
        )
        XCTAssertTrue(before.execution.todayTimeLayer.items.isEmpty)

        let place = timeCommand(
            kind: .placeStepInTime,
            timeID: "time.today.visible",
            stepID: "step.today.visible",
            title: "Visible scheduled step",
            metadata: [
                "start": "2027-02-19T13:00:00Z",
                "end": "2027-02-19T13:30:00Z",
            ]
        )
        let placed = await executor.execute(place, context: CommandExecutionContext(now: now))
        let afterPlace = try await today.loadTodayExperience(
            userDisplayName: "Local User",
            now: now,
            entryContext: .standard
        )

        XCTAssertEqual(placed.status, .succeeded)
        XCTAssertTrue(afterPlace.execution.todayTimeLayer.items.contains { item in
            item.id.contains("time.today.visible") && item.title == "Visible scheduled step"
        })
        XCTAssertNotEqual(afterPlace.execution.todayTimeLayer, before.execution.todayTimeLayer)

        let receiptID = try XCTUnwrap(placed.metadata["runtimeReceiptID"])
        let storedTimeProjection = try await projections.fetchRecord(id: .time)
        let timeProjection = try XCTUnwrap(storedTimeProjection)
        let undo = AmbitionsCommand(
            id: "command.time.undo.today-visible",
            kind: .correctTimeWindow,
            source: .time,
            target: place.target,
            payload: AmbitionsCommandPayload(
                title: "Undo",
                metadata: [
                    "undoOriginalReceiptID": receiptID,
                    "expectedProjectionVersion": String(timeProjection.cursor.sequence),
                ]
            ),
            createdAt: "2027-02-19T12:21:00Z"
        )
        let undone = await executor.execute(undo, context: CommandExecutionContext(now: now.addingTimeInterval(60)))
        let afterUndo = try await today.loadTodayExperience(
            userDisplayName: "Local User",
            now: now,
            entryContext: .standard
        )

        XCTAssertEqual(undone.status, .succeeded)
        XCTAssertFalse(afterUndo.execution.todayTimeLayer.items.contains { $0.id.contains("time.today.visible") })
    }

    func testProtectWindowUpdatesTimeAndTodayAvoidsAffectedWindow() throws {
        let before = try LifeShapeEngine().project(LifeShapeStressScenarios.calendarDeniedManualInput)
        let target = try XCTUnwrap(before.todayBuckets.first { $0.layer == .open })
        let command = timeCommand(kind: .protectTimeWindow, timeID: target.id, title: "School pickup")

        let mutation = try TimeMutation.make(command: command, beforeProjection: before)
        let afterTarget = try XCTUnwrap(mutation.afterProjection.todayBuckets.first { $0.id == target.id })

        XCTAssertEqual(afterTarget.layer, .protected)
        XCTAssertEqual(afterTarget.protectedBoundary?.title, "School pickup")
        XCTAssertTrue(mutation.todayRecompute.recomputedToday)
        XCTAssertTrue(mutation.todayRecompute.todayRecommendationAvoidsAffectedWindow)
        XCTAssertTrue(mutation.todayRecompute.afterAvoidedBucketIDs.contains(target.id))
        XCTAssertEqual(mutation.todayRecompute.actionKind, .protectWindow)
    }

    func testCorrectionsUpdateFutureFitAndTodayWhenRelevant() throws {
        let before = try LifeShapeEngine().project(LifeShapeStressScenarios.denseDayInput)
        let target = try XCTUnwrap(before.todayBuckets.first { $0.layer == .open })
        let placed = try TimeMutation.make(
            command: timeCommand(kind: .placeStepInTime, timeID: target.id, stepID: "step.needs-room"),
            beforeProjection: before
        )

        let needsMoreTime = try TimeMutation.make(
            command: timeCommand(
                kind: .correctTimeWindow,
                timeID: target.id,
                metadata: ["correctionKind": TimeMutationActionKind.needsMoreTime.rawValue]
            ),
            beforeProjection: placed.afterProjection
        )
        let notUsable = try TimeMutation.make(
            command: timeCommand(
                kind: .correctTimeWindow,
                timeID: target.id,
                metadata: ["correctionKind": TimeMutationActionKind.notUsable.rawValue]
            ),
            beforeProjection: before
        )
        let keepClear = try TimeMutation.make(
            command: timeCommand(
                kind: .correctTimeWindow,
                timeID: target.id,
                title: "Keep this clear",
                metadata: ["correctionKind": TimeMutationActionKind.keepClear.rawValue]
            ),
            beforeProjection: before
        )

        XCTAssertNil(needsMoreTime.afterProjection.todayBuckets.first { $0.id == target.id }?.recommendedStepID)
        XCTAssertNotEqual(needsMoreTime.todayRecompute.beforeStartHereStepID, needsMoreTime.todayRecompute.afterStartHereStepID)
        XCTAssertFalse(notUsable.afterProjection.todayBuckets.contains { $0.id == target.id })
        XCTAssertTrue(notUsable.todayRecompute.recomputedToday)
        XCTAssertEqual(keepClear.afterProjection.todayBuckets.first { $0.id == target.id }?.protectedBoundary?.kind, .keepClearCorrection)
        XCTAssertTrue(keepClear.todayRecompute.todayRecommendationAvoidsAffectedWindow)
    }

    func testAMB1171MakeTodayLighterUpdatesPressureAndTodayCoupling() throws {
        let now = try XCTUnwrap(ISO8601DateFormatter().date(from: "2027-02-19T12:20:00Z"))
        let field = PreviewTimeScenarios.seeded.lifeSuite.field
        let pressureMark = try XCTUnwrap(field.semanticMarks.first { $0.kind == .pressure })
        let before = try LifeShapeProjection.fromVisibleTimeField(
            field,
            selectedMark: pressureMark,
            preferredLayer: .pressure,
            now: now
        )
        let target = try XCTUnwrap(before.todayBuckets.first { $0.layer == .pressure })
        let command = timeCommand(
            kind: .correctTimeWindow,
            timeID: target.id,
            title: "Make today lighter",
            metadata: ["correctionKind": TimeMutationActionKind.makeTodayLighter.rawValue]
        )

        let mutation = try TimeMutation.make(command: command, beforeProjection: before)
        let runtimeMutation = PrivateLifeRuntime().mutation(
            for: command,
            beforeSnapshot: before.semanticSummary,
            afterSnapshot: mutation.afterProjection.semanticSummary,
            targetSurface: .time,
            timeMutation: mutation
        )
        let afterTarget = try XCTUnwrap(mutation.afterProjection.todayBuckets.first { $0.id == target.id })

        XCTAssertEqual(mutation.actionKind, .makeTodayLighter)
        XCTAssertEqual(afterTarget.layer, .pressure)
        XCTAssertEqual(afterTarget.reading.kind, .pressure)
        XCTAssertEqual(afterTarget.reading.title, "Light")
        XCTAssertTrue(mutation.todayRecompute.recomputedToday)
        XCTAssertTrue(mutation.todayRecompute.hasTimeCauseProof)
        XCTAssertTrue(mutation.todayRecompute.affectedBucketIDs.contains(target.id))
        XCTAssertEqual(runtimeMutation?.stageMutation.visibleUserFacingChange, "Today made lighter")
        XCTAssertTrue(runtimeMutation?.stageMutation.accessibilityAnnouncement.message.contains("Today made lighter") == true)
    }

    func testAMB1173AddBufferUpdatesTimeAndTodayCoupling() throws {
        let now = try XCTUnwrap(ISO8601DateFormatter().date(from: "2027-02-19T12:20:00Z"))
        let field = PreviewTimeScenarios.seeded.lifeSuite.field
        let bufferMark = try XCTUnwrap(field.semanticMarks.first { $0.kind == .transitionFriction })
        let before = try LifeShapeProjection.fromVisibleTimeField(
            field,
            selectedMark: bufferMark,
            preferredLayer: .buffer,
            now: now
        )
        let target = try XCTUnwrap(before.todayBuckets.first { $0.layer == .buffer })
        let command = timeCommand(
            kind: .correctTimeWindow,
            timeID: target.id,
            title: "Add buffer",
            metadata: ["correctionKind": TimeMutationActionKind.addBuffer.rawValue]
        )

        let mutation = try TimeMutation.make(command: command, beforeProjection: before)
        let runtimeMutation = PrivateLifeRuntime().mutation(
            for: command,
            beforeSnapshot: before.semanticSummary,
            afterSnapshot: mutation.afterProjection.semanticSummary,
            targetSurface: .time,
            timeMutation: mutation
        )
        let afterTarget = try XCTUnwrap(mutation.afterProjection.todayBuckets.first { $0.id == target.id })

        XCTAssertEqual(mutation.actionKind, .addBuffer)
        XCTAssertEqual(afterTarget.layer, .buffer)
        XCTAssertEqual(afterTarget.reading.kind, .buffer)
        XCTAssertEqual(afterTarget.reading.title, "Buffer added")
        XCTAssertEqual(afterTarget.reading.capacityStatement, "Add room")
        XCTAssertTrue(mutation.todayRecompute.recomputedToday)
        XCTAssertTrue(mutation.todayRecompute.hasTimeCauseProof)
        XCTAssertTrue(mutation.todayRecompute.affectedBucketIDs.contains(target.id))
        XCTAssertEqual(runtimeMutation?.stageMutation.visibleUserFacingChange, "Buffer added")
        XCTAssertTrue(runtimeMutation?.stageMutation.accessibilityAnnouncement.message.contains("Buffer added") == true)
    }

    private func timeCommand(
        kind: AmbitionsCommandKind,
        timeID: String,
        stepID: String? = nil,
        title: String = "Write outline",
        metadata: [String: String] = [:]
    ) -> AmbitionsCommand {
        AmbitionsCommand(
            id: "command.\(kind.rawValue).\(timeID)",
            kind: kind,
            source: .time,
            target: AmbitionsCommandTarget(goalID: "goal.book", timeID: timeID, stepID: stepID),
            payload: AmbitionsCommandPayload(title: title, metadata: metadata),
            createdAt: "2027-02-19T12:20:00Z"
        )
    }

    private func makeRepositories() throws -> AppRepositories {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        return AppRepositories(
            goals: SwiftDataGoalRepository(store: store),
            drafts: SwiftDataGoalDraftRepository(store: store),
            evidence: SwiftDataProgressEvidenceRepository(store: store),
            feedback: SwiftDataFeedbackEventRepository(store: store),
            captures: SwiftDataCaptureRepository(store: store),
            eventLedger: InMemoryEventLedgerRepository(),
            commandExecutionRecords: InMemoryAmbitionsCommandExecutionRecordRepository(),
            runtimeEvents: InMemoryRuntimeEventStore(),
            appState: SwiftDataAppStateRepository(store: store)
        )
    }
}
