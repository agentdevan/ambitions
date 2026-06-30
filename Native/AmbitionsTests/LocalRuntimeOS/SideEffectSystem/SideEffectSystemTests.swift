import SwiftData
import XCTest
@testable import Ambitions

final class SideEffectSystemTests: XCTestCase {
    func testSideEffectSystemCanonicalOwnerFilesExistAndOldOwnersAreRemoved() throws {
        let root = repositoryRoot()
        let requiredFiles = [
            "Native/Ambitions/Core/LocalRuntimeOS/SideEffectSystem/SideEffectLedgerModels.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/SideEffectSystem/SideEffectLedgerSwiftDataRepository.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/SideEffectSystem/SideEffectPolicyEngine.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/SideEffectSystem/SideEffectOutbox.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/SideEffectSystem/NotificationOutbox.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/SideEffectSystem/EventKitOutbox.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/SideEffectSystem/ReminderOutbox.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/SideEffectSystem/WidgetRefreshOutbox.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/SideEffectSystem/AppIntentBridge.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/SideEffectSystem/ShareExtensionIntake.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/SideEffectSystem/ExternalCreationImportService.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/SideEffectSystem/ExternalReconciliation.swift",
        ]

        for path in requiredFiles {
            XCTAssertTrue(FileManager.default.fileExists(atPath: root.appendingPathComponent(path).path), path)
        }

        XCTAssertFalse(
            FileManager.default.fileExists(atPath: root.appendingPathComponent("Native/Ambitions/Core/Domain/SideEffectLedgerModels.swift").path)
        )
        XCTAssertFalse(
            FileManager.default.fileExists(atPath: root.appendingPathComponent("Native/Ambitions/Core/Runtime/ExternalCreationImportService.swift").path)
        )

        let oldPersistenceFile = try String(
            contentsOf: root.appendingPathComponent("Native/Ambitions/Core/Persistence/SwiftDataRepositories+05-SwiftDataAmbitionGraphProjectionRecordRepository.swift"),
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

    func testLocalCommitReceiptSurvivesExternalAttemptFailure() async throws {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        let unitOfWork = SwiftDataAppUnitOfWork(store: store)
        let localCommit = try await unitOfWork.perform(
            id: "local-commit.before-side-effect",
            timestampProvider: Self.timestampProvider()
        ) { context in
            context.insert(
                AppStateRecord(
                    id: "side-effect-system-test-state",
                    preferredTabRaw: "today",
                    userDisplayName: "Local Runtime",
                    appearancePreferenceRaw: "system",
                    accentFamilyRaw: nil,
                    hasCompletedBootstrap: true,
                    lastBootstrapSourceRaw: "test",
                    lastBootstrapAt: "2026-06-30T08:00:00Z",
                    lastSeedVersion: nil,
                    lastSeededAt: nil,
                    lastOpenedGoalID: nil,
                    snapshotData: Data()
                )
            )
            return "committed"
        }
        XCTAssertEqual(localCommit.value, "committed")
        XCTAssertTrue(localCommit.receipt.didCommitChanges)
        XCTAssertEqual(localCommit.receipt.sideEffectPolicy, AppUnitOfWorkReceipt.noExternalSideEffects)

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
            localCommit: SideEffectLocalCommitEvidence(receipt: localCommit.receipt),
            requestedStatus: .queued,
            requestedBoundary: .externalEffect,
            reasons: [.externalSideEffect]
        )

        let attempt = try await outbox.enqueue(request)
        let queued = try await ledger.fetchRecord(id: request.id)

        XCTAssertTrue(attempt.mayAttemptExternalWrite)
        XCTAssertEqual(attempt.lease?.sideEffectID, request.id)
        XCTAssertEqual(queued?.status, .queued)
        XCTAssertTrue(queued?.degradedFacts.contains("Local commit receipt local-commit.before-side-effect completed before side-effect recording.") == true)

        let receipt = try await outbox.recordResult(
            SideEffectAttemptResult(
                state: .failedSafely,
                degradedFacts: ["EventKit write failed after local commit remained saved."]
            ),
            for: attempt,
            occurredAt: Date(timeIntervalSince1970: 1_714_000_120)
        )
        let failed = try await ledger.fetchRecord(id: request.id)
        let storedState = try await store.read { context -> (id: String, completedBootstrap: Bool)? in
            try context.fetch(FetchDescriptor<AppStateRecord>())
                .first(where: { $0.id == "side-effect-system-test-state" })
                .map { ($0.id, $0.hasCompletedBootstrap) }
        }

        XCTAssertEqual(receipt.localCommitReceiptID, "local-commit.before-side-effect")
        XCTAssertEqual(receipt.status, .failedSafely)
        XCTAssertEqual(failed?.status, .failedSafely)
        XCTAssertEqual(failed?.receiptID, receipt.id)
        XCTAssertEqual(storedState?.id, "side-effect-system-test-state")
        XCTAssertEqual(storedState?.completedBootstrap, true)
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
    }

    private func repositoryRoot() -> URL {
        var url = URL(fileURLWithPath: #filePath)
        for _ in 0..<5 {
            url.deleteLastPathComponent()
        }
        return url
    }

    private static func timestampProvider() -> @Sendable () -> String {
        { "2026-06-30T08:00:00Z" }
    }

    private func temporaryDirectory() -> URL {
        FileManager.default.temporaryDirectory
            .appendingPathComponent("AmbitionsSideEffectSystemTests-\(UUID().uuidString)", isDirectory: true)
    }
}
