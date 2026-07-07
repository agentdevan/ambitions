import XCTest

@MainActor
extension AmbitionsUITestCase {
    func goalCreateButton(in app: XCUIApplication) -> XCUIElement {
        let candidates = [
            app.buttons["goals.capture-plus"],
            app.descendants(matching: .any)["goals.capture-plus"],
            app.buttons["Add goal"],
            app.buttons["goals.atlas-dock.create"],
            app.descendants(matching: .any)["goals.atlas-dock.create"],
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
            app.textFields["shell.activated-capture.input"],
            app.textViews["shell.activated-capture.input"],
            app.textFields["capture.quick-input"],
            app.textViews["capture.quick-input"],
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
            app.descendants(matching: .any)["shell.activated-capture-seam"],
            app.descendants(matching: .any)["shell.activated-capture.composer"],
            app.textFields["shell.activated-capture.input"],
            app.descendants(matching: .any)["capture.composer"],
            app.textFields["capture.quick-input"],
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
        let candidates = [
            app.buttons["goals.current-step.open"],
            app.descendants(matching: .any)["goals.current-step.open"],
            app.buttons["goals.hero.primary-action"],
            app.descendants(matching: .any)["goals.hero.primary-action"],
            app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "goals.surface.open.")).firstMatch,
            app.descendants(matching: .any).matching(NSPredicate(format: "identifier BEGINSWITH %@", "goals.surface.open.")).firstMatch
        ]

        for candidate in candidates where candidate.waitForExistence(timeout: 1) && candidate.isHittable {
            return candidate
        }

        for candidate in candidates where candidate.waitForExistence(timeout: 1) {
            return candidate
        }

        return app.descendants(matching: .any)["goals.current-step.open"]
    }

    func waitForGoalsPrimaryObject(in app: XCUIApplication, timeout: TimeInterval = 20) -> Bool {
        let candidates = [
            app.descendants(matching: .any)["goals.life-area-atlas.object"],
            app.descendants(matching: .any)["goals.life-area-atlas.title"],
            app.buttons["goals.capture-plus"],
            app.descendants(matching: .any)["goals.current-step.open"],
            app.descendants(matching: .any)["goals.mission-control-lanes"],
            app.descendants(matching: .any)["goals.life-path"],
            app.descendants(matching: .any)["goals.hero-card"]
        ]
        let deadline = Date().addingTimeInterval(timeout)

        while Date() < deadline {
            if candidates.contains(where: { $0.waitForExistence(timeout: 1) }) {
                return true
            }
            scrollPageUp(in: app)
        }

        return candidates.contains(where: { $0.exists })
    }

    func tapGoalsHeroPrimaryAction(in app: XCUIApplication) {
        let directCandidates = [
            goalsHeroPrimaryAction(in: app),
            app.buttons["goals.current-step.open"],
            app.descendants(matching: .any)["goals.current-step.open"],
            app.buttons["goals.hero-card"],
            app.descendants(matching: .any)["goals.hero-card"].firstMatch,
            app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "goals.surface.open.")).firstMatch,
            app.descendants(matching: .any).matching(NSPredicate(format: "identifier BEGINSWITH %@", "goals.surface.open.")).firstMatch
        ]

        for candidate in directCandidates where candidate.waitForExistence(timeout: 1) && candidate.isHittable {
            candidate.tap()
            return
        }

        let visibleAtlas = app.descendants(matching: .any)["goals.life-area-atlas.object"].firstMatch
        if visibleAtlas.waitForExistence(timeout: 2) {
            visibleAtlas.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.54)).tap()
            return
        }

        for _ in 0..<6 {
            for candidate in directCandidates where candidate.exists && candidate.isHittable {
                candidate.tap()
                return
            }
            scrollPageUp(in: app)
        }

        for candidate in directCandidates where candidate.exists {
            tapIfPossible(candidate)
            return
        }

        let atlas = app.descendants(matching: .any)["goals.life-area-atlas.object"]
        XCTAssertTrue(atlas.waitForExistence(timeout: 10))
        atlas.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
    }

    func tapFirstVisibleGoalCard(in app: XCUIApplication) {
        app.swipeUp()
        app.swipeUp()
        let cardCoordinate = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.45))
        cardCoordinate.tap()
    }
}
