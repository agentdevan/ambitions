import XCTest
import AmbitionsExternalContracts

final class ExternalSurfaceWireContractTests: XCTestCase {
    func testWireRawValuesRemainStable() throws {
        XCTAssertEqual(
            ExternalSurfaceKind.allCases.map(\.rawValue),
            ["notifications", "widgets", "live_activities", "app_intents", "shortcuts", "focus_filters"]
        )
        XCTAssertEqual(ExternalSurfacePayloadSurface.goalDetail.rawValue, "goal-detail")
        XCTAssertEqual(ExternalSurfacePayloadSurface.captureComposer.rawValue, "capture-composer")
        XCTAssertEqual(ExternalSurfaceActionName.askForSmallerStep.rawValue, "ask-for-smaller-step")
        XCTAssertEqual(ExternalSurfaceActionName.openMemoryLens.rawValue, "open-memory-lens")
        XCTAssertEqual(ExternalSurfacePrivacyDefault.detailsHidden.rawValue, "details_hidden")
        XCTAssertEqual(ExternalSurfacePrivacyDefault.minimalPayload.rawValue, "minimal_payload")
    }

    func testCodableCompatibilityUsesTheExistingPrivacySchema() throws {
        let payload = Data(
            #"{"defaultVisibility":"details_hidden","sensitiveDetailLabel":"Private","staleLabel":"Stale","unavailableLabel":"Unavailable"}"#.utf8
        )

        let policy = try JSONDecoder().decode(ExternalSurfacePrivacySnapshotPolicy.self, from: payload)
        XCTAssertEqual(policy.defaultVisibility, .detailsHidden)
        XCTAssertEqual(policy.sensitiveDetailLabel, "Private")
        XCTAssertEqual(policy.unavailableLabel, "Unavailable")
        XCTAssertEqual(policy.staleLabel, "Stale")

        let encoded = try JSONEncoder().encode(policy)
        XCTAssertEqual(
            try JSONSerialization.jsonObject(with: encoded) as? [String: String],
            try JSONSerialization.jsonObject(with: payload) as? [String: String]
        )
    }

    func testSafeDefaultKeepsSensitiveDetailsOutOfExternalSurfaces() {
        let policy = ExternalSurfacePrivacySnapshotPolicy.safeDefault

        XCTAssertEqual(policy.defaultVisibility, .detailsHidden)
        XCTAssertEqual(policy.sensitiveDetailLabel, "Details stay private until you open Ambitions.")
        XCTAssertEqual(policy.unavailableLabel, "Open Ambitions to confirm the latest local state.")
        XCTAssertEqual(policy.staleLabel, "This may be behind. Open Ambitions to refresh.")
    }

    func testLegacyActionAliasesKeepTheirExistingFallbackBehavior() {
        XCTAssertEqual(ExternalSurfaceActionName(rawAction: "smaller-step"), .askForSmallerStep)
        XCTAssertEqual(ExternalSurfaceActionName(rawAction: "memory-lens"), .openMemoryLens)
        XCTAssertEqual(ExternalSurfaceActionName(rawAction: "unknown-action"), .open)
    }
}
