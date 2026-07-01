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
        let fixture = try await Self.sanctionedMutationFixture()

        let plan = try await recorder.record(
            TrustSystemCommitInput(
                commandRecord: fixture.commandRecord,
                runtimeEventEnvelope: fixture.runtimeEventEnvelope,
                runtimeCommitReceipt: fixture.runtimeCommitReceipt,
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
        XCTAssertEqual(storedReceipts.map(\.id), [fixture.runtimeCommitReceipt.receiptID])
        XCTAssertTrue(plan.hasCompleteCommandEventProjectionReceiptReplayFlow)
        XCTAssertEqual(plan.runtimeLineage.runtimeTransactionID, fixture.runtimeCommitReceipt.transactionID)
        XCTAssertEqual(plan.runtimeLineage.runtimeEventID, fixture.runtimeCommitReceipt.eventID)
        XCTAssertEqual(plan.receiptRecord.runtimeLineage?.runtimeReplayTraceID, fixture.runtimeCommitReceipt.replayTraceID)
        XCTAssertEqual(plan.proofLedgerEntry.runtimeTransactionID, fixture.runtimeCommitReceipt.transactionID)
        XCTAssertEqual(plan.proofLedger.runtimeReplayTraceIDs, [fixture.runtimeCommitReceipt.replayTraceID])
        XCTAssertEqual(plan.proofLedgerEntry.proofReference?.id, "proof.\(fixture.runtimeCommitReceipt.receiptID)")
        XCTAssertEqual(plan.undoLedger.entry(receiptID: fixture.runtimeCommitReceipt.receiptID)?.runtimeRollbackPlanID, fixture.runtimeCommitReceipt.rollbackPlanID)
        XCTAssertEqual(plan.undoLedger.entry(receiptID: fixture.runtimeCommitReceipt.receiptID)?.canUndoLocally, true)
        XCTAssertEqual(plan.historyProjection.results.count, 2)
        XCTAssertTrue(plan.historyProjection.results.allSatisfy { $0.runtimeLineage?.runtimeEventID == fixture.runtimeCommitReceipt.eventID })
        XCTAssertEqual(plan.replayOutcome.decision, .replayExistingReceipt)
        XCTAssertTrue(plan.auditTrail.localOnly)
        XCTAssertTrue(plan.auditTrail.hasCompleteRuntimeLineage(
            commandID: fixture.commandRecord.commandID,
            receiptID: fixture.runtimeCommitReceipt.receiptID
        ))
        XCTAssertTrue(plan.sourceRecordLedger.separationReport.isSeparated)
        XCTAssertEqual(plan.sourceRecordLedger.publicSourceAtlasRecords.map(\.id), [
            "source.public-source-atlas.source-atlas.public.life-calendar"
        ])
        XCTAssertTrue(plan.sourceRecordLedger.privateLifeGraphRecords.allSatisfy { $0.allowsNetworkRefresh == false })
        XCTAssertTrue(plan.sourceRecordLedger.privateLifeGraphRecords.allSatisfy(\.hasPrivateRuntimeLineage))
        XCTAssertFalse(plan.sourceRecordLedger.publicSourceAtlasRecords.contains { $0.containsPrivateLifeGraph })
        XCTAssertTrue(plan.sourceRecordLedger.publicSourceAtlasRecords.allSatisfy(\.isPublicReferenceOnly))
    }

    func testTrustSystemRejectsRuntimeEventThatDoesNotMatchCommandRecord() async throws {
        let fixture = try await Self.sanctionedMutationFixture()
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
        let mismatchedEnvelope = try RuntimeEventEnvelope.make(
            sequence: fixture.runtimeEventEnvelope.sequence,
            previousChecksum: nil,
            event: mismatchedEvent
        )

        XCTAssertThrowsError(try TrustSystemCommitPlanner().plan(
            TrustSystemCommitInput(
                commandRecord: fixture.commandRecord,
                runtimeEventEnvelope: mismatchedEnvelope,
                runtimeCommitReceipt: fixture.runtimeCommitReceipt,
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

    private static func sanctionedMutationFixture() async throws -> (
        commandRecord: AmbitionsCommandExecutionRecord,
        runtimeEventEnvelope: RuntimeEventEnvelope,
        runtimeCommitReceipt: RuntimeCommitReceipt,
        receipt: ActionReceipt
    ) {
        let eventStore = InMemoryRuntimeEventStore()
        let coordinator = RuntimeTransactionCoordinator(eventStore: eventStore)
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
        let runtimeReceiptID = "runtime.receipt.command-trust-1"
        let result = AmbitionsCommandExecutionResult(
            status: .succeeded,
            summary: "Completed recommended step",
            route: .today,
            target: target,
            eventLedgerEntryIDs: ["event-ledger.command-trust-1.command_execution"],
            metadata: ["receiptID": runtimeReceiptID]
        )
        guard let occurredAt = DomainTimestamp.date(from: "2026-06-30T12:00:30Z") else {
            throw NSError(domain: "TrustSystemTests", code: 2)
        }
        let outcome = try await coordinator.commit(
            command: command,
            beforeSnapshot: "step.active",
            afterSnapshot: "step.completed",
            targetSurface: .today,
            executionResult: result,
            commandRecordID: "command.execution.command-trust-1",
            occurredAt: occurredAt
        )
        let envelopes = try await eventStore.fetchEvents(matching: .all, limit: nil)
        guard let runtimeEventEnvelope = envelopes.first else {
            throw NSError(domain: "TrustSystemTests", code: 3)
        }
        let lineage = RuntimeTrustLineage(runtimeCommitReceipt: outcome.receipt)
        let commandResult = result.mergingMetadata(lineage.metadata)
        let commandRecord = AmbitionsCommandExecutionRecord(
            id: "command.execution.command-trust-1",
            command: command,
            result: commandResult,
            recordedAt: "2026-06-30T12:00:30Z"
        )
        let step = LifeGraphObjectReference(
            kind: .step,
            id: "step-trust-1",
            parentContextID: "goal-trust-1",
            label: "Recommended step",
            sourceDomain: .today
        )
        let receipt = ActionReceipt(
            id: outcome.receipt.receiptID,
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
        return (commandRecord, runtimeEventEnvelope, outcome.receipt, receipt)
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
