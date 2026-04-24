import XCTest
@testable import Ambitions

@MainActor
final class ExternalCreationImportServiceTests: XCTestCase {
    func testSharedExternalCreationStoreAppendsAndDrainsRequests() throws {
        let store = SharedExternalCreationStore(baseURL: temporaryDirectory())
        let request = makeRequest(text: "Shared note", source: .shareExtensionText)

        try store.append(request)

        XCTAssertEqual(try store.peek(), [request])
        XCTAssertEqual(try store.drain(), [request])
        XCTAssertEqual(try store.peek(), [])
    }

    func testImportServiceCreatesNormalCapturesAndPreservesProvenanceHint() async throws {
        let store = SharedExternalCreationStore(baseURL: temporaryDirectory())
        let repository = PreviewCaptureRepository()
        let captureService = DefaultCaptureService(repository: repository, idProvider: { "capture-external" })
        let service = DefaultExternalCreationImportService(store: store, captureService: captureService)

        try store.append(
            makeRequest(
                text: "https://example.com/source",
                source: .shareExtensionURL,
                sourceApplication: "Safari",
                sourceURL: "https://example.com/source"
            )
        )

        let result = await service.importPendingCreations(now: Date(timeIntervalSince1970: 1_712_692_800))
        let captures = try await repository.listCaptures()

        XCTAssertEqual(result.importedCaptureIDs, ["capture-external"])
        XCTAssertEqual(result.preferredLanding, .capturesInbox)
        XCTAssertEqual(result.source, .shareExtensionURL)
        XCTAssertEqual(captures.first?.rawText, "https://example.com/source")
        XCTAssertEqual(captures.first?.sourceType, .shareExtensionURL)
        XCTAssertEqual(captures.first?.triage?.destination, .doSoon)
        XCTAssertEqual(captures.first?.triage?.hint, "From Safari: https://example.com/source")
    }

    func testImportServiceCanPreferCreateGoalLandingWithoutCreatingASeparateGoalPath() async throws {
        let store = SharedExternalCreationStore(baseURL: temporaryDirectory())
        let repository = PreviewCaptureRepository()
        let captureService = DefaultCaptureService(repository: repository, idProvider: { "capture-goal-seed" })
        let service = DefaultExternalCreationImportService(store: store, captureService: captureService)

        try store.append(
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
    }

    private func makeRequest(
        text: String,
        source: ExternalCreationSource,
        sourceApplication: String? = nil,
        sourceURL: String? = nil,
        landing: ExternalCreationLanding = .capturesInbox
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
