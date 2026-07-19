import XCTest
@testable import Ambitions

final class AppShellRouteMarkerTests: XCTestCase {
    func testRouteMarkerNormalizesTitleWithoutClaimingFinishedSurface() {
        let marker = AppShellRouteMarker(title: "Owned Route")

        XCTAssertEqual(marker.identifier, "shell.route-marker.owned-route")
        XCTAssertEqual(marker.statusText, "Temporary route marker")
        XCTAssertFalse(marker.isFinishedSurface)
    }

    func testRouteMarkerUsesUntitledFallbackForEmptyTitles() {
        let marker = AppShellRouteMarker(title: "   ")

        XCTAssertEqual(marker.identifier, "shell.route-marker.untitled")
        XCTAssertFalse(marker.isFinishedSurface)
    }
}
