import Foundation
import XCTest
import AmbitionsRuntimeTestSupport

final class GenericTestSupportTests: XCTestCase {
    func testTemporarySQLiteStoreOwnsAnExplicitDisposableDirectory() throws {
        let store = try TemporarySQLiteStore.create(fileName: "fixture.sqlite")
        XCTAssertTrue(
            FileManager.default.fileExists(atPath: store.directoryURL.path)
        )
        XCTAssertEqual(store.databaseURL.lastPathComponent, "fixture.sqlite")

        try store.remove()
        XCTAssertFalse(
            FileManager.default.fileExists(atPath: store.directoryURL.path)
        )
    }

    func testFaultInjectorFailsOnlyAtConfiguredOccurrenceWithSafeText() async throws {
        let token = FaultToken(rawValue: "private-test-token")
        let injector = DeterministicFaultInjector(
            failureOccurrences: [token: 2]
        )

        try await injector.checkpoint(token)
        do {
            try await injector.checkpoint(token)
            XCTFail("Expected the configured fault.")
        } catch let error as FaultInjectionError {
            XCTAssertEqual(error.token, token)
            XCTAssertFalse(error.description.contains(token.rawValue))
        }
        try await injector.checkpoint(token)

        let observationCount = await injector.observationCount(for: token)
        XCTAssertEqual(observationCount, 3)
    }
}
