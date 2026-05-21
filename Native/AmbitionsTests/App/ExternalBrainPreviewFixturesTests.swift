import XCTest
@testable import Ambitions

final class ExternalBrainPreviewFixturesTests: XCTestCase {
    func testEB35ExternalBrainScenarioLibraryCoversRequiredSurfacesAndProofBoundaries() {
        let scenarios = PreviewFixtures.default.externalBrainScenarios

        XCTAssertGreaterThanOrEqual(scenarios.count, 6)
        XCTAssertTrue(scenarios.contains { $0.surface == "Capture" })
        XCTAssertTrue(scenarios.contains { $0.surface == "What Ambitions knows" })
        XCTAssertTrue(scenarios.contains { $0.surface == "Shell command" })
        XCTAssertTrue(scenarios.contains { $0.surface == "You" })
        XCTAssertTrue(scenarios.contains { $0.surface == "Today / Time" })
        XCTAssertTrue(scenarios.contains { $0.memoryQuery == "safe context recall" })
        XCTAssertTrue(scenarios.contains { $0.memoryQuery == "Correction trail" })
        XCTAssertTrue(scenarios.contains { $0.commandIntent == .quickCapture })
        XCTAssertTrue(scenarios.contains { $0.commandIntent == .quickRecovery })
        XCTAssertTrue(scenarios.allSatisfy { !$0.privacyBoundary.isEmpty })
        XCTAssertTrue(scenarios.allSatisfy { !$0.accessibilityExpectation.isEmpty })
        XCTAssertTrue(scenarios.allSatisfy { !$0.yellowLimit.isEmpty })
        XCTAssertTrue(scenarios.allSatisfy { !$0.expectedEvidence.isEmpty })
    }

    func testEB35ScenarioLibraryDoesNotClaimScreenshotsOrDeviceProof() {
        let combined = PreviewFixtures.default.externalBrainScenarios
            .flatMap {
                [
                    $0.title,
                    $0.privacyBoundary,
                    $0.accessibilityExpectation,
                    $0.yellowLimit
                ] + $0.expectedEvidence
            }
            .joined(separator: " ")

        XCTAssertFalse(combined.localizedCaseInsensitiveContains("screenshot verified"))
        XCTAssertFalse(combined.localizedCaseInsensitiveContains("device verified"))
        XCTAssertFalse(combined.localizedCaseInsensitiveContains("VoiceOver verified"))
        XCTAssertFalse(combined.localizedCaseInsensitiveContains("production ready"))
        XCTAssertFalse(combined.localizedCaseInsensitiveContains("release ready"))
    }
}
