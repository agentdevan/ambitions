import CryptoKit
import Foundation
import XCTest
import AmbitionsRuntimeSQLite
@testable import AmbitionsRuntimeTestSupport

final class RuntimeHistoricalStoreFixtureTests: XCTestCase {
    func testLoadsCallerSuppliedStoreByImmutableURLAndDigestWithoutMutation() async throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        let sourceURL = directory.appendingPathComponent("Historical.sqlite")
        let store = try RuntimeStoreSQLite(databaseURL: sourceURL)
        _ = try await store.snapshot()
        let before = try Data(contentsOf: sourceURL)
        let digest = SHA256.hash(data: before)
            .map { String(format: "%02x", $0) }
            .joined()

        let fixture = try RuntimeHistoricalStoreFixture.load(
            immutableURL: sourceURL,
            expectedDigest: digest
        )

        XCTAssertEqual(fixture.schemaVersion, 1)
        XCTAssertEqual(fixture.immutableURL, sourceURL)
        XCTAssertEqual(fixture.digest, digest)
        XCTAssertEqual(try Data(contentsOf: sourceURL), before)
    }

    func testRejectsCallerSuppliedStoreWhenDigestDoesNotMatch() async throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        let sourceURL = directory.appendingPathComponent("Historical.sqlite")
        let store = try RuntimeStoreSQLite(databaseURL: sourceURL)
        _ = try await store.snapshot()

        XCTAssertThrowsError(
            try RuntimeHistoricalStoreFixture.load(
                immutableURL: sourceURL,
                expectedDigest: String(repeating: "0", count: 64)
            )
        ) { error in
            guard case RuntimeHistoricalStoreFixtureError.digestMismatch = error else {
                return XCTFail("Unexpected error: \(error)")
            }
        }
    }
}
