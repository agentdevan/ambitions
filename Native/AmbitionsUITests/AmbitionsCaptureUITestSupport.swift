import XCTest

@MainActor
extension AmbitionsUITestCase {
    func shellCaptureInput(in app: XCUIApplication) -> XCUIElement {
        let candidates = [
            app.textFields["shell.activated-capture.input"],
            app.textViews["shell.activated-capture.input"],
            app.textFields["shell.overlay.quick-capture-field"],
            app.textViews["shell.overlay.quick-capture-field"],
            app.textFields["shell.command.capture-field"],
            app.textViews["shell.command.capture-field"],
            app.textFields["What needs to be remembered?"],
            app.textViews["What needs to be remembered?"],
            app.textFields.element(boundBy: 0),
            app.textViews.element(boundBy: 0)
        ]

        for candidate in candidates where candidate.waitForExistence(timeout: 2) {
            return candidate
        }

        return app.textFields["shell.overlay.quick-capture-field"]
    }

    func captureQuickInput(in app: XCUIApplication) -> XCUIElement {
        let candidates = [
            app.textFields["capture.quick-input"],
            app.textViews["capture.quick-input"],
            app.textFields["What needs a place?"],
            app.textViews["What needs a place?"]
        ]

        for candidate in candidates where candidate.waitForExistence(timeout: 2) {
            return candidate
        }

        return app.textFields["capture.quick-input"]
    }

    func tapCaptureNewGoal(in app: XCUIApplication, captureCard: XCUIElement) {
        let cardScopedButtons = captureCard.descendants(matching: .button)
            .matching(NSPredicate(format: "label == %@", "New goal"))
            .allElementsBoundByIndex
        if let control = cardScopedButtons.first(where: { $0.waitForExistence(timeout: 2) && $0.isEnabled && $0.isHittable }) {
            control.tap()
            return
        }

        let labeledButtons = app.buttons.matching(NSPredicate(format: "label == %@", "New goal")).allElementsBoundByIndex
        if let control = labeledButtons.first(where: { button in
            button.waitForExistence(timeout: 2)
                && button.identifier == "capture.new-goal.preview-capture-2"
                && button.isEnabled
                && button.isHittable
        }) {
            control.tap()
            return
        }

        captureCard.coordinate(withNormalizedOffset: CGVector(dx: 0.30, dy: 0.82)).tap()
    }
}
