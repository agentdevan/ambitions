import XCTest
@testable import Ambitions

final class EventLedgerRepositoryTests: XCTestCase {
    func testSwiftDataRepositoryAppendsAndFetchesRecentNewestFirst() async throws {
        let repository = try await makeRepository()
        let older = event(id: "event-older", kind: .goalCreated, occurredAt: "2026-04-24T09:00:00Z")
        let newer = event(id: "event-newer", kind: .goalUpdated, occurredAt: "2026-04-24T10:00:00Z")

        try await repository.append(older)
        try await repository.append(newer)

        let recent = try await repository.fetchRecent(limit: 2)

        XCTAssertEqual(recent.map(\.id), ["event-newer", "event-older"])
    }

    func testSwiftDataRepositoryFiltersByGoalCaptureKindAndDateRange() async throws {
        let repository = try await makeRepository()
        try await repository.append(event(id: "goal-event", kind: .goalUpdated, occurredAt: "2026-04-24T10:00:00Z", goalID: "goal-1"))
        try await repository.append(event(id: "capture-event", kind: .captureCreated, occurredAt: "2026-04-24T11:00:00Z", captureID: "capture-1"))
        try await repository.append(event(id: "range-event", kind: .reviewCompleted, occurredAt: "2026-04-24T12:00:00Z", goalID: "goal-2"))
        try await repository.append(event(id: "late-event", kind: .goalUpdated, occurredAt: "2026-04-25T10:00:00Z", goalID: "goal-1"))

        let goalEvents = try await repository.fetchEvents(goalID: "goal-1")
        let captureEvents = try await repository.fetchEvents(captureID: "capture-1")
        let updatedEvents = try await repository.fetchEvents(kind: .goalUpdated)
        let rangedEvents = try await repository.fetchEvents(
            from: "2026-04-24T10:30:00Z",
            through: "2026-04-24T12:30:00Z"
        )

        XCTAssertEqual(goalEvents.map(\.id), ["late-event", "goal-event"])
        XCTAssertEqual(captureEvents.map(\.id), ["capture-event"])
        XCTAssertEqual(updatedEvents.map(\.id), ["late-event", "goal-event"])
        XCTAssertEqual(rangedEvents.map(\.id), ["range-event", "capture-event"])
    }

    func testSwiftDataRepositoryUsesTypedDatesForOffsetOrderingAndRangeFiltering() async throws {
        let repository = try await makeRepository()
        try await repository.append(event(id: "offset-newer", kind: .goalUpdated, occurredAt: "2026-06-01T11:00:00-05:00"))
        try await repository.append(event(id: "zulu-older", kind: .goalUpdated, occurredAt: "2026-06-01T15:30:00Z"))

        let recent = try await repository.fetchRecent(limit: 2)
        let ranged = try await repository.fetchEvents(
            from: "2026-06-01T15:45:00Z",
            through: "2026-06-01T16:15:00Z"
        )

        XCTAssertEqual(recent.map(\.id), ["offset-newer", "zulu-older"])
        XCTAssertEqual(ranged.map(\.id), ["offset-newer"])
    }

    func testSwiftDataRepositoryBackfillsLegacyStringDatesWhenTypedDateIsMissing() async throws {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        let repository = SwiftDataEventLedgerRepository(store: store)
        let newerEvent = event(id: "legacy-offset-newer", kind: .goalUpdated, occurredAt: "2026-06-01T11:00:00-05:00")
        let olderEvent = event(id: "legacy-zulu-older", kind: .goalUpdated, occurredAt: "2026-06-01T15:30:00Z")

        try await store.write { context in
            let newer = try Self.legacyEventRecord(newerEvent)
            let older = try Self.legacyEventRecord(olderEvent)
            XCTAssertNil(newer.occurredAtDate)
            XCTAssertNil(older.occurredAtDate)
            context.insert(newer)
            context.insert(older)
        }

        let recent = try await repository.fetchRecent(limit: 2)

        XCTAssertEqual(recent.map(\.id), ["legacy-offset-newer", "legacy-zulu-older"])
    }

    func testSwiftDataRepositoryUsesDeterministicIDTieBreakForSameTypedDate() async throws {
        let repository = try await makeRepository()
        try await repository.append(event(id: "event-a", kind: .goalCreated, occurredAt: "2026-04-24T10:00:00Z"))
        try await repository.append(event(id: "event-b", kind: .goalUpdated, occurredAt: "2026-04-24T10:00:00Z"))

        let recent = try await repository.fetchRecent(limit: 2)

        XCTAssertEqual(recent.map(\.id), ["event-b", "event-a"])
    }

    func testSwiftDataRepositoryUpdatesExistingEventByID() async throws {
        let repository = try await makeRepository()
        let original = event(id: "event-stable", kind: .recommendationShown, occurredAt: "2026-04-24T10:00:00Z", title: "Shown")
        let updated = event(id: "event-stable", kind: .recommendationAccepted, occurredAt: "2026-04-24T10:05:00Z", title: "Accepted")

        try await repository.append(original)
        try await repository.append(updated)

        let recent = try await repository.fetchRecent(limit: 10)

        XCTAssertEqual(recent.count, 1)
        XCTAssertEqual(recent.first?.kind, .recommendationAccepted)
        XCTAssertEqual(recent.first?.title, "Accepted")
    }

    func testSwiftDataRepositoryRedactsAndDeletesEvents() async throws {
        let repository = try await makeRepository()
        try await repository.append(
            event(
                id: "event-private",
                kind: .userCorrectionAdded,
                occurredAt: "2026-04-24T10:00:00Z",
                title: "Private correction",
                summary: "Sensitive wording",
                payload: ["rawText": "Sensitive wording"]
            )
        )

        try await repository.redactEvent(id: "event-private", at: "2026-04-24T11:00:00Z")
        let redacted = try await repository.fetchRecent(limit: 1).first

        XCTAssertEqual(redacted?.title, "Redacted event")
        XCTAssertNil(redacted?.summary)
        XCTAssertEqual(redacted?.payload, [:])
        XCTAssertEqual(redacted?.metadata["redacted"], "true")
        XCTAssertEqual(redacted?.privacy, .privateUserText)
        XCTAssertEqual(redacted?.updatedAt, "2026-04-24T11:00:00Z")

        try await repository.deleteEvent(id: "event-private")

        let remaining = try await repository.fetchRecent(limit: 10)
        XCTAssertTrue(remaining.isEmpty)
    }

    func testInMemoryRepositoryUsesSameDeterministicOrdering() async throws {
        let repository = InMemoryEventLedgerRepository()

        try await repository.append(event(id: "event-a", kind: .goalCreated, occurredAt: "2026-04-24T10:00:00Z"))
        try await repository.append(event(id: "event-b", kind: .goalUpdated, occurredAt: "2026-04-24T10:00:00Z"))

        let recent = try await repository.fetchRecent(limit: 2)

        XCTAssertEqual(recent.map(\.id), ["event-b", "event-a"])
    }

    func testSwiftDataCommandExecutionRepositoryAppendsAndFetchesRecent() async throws {
        let repository = try await makeCommandRepository()
        let command = AmbitionsCommand(
            id: "command-old",
            kind: .quickCapture,
            source: .today,
            target: AmbitionsCommandTarget(captureID: "capture-1"),
            payload: AmbitionsCommandPayload(rawText: "Write a note"),
            createdAt: "2026-04-25T12:00:00Z"
        )
        let older = AmbitionsCommandExecutionRecord(
            command: command,
            result: AmbitionsCommandExecutionResult(status: .succeeded, summary: "Created"),
            recordedAt: "2026-04-24T09:00:00Z"
        )
        let newer = AmbitionsCommandExecutionRecord(
            command: AmbitionsCommand(
                id: "command-new",
                kind: .quickCapture,
                source: .today,
                target: AmbitionsCommandTarget(captureID: "capture-2"),
                payload: AmbitionsCommandPayload(rawText: "Write a second note"),
                createdAt: "2026-04-25T12:00:00Z"
            ),
            result: AmbitionsCommandExecutionResult(status: .failed, summary: "Ignored"),
            recordedAt: "2026-04-24T10:00:00Z"
        )

        try await repository.append(older)
        try await repository.append(newer)

        let recent = try await repository.fetchRecent(limit: 2)
        let fetched = try await repository.fetchRecord(commandID: "command-old")

        XCTAssertEqual(recent.map(\.command.id), ["command-new", "command-old"])
        XCTAssertEqual(recent.map(\.result.status), [.failed, .succeeded])
        XCTAssertEqual(recent.map(\.recordedAt), ["2026-04-24T10:00:00Z", "2026-04-24T09:00:00Z"])
        XCTAssertEqual(fetched?.result.summary, "Created")
        XCTAssertEqual(fetched?.commandID, "command-old")
    }

    func testInMemoryCommandExecutionRepositoryPreservesFetchByCommandIDAndReplacesByCommandID() async throws {
        let repository = InMemoryAmbitionsCommandExecutionRecordRepository()
        let command = AmbitionsCommand(
            id: "command-memory",
            kind: .routeCommitment,
            source: .capture,
            target: AmbitionsCommandTarget(captureID: "capture-2"),
            payload: AmbitionsCommandPayload(rawText: "Plan tomorrow"),
            executionStatus: .queued,
            createdAt: "2026-04-25T13:00:00Z"
        )
        try await repository.append(
            AmbitionsCommandExecutionRecord(
                command: command,
                result: AmbitionsCommandExecutionResult(status: .queued, summary: "Queued"),
                recordedAt: "2026-04-25T13:30:00Z"
            )
        )
        try await repository.append(
            AmbitionsCommandExecutionRecord(
                command: command,
                result: AmbitionsCommandExecutionResult(status: .succeeded, summary: "Replaced"),
                recordedAt: "2026-04-25T14:00:00Z"
            )
        )

        let fetched = try await repository.fetchRecord(commandID: "command-memory")
        let records = try await repository.fetchRecent(limit: 10)

        XCTAssertEqual(fetched?.command.id, "command-memory")
        XCTAssertEqual(records.count, 1)
        XCTAssertEqual(records.first?.result.summary, "Replaced")
    }
}

private extension EventLedgerRepositoryTests {
    func makeRepository() async throws -> SwiftDataEventLedgerRepository {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        return SwiftDataEventLedgerRepository(store: store)
    }

    func makeCommandRepository() async throws -> SwiftDataAmbitionsCommandExecutionRecordRepository {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        return SwiftDataAmbitionsCommandExecutionRecordRepository(store: store)
    }

    func event(
        id: String,
        kind: EventLedgerKind,
        occurredAt: String,
        goalID: String? = nil,
        captureID: String? = nil,
        title: String = "Ledger event",
        summary: String? = nil,
        payload: [String: String] = [:]
    ) -> EventLedgerEntry {
        EventLedgerEntry(
            id: id,
            kind: kind,
            occurredAt: occurredAt,
            source: .system,
            goalID: goalID,
            captureID: captureID,
            title: title,
            summary: summary,
            payload: payload
        )
    }

    static func legacyEventRecord(_ event: EventLedgerEntry) throws -> EventLedgerRecord {
        let record = EventLedgerRecord(
            id: event.id,
            kindRaw: event.kind.rawValue,
            occurredAt: event.occurredAt,
            sourceRaw: event.source.rawValue,
            goalID: event.goalID,
            captureID: event.captureID,
            planID: event.planID,
            planScope: event.planScope,
            reviewID: event.reviewID,
            title: event.title,
            summaryText: event.summary,
            semanticState: event.semanticState,
            toneRaw: event.tone.rawValue,
            schemaVersion: event.schemaVersion,
            privacyRaw: event.privacy.rawValue,
            localOnly: event.localOnly,
            createdAt: event.createdAt,
            updatedAt: event.updatedAt,
            evidenceReferencesData: try PersistenceCoding.encode(event.evidenceReferences),
            metadataData: try PersistenceCoding.encode(event.metadata),
            payloadData: try PersistenceCoding.encode(event.payload),
            trustData: try PersistenceCoding.encode(event.trust),
            snapshotData: try PersistenceCoding.encode(event)
        )
        record.occurredAtDate = nil
        record.createdAtDate = nil
        record.updatedAtDate = nil
        return record
    }
}
