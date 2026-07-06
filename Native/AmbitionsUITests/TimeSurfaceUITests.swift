import XCTest

@MainActor
final class TimeSurfaceUITests: AmbitionsUITestCase {
    func testDemoTimeWorkspaceShowsBatch49CoreModules() throws {
        let app = makeApp(bootstrapMode: "demo", launchURL: "ambitions://tab/time")
        app.launch()

        XCTAssertTrue(waitForSelectedTab("Time", in: app))
        dismissContinuityReceiptIfPresent(in: app)
        XCTAssertTrue(app.descendants(matching: .any)["time.screen"].waitForExistence(timeout: 15))
        XCTAssertTrue(app.descendants(matching: .any)["time.life-shape-field"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["LifeShape Field"].waitForExistence(timeout: 10))
    }

    func testAMB964TimeReconstructionScreenshotMatrix() throws {
        struct TimeMatrixItem {
            let name: String
            let renderState: String
            let contentSizeCategory: String
            let requiredIdentifiers: [String]
            let requiredTexts: [String]
        }

        let matrix: [TimeMatrixItem] = [
            TimeMatrixItem(
                name: "default-week",
                renderState: "default-week",
                contentSizeCategory: "UICTContentSizeCategoryM",
                requiredIdentifiers: [
                    "time.life-shape-field",
                    "time.life-shape-field.layer-selector",
                    "time.life-shape-field.visual-stage",
                    "time.life-shape-field.primary-action"
                ],
                requiredTexts: ["LifeShape Field", "This week", "Place Step"]
            ),
            TimeMatrixItem(
                name: "pressure-protected",
                renderState: "pressure-cluster",
                contentSizeCategory: "UICTContentSizeCategoryM",
                requiredIdentifiers: [
                    "time.life-shape-field.layer.protected",
                    "time.life-shape-field.horizon-strip",
                    "time.life-shape-field.visual-stage"
                ],
                requiredTexts: ["Protected", "Pressure"]
            ),
            TimeMatrixItem(
                name: "source-unavailable-manual",
                renderState: "manual-only",
                contentSizeCategory: "UICTContentSizeCategoryM",
                requiredIdentifiers: [
                    "shell.header.context-crown",
                    "time.life-shape-field",
                    "time.life-shape-field.primary-action"
                ],
                requiredTexts: ["LifeShape Field", "This week"]
            ),
            TimeMatrixItem(
                name: "static-equivalent",
                renderState: "calendar-denied",
                contentSizeCategory: "UICTContentSizeCategoryM",
                requiredIdentifiers: [
                    "time.life-shape-field",
                    "time.life-shape-field.visual-stage",
                    "time.life-shape-field.horizon-strip"
                ],
                requiredTexts: ["This week"]
            ),
            TimeMatrixItem(
                name: "large-dynamic-type",
                renderState: "pressure-cluster",
                contentSizeCategory: "UICTContentSizeCategoryAccessibilityXL",
                requiredIdentifiers: [
                    "time.life-shape-field",
                    "time.life-shape-field.visual-stage",
                    "time.life-shape-field.horizon-strip"
                ],
                requiredTexts: ["This week"]
            )
        ]

        func launchMatrixApp(for item: TimeMatrixItem) -> XCUIApplication {
            let app = makeApp(
                bootstrapMode: "demo",
                launchURL: "ambitions://tab/time",
                extraEnvironment: [
                    "AmbitionsTimeRenderState": item.renderState,
                    "AmbitionsScreenshotMode": "YES"
                ],
                contentSizeCategory: item.contentSizeCategory
            )
            app.launch()
            return app
        }

        for item in matrix {
            let app = launchMatrixApp(for: item)

            XCTAssertTrue(waitForSelectedTab("Time", in: app), "Time should be selected for \(item.name).")
            dismissContinuityReceiptIfPresent(in: app)
            XCTAssertTrue(app.descendants(matching: .any)["time.screen"].waitForExistence(timeout: 20), "Time screen should exist for \(item.name).")
            XCTAssertTrue(app.descendants(matching: .any)["time.life-shape-field"].waitForExistence(timeout: 10), "LifeShape Field should exist for \(item.name).")

            for identifier in item.requiredIdentifiers {
                XCTAssertTrue(
                    scrollUntilElementExists(identifier, in: app, maxAttempts: 10),
                    "\(identifier) should exist for \(item.name)."
                )
            }

            for text in item.requiredTexts {
                XCTAssertTrue(
                    scrollUntilStaticTextExists(text, in: app, maxAttempts: 10),
                    "Missing required AMB-964 copy '\(text)' in \(item.name)."
                )
            }

            XCTAssertFalse(app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", "KPI")).firstMatch.exists, "Time must not read as KPI dashboard for \(item.name).")
            XCTAssertFalse(app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", "dashboard")).firstMatch.exists, "Time must not read as a dashboard for \(item.name).")
            XCTAssertFalse(app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", "calendar grid")).firstMatch.exists, "Time must not become a calendar grid for \(item.name).")
            if item.name == "large-dynamic-type" {
                app.terminate()
                let screenshotApp = launchMatrixApp(for: item)
                XCTAssertTrue(waitForSelectedTab("Time", in: screenshotApp), "Time should be selected for \(item.name) screenshot proof.")
                dismissContinuityReceiptIfPresent(in: screenshotApp)
                XCTAssertTrue(screenshotApp.descendants(matching: .any)["time.life-shape-field"].waitForExistence(timeout: 10), "LifeShape Field should exist for \(item.name) screenshot proof.")
                captureTimeScreenshot(named: "amb-964-time-\(item.name)", in: screenshotApp)
                screenshotApp.terminate()
            } else {
                captureTimeScreenshot(named: "amb-964-time-\(item.name)", in: app)
                app.terminate()
            }
        }
    }

    func testDemoTimeLifeShapeLayerAndCorrectionControlsStayInteractive() throws {
        let app = makeApp(bootstrapMode: "demo", launchURL: "ambitions://tab/time")
        app.launch()

        XCTAssertTrue(waitForSelectedTab("Time", in: app))
        dismissContinuityReceiptIfPresent(in: app)
        XCTAssertTrue(app.descendants(matching: .any)["time.screen"].waitForExistence(timeout: 15))
        XCTAssertTrue(scrollUntilElementExists("time.life-shape-field.layer.protected", in: app, maxAttempts: 20))
        let protected = app.descendants(matching: .any)["time.life-shape-field.layer.protected"]
        XCTAssertTrue(protected.waitForExistence(timeout: 10))
        protected.tap()
        let protectedValue = protected.value as? String
        XCTAssertTrue(
            protected.isSelected || protectedValue?.localizedCaseInsensitiveContains("Selected") == true,
            "Protected layer should expose selected state after tap. Value: \(protectedValue ?? "<nil>")"
        )

        XCTAssertTrue(scrollUntilElementExists("time.life-shape-field.correction-menu", in: app, maxAttempts: 10))
        XCTAssertTrue(scrollUntilElementExists("time.life-shape-field.bucket-detail", in: app, maxAttempts: 10))
    }

    func testAMB1168TimeLifeShapeMutationAndUndoScreenshotProof() throws {
        let app = makeApp(
            bootstrapMode: "preview",
            launchURL: "ambitions://tab/time",
            extraEnvironment: [
                "AmbitionsScreenshotMode": "YES",
                "AMBITIONS_UI_PROTECTED_PLACEMENT_REVIEW": "1"
            ]
        )
        app.launch()

        XCTAssertTrue(waitForSelectedTab("Time", in: app))
        dismissContinuityReceiptIfPresent(in: app)
        XCTAssertTrue(app.descendants(matching: .any)["time.life-shape-field"].waitForExistence(timeout: 15))
        captureTimeScreenshot(named: "amb-1168-time-before-place-step", in: app)

        XCTAssertTrue(scrollUntilElementExists("time.life-shape-field.primary-action", in: app, maxAttempts: 10))
        app.descendants(matching: .any)["time.life-shape-field.primary-action"].tap()
        XCTAssertTrue(scrollUntilElementExists("protected-placement-review", in: app, maxAttempts: 10))
        XCTAssertTrue(app.descendants(matching: .any)["protected-placement-review.step"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.descendants(matching: .any)["protected-placement-review.current-placement"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.descendants(matching: .any)["protected-placement-review.proposed-placement"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.descendants(matching: .any)["protected-placement-review.priority"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.descendants(matching: .any)["Low"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.descendants(matching: .any)["Normal"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.descendants(matching: .any)["High"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.descendants(matching: .any)["protected-placement-review.move-it"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.descendants(matching: .any)["protected-placement-review.keep-as-is"].waitForExistence(timeout: 10))
        captureTimeScreenshot(named: "amb-1168-time-protected-placement-review", in: app)

        tapIfPossible(app.descendants(matching: .any)["protected-placement-review.keep-as-is"])
        XCTAssertTrue(app.descendants(matching: .any)["protected-placement-review.outcome"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["Kept as is"].waitForExistence(timeout: 10))
        XCTAssertFalse(app.staticTexts["Step placed"].exists)

        XCTAssertTrue(scrollUntilElementExists("time.life-shape-field.primary-action", in: app, maxAttempts: 10))
        app.descendants(matching: .any)["time.life-shape-field.primary-action"].tap()
        XCTAssertTrue(scrollUntilElementExists("protected-placement-review", in: app, maxAttempts: 10))
        tapIfPossible(app.descendants(matching: .any)["protected-placement-review.move-it"])
        XCTAssertTrue(scrollUntilElementExists("time.life-shape-field.mutation-proof", in: app, maxAttempts: 10))
        XCTAssertTrue(app.staticTexts["Step placed"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", "Today recomputed")).firstMatch.exists)
        captureTimeScreenshot(named: "amb-1168-time-after-place-step", in: app)

        XCTAssertTrue(app.descendants(matching: .any)["time.life-shape-field.undo"].waitForExistence(timeout: 10))
        app.descendants(matching: .any)["time.life-shape-field.undo"].tap()
        XCTAssertTrue(app.staticTexts["Undo applied"].waitForExistence(timeout: 10))
        captureTimeScreenshot(named: "amb-1168-time-after-undo", in: app)

        XCTAssertTrue(scrollUntilElementExists("time.life-shape-field.layer.protected", in: app, maxAttempts: 20))
        tapIfPossible(app.descendants(matching: .any)["time.life-shape-field.layer.protected"])
        XCTAssertTrue(scrollUntilElementExists("time.life-shape-field.primary-action", in: app, maxAttempts: 10))
        app.descendants(matching: .any)["time.life-shape-field.primary-action"].tap()
        XCTAssertTrue(scrollUntilElementExists("time.life-shape-field.mutation-proof", in: app, maxAttempts: 10))
        XCTAssertTrue(app.staticTexts["Window protected"].waitForExistence(timeout: 10))
        captureTimeScreenshot(named: "amb-1168-time-after-protect-window", in: app)
    }

    func testAMB1169TimeWhyThisInspectionStaysBehindDetailIntent() throws {
        let app = makeApp(
            bootstrapMode: "demo",
            launchURL: "ambitions://tab/time",
            extraEnvironment: ["AmbitionsScreenshotMode": "YES"]
        )
        app.launch()

        XCTAssertTrue(waitForSelectedTab("Time", in: app))
        dismissContinuityReceiptIfPresent(in: app)
        XCTAssertTrue(app.descendants(matching: .any)["time.life-shape-field"].waitForExistence(timeout: 15))
        XCTAssertFalse(app.staticTexts["Source: Calendar"].exists)
        XCTAssertFalse(app.staticTexts["Receipt: Current"].exists)
        XCTAssertFalse(app.staticTexts["Privacy posture: Local"].exists)
        captureTimeScreenshot(named: "amb-1169-time-root-clean", in: app)

        XCTAssertTrue(scrollUntilElementExists("time.life-shape-field.bucket-detail", in: app, maxAttempts: 12))
        XCTAssertTrue(scrollUntilElementExists("time.life-shape-field.why-this.button", in: app, maxAttempts: 8))
        app.descendants(matching: .any)["time.life-shape-field.why-this.button"].tap()
        XCTAssertTrue(app.descendants(matching: .any)["time.life-shape-field.why-this.reasons"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["This block is not protected."].waitForExistence(timeout: 10))
        captureTimeScreenshot(named: "amb-1169-time-bucket-detail-why-this", in: app)

        XCTAssertTrue(scrollUntilElementExists("time.life-shape-field.inspect-proof.button", in: app, maxAttempts: 8))
        app.descendants(matching: .any)["time.life-shape-field.inspect-proof.button"].tap()
        XCTAssertTrue(app.descendants(matching: .any)["time.life-shape-field.proof-inspection"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["Receipt is saved with this Time shape."].waitForExistence(timeout: 10))
        XCTAssertFalse(app.staticTexts["Runtime-backed projection"].exists)
        XCTAssertTrue(
            scrollLifeShapeProofLineIntoScreenshotBand("Receipt is saved with this Time shape.", in: app),
            "Proof receipt line should be visibly inside the screenshot proof band."
        )
        captureTimeScreenshot(named: "amb-1169-time-proof-inspection", in: app)
    }

    func testAMB1171PressureLayerMakeTodayLighterMutationProof() throws {
        let app = makeApp(
            bootstrapMode: "demo",
            launchURL: "ambitions://tab/time",
            extraEnvironment: ["AmbitionsScreenshotMode": "YES"]
        )
        app.launch()

        XCTAssertTrue(waitForSelectedTab("Time", in: app))
        dismissContinuityReceiptIfPresent(in: app)
        XCTAssertTrue(app.descendants(matching: .any)["time.life-shape-field"].waitForExistence(timeout: 15))
        XCTAssertTrue(scrollUntilElementExists("time.life-shape-field.layer.pressure", in: app, maxAttempts: 12))
        app.descendants(matching: .any)["time.life-shape-field.layer.pressure"].tap()
        XCTAssertTrue(scrollUntilStaticTextExists("Pressure", in: app, maxAttempts: 8))
        XCTAssertTrue(scrollUntilStaticTextExists("Make today lighter", in: app, maxAttempts: 8))
        XCTAssertFalse(app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", "82% pressure")).firstMatch.exists)
        XCTAssertFalse(app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", "poor productivity")).firstMatch.exists)
        captureTimeScreenshot(named: "amb-1171-pressure-root", in: app)

        XCTAssertTrue(scrollUntilElementExists("time.life-shape-field.primary-action", in: app, maxAttempts: 10))
        app.descendants(matching: .any)["time.life-shape-field.primary-action"].tap()
        XCTAssertTrue(scrollUntilElementExists("time.life-shape-field.mutation-proof", in: app, maxAttempts: 10))
        XCTAssertTrue(app.staticTexts["Today made lighter"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", "Today recomputed")).firstMatch.exists)
        XCTAssertTrue(app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", "Later Today updated")).firstMatch.exists)
        captureTimeScreenshot(named: "amb-1171-pressure-after-make-today-lighter", in: app)

        XCTAssertTrue(app.descendants(matching: .any)["time.life-shape-field.undo"].waitForExistence(timeout: 10))
        app.descendants(matching: .any)["time.life-shape-field.undo"].tap()
        XCTAssertTrue(app.staticTexts["Undo applied"].waitForExistence(timeout: 10))
        captureTimeScreenshot(named: "amb-1171-pressure-after-undo", in: app)

        XCTAssertTrue(openCanonicalDestination("Today", screenIdentifier: "today.screen", in: app))
        XCTAssertTrue(app.staticTexts["Start here"].waitForExistence(timeout: 10) || app.staticTexts["Start now"].waitForExistence(timeout: 10))
        captureTodayScreenshot(named: "amb-1171-today-after-pressure-mutation", in: app)
    }

    func testAMB1173BufferLayerAddBufferMutationProof() throws {
        let app = makeApp(
            bootstrapMode: "demo",
            launchURL: "ambitions://tab/time",
            extraEnvironment: ["AmbitionsScreenshotMode": "YES"]
        )
        app.launch()

        XCTAssertTrue(waitForSelectedTab("Time", in: app))
        dismissContinuityReceiptIfPresent(in: app)
        XCTAssertTrue(app.descendants(matching: .any)["time.life-shape-field"].waitForExistence(timeout: 15))
        XCTAssertTrue(scrollUntilElementExists("time.life-shape-field.layer.buffer", in: app, maxAttempts: 12))
        app.descendants(matching: .any)["time.life-shape-field.layer.buffer"].tap()
        XCTAssertTrue(scrollUntilStaticTextExists("Buffer", in: app, maxAttempts: 8))
        XCTAssertTrue(scrollUntilStaticTextExists("Add buffer", in: app, maxAttempts: 8))
        XCTAssertFalse(app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", "diagnosis")).firstMatch.exists)
        XCTAssertFalse(app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", "wellness")).firstMatch.exists)
        XCTAssertFalse(app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", "low-energy")).firstMatch.exists)
        captureTimeScreenshot(named: "amb-1173-buffer-root", in: app)

        XCTAssertTrue(scrollUntilElementExists("time.life-shape-field.primary-action", in: app, maxAttempts: 10))
        app.descendants(matching: .any)["time.life-shape-field.primary-action"].tap()
        XCTAssertTrue(scrollUntilElementExists("time.life-shape-field.mutation-proof", in: app, maxAttempts: 10))
        XCTAssertTrue(app.staticTexts["Buffer added"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", "Today recomputed")).firstMatch.exists)
        XCTAssertTrue(app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", "Current window updated")).firstMatch.exists)
        captureTimeScreenshot(named: "amb-1173-buffer-after-add-buffer", in: app)

        XCTAssertTrue(app.descendants(matching: .any)["time.life-shape-field.undo"].waitForExistence(timeout: 10))
        app.descendants(matching: .any)["time.life-shape-field.undo"].tap()
        XCTAssertTrue(app.staticTexts["Undo applied"].waitForExistence(timeout: 10))
        captureTimeScreenshot(named: "amb-1173-buffer-after-undo", in: app)

        XCTAssertTrue(openCanonicalDestination("Today", screenIdentifier: "today.screen", in: app))
        XCTAssertTrue(app.staticTexts["Start here"].waitForExistence(timeout: 10) || app.staticTexts["Start now"].waitForExistence(timeout: 10))
        captureTodayScreenshot(named: "amb-1173-today-after-buffer-mutation", in: app)
    }

    func testAMB1174TimeVisualFlagshipLayerScreenshotProof() throws {
        let app = makeApp(
            bootstrapMode: "demo",
            launchURL: "ambitions://tab/time",
            extraEnvironment: [
                "AmbitionsScreenshotMode": "YES",
                "AmbitionsTimeRenderState": "default-week"
            ]
        )
        app.launch()

        XCTAssertTrue(waitForSelectedTab("Time", in: app))
        dismissContinuityReceiptIfPresent(in: app)
        XCTAssertTrue(app.descendants(matching: .any)["time.life-shape-field"].waitForExistence(timeout: 15))
        XCTAssertTrue(app.descendants(matching: .any)["time.life-shape-field.layer-selector"].exists)
        XCTAssertTrue(app.descendants(matching: .any)["time.life-shape-field.visual-stage"].exists)
        XCTAssertTrue(app.descendants(matching: .any)["time.life-shape-field.primary-action"].exists)
        assertAMB1174VisualCopyGuards(in: app, variant: "open")
        captureTimeScreenshot(named: "amb-1174-time-open-root", in: app)

        let layers: [(identifier: String, title: String, screenshot: String)] = [
            ("time.life-shape-field.layer.protected", "Protected", "amb-1174-time-protected-root"),
            ("time.life-shape-field.layer.pressure", "Pressure", "amb-1174-time-pressure-root"),
            ("time.life-shape-field.layer.buffer", "Buffer", "amb-1174-time-buffer-root")
        ]

        for layer in layers {
            XCTAssertTrue(scrollUntilElementExists(layer.identifier, in: app, maxAttempts: 12))
            app.descendants(matching: .any)[layer.identifier].tap()
            XCTAssertTrue(scrollUntilStaticTextExists(layer.title, in: app, maxAttempts: 8))
            XCTAssertTrue(app.descendants(matching: .any)["time.life-shape-field.primary-action"].exists)
            assertAMB1174VisualCopyGuards(in: app, variant: layer.title)
            captureTimeScreenshot(named: layer.screenshot, in: app)
        }
    }

    func testAMB1174TimeVisualFlagshipAccessibilityVariantScreenshotProof() throws {
        let app = makeApp(
            bootstrapMode: "demo",
            launchURL: "ambitions://tab/time",
            extraEnvironment: [
                "AmbitionsScreenshotMode": "YES",
                "AmbitionsTimeRenderState": "pressure-cluster",
                "UIAccessibilityDarkerSystemColorsEnabled": "YES",
                "UIAccessibilityReduceTransparencyEnabled": "YES"
            ]
        )
        app.launch()

        XCTAssertTrue(waitForSelectedTab("Time", in: app))
        dismissContinuityReceiptIfPresent(in: app)
        XCTAssertTrue(app.descendants(matching: .any)["time.life-shape-field"].waitForExistence(timeout: 15))
        XCTAssertTrue(scrollUntilElementExists("time.life-shape-field.layer.pressure", in: app, maxAttempts: 12))
        app.descendants(matching: .any)["time.life-shape-field.layer.pressure"].tap()
        XCTAssertTrue(scrollUntilStaticTextExists("Pressure", in: app, maxAttempts: 8))
        XCTAssertTrue(app.descendants(matching: .any)["time.life-shape-field.primary-action"].exists)
        assertAMB1174VisualCopyGuards(in: app, variant: "accessibility")
        captureTimeScreenshot(named: "amb-1174-time-accessibility-variant", in: app)
    }

    func testAMB1175TimeRootDeletesOldReportAndFallbackClutter() throws {
        let app = makeApp(
            bootstrapMode: "demo",
            launchURL: "ambitions://tab/time",
            extraEnvironment: [
                "AmbitionsScreenshotMode": "YES",
                "AmbitionsTimeRenderState": "default-week"
            ]
        )
        app.launch()

        XCTAssertTrue(waitForSelectedTab("Time", in: app))
        dismissContinuityReceiptIfPresent(in: app)
        XCTAssertTrue(app.descendants(matching: .any)["time.life-shape-field"].waitForExistence(timeout: 15))
        XCTAssertTrue(app.descendants(matching: .any)["time.life-shape-field.layer-selector"].exists)
        XCTAssertTrue(app.descendants(matching: .any)["time.life-shape-field.visual-stage"].exists)
        XCTAssertTrue(app.descendants(matching: .any)["time.life-shape-field.primary-action"].exists)
        assertAMB1175OldTimeRootGuards(in: app)
        captureTimeScreenshot(named: "amb-1175-time-root-new-only", in: app)
    }

    func testAMB1176TimeEmptyAndAccessibilityProofPacket() throws {
        let emptyApp = makeApp(
            bootstrapMode: "preview",
            launchURL: "ambitions://tab/time",
            extraEnvironment: [
                "AmbitionsScreenshotMode": "YES",
                "AmbitionsTimeRenderState": "manual-only"
            ]
        )
        emptyApp.launch()

        XCTAssertTrue(waitForSelectedTab("Time", in: emptyApp))
        dismissContinuityReceiptIfPresent(in: emptyApp)
        XCTAssertTrue(emptyApp.descendants(matching: .any)["time.life-shape-field"].waitForExistence(timeout: 15))
        XCTAssertTrue(emptyApp.descendants(matching: .any)["time.life-shape-field.visual-stage"].exists)
        XCTAssertFalse(emptyApp.descendants(matching: .any)["time.empty.create-goal"].exists)
        XCTAssertFalse(emptyApp.descendants(matching: .any)["time.empty.open-captures"].exists)
        attachAMB1176AccessibilityTranscript(named: "amb-1176-empty-root-voiceover-transcript", in: emptyApp)
        captureTimeScreenshot(named: "amb-1176-time-empty-root", in: emptyApp)
        emptyApp.terminate()

        let accessibilityApp = makeApp(
            bootstrapMode: "demo",
            launchURL: "ambitions://tab/time",
            extraEnvironment: [
                "AmbitionsScreenshotMode": "YES",
                "AmbitionsTimeRenderState": "pressure-cluster",
                "UIAccessibilityReduceMotionEnabled": "YES",
                "UIAccessibilityReduceTransparencyEnabled": "YES",
                "UIAccessibilityDarkerSystemColorsEnabled": "YES"
            ],
            contentSizeCategory: "UICTContentSizeCategoryAccessibilityXXXL"
        )
        accessibilityApp.launch()

        XCTAssertTrue(waitForSelectedTab("Time", in: accessibilityApp))
        dismissContinuityReceiptIfPresent(in: accessibilityApp)
        XCTAssertTrue(accessibilityApp.descendants(matching: .any)["time.life-shape-field"].waitForExistence(timeout: 15))
        XCTAssertTrue(scrollUntilElementExists("time.life-shape-field.visual-stage", in: accessibilityApp, maxAttempts: 8))
        attachAMB1176AccessibilityTranscript(named: "amb-1176-accessibility-variant-voiceover-transcript", in: accessibilityApp)
        captureTimeScreenshot(named: "amb-1176-time-accessibility-xxxl-reduce-motion", in: accessibilityApp)
    }

    func testP1ERenderedTimeFoundationShowsProjectedFixedOpenAndScheduledStepSemantics() throws {
        let app = makeApp(
            bootstrapMode: "demo",
            launchURL: "ambitions://tab/time",
            extraEnvironment: [
                "AMBITIONS_UI_TIME_FOUNDATION_SEED": "1",
                "AmbitionsScreenshotMode": "YES"
            ]
        )
        app.launch()

        XCTAssertTrue(waitForSelectedTab("Time", in: app))
        dismissContinuityReceiptIfPresent(in: app)
        XCTAssertTrue(app.descendants(matching: .any)["time.screen"].waitForExistence(timeout: 15))
        XCTAssertTrue(app.descendants(matching: .any)["time.life-shape-field"].waitForExistence(timeout: 15))

        XCTAssertTrue(scrollUntilElementExists("time.calendar.now", in: app, maxAttempts: 10))
        XCTAssertTrue(scrollUntilElementExists("time.calendar.fixed-point", in: app, maxAttempts: 10))
        XCTAssertTrue(scrollUntilElementExists("time.calendar.open-window", in: app, maxAttempts: 10))
        XCTAssertTrue(scrollUntilElementExists("time.calendar.scheduled-step", in: app, maxAttempts: 10))

        let nowRow = app.descendants(matching: .any)["time.calendar.now"]
        let fixedRow = app.descendants(matching: .any)["time.calendar.fixed-point"]
        let openRow = app.descendants(matching: .any)["time.calendar.open-window"]
        let scheduledRow = app.descendants(matching: .any)["time.calendar.scheduled-step"]
        let nowText = accessibilityText(for: nowRow)
        let fixedText = accessibilityText(for: fixedRow)
        let openText = accessibilityText(for: openRow)
        let scheduledText = accessibilityText(for: scheduledRow)

        XCTAssertTrue(nowText.localizedCaseInsensitiveContains("Now"), nowText)
        XCTAssertTrue(fixedText.localizedCaseInsensitiveContains("fixed"), fixedText)
        XCTAssertTrue(openText.localizedCaseInsensitiveContains("open"), openText)
        XCTAssertTrue(scheduledText.localizedCaseInsensitiveContains("Scheduled"), scheduledText)
        XCTAssertTrue(scheduledText.localizedCaseInsensitiveContains("Mail the library card form"), scheduledText)
        XCTAssertFalse(scheduledText.localizedCaseInsensitiveContains("capture."))
        XCTAssertFalse(app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", "7 open days")).firstMatch.exists)
        XCTAssertFalse(app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", "AI recommends")).firstMatch.exists)
        XCTAssertFalse(app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", "optimized")).firstMatch.exists)

        captureTimeScreenshot(named: "p1e-rendered-time-foundation", in: app)
        app.terminate()

        let lowContextApp = makeApp(
            bootstrapMode: "preview",
            launchURL: "ambitions://tab/time",
            extraEnvironment: [
                "AmbitionsScreenshotMode": "YES"
            ]
        )
        lowContextApp.launch()

        XCTAssertTrue(waitForSelectedTab("Time", in: lowContextApp))
        dismissContinuityReceiptIfPresent(in: lowContextApp)
        XCTAssertTrue(lowContextApp.descendants(matching: .any)["time.life-shape-field"].waitForExistence(timeout: 15))
        XCTAssertTrue(scrollUntilElementExists("time.calendar.open-window", in: lowContextApp, maxAttempts: 10))
        let lowContextOpenRow = lowContextApp.descendants(matching: .any)["time.calendar.open-window"]
        let lowContextOpenText = accessibilityText(for: lowContextOpenRow)
        let lowContextScheduledText = accessibilityText(for: lowContextApp.descendants(matching: .any)["time.calendar.scheduled-step"])
        XCTAssertTrue(lowContextOpenText.localizedCaseInsensitiveContains("Low context"))
        XCTAssertTrue(lowContextOpenText.localizedCaseInsensitiveContains("local"))
        XCTAssertFalse(lowContextOpenText.localizedCaseInsensitiveContains("7 open days"))
        XCTAssertFalse(lowContextOpenText.localizedCaseInsensitiveContains("optimized"))
        XCTAssertFalse(lowContextScheduledText.localizedCaseInsensitiveContains("Mail the library card form"))
    }

    func testP1E1RenderedTimeFoundationPersistsAcrossLiveNoAccountRelaunch() throws {
        let seededApp = makeApp(
            bootstrapMode: "live",
            launchURL: "ambitions://tab/time",
            extraEnvironment: [
                "AMBITIONS_UI_TIME_FOUNDATION_SEED": "1",
                "AmbitionsScreenshotMode": "YES"
            ]
        )
        seededApp.launch()

        XCTAssertTrue(waitForSelectedTab("Time", in: seededApp))
        dismissContinuityReceiptIfPresent(in: seededApp)
        XCTAssertFalse(seededApp.descendants(matching: .any)["onboarding.screen"].exists)
        XCTAssertTrue(seededApp.descendants(matching: .any)["time.life-shape-field"].waitForExistence(timeout: 15))
        XCTAssertTrue(scrollUntilElementExists("time.calendar.scheduled-step", in: seededApp, maxAttempts: 10))
        let seededScheduledText = accessibilityText(for: seededApp.descendants(matching: .any)["time.calendar.scheduled-step"])
        XCTAssertTrue(seededScheduledText.localizedCaseInsensitiveContains("Scheduled"), seededScheduledText)
        XCTAssertTrue(seededScheduledText.localizedCaseInsensitiveContains("Mail the library card form"), seededScheduledText)
        seededApp.terminate()

        let reloadedApp = makeApp(
            bootstrapMode: "live",
            launchURL: "ambitions://tab/time",
            extraEnvironment: [
                "AmbitionsScreenshotMode": "YES"
            ]
        )
        reloadedApp.launch()

        XCTAssertTrue(waitForSelectedTab("Time", in: reloadedApp))
        dismissContinuityReceiptIfPresent(in: reloadedApp)
        XCTAssertFalse(reloadedApp.descendants(matching: .any)["onboarding.screen"].exists)
        XCTAssertTrue(reloadedApp.descendants(matching: .any)["time.life-shape-field"].waitForExistence(timeout: 15))
        XCTAssertTrue(scrollUntilElementExists("time.calendar.now", in: reloadedApp, maxAttempts: 10))
        XCTAssertTrue(scrollUntilElementExists("time.calendar.fixed-point", in: reloadedApp, maxAttempts: 10))
        XCTAssertTrue(scrollUntilElementExists("time.calendar.open-window", in: reloadedApp, maxAttempts: 10))
        XCTAssertTrue(scrollUntilElementExists("time.calendar.scheduled-step", in: reloadedApp, maxAttempts: 10))

        let fixedText = accessibilityText(for: reloadedApp.descendants(matching: .any)["time.calendar.fixed-point"])
        let openText = accessibilityText(for: reloadedApp.descendants(matching: .any)["time.calendar.open-window"])
        let scheduledText = accessibilityText(for: reloadedApp.descendants(matching: .any)["time.calendar.scheduled-step"])
        XCTAssertTrue(fixedText.localizedCaseInsensitiveContains("fixed"), fixedText)
        XCTAssertTrue(openText.localizedCaseInsensitiveContains("open"), openText)
        XCTAssertTrue(scheduledText.localizedCaseInsensitiveContains("Scheduled"), scheduledText)
        XCTAssertTrue(scheduledText.localizedCaseInsensitiveContains("Mail the library card form"), scheduledText)
        XCTAssertFalse(scheduledText.localizedCaseInsensitiveContains("capture."))
        XCTAssertFalse(reloadedApp.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", "Sign in")).firstMatch.exists)
        XCTAssertFalse(reloadedApp.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", "7 open days")).firstMatch.exists)
        XCTAssertFalse(reloadedApp.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", "AI recommends")).firstMatch.exists)
        XCTAssertFalse(reloadedApp.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", "optimized")).firstMatch.exists)

        captureTimeScreenshot(named: "p1e1-reload-backed-time-foundation", in: reloadedApp)
    }
}
