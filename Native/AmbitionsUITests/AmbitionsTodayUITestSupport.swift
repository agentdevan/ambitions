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

        let startHere = app.descendants(matching: .any)["TodayRealityRailStartHereTitle"]
        if startHere.waitForExistence(timeout: 5) {
            tapIfPossible(startHere)
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
            app.descendants(matching: .any)["TodayStartHereOpenStep"],
            app.buttons["TodayRealityRailPrimaryAction"],
            app.descendants(matching: .any)["TodayRealityRailPrimaryAction"]
        ]

        for candidate in candidates where candidate.waitForExistence(timeout: 1) && candidate.isHittable {
            return candidate
        }

        for candidate in candidates where candidate.waitForExistence(timeout: 1) {
            return candidate
        }

        return app.descendants(matching: .any)["TodayStartHereOpenStep"]
    }

    func todayStepTitleElement(in app: XCUIApplication) -> XCUIElement {
        let candidates = [
            app.descendants(matching: .any)["TodayRealityRailStepTitle"],
            app.buttons["TodayStartHereOpenStep"],
            app.descendants(matching: .any)["TodayStartHereOpenStep"]
        ]

        for candidate in candidates where candidate.waitForExistence(timeout: 2) {
            return candidate
        }

        return app.descendants(matching: .any)["TodayRealityRailStepTitle"]
    }

    func todayStepTitleText(in app: XCUIApplication) -> String {
        accessibilityText(for: todayStepTitleElement(in: app))
    }

    func normalTodayStepRowControl(in app: XCUIApplication) -> XCUIElement {
        let candidates = [
            app.buttons.matching(identifier: "TodayRealityRailRow").firstMatch,
            app.descendants(matching: .any)["TodayRealityRailRow"],
            app.buttons["TodayRealityRailPrimaryAction"],
            app.descendants(matching: .any)["TodayRealityRailPrimaryAction"],
            app.buttons["TodayStartHereOpenStep"],
            app.descendants(matching: .any)["TodayStartHereOpenStep"]
        ]

        for candidate in candidates where candidate.waitForExistence(timeout: 1) && candidate.isHittable {
            return candidate
        }

        for candidate in candidates where candidate.waitForExistence(timeout: 1) {
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
            tapIfPossible(stepRow)
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

    func waitForTodayInlineReceipt(
        in app: XCUIApplication,
        title: String,
        bodyFragment: String? = nil,
        timeout: TimeInterval = 10
    ) -> Bool {
        let deadline = Date().addingTimeInterval(timeout)
        let receipt = app.descendants(matching: .any)["today.inline-message"]
        let titlePredicate = NSPredicate(format: "label CONTAINS[c] %@", title)

        while Date() < deadline {
            if receipt.exists {
                let receiptText = accessibilityText(for: receipt)
                let hasTitle = receiptText.localizedCaseInsensitiveContains(title)
                    || app.staticTexts.matching(titlePredicate).firstMatch.exists
                let hasBody = bodyFragment.map { receiptText.localizedCaseInsensitiveContains($0) } ?? true
                if hasTitle && hasBody {
                    return true
                }
            }

            if app.staticTexts.matching(titlePredicate).firstMatch.exists {
                if let bodyFragment {
                    let bodyPredicate = NSPredicate(format: "label CONTAINS[c] %@", bodyFragment)
                    if app.staticTexts.matching(bodyPredicate).firstMatch.exists {
                        return true
                    }
                } else {
                    return true
                }
            }

            RunLoop.current.run(until: Date().addingTimeInterval(0.2))
        }

        return false
    }

    func todayInlineReceiptDebugDescription(in app: XCUIApplication) -> String {
        let receipt = app.descendants(matching: .any)["today.inline-message"]
        let receiptText = receipt.exists ? accessibilityText(for: receipt) : ""
        let visibleText = app.staticTexts.allElementsBoundByIndex
            .prefix(24)
            .map { accessibilityText(for: $0) }
            .filter { $0.isEmpty == false }
            .joined(separator: " | ")
        return "receiptExists=\(receipt.exists); receiptText=\(receiptText); visibleText=\(visibleText)"
    }

    func todayReadinessAnchors(in app: XCUIApplication) -> [XCUIElement] {
        [
            app.descendants(matching: .any)["TodayRealityRailStartHereTitle"],
            app.descendants(matching: .any)["TodayRealityRailStepTitle"],
            app.descendants(matching: .any)["TodayStartHereSurface"],
            app.descendants(matching: .any)["TodayRealityRail"],
            app.buttons["TodayRealityRailPrimaryAction"],
            app.buttons["TodayStartHereOpenStep"]
        ]
    }
}
