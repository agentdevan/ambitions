import XCTest

@MainActor
extension AmbitionsUITestCase {
    func goalCreateButton(in app: XCUIApplication) -> XCUIElement {
        let candidates = [
            goalsHeroPrimaryAction(in: app),
            app.buttons["goals.empty.create-goal"],
            app.buttons["goals.create-button"],
            app.buttons["shell.goals.create-button"],
            app.navigationBars.buttons["goals.create-button"],
            app.buttons["Create your first goal"],
            app.buttons["Create Goal"],
            app.navigationBars.buttons["Create Goal"]
        ]

        for candidate in candidates where candidate.waitForExistence(timeout: 2) {
            return candidate
        }

        return app.buttons["goals.create-button"]
    }

    func goalTitleInput(in app: XCUIApplication) -> XCUIElement {
        let candidates = [
            app.textFields["create-goal.title-field"],
            app.textViews["create-goal.title-field"],
            app.textFields["What do you want to make real?"],
            app.textViews["What do you want to make real?"],
            app.textFields.element(boundBy: 0),
            app.textViews.element(boundBy: 0)
        ]

        for candidate in candidates where candidate.waitForExistence(timeout: 2) {
            return candidate
        }

        return app.textFields["create-goal.title-field"]
    }

    func waitForClarificationCard(in app: XCUIApplication, timeout: TimeInterval = 12) -> Bool {
        let clarificationCard = app.descendants(matching: .any)["create-goal.clarification-card"]
        let deadline = Date().addingTimeInterval(timeout)

        while Date() < deadline {
            if clarificationCard.waitForExistence(timeout: 1) {
                return true
            }
            app.swipeUp()
        }

        return clarificationCard.exists
    }

    func waitForCreateGoalComposer(in app: XCUIApplication, timeout: TimeInterval = 10) -> Bool {
        let candidates = [
            app.descendants(matching: .any)["create-goal.hero-card"],
            app.navigationBars["Create Goal"],
            app.staticTexts["Strategy Composer"],
            app.textFields["create-goal.title-field"],
            app.textFields["What do you want to make real?"],
            app.buttons["Cancel"]
        ]

        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if candidates.contains(where: { $0.waitForExistence(timeout: 1) }) {
                return true
            }
        }

        return candidates.contains(where: { $0.exists })
    }

    func waitForCreatedGoalAcknowledgement(title: String, in app: XCUIApplication, timeout: TimeInterval = 30) -> Bool {
        let message = app.descendants(matching: .any)["goals.creation-message"]
        let titleText = app.staticTexts[title]
        let goalsScreen = app.descendants(matching: .any)["goals.screen"]
        let deadline = Date().addingTimeInterval(timeout)

        while Date() < deadline {
            if message.waitForExistence(timeout: 1) || titleText.exists {
                return true
            }
            if goalsScreen.exists {
                app.swipeUp()
            }
        }

        return message.exists || titleText.exists
    }

    func goalsHeroPrimaryAction(in app: XCUIApplication) -> XCUIElement {
        let button = app.buttons["goals.hero.primary-action"]
        if button.waitForExistence(timeout: 2) {
            return button
        }

        let fallback = app.descendants(matching: .any)["goals.hero.primary-action"]
        _ = fallback.waitForExistence(timeout: 2)
        return fallback
    }

    func waitForGoalsPrimaryObject(in app: XCUIApplication, timeout: TimeInterval = 20) -> Bool {
        let candidates = [
            app.descendants(matching: .any)["goals.constellation-atlas.stage"],
            app.descendants(matching: .any)["goals.constellation-atlas.object"],
            app.descendants(matching: .any)["goals.mission-control-lanes"],
            app.descendants(matching: .any)["goals.life-path"],
            app.descendants(matching: .any)["goals.hero-card"]
        ]
        let deadline = Date().addingTimeInterval(timeout)

        while Date() < deadline {
            if candidates.contains(where: { $0.waitForExistence(timeout: 1) }) {
                return true
            }
        }

        return candidates.contains(where: { $0.exists })
    }

    func openGoalsDirectionDepth(in app: XCUIApplication) -> Bool {
        if app.descendants(matching: .any)["goals.week-pressure"].waitForExistence(timeout: 1) {
            return true
        }

        let toggle = app.buttons["goals.direction-depth-toggle"]
        if toggle.waitForExistence(timeout: 2) {
            toggle.tap()
            return app.descendants(matching: .any)["goals.week-pressure"].waitForExistence(timeout: 5)
        }

        let title = app.staticTexts["Direction depth"]
        for _ in 0..<8 {
            if title.exists || title.waitForExistence(timeout: 0.25) {
                title.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
                return app.descendants(matching: .any)["goals.week-pressure"].waitForExistence(timeout: 5)
            }
            scrollPageUp(in: app)
        }

        return false
    }

    func openGoalsOrbitalLens(in app: XCUIApplication) -> Bool {
        if app.descendants(matching: .any)["goals.orbital-lens.expanded"].waitForExistence(timeout: 1) {
            return true
        }

        let toggle = app.buttons["goals.orbital-lens.toggle"]
        if toggle.waitForExistence(timeout: 2) {
            toggle.tap()
            return app.descendants(matching: .any)["goals.orbital-lens.expanded"].waitForExistence(timeout: 5)
        }

        let lens = app.descendants(matching: .any)["goals.orbital-lens.collapsed"]
        if lens.waitForExistence(timeout: 2) {
            lens.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.2)).tap()
            return app.descendants(matching: .any)["goals.orbital-lens.expanded"].waitForExistence(timeout: 5)
        }

        return false
    }

    func tapGoalsHeroPrimaryAction(in app: XCUIApplication) {
        let direct = goalsHeroPrimaryAction(in: app)
        if direct.exists && direct.isHittable {
            direct.tap()
            return
        }

        let heroButton = app.buttons["goals.hero-card"]
        if heroButton.waitForExistence(timeout: 10) {
            heroButton.tap()
            return
        }

        let heroCard = app.descendants(matching: .any)["goals.hero-card"].firstMatch
        XCTAssertTrue(heroCard.waitForExistence(timeout: 10))
        heroCard.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.82)).tap()
    }

    func tapFirstVisibleGoalCard(in app: XCUIApplication) {
        app.swipeUp()
        app.swipeUp()
        let cardCoordinate = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.45))
        cardCoordinate.tap()
    }
}
