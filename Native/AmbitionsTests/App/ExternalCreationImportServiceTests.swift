import XCTest
@testable import Ambitions

@MainActor
final class ExternalCreationImportServiceTests: XCTestCase {
    func testSharedExternalCreationStoreKeepsPendingRequestsUntilAcknowledged() throws {
        let store = SharedExternalCreationStore(baseURL: temporaryDirectory())
        let request = makeRequest(text: "Shared note", source: .shareExtensionText)

        try store.enqueueDurableRequest(request)

        XCTAssertEqual(try store.pendingRequests(), [request])
        XCTAssertEqual(try store.pendingRequests(), [request])
        XCTAssertEqual(try store.peek(), [request])
        try store.acknowledge(requestIDs: [request.id])
        XCTAssertEqual(try store.peek(), [])
    }

    func testSharedExternalCreationStoreAcknowledgementIsIdempotent() throws {
        let store = SharedExternalCreationStore(baseURL: temporaryDirectory())
        let request = makeRequest(text: "Shared note", source: .shareExtensionText)

        try store.enqueueDurableRequest(request)
        try store.acknowledge(requestIDs: [request.id])
        try store.acknowledge(requestIDs: [request.id])

        XCTAssertEqual(try store.pendingRequests(), [])
    }

    func testSharedExternalCreationStoreRejectsOversizedPayloadBeforeItCanEnterTheQueue() throws {
        let store = SharedExternalCreationStore(baseURL: temporaryDirectory())
        let request = makeRequest(
            text: String(repeating: "x", count: SharedExternalCreationStore.maximumCaptureTextBytes + 1),
            source: .shareExtensionText
        )

        XCTAssertThrowsError(try store.enqueueDurableRequest(request)) { error in
            guard let storeError = error as? SharedExternalCreationStoreError,
                  case .invalidRequest = storeError else {
                return XCTFail("Expected oversized request rejection, got \(error)")
            }
        }
        XCTAssertEqual(try store.pendingRequests(), [])
    }

    func testIndependentStoresSerializeOverlappingQueueMutationsWithoutLostUpdate() async throws {
        let root = temporaryDirectory()
        let firstWriterLoadedQueue = DispatchSemaphore(value: 0)
        let releaseFirstWriter = DispatchSemaphore(value: 0)
        let secondWriterStarted = DispatchSemaphore(value: 0)
        let secondWriterLoadedQueue = DispatchSemaphore(value: 0)
        let appStore = SharedExternalCreationStore(
            baseURL: root,
            coordinatedMutationDidLoadQueue: {
                firstWriterLoadedQueue.signal()
                releaseFirstWriter.wait()
            }
        )
        let extensionStore = SharedExternalCreationStore(
            baseURL: root,
            coordinatedMutationDidLoadQueue: {
                secondWriterLoadedQueue.signal()
            }
        )
        let first = makeRequest(id: "first", text: "From app", source: .appIntent)
        let second = makeRequest(id: "second", text: "From share", source: .shareExtensionText)

        let firstWriter = Task.detached(priority: .high) {
            try appStore.enqueueDurableRequest(first)
        }
        XCTAssertEqual(firstWriterLoadedQueue.wait(timeout: .now() + 2), .success)

        let secondWriter = Task.detached(priority: .high) {
            secondWriterStarted.signal()
            try extensionStore.enqueueDurableRequest(second)
        }
        XCTAssertEqual(secondWriterStarted.wait(timeout: .now() + 2), .success)
        XCTAssertEqual(secondWriterLoadedQueue.wait(timeout: .now() + 0.2), .timedOut)

        releaseFirstWriter.signal()
        try await firstWriter.value
        try await secondWriter.value

        XCTAssertEqual(secondWriterLoadedQueue.wait(timeout: .now() + 2), .success)
        XCTAssertEqual(
            try SharedExternalCreationStore(baseURL: root).pendingRequests(),
            [first, second]
        )
    }

    func testImportServiceCreatesNormalCapturesAndPreservesProvenanceHint() async throws {
        let root = temporaryDirectory()
        let store = SharedExternalCreationStore(baseURL: root)
        let captureRouting = CaptureRoutingServices.fileBacked(rootDirectory: root)
        let repository = PreviewCaptureRepository()
        let captureService = DefaultCaptureService(
            repository: repository,
            captureRouting: captureRouting,
            idProvider: { "capture-external" }
        )
        let commandRecords = InMemoryAmbitionsCommandExecutionRecordRepository()
        let commandJournal = InMemoryCommandJournal()
        let executor = AmbitionsCommandExecutor.test(
            captureService: captureService,
            commandExecutionRecords: commandRecords,
            commandJournal: commandJournal
        )
        let service = DefaultExternalCreationImportService(store: store, commandExecutor: executor)

        try store.enqueueDurableRequest(
            makeRequest(
                text: "https://example.com/source",
                source: .shareExtensionURL,
                sourceApplication: "Safari",
                sourceURL: "https://example.com/source"
            )
        )

        let result = await service.importPendingCreations(now: Date(timeIntervalSince1970: 1_712_692_800))
        let captures = try await repository.listCaptures()
        let intakeRecords = try await captureRouting.intakeJournal.records()
        let lookup = try await captureRouting.directLookupIndex.entry(
            captureID: "capture.external.creation.command.external-request"
        )

        XCTAssertEqual(result.importedCaptureIDs, ["capture.external.creation.command.external-request"])
        XCTAssertEqual(result.preferredLanding, .captureComposer)
        XCTAssertEqual(result.source, .shareExtensionURL)
        XCTAssertEqual(captures.first?.rawText, "https://example.com/source")
        XCTAssertEqual(captures.first?.sourceType, .shareExtensionURL)
        XCTAssertEqual(captures.first?.triage?.destination, .doSoon)
        XCTAssertEqual(captures.first?.triage?.hint, "From Safari: https://example.com/source")
        XCTAssertEqual(intakeRecords.map(\.captureID), ["capture.external.creation.command.external-request"])
        XCTAssertEqual(intakeRecords.first?.sourceType, .shareExtensionURL)
        XCTAssertEqual(lookup?.intakeRecordID, intakeRecords.first?.id)
        XCTAssertEqual(try store.pendingRequests(), [])
        let entries = try await commandJournal.fetchEntries(matching: .all, limit: nil)
        XCTAssertEqual(entries.map(\.envelope.commandID), ["external.creation.command.external-request"])
        let record = try await commandRecords.fetchRecord(commandID: "external.creation.command.external-request")
        XCTAssertEqual(
            record?.result?.metadata["commandReceiptID"],
            "command.receipt.external.creation.command.external-request"
        )
    }

    func testImportServiceCanPreferCreateGoalLandingWithoutCreatingASeparateGoalPath() async throws {
        let store = SharedExternalCreationStore(baseURL: temporaryDirectory())
        let repository = PreviewCaptureRepository()
        let captureService = DefaultCaptureService(repository: repository, idProvider: { "capture-goal-seed" })
        let commandJournal = InMemoryCommandJournal()
        let executor = AmbitionsCommandExecutor.test(
            captureService: captureService,
            commandExecutionRecords: InMemoryAmbitionsCommandExecutionRecordRepository(),
            commandJournal: commandJournal
        )
        let service = DefaultExternalCreationImportService(store: store, commandExecutor: executor)

        try store.enqueueDurableRequest(
            makeRequest(
                text: "Turn this into an ambition",
                source: .appIntent,
                landing: .createGoal
            )
        )

        let result = await service.importPendingCreations(now: .now)
        let captures = try await repository.listCaptures()

        XCTAssertEqual(result.importedCaptureIDs, ["capture.external.creation.command.external-request"])
        XCTAssertEqual(result.preferredLanding, .createGoal)
        XCTAssertEqual(result.source, .appIntent)
        XCTAssertEqual(captures.first?.sourceType, .appIntent)
        XCTAssertEqual(captures.first?.triage?.destination, .turnIntoGoal)
        XCTAssertEqual(try store.pendingRequests(), [])
        let entries = try await commandJournal.fetchEntries(matching: .all, limit: nil)
        XCTAssertEqual(entries.first?.envelope.source, .appIntent)
        XCTAssertEqual(entries.first?.envelope.actor, .externalSurface)
    }

    func testFailedImportRemainsQueued() async throws {
        let store = SharedExternalCreationStore(baseURL: temporaryDirectory())
        let executor = AmbitionsCommandExecutor.test(captureService: nil)
        let service = DefaultExternalCreationImportService(store: store, commandExecutor: executor)
        let request = makeRequest(text: "Keep this until import works", source: .appIntent)

        try store.enqueueDurableRequest(request)

        let result = await service.importPendingCreations(now: Date(timeIntervalSince1970: 1_712_692_800))

        XCTAssertEqual(result.importedCaptureIDs, [])
        XCTAssertEqual(try store.pendingRequests(), [request])
    }
}

extension ExternalCreationImportServiceTests {
    func testSQLiteAuthorityReplayAcknowledgesWithoutDoubleCapture() async throws {
        let root = temporaryDirectory()
        let databaseURL = root.appendingPathComponent("EventStore.sqlite")
        let failedAcknowledgementStore = SharedExternalCreationStore(
            fileManager: RemoveFailingFileManager(),
            baseURL: root
        )
        let retryStore = SharedExternalCreationStore(baseURL: root)
        let repository = PreviewCaptureRepository()
        let captureService = DefaultCaptureService(repository: repository)
        let firstAuthority = EventStoreSQLite(databaseURL: databaseURL, deviceID: "external-import-first")
        let firstService = makeImportService(
            store: failedAcknowledgementStore,
            captureService: captureService,
            commandExecutionRecords: InMemoryAmbitionsCommandExecutionRecordRepository(),
            authority: firstAuthority
        )
        let request = makeRequest(id: "sqlite-replay", text: "Replay safely", source: .appIntent)
        let commandID = "external.creation.command.sqlite-replay"
        let captureID = "capture.\(commandID)"

        try failedAcknowledgementStore.enqueueDurableRequest(request)
        let firstResult = await firstService.importPendingCreations(now: Date(timeIntervalSince1970: 1_712_692_800))
        XCTAssertEqual(try retryStore.pendingRequests(), [request])

        let replayRecords = InMemoryAmbitionsCommandExecutionRecordRepository()
        let replayAuthority = EventStoreSQLite(databaseURL: databaseURL, deviceID: "external-import-replay")
        let retryService = makeImportService(
            store: retryStore,
            captureService: captureService,
            commandExecutionRecords: replayRecords,
            authority: replayAuthority
        )
        let replayResult = await retryService.importPendingCreations(now: Date(timeIntervalSince1970: 1_712_692_860))
        let captures = try await repository.listCaptures()
        let commandEvents = try await replayAuthority.fetchEvents(matching: .commandID(commandID), limit: nil)
        let captureMutationCount = captureMutationCount(in: commandEvents)
        let replayRecord = try await replayRecords.fetchRecord(commandID: commandID)
        let authorityReceipt = try await replayAuthority.authorityReceipt(commandID: commandID)

        XCTAssertEqual(firstResult.importedCaptureIDs, [captureID])
        XCTAssertEqual(replayResult.importedCaptureIDs, [captureID])
        XCTAssertEqual(captures.map(\.id), [captureID])
        XCTAssertEqual(commandEvents.count, 2)
        XCTAssertEqual(captureMutationCount, 1)
        XCTAssertNotNil(authorityReceipt)
        XCTAssertEqual(
            replayRecord?.result?.metadata["runtimeTransactionDisposition"],
            RuntimeTransactionCommitDisposition.replayedExistingReceipt.rawValue
        )
        XCTAssertEqual(try retryStore.pendingRequests(), [])
    }

    func testSucceededImportWithoutCommittedEvidenceRemainsQueued() async throws {
        let store = SharedExternalCreationStore(baseURL: temporaryDirectory())
        let service = DefaultExternalCreationImportService(
            store: store,
            commandExecutor: UnverifiedSuccessExecutor()
        )
        let request = makeRequest(text: "Wait for committed evidence", source: .appIntent)

        try store.enqueueDurableRequest(request)

        let result = await service.importPendingCreations(now: Date(timeIntervalSince1970: 1_712_692_800))

        XCTAssertEqual(result.importedCaptureIDs, [])
        XCTAssertEqual(try store.pendingRequests(), [request])
    }

    func testDuplicateRowsExecuteAndReportOnceUsingFirstQueuedValue() async throws {
        let store = SharedExternalCreationStore(baseURL: temporaryDirectory())
        let repository = PreviewCaptureRepository()
        let captureService = DefaultCaptureService(repository: repository, idProvider: { "capture-replayed" })
        let commandRecords = InMemoryAmbitionsCommandExecutionRecordRepository()
        let commandJournal = InMemoryCommandJournal()
        let executor = AmbitionsCommandExecutor.test(
            captureService: captureService,
            commandExecutionRecords: commandRecords,
            commandJournal: commandJournal
        )
        let service = DefaultExternalCreationImportService(store: store, commandExecutor: executor)
        let first = makeRequest(text: "Use the first value", source: .appIntent)
        let duplicate = makeRequest(text: "Ignore the duplicate value", source: .shareExtensionText)

        try store.enqueueDurableRequest(first)
        try store.enqueueDurableRequest(duplicate)

        let result = await service.importPendingCreations(now: Date(timeIntervalSince1970: 1_712_692_800))
        let captures = try await repository.listCaptures()
        let entries = try await commandJournal.fetchEntries(matching: .all, limit: nil)
        let record = try await commandRecords.fetchRecord(commandID: "external.creation.command.external-request")

        XCTAssertEqual(result.importedCaptureIDs, ["capture.external.creation.command.external-request"])
        XCTAssertEqual(result.source, .appIntent)
        XCTAssertEqual(captures.map(\.id), ["capture.external.creation.command.external-request"])
        XCTAssertEqual(captures.map(\.rawText), ["Use the first value"])
        XCTAssertEqual(entries.count, 1)
        XCTAssertEqual(
            record?.result?.metadata["commandReceiptID"],
            "command.receipt.external.creation.command.external-request"
        )
        XCTAssertEqual(try store.pendingRequests(), [])
    }

    func testFailedAcknowledgementPropagatesAndLeavesCommittedRequestQueued() async throws {
        let root = temporaryDirectory()
        let fileManager = RemoveFailingFileManager()
        let store = SharedExternalCreationStore(fileManager: fileManager, baseURL: root)
        let repository = PreviewCaptureRepository()
        let captureService = DefaultCaptureService(repository: repository, idProvider: { "capture-awaiting-ack" })
        let executor = AmbitionsCommandExecutor.test(captureService: captureService)
        let service = DefaultExternalCreationImportService(store: store, commandExecutor: executor)
        let request = makeRequest(text: "Keep after ack failure", source: .appIntent)

        try store.enqueueDurableRequest(request)

        let result = await service.importPendingCreations(now: Date(timeIntervalSince1970: 1_712_692_800))

        XCTAssertEqual(result.importedCaptureIDs, ["capture.external.creation.command.external-request"])
        XCTAssertEqual(try store.pendingRequests(), [request])
        XCTAssertThrowsError(try store.acknowledge(requestIDs: [request.id]))
    }

    private func makeImportService(
        store: SharedExternalCreationStore,
        captureService: DefaultCaptureService,
        commandExecutionRecords: InMemoryAmbitionsCommandExecutionRecordRepository,
        authority: EventStoreSQLite
    ) -> DefaultExternalCreationImportService {
        DefaultExternalCreationImportService(
            store: store,
            commandExecutor: AmbitionsCommandExecutor.test(
                captureService: captureService,
                commandExecutionRecords: commandExecutionRecords,
                runtimeEvents: authority
            )
        )
    }

    private func captureMutationCount(in events: [RuntimeEventEnvelope]) -> Int {
        events.filter { envelope in
            guard case let .domainMutation(record) = envelope.event.payload,
                  let event = try? record.decodedEvent(),
                  case .captureCreated = event
            else { return false }
            return true
        }.count
    }

    private func makeRequest(
        id: String = "external-request",
        text: String,
        source: ExternalCreationSource,
        sourceApplication: String? = nil,
        sourceURL: String? = nil,
        landing: ExternalCreationLanding = .captureComposer
    ) -> ExternalCreationRequest {
        ExternalCreationRequest(
            id: id,
            createdAt: "2026-04-24T12:00:00Z",
            text: text,
            source: source,
            sourceApplication: sourceApplication,
            sourceURL: sourceURL,
            landing: landing
        )
    }

    private func temporaryDirectory() -> URL {
        FileManager.default.temporaryDirectory
            .appendingPathComponent("AmbitionsExternalCreationTests-\(UUID().uuidString)", isDirectory: true)
    }
}

private final class RemoveFailingFileManager: FileManager, @unchecked Sendable {
    override func removeItem(at URL: URL) throws {
        throw CocoaError(.fileWriteNoPermission)
    }
}

private struct UnverifiedSuccessExecutor: CommandExecuting {
    func validate(_ command: AmbitionsCommand) -> AmbitionsCommandValidationState {
        .valid
    }

    func execute(
        _ command: AmbitionsCommand,
        context: CommandExecutionContext
    ) async -> AmbitionsCommandExecutionResult {
        AmbitionsCommandExecutionResult(
            status: .succeeded,
            summary: "Unverified capture result",
            target: AmbitionsCommandTarget(captureID: "capture-unverified", destination: .captureInbox)
        )
    }
}
