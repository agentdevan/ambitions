import XCTest
@testable import AmbitionsNativeVisualFoundry

final class YouNativeCalibrationJourneyStateTests: XCTestCase {
    func testAppearanceDepthUsesNativePathAndFrameworkBackRestoresTheRow() {
        var state = YouNativeCalibrationJourneyState()

        XCTAssertTrue(state.openAppearance())
        XCTAssertEqual(state.navigationPath, [.appearance])
        XCTAssertEqual(state.currentRoute, .appearance)

        state.restoreNavigationPath([])

        XCTAssertTrue(state.navigationPath.isEmpty)
        XCTAssertEqual(state.focusAnchor, .domain(.appearance))
        XCTAssertFalse(state.hasDurableMutation)
    }

    func testFixtureAppearanceSelectionIsPreviewOnly() {
        var state = YouNativeCalibrationJourneyState()

        XCTAssertTrue(state.selectAppearance(.light))
        XCTAssertEqual(state.previewAppearance, .light)
        XCTAssertFalse(state.hasDurableMutation)
        XCTAssertFalse(state.selectAppearance(.light))
    }

    func testDuplicateAppearanceRouteIsRejected() {
        var state = YouNativeCalibrationJourneyState()

        XCTAssertTrue(state.openAppearance())
        XCTAssertFalse(state.openAppearance())
        XCTAssertEqual(state.navigationPath, [.appearance])
    }
}
