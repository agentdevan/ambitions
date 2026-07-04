import XCTest
@testable import Ambitions

@MainActor
final class ExternalCreationImportServiceTests: XCTestCase {
    func testSharedExternalCreationStoreAppendsAndDrainsRequests() throws {
        let store = SharedExternalCreationStore(baseURL: temporaryDirectory())
        let request = makeRequest(text: "Shared note", source: .shareExtensionText)

        try store.enqueueDurableRequest(request)

        XCTAssertEqual(try store.peek(), [request])
        XCTAssertEqual(try store.drain(), [request])
        XCTAssertEqual(try store.peek(), [])
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
        let executor = AmbitionsCommandExecutor(
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
        let lookup = try await captureRouting.directLookupIndex.entry(captureID: "capture-external")

        XCTAssertEqual(result.importedCaptureIDs, ["capture-external"])
        XCTAssertEqual(result.preferredLanding, .captureComposer)
        XCTAssertEqual(result.source, .shareExtensionURL)
        XCTAssertEqual(captures.first?.rawText, "https://example.com/source")
        XCTAssertEqual(captures.first?.sourceType, .shareExtensionURL)
        XCTAssertEqual(captures.first?.triage?.destination, .doSoon)
        XCTAssertEqual(captures.first?.triage?.hint, "From Safari: https://example.com/source")
        XCTAssertEqual(intakeRecords.map(\.captureID), ["capture-external"])
        XCTAssertEqual(intakeRecords.first?.sourceType, .shareExtensionURL)
        XCTAssertEqual(lookup?.intakeRecordID, intakeRecords.first?.id)
        let entries = try await commandJournal.fetchEntries(matching: .all, limit: nil)
        XCTAssertEqual(entries.map(\.envelope.commandID), ["external.creation.command.external-request"])
        let record = try await commandRecords.fetchRecord(commandID: "external.creation.command.external-request")
        XCTAssertEqual(record?.result.metadata["commandReceiptID"], "command.receipt.external.creation.command.external-request")
    }

    func testImportServiceCanPreferCreateGoalLandingWithoutCreatingASeparateGoalPath() async throws {
        let store = SharedExternalCreationStore(baseURL: temporaryDirectory())
        let repository = PreviewCaptureRepository()
        let captureService = DefaultCaptureService(repository: repository, idProvider: { "capture-goal-seed" })
        let commandJournal = InMemoryCommandJournal()
        let executor = AmbitionsCommandExecutor(
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

        XCTAssertEqual(result.importedCaptureIDs, ["capture-goal-seed"])
        XCTAssertEqual(result.preferredLanding, .createGoal)
        XCTAssertEqual(result.source, .appIntent)
        XCTAssertEqual(captures.first?.sourceType, .appIntent)
        XCTAssertEqual(captures.first?.triage?.destination, .turnIntoGoal)
        let entries = try await commandJournal.fetchEntries(matching: .all, limit: nil)
        XCTAssertEqual(entries.first?.envelope.source, .appIntent)
        XCTAssertEqual(entries.first?.envelope.actor, .externalSurface)
    }

    func testImportServiceReplaysDuplicateExternalRequestIDsWithoutDoubleMutation() async throws {
        let store = SharedExternalCreationStore(baseURL: temporaryDirectory())
        let repository = PreviewCaptureRepository()
        let captureService = DefaultCaptureService(repository: repository, idProvider: { "capture-replayed" })
        let commandRecords = InMemoryAmbitionsCommandExecutionRecordRepository()
        let commandJournal = InMemoryCommandJournal()
        let executor = AmbitionsCommandExecutor(
            captureService: captureService,
            commandExecutionRecords: commandRecords,
            commandJournal: commandJournal
        )
        let service = DefaultExternalCreationImportService(store: store, commandExecutor: executor)
        let request = makeRequest(text: "Only import this once", source: .appIntent)

        try store.enqueueDurableRequest(request)
        try store.enqueueDurableRequest(request)

        let result = await service.importPendingCreations(now: Date(timeIntervalSince1970: 1_712_692_800))
        let captures = try await repository.listCaptures()
        let entries = try await commandJournal.fetchEntries(matching: .all, limit: nil)
        let record = try await commandRecords.fetchRecord(commandID: "external.creation.command.external-request")

        XCTAssertEqual(result.importedCaptureIDs, ["capture-replayed", "capture-replayed"])
        XCTAssertEqual(captures.map(\.id), ["capture-replayed"])
        XCTAssertEqual(entries.count, 1)
        XCTAssertEqual(record?.result.metadata["commandReceiptID"], "command.receipt.external.creation.command.external-request")
    }

    private func makeRequest(
        text: String,
        source: ExternalCreationSource,
        sourceApplication: String? = nil,
        sourceURL: String? = nil,
        landing: ExternalCreationLanding = .captureComposer
    ) -> ExternalCreationRequest {
        ExternalCreationRequest(
            id: "external-request",
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
