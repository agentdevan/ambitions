import XCTest
@testable import Ambitions

final class TrustHistoryQueryRepositoryTests: XCTestCase {
    func testSwiftDataTrustHistoryQueryFiltersReceiptsAndEventsWithDeterministicOrdering() async throws {
        let store = try await makeStore()
        let repository = SwiftDataTrustHistoryQueryRepository(store: store)
        let eventRepository = SwiftDataEventLedgerRepository(store: store)
        let receiptRepository = SwiftDataActionReceiptHistoryRepository(store: store)

        let goal = object(.goal, "goal-1", label: "Plan goal")
        let actionReceipt = ActionReceiptHistoryRecord(
            receipt: receipt(
                id: "receipt-1",
                resultState: .completed,
                title: "Plan receipt",
                occurredAt: "2026-04-26T12:00:00Z",
                affectedObjects: [goal],
                changedFacts: [
                    ActionReceiptChangedFact(
                        id: "fact-1",
                        kind: .completedTask,
                        object: goal,
                        summary: "Plan completion"
                    )
                ],
                sourceDomain: .time
            ),
            privacyLevel: .safeToShow,
            proofRelevance: .countsAsProof,
            requiresConfirmationBeforeBroaderUse: false
        )
        let excludedReceipt = ActionReceiptHistoryRecord(
            receipt: receipt(
                id: "receipt-2",
                resultState: .changed,
                title: "Capture receipt",
                occurredAt: "2026-04-26T11:00:00Z",
                affectedObjects: [goal],
                changedFacts: [
                    ActionReceiptChangedFact(
                        id: "fact-2",
                        kind: .changedField,
                        object: goal,
                        summary: "Capture update"
                    )
                ],
                sourceDomain: .capture
            ),
            privacyLevel: .sensitive,
            proofRelevance: .notProof,
            requiresConfirmationBeforeBroaderUse: true
        )
        try await receiptRepository.save([actionReceipt, excludedReceipt])

        try await eventRepository.append(
            EventLedgerEntry(
                id: "event-1",
                kind: .captureCreated,
                occurredAt: "2026-04-26T12:00:00Z",
                source: .capture,
                title: "Capture created",
                summary: "Capture event summary",
                trust: EventLedgerTrustMetadata(isUserConfirmed: false, requiresReview: true),
                evidenceReferences: [
                    EventLedgerEvidenceReference(id: "e-1", kind: .capture)
                ],
                metadata: ["source": "capture"],
                privacy: .privateUserText
            )
        )
        try await eventRepository.append(
            EventLedgerEntry(
                id: "event-2",
                kind: .goalUpdated,
                occurredAt: "2026-04-25T12:00:00Z",
                source: .goals,
                title: "Goal updated",
                summary: "Filtered out",
                trust: EventLedgerTrustMetadata(isUserConfirmed: true, requiresReview: false),
                metadata: ["source": "goals"],
                privacy: .standard
            )
        )

        let projection = try await repository.fetch(
            TrustHistoryQuery(
                receiptSourceDomains: [.time],
                receiptPrivacyLevels: [.safeToShow],
                receiptProofRelevance: [.countsAsProof],
                eventSources: [.capture],
                eventPrivacyLevels: [.privateUserText],
                requiresReview: true,
                userConfirmed: false,
                proofReferenceKinds: [.capture],
                includeReceiptHistory: true,
                includeEventLedger: true
            )
        )

        XCTAssertEqual(projection.totalMatchCount, 2)
        XCTAssertEqual(projection.results.map(\.id), ["receipt.receipt-1", "event.event-1"])
        XCTAssertEqual(projection.results.first?.kind, .actionReceipt)
        XCTAssertEqual(projection.results.first?.requiresReview, nil)
        XCTAssertEqual(projection.results.first?.proofReferenceKinds, [])
        XCTAssertEqual(projection.results.first?.trustStatus, .safeToShow)
        XCTAssertEqual(projection.results.first?.proofFreshnessLineage?.proofReferenceIDs, ["proof.receipt-1"])
        XCTAssertEqual(projection.results.last?.kind, .eventLedger)
        XCTAssertEqual(projection.results.last?.requiresReview, true)
        XCTAssertEqual(projection.results.last?.proofReferenceKinds, [.capture])
        XCTAssertEqual(projection.results.last?.proofRelevance, nil)
    }

    func testSwiftDataTrustHistoryQueryCanTargetOnlyReceiptsOrOnlyEvents() async throws {
        let store = try await makeStore()
        let repository = SwiftDataTrustHistoryQueryRepository(store: store)
        let eventRepository = SwiftDataEventLedgerRepository(store: store)
        let receiptRepository = SwiftDataActionReceiptHistoryRepository(store: store)

        let goal = object(.goal, "goal-2", label: "Only receipts")
        try await receiptRepository.save([
            ActionReceiptHistoryRecord(
                receipt: receipt(
                    id: "receipt-only",
                    resultState: .completed,
                    title: "Only receipt",
                    affectedObjects: [goal],
                    changedFacts: [
                        ActionReceiptChangedFact(
                            id: "fact-only",
                            kind: .completedTask,
                            object: goal,
                            summary: "Completed"
                        )
                    ],
                    sourceDomain: .time
                )
            )
        ])

        try await eventRepository.append(
            EventLedgerEntry(
                id: "event-only",
                kind: .goalCreated,
                occurredAt: "2026-04-26T12:00:00Z",
                source: .goals,
                title: "Only event",
                trust: EventLedgerTrustMetadata(isUserConfirmed: true, requiresReview: true),
                evidenceReferences: [
                    EventLedgerEvidenceReference(id: "e-2", kind: .goal)
                ],
                metadata: ["source": "goals"],
                privacy: .standard
            )
        )

        let onlyReceipt = try await repository.fetch(
            TrustHistoryQuery(
                receiptTrustStatuses: [.safeToShow],
                includeReceiptHistory: true,
                includeEventLedger: false
            )
        )
        XCTAssertEqual(onlyReceipt.totalMatchCount, 1)
        XCTAssertEqual(onlyReceipt.results.map { $0.kind }, [TrustHistoryQueryItemKind.actionReceipt])

        let onlyEvents = try await repository.fetch(
            TrustHistoryQuery(
                requiresReview: true,
                proofReferenceKinds: [.goal],
                includeReceiptHistory: false,
                includeEventLedger: true
            )
        )
        XCTAssertEqual(onlyEvents.totalMatchCount, 1)
        XCTAssertEqual(onlyEvents.results.map { $0.id }, ["event.event-only"])
    }

    func testSwiftDataTrustHistoryQueryFiltersReceiptFreshnessReviewFlags() async throws {
        let store = try await makeStore()
        let repository = SwiftDataTrustHistoryQueryRepository(store: store)
        let receiptRepository = SwiftDataActionReceiptHistoryRepository(store: store)

        let goal = object(.goal, "goal-freshness", label: "Freshness goal")
        try await receiptRepository.save([
            ActionReceiptHistoryRecord(
                receipt: receipt(
                    id: "receipt-freshness-required",
                    resultState: .changed,
                    title: "Freshness required",
                    affectedObjects: [goal],
                    changedFacts: [],
                    sourceDomain: .capture
                ),
                privacyLevel: .safeToShow,
                localOnly: true
            ),
            ActionReceiptHistoryRecord(
                receipt: receipt(
                    id: "receipt-freshness-clear",
                    resultState: .completed,
                    title: "Freshness clear",
                    affectedObjects: [goal],
                    changedFacts: [
                        ActionReceiptChangedFact(
                            id: "fact-freshness-clear",
                            kind: .completedTask,
                            object: goal,
                            summary: "Completed."
                        )
                    ],
                    sourceDomain: .time
                ),
                privacyLevel: .safeToShow,
                localOnly: true
            )
        ])

        let filtered = try await repository.fetch(
            TrustHistoryQuery(
                receiptRequiresFreshnessReview: true,
                includeReceiptHistory: true,
                includeEventLedger: false
            )
        )

        XCTAssertEqual(filtered.totalMatchCount, 1)
        XCTAssertEqual(filtered.results.map { $0.id }, ["receipt.receipt-freshness-required"])
        XCTAssertEqual(filtered.results.first?.proofFreshnessLineage?.sourceFreshnessLabel, "Source freshness needs detail")
    }

    func testSwiftDataTrustHistoryQueryFiltersEventProofReferencePresence() async throws {
        let store = try await makeStore()
        let repository = SwiftDataTrustHistoryQueryRepository(store: store)
        let eventRepository = SwiftDataEventLedgerRepository(store: store)

        try await eventRepository.append(
            EventLedgerEntry(
                id: "event-with-proof",
                kind: .goalUpdated,
                occurredAt: "2026-04-26T12:00:00Z",
                source: .goals,
                title: "Event with proof",
                evidenceReferences: [
                    EventLedgerEvidenceReference(id: "proof-1", kind: .goal)
                ],
                metadata: ["source": "goals"],
                privacy: .standard
            )
        )
        try await eventRepository.append(
            EventLedgerEntry(
                id: "event-without-proof",
                kind: .goalUpdated,
                occurredAt: "2026-04-26T11:00:00Z",
                source: .goals,
                title: "Event without proof",
                metadata: ["source": "goals"],
                privacy: .standard
            )
        )

        let requiringProof = try await repository.fetch(
            TrustHistoryQuery(
                requiresProofReferences: true,
                includeReceiptHistory: false,
                includeEventLedger: true
            )
        )
        XCTAssertEqual(requiringProof.results.map(\.id), ["event.event-with-proof"])

        let requiringNoProof = try await repository.fetch(
            TrustHistoryQuery(
                requiresProofReferences: false,
                includeReceiptHistory: false,
                includeEventLedger: true
            )
        )
        XCTAssertEqual(requiringNoProof.results.map(\.id), ["event.event-without-proof"])
    }

    private func makeStore() async throws -> AmbitionsPersistenceStore {
        try AmbitionsPersistenceStore(inMemory: true)
    }

    private func object(
        _ kind: LifeGraphObjectKind,
        _ id: String,
        label: String,
        sourceDomain: LifeGraphSourceDomain? = nil
    ) -> LifeGraphObjectReference {
        LifeGraphObjectReference(kind: kind, id: id, label: label, sourceDomain: sourceDomain)
    }

    private func receipt(
        id: String,
        resultState: ActionReceiptResultState,
        title: String,
        occurredAt: String = "2026-04-26T12:00:00Z",
        affectedObjects: [LifeGraphObjectReference],
        changedFacts: [ActionReceiptChangedFact] = [],
        sourceDomain: ActionReceiptSourceDomain = .system
    ) -> ActionReceipt {
        ActionReceipt(
            id: id,
            resultState: resultState,
            title: title,
            summary: "\(title) summary.",
            sourceDomain: sourceDomain,
            occurredAt: occurredAt,
            affectedObjects: affectedObjects,
            changedFacts: changedFacts,
            correctionAvailability: .unavailable,
            undoAvailability: .availableLocal
        )
    }
}
