import XCTest

@MainActor
extension AmbitionsUITestCase {
    func openTodayStepDetail(in app: XCUIApplication) -> Bool {
        let existingDetail = app.descendants(matching: .any)["TodayStepDetail"]
        if existingDetail.waitForExistence(timeout: 1) {
            return true
        }

        let normalOpenStep = normalTodayStepOpenControl(in: app)
        if normalOpenStep.waitForExistence(timeout: 5) {
            normalOpenStep.tap()
            if existingDetail.waitForExistence(timeout: 5) {
                return true
            }
        }

        let startHere = app.staticTexts["Start here"]
        if startHere.waitForExistence(timeout: 5) {
            startHere.tap()
            if existingDetail.waitForExistence(timeout: 5) {
                return true
            }
        }

        let stepTitle = app.descendants(matching: .any)["TodayRealityRailStepTitle"]
        if stepTitle.waitForExistence(timeout: 5) {
            stepTitle.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
            if existingDetail.waitForExistence(timeout: 5) {
                return true
            }
        }

        let whyThis = app.buttons["TodayStartHereSourceFreshness"]
        if whyThis.waitForExistence(timeout: 5) {
            whyThis.tap()
            if existingDetail.waitForExistence(timeout: 5) {
                return true
            }
        }

        let startHereSurface = app.buttons["TodayStartHereSurface"]
        if startHereSurface.waitForExistence(timeout: 5) {
            startHereSurface.tap()
            if existingDetail.waitForExistence(timeout: 5) {
                return true
            }
        }

        let startHereElement = app.descendants(matching: .any)["TodayStartHereSurface"]
        if startHereElement.waitForExistence(timeout: 5) {
            startHereElement.tap()
            if existingDetail.waitForExistence(timeout: 5) {
                return true
            }
        }

        let rail = app.descendants(matching: .any)["TodayRealityRail"]
        guard rail.waitForExistence(timeout: 5) else {
            return false
        }
        rail.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.24)).tap()
        return existingDetail.waitForExistence(timeout: 10)
    }

    func normalTodayStepOpenControl(in app: XCUIApplication) -> XCUIElement {
        let candidates = [
            app.buttons["TodayStartHereOpenStep"],
            app.descendants(matching: .any)["TodayStartHereOpenStep"]
        ]

        for candidate in candidates where candidate.waitForExistence(timeout: 2) {
            return candidate
        }

        return app.descendants(matching: .any)["TodayStartHereOpenStep"]
    }

    func normalTodayStepRowControl(in app: XCUIApplication) -> XCUIElement {
        let candidates = [
            app.buttons.matching(identifier: "TodayRealityRailRow").firstMatch,
            app.descendants(matching: .any)["TodayRealityRailRow"]
        ]

        for candidate in candidates where candidate.waitForExistence(timeout: 2) {
            return candidate
        }

        return app.descendants(matching: .any)["TodayRealityRailRow"]
    }

    func openTodayStepRowDetail(in app: XCUIApplication) -> Bool {
        let existingDetail = app.descendants(matching: .any)["TodayStepDetail"]
        if existingDetail.waitForExistence(timeout: 1) {
            return true
        }

        let stepRow = normalTodayStepRowControl(in: app)
        if stepRow.waitForExistence(timeout: 5) {
            stepRow.tap()
            return existingDetail.waitForExistence(timeout: 5)
        }

        return false
    }

    func todayPrimaryAction(in app: XCUIApplication) -> XCUIElement {
        let candidates = [
            app.buttons["TodayRealityRailPrimaryAction"],
            app.buttons["today.hero.primary-action"],
            app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "today.hero.primary-action.")).firstMatch,
            app.descendants(matching: .any)["TodayRealityRailPrimaryAction"],
            app.descendants(matching: .any)["today.hero.primary-action"]
        ]

        for candidate in candidates where candidate.waitForExistence(timeout: 2) {
            return candidate
        }

        return app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "today.hero.primary-action.")).firstMatch
    }

    func todayRealityMeridianAnchorExists(in app: XCUIApplication) -> Bool {
        let deadline = Date().addingTimeInterval(5)
        while Date() < deadline {
            if todayReadinessAnchors(in: app).contains(where: { $0.exists }) {
                return true
            }
            RunLoop.current.run(until: Date().addingTimeInterval(0.2))
        }

        return todayReadinessAnchors(in: app).contains(where: { $0.exists })
    }

    func waitForTodayScreenReady(in app: XCUIApplication, timeout: TimeInterval = 30) -> Bool {
        let deadline = Date().addingTimeInterval(timeout)

        while Date() < deadline {
            if todayReadinessAnchors(in: app).contains(where: { $0.exists }) {
                return true
            }
            RunLoop.current.run(until: Date().addingTimeInterval(0.2))
        }

        return todayReadinessAnchors(in: app).contains(where: { $0.exists })
    }

    func todayReadinessAnchors(in app: XCUIApplication) -> [XCUIElement] {
        [
            app.staticTexts["Start here"],
            app.staticTexts["On-device"],
            app.staticTexts["TodayRealityRailStartHereTitle"],
            app.staticTexts["TodayRealityRailStepTitle"],
            app.otherElements["TodayRealityRail"],
            app.buttons["TodayRealityRailPrimaryAction"]
        ]
    }
}
