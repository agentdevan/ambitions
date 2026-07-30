import XCTest

@MainActor
final class YouNativeCalibrationD07HostUITests: XCTestCase {
    private struct ExpectedDomain {
        let id: String
        let title: String
        let summary: String
    }

    private lazy var app = XCUIApplication()

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    func testRootPreservesOrderedCurrentTruthAndOrdinaryFirstViewport() {
        launch("ync-d07-root-dark")

        let crown = element("ync-d07-crown")
        let identity = domain("identity-and-local-data")
        let personalization = domain("personalization")
        let privacy = domain("privacy-and-data")
        let appearance = domain("appearance")
        let notifications = domain("notifications-and-attention")
        assertExists([crown, identity, personalization, privacy, appearance, notifications])

        XCTAssertEqual(crown.label, "You")
        XCTAssertEqual(identity.label, "Identity & Local Data")
        XCTAssertEqual(identity.value as? String, "On this iPhone · No account")
        XCTAssertEqual(personalization.value as? String, "Today · Review every 7 days")
        XCTAssertEqual(privacy.value as? String, "Stored locally")
        XCTAssertEqual(appearance.value as? String, "System")
        XCTAssertEqual(notifications.value as? String, "Allowed")

        let ordered = [identity, personalization, privacy, appearance, notifications]
        for pair in zip(ordered, ordered.dropFirst()) {
            XCTAssertLessThan(pair.0.frame.minY, pair.1.frame.minY)
        }
        for row in ordered {
            XCTAssertGreaterThanOrEqual(row.frame.height, 44)
        }

        XCTAssertTrue(notifications.frame.intersects(appWindow.frame))
        XCTAssertGreaterThanOrEqual(
            domain("connections-and-permissions").frame.minY,
            appWindow.frame.maxY - 2
        )
        XCTAssertFalse(app.staticTexts["Controlled in iPhone Settings"].exists)
        XCTAssertFalse(app.staticTexts["Authorization owned by iOS"].exists)
        XCTAssertFalse(app.staticTexts["No Ambitions account"].exists)
    }

    func testAppearanceDepthAndFrameworkBackRestoreTheExactRootTarget() {
        launch("ync-d07-root-dark")

        let appearance = domain("appearance")
        XCTAssertTrue(appearance.waitForExistence(timeout: 6))
        let originatingFrame = appearance.frame
        appearance.tap()

        assertExists([
            element("ync-d07-appearance-depth"),
            element("ync-d07-appearance-current"),
            element("ync-d07-appearance-controls"),
            element("ync-d07-appearance-accent"),
            element("ync-d07-appearance-specimen")
        ])
        assertExists([
            app.buttons["System"],
            app.buttons["Light"],
            app.buttons["Dark"]
        ])
        XCTAssertTrue(app.navigationBars["Appearance"].exists)
        XCTAssertEqual(
            element("ync-d07-appearance-current").label,
            "Current appearance"
        )
        XCTAssertEqual(
            element("ync-d07-appearance-current").value as? String,
            "System. Matches your iPhone appearance."
        )
        XCTAssertEqual(
            element("ync-d07-appearance-accent").value as? String,
            "Violet–indigo, selected. Used for actions, not status."
        )

        let currentAppearance = element("ync-d07-appearance-current")
        let appearanceSelection = element("ync-d07-appearance-controls")
        let actionAccent = element("ync-d07-appearance-accent")
        let previewIdentity = element("ync-d07-appearance-preview-identity")
        let previewTruth = element("ync-d07-appearance-preview-truth")
        let previewAction = element("ync-d07-appearance-preview-action")
        assertExists([
            currentAppearance,
            appearanceSelection,
            actionAccent,
            previewIdentity,
            previewTruth,
            previewAction
        ])

        let orderedDepth = [
            currentAppearance,
            appearanceSelection,
            actionAccent,
            previewIdentity,
            previewTruth,
            previewAction
        ]
        for pair in zip(orderedDepth, orderedDepth.dropFirst()) {
            XCTAssertLessThan(pair.0.frame.minY, pair.1.frame.minY)
        }

        XCTAssertEqual(
            previewIdentity.label,
            "Start Here. Prepare for tomorrow’s appointment"
        )
        XCTAssertEqual(previewTruth.label, "Protected time · 30 min")
        XCTAssertEqual(previewAction.label, "Review")

        for forbiddenPhrase in [
            "Current truth",
            "Supported controls",
            "Controlled specimen",
            "fixture",
            "Visual-authority target",
            "Production enum unresolved",
            "proof",
            "architecture",
            "implementation"
        ] {
            assertNoAccessibleText(containing: forbiddenPhrase)
        }

        let back = app.navigationBars["Appearance"].buttons.firstMatch
        XCTAssertTrue(back.isHittable)
        back.tap()

        XCTAssertTrue(appearance.waitForExistence(timeout: 6))
        XCTAssertEqual(appearance.frame.minY, originatingFrame.minY, accuracy: 2)
        XCTAssertTrue((appearance.value as? String)?.contains("Return target") == true)
        XCTAssertTrue(element("ync-d07-root").exists)
    }

    func testAccessibilityRootKeepsAllDomainsAndCurrentTruthReachableInOrder() {
        launch("ync-d07-root-accessibility-dark")

        let expected: [ExpectedDomain] = [
            ExpectedDomain(
                id: "identity-and-local-data",
                title: "Identity & Local Data",
                summary: "On this iPhone · No account"
            ),
            ExpectedDomain(
                id: "personalization",
                title: "Personalization",
                summary: "Today · Review every 7 days"
            ),
            ExpectedDomain(
                id: "privacy-and-data",
                title: "Privacy & Data",
                summary: "Stored locally"
            ),
            ExpectedDomain(id: "appearance", title: "Appearance", summary: "System"),
            ExpectedDomain(
                id: "notifications-and-attention",
                title: "Notifications & Attention",
                summary: "Allowed"
            ),
            ExpectedDomain(
                id: "connections-and-permissions",
                title: "Connections & Permissions",
                summary: "Calendar and Reminders · Allowed"
            ),
            ExpectedDomain(
                id: "accessibility-and-interaction",
                title: "Accessibility & Interaction",
                summary: "Follows system settings"
            ),
            ExpectedDomain(
                id: "app-behavior",
                title: "App Behavior",
                summary: "Local defaults active"
            ),
            ExpectedDomain(
                id: "about-ambitions",
                title: "About Ambitions",
                summary: "Version and build"
            )
        ]

        var previousFrameMinimum: CGFloat?
        for entry in expected {
            let row = domain(entry.id)
            XCTAssertTrue(row.exists)
            XCTAssertEqual(row.label, entry.title)
            XCTAssertEqual(row.value as? String, entry.summary)
            XCTAssertGreaterThanOrEqual(row.frame.height, 44)
            if let previousFrameMinimum {
                XCTAssertGreaterThan(row.frame.minY, previousFrameMinimum)
            }
            previousFrameMinimum = row.frame.minY
        }

        for entry in expected {
            scrollUntilVisible(domain(entry.id))
        }
        XCTAssertTrue(domain("about-ambitions").frame.intersects(appWindow.frame))
    }

    private var appWindow: XCUIElement {
        app.windows.firstMatch
    }

    private func launch(_ variant: String) {
        app.launchArguments = ["-FoundryVariant", variant]
        app.launch()
    }

    private func domain(_ id: String) -> XCUIElement {
        element("ync-d07-domain-\(id)")
    }

    private func element(_ identifier: String) -> XCUIElement {
        app.descendants(matching: .any).matching(identifier: identifier).firstMatch
    }

    private func assertExists(
        _ elements: [XCUIElement],
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        for element in elements {
            XCTAssertTrue(
                element.waitForExistence(timeout: 6),
                "Missing accessibility element \(element)",
                file: file,
                line: line
            )
        }
    }

    private func assertNoAccessibleText(
        containing phrase: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let predicate = NSPredicate(
            format: "label CONTAINS[c] %@ OR value CONTAINS[c] %@",
            phrase,
            phrase
        )
        XCTAssertEqual(
            app.descendants(matching: .any).matching(predicate).count,
            0,
            "Unexpected product UI language containing \(phrase)",
            file: file,
            line: line
        )
    }

    private func scrollUntilVisible(_ target: XCUIElement, attempts: Int = 16) {
        var remaining = attempts
        while target.frame.intersects(appWindow.frame) == false, remaining > 0 {
            app.swipeUp()
            remaining -= 1
        }
        XCTAssertTrue(target.frame.intersects(appWindow.frame), "Element did not become visible: \(target)")
    }
}
