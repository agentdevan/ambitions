import XCTest
import SQLite3
@testable import Ambitions

final class TimeDurableMutationIntegrationTests: XCTestCase {
    func testProtectThenOrdinaryCorrectionRestartReplacesExactDurableWindow() async throws {
        let root = try makeRoot("time-protect-correct")
        defer { try? FileManager.default.removeItem(at: root) }
        let eventURL = root.appendingPathComponent("EventStore.sqlite")
        let projectionURL = root.appendingPathComponent("ProjectionStore.sqlite")
        let scheduleURL = root.appendingPathComponent("LifeCalendar.json")
        let events = EventStoreSQLite(databaseURL: eventURL)
        let projections = ProjectionStoreSQLite(databaseURL: projectionURL)
        let executor = AmbitionsCommandExecutor.test(
            runtimeEvents: events,
            projectionStore: projections,
            scheduleStoreFileURL: scheduleURL
        )
        let protect = windowCommand(id: "command.time.protect", kind: .protectTimeWindow)
        let correct = windowCommand(
            id: "command.time.correct",
            kind: .correctTimeWindow,
            metadata: ["correctionKind": TimeMutationActionKind.keepClear.rawValue]
        )

        let protected = await executor.execute(protect, context: commandContext(protect))
        let corrected = await executor.execute(correct, context: commandContext(correct))

        XCTAssertEqual(protected.status, .succeeded)
        XCTAssertNotNil(protected.metadata["runtimeReceiptID"])
        XCTAssertEqual(corrected.status, .succeeded)
        XCTAssertNotNil(corrected.metadata["runtimeReceiptID"])
        let semanticEnvelopes = try await events.fetchEvents(matching: .kind(.domainMutation), limit: nil)
        let semanticEvents = try semanticEnvelopes.compactMap { envelope -> RuntimeDomainEvent? in
            guard case let .domainMutation(record) = envelope.event.payload else { return nil }
            return try record.decodedEvent()
        }
        XCTAssertTrue(semanticEvents.contains { if case .timeWindowProtected = $0 { true } else { false } })
        XCTAssertTrue(semanticEvents.contains { if case .timeWindowCorrected = $0 { true } else { false } })
        let storedProjectionBeforeRestart = try await projections.fetchRecord(id: .time)
        let projectionBeforeRestart = try XCTUnwrap(storedProjectionBeforeRestart)
        let schedule = LifeCalendarStore(fileURL: scheduleURL)
        _ = try await schedule.loadFromDisk()
        let correctedGraph = await schedule.graph()
        XCTAssertEqual(correctedGraph.blocks.count, 1)
        XCTAssertEqual(correctedGraph.blocks.first?.id, "window.shared")
        XCTAssertEqual(correctedGraph.blocks.first?.title, "Keep this clear")
        XCTAssertEqual(correctedGraph.blocks.first?.commandID, correct.id)

        let restartedEvents = EventStoreSQLite(databaseURL: eventURL)
        let restartedProjections = ProjectionStoreSQLite(databaseURL: projectionURL)
        let replay = await AmbitionsCommandExecutor.test(
            runtimeEvents: restartedEvents,
            projectionStore: restartedProjections,
            scheduleStoreFileURL: scheduleURL
        ).execute(correct, context: commandContext(correct))
        XCTAssertEqual(replay.metadata["runtimeReceiptID"], corrected.metadata["runtimeReceiptID"])
        let storedProjectionAfterRestart = try await restartedProjections.fetchRecord(id: .time)
        let projectionAfterRestart = try XCTUnwrap(storedProjectionAfterRestart)
        XCTAssertEqual(projectionAfterRestart.payloadChecksum, projectionBeforeRestart.payloadChecksum)
        let restartedSchedule = LifeCalendarStore(fileURL: scheduleURL)
        _ = try await restartedSchedule.loadFromDisk()
        let restartedGraph = await restartedSchedule.graph()
        XCTAssertEqual(restartedGraph.blocks.count, 1)
        XCTAssertEqual(restartedGraph.blocks.first?.id, "window.shared")
        XCTAssertEqual(restartedGraph.blocks.first?.commandID, correct.id)
    }

    func testEveryCorrectionKindRetainsDistinctDurableSemanticsWithoutAddingFalsePressure() async throws {
        let root = try makeRoot("time-correction-semantics")
        defer { try? FileManager.default.removeItem(at: root) }
        let scheduleURL = root.appendingPathComponent("LifeCalendar.json")
        let executor = AmbitionsCommandExecutor.test(
            runtimeEvents: EventStoreSQLite(databaseURL: root.appendingPathComponent("EventStore.sqlite")),
            projectionStore: ProjectionStoreSQLite(databaseURL: root.appendingPathComponent("ProjectionStore.sqlite")),
            scheduleStoreFileURL: scheduleURL
        )
        let expectedKinds: [(TimeMutationActionKind, String, TimeBlockKind)] = [
            (.notUsable, "Not usable", .unavailable),
            (.needsMoreTime, "Needs more time", .needsMoreTime),
            (.keepClear, "Keep this clear", .keepClear),
            (.makeTodayLighter, "Today made lighter", .lighterPressure),
            (.addBuffer, "Buffer added", .buffer),
        ]

        for (index, pair) in expectedKinds.enumerated() {
            let command = windowCommand(
                id: "command.time.correction.\(pair.0.rawValue)",
                kind: .correctTimeWindow,
                timeID: "window.correction.\(index)",
                metadata: ["correctionKind": pair.0.rawValue]
            )
            let result = await executor.execute(command, context: commandContext(command))
            XCTAssertEqual(result.status, .succeeded)
        }

        let store = LifeCalendarStore(fileURL: scheduleURL)
        _ = try await store.loadFromDisk()
        let blocks = await store.graph().blocks
        XCTAssertEqual(Dictionary(uniqueKeysWithValues: blocks.map { ($0.title, $0.kind) }), Dictionary(uniqueKeysWithValues: expectedKinds.map { ($0.1, $0.2) }))
        XCTAssertFalse(try XCTUnwrap(blocks.first { $0.kind == .lighterPressure }).kind.consumesCapacity)
        XCTAssertTrue(try XCTUnwrap(blocks.first { $0.kind == .keepClear }).kind.protectsBoundary)
    }

    func testDuplicateCommandReturnsOneReceiptOneJournalEnvelopeAndOneScheduleBlock() async throws {
        let root = try makeRoot("time-duplicate")
        defer { try? FileManager.default.removeItem(at: root) }
        let journal = FileCommandJournal(fileURL: root.appendingPathComponent("CommandJournal.jsonl"))
        let events = EventStoreSQLite(databaseURL: root.appendingPathComponent("EventStore.sqlite"))
        let projections = ProjectionStoreSQLite(databaseURL: root.appendingPathComponent("ProjectionStore.sqlite"))
        let scheduleURL = root.appendingPathComponent("LifeCalendar.json")
        let executor = AmbitionsCommandExecutor.test(
            runtimeEvents: events,
            projectionStore: projections,
            commandJournal: journal,
            scheduleStoreFileURL: scheduleURL
        )
        let command = placementCommand(id: "command.time.duplicate")
        let context = CommandExecutionContext(now: try XCTUnwrap(DomainTimestamp.date(from: command.createdAt)))

        let first = await executor.execute(command, context: context)
        let duplicate = await executor.execute(command, context: context)

        XCTAssertEqual(first.status, .succeeded)
        XCTAssertEqual(duplicate.status, .succeeded)
        XCTAssertEqual(duplicate.metadata["runtimeReceiptID"], first.metadata["runtimeReceiptID"])
        let envelopes = try await journal.fetchEnvelopes(matching: .commandID(command.id), limit: nil)
        XCTAssertEqual(envelopes.count, 1)
        let semanticEvents = try await events.fetchEvents(matching: .kind(.domainMutation), limit: nil)
        XCTAssertEqual(semanticEvents.count, 1)
        let schedule = LifeCalendarStore(fileURL: scheduleURL)
        _ = try await schedule.loadFromDisk()
        let duplicateGraph = await schedule.graph()
        XCTAssertEqual(duplicateGraph.blocks.map(\.id), ["block.restart"])
    }

    func testJournalFailureHasNoVisibleSuccessScheduleOrExternalWrite() async throws {
        let root = try makeRoot("time-journal-failure")
        defer { try? FileManager.default.removeItem(at: root) }
        let scheduleURL = root.appendingPathComponent("LifeCalendar.json")
        let ledger = InMemoryEventLedgerRepository()
        let command = placementCommand(id: "command.time.journal-failure")
        let result = await AmbitionsCommandExecutor.test(
            eventLedger: ledger,
            commandJournal: TimeFailingCommandJournal(),
            scheduleStoreFileURL: scheduleURL
        ).execute(command, context: commandContext(command))

        XCTAssertEqual(result.status, .blocked)
        XCTAssertEqual(result.metadata["blockedBy"], "command_journal_append_failed")
        XCTAssertNil(result.metadata["runtimeReceiptID"])
        XCTAssertFalse(FileManager.default.fileExists(atPath: scheduleURL.path))
        let ledgerEntries = try await ledger.fetchRecent(limit: 10)
        XCTAssertTrue(ledgerEntries.isEmpty)
    }

    func testEventAppendFailureHasNoVisibleSuccessScheduleOrExternalWrite() async throws {
        let root = try makeRoot("time-event-failure")
        defer { try? FileManager.default.removeItem(at: root) }
        let scheduleURL = root.appendingPathComponent("LifeCalendar.json")
        let ledger = InMemoryEventLedgerRepository()
        let command = placementCommand(id: "command.time.event-failure")
        let result = await AmbitionsCommandExecutor.test(
            eventLedger: ledger,
            runtimeEvents: TimeFailingEventStore(),
            scheduleStoreFileURL: scheduleURL
        ).execute(command, context: commandContext(command))

        XCTAssertEqual(result.status, .blocked)
        XCTAssertEqual(result.metadata["blockedBy"], "runtime_transaction_commit_failed")
        XCTAssertNil(result.metadata["runtimeReceiptID"])
        XCTAssertFalse(FileManager.default.fileExists(atPath: scheduleURL.path))
        let ledgerEntries = try await ledger.fetchRecent(limit: 10)
        XCTAssertTrue(ledgerEntries.isEmpty)
    }

    func testAuthorityReceiptFailureHasNoVisibleSuccessScheduleOrExternalWrite() async throws {
        let root = try makeRoot("time-receipt-failure")
        defer { try? FileManager.default.removeItem(at: root) }
        let databaseURL = root.appendingPathComponent("EventStore.sqlite")
        let eventStore = EventStoreSQLite(databaseURL: databaseURL)
        _ = try await eventStore.authorityReceipt(commandID: "schema-bootstrap")
        try installAuthorityReceiptAbortTrigger(databaseURL: databaseURL)
        let scheduleURL = root.appendingPathComponent("LifeCalendar.json")
        let ledger = InMemoryEventLedgerRepository()
        let command = placementCommand(id: "command.time.receipt-failure")
        let result = await AmbitionsCommandExecutor.test(
            eventLedger: ledger,
            runtimeEvents: eventStore,
            scheduleStoreFileURL: scheduleURL
        ).execute(command, context: commandContext(command))

        XCTAssertEqual(result.status, .blocked)
        XCTAssertEqual(result.metadata["runtimeTransactionDisposition"], "not_committed")
        XCTAssertNil(result.metadata["runtimeReceiptID"])
        XCTAssertFalse(FileManager.default.fileExists(atPath: scheduleURL.path))
        let rolledBackEvents = try await eventStore.fetchEvents(matching: .all, limit: nil)
        XCTAssertTrue(rolledBackEvents.isEmpty)
        let rolledBackReceipt = try await eventStore.authorityReceipt(commandID: command.id)
        XCTAssertNil(rolledBackReceipt)
        let rolledBackOutbox = try await eventStore.outboxIntents(commandID: command.id)
        XCTAssertTrue(rolledBackOutbox.isEmpty)
        let ledgerEntries = try await ledger.fetchRecent(limit: 10)
        XCTAssertTrue(ledgerEntries.isEmpty)
    }

    func testProjectionFailureKeepsCommittedAuthorityButViewModelCannotShowSyntheticSuccess() async throws {
        let root = try makeRoot("time-projection-failure")
        defer { try? FileManager.default.removeItem(at: root) }
        let invalidProjectionURL = root.appendingPathComponent("ProjectionStore.sqlite", isDirectory: true)
        try FileManager.default.createDirectory(at: invalidProjectionURL, withIntermediateDirectories: true)
        let eventStore = EventStoreSQLite(databaseURL: root.appendingPathComponent("EventStore.sqlite"))
        let projectionStore = ProjectionStoreSQLite(databaseURL: invalidProjectionURL)
        let scheduleURL = root.appendingPathComponent("LifeCalendar.json")
        let command = placementCommand(id: "command.time.projection-failure")
        let executor = AmbitionsCommandExecutor.test(
            runtimeEvents: eventStore,
            projectionStore: projectionStore,
            scheduleStoreFileURL: scheduleURL
        )
        let result = await executor.execute(command, context: commandContext(command))

        XCTAssertEqual(result.status, .succeeded)
        XCTAssertEqual(result.metadata["runtimeProjectionStoreStatus"], "needs_recovery")
        XCTAssertNotNil(result.metadata["runtimeReceiptID"])
        XCTAssertTrue(FileManager.default.fileExists(atPath: scheduleURL.path))
        let initial = PreviewTimeScenarios.seeded
        let viewModel = await MainActor.run { TimeViewModel(state: .loaded(initial)) }
        let client = RuntimeCommandClient(
            execute: { _, _ in result },
            projection: { request in throw RuntimeProjectionClientError.projectionUnavailable(request) }
        )
        await viewModel.performLifeShapeMutation(
            .protectWindow,
            selectedMark: initial.lifeSuite.field.semanticMarks.first { $0.kind == .protectedTime },
            now: commandContext(command).now,
            runtimeClient: client,
            service: StubTimeService(timeState: PreviewTimeScenarios.seeded, weeklyReviewState: PreviewTimeScenarios.weeklyReview),
            calendar: Calendar(identifier: .gregorian),
            timeZone: TimeZone(secondsFromGMT: 0)!
        )
        let visibleMutation = await MainActor.run { viewModel.visibleTimeMutation }
        XCTAssertNil(visibleMutation)
    }

    func testStaleProjectionCannotBePresentedAsSuccessForNewReceipt() async throws {
        let initial = PreviewTimeScenarios.seeded
        let viewModel = await MainActor.run { TimeViewModel(state: .loaded(initial)) }
        let result = AmbitionsCommandExecutionResult(
            status: .succeeded,
            summary: "Time authority committed but the client projection is stale.",
            route: .time,
            metadata: [
                "runtimeReceiptID": "runtime.receipt.command.time.stale-projection",
                "runtimeProjectionStoreStatus": "saved",
                "timeMaterialization": "saved_post_authority",
                "runtimeMaterializedProjectionCursorIDs": "time",
                "runtimeMaterializedProjectionCursorSequences": "8",
                "runtimeMaterializedProjectionCursorChecksums": "checksum-time-8",
            ]
        )
        let client = RuntimeCommandClient(
            execute: { _, _ in result },
            projection: { request in
                guard request == .time else { throw RuntimeProjectionClientError.projectionUnavailable(request) }
                return RuntimeProjectionSnapshot(
                    projectionID: "time",
                    payload: Data("{}".utf8),
                    eventSequence: 7,
                    cursorChecksum: "checksum-time-7",
                    payloadChecksum: "checksum-time-7",
                    materializedAt: "2027-02-19T12:20:00Z"
                )
            }
        )

        await viewModel.performLifeShapeMutation(
            .protectWindow,
            selectedMark: initial.lifeSuite.field.semanticMarks.first { $0.kind == .protectedTime },
            now: Date(timeIntervalSince1970: 1_803_046_800),
            runtimeClient: client,
            service: StubTimeService(timeState: initial, weeklyReviewState: PreviewTimeScenarios.weeklyReview),
            calendar: Calendar(identifier: .gregorian),
            timeZone: TimeZone(secondsFromGMT: 0)!
        )

        let visibleMutation = await MainActor.run { viewModel.visibleTimeMutation }
        let errorMessage = await MainActor.run { viewModel.mutationErrorMessage }
        XCTAssertNil(visibleMutation)
        XCTAssertNotNil(errorMessage)
    }

    func testFailedScheduleMaterializationCannotPresentCommittedProjectionAsVisibleSuccess() async throws {
        let initial = PreviewTimeScenarios.seeded
        let viewModel = await MainActor.run { TimeViewModel(state: .loaded(initial)) }
        let result = AmbitionsCommandExecutionResult(
            status: .succeeded,
            summary: "Time authority committed but Life Calendar materialization needs recovery.",
            route: .time,
            metadata: [
                "runtimeReceiptID": "runtime.receipt.command.time.materialization-recovery",
                "runtimeProjectionStoreStatus": "saved",
                "timeMaterialization": "needs_recovery",
                "runtimeMaterializedProjectionCursorIDs": "time",
                "runtimeMaterializedProjectionCursorSequences": "8",
                "runtimeMaterializedProjectionCursorChecksums": "checksum-time-8",
            ]
        )
        let client = RuntimeCommandClient(
            execute: { _, _ in result },
            projection: { request in
                guard request == .time else { throw RuntimeProjectionClientError.projectionUnavailable(request) }
                return RuntimeProjectionSnapshot(
                    projectionID: "time",
                    payload: Data("{}".utf8),
                    eventSequence: 8,
                    cursorChecksum: "checksum-time-8",
                    payloadChecksum: "checksum-time-8",
                    materializedAt: "2027-02-19T12:20:00Z"
                )
            }
        )

        await viewModel.performLifeShapeMutation(
            .protectWindow,
            selectedMark: initial.lifeSuite.field.semanticMarks.first { $0.kind == .protectedTime },
            now: Date(timeIntervalSince1970: 1_803_046_800),
            runtimeClient: client,
            service: StubTimeService(timeState: initial, weeklyReviewState: PreviewTimeScenarios.weeklyReview),
            calendar: Calendar(identifier: .gregorian),
            timeZone: TimeZone(secondsFromGMT: 0)!
        )

        let visibleMutation = await MainActor.run { viewModel.visibleTimeMutation }
        let errorMessage = await MainActor.run { viewModel.mutationErrorMessage }
        XCTAssertNil(visibleMutation)
        XCTAssertNotNil(errorMessage)
    }

    func testRealExecutorProjectionClientAndViewModelAcceptMatchingCursorLineage() async throws {
        let root = try makeRoot("time-live-client-lineage")
        defer { try? FileManager.default.removeItem(at: root) }
        let events = EventStoreSQLite(databaseURL: root.appendingPathComponent("EventStore.sqlite"))
        let projections = ProjectionStoreSQLite(databaseURL: root.appendingPathComponent("ProjectionStore.sqlite"))
        let scheduleURL = root.appendingPathComponent("LifeCalendar.json")
        let executor = AmbitionsCommandExecutor.test(
            runtimeEvents: events,
            projectionStore: projections,
            scheduleStoreFileURL: scheduleURL
        )
        let client = RuntimeCommandClient(
            execute: { command, context in
                await executor.execute(command, context: context)
            },
            projection: { request in
                guard let record = try await projections.fetchRecord(id: request.projectionID) else {
                    throw RuntimeProjectionClientError.projectionUnavailable(request)
                }
                return RuntimeProjectionSnapshot(
                    projectionID: record.id.rawValue,
                    payload: record.payloadData,
                    eventSequence: record.cursor.sequence,
                    cursorChecksum: record.cursor.checksum,
                    payloadChecksum: record.payloadChecksum,
                    materializedAt: record.materializedAt
                )
            }
        )
        let repositories = try await makeRepositories()
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let service = RepositoryBackedTimeService(
            repositories: repositories,
            lifeCalendarStoreFileURL: scheduleURL,
            calendar: calendar
        )
        let initial = PreviewTimeScenarios.seeded
        let viewModel = await MainActor.run { TimeViewModel(state: .loaded(initial)) }
        let now = try XCTUnwrap(DomainTimestamp.date(from: "2027-02-19T12:20:00Z"))

        await viewModel.performLifeShapeMutation(
            .protectWindow,
            selectedMark: initial.lifeSuite.field.semanticMarks.first { $0.kind == .protectedTime },
            now: now,
            runtimeClient: client,
            service: service,
            calendar: calendar,
            timeZone: calendar.timeZone
        )

        let visibleMutation = await MainActor.run { viewModel.visibleTimeMutation }
        let errorMessage = await MainActor.run { viewModel.mutationErrorMessage }
        let fetchedProjection = try await projections.fetchRecord(id: .time)
        let storedProjection = try XCTUnwrap(fetchedProjection)
        XCTAssertNotEqual(storedProjection.cursor.checksum, storedProjection.payloadChecksum)
        XCTAssertNotNil(visibleMutation)
        XCTAssertNil(errorMessage)
        XCTAssertEqual(visibleMutation?.stageMutation.receipt.saved, true)
    }

    func testPlaceStepSurvivesRuntimeRestartWithIdenticalProjectionReceiptAndSchedule() async throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("time-durable-mutation-\(UUID().uuidString)", isDirectory: true)
        defer { try? FileManager.default.removeItem(at: root) }
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)

        let journalURL = root.appendingPathComponent("CommandJournal.jsonl")
        let eventURL = root.appendingPathComponent("EventStore.sqlite")
        let projectionURL = root.appendingPathComponent("ProjectionStore.sqlite")
        let scheduleURL = root.appendingPathComponent("LifeCalendar.json")
        let command = placementCommand(id: "command.time.restart")
        let context = CommandExecutionContext(now: try XCTUnwrap(DomainTimestamp.date(from: command.createdAt)))

        let firstEvents = EventStoreSQLite(databaseURL: eventURL, deviceID: "time-first")
        let firstProjections = ProjectionStoreSQLite(databaseURL: projectionURL)
        let first = await AmbitionsCommandExecutor.test(
            runtimeEvents: firstEvents,
            projectionStore: firstProjections,
            commandJournal: FileCommandJournal(fileURL: journalURL),
            scheduleStoreFileURL: scheduleURL
        ).execute(command, context: context)

        XCTAssertEqual(first.status, .succeeded)
        let storedFirstProjection = try await firstProjections.fetchRecord(id: .time)
        let firstProjection = try XCTUnwrap(storedFirstProjection)
        let firstReceiptID = try XCTUnwrap(first.metadata["runtimeReceiptID"])
        let firstSchedule = try Data(contentsOf: scheduleURL)

        let restartedEvents = EventStoreSQLite(databaseURL: eventURL, deviceID: "time-restarted")
        let restartedProjections = ProjectionStoreSQLite(databaseURL: projectionURL)
        let replay = await AmbitionsCommandExecutor.test(
            runtimeEvents: restartedEvents,
            projectionStore: restartedProjections,
            commandJournal: FileCommandJournal(fileURL: journalURL),
            scheduleStoreFileURL: scheduleURL
        ).execute(command, context: context)

        XCTAssertEqual(replay.status, .succeeded)
        XCTAssertEqual(replay.metadata["runtimeReceiptID"], firstReceiptID)
        let restartedReceipt = try await restartedEvents.authorityReceipt(commandID: command.id)
        let restartedProjection = try await restartedProjections.fetchRecord(id: .time)
        XCTAssertEqual(restartedReceipt?.receiptID, firstReceiptID)
        XCTAssertEqual(restartedProjection?.payloadChecksum, firstProjection.payloadChecksum)
        XCTAssertEqual(try Data(contentsOf: scheduleURL), firstSchedule)
        let calendar = LifeCalendarStore(fileURL: scheduleURL)
        _ = try await calendar.loadFromDisk()
        let restartedGraph = await calendar.graph()
        XCTAssertEqual(restartedGraph.blocks.map(\.stepID), ["step.restart"])

        let repositories = try await makeRepositories()
        var utcCalendar = Calendar(identifier: .gregorian)
        utcCalendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let timeService = RepositoryBackedTimeService(
            repositories: repositories,
            lifeCalendarStoreFileURL: scheduleURL,
            calendar: utcCalendar
        )
        let reloadedState = try await timeService.loadTimeSurfaceState(
            now: try XCTUnwrap(DomainTimestamp.date(from: "2026-09-10T12:00:00Z"))
        )
        let scheduledRow = try XCTUnwrap(reloadedState.lifeSuite.field.calendarRows.first { $0.kind == .scheduledStep })
        XCTAssertTrue(scheduledRow.isOperational)
        XCTAssertTrue(scheduledRow.detail.contains("Restart-safe step"))
        XCTAssertTrue(reloadedState.weekDays.flatMap(\.blocks).contains { block in
            block.title == "Restart-safe step" && block.timingLabel.contains("Scheduled")
        })
    }

    func testLifeCalendarFailedPersistenceDoesNotChangeMemoryOrDisk() async throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("life-calendar-atomic-\(UUID().uuidString)", isDirectory: true)
        defer { try? FileManager.default.removeItem(at: root) }
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        let invalidFileURL = root.appendingPathComponent("directory-instead-of-file", isDirectory: true)
        try FileManager.default.createDirectory(at: invalidFileURL, withIntermediateDirectories: true)
        let initial = TimeBlock(
            id: "block.initial", title: "Initial", start: Date(timeIntervalSince1970: 1_789_123_600),
            end: Date(timeIntervalSince1970: 1_789_127_200), kind: .protected
        )
        let candidate = TimeBlock(
            id: "block.candidate", title: "Candidate", start: Date(timeIntervalSince1970: 1_789_130_800),
            end: Date(timeIntervalSince1970: 1_789_134_400), kind: .scheduledStep
        )
        let store = LifeCalendarStore(blocks: [initial], fileURL: invalidFileURL)

        do {
            _ = try await store.save(candidate)
            XCTFail("Expected persistence failure")
        } catch {
            let graphAfterFailure = await store.graph()
            XCTAssertEqual(graphAfterFailure.blocks, [initial])
            XCTAssertTrue(FileManager.default.fileExists(atPath: invalidFileURL.path))
        }
    }

    private func placementCommand(id: String) -> AmbitionsCommand {
        AmbitionsCommand(
            id: id,
            kind: .placeStepInTime,
            source: .time,
            target: AmbitionsCommandTarget(goalID: "goal.restart", timeID: "block.restart", stepID: "step.restart"),
            payload: AmbitionsCommandPayload(
                title: "Restart-safe step",
                metadata: [
                    "start": "2026-09-10T13:00:00Z",
                    "end": "2026-09-10T13:30:00Z",
                    "durationMinutes": "30",
                ]
            ),
            createdAt: "2026-09-10T12:00:00Z"
        )
    }

    private func windowCommand(
        id: String,
        kind: AmbitionsCommandKind,
        timeID: String = "window.shared",
        metadata: [String: String] = [:]
    ) -> AmbitionsCommand {
        AmbitionsCommand(
            id: id,
            kind: kind,
            source: .time,
            target: AmbitionsCommandTarget(timeID: timeID),
            payload: AmbitionsCommandPayload(
                title: kind == .protectTimeWindow ? "Protected focus" : "Keep clear",
                metadata: metadata.merging([
                    "start": "2026-09-10T14:00:00Z",
                    "end": "2026-09-10T15:00:00Z",
                ]) { current, _ in current }
            ),
            createdAt: kind == .protectTimeWindow ? "2026-09-10T12:00:00Z" : "2026-09-10T12:01:00Z"
        )
    }

    private func makeRoot(_ prefix: String) throws -> URL {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("\(prefix)-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        return root
    }

    private func commandContext(_ command: AmbitionsCommand) -> CommandExecutionContext {
        CommandExecutionContext(now: DomainTimestamp.date(from: command.createdAt)!)
    }

    private func installAuthorityReceiptAbortTrigger(databaseURL: URL) throws {
        var database: OpaquePointer?
        guard sqlite3_open(databaseURL.path, &database) == SQLITE_OK, let database else {
            throw TimeFailure.injected
        }
        defer { sqlite3_close(database) }
        let sql = """
        CREATE TRIGGER fail_time_authority_receipt
        BEFORE INSERT ON runtime_authority_commits
        BEGIN
            SELECT RAISE(ABORT, 'injected time authority receipt failure');
        END;
        """
        guard sqlite3_exec(database, sql, nil, nil, nil) == SQLITE_OK else {
            throw TimeFailure.injected
        }
    }

    private func makeRepositories() async throws -> AppRepositories {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        return AppRepositories(
            goals: SwiftDataGoalRepository(store: store),
            drafts: SwiftDataGoalDraftRepository(store: store),
            evidence: SwiftDataProgressEvidenceRepository(store: store),
            feedback: SwiftDataFeedbackEventRepository(store: store),
            captures: SwiftDataCaptureRepository(store: store),
            eventLedger: InMemoryEventLedgerRepository(),
            appState: SwiftDataAppStateRepository(store: store)
        )
    }
}

private enum TimeFailure: Error { case injected }

private actor TimeFailingCommandJournal: CommandJournal {
    func append(_ envelope: CommandEnvelope) async throws -> CommandJournalAppendReceipt { throw TimeFailure.injected }
    func fetchEntries(matching query: CommandJournalQuery, limit: Int?) async throws -> [CommandJournalEntry] { [] }
    func fetchEnvelopes(matching query: CommandJournalQuery, limit: Int?) async throws -> [CommandEnvelope] { [] }
}

private actor TimeFailingEventStore: RuntimeEventStore {
    nonisolated let storeKind = RuntimeEventStoreKind.inMemory
    func append(_ event: RuntimeEvent) async throws -> RuntimeEventEnvelope { throw TimeFailure.injected }
    func fetchEvents(matching query: RuntimeEventQuery, limit: Int?) async throws -> [RuntimeEventEnvelope] { [] }
    func latestCursor() async throws -> RuntimeEventCursor? { nil }
}
