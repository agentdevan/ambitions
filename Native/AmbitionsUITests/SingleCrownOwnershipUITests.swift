import XCTest

@MainActor
final class SingleCrownOwnershipUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testTimeDoesNotDuplicateShellAndObjectCrownOwnership() throws {
        let app = AmbitionsVisualAcceptanceApp.launchTime()

        XCTAssertTrue(app.descendants(matching: .any)["time.life-shape-field"].waitForExistence(timeout: 30))

        let shellCrown = app.descendants(matching: .any).matching(identifier: "shell.header.context-crown").count
        let objectCrown = app.descendants(matching: .any).matching(identifier: "time.life-shape-field.context-crown").count

        XCTAssertLessThanOrEqual(shellCrown + objectCrown, 1, "Time must have exactly one visible context crown owner.")
    }
}
