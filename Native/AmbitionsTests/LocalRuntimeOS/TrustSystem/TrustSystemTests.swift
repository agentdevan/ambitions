@testable import Ambitions
import XCTest

final class TrustSystemTests: XCTestCase {
    func testTrustSystemOwnerFilesExistAndOldOwnersAreRemoved() throws {
        let root = try repoRoot()
        let requiredPaths = [
            "Native/Ambitions/Core/LocalRuntimeOS/TrustSystem/EventLedgerModels.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/TrustSystem/EventLedgerModels+02-EventLedgerEntry.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/TrustSystem/ActionClosureReceiptModels.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/TrustSystem/ActionClosureReceiptModels+03-ActionReceiptHistoryRecord.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/TrustSystem/ActionReceiptProofLedgerModels.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/TrustSystem/ProofLedger.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/TrustSystem/SourceRecordLedger.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/TrustSystem/EntityRevisionTombstoneModels.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/TrustSystem/AuditTrail.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/TrustSystem/UndoLedger.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/TrustSystem/HistoryQueryEngine.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/TrustSystem/TrustSystem.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/TrustSystem/TrustSystemRepositoryContracts.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/TrustSystem/TrustSystemSwiftDataRepositories.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/TrustSystem/ExecutionLedgerReplayInspectionSwiftDataRepository.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/TrustSystem/GoalIntentCompilerReceiptPersistenceAdapter.swift",
        ]

        for path in requiredPaths {
            XCTAssertTrue(FileManager.default.fileExists(atPath: root.appendingPathComponent(path).path), path)
        }

        let retiredPaths = [
            "Native/Ambitions/Core/Domain/EventLedgerModels.swift",
            "Native/Ambitions/Core/Domain/ActionClosureReceiptModels.swift",
            "Native/Ambitions/Core/Domain/ActionReceiptProofLedgerModels.swift",
            "Native/Ambitions/Core/Domain/LedgerReplayModels.swift",
            "Native/Ambitions/Core/Domain/EntityRevisionTombstoneModels.swift",
            "Native/Ambitions/Core/Runtime/ProofLedger.swift",
            "Native/Ambitions/Core/Persistence/GoalIntentCompilerReceiptPersistenceAdapter.swift",
            "Native/Ambitions/Core/Persistence/SwiftDataRepositories+06-SwiftDataTrustHistoryQueryRepository.swift",
        ]

        for path in retiredPaths {
            XCTAssertFalse(FileManager.default.fileExists(atPath: root.appendingPathComponent(path).path), path)
        }
    }

    func testSanctionedRuntimeMutationProducesTrustLedgersReceiptsUndoAndHistory() async throws {
        let eventLedger = InMemoryEventLedgerRepository()
        let receiptHistory = InMemoryActionReceiptHistoryRepository()
        let recorder = TrustSystemRecorder(
            eventLedger: eventLedger,
            actionReceiptHistory: receiptHistory
        )
        let fixture = Self.sanctionedMutationFixture()

        let plan = try await recorder.record(
            TrustSystemCommitInput(
                commandRecord: fixture.commandRecord,
                runtimeEvent: fixture.runtimeEvent,
                receipt: fixture.receipt,
                proofRelevance: .countsAsProof,
                publicSourceAtlasReferences: [
                    TrustSystemPublicSourceAtlasReference(
                        packID: "source-atlas.public.life-calendar",
                        manifestID: "manifest.2026-06-30",
                        summary: "Public date calculation reference pack."
                    )
                ]
            ),
            recordedAt: "2026-06-30T12:01:00Z"
        )

        let storedEvents = try await eventLedger.fetchRecent(limit: 5)
        let storedReceipts = try await receiptHistory.listRecords()

        XCTAssertEqual(storedEvents.map(\.id), [plan.eventLedgerEntry.id])
        XCTAssertEqual(storedReceipts.map(\.id), ["receipt-trust-1"])
        XCTAssertTrue(plan.hasCompleteCommandEventProjectionReceiptReplayFlow)
        XCTAssertEqual(plan.proofLedgerEntry.proofReference?.id, "proof.receipt-trust-1")
        XCTAssertEqual(plan.undoLedger.entry(receiptID: "receipt-trust-1")?.canUndoLocally, true)
        XCTAssertEqual(plan.historyProjection.results.count, 2)
        XCTAssertEqual(plan.replayOutcome.decision, .replayExistingReceipt)
        XCTAssertTrue(plan.auditTrail.localOnly)
        XCTAssertTrue(plan.sourceRecordLedger.separationReport.isSeparated)
        XCTAssertEqual(plan.sourceRecordLedger.publicSourceAtlasRecords.map(\.id), [
            "source.public-source-atlas.source-atlas.public.life-calendar"
        ])
        XCTAssertTrue(plan.sourceRecordLedger.privateLifeGraphRecords.allSatisfy { $0.allowsNetworkRefresh == false })
        XCTAssertFalse(plan.sourceRecordLedger.publicSourceAtlasRecords.contains { $0.containsPrivateLifeGraph })
    }

    func testTrustSystemRejectsRuntimeEventThatDoesNotMatchCommandRecord() throws {
        let fixture = Self.sanctionedMutationFixture()
        let mismatchedEvent = RuntimeEvent(
            commandID: "command-other",
            actor: .user,
            source: .today,
            target: fixture.commandRecord.command.target,
            occurredAt: "2026-06-30T12:00:30Z",
            payload: .commandExecution(
                RuntimeCommandEventPayload(
                    phase: .executionRecorded,
                    commandKind: .completeAction,
                    validationState: .valid,
                    executionStatus: .succeeded,
                    resultStatus: .succeeded,
                    resultSummary: "Different command",
                    commandRecordID: "command.execution.command-other",
                    resultRoute: .today,
                    eventLedgerEntryIDs: [],
                    recommendationExplanationIDs: [],
                    resultMetadata: [:]
                )
            )
        )

        XCTAssertThrowsError(try TrustSystemCommitPlanner().plan(
            TrustSystemCommitInput(
                commandRecord: fixture.commandRecord,
                runtimeEvent: mismatchedEvent,
                receipt: fixture.receipt
            ),
            plannedAt: "2026-06-30T12:01:00Z"
        )) { error in
            XCTAssertEqual(
                error as? TrustSystemCommitError,
                .commandMismatch(expected: "command-trust-1", actual: "command-other")
            )
        }
    }

    private static func sanctionedMutationFixture() -> (
        commandRecord: AmbitionsCommandExecutionRecord,
        runtimeEvent: RuntimeEvent,
        receipt: ActionReceipt
    ) {
        let target = AmbitionsCommandTarget(
            goalID: "goal-trust-1",
            stepID: "step-trust-1",
            destination: .today
        )
        let command = AmbitionsCommand(
            id: "command-trust-1",
            kind: .completeAction,
            source: .today,
            target: target,
            createdAt: "2026-06-30T12:00:00Z"
        )
        let result = AmbitionsCommandExecutionResult(
            status: .succeeded,
            summary: "Completed recommended step",
            route: .today,
            target: target,
            eventLedgerEntryIDs: ["event-ledger.command-trust-1.command_execution"],
            metadata: ["receiptID": "receipt-trust-1"]
        )
        let commandRecord = AmbitionsCommandExecutionRecord(
            command: command,
            result: result,
            recordedAt: "2026-06-30T12:00:30Z"
        )
        let runtimeEvent = RuntimeEvent.commandExecution(
            command: command,
            result: result,
            recordedAt: "2026-06-30T12:00:30Z",
            commandRecordID: commandRecord.id
        )
        let step = LifeGraphObjectReference(
            kind: .step,
            id: "step-trust-1",
            parentContextID: "goal-trust-1",
            label: "Recommended step",
            sourceDomain: .today
        )
        let receipt = ActionReceipt(
            id: "receipt-trust-1",
            resultState: .completed,
            title: "Step completed",
            summary: "Completed recommended step with local proof.",
            sourceDomain: .today,
            occurredAt: "2026-06-30T12:00:45Z",
            affectedObjects: [step],
            changedFacts: [
                ActionReceiptChangedFact(
                    id: "fact-trust-1",
                    kind: .completedAction,
                    object: step,
                    fieldName: "state",
                    previousValueSummary: "active",
                    newValueSummary: "completed",
                    summary: "The recommended step completed locally."
                )
            ],
            correctionAvailability: .available,
            undoAvailability: .availableLocal,
            sourceObject: step
        )
        return (commandRecord, runtimeEvent, receipt)
    }

    private func repoRoot() throws -> URL {
        var candidate = URL(fileURLWithPath: #filePath)
        while candidate.path != "/" {
            if FileManager.default.fileExists(atPath: candidate.appendingPathComponent("project.yml").path) {
                return candidate
            }
            candidate.deleteLastPathComponent()
        }
        throw NSError(domain: "TrustSystemTests", code: 1)
    }
}
