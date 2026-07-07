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
}
