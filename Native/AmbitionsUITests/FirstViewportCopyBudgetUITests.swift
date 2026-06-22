import XCTest

@MainActor
final class FirstViewportCopyBudgetUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testTimeFirstViewportDoesNotExposeRootJargon() throws {
        let app = AmbitionsVisualAcceptanceApp.launchTime()
        XCTAssertTrue(app.descendants(matching: .any)["time.life-shape-field"].waitForExistence(timeout: 15))

        let labels = app.staticTexts.allElementsBoundByIndex
            .filter { $0.frame.minY < app.windows.firstMatch.frame.height }
            .map(\.label)

        for forbidden in ["ridge", "contour", "basin", "bridge", "lane", "seam", "trace", "pocket"] {
            XCTAssertFalse(
                labels.contains { $0.localizedCaseInsensitiveContains(forbidden) },
                "Root Time first viewport must not expose unapproved jargon: \(forbidden). Labels: \(labels)"
            )
        }
    }
}
