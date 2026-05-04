import AmbitionsDesignSystem
import XCTest

final class TopLevelSurfaceCompositionTests: XCTestCase {
    func testSI17CompositionKeepsFiveCanonicalSurfacesOnly() {
        XCTAssertEqual(
            AmbitionsTopLevelSurfaceComposition.allCases,
            [.today, .goals, .capture, .plan, .you]
        )

        XCTAssertEqual(
            AmbitionsTopLevelSurfaceComposition.allCases.map(\.title),
            ["Today", "Goals", "Capture", "Plan", "You"]
        )
    }

    func testSI17EachSurfaceHasOnePrimaryObjectAndSubordinateModules() {
        for surface in AmbitionsTopLevelSurfaceComposition.allCases {
            XCTAssertFalse(surface.primaryObject.isEmpty)
            XCTAssertFalse(surface.orientation.isEmpty)
            XCTAssertEqual(surface.supportingModules.count, 3)
            XCTAssertTrue(surface.accessibilitySummary.contains(surface.title))
            XCTAssertTrue(surface.accessibilitySummary.contains(surface.primaryObject))
        }
    }

    func testSI17CompositionAvoidsGenericSurfaceDrift() {
        let combined = AmbitionsTopLevelSurfaceComposition.allCases
            .map { "\($0.title) \($0.primaryObject) \($0.orientation) \($0.supportingModules.joined(separator: " "))" }
            .joined(separator: " ")

        XCTAssertFalse(combined.localizedCaseInsensitiveContains("dashboard"))
        XCTAssertFalse(combined.localizedCaseInsensitiveContains("chatbot"))
        XCTAssertFalse(combined.localizedCaseInsensitiveContains("project-management"))
        XCTAssertFalse(combined.localizedCaseInsensitiveContains("sixth destination"))
        XCTAssertFalse(combined.localizedCaseInsensitiveContains("hosted " + "AI"))
        XCTAssertFalse(combined.localizedCaseInsensitiveContains("production " + "AI"))
        XCTAssertFalse(combined.localizedCaseInsensitiveContains("backend " + "sync"))
        XCTAssertFalse(combined.localizedCaseInsensitiveContains("release " + "ready"))
    }

    func testSI17SurfaceLensesAndStatusExposeNonColorMeaning() {
        for surface in AmbitionsTopLevelSurfaceComposition.allCases {
            XCTAssertFalse(surface.lens.title.isEmpty)
            XCTAssertFalse(surface.lens.systemImage.isEmpty)
            XCTAssertFalse(surface.ambientStatus.title.isEmpty)
            XCTAssertFalse(surface.ambientStatus.systemImage.isEmpty)
        }
    }
}
