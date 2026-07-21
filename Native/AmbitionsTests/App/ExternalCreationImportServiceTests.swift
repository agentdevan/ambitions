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

    func testIndependentStoresCoordinateInterleavedEnqueueAndAcknowledgement() throws {
        let root = temporaryDirectory()
        let appStore = SharedExternalCreationStore(baseURL: root)
        let extensionStore = SharedExternalCreationStore(baseURL: root)
        let first = makeRequest(id: "first", text: "From app", source: .appIntent)
        let second = makeRequest(id: "second", text: "From share", source: .shareExtensionText)

        try appStore.enqueueDurableRequest(first)
        XCTAssertEqual(try extensionStore.pendingRequests(), [first])

        try extensionStore.enqueueDurableRequest(second)
        try appStore.acknowledge(requestIDs: [first.id])

        XCTAssertEqual(try extensionStore.pendingRequests(), [second])
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
            record?.result.metadata["commandReceiptID"],
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

    func testReplayedSuccessIsAcknowledgedWithoutDoubleCapture() async throws {
        let root = temporaryDirectory()
        let failedAcknowledgementStore = SharedExternalCreationStore(
            fileManager: RemoveFailingFileManager(),
            baseURL: root
        )
        let retryStore = SharedExternalCreationStore(baseURL: root)
        let executor = ReplayAwareCreationExecutor()
        let firstService = DefaultExternalCreationImportService(
            store: failedAcknowledgementStore,
            commandExecutor: executor
        )
        let retryService = DefaultExternalCreationImportService(store: retryStore, commandExecutor: executor)
        let request = makeRequest(text: "Replay safely", source: .appIntent)

        try failedAcknowledgementStore.enqueueDurableRequest(request)
        let firstResult = await firstService.importPendingCreations(now: Date(timeIntervalSince1970: 1_712_692_800))
        XCTAssertEqual(try retryStore.pendingRequests(), [request])

        let replayResult = await retryService.importPendingCreations(now: Date(timeIntervalSince1970: 1_712_692_860))
        let counts = await executor.counts()

        XCTAssertEqual(firstResult.importedCaptureIDs, ["capture-replayed"])
        XCTAssertEqual(replayResult.importedCaptureIDs, ["capture-replayed"])
        XCTAssertEqual(counts.executions, 2)
        XCTAssertEqual(counts.captureMutations, 1)
        XCTAssertEqual(try retryStore.pendingRequests(), [])
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
            record?.result.metadata["commandReceiptID"],
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

private actor ReplayAwareCreationExecutor: CommandExecuting {
    private var executionCount = 0
    private var captureMutationCount = 0
    private var commandIDs: Set<String> = []

    nonisolated func validate(_ command: AmbitionsCommand) -> AmbitionsCommandValidationState {
        .valid
    }

    func execute(
        _ command: AmbitionsCommand,
        context: CommandExecutionContext
    ) async -> AmbitionsCommandExecutionResult {
        executionCount += 1
        let isReplay = commandIDs.insert(command.id).inserted == false
        if isReplay == false {
            captureMutationCount += 1
        }
        var metadata = Dictionary(
            uniqueKeysWithValues: RuntimeTransactionCommitPolicy.requiredEvidenceKeys.map { key in
                (key, "evidence.\(key)")
            }
        )
        metadata["runtimeTransactionDisposition"] = isReplay ? "replayed_existing_receipt" : "committed"
        metadata["replayDecision"] = isReplay ? LedgerReplayDecision.replayExistingReceipt.rawValue : "execute"

        return AmbitionsCommandExecutionResult(
            status: .succeeded,
            summary: isReplay ? "Replayed committed capture" : "Committed capture",
            target: AmbitionsCommandTarget(captureID: "capture-replayed", destination: .captureInbox),
            metadata: metadata
        )
    }

    func counts() -> (executions: Int, captureMutations: Int) {
        (executionCount, captureMutationCount)
    }
}
