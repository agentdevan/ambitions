@testable import Ambitions
import XCTest

final class AppShellDebugLaunchConfigurationTests: XCTestCase {
    @MainActor
    func testDefaultsRespectCanonicalInitialSurfaceOnly() {
        let bootstrapper = AppBootstrapper()

        XCTAssertNil(bootstrapper.debugLaunchConfiguration().initialSurface)
        XCTAssertFalse(bootstrapper.debugLaunchConfiguration().screenshotModeEnabled)
    }

    @MainActor
    func testParsesAllowedInitialSurfaceArguments() {
        let bootstrapper = AppBootstrapper()

        let expected: [(String, AmbitionsSurface)] = [
            ("today", .today),
            ("goals", .goals),
            ("time", .time),
            ("you", .you)
        ]

        for (surface, tab) in expected {
            let configuration = bootstrapper.debugLaunchConfiguration(arguments: ["Ambitions", "-AmbitionsInitialSurface", surface])

            XCTAssertEqual(configuration.initialSurface, tab)
            XCTAssertFalse(configuration.screenshotModeEnabled)
        }
    }

    @MainActor
    func testRejectsInvalidOrLegacyInitialSurfaceArguments() {
        let bootstrapper = AppBootstrapper()
        let invalidValues = ["capture", "pulse", "plan", "habits", "insights", "review", "profile", "unknown"]

        for value in invalidValues {
            let configuration = bootstrapper.debugLaunchConfiguration(arguments: ["Ambitions", "-AmbitionsInitialSurface", value])

            XCTAssertNil(configuration.initialSurface, "Legacy or invalid value '\(value)' must not map to top-level launch targets.")
            XCTAssertFalse(configuration.screenshotModeEnabled)
        }
    }

    @MainActor
    func testIgnoresEnvironmentValues() {
        let bootstrapper = AppBootstrapper()

        let configuration = bootstrapper.debugLaunchConfiguration(arguments: ["Ambitions"])

        XCTAssertNil(configuration.initialSurface)
        XCTAssertFalse(configuration.screenshotModeEnabled)
    }

    @MainActor
    func testParsesScreenshotModeStrictly() {
        let bootstrapper = AppBootstrapper()

        XCTAssertTrue(
            bootstrapper.debugLaunchConfiguration(arguments: ["Ambitions", "-AmbitionsScreenshotMode", "YES"]).screenshotModeEnabled
        )
        XCTAssertTrue(
            bootstrapper.debugLaunchConfiguration(arguments: ["Ambitions", "-AmbitionsScreenshotMode", "yes"]).screenshotModeEnabled
        )
        XCTAssertFalse(
            bootstrapper.debugLaunchConfiguration(arguments: ["Ambitions", "-AmbitionsScreenshotMode", "No"]).screenshotModeEnabled
        )
        XCTAssertFalse(
            bootstrapper.debugLaunchConfiguration(arguments: ["Ambitions"]).screenshotModeEnabled
        )
    }

    @MainActor
    func testDoesNotSelectCaptureOrLegacySurfaces() {
        let bootstrapper = AppBootstrapper()
        let captureLikeInputs = [
            ["Ambitions", "-AmbitionsInitialSurface", "capture"],
            ["Ambitions", "-AmbitionsInitialSurface", "captures"],
            ["Ambitions", "-AmbitionsInitialSurface", "pulse"],
            ["Ambitions", "-AmbitionsInitialSurface", "plan"],
            ["Ambitions", "-AmbitionsInitialSurface", "habits"],
            ["Ambitions", "-AmbitionsInitialSurface", "insights"]
        ]

        for arguments in captureLikeInputs {
            let configuration = bootstrapper.debugLaunchConfiguration(arguments: arguments)

            XCTAssertNil(configuration.initialSurface)
        }
    }
}
