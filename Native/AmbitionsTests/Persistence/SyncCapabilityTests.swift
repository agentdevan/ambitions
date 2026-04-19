import XCTest
@testable import Ambitions

final class SyncCapabilityTests: XCTestCase {
    func testLocalOnlyCapabilityReportsOnlySupportedRuntimePosture() async throws {
        let capability = LocalOnlySyncCapability()

        let status = await capability.status()

        XCTAssertEqual(status.backendKind, .localOnly)
        XCTAssertEqual(status.trustPosture, .localOnly)
        XCTAssertEqual(status.availability, .unavailable)
        XCTAssertEqual(status.detail, "Ambitions is running in explicit local-only mode.")
    }
}
