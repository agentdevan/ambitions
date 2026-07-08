import XCTest
import UIKit

@MainActor
final class DeterministicScreenshotLaneUITests: AmbitionsUITestCase {
    func testAMB1815TimeRootLightMScreenshotLane() throws {
        let appearance = DeterministicAppearanceCase.light
        let app = appearance.launchApplication(initialSurface: "time")

        XCTAssertTrue(
            app.descendants(matching: .any)["time.life-shape-field"].waitForExistence(timeout: 30),
            "time.life-shape-field must exist before screenshot capture."
        )

        let screen = XCUIScreen.main.screenshot()
        let screenshot = XCTAttachment(screenshot: screen)
        screenshot.name = "amb-1815-time-root-light-m-screenshot"
        screenshot.lifetime = .keepAlways
        add(screenshot)

        let luminance = assertScreenshotTone(screen, expected: .light, context: "Time root Light")
        let metadata = XCTAttachment(string: metadataJSON(
            id: "amb-1815-time-root-light-m",
            surface: "Time",
            appearance: appearance,
            expectedMode: .light,
            luminance: luminance,
            proofScope: "deterministic simulator screenshot lane; not Visual Green"
        ))
        metadata.name = "amb-1815-time-root-light-m-metadata"
        metadata.lifetime = .keepAlways
        add(metadata)
        app.terminate()
    }

    func testAMB1815AppearanceRootScreenshotMatrix() throws {
        var samples: [String: [String: Double]] = [:]

        for appearance in DeterministicAppearanceCase.allCases {
            let app = appearance.launchApplication(initialSurface: "today")
            XCTAssertTrue(waitForShellReady(in: app))
            dismissContinuityReceiptIfPresent(in: app, timeout: 1)

            for surface in DeterministicRootSurface.allCases {
                if surface.title == "Today" {
                    XCTAssertTrue(app.descendants(matching: .any)[surface.screenIdentifier].waitForExistence(timeout: 20))
                } else {
                    XCTAssertTrue(
                        openCanonicalDestination(surface.title, screenIdentifier: surface.screenIdentifier, in: app),
                        "\(surface.title) should open for \(appearance.id)."
                    )
                    XCTAssertTrue(waitForSelectedSurface(surface.title, in: app, timeout: 10))
                }
                dismissContinuityReceiptIfPresent(in: app, timeout: 1)

                let screen = XCUIScreen.main.screenshot()
                let screenshot = XCTAttachment(screenshot: screen)
                screenshot.name = "amb-1815-root-\(surface.id)-\(appearance.id)-screenshot"
                screenshot.lifetime = .keepAlways
                add(screenshot)

                let luminance = assertScreenshotTone(
                    screen,
                    expected: appearance.expectedMode,
                    context: "\(surface.title) root \(appearance.id)"
                )
                samples[surface.id, default: [:]][appearance.id] = luminance
                attachMetadata(
                    id: "amb-1815-root-\(surface.id)-\(appearance.id)",
                    surface: surface.title,
                    appearance: appearance,
                    luminance: luminance,
                    proofScope: "root appearance matrix; simulator proof only"
                )
            }

            app.terminate()
        }

        for surface in DeterministicRootSurface.allCases {
            assertAppearanceSeparation(samples[surface.id, default: [:]], context: surface.title)
        }
    }

    func testPacket31TodayProof() throws {
        var samples: [String: Double] = [:]

        for appearance in [DeterministicAppearanceCase.light, DeterministicAppearanceCase.dark] {
            let app = appearance.launchApplication(
                initialSurface: "today",
                extraEnvironment: ["AMBITIONS_PREVIEW_TODAY_SCENARIO": "start-here-ready"]
            )
            XCTAssertTrue(waitForShellReady(in: app))
            XCTAssertTrue(app.descendants(matching: .any)["today.screen"].waitForExistence(timeout: 20))
            XCTAssertTrue(app.descendants(matching: .any)["TodayRealityRailStartHereTitle"].waitForExistence(timeout: 20))
            let openStep = app.descendants(matching: .any)["TodayStartHereOpenStep"]
            XCTAssertTrue(openStep.waitForExistence(timeout: 20))
            XCTAssertTrue(accessibilityText(for: openStep).localizedCaseInsensitiveContains("Draft the talk outline"))
            XCTAssertTrue(app.descendants(matching: .any)["TodayRealityRailPrimaryAction"].waitForExistence(timeout: 20))
            XCTAssertTrue(app.descendants(matching: .any)["TodayStartHereSourceFreshness"].waitForExistence(timeout: 20))
            XCTAssertTrue(app.descendants(matching: .any)["TodayStartHereShowAnother"].waitForExistence(timeout: 20))
            XCTAssertTrue(app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", "Recommended step")).firstMatch.waitForExistence(timeout: 10))
            XCTAssertTrue(app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", "Draft the talk outline")).firstMatch.waitForExistence(timeout: 10))
            XCTAssertTrue(app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", "open window")).firstMatch.waitForExistence(timeout: 10))
            XCTAssertFalse(app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", "runtime summary truth")).firstMatch.exists)
            XCTAssertFalse(app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", "top layer")).firstMatch.exists)

            let dockFrame = rootDockFrame(in: app)
            XCTAssertFalse(dockFrame.isNull)
            XCTAssertLessThanOrEqual(
                app.descendants(matching: .any)["TodayRealityRailPrimaryAction"].frame.maxY,
                dockFrame.minY - 4,
                "Start Here primary action should clear the root dock in the first viewport."
            )
            XCTAssertLessThanOrEqual(
                app.descendants(matching: .any)["TodayStartHereShowAnother"].frame.maxY,
                dockFrame.minY - 4,
                "Start Here correction controls should clear the root dock in the first viewport."
            )

            let screen = XCUIScreen.main.screenshot()
            let screenshot = XCTAttachment(screenshot: screen)
            screenshot.name = "packet-3.1-today-start-here-\(appearance.id)-screenshot"
            screenshot.lifetime = .keepAlways
            add(screenshot)

            samples[appearance.id] = assertScreenshotTone(
                screen,
                expected: appearance.expectedMode,
                context: "Today Start Here \(appearance.id)"
            )
            attachMetadata(
                id: "packet-3.1-today-start-here-\(appearance.id)",
                surface: "Today",
                appearance: appearance,
                luminance: samples[appearance.id] ?? 0,
                proofScope: "Packet 3.1 seeded Start Here screenshot proof; simulator proof only"
            )
            app.terminate()
        }

        XCTAssertGreaterThan(
            samples[DeterministicAppearanceCase.light.id] ?? 0,
            (samples[DeterministicAppearanceCase.dark.id] ?? 0) + 0.18,
            "Seeded Today Start Here Light should be visually distinct from Dark."
        )
    }

    func testAMB1815AppearanceCoreOverlayScreenshotMatrix() throws {
        var samples: [String: [String: Double]] = [:]

        for overlay in DeterministicOverlaySurface.allCases {
            for appearance in DeterministicAppearanceCase.allCases {
                let app = appearance.launchApplication(launchURL: overlay.launchURL, initialSurface: "today")
                XCTAssertTrue(waitForShellReady(in: app))
                XCTAssertTrue(
                    app.descendants(matching: .any)[overlay.requiredElementIdentifier].waitForExistence(timeout: 20),
                    "\(overlay.title) should render for \(appearance.id)."
                )

                let screen = XCUIScreen.main.screenshot()
                let screenshot = XCTAttachment(screenshot: screen)
                screenshot.name = "amb-1815-overlay-\(overlay.id)-\(appearance.id)-screenshot"
                screenshot.lifetime = .keepAlways
                add(screenshot)

                let luminance = assertScreenshotTone(
                    screen,
                    expected: appearance.expectedMode,
                    context: "\(overlay.title) overlay \(appearance.id)"
                )
                samples[overlay.id, default: [:]][appearance.id] = luminance
                attachMetadata(
                    id: "amb-1815-overlay-\(overlay.id)-\(appearance.id)",
                    surface: overlay.title,
                    appearance: appearance,
                    luminance: luminance,
                    proofScope: "core overlay appearance matrix; simulator proof only"
                )
                app.terminate()
            }
        }

        for overlay in DeterministicOverlaySurface.allCases {
            assertAppearanceSeparation(samples[overlay.id, default: [:]], context: overlay.title)
        }
    }

    private func assertScreenshotTone(
        _ screenshot: XCUIScreenshot,
        expected mode: ExpectedAppearanceMode,
        context: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> Double {
        let luminance = ScreenshotLuminance.averageContentLuminance(of: screenshot)
        switch mode {
        case .light:
            XCTAssertGreaterThan(luminance, 0.42, "\(context) should render as light mode. luminance=\(luminance)", file: file, line: line)
        case .dark:
            XCTAssertLessThan(luminance, 0.40, "\(context) should render as dark mode. luminance=\(luminance)", file: file, line: line)
        }
        return luminance
    }

    private func assertAppearanceSeparation(
        _ samples: [String: Double],
        context: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        guard let light = samples[DeterministicAppearanceCase.light.id],
              let dark = samples[DeterministicAppearanceCase.dark.id],
              let systemLight = samples[DeterministicAppearanceCase.systemLight.id],
              let systemDark = samples[DeterministicAppearanceCase.systemDark.id] else {
            XCTFail("Missing appearance luminance samples for \(context).", file: file, line: line)
            return
        }

        XCTAssertGreaterThan(light, dark + 0.18, "\(context) Light should be visually distinct from Dark.", file: file, line: line)
        XCTAssertGreaterThan(systemLight, systemDark + 0.18, "\(context) System should follow OS light/dark.", file: file, line: line)
    }

    private func attachMetadata(
        id: String,
        surface: String,
        appearance: DeterministicAppearanceCase,
        luminance: Double,
        proofScope: String
    ) {
        let metadata = XCTAttachment(string: metadataJSON(
            id: id,
            surface: surface,
            appearance: appearance,
            expectedMode: appearance.expectedMode,
            luminance: luminance,
            proofScope: proofScope
        ))
        metadata.name = "\(id)-metadata"
        metadata.lifetime = .keepAlways
        add(metadata)
    }

    private func metadataJSON(
        id: String,
        surface: String,
        appearance: DeterministicAppearanceCase,
        expectedMode: ExpectedAppearanceMode,
        luminance: Double,
        proofScope: String
    ) -> String {
        """
        {
          "lane_id": "\(id)",
          "surface": "\(surface)",
          "app_appearance_preference": "\(appearance.appPreference)",
          "simulator_os_appearance": "\(appearance.systemStyle)",
          "debug_system_appearance_override": "\(appearance.systemStyle)",
          "expected_render_mode": "\(expectedMode.rawValue)",
          "content_size_category": "\(appearance.contentSizeCategory)",
          "average_content_luminance": "\(String(format: "%.4f", luminance))",
          "proof_scope": "\(proofScope)"
        }
        """
    }
}

private struct DeterministicAppearanceCase: Equatable {
    let id: String
    let appPreference: String
    let systemStyle: String
    let expectedMode: ExpectedAppearanceMode
    let contentSizeCategory = "UICTContentSizeCategoryM"

    static let light = DeterministicAppearanceCase(
        id: "light",
        appPreference: "light",
        systemStyle: "light",
        expectedMode: .light
    )
    static let dark = DeterministicAppearanceCase(
        id: "dark",
        appPreference: "dark",
        systemStyle: "dark",
        expectedMode: .dark
    )
    static let systemLight = DeterministicAppearanceCase(
        id: "system-light",
        appPreference: "system",
        systemStyle: "light",
        expectedMode: .light
    )
    static let systemDark = DeterministicAppearanceCase(
        id: "system-dark",
        appPreference: "system",
        systemStyle: "dark",
        expectedMode: .dark
    )

    static let allCases = [light, dark, systemLight, systemDark]

    @MainActor
    func launchApplication(
        launchURL: String? = nil,
        initialSurface: String,
        extraEnvironment: [String: String] = [:]
    ) -> XCUIApplication {
        let app = XCUIApplication()
        var keyValues = [
            "AMBITIONS_BOOTSTRAP_MODE": "preview",
            "AmbitionsAppearancePreference": appPreference,
            "AmbitionsInitialSurface": initialSurface,
            "AmbitionsScreenshotMode": "YES",
            "AmbitionsSystemAppearance": systemStyle,
            "AmbitionsTimeRenderState": "manual-only",
            "UIPreferredContentSizeCategoryName": contentSizeCategory,
            "uiuserinterfacestyle": systemStyle.capitalized,
            "AppleLocale": "en_US",
            "AppleLanguages": "(en)",
        ]
        if let launchURL {
            keyValues["AMBITIONS_LAUNCH_URL"] = launchURL
        }
        for (key, value) in extraEnvironment {
            keyValues[key] = value
        }

        for keyValue in keyValues.sorted(by: { $0.key < $1.key }) {
            app.launchEnvironment[keyValue.key] = keyValue.value
            app.launchArguments += ["-\(keyValue.key)", keyValue.value]
        }

        app.launch()
        dismissTransientReceiptIfPresent(in: app)
        return app
    }

    @MainActor
    private func dismissTransientReceiptIfPresent(in app: XCUIApplication) {
        let receiptDismiss = app.descendants(matching: .any)["action-closure-tray.dismiss-button"]
        if receiptDismiss.waitForExistence(timeout: 3) {
            receiptDismiss.tap()
        }
    }
}

private struct DeterministicRootSurface {
    let id: String
    let title: String
    let screenIdentifier: String

    static let allCases = [
        DeterministicRootSurface(id: "today", title: "Today", screenIdentifier: "today.screen"),
        DeterministicRootSurface(id: "goals", title: "Goals", screenIdentifier: "goals.screen"),
        DeterministicRootSurface(id: "time", title: "Time", screenIdentifier: "time.screen"),
        DeterministicRootSurface(id: "you", title: "You", screenIdentifier: "you.screen")
    ]
}

private struct DeterministicOverlaySurface {
    let id: String
    let title: String
    let launchURL: String
    let requiredElementIdentifier: String

    static let allCases = [
        DeterministicOverlaySurface(
            id: "capture",
            title: "Capture",
            launchURL: "ambitions://overlay/quiet-command-sheet?intent=quick_capture",
            requiredElementIdentifier: "shell.activated-capture-seam"
        ),
        DeterministicOverlaySurface(
            id: "search",
            title: "Search",
            launchURL: "ambitions://overlay/memory-lens?intent=memory_lens",
            requiredElementIdentifier: "shell.memory-lens.search-field"
        )
    ]
}

private enum ExpectedAppearanceMode: String {
    case light
    case dark
}

private enum ScreenshotLuminance {
    @MainActor
    static func averageContentLuminance(of screenshot: XCUIScreenshot) -> Double {
        guard let image = UIImage(data: screenshot.pngRepresentation),
              let cgImage = image.cgImage,
              let context = makeBitmapContext(width: 48, height: 80) else {
            return 0
        }

        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: 48, height: 80))
        guard let data = context.data else { return 0 }
        let bytes = data.bindMemory(to: UInt8.self, capacity: 48 * 80 * 4)
        var total = 0.0
        var count = 0.0

        for y in 14..<66 {
            for x in 3..<45 {
                let offset = ((y * 48) + x) * 4
                let red = Double(bytes[offset])
                let green = Double(bytes[offset + 1])
                let blue = Double(bytes[offset + 2])
                total += ((0.2126 * red) + (0.7152 * green) + (0.0722 * blue)) / 255.0
                count += 1
            }
        }

        return count == 0 ? 0 : total / count
    }

    private static func makeBitmapContext(width: Int, height: Int) -> CGContext? {
        CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width * 4,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )
    }
}
