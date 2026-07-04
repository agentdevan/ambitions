import XCTest
@testable import Ambitions

final class ExternalWritesTests: XCTestCase {
    func testExternalWritesCanonicalOwnerFilesExistAndOldOwnersAreRemoved() throws {
        let root = repositoryRoot()
        let requiredFiles = [
            "Native/Ambitions/Core/LocalRuntimeOS/ExternalWrites/SideEffectLedgerModels.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/ExternalWrites/SideEffectLedgerSwiftDataRepository.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/ExternalWrites/SideEffectPolicyEngine.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/ExternalWrites/SideEffectOutbox.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/ExternalWrites/NotificationOutbox.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/ExternalWrites/EventKitOutbox.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/ExternalWrites/WidgetRefreshOutbox.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/ExternalWrites/AppIntentBridge.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/ExternalWrites/ShareExtensionIntake.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/ExternalWrites/ExternalCreationImportService.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/ExternalWrites/ExternalReconciliation.swift",
        ]

        for path in requiredFiles {
            XCTAssertTrue(FileManager.default.fileExists(atPath: root.appendingPathComponent(path).path), path)
        }

        XCTAssertFalse(
            FileManager.default.fileExists(atPath: root.appendingPathComponent("Native/Ambitions/Core/Domain/SideEffectLedgerModels.swift").path)
        )
        XCTAssertFalse(
            FileManager.default.fileExists(atPath: root.appendingPathComponent(removedRuntimeOwnerPath("ExternalCreationImportService.swift")).path)
        )
        XCTAssertFalse(
            FileManager.default.fileExists(atPath: root.appendingPathComponent("Native/Ambitions/Core/LocalRuntimeOS/SideEffectSystem").path)
        )
        XCTAssertFalse(
            FileManager.default.fileExists(atPath: root.appendingPathComponent("Native/AmbitionsTests/LocalRuntimeOS/SideEffectSystem").path)
        )
        XCTAssertFalse(
            FileManager.default.fileExists(atPath: root.appendingPathComponent("Native/Ambitions/Core/LocalRuntimeOS/ExternalWrites/ReminderOutbox.swift").path)
        )

        let oldPersistenceFile = try String(
            contentsOf: root.appendingPathComponent("Native/Ambitions/Core/LocalRuntimeOS/Storage/SwiftDataAmbitionGraphProjectionRecordRepository.swift"),
            encoding: .utf8
        )
        XCTAssertFalse(oldPersistenceFile.contains("struct SwiftDataSideEffectLedgerRepository"))
    }

    func testOutboxBlocksExternalAttemptWithoutCommittedLocalMutationReceipt() async throws {
        let ledger = InMemorySideEffectLedgerRepository()
        let outbox = SideEffectOutbox(ledger: ledger, leaseDuration: 60)
        let request = SideEffectOutboxRequest(
            id: "side-effect.calendar.write.missing-local-commit",
            effectKind: .calendar,
            actionKind: .writeCalendarBlock,
            sourceDomain: .time,
            targetObjects: [LifeGraphObjectReference(kind: .action, id: "step-1", label: "Draft proposal", sourceDomain: .today)],
            requestedAt: Date(timeIntervalSince1970: 1_714_000_000),
            externalEffect: true,
            requiresConfirmation: false,
            commitRequirement: .localCommitRequired,
            requestedStatus: .queued,
            requestedBoundary: .externalEffect,
            reasons: [.externalSideEffect]
        )

        let attempt = try await outbox.enqueue(request)
        let stored = try await ledger.fetchRecord(id: request.id)

        XCTAssertFalse(attempt.mayAttemptExternalWrite)
        XCTAssertNil(attempt.lease)
        XCTAssertEqual(stored?.status, .blocked)
        XCTAssertEqual(stored?.boundary, .externalEffect)
        XCTAssertEqual(stored?.externalEffect, true)
        XCTAssertTrue(stored?.blockedFacts.contains("External side effect cannot be attempted before a committed local mutation receipt.") == true)
    }

    func testOutboxBlocksExternalAttemptThatDoesNotDeclareLocalCommitRequirement() async throws {
        let eventStore = InMemoryRuntimeEventStore()
        let localCommitOutcome = try await runtimeCommit(
            id: "command-before-bad-requirement",
            eventStore: eventStore
        )
        let ledger = InMemorySideEffectLedgerRepository()
        let outbox = SideEffectOutbox(ledger: ledger, leaseDuration: 60)
        let request = SideEffectOutboxRequest(
            id: "side-effect.calendar.write.bad-requirement",
            effectKind: .calendar,
            actionKind: .writeCalendarBlock,
            sourceDomain: .time,
            requestedAt: Date(timeIntervalSince1970: 1_714_000_000),
            externalEffect: true,
            requiresConfirmation: false,
            commitRequirement: .resultObservation,
            localCommit: SideEffectLocalCommitEvidence(runtimeReceipt: localCommitOutcome.receipt),
            requestedStatus: .queued,
            requestedBoundary: .externalEffect,
            reasons: [.externalSideEffect]
        )

        let attempt = try await outbox.enqueue(request)
        let stored = try await ledger.fetchRecord(id: request.id)

        XCTAssertFalse(attempt.mayAttemptExternalWrite)
        XCTAssertNil(attempt.lease)
        XCTAssertEqual(stored?.status, .blocked)
        XCTAssertTrue(stored?.blockedFacts.contains("External side effect must declare a local runtime commit receipt requirement.") == true)
    }

    func testBlockedRequestPreservesExplicitUnsupportedBoundary() async throws {
        let ledger = InMemorySideEffectLedgerRepository()
        let outbox = SideEffectOutbox(ledger: ledger, leaseDuration: 60)
        let request = SideEffectOutboxRequest(
            id: "side-effect.command-bridge.unsupported-payload",
            effectKind: .commandBridge,
            actionKind: .markDone,
            sourceDomain: .externalSurface,
            requestedAt: Date(timeIntervalSince1970: 1_714_000_000),
            externalEffect: false,
            requiresConfirmation: false,
            commitRequirement: .noUserStateMutation,
            requestedStatus: .unsupported,
            requestedBoundary: .unsupported,
            reasons: [.unsupportedSource],
            blockedFacts: ["External payload attempted a runtime mutation from an unsupported surface."]
        )

        let attempt = try await outbox.enqueue(request)
        let stored = try await ledger.fetchRecord(id: request.id)

        XCTAssertFalse(attempt.mayAttemptExternalWrite)
        XCTAssertEqual(stored?.status, .blocked)
        XCTAssertEqual(stored?.boundary, .unsupported)
        XCTAssertTrue(stored?.localOnly == true)
        XCTAssertTrue(stored?.blockedFacts.contains("External payload attempted a runtime mutation from an unsupported surface.") == true)
    }

    func testLocalCommitReceiptSurvivesExternalAttemptFailure() async throws {
        let eventStore = InMemoryRuntimeEventStore()
        let localCommitOutcome = try await runtimeCommit(
            id: "command-before-side-effect",
            eventStore: eventStore
        )
        let localCommit = SideEffectLocalCommitEvidence(runtimeReceipt: localCommitOutcome.receipt)

        let ledger = InMemorySideEffectLedgerRepository()
        let outbox = SideEffectOutbox(ledger: ledger, leaseDuration: 60)
        let request = SideEffectOutboxRequest(
            id: "side-effect.calendar.write.after-local-commit",
            effectKind: .calendar,
            actionKind: .writeCalendarBlock,
            sourceDomain: .time,
            targetObjects: [LifeGraphObjectReference(kind: .action, id: "step-2", label: "Schedule proposal", sourceDomain: .today)],
            requestedAt: Date(timeIntervalSince1970: 1_714_000_000),
            externalEffect: true,
            requiresConfirmation: false,
            commitRequirement: .localCommitRequired,
            localCommit: localCommit,
            requestedStatus: .queued,
            requestedBoundary: .externalEffect,
            reasons: [.externalSideEffect]
        )

        let attempt = try await outbox.enqueue(request)
        let queued = try await ledger.fetchRecord(id: request.id)

        XCTAssertTrue(attempt.mayAttemptExternalWrite)
        XCTAssertEqual(attempt.lease?.sideEffectID, request.id)
        XCTAssertEqual(queued?.status, .queued)
        XCTAssertTrue(queued?.degradedFacts.contains("Local commit receipt runtime.commit-receipt.command-before-side-effect completed before side-effect recording.") == true)

        let receipt = try await outbox.recordResult(
            SideEffectAttemptResult(
                state: .failedSafely,
                degradedFacts: ["EventKit write failed after local commit remained saved."]
            ),
            for: attempt,
            occurredAt: Date(timeIntervalSince1970: 1_714_000_120)
        )
        let failed = try await ledger.fetchRecord(id: request.id)
        let events = try await eventStore.fetchEvents(matching: .all, limit: nil)

        XCTAssertEqual(receipt.localCommitReceiptID, "runtime.commit-receipt.command-before-side-effect")
        XCTAssertEqual(receipt.status, .failedSafely)
        XCTAssertEqual(failed?.status, .failedSafely)
        XCTAssertEqual(failed?.receiptID, receipt.id)
        XCTAssertEqual(events.count, 1)
        XCTAssertEqual(events.first?.event.commandID, "command-before-side-effect")
        XCTAssertTrue(localCommitOutcome.receipt.hasReplayableProof)
    }

    func testConfirmedExternalWriteWithRuntimeReceiptMayAttempt() async throws {
        let eventStore = InMemoryRuntimeEventStore()
        let localCommitOutcome = try await runtimeCommit(
            id: "command-before-confirmed-side-effect",
            eventStore: eventStore
        )
        let ledger = InMemorySideEffectLedgerRepository()
        let outbox = SideEffectOutbox(ledger: ledger, leaseDuration: 60)
        let request = SideEffectOutboxRequest(
            id: "side-effect.calendar.write.after-confirmation",
            effectKind: .calendar,
            actionKind: .writeCalendarBlock,
            sourceDomain: .time,
            requestedAt: Date(timeIntervalSince1970: 1_714_000_000),
            externalEffect: true,
            requiresConfirmation: true,
            commitRequirement: .localCommitRequired,
            localCommit: SideEffectLocalCommitEvidence(runtimeReceipt: localCommitOutcome.receipt),
            requestedStatus: .queued,
            requestedBoundary: .externalEffect,
            reasons: [.externalSideEffect, .confirmationRequired]
        )

        let attempt = try await outbox.enqueue(request)
        let queued = try await ledger.fetchRecord(id: request.id)

        XCTAssertTrue(attempt.mayAttemptExternalWrite)
        XCTAssertEqual(attempt.lease?.sideEffectID, request.id)
        XCTAssertEqual(queued?.status, .queued)
        XCTAssertEqual(queued?.requiresConfirmation, true)
        XCTAssertEqual(queued?.externalEffect, true)
    }

    func testLegacyUnitOfWorkReceiptDoesNotPermitExternalWriteWithoutRuntimeReceiptProof() async throws {
        let ledger = InMemorySideEffectLedgerRepository()
        let outbox = SideEffectOutbox(ledger: ledger, leaseDuration: 60)
        let legacyReceipt = AppUnitOfWorkReceipt(
            id: "legacy.unit-of-work.receipt",
            startedAt: "2026-06-30T08:00:00Z",
            completedAt: "2026-06-30T08:00:01Z",
            writeScope: .localSwiftDataSingleContext,
            didCommitChanges: true,
            rollbackBehavior: AppUnitOfWorkReceipt.rollbackOnThrownError,
            sideEffectPolicy: AppUnitOfWorkReceipt.noExternalSideEffects
        )
        let request = SideEffectOutboxRequest(
            id: "side-effect.calendar.write.legacy-receipt",
            effectKind: .calendar,
            actionKind: .writeCalendarBlock,
            sourceDomain: .time,
            requestedAt: Date(timeIntervalSince1970: 1_714_000_000),
            externalEffect: true,
            requiresConfirmation: false,
            commitRequirement: .localCommitRequired,
            localCommit: SideEffectLocalCommitEvidence(receipt: legacyReceipt),
            requestedStatus: .queued,
            requestedBoundary: .externalEffect,
            reasons: [.externalSideEffect]
        )

        let attempt = try await outbox.enqueue(request)
        let stored = try await ledger.fetchRecord(id: request.id)

        XCTAssertFalse(attempt.mayAttemptExternalWrite)
        XCTAssertNil(attempt.lease)
        XCTAssertEqual(stored?.status, .blocked)
        XCTAssertTrue(stored?.blockedFacts.contains("External side effect cannot be attempted before a committed local mutation receipt.") == true)
    }

    func testAppIntentBridgeAppendsExternalCreationThroughCanonicalSideEffectOwner() async throws {
        let ledger = InMemorySideEffectLedgerRepository()
        let outbox = SideEffectOutbox(ledger: ledger, leaseDuration: 60)
        let store = SharedExternalCreationStore(baseURL: temporaryDirectory())
        let bridge = AppIntentBridge(recorder: outbox, store: store)
        let request = ExternalCreationRequest(
            id: "intent-side-effect-test",
            createdAt: "2026-06-30T12:00:00Z",
            text: "Capture from App Intent",
            source: .appIntent,
            landing: .captureComposer
        )

        let attempt = try await bridge.enqueueExternalCreation(
            request,
            acceptedAt: Date(timeIntervalSince1970: 1_777_113_600)
        )

        XCTAssertEqual(try store.peek(), [request])
        XCTAssertEqual(attempt?.id, "app-intent-intake.intent-side-effect-test")
        let stored = try await ledger.fetchRecord(id: "app-intent-intake.intent-side-effect-test")
        XCTAssertEqual(stored?.effectKind, .externalSnapshot)
        XCTAssertEqual(stored?.actionKind, .createCapture)
        XCTAssertEqual(stored?.sourceDomain, .externalSurface)
        XCTAssertEqual(stored?.status, .recordedLocalOnly)
        XCTAssertEqual(stored?.boundary, .localOnly)
        XCTAssertEqual(stored?.receiptID, "app-intent-intake-receipt.intent-side-effect-test")
        XCTAssertTrue(stored?.degradedFacts.contains("App Intent external creation intent-side-effect-test stored for local command-backed import.") == true)
    }

    func testShareExtensionIntakeRecordsCommittedProjectionOutboxInsteadOfDirectMutation() async throws {
        let ledger = InMemorySideEffectLedgerRepository()
        let outbox = SideEffectOutbox(ledger: ledger, leaseDuration: 60)
        let intake = ShareExtensionIntake(recorder: outbox)

        await intake.recordDurableIntake(
            requestID: "share-side-effect-test",
            landing: .captureComposer,
            receivedAt: Date(timeIntervalSince1970: 1_777_113_600)
        )

        let stored = try await ledger.fetchRecord(id: "share-intake.share-side-effect-test")
        XCTAssertEqual(stored?.effectKind, .externalSnapshot)
        XCTAssertEqual(stored?.actionKind, .createCapture)
        XCTAssertEqual(stored?.sourceDomain, .capture)
        XCTAssertEqual(stored?.status, .recordedLocalOnly)
        XCTAssertEqual(stored?.boundary, .localOnly)
        XCTAssertEqual(stored?.externalEffect, false)
        XCTAssertEqual(stored?.receiptID, "share-intake-receipt.share-side-effect-test")
        XCTAssertTrue(stored?.degradedFacts.contains("Share extension intake stored request for capture_composer without direct private graph mutation.") == true)
    }

    private func repositoryRoot() -> URL {
        var url = URL(fileURLWithPath: #filePath)
        for _ in 0..<5 {
            url.deleteLastPathComponent()
        }
        return url
    }

    private func runtimeCommit(
        id: String,
        eventStore: InMemoryRuntimeEventStore
    ) async throws -> RuntimeTransactionCommitOutcome {
        let coordinator = RuntimeTransactionCoordinator(eventStore: eventStore)
        let occurredAt = try XCTUnwrap(DomainTimestamp.date(from: "2026-04-25T12:00:00Z"))
        let command = AmbitionsCommand(
            id: id,
            kind: .startStepSession,
            source: .today,
            target: AmbitionsCommandTarget(goalID: "goal-1", stepID: "step-1"),
            payload: AmbitionsCommandPayload(title: "Open step"),
            createdAt: "2026-04-25T12:00:00Z"
        )
        return try await coordinator.commit(
            command: command,
            beforeSnapshot: "today.before",
            afterSnapshot: "today.after",
            targetSurface: .today,
            occurredAt: occurredAt
        )
    }

    private func temporaryDirectory() -> URL {
        FileManager.default.temporaryDirectory
            .appendingPathComponent("AmbitionsExternalWritesTests-\(UUID().uuidString)", isDirectory: true)
    }
}
