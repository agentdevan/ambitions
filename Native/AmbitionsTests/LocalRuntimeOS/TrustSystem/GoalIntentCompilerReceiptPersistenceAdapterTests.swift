import XCTest
@testable import Ambitions

final class GoalIntentCompilerReceiptPersistenceAdapterTests: XCTestCase {
    func testAdapterSavesClearCompilerReceiptWithGoalAndStepFacts() async throws {
        let repository = try await makeRepository()
        let adapter = GoalIntentCompilerReceiptPersistenceAdapter(actionReceiptHistoryRepository: repository)
        let output = makeClearOutput(
            receiptID: "compiler-receipt-clear",
            compiledStepID: "compiled-step-clear",
            stepTitle: "Draft launch announcement",
            summary: "Compiled daily step candidate Draft launch announcement.",
            reason: "Deterministic local-first compilation."
        )

        try await adapter.save(output)

        let projection = try await repository.fetch(
            ActionReceiptSearchQuery(
                sourceDomains: [.goals],
                limit: 10,
                projectionDetail: .fullDetail
            )
        )

        XCTAssertEqual(projection.totalMatchCount, 1)
        let result = try XCTUnwrap(projection.results.first)
        XCTAssertEqual(result.receiptID, "compiler-receipt-clear")
        XCTAssertEqual(result.resultState, .completed)
        XCTAssertEqual(result.title, "Compiled daily step candidate Draft launch announcement.")
        XCTAssertEqual(result.summary, "Deterministic local-first compilation.")
        XCTAssertEqual(result.proofRelevance, .notProof)
        XCTAssertEqual(result.trustStatus, .safeToShow)
        XCTAssertFalse(result.proofFreshnessLineage.requiresFreshnessReview)
        XCTAssertEqual(result.proofFreshnessLineage.sourceFreshnessLabel, "Source freshness current local receipt")
        XCTAssertEqual(Set(result.proofFreshnessLineage.lineageObjectIDs), ["clear-goal-intent", "compiled-step-clear"])
        XCTAssertEqual(result.changedFactSummaries, [
            "Compiled from goals input.",
            "Compiled daily step candidate Draft launch announcement."
        ])
    }

    func testAdapterReplacesCompilerReceiptWhenTheSameIDIsSavedAgain() async throws {
        let repository = try await makeRepository()
        let adapter = GoalIntentCompilerReceiptPersistenceAdapter(actionReceiptHistoryRepository: repository)
        let originalOutput = makeClearOutput(
            receiptID: "compiler-receipt-replace",
            compiledStepID: "compiled-step-replace",
            stepTitle: "Draft launch announcement",
            summary: "Compiled daily step candidate Draft launch announcement.",
            reason: "Deterministic local-first compilation."
        )
        let updatedOutput = makeClearOutput(
            receiptID: "compiler-receipt-replace",
            compiledStepID: "compiled-step-replace",
            stepTitle: "Draft launch announcement",
            summary: "Compiled daily step candidate Draft launch announcement v2.",
            reason: "Deterministic local-first compilation after refinement."
        )

        try await adapter.save(originalOutput)
        try await adapter.save(updatedOutput)

        let projection = try await repository.fetch(
            ActionReceiptSearchQuery(
                sourceDomains: [.goals],
                limit: 10,
                projectionDetail: .fullDetail
            )
        )

        XCTAssertEqual(projection.totalMatchCount, 1)
        let result = try XCTUnwrap(projection.results.first)
        XCTAssertEqual(result.receiptID, "compiler-receipt-replace")
        XCTAssertEqual(result.title, "Compiled daily step candidate Draft launch announcement v2.")
        XCTAssertEqual(result.summary, "Deterministic local-first compilation after refinement.")
        XCTAssertEqual(result.changedFactSummaries.last, "Compiled daily step candidate Draft launch announcement v2.")
    }

    func testAdapterForcesCompilerReceiptHistoryToStayLocalOnly() async throws {
        let repository = try await makeRepository()
        let adapter = GoalIntentCompilerReceiptPersistenceAdapter(actionReceiptHistoryRepository: repository)
        let output = makeClearOutput(
            receiptID: "compiler-receipt-local-only",
            compiledStepID: "compiled-step-local-only",
            stepTitle: "Draft local-only receipt",
            summary: "Compiled daily step candidate Draft local-only receipt.",
            reason: "Deterministic local-first compilation.",
            localOnly: false
        )

        try await adapter.save(output)

        let projection = try await repository.fetch(
            ActionReceiptSearchQuery(
                sourceDomains: [.goals],
                limit: 10,
                projectionDetail: .fullDetail
            )
        )

        let result = try XCTUnwrap(projection.results.first)
        XCTAssertTrue(result.localOnly)
        XCTAssertTrue(result.safeToShowInExternalSurface)
        XCTAssertEqual(result.proofFreshnessLineage.privacyReceiptLabel, "Privacy receipt stored on this device")
    }

    func testAdapterPersistsBlockedCompilerReceiptWithFreshnessReviewMetadata() async throws {
        let repository = try await makeRepository()
        let adapter = GoalIntentCompilerReceiptPersistenceAdapter(actionReceiptHistoryRepository: repository)
        let output = makeBlockedOutput(
            receiptID: "compiler-receipt-blocked",
            blockedReasonID: "block-success-definition",
            blockedReasonSummary: "Clarify what success looks like.",
            summary: "No executable daily step was emitted.",
            reason: "Clarify what success looks like. Capacity context: Open window available."
        )

        try await adapter.save(output)

        let projection = try await repository.fetch(
            ActionReceiptSearchQuery(
                sourceDomains: [.goals],
                limit: 10,
                projectionDetail: .fullDetail
            )
        )

        XCTAssertEqual(projection.totalMatchCount, 1)
        let result = try XCTUnwrap(projection.results.first)
        XCTAssertEqual(result.receiptID, "compiler-receipt-blocked")
        XCTAssertEqual(result.resultState, .needsConfirmation)
        XCTAssertEqual(result.proofRelevance, .needsConfirmation)
        XCTAssertEqual(result.trustStatus, .confirmationRequired)
        XCTAssertTrue(result.proofFreshnessLineage.requiresFreshnessReview)
        XCTAssertEqual(result.proofFreshnessLineage.sourceFreshnessLabel, "Source freshness needs review")
        XCTAssertEqual(result.changedFactSummaries, [
            "Compiled from goals input.",
            "Clarify what success looks like."
        ])
        XCTAssertEqual(result.proofFreshnessLineage.lineageObjectIDs, ["blocked-goal-intent"])
    }

    private func makeRepository() async throws -> SwiftDataActionReceiptHistoryRepository {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        return SwiftDataActionReceiptHistoryRepository(store: store)
    }

    private func makeIntent(
        id: String,
        rawStatement: String,
        sourceSurface: GoalIntentSourceSurface
    ) -> GoalIntent {
        GoalIntent(
            id: id,
            rawStatement: rawStatement,
            createdAt: "2026-05-22T18:13:20Z",
            sourceSurface: sourceSurface,
            privacyClass: .localOnly,
            sourceState: .draft
        )
    }

    private func makeClearOutput(
        receiptID: String,
        compiledStepID: String,
        stepTitle: String,
        summary: String,
        reason: String,
        localOnly: Bool = true
    ) -> GoalIntentDayCompilerOutput {
        let intent = makeIntent(
            id: "clear-goal-intent",
            rawStatement: "Launch the announcement",
            sourceSurface: .goals
        )
        let compiledStep = CompiledStep(
            id: compiledStepID,
            intentID: intent.id,
            title: stepTitle,
            summary: "Prepare the launch announcement.",
            orderIndex: 0
        )

        return GoalIntentDayCompilerOutput(
            intent: intent,
            compiledAt: "2026-05-22T18:13:20Z",
            status: .clear,
            assumptions: [],
            clarification: GoalIntentClarification(
                status: .clear,
                readiness: .readyForPlanning,
                questions: [],
                missingFields: []
            ),
            blockedReasons: [],
            capacityEnvelope: nil,
            compiledSteps: [compiledStep],
            receipts: [
                CompiledStepReceipt(
                    id: receiptID,
                    compiledStepID: compiledStep.id,
                    intentID: intent.id,
                    generatedAt: "2026-05-22T18:13:20Z",
                    status: .clear,
                    summary: summary,
                    reason: reason,
                    sourceSurface: .goals,
                    assumptionIDs: [],
                    clarificationQuestionIDs: [],
                    blockedReasonIDs: [],
                    localOnly: localOnly
                )
            ],
            localOnly: localOnly
        )
    }

    private func makeBlockedOutput(
        receiptID: String,
        blockedReasonID: String,
        blockedReasonSummary: String,
        summary: String,
        reason: String
    ) -> GoalIntentDayCompilerOutput {
        let intent = makeIntent(
            id: "blocked-goal-intent",
            rawStatement: "Plan a blocked follow-up",
            sourceSurface: .goals
        )
        let blockedReason = GoalIntentBlockedReason(
            id: blockedReasonID,
            kind: .clarificationNeeded,
            summary: blockedReasonSummary,
            field: .successDefinition
        )

        return GoalIntentDayCompilerOutput(
            intent: intent,
            compiledAt: "2026-05-22T18:13:20Z",
            status: .blocked,
            assumptions: [],
            clarification: GoalIntentClarification(
                status: .blocked,
                readiness: .needsClarification,
                questions: [],
                missingFields: [
                    GoalIntentMissingField(
                        id: "missing-success-definition",
                        field: .successDefinition,
                        reason: "Success needs a concrete definition before planning can continue.",
                        blocksCompilation: true
                    )
                ]
            ),
            blockedReasons: [blockedReason],
            capacityEnvelope: nil,
            compiledSteps: [],
            receipts: [
                CompiledStepReceipt(
                    id: receiptID,
                    compiledStepID: "blocked",
                    intentID: intent.id,
                    generatedAt: "2026-05-22T18:13:20Z",
                    status: .blocked,
                    summary: summary,
                    reason: reason,
                    sourceSurface: .goals,
                    assumptionIDs: [],
                    clarificationQuestionIDs: [],
                    blockedReasonIDs: [blockedReason.id],
                    localOnly: true
                )
            ],
            localOnly: true
        )
    }
}
