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
}

private extension EventLedgerRepositoryTests {
    func makeRepository() async throws -> SwiftDataEventLedgerRepository {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        return SwiftDataEventLedgerRepository(store: store)
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
}
