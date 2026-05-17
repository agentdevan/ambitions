import XCTest
@testable import Ambitions

final class SideEffectLedgerRepositoryTests: XCTestCase {
    func testSwiftDataRepositoryAppendsAndFetchesRecentNewestFirst() async throws {
        let repository = try await makeRepository()
        let older = sideEffect(
            id: "sideeffect-older",
            effectKind: .localOnly,
            status: .recordedLocalOnly,
            actionKind: .archiveItem,
            occurredAt: "2026-06-01T10:00:00Z",
            sourceDomain: .capture
        )
        let newer = sideEffect(
            id: "sideeffect-newer",
            effectKind: .calendar,
            status: .confirmationRequired,
            actionKind: .writeCalendarBlock,
            occurredAt: "2026-06-01T10:10:00Z",
            sourceDomain: .time
        )

        try await repository.append(older)
        try await repository.append(newer)

        let recent = try await repository.fetchRecent(limit: 2)

        XCTAssertEqual(recent.map(\.id), ["sideeffect-newer", "sideeffect-older"])
    }

    func testSwiftDataRepositoryFiltersByStatusAndFetchesByID() async throws {
        let repository = try await makeRepository()
        try await repository.append(sideEffect(id: "local", effectKind: .localOnly, status: .recordedLocalOnly, actionKind: .archiveItem, occurredAt: "2026-06-01T10:00:00Z", sourceDomain: .capture))
        try await repository.append(sideEffect(id: "blocked", effectKind: .calendar, status: .confirmationRequired, actionKind: .writeCalendarBlock, occurredAt: "2026-06-01T10:05:00Z", sourceDomain: .time))
        try await repository.append(sideEffect(id: "failed", effectKind: .sync, status: .failedSafely, actionKind: .applySyncResolution, occurredAt: "2026-06-01T10:10:00Z", sourceDomain: .you))

        let confirmationRequired = try await repository.fetchRecords(status: .confirmationRequired)
        let recovered = try await repository.fetchRecord(id: "failed")

        XCTAssertEqual(confirmationRequired.map(\.id), ["blocked"])
        XCTAssertEqual(recovered?.status, .failedSafely)
    }

    func testSwiftDataRepositoryUpdatesExistingEntryByID() async throws {
        let repository = try await makeRepository()
        let original = sideEffect(
            id: "sideeffect-stable",
            effectKind: .localOnly,
            status: .recordedLocalOnly,
            actionKind: .archiveItem,
            occurredAt: "2026-06-01T10:00:00Z",
            sourceDomain: .capture
        )
        let replacement = sideEffect(
            id: "sideeffect-stable",
            effectKind: .calendar,
            status: .confirmationRequired,
            actionKind: .writeCalendarBlock,
            occurredAt: "2026-06-01T10:01:00Z",
            sourceDomain: .time
        )

        try await repository.append(original)
        try await repository.append(replacement)

        let recent = try await repository.fetchRecent(limit: 10)

        XCTAssertEqual(recent.count, 1)
        XCTAssertEqual(recent.first?.effectKind, .calendar)
        XCTAssertEqual(recent.first?.status, .confirmationRequired)
    }

    func testInMemoryRepositoryUsesDeterministicOrderingForSameTimestamp() async throws {
        let repository = InMemorySideEffectLedgerRepository()

        try await repository.append(sideEffect(id: "a", effectKind: .localOnly, status: .recordedLocalOnly, actionKind: .archiveItem, occurredAt: "2026-06-01T11:00:00Z", sourceDomain: .capture))
        try await repository.append(sideEffect(id: "b", effectKind: .calendar, status: .confirmationRequired, actionKind: .writeCalendarBlock, occurredAt: "2026-06-01T11:00:00Z", sourceDomain: .time))

        let recent = try await repository.fetchRecent(limit: 2)

        XCTAssertEqual(recent.map(\.id), ["a", "b"])
    }
}

private extension SideEffectLedgerRepositoryTests {
    func makeRepository() async throws -> SwiftDataSideEffectLedgerRepository {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        return SwiftDataSideEffectLedgerRepository(store: store)
    }

    func sideEffect(
        id: String,
        effectKind: SideEffectLedgerEffectKind,
        status: SideEffectLedgerStatus,
        actionKind: SafeAutomationActionKind,
        occurredAt: String,
        sourceDomain: ActionReceiptSourceDomain
    ) -> SideEffectLedgerRecord {
        SideEffectLedgerRecord(
            id: id,
            effectKind: effectKind,
            status: status,
            boundary: status == .confirmationRequired ? .externalEffect : .localOnly,
            actionKind: actionKind,
            sourceDomain: sourceDomain,
            commandID: "command-\(id)",
            targetObjects: [LifeGraphObjectReference(kind: .action, id: "target-\(id)", sourceDomain: sourceDomain.lifeGraphSourceDomain)],
            occurredAt: occurredAt,
            requiresConfirmation: status == .confirmationRequired,
            externalEffect: status == .confirmationRequired,
            reasons: status == .confirmationRequired ? [.externalSideEffect] : [],
            receiptID: "receipt-\(id)"
        )
    }
}
