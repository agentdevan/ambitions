import XCTest

extension TodayFlagshipCalibrationHostUITests {
    func testR13RootCrownAndDockPreserveLockedOwnership() {
        launch("tfcs-f01")

        let heading = element("tfcs-today-heading")
        let wordmark = element("tfcs-ambitions-wordmark")
        let peek = element("tfcs-dock-shell-peek")
        assertExists([heading, wordmark, peek])
        XCTAssertEqual(heading.label, "Today")
        XCTAssertEqual(wordmark.label, "Ambitions")
        XCTAssertFalse(app.buttons["Search"].exists)
        XCTAssertFalse(app.buttons["Capture"].exists)
        assertMinimumTarget(peek)
        XCTAssertEqual(peek.frame.width, 44, accuracy: 1)
        XCTAssertGreaterThanOrEqual(peek.frame.height, 44)

        peek.tap()
        let rootsGroup = element("tfcs-dock-roots-group")
        let globalsGroup = element("tfcs-dock-global-actions-group")
        let rootCommands = ["today", "goals", "time", "you"].map {
            element("tfcs-dock-\($0)")
        }
        let globalCommands = ["search", "capture"].map {
            element("tfcs-dock-\($0)")
        }
        assertExists([rootsGroup, globalsGroup] + rootCommands + globalCommands)
        XCTAssertEqual(rootCommands.map { $0.label }, ["Today", "Goals", "Time", "You"])
        XCTAssertEqual(globalCommands.map { $0.label }, ["Search", "Capture"])
        XCTAssertLessThan(rootCommands.last!.frame.maxY, globalCommands.first!.frame.minY)
        XCTAssertEqual(rootCommands.first!.value as? String, "Selected root")
        XCTAssertTrue(rootCommands.first!.isSelected)

        app.terminate()
        launch("tfcs-f06")
        XCTAssertFalse(element("tfcs-today-heading").exists)
        XCTAssertFalse(element("tfcs-dock-shell-peek").exists)
        XCTAssertFalse(element("tfcs-dock-expanded").exists)
    }

    func testR13ExpandedDockProvidesCompactHeightEscape() {
        XCUIDevice.shared.orientation = .landscapeLeft
        defer { XCUIDevice.shared.orientation = .portrait }
        launch("tfcs-f04")

        let expanded = element("tfcs-dock-expanded")
        let capture = element("tfcs-dock-capture")
        assertExists([expanded, capture])
        scrollUntilHittable(capture)
        XCTAssertTrue(capture.isHittable)
        assertMinimumTarget(capture)
        XCTAssertLessThanOrEqual(expanded.frame.height, app.frame.height + 1)
    }

    func testR13ReduceTransparencyUsesOpaqueDockAndAdaptivePassageRemainsAvailable() {
        launch("b02-root-reduce-transparency")

        let opaquePeek = element("tfcs-dock-shell-peek-opaque")
        assertExists([opaquePeek])
        assertMinimumTarget(opaquePeek)

        app.terminate()
        launch("b02-root-accessibility5")
        let passage = element("tfcs-adaptive-navigation-passage")
        assertExists([passage])
        XCTAssertFalse(element("tfcs-dock-shell-peek").exists)
        XCTAssertFalse(element("tfcs-dock-shell-peek-opaque").exists)
        for identifier in ["today", "goals", "time", "you", "search", "capture"] {
            let command = element("tfcs-navigation-\(identifier)")
            scrollUntilHittable(command)
            assertMinimumTarget(command)
        }
    }
}
