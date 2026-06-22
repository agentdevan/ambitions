import XCTest

@MainActor
final class ProductObjectDominanceUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testTimeLifeShapeFieldPrimaryObjectDominatesFirstViewport() throws {
        let app = AmbitionsVisualAcceptanceApp.launchTime()
        let primaryObject = app.descendants(matching: .any)["time.life-shape-field.primary-object"]

        XCTAssertTrue(primaryObject.waitForExistence(timeout: 15))

        let firstViewportHeight = app.windows.firstMatch.frame.height
        XCTAssertGreaterThan(primaryObject.frame.minY, 0)
        XCTAssertLessThan(primaryObject.frame.minY, firstViewportHeight * 0.60)
        XCTAssertGreaterThanOrEqual(primaryObject.frame.height, firstViewportHeight * 0.45)
    }
}
