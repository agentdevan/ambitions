import XCTest
@testable import Ambitions

final class CaptureServiceTests: XCTestCase {
    func testCreateCaptureTrimsTextAndDefaultsToPending() async throws {
        let repository = PreviewCaptureRepository()
        let service = DefaultCaptureService(
            repository: repository,
            idProvider: { "capture-1" }
        )
        let now = Date(timeIntervalSince1970: 1_712_692_800)

        let created = try await service.createCapture(
            CreateCaptureRequest(
                rawText: "  Capture this idea  ",
                sourceType: .todayQuickCapture,
                linkedGoalID: "goal-123"
            ),
            now: now
        )
        let all = try await service.listCaptures()

        XCTAssertEqual(created.id, "capture-1")
        XCTAssertEqual(created.rawText, "Capture this idea")
        XCTAssertEqual(created.status, .pending)
        XCTAssertEqual(created.sourceType, .todayQuickCapture)
        XCTAssertEqual(created.linkedGoalID, "goal-123")
        XCTAssertEqual(all.count, 1)
    }

    func testMarkCaptureProcessedThenArchivedUpdatesStatus() async throws {
        let repository = PreviewCaptureRepository()
        let service = DefaultCaptureService(
            repository: repository,
            idProvider: { "capture-2" }
        )
        let createdAt = Date(timeIntervalSince1970: 1_712_692_800)
        let processedAt = Date(timeIntervalSince1970: 1_712_693_100)
        let archivedAt = Date(timeIntervalSince1970: 1_712_693_500)

        _ = try await service.createCapture(
            CreateCaptureRequest(rawText: "Ship intake model"),
            now: createdAt
        )
        let processed = try await service.markCaptureProcessed(id: "capture-2", now: processedAt)
        let archived = try await service.markCaptureArchived(id: "capture-2", now: archivedAt)

        XCTAssertEqual(processed?.status, .processed)
        XCTAssertEqual(archived?.status, .archived)
        XCTAssertNotEqual(processed?.updatedAt, archived?.updatedAt)
    }

    func testCreateCaptureRejectsWhitespaceOnlyText() async throws {
        let repository = PreviewCaptureRepository()
        let service = DefaultCaptureService(repository: repository, idProvider: { "capture-3" })

        await XCTAssertThrowsErrorAsync(
            try await service.createCapture(CreateCaptureRequest(rawText: "   "), now: .now)
        ) { error in
            XCTAssertEqual((error as? CaptureServiceError)?.errorDescription, "Capture text cannot be empty.")
        }
    }
}

private extension CaptureServiceTests {
    func XCTAssertThrowsErrorAsync<T>(
        _ expression: @autoclosure () async throws -> T,
        _ errorHandler: (Error) -> Void
    ) async {
        do {
            _ = try await expression()
            XCTFail("Expected error to be thrown.")
        } catch {
            errorHandler(error)
        }
    }
}
