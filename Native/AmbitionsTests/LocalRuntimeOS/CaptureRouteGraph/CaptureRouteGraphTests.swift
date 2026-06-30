import CryptoKit
import XCTest
@testable import Ambitions

final class CaptureRouteGraphTests: XCTestCase {
    func testCaptureRouteGraphOwnsCanonicalFilesWithoutOldAuthorityPaths() throws {
        let root = try repoRoot()
        let owner = root.appendingPathComponent("Native/Ambitions/Core/LocalRuntimeOS/CaptureRouteGraph", isDirectory: true)
        let requiredFiles = [
            "CaptureIntakeJournal.swift",
            "CaptureDraftStore.swift",
            "CaptureClassifier.swift",
            "CaptureRouteResolver.swift",
            "CaptureAttachmentVault.swift",
            "CapturePromotionTransaction.swift",
            "CaptureCorrectionLedger.swift",
            "CaptureDirectLookupIndex.swift",
            "CaptureRouteGraph.swift",
            "CaptureRouteCommandMapping.swift"
        ]

        for file in requiredFiles {
            XCTAssertTrue(FileManager.default.fileExists(atPath: owner.appendingPathComponent(file).path), file)
        }
        XCTAssertFalse(FileManager.default.fileExists(atPath: root.appendingPathComponent("Native/Ambitions/Core/Domain/CaptureRouteGraph.swift").path))
        XCTAssertFalse(FileManager.default.fileExists(atPath: root.appendingPathComponent("Native/Ambitions/Core/Domain/CaptureRouteCommandMapping.swift").path))

        let runtimeHelper = try String(
            contentsOf: root.appendingPathComponent("Native/Ambitions/Core/Runtime/CaptureService+04-DefaultCaptureService.swift"),
            encoding: .utf8
        )
        XCTAssertFalse(runtimeHelper.contains("enum CaptureClassifier"))
    }

    func testIntakeJournalPersistsBeforeRouteResolution() async throws {
        let root = try temporaryRoot()
        let graph = CaptureRouteGraphServices.fileBacked(rootDirectory: root)
        let receipt = try await graph.intakeJournal.append(
            CaptureIntakeJournalAppendRequest(
                captureID: "capture-intake-1",
                rawText: "Create launch checklist by Friday",
                sourceType: .shellComposer,
                sourceSurface: "Capture",
                receivedAt: "2026-06-30T10:00:00Z",
                deadlineIntent: "Friday"
            )
        )

        let reloadedGraph = CaptureRouteGraphServices.fileBacked(rootDirectory: root)
        let persistedRecord = try await reloadedGraph.intakeJournal.record(id: receipt.journalRecordID)
        let persisted = try XCTUnwrap(persistedRecord)
        let decision = try reloadedGraph.routeResolver.resolve(
            CaptureRouteResolveRequest(
                intakeReceipt: receipt,
                rawText: persisted.rawText,
                requestedKind: nil,
                requestedRoute: nil,
                deadlineText: nil,
                contextLensHint: nil,
                priorityHints: CapturePriorityHints(),
                sourceType: persisted.sourceType,
                sourceSurface: persisted.sourceSurface
            )
        )
        let draft = try await reloadedGraph.draftStore.upsert(intake: persisted, decision: decision, updatedAt: "2026-06-30T10:00:01Z")
        let lookup = try await reloadedGraph.directLookupIndex.index(intake: persisted, draft: draft, decision: decision, updatedAt: "2026-06-30T10:00:02Z")

        XCTAssertTrue(receipt.acknowledgedAfterDurableWrite)
        XCTAssertTrue(receipt.canClassify)
        XCTAssertEqual(decision.route, .timeSeed)
        XCTAssertEqual(decision.kind, .oneTimeCommitment)
        XCTAssertEqual(decision.runtimeEvent.kind, .captureRouteDecided)
        XCTAssertTrue(decision.runtimeTrace.satisfiesRuntimeSpine)
        XCTAssertEqual(draft.captureID, "capture-intake-1")
        XCTAssertEqual(lookup.intakeRecordID, receipt.journalRecordID)
    }

    func testAttachmentVaultStagesChecksumAndQuarantinesPrivatePayload() async throws {
        let root = try temporaryRoot()
        let graph = CaptureRouteGraphServices.fileBacked(rootDirectory: root)
        let data = Data("private proof payload".utf8)
        let staged = try await graph.attachmentVault.stage(
            CaptureAttachmentVaultStageRequest(
                captureID: "capture-attachment-1",
                originalFilename: "proof note.txt",
                contentType: "text/plain",
                data: data,
                stagedAt: "2026-06-30T10:05:00Z"
            )
        )
        let quarantined = try await graph.attachmentVault.quarantine(
            id: staged.id,
            reason: "User review required before promotion.",
            updatedAt: "2026-06-30T10:06:00Z"
        )

        XCTAssertEqual(staged.sha256, SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined())
        XCTAssertEqual(staged.byteCount, data.count)
        XCTAssertEqual(staged.state, .staged)
        XCTAssertEqual(quarantined.state, .quarantined)
        XCTAssertEqual(quarantined.quarantineReason, "User review required before promotion.")
        XCTAssertTrue(quarantined.localOnly)
    }

    func testPromotionTransactionAndCorrectionLedgerUseDurableIntake() async throws {
        let root = try temporaryRoot()
        let graph = CaptureRouteGraphServices.fileBacked(rootDirectory: root)
        let receipt = try await graph.intakeJournal.append(
            CaptureIntakeJournalAppendRequest(
                captureID: "capture-promotion-1",
                rawText: "Turn launch idea into a goal",
                sourceType: .shellComposer,
                sourceSurface: "Capture",
                receivedAt: "2026-06-30T10:10:00Z"
            )
        )
        let intakeRecord = try await graph.intakeJournal.record(id: receipt.journalRecordID)
        let intake = try XCTUnwrap(intakeRecord)
        let decision = try graph.routeResolver.resolve(
            CaptureRouteResolveRequest(
                intakeReceipt: receipt,
                rawText: intake.rawText,
                requestedKind: .goalSeed,
                requestedRoute: .goalSeed,
                deadlineText: nil,
                contextLensHint: nil,
                priorityHints: CapturePriorityHints(),
                sourceType: intake.sourceType,
                sourceSurface: intake.sourceSurface
            )
        )
        let draft = try await graph.draftStore.upsert(intake: intake, decision: decision, updatedAt: "2026-06-30T10:10:01Z")
        let lookup = try await graph.directLookupIndex.index(intake: intake, draft: draft, decision: decision, updatedAt: "2026-06-30T10:10:02Z")
        let promotion = try await graph.promotionTransaction.prepare(
            CapturePromotionTransactionRequest(
                intakeReceipt: receipt,
                captureID: "capture-promotion-1",
                destination: .goal,
                targetObjectIDs: ["goal-1", "draft-1"],
                occurredAt: "2026-06-30T10:10:03Z",
                summary: "Promote capture into a local goal."
            )
        )
        let correctedLookup = try await graph.directLookupIndex.updateRoute(
            captureID: "capture-promotion-1",
            route: .timeSeed,
            kind: .oneTimeCommitment,
            decisionID: "decision-corrected",
            updatedAt: "2026-06-30T10:10:04Z"
        )
        let correction = try await graph.correctionLedger.append(
            CaptureCorrectionLedgerRequest(
                captureID: "capture-promotion-1",
                previousRoute: .goalSeed,
                correctedRoute: .timeSeed,
                previousKind: .goalSeed,
                correctedKind: .oneTimeCommitment,
                reason: "User chose Step instead of Goal.",
                occurredAt: "2026-06-30T10:10:05Z",
                intakeRecordID: receipt.journalRecordID,
                decisionID: correctedLookup?.decisionID
            )
        )

        XCTAssertEqual(lookup.captureID, "capture-promotion-1")
        XCTAssertTrue(promotion.satisfiesRuntimeSpine)
        XCTAssertEqual(promotion.writeAuthority, "Core/LocalRuntimeOS/CaptureRouteGraph + TransactionKernel")
        XCTAssertEqual(promotion.sideEffectPolicy, AppUnitOfWorkReceipt.noExternalSideEffects)
        XCTAssertEqual(correctedLookup?.route, .timeSeed)
        XCTAssertEqual(correction.correctedRoute, .timeSeed)
        XCTAssertTrue(correction.runtimeTrace.satisfiesRuntimeSpine)
    }

    func testDefaultCaptureServiceRoutesThroughCaptureRouteGraphOnCreateAndPromotion() async throws {
        let root = try temporaryRoot()
        let graph = CaptureRouteGraphServices.fileBacked(rootDirectory: root)
        let store = try AmbitionsPersistenceStore(inMemory: true)
        let repositories = makeRepositories(store: store)
        let service = DefaultCaptureService(
            repository: repositories.captures,
            eventLedger: repositories.eventLedger,
            simpleStepLifecycleService: SimpleStepLifecycleService(repositories: repositories, idProvider: { "route-graph-step" }),
            captureRouteGraph: graph,
            idProvider: { "capture-route-graph-service" }
        )

        let capture = try await service.createCapture(
            CreateCaptureRequest(
                rawText: "Email the launch checklist by Friday",
                sourceType: .shellComposer,
                kind: .oneTimeCommitment,
                route: .timeSeed
            ),
            now: Date(timeIntervalSince1970: 1_777_113_600)
        )
        let intakeRecords = try await graph.intakeJournal.records()
        let lookup = try await graph.directLookupIndex.entry(captureID: capture.id)
        let promotions = try await graph.promotionTransaction.receipts(captureID: capture.id)

        XCTAssertEqual(capture.route, .timeSeed)
        XCTAssertEqual(intakeRecords.map(\.captureID), [capture.id])
        XCTAssertEqual(lookup?.route, .timeSeed)
        XCTAssertEqual(promotions.first?.destination, .step)
        XCTAssertTrue(promotions.first?.satisfiesRuntimeSpine == true)
    }
}

private extension CaptureRouteGraphTests {
    func temporaryRoot() throws -> URL {
        let root = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            .appendingPathComponent("CaptureRouteGraphTests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        addTeardownBlock {
            try? FileManager.default.removeItem(at: root)
        }
        return root
    }

    func repoRoot() throws -> URL {
        var url = URL(fileURLWithPath: #filePath)
        while url.lastPathComponent != "ambitions" && url.path != "/" {
            url.deleteLastPathComponent()
        }
        return url
    }

    func makeRepositories(store: AmbitionsPersistenceStore) -> AppRepositories {
        AppRepositories(
            goals: SwiftDataGoalRepository(store: store),
            drafts: SwiftDataGoalDraftRepository(store: store),
            evidence: SwiftDataProgressEvidenceRepository(store: store),
            feedback: SwiftDataFeedbackEventRepository(store: store),
            captures: SwiftDataCaptureRepository(store: store),
            eventLedger: SwiftDataEventLedgerRepository(store: store),
            commandExecutionRecords: SwiftDataAmbitionsCommandExecutionRecordRepository(store: store),
            goalCreationUnitOfWork: SwiftDataGoalCreationUnitOfWork(store: store),
            capturePromotionUnitOfWork: SwiftDataCapturePromotionUnitOfWork(store: store),
            appState: SwiftDataAppStateRepository(store: store)
        )
    }
}
