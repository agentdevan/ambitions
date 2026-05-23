import XCTest
@testable import Ambitions

final class ActionReceiptHistoryRepositoryTests: XCTestCase {
    func testSwiftDataReceiptHistoryRepositorySavesAndQueriesByFilters() async throws {
        let repository = try await makeRepository()
        let goal = object(.goal, "goal-1", label: "Launch app")
        let planItem = object(.action, "plan-item-1", label: "Draft announcement", sourceDomain: .time)
        let capture = object(.capture, "capture-1", label: "Launch checklist", sourceDomain: .capture)

        let completed = ActionReceiptHistoryRecord(
            receipt: receipt(
                id: "receipt-completed",
                resultState: .completed,
                title: "Launch task completed",
                occurredAt: "2026-04-26T12:00:00Z",
                affectedObjects: [goal, planItem],
                changedFacts: [
                    ActionReceiptChangedFact(
                        id: "fact-completed",
                        kind: .completedTask,
                        object: planItem,
                        summary: "Task completed."
                    )
                ],
                sourceDomain: .time
            ),
            privacyLevel: .safeToShow,
            localOnly: true
        )
        let changed = ActionReceiptHistoryRecord(
            receipt: receipt(
                id: "receipt-changed",
                resultState: .changed,
                title: "Capture updated",
                occurredAt: "2026-04-26T10:00:00Z",
                affectedObjects: [goal, capture],
                changedFacts: [
                    ActionReceiptChangedFact(
                        id: "fact-changed",
                        kind: .changedField,
                        object: goal,
                        summary: "Title updated."
                    )
                ],
                sourceDomain: .capture
            )
        )

        try await repository.save([changed, completed])

        let query = ActionReceiptSearchQuery(
            startDate: "2026-04-26T11:00:00Z",
            actionKinds: [.completedTask],
            resultStates: [.completed],
            relatedGoalID: "goal-1",
            sourceDomains: [.time],
            limit: 10,
            projectionDetail: .fullDetail
        )
        let projection = try await repository.fetch(query)

        XCTAssertEqual(projection.totalMatchCount, 1)
        XCTAssertEqual(projection.results.map { $0.receiptID }, ["receipt-completed"])
        XCTAssertEqual(projection.results.first?.resultState, .completed)
        XCTAssertEqual(projection.results.first?.trustStatus, .safeToShow)
        XCTAssertEqual(projection.results.first?.proofFreshnessLineage.proofReferenceIDs, ["proof.receipt-completed"])
        XCTAssertEqual(Set(projection.results.first?.proofFreshnessLineage.lineageObjectIDs ?? []), ["goal-1", "plan-item-1"])
        XCTAssertFalse(projection.results.first?.proofFreshnessLineage.requiresFreshnessReview ?? true)
    }

    func testSwiftDataReceiptHistoryRepositoryReplacesExistingRecordsByIDAndSortsDeterministically() async throws {
        let repository = try await makeRepository()
        let goal = object(.goal, "goal-sort", label: "Sort goal")

        let earlier = ActionReceiptHistoryRecord(
            receipt: receipt(
                id: "receipt-sorted",
                resultState: .changed,
                title: "B Title",
                occurredAt: "2026-04-26T12:00:00Z",
                affectedObjects: [goal],
                changedFacts: [
                    ActionReceiptChangedFact(id: "fact-sort", kind: .changedField, object: goal, summary: "Order test.")
                ]
            )
        )
        let later = ActionReceiptHistoryRecord(
            receipt: receipt(
                id: "receipt-sorted",
                resultState: .changed,
                title: "A Title",
                occurredAt: "2026-04-26T12:00:00Z",
                affectedObjects: [goal],
                changedFacts: [
                    ActionReceiptChangedFact(id: "fact-sort", kind: .changedField, object: goal, summary: "Order test.")
                ]
            )
        )
        let anchor = ActionReceiptHistoryRecord(
            receipt: receipt(
                id: "receipt-anchor",
                resultState: .created,
                title: "Anchor Receipt",
                occurredAt: "2026-04-26T11:30:00Z",
                affectedObjects: [goal],
                changedFacts: []
            )
        )

        try await repository.save([earlier, anchor])
        try await repository.save([later])

        let projection = try await repository.fetch(
            ActionReceiptSearchQuery(
                limit: 10,
                projectionDetail: .fullDetail
            )
        )

        XCTAssertEqual(projection.totalMatchCount, 2)
        XCTAssertEqual(projection.results.map(\.receiptID), ["receipt-sorted", "receipt-anchor"])
        XCTAssertEqual(projection.results.first?.title, "A Title")
        XCTAssertFalse(projection.results.first?.proofFreshnessLineage.publicClaimAllowed ?? true)
    }

    func testSwiftDataReceiptHistoryRepositoryPreservesRedactionAndLocalOnlyMetadata() async throws {
        let repository = try await makeRepository()
        let goal = object(.goal, "goal-private", label: "Secure goal")
        let safeGoal = object(.goal, "goal-safe", label: "Safe goal")

        let privateReceipt = ActionReceiptHistoryRecord(
            receipt: receipt(
                id: "receipt-private",
                resultState: .changed,
                title: "Private change",
                affectedObjects: [goal],
                changedFacts: [
                    ActionReceiptChangedFact(
                        id: "fact-private",
                        kind: .changedField,
                        object: goal,
                        fieldName: "title",
                        previousValueSummary: "Old",
                        newValueSummary: "New",
                        summary: "Private goal title changed."
                    )
                ]
            ),
            privacyLevel: .sensitive,
            localOnly: true
        )
        let safeReceipt = ActionReceiptHistoryRecord(
            receipt: receipt(
                id: "receipt-safe",
                resultState: .attached,
                title: "Safe capture",
                affectedObjects: [safeGoal],
                sourceDomain: .capture
            )
        )

        try await repository.save([privateReceipt, safeReceipt])

        let projection = try await repository.fetch(
            ActionReceiptSearchQuery(
                searchText: "private",
                limit: 10,
                projectionDetail: .redacted
            )
        )

        XCTAssertEqual(projection.results.count, 1)
        guard let result = projection.results.first else {
            return XCTFail("Expected one redacted private result.")
        }
        XCTAssertEqual(result.receiptID, "receipt-private")
        XCTAssertEqual(result.title, "Private item")
        XCTAssertEqual(result.summary, "Private item")
        XCTAssertEqual(result.privacyLevel, .redacted)
        XCTAssertFalse(result.safeToShowInExternalSurface)
        XCTAssertTrue(result.localOnly)
        XCTAssertEqual(result.proofFreshnessLineage.sourceFreshnessLabel, "Source freshness private")
        XCTAssertEqual(result.proofFreshnessLineage.privacyReceiptLabel, "Privacy receipt hides private detail")
        XCTAssertEqual(result.proofFreshnessLineage.lineageObjectIDs, ["goal-private"])
        XCTAssertFalse(result.proofFreshnessLineage.publicClaimAllowed)
    }

    func testSwiftDataReceiptHistoryRepositoryFiltersBySourceDomainAndProofRelevanceWithLimit() async throws {
        let repository = try await makeRepository()
        let goal = object(.goal, "goal-filter", label: "Filter goal")

        try await repository.save([
            ActionReceiptHistoryRecord(
                receipt: receipt(
                    id: "receipt-capture",
                    resultState: .changed,
                    title: "Capture entry",
                    affectedObjects: [goal],
                    changedFacts: [
                        ActionReceiptChangedFact(
                            id: "capture-field",
                            kind: .changedField,
                            object: goal,
                            summary: "Capture touched."
                        )
                    ],
                    sourceDomain: .capture
                ),
                proofRelevance: .notProof
            ),
            ActionReceiptHistoryRecord(
                receipt: receipt(
                    id: "receipt-plan-proof",
                    resultState: .completed,
                    title: "Plan proof",
                    occurredAt: "2026-04-27T09:00:00Z",
                    affectedObjects: [goal],
                    changedFacts: [
                        ActionReceiptChangedFact(
                            id: "proof-field",
                            kind: .completedTask,
                            object: goal,
                            summary: "Task completed."
                        )
                    ],
                    sourceDomain: .time
                ),
                proofRelevance: .countsAsProof
            )
        ])

        let projection = try await repository.fetch(
            ActionReceiptSearchQuery(
                startDate: "2026-04-27T08:00:00Z",
                endDate: "2026-04-27T10:00:00Z",
                sourceDomains: [.time],
                proofRelevance: [.countsAsProof],
                limit: 1,
                projectionDetail: .fullDetail
            )
        )

        XCTAssertEqual(projection.totalMatchCount, 1)
        XCTAssertEqual(projection.results.map(\.receiptID), ["receipt-plan-proof"])
        XCTAssertEqual(projection.results.first?.proofRelevance, .countsAsProof)
        XCTAssertEqual(projection.results.first?.proofFreshnessLineage.proofReferenceIDs, ["proof.receipt-plan-proof"])
    }

    func testSwiftDataReceiptHistoryRepositoryFiltersByFreshnessReviewFlag() async throws {
        let repository = try await makeRepository()
        let goal = object(.goal, "goal-review", label: "Review goal")

        try await repository.save([
            ActionReceiptHistoryRecord(
                receipt: receipt(
                    id: "receipt-review-required",
                    resultState: .changed,
                    title: "Needs review",
                    affectedObjects: [goal],
                    changedFacts: [],
                    sourceDomain: .capture
                ),
                privacyLevel: .safeToShow,
                localOnly: true
            ),
            ActionReceiptHistoryRecord(
                receipt: receipt(
                    id: "receipt-review-clear",
                    resultState: .completed,
                    title: "Review clear",
                    affectedObjects: [goal],
                    changedFacts: [
                        ActionReceiptChangedFact(
                            id: "fact-review-clear",
                            kind: .completedTask,
                            object: goal,
                            summary: "Task completed."
                        )
                    ],
                    sourceDomain: .time
                ),
                privacyLevel: .safeToShow,
                localOnly: true
            )
        ])

        let projection = try await repository.fetch(
            ActionReceiptSearchQuery(
                requiresFreshnessReview: true,
                limit: 10,
                projectionDetail: .fullDetail
            )
        )

        XCTAssertEqual(projection.totalMatchCount, 1)
        XCTAssertEqual(projection.results.map(\.receiptID), ["receipt-review-required"])
        XCTAssertTrue(projection.results.first?.proofFreshnessLineage.requiresFreshnessReview ?? false)
    }

    func testSwiftDataReceiptHistoryRepositoryListsInsertedRecords() async throws {
        let repository = try await makeRepository()
        let receipt = ActionReceipt.candidateRejectionReceipt(
            id: "receipt-rejection",
            candidateID: "candidate-1",
            sourceStepID: "step-1",
            sourceCandidateID: "candidate-source-1",
            reason: StepCandidateRejectionReason(code: .tooLong),
            contextFingerprint: "fingerprint-1",
            recordedAt: "2026-05-01T12:00:00Z",
            skippedReason: true
        )
        let record = ActionReceiptHistoryRecord(
            receipt: receipt,
            privacyLevel: .safeToShow,
            localOnly: true
        )

        try await repository.save([record])

        let listed = try await repository.listRecords()
        XCTAssertEqual(listed.count, 1)
        XCTAssertEqual(listed.first?.id, record.id)
        XCTAssertEqual(listed.first?.receipt.id, receipt.id)
        XCTAssertEqual(listed.first?.receipt.sourceDomain, .today)
        XCTAssertEqual(listed.first?.privacyLevel, .safeToShow)
        XCTAssertTrue(listed.first?.receipt.changedFacts.contains(where: { $0.fieldName == "contextFingerprint" }) ?? false)
        XCTAssertTrue(listed.first?.receipt.changedFacts.contains(where: { $0.fieldName == "skippedReason" }) ?? false)
    }

    private func makeRepository() async throws -> SwiftDataActionReceiptHistoryRepository {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        return SwiftDataActionReceiptHistoryRepository(store: store)
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
