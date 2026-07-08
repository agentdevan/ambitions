import XCTest

@MainActor
extension AmbitionsUITestCase {
    func assertAMB1174VisualCopyGuards(
        in app: XCUIApplication,
        variant: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        for forbidden in ["Weather", "weather", "rain", "droplet", "scenic sky", "wallpaper", "82% pressure", "poor productivity", "diagnosis", "wellness"] {
            XCTAssertFalse(
                app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", forbidden)).firstMatch.exists,
                "AMB-1174 \(variant) must not expose forbidden copy: \(forbidden)",
                file: file,
                line: line
            )
        }
    }

    func assertAMB1175OldTimeRootGuards(
        in app: XCUIApplication,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        for identifier in [
            "time.empty.create-goal",
            "time.empty.open-captures",
            "time.life-shape-field.continuity-dock"
        ] {
            XCTAssertFalse(
                app.descendants(matching: .any)[identifier].exists,
                "AMB-1175 root Time must not expose old fallback identifier \(identifier)",
                file: file,
                line: line
            )
        }

        let staticTextLabels = app.staticTexts.allElementsBoundByIndex
            .map(\.label)
            .filter { $0.isEmpty == false }

        for forbidden in [
            "source unavailable",
            "receipt current",
            "review before reflow",
            "runtime-backed",
            "proof seam",
            "route reveal",
            "ready before change",
            "privacy posture",
            "2x2",
            "Week Shape",
            "Reflow preview",
            "Context stays together",
            "Create goal",
            "Open Capture"
        ] {
            let matchingLabels = staticTextLabels.filter { $0.localizedCaseInsensitiveContains(forbidden) }
            if matchingLabels.isEmpty == false {
                XCTFail(
                    "AMB-1175 root Time must not expose old card/report/fallback copy: \(forbidden). Matching labels: \(matchingLabels)",
                    file: file,
                    line: line
                )
            }
        }
    }

    func attachAMB1176AccessibilityTranscript(named name: String, in app: XCUIApplication) {
        let identifiers = [
            "time.life-shape-field",
            "time.life-shape-field.layer-selector",
            "time.life-shape-field.visual-stage",
            "time.life-shape-field.primary-action",
            "time.life-shape-field.horizon-strip"
        ]
        let lines = identifiers.map { identifier -> String in
            let element = app.descendants(matching: .any)[identifier]
            let label = element.label.trimmingCharacters(in: .whitespacesAndNewlines)
            let value = (element.value as? String)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let existence = element.exists ? "exists" : "missing"
            return [identifier, existence, label, value]
                .filter { $0.isEmpty == false }
                .joined(separator: " | ")
        }
        let transcript = ([
            "AMB-1176 accessibility transcript",
            "Source: XCUIElement label/value/hint tree from simulator proof run; manual VoiceOver audio was not produced by this automated test.",
            "Expected VoiceOver reading order focus: root Life Calendar, internal layer selector, visual field, primary action, horizon strip."
        ] + lines).joined(separator: "\n")
        let attachment = XCTAttachment(string: transcript)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    func assertTimeAccessibilityXXXLStackIsReadable(
        in app: XCUIApplication,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let identifiers = [
            "time.life-shape-field.accessibility-stage",
            "time.life-shape-field.accessibility-selected-layer",
            "time.life-shape-field.accessibility-segment.openTime",
            "time.life-shape-field.accessibility-segment.protectedTime",
            "time.life-shape-field.accessibility-segment.pressure",
            "time.life-shape-field.accessibility-primary-row"
        ]

        let elements = identifiers.map { app.descendants(matching: .any)[$0] }
        let window = app.windows.firstMatch
        XCTAssertTrue(window.waitForExistence(timeout: 10), file: file, line: line)
        let headerFrame = shellHeaderFrame(in: app)
        XCTAssertFalse(headerFrame.isNull, "Shell header frame should exist before Time Accessibility XXXL rendered validation.", file: file, line: line)
        let dockFrame = rootDockFrame(in: app)
        XCTAssertFalse(dockFrame.isNull, "Root dock frame should exist before Time Accessibility XXXL rendered validation.", file: file, line: line)

        for (identifier, element) in zip(identifiers, elements) {
            XCTAssertTrue(element.waitForExistence(timeout: 10), "\(identifier) should render in the Accessibility XXXL Time stack.", file: file, line: line)
            XCTAssertGreaterThan(element.frame.height, 12, "\(identifier) should have a readable rendered height.", file: file, line: line)
            XCTAssertGreaterThan(element.frame.width, 80, "\(identifier) should have readable rendered width.", file: file, line: line)
            assertFrame(element.frame, isInside: window.frame, named: "\(identifier) Accessibility XXXL frame", file: file, line: line)
            XCTAssertGreaterThanOrEqual(
                element.frame.minY,
                headerFrame.maxY + 4,
                "\(identifier) collides with shell header at Accessibility XXXL. element=\(element.frame) header=\(headerFrame)",
                file: file,
                line: line
            )
            XCTAssertLessThanOrEqual(
                element.frame.maxY,
                dockFrame.minY - 8,
                "\(identifier) collides with root dock at Accessibility XXXL. element=\(element.frame) dock=\(dockFrame)",
                file: file,
                line: line
            )
        }

        for index in 1..<(elements.count - 1) {
            let current = elements[index]
            let next = elements[index + 1]
            XCTAssertLessThanOrEqual(
                current.frame.maxY,
                next.frame.minY + 2,
                "\(identifiers[index]) overlaps \(identifiers[index + 1]) at Accessibility XXXL.",
                file: file,
                line: line
            )
        }
    }

    func scrollTimeContentToCapacityProof(in app: XCUIApplication) {
        let scrollView = app.scrollViews["time.content-scroll"]
        let target = app.descendants(matching: .any)["time.life-shape-field.capacity-statement"]

        for _ in 0..<12 {
            if target.exists, target.frame.minY > 120, target.frame.maxY < 620 {
                return
            }
            if scrollView.exists {
                scrollView.swipeUp(velocity: .slow)
            } else {
                app.swipeUp(velocity: .slow)
            }
        }
    }

    func scrollLifeShapeBucketDetailIntoScreenshotBand(in app: XCUIApplication) -> Bool {
        let scrollView = app.scrollViews["time.content-scroll"]
        let target = app.descendants(matching: .any)["time.life-shape-field.bucket-detail"]
        let screenshotBand = CGRect(x: 0, y: 180, width: 1_000, height: 560)

        for _ in 0..<12 {
            if target.exists, target.frame.intersects(screenshotBand), target.frame.maxY < 760 {
                return true
            }
            if scrollView.exists {
                scrollView.swipeUp(velocity: .slow)
            } else {
                app.swipeUp(velocity: .slow)
            }
        }

        return target.exists && target.frame.intersects(screenshotBand)
    }

    func scrollLifeShapeProofLineIntoScreenshotBand(_ label: String, in app: XCUIApplication) -> Bool {
        let scrollView = app.scrollViews["time.content-scroll"]
        let target = app.staticTexts[label]
        let screenshotBand = CGRect(x: 0, y: 220, width: 1_000, height: 460)

        for _ in 0..<8 {
            if target.exists, target.frame.intersects(screenshotBand), target.frame.maxY < 720 {
                return true
            }
            if scrollView.exists {
                scrollView.swipeUp(velocity: .slow)
            } else {
                app.swipeUp(velocity: .slow)
            }
        }

        return target.exists && target.frame.intersects(screenshotBand)
    }

    func assertPacket36TimeMutationProofIsInspectableAndClear(
        in app: XCUIApplication,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let proof = app.descendants(matching: .any)["time.life-shape-field.mutation-proof"]
        let source = app.descendants(matching: .any)["time.life-shape-field.mutation-proof.source"]
        let proofLine = app.descendants(matching: .any)["time.life-shape-field.mutation-proof.proof"]
        let history = app.descendants(matching: .any)["time.life-shape-field.mutation-proof.history"]
        let privacy = app.descendants(matching: .any)["time.life-shape-field.mutation-proof.privacy"]

        XCTAssertTrue(proof.waitForExistence(timeout: 10), "Time mutation proof should render as an inline receipt.", file: file, line: line)
        XCTAssertTrue(source.waitForExistence(timeout: 10), "Time mutation proof should expose source.", file: file, line: line)
        XCTAssertTrue(proofLine.waitForExistence(timeout: 10), "Time mutation proof should expose proof.", file: file, line: line)
        XCTAssertTrue(history.waitForExistence(timeout: 10), "Time mutation proof should expose history.", file: file, line: line)
        XCTAssertTrue(privacy.waitForExistence(timeout: 10), "Time mutation proof should expose privacy.", file: file, line: line)

        let receiptText = accessibilityText(for: proof)
        XCTAssertTrue(receiptText.localizedCaseInsensitiveContains("Local Time action"), receiptText, file: file, line: line)
        XCTAssertTrue(receiptText.localizedCaseInsensitiveContains("Saved on this iPhone"), receiptText, file: file, line: line)
        XCTAssertTrue(
            receiptText.localizedCaseInsensitiveContains("Today recomputed") ||
                receiptText.localizedCaseInsensitiveContains("Undo applied"),
            receiptText,
            file: file,
            line: line
        )
        XCTAssertFalse(app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", "runtime-backed")).firstMatch.exists, file: file, line: line)
        XCTAssertFalse(app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", "proof seam")).firstMatch.exists, file: file, line: line)
        XCTAssertFalse(app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", "AI recommends")).firstMatch.exists, file: file, line: line)

        let headerFrame = shellHeaderFrame(in: app)
        let layerSelector = app.descendants(matching: .any)["time.life-shape-field.layer-selector"]
        XCTAssertFalse(headerFrame.isNull, "Shell header frame should exist before receipt collision validation.", file: file, line: line)
        XCTAssertFalse(
            proof.frame.intersects(headerFrame),
            "Inline Time receipt intersects shell header. proof=\(proof.frame) header=\(headerFrame)",
            file: file,
            line: line
        )
        if layerSelector.exists {
            XCTAssertFalse(
                proof.frame.intersects(layerSelector.frame),
                "Inline Time receipt intersects layer controls. proof=\(proof.frame) selector=\(layerSelector.frame)",
                file: file,
                line: line
            )
        }
    }

    func assertPacket36ProtectedPlacementReviewDepthExists(
        in app: XCUIApplication,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        for identifier in [
            "protected-placement-review.step",
            "protected-placement-review.current-placement",
            "protected-placement-review.proposed-placement",
            "protected-placement-review.protection",
            "protected-placement-review.receipt",
            "protected-placement-review.privacy",
            "protected-placement-review.priority",
            "protected-placement-review.move-it",
            "protected-placement-review.keep-as-is"
        ] {
            XCTAssertTrue(
                app.descendants(matching: .any)[identifier].waitForExistence(timeout: 10),
                "\(identifier) should render in the Packet 3.6 placement review.",
                file: file,
                line: line
            )
        }
        XCTAssertTrue(app.descendants(matching: .any)["Low"].waitForExistence(timeout: 10), file: file, line: line)
        XCTAssertTrue(app.descendants(matching: .any)["Normal"].waitForExistence(timeout: 10), file: file, line: line)
        XCTAssertTrue(app.descendants(matching: .any)["High"].waitForExistence(timeout: 10), file: file, line: line)
    }

    func scrollPacket36ProtectedPlacementReviewIntoScreenshotBand(in app: XCUIApplication) -> Bool {
        let scrollView = app.scrollViews["time.content-scroll"]
        let card = app.descendants(matching: .any)["protected-placement-review"]
        let receipt = app.descendants(matching: .any)["protected-placement-review.receipt"]
        let screenshotBand = CGRect(x: 0, y: 170, width: 1_000, height: 760)

        for _ in 0..<12 {
            if card.exists,
               card.frame.intersects(screenshotBand),
               card.frame.minY >= 130,
               receipt.exists,
               receipt.frame.intersects(screenshotBand) {
                return true
            }

            if scrollView.exists {
                scrollView.swipeUp(velocity: .slow)
            } else {
                app.swipeUp(velocity: .slow)
            }
        }

        return card.exists && card.frame.intersects(screenshotBand)
    }
}
